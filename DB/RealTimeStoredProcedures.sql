USE [YourScreensBoxOffice]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetAvailableSeatsByShow]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetAvailableSeatsByShow]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--[GetAvailableSeatsByShow] 779

CREATE Procedure [dbo].[GetAvailableSeatsByShow]
(
@ShowID INT
)
AS
BEGIN
	IF NOT EXISTS (SELECT ShowID FROM Show WHERE ShowID = @showID AND (IsRealTime = 1 OR IsCancel = 0))
	BEGIN
		SELECT 'Fail'
		RETURN
	END

	SELECT STUFF((SELECT ',' + SeatClassInfo FROM Seat WHERE ShowID = @ShowID AND StatusType = 0 AND QuotaType <> 1 AND SeatType <> 1 FOR XML PATH('')),1,1,'') As AvailableSeats, STUFF((SELECT ',' + SeatClassInfo FROM Seat WHERE ShowID = @ShowID AND StatusType = 4 AND SeatType <> 1 FOR XML PATH('')),1,1,'') As NotAvailableSeats
END
GO

/*BlockSeats*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BlockSeats]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BlockSeats]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BlockSeats]
(
	@showID INT,
	@blockCode NVARCHAR(36),
	@blockDuration INT,
	@seatList NVARCHAR(MAX),
	@unpaidBookingCode NVARCHAR(8)
)
AS
BEGIN
	DECLARE @isDisplaySeatNos BIT

	SELECT @isDisplaySeatNos = IsDisplaySeatNos FROM Show WHERE ShowID = @showID AND (IsRealTime = 1 OR IsCancel = 0 OR IsPaused = 0)

	IF @isDisplaySeatNos IS NULL
	BEGIN
		SELECT 'Fail'
		RETURN
	END
	
	SET XACT_ABORT ON
	DECLARE @blockedOn DATETIME
	SET @blockedOn = GETDATE()

	BEGIN TRAN
		IF @blockCode <> ''
		BEGIN
			SELECT @blockedOn = BlockedOn FROM BlockHistory WHERE BlockCode = @blockCode
			IF @blockedOn IS NOT NULL
			BEGIN
				UPDATE Seat SET StatusType = 0 WHERE StatusType = 4 AND QuotaType <> 1 AND SeatType <> 1 AND ShowID = @showID AND SeatID IN
				(SELECT SeatID FROM BlockHistory WHERE BlockCode = @blockCode AND BlockedById = 0 AND ShowID = @showID)
			
				DELETE FROM BlockHistory WHERE BlockCode = @blockCode AND BlockedById = 0 AND ShowID = @showID
			END
			ELSE
				SET @blockCode = NEWID()
		END
		ELSE
			SET @blockCode = NEWID()

		IF @unpaidBookingCode <> ''
		BEGIN
			IF EXISTS(SELECT SeatId FROM BlockHistory WHERE ShowId = @showID AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID))
			BEGIN
				SELECT 'Fail'
				SET @blockCode = NULL
			END
			ELSE
				INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
				SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, @blockedOn, DATEADD(ss, @blockDuration, GETDATE())
				FROM Seat WHERE ShowID = @showID AND StatusType = 6
				AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID)
		END
		ELSE
		BEGIN
			SELECT items, S.ClassID INTO #RequestSeats FROM dbo.FnSplit(@seatList, ',') SL, Seat S WHERE S.SeatClassInfo = SL.items AND S.ShowID = @showID

			IF @isDisplaySeatNos = 0
			BEGIN
				;WITH TempSeat(ShowID, SeatID, ClassID, SeatClassInfo, RowNumber)
				AS
				(
					SELECT ShowID, SeatID, ClassID, SeatClassInfo, ROW_NUMBER() OVER (PARTITION BY ClassID ORDER BY SeatType, SeatID)
					FROM Seat WITH (HOLDLOCK, ROWLOCK) WHERE ShowID = @showID AND StatusType = 0 AND QuotaType <> 1 AND SeatType <> 1
				)

				INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
				SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, @blockedOn, DATEADD(ss, @blockDuration, GETDATE())
				FROM TempSeat S, (SELECT COUNT(items) AS RequestSeatCount, ClassID FROM #RequestSeats GROUP BY ClassID) A
				WHERE RowNumber <= RequestSeatCount AND S.ClassID = A.ClassID

				UPDATE Seat SET StatusType = 4 WHERE ShowID = @showID AND SeatID IN (SELECT SeatID FROM BlockHistory WHERE BlockCode = @blockCode AND BlockedById = 0 AND ShowID = @showID)
			END
			ELSE
			BEGIN
				SELECT SeatID, SeatClassInfo, SeatType INTO #AvailableSeats FROM Seat WITH (HOLDLOCK, ROWLOCK) WHERE ShowID = @showID AND 
				SeatClassInfo IN (SELECT Items FROM #RequestSeats) AND StatusType = 0 AND QuotaType <> 1 AND SeatType <> 1 ORDER BY SeatID

				--To handle couple seat
				IF ((SELECT COUNT(SeatID) FROM #AvailableSeats WHERE SeatType = 2)%2 <> 0)
					DELETE FROM #AvailableSeats WHERE SeatType = 2

				DELETE FROM #RequestSeats WHERE Items NOT IN (SELECT SeatClassInfo FROM #AvailableSeats)

				DROP TABLE #AvailableSeats

				UPDATE Seat SET StatusType = 4 WHERE ShowID = @showID AND SeatClassInfo IN (SELECT Items FROM #RequestSeats) AND StatusType = 0 
				AND QuotaType <> 1 AND SeatType <> 1 
	
				INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
				SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, @blockedOn, DATEADD(ss, @blockDuration, GETDATE())
				FROM Seat WHERE ShowID = @showID AND StatusType = 4 AND QuotaType <> 1 AND SeatType <> 1 AND SeatClassInfo IN (SELECT Items FROM #RequestSeats)
			END
			DROP TABLE #RequestSeats
		END
	COMMIT TRAN
	
	IF @blockCode IS NOT NULL
		SELECT @blockCode, STUFF((SELECT ',' + SeatClassInfo FROM BlockHistory WHERE BlockCode = @blockCode AND BlockedById = 0 AND ShowID = @showID FOR XML PATH('')),1,1,'') AS AvailableSeats
	
	SET XACT_ABORT OFF
END
GO

/*CancelBlock*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CancelBlock]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[CancelBlock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CancelBlock]
(
	@showID INT,
	@blockCode NVARCHAR(36)
)
AS
BEGIN
	
	IF NOT EXISTS(SELECT ShowId FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode AND SeatClassInfo IN (SELECT SeatClassInfo FROM BookHistory WHERE BlockCode = @blockCode))
	BEGIN
		UPDATE Seat SET StatusType = 0 WHERE ShowId = @showID AND StatusType = 4 AND SeatClassInfo IN (SELECT SeatClassInfo FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode)
		DELETE FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode
		SELECT 'Success'
	END
	ELSE
		SELECT 'Fail'
END
GO

/*[ExtendBlock]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExtendBlock]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ExtendBlock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[ExtendBlock] 918, '70EC5AB6-8518-4F5F-8AE4-6C2BF146F1A0', 239, 1200, 'BALCONY_A26'
CREATE PROCEDURE [dbo].[ExtendBlock]
	@showID INT,
	@blockCode NVARCHAR(36),
	@extendBlockDuration INT,
	@maxBlockDuration INT,
	@seatList NVARCHAR(MAX),
	@unpaidBookingCode NVARCHAR(8)
AS
BEGIN
	SET XACT_ABORT ON
	SELECT items into #RequestSeats FROM dbo.FnSplit(@seatList, ',')
	
	IF EXISTS (SELECT BlockCode FROM BlockHistory WITH (HOLDLOCK, ROWLOCK) WHERE ShowId = @showID AND BlockCode = @blockCode)
	BEGIN
		DECLARE @maxBlockTime DATETIME
		SELECT @maxBlockTime = DATEADD(ss, @maxBlockDuration, BlockedOn) FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode
		
		IF (@maxBlockTime > GETDATE())
		BEGIN	
			IF (@maxBlockTime > DATEADD(ss, @extendBlockDuration, GETDATE()))
			BEGIN
				UPDATE BlockHistory SET ExpiresAt = DATEADD(ss, @extendBlockDuration, GETDATE()) WHERE ShowId = @showID AND BlockCode = @blockCode
				SELECT 'Success', @extendBlockDuration
			END
			ELSE
			BEGIN
				UPDATE BlockHistory SET ExpiresAt = DATEADD(ss, DATEDIFF(ss, GETDATE(), @maxBlockTime), GETDATE()) WHERE ShowId = @showID AND BlockCode = @blockCode
				SELECT 'Success', DATEDIFF(ss, GETDATE(), @maxBlockTime)
			END
		END
		ELSE
			SELECT 'Fail'
	END
	ELSE
	BEGIN
		BEGIN TRAN
			IF @unpaidBookingCode <> ''
			BEGIN
				IF EXISTS(SELECT SeatId FROM BlockHistory WHERE ShowId = @showID AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID))
				BEGIN
					SELECT 'Fail'
				END
				ELSE
					INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
					SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, GETDATE(), DATEADD(ss, @extendBlockDuration, GETDATE())
					FROM Seat WHERE ShowID = @showID AND StatusType = 6
					AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID)
					SELECT 'Success', @extendBlockDuration
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT SeatId FROM Seat WHERE StatusType <> 0 AND SeatClassInfo IN (SELECT items FROM #RequestSeats))
				BEGIN
					SELECT 'Fail'
				END
				ELSE
				BEGIN
					UPDATE Seat SET StatusType = 4 WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
					INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
					SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, GETDATE(), DATEADD(ss, @extendBlockDuration, GETDATE()) FROM Seat WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
					SELECT 'Success', @extendBlockDuration
				END
			END
		COMMIT TRAN
	END
	SET XACT_ABORT OFF
END	
GO

/*ConfirmOrder*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ConfirmOrder]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ConfirmOrder]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ConfirmOrder]
(
	@showID INT,
	@patronInfo NVARCHAR(100),
	@blockCode NVARCHAR(36),
	@bookingCode NVARCHAR(8),
	@seatList NVARCHAR(MAX),
	@unpaidBookingCode NVARCHAR(8)
)
AS
BEGIN
	IF EXISTS(SELECT BlockCode FROM BookHistory WHERE ShowId = @showID AND BlockCode = @blockCode)
	BEGIN
		SELECT DISTINCT BOBookingCode FROM BookHistory WHERE ShowId = @showID AND BlockCode = @blockCode
		RETURN
	END

	DECLARE @isReturn BIT
	DECLARE @isAdvanceToken BIT
	SELECT items INTO #RequestSeats FROM dbo.FnSplit(@seatList, ',')

	BEGIN TRY
		IF @unpaidBookingCode <> ''
		BEGIN
			IF EXISTS(SELECT items FROM #RequestSeats EXCEPT SELECT SeatClassInfo FROM UnpaidBookings WHERE ShowId = @showID AND BookingCode = @unpaidBookingCode)
				RAISERROR('Seats mismatch', 11, 1)
			ELSE IF EXISTS(SELECT SeatClassInfo FROM UnpaidBookings WHERE ShowId = @showID AND BookingCode = @unpaidBookingCode EXCEPT SELECT items FROM #RequestSeats)
				RAISERROR('Seats mismatch', 11, 1)
		END
	
		IF NOT EXISTS(SELECT ShowId FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode)
		BEGIN
			IF @unpaidBookingCode <> ''
			BEGIN
				IF EXISTS (SELECT SeatId FROM BlockHistory WHERE ShowId = @showID AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID))
					RAISERROR('Seats unavailable', 11, 1)
			END
			ELSE IF EXISTS (SELECT SeatId FROM Seat WITH (HOLDLOCK, ROWLOCK) WHERE StatusType <> 0 AND SeatClassInfo IN (SELECT items FROM #RequestSeats) AND ShowID = @showID)
				RAISERROR('Seats unavailable', 11, 1)
		END

		SET @isAdvanceToken = (SELECT IsAdvanceToken FROM Show WHERE ShowID = @showID AND (IsRealTime = 1 OR IsCancel = 0 OR IsPaused = 0))

		IF @isAdvanceToken IS NULL
			RAISERROR('Invalid session', 11, 1)
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		SET @isReturn = 1
	END CATCH

	IF @isReturn = 1
	BEGIN
		SELECT ''
		RETURN
	END

	IF @unpaidBookingCode <> ''
	BEGIN
		SET @isAdvanceToken = 0
		SET @bookingCode = @unpaidBookingCode
	END

	SET XACT_ABORT ON
	BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @currentDate DATETIME = GETDATE()

		IF EXISTS(SELECT ShowId FROM BlockHistory WITH (HOLDLOCK, ROWLOCK) WHERE ShowId = @showID AND BlockCode = @blockCode)
		BEGIN
			DELETE FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode AND SeatClassInfo NOT IN (SELECT items FROM #RequestSeats)

			SET @patronInfo = @bookingCode + @patronInfo
		
			IF @isAdvanceToken = 1
			BEGIN
				UPDATE Seat SET PatronInfo = @patronInfo, StatusType = 1, QuotaType = 3, TicketID = (SELECT TOP 1 SeatId FROM BlockHistory WHERE BlockCode = @blockCode AND ShowId = @showID ORDER BY SeatId) 
				WHERE StatusType = 4 AND SeatId IN (SELECT SeatId FROM BlockHistory WHERE BlockCode = @blockCode AND ShowId = @showID)
			END
			ELSE
			BEGIN			
				DECLARE @transactionID1 VARCHAR(10)
				
				SELECT S.SeatID, S.PriceCardID, PC.ItemID, PC.ItemPriceID, PC.Quantity, PC.DiscountPerItem, S.ShowID, SC.ComplexID INTO #tempSeat1 
				FROM PriceCardItemDetails PC, Screen SC, BlockHistory Bh, Seat S WHERE 
				Bh.BlockCode = @blockCode AND Bh.ShowId = @showID AND Bh.SeatId = S.SeatId AND S.StatusType IN (4,6) AND S.PriceCardID = PC.PriceCardID 
				AND S.ScreenID = SC.ScreenID 
				
				IF EXISTS(SELECT TOP 1 SeatID FROM #tempSeat1)
				BEGIN				
					DECLARE @isDuplicate1 BIT = 1
					WHILE (@isDuplicate1 > 0)
					BEGIN
						SELECT @transactionID1 = RIGHT(NEWID(), 10)
						IF NOT EXISTS(SELECT TransactionID FROM ItemSalesHistory WHERE TransactionID = @transactionID1)
							SET @isDuplicate1 = 0
					END
					
					INSERT INTO ItemSalesHistory (TransactionID, ItemID, ItemPriceID, Quantity, OrderType, PaymentType, ItemStockID, ComplexID, SoldBy, SoldOn, DiscountPerItem, SeatID, IsBlocked)
					SELECT @transactionID1, ItemID, ItemPriceID, Quantity, 3, 1, 0, ComplexID, 0, @currentDate, DiscountPerItem, SeatID, 1 FROM
					#tempSeat1
					
					SELECT I.ItemID, SUM(t.Quantity) AS Quantity INTO #ItemQuantity1 FROM #tempSeat1 t, Items I WHERE I.ItemID = t.ItemID GROUP BY I.ItemID
					
					UPDATE I SET I.BlockedStock = I.BlockedStock + IQ.Quantity FROM Items I, #ItemQuantity1 IQ WHERE I.ItemID = IQ.ItemID
					DROP TABLE #ItemQuantity1
				END
				
				INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, BOBookingCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID)
				SELECT Bh.ShowId, Bh.SeatId, Bh.SeatClassInfo, @blockCode, @bookingCode, @patronInfo, 0, @currentDate, 1, S.PriceCardId, CASE WHEN S.SeatID IN (SELECT TS.SeatID FROM #tempSeat1 TS) THEN @transactionID1 ELSE NULL END FROM BlockHistory Bh, Seat S WHERE 
				Bh.BlockCode = @blockCode AND Bh.ShowId = @showID AND Bh.SeatId = S.SeatId AND S.StatusType IN (4,6)
				
				DROP TABLE #tempSeat1
				
				UPDATE Seat SET PatronInfo = @patronInfo, StatusType = 2, QuotaType = 3, TicketID = (SELECT TOP 1 SeatId FROM BookHistory WHERE BlockCode = @blockCode AND ShowId = @showID AND BOBookingCode = @bookingCode), LastSoldOn = @currentDate, PaymentType = 1
				WHERE StatusType IN (4,6) AND SeatId IN (SELECT SeatId FROM BookHistory WHERE BlockCode = @blockCode AND ShowId = @showID AND BOBookingCode = @bookingCode)
			END
		END
		ELSE
		BEGIN
			SET @patronInfo = @bookingCode + @patronInfo

			IF @isAdvanceToken = 1 
			BEGIN
				UPDATE Seat SET PatronInfo = @patronInfo, StatusType = 1, QuotaType = 3, TicketID = (SELECT TOP 1 SeatId FROM Seat WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats))
				WHERE ShowID = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)

				INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
				SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, @currentDate, @currentDate FROM Seat WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
			END
			ELSE
			BEGIN			
				DECLARE @transactionID VARCHAR(10)
				
				SELECT S.SeatID, S.PriceCardID, PC.ItemID, PC.ItemPriceID, PC.Quantity, PC.DiscountPerItem, S.ShowID, SC.ComplexID INTO #tempSeat FROM Seat S, PriceCardItemDetails PC, Screen SC WHERE S.ShowId = @showID AND S.SeatClassInfo IN (SELECT items FROM #RequestSeats) AND S.PriceCardID = PC.PriceCardID AND S.ScreenID = SC.ScreenID 
				
				IF EXISTS(SELECT TOP 1 SeatID FROM #tempSeat)
				BEGIN				
					DECLARE @isDuplicate BIT = 1
					WHILE (@isDuplicate > 0)
					BEGIN
						SELECT @transactionID = RIGHT(NEWID(), 10)
						IF NOT EXISTS(SELECT TransactionID FROM ItemSalesHistory WHERE TransactionID = @transactionID)
							SET @isDuplicate = 0
					END
					
					INSERT INTO ItemSalesHistory (TransactionID, ItemID, ItemPriceID, Quantity, OrderType, PaymentType, ItemStockID, ComplexID, SoldBy, SoldOn, DiscountPerItem, SeatID, IsBlocked)
					SELECT @transactionID, ItemID, ItemPriceID, Quantity, 3, 1, 0, ComplexID, 0, @currentDate, DiscountPerItem, SeatID, 1 FROM
					#tempSeat
					
					SELECT I.ItemID, SUM(t.Quantity) AS Quantity INTO #ItemQuantity FROM #tempSeat t, Items I WHERE I.ItemID = t.ItemID GROUP BY I.ItemID
					
					UPDATE I SET I.BlockedStock = I.BlockedStock + IQ.Quantity FROM Items I, #ItemQuantity IQ WHERE I.ItemID = IQ.ItemID
					DROP TABLE #ItemQuantity
				END
				
				INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, BOBookingCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID)
				SELECT ShowId, SeatId, SeatClassInfo, @blockCode, @bookingCode, @patronInfo, 0, @currentDate, 1, PriceCardId, CASE WHEN SeatID IN (SELECT TS.SeatID FROM #tempSeat TS) THEN @transactionID ELSE NULL END FROM Seat WHERE 
				ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
				
				DROP TABLE #tempSeat
				
				UPDATE Seat SET PatronInfo = @patronInfo, StatusType = 2, QuotaType = 3, TicketID = (SELECT TOP 1 SeatId FROM BookHistory WHERE BlockCode = @blockCode AND ShowId = @showID AND BOBookingCode = @bookingCode), LastSoldOn = @currentDate, PaymentType = 1
				WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)

				INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
				SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, @currentDate, @currentDate FROM Seat WHERE 
				ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
			END
		END

		IF @isAdvanceToken = 1
		BEGIN
			SELECT BH.SeatClassInfo, R.items INTO #validationBlock FROM BlockHistory BH FULL OUTER JOIN #RequestSeats R ON BH.SeatClassInfo=R.items WHERE BH.BlockCode = @blockCode
			IF EXISTS(SELECT SeatClassInfo FROM #validationBlock WHERE SeatClassInfo IS NULL OR items IS NULL)
			BEGIN
				DROP TABLE #validationBlock
				RAISERROR('Seats mismatch', 11, 1)
			END

			SELECT TOP 1 items FROM dbo.FnSplit((SELECT PatronInfo FROM Seat WHERE SeatId IN (SELECT SeatId FROM BlockHistory WHERE BlockCode = @blockCode AND ShowId = @showID) GROUP BY PatronInfo), '|')A
		END
		ELSE
		BEGIN
			SELECT BH.SeatClassInfo, R.items INTO #validation FROM BookHistory BH FULL OUTER JOIN #RequestSeats R ON BH.SeatClassInfo=R.items WHERE BH.BOBookingCode = @bookingCode
			IF EXISTS(SELECT SeatClassInfo FROM #validation WHERE SeatClassInfo IS NULL OR items IS NULL)
			BEGIN
				DROP TABLE #validation
				RAISERROR('Seats mismatch', 11, 1)
			END

			SELECT DISTINCT BOBookingCode FROM BookHistory WHERE ShowId = @showID AND BOBookingCode = @bookingCode
		END
		
		DROP TABLE #RequestSeats
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		RAISERROR('Unable to confirm order', 11, 1)
	END CATCH
	SET XACT_ABORT OFF
END
GO

/*GenerateBill*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateBill]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GenerateBill]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GenerateBill]
(
@SessionID VARCHAR(50),
@ShowID INT,
@blockCode NVARCHAR(36),
@seatList NVARCHAR(MAX),
@unpaidBookingCode NVARCHAR(8)
)
AS
BEGIN
	DECLARE @IsReturn BIT = 0
	SELECT items into #RequestSeats FROM dbo.FnSplit(@seatList, ',')

	IF @unpaidBookingCode <> ''
	BEGIN
		IF EXISTS(SELECT items FROM #RequestSeats EXCEPT SELECT SeatClassInfo FROM UnpaidBookings WHERE ShowId = @showID AND BookingCode = @unpaidBookingCode)
		BEGIN 
			SELECT 'Fail'
			RETURN
		END
		IF EXISTS(SELECT SeatClassInfo FROM UnpaidBookings WHERE ShowId = @showID AND BookingCode = @unpaidBookingCode EXCEPT SELECT items FROM #RequestSeats)
		BEGIN 
			SELECT 'Fail'
			RETURN
		END
		IF NOT EXISTS(SELECT ShowId FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode)
		BEGIN 
			SET XACT_ABORT ON
			BEGIN TRAN
				IF EXISTS (SELECT SeatId FROM BlockHistory WHERE ShowId = @showID AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID))
					SET @IsReturn = 1
				ELSE
				BEGIN
					INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
					SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, GETDATE(), DATEADD(ss, 120, GETDATE()) FROM Seat 
					WHERE ShowId = @showID AND SeatId IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @unpaidBookingCode AND ShowId = @showID)
				END
			COMMIT TRAN
			SET XACT_ABORT OFF

			IF( @IsReturn = 1)
			BEGIN
				SELECT 'Fail'
				RETURN
			END
		END
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT ShowId FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode)
		BEGIN
			SET XACT_ABORT ON
			BEGIN TRAN
				IF EXISTS (SELECT SeatId FROM Seat WITH (HOLDLOCK, ROWLOCK) WHERE StatusType <> 0 AND SeatClassInfo IN (SELECT items FROM #RequestSeats))
					SET @IsReturn = 1
				ELSE
				BEGIN
					UPDATE Seat SET StatusType = 4 WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
					INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
					SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, GETDATE(), DATEADD(ss, 120, GETDATE()) FROM Seat WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
				END
			COMMIT TRAN
			SET XACT_ABORT OFF

			IF( @IsReturn = 1)
			BEGIN
				SELECT 'Fail'
				RETURN
			END
		END
	
		IF EXISTS(SELECT items FROM #RequestSeats EXCEPT SELECT SeatClassInfo FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode)
		BEGIN
			SET XACT_ABORT ON
			BEGIN TRAN
				IF EXISTS (SELECT SeatId FROM Seat WITH (HOLDLOCK, ROWLOCK) WHERE StatusType <> 0 AND SeatClassInfo IN (SELECT items FROM #RequestSeats EXCEPT SELECT SeatClassInfo FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode))
					SET @IsReturn = 1
				ELSE
				BEGIN
					DELETE FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode
					UPDATE Seat SET StatusType = 4 WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
					INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt])
					SELECT ShowID, SeatID, SeatClassInfo, '', @blockCode, 0, GETDATE(), DATEADD(ss, 120, GETDATE()) FROM Seat WHERE ShowId = @showID AND SeatClassInfo IN (SELECT items FROM #RequestSeats)
				END
			COMMIT TRAN
			SET XACT_ABORT OFF

			IF( @IsReturn = 1)
			BEGIN
				SELECT 'Fail'
				RETURN
			END
		END
	
		IF EXISTS(SELECT SeatClassInfo FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode EXCEPT SELECT items FROM #RequestSeats)
		BEGIN
			SET XACT_ABORT ON
			BEGIN TRAN
					UPDATE Seat SET StatusType = 0 WHERE ShowId = @showID AND SeatClassInfo IN (SELECT SeatClassInfo FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode EXCEPT SELECT items FROM #RequestSeats)
					DELETE FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode AND SeatClassInfo IN (SELECT SeatClassInfo FROM BlockHistory WHERE ShowId = @showID AND BlockCode = @blockCode EXCEPT SELECT items FROM #RequestSeats)
			COMMIT TRAN
			SET XACT_ABORT OFF
		END
	END

	
	DECLARE @IsAdvanceToken BIT = (SELECT IsAdvanceToken FROM Show WHERE ShowID = @ShowID)
	DECLARE @PriceDetails NVARCHAR(MAX)
	
	-- Zero PC is not applicable for Advance Token 
	IF @unpaidBookingCode <> ''
		SET @IsAdvanceToken = 0
	
	SELECT @PriceDetails = COALESCE(@PriceDetails + ',' , '') + 
	'{
	"seatId":"'+ S.SeatClassInfo +'",
	"seatClass":"'+ (SELECT ClassName FROM Class WHERE ClassID = S.ClassID) +'",
	"priceCardId":"'+CAST(P.Id AS VARCHAR)+'",
	"total":'+CAST(P.Amount AS VARCHAR)+ ',
	"priceCardLineItems":[' + (CASE WHEN @IsAdvanceToken = 0 THEN SUBSTRING([dbo].[GetFullPriceCardDetailsByID](P.Id ),2,LEN([dbo].[GetFullPriceCardDetailsByID](P.Id ))) ELSE '' END)+ ']
	}'
	FROM PriceCard P
	INNER JOIN Seat S ON S.ShowID = @ShowID AND S.SeatClassInfo IN (SELECT items FROM #RequestSeats) AND P.Id = (CASE WHEN @IsAdvanceToken = 0 THEN S.PriceCardId ELSE 0 END)
	 
	SET @PriceDetails = SUBSTRING(@PriceDetails, 2, LEN(@PriceDetails))
	
	SELECT
	'{
	"sessionID":"' + @SessionID + '",
	"blockCode":"' + @blockCode + '",
	"total":' + CAST(SUM(P.Amount)  AS VARCHAR) + ',
	"breakups":[{' + @PriceDetails + ']}'
	FROM PriceCard P
	INNER JOIN Seat S ON S.ShowID = @ShowID AND S.SeatClassInfo IN (SELECT items FROM #RequestSeats) AND 
	P.Id = (CASE WHEN @IsAdvanceToken = 0 THEN S.PriceCardId ELSE 0 END)
END
GO

/* Release Block Expired Seats */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReleaseBlockExpiredSeats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReleaseBlockExpiredSeats]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReleaseBlockExpiredSeats]
AS
BEGIN
	SELECT ShowID INTO #Temp FROM Show WHERE IsHandoff = 0 
	--delete the expired request which is not booked
	DELETE FROM BlockHistory WHERE GETDATE() >= ExpiresAt AND BlockedById = 0 AND SeatId NOT IN (SELECT SeatId FROM Seat WHERE StatusType IN (1,2,3) AND ShowID IN (SELECT ShowID FROM #Temp)) AND ShowID IN (SELECT ShowID FROM #Temp)
	--updating the seat's status type which is not in blockHistory
	UPDATE Seat SET StatusType = 0 WHERE SeatID NOT IN (select SeatId from BlockHistory WHERE BlockedById = 0) AND StatusType = 4 AND ShowID IN (SELECT ShowID FROM #Temp)
END
GO

/* [GetHandoffSessionsInfo] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetHandoffSessionsInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetHandoffSessionsInfo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[GetHandoffSessionsInfo]
CREATE PROCEDURE [dbo].[GetHandoffSessionsInfo]
AS
BEGIN
IF NOT EXISTS(SELECT Id FROM HandoffDetails)
	IF EXISTS(SELECT ShowId FROM Show WHERE IsRealTime = 1 AND ShowTime > GETDATE() AND IsOnlineSaleClosed = 0 AND OnlineShowId <> '' AND IsCancel = 0 AND IsPaused = 0 AND IsOnlineEdit = 1)
		BEGIN
			--delete the current non-booked block request
			DELETE FROM BlockHistory WHERE BlockedById = 0 AND SeatId IN (SELECT SeatId FROM Seat WHERE StatusType = 4)
			--updating the seat's status type which is not in blockHistory
			UPDATE Seat SET StatusType = 0 WHERE SeatID NOT IN (select SeatId from BlockHistory WHERE BlockedById = 0) AND StatusType = 4

			SELECT SH.ShowID, SH.OnlineShowId, S.SeatClassInfo, S.SeatID INTO #handoffData FROM Seat S WITH (HOLDLOCK, ROWLOCK) INNER JOIN Show SH WITH (HOLDLOCK, ROWLOCK) ON 
			S.ShowID = SH.ShowID WHERE SH.IsRealTime = 1 AND SH.ShowTime > GETDATE() AND SH.IsCancel = 0 AND SH.IsPaused = 0 AND SH.IsOnlineSaleClosed = 0 AND IsOnlineEdit = 1 
			AND SH.OnlineShowId <> '' AND S.StatusType = 0 AND S.SeatType <> 1 AND S.QuotaType <> 1

			UPDATE Show SET IsRealTime = 0, [IsHandoff] = 1 WHERE ShowID IN (SELECT ShowID FROM #handoffData)
			UPDATE Seat SET QuotaType = 3, StatusType = 5 WHERE SeatID IN (SELECT SeatID FROM #handoffData)
			SELECT '{' + 
			STUFF((SELECT ',"' + SH.OnlineShowId + '": [' + 
			STUFF((SELECT ',"' + A.SeatClassInfo + '"' FROM #handoffData A WHERE A.ShowID = SH.ShowId FOR XML PATH('')),1,1,'') + ']'
			FROM Show SH FOR XML PATH('')),1,1,'') + '}'

			DROP TABLE #handoffData
		END	
	END	
GO

/* UpdateHandoffRequestDetails */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateHandoffRequestDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateHandoffRequestDetails
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[UpdateHandoffRequestDetails]
CREATE PROCEDURE [dbo].UpdateHandoffRequestDetails(
@handoffRequestId NVARCHAR(36),
@action NVARCHAR(20))
AS
BEGIN
IF @handoffRequestId <> ''
	IF NOT EXISTS(SELECT Id FROM HandoffDetails WHERE Id = @handoffRequestId)
		INSERT INTO HandoffDetails(Id) VALUES (@handoffRequestId)
	ELSE IF @action = 'ActivationStartedOn'
		UPDATE HandoffDetails SET ActivationStartedOn = GETDATE() WHERE Id = @handoffRequestId  AND ActivationStartedOn IS NULL
	ELSE IF @action = 'ActivationFinishedOn'
		UPDATE HandoffDetails SET ActivationFinishedOn = GETDATE() WHERE Id = @handoffRequestId AND ActivationFinishedOn IS NULL
	ELSE IF @action = 'WithdrawStartedOn'
		UPDATE HandoffDetails SET WithdrawStartedOn = GETDATE() WHERE Id = @handoffRequestId AND WithdrawStartedOn IS NULL
	ELSE IF @action = 'WithdrawFinishedOn'
		UPDATE HandoffDetails SET WithdrawFinishedOn = GETDATE() WHERE Id = @handoffRequestId AND WithdrawFinishedOn IS NULL
END		
GO

/*[GetHandoffShows]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetHandoffShows]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetHandoffShows]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetHandoffShows]
AS
BEGIN
	SELECT ShowID, OnlineShowId FROM Show WHERE [IsHandoff] = 1 ORDER BY ShowID
END
GO

/*[DeleteHandoff]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteHandoff]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeleteHandoff]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteHandoff]
AS
BEGIN
	UPDATE Show SET [IsRealTime] = 1 WHERE [IsHandoff] = 1
	UPDATE Seat SET [QuotaType] = 0, [StatusType] = 0 WHERE [StatusType] = 5 AND ShowId IN (SELECT ShowId FROM Show WHERE [IsHandoff] = 1) AND QuotaType = 3
	UPDATE Show SET [IsHandoff] = 0 WHERE [IsHandoff] = 1
	INSERT INTO Log(TableType, TransactionByID, TransactionByIP, TransactionByName, ObjectID, ObjectName, TransactionDetail, TransactionTime, Action)
	SELECT 21, 0, 0, '', 0, 'Admin', 'Id: ' + Id + ' CreatedOn: ' + CONVERT(NVARCHAR(30), CreatedOn, 113) + ' ActivationStartedOn: ' + CONVERT(NVARCHAR(30), ActivationStartedOn, 113) + ' ActivationFinishedOn: ' + CONVERT(NVARCHAR(30), ActivationFinishedOn, 113) + ' WithdrawalStartedOn: ' + CONVERT(NVARCHAR(30), WithdrawStartedOn, 113) + ' WithdrawalFinishedOn: ' + CONVERT(NVARCHAR(30), WithdrawFinishedOn, 113) + ' DeletedOn: ' + CONVERT(NVARCHAR(30),GETDATE(), 113), GETDATE(), 'HandoffDetails' FROM HandoffDetails
	DELETE FROM HandoffDetails
END
GO

/* UpdateSessionTypeAndStatus */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateSessionTypeAndStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateSessionTypeAndStatus
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[UpdateSessionTypeAndStatus]
CREATE PROCEDURE [dbo].UpdateSessionTypeAndStatus(
@SessionId VARCHAR(64)='',
@Status BIT,
@SessionType BIT,
@OnlineQuota NVARCHAR(MAX))
AS
BEGIN 
	IF @SessionType = 1
	BEGIN
		UPDATE Show SET IsOnlineSaleClosed = @Status, IsRealTime = 1, IsHandoff = 0 WHERE OnlineShowId = @SessionId
		UPDATE Seat SET QuotaType = 0, [StatusType] = 0  WHERE ShowID IN (SELECT ShowId FROM Show WHERE OnlineShowId = @SessionId) AND StatusType = 5 AND QuotaType = 3
	END
	ELSE
	BEGIN
		INSERT INTO Log(TableType, ObjectID, ObjectName, TransactionDetail, Action, TransactionByID, TransactionByIP, TransactionByName, TransactionTime)
		SELECT 6, ShowID, SUBSTRING(ShowName, 1, 16), 'SessionType: Quota, JTID: ' + @SessionId, 'WithdrawStatus', 0, 0, '', GETDATE() FROM Show WHERE OnlineShowId = @SessionId AND IsHandoff = 1

		UPDATE Show SET IsOnlineSaleClosed = @Status, IsRealTime = 0, IsHandoff = 0 WHERE OnlineShowId = @SessionId
		UPDATE Seat SET [StatusType] = 0, QuotaType = 0  WHERE ShowID IN (SELECT ShowId FROM Show WHERE OnlineShowId = @SessionId) AND StatusType = 5 AND QuotaType = 3 AND SeatClassInfo NOT IN (SELECT items FROM dbo.FnSplit(@OnlineQuota, ','))
		UPDATE Seat SET [StatusType] = 0  WHERE ShowID IN (SELECT ShowId FROM Show WHERE OnlineShowId = @SessionId) AND StatusType = 5 AND QuotaType = 3
		IF @Status = 1
			UPDATE Seat SET QuotaType = 0 WHERE ShowId = (SELECT ShowID FROM Show WHERE IsOnlineSaleClosed = 1 AND OnlineShowId = @SessionId) AND QuotaType = 3 AND StatusType = 0
	END
END	
GO

/*[GetRealTimeBOBookings]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetRealTimeBOBookings]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetRealTimeBOBookings]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetRealTimeBOBookings]
AS
BEGIN
	SELECT DISTINCT S.OnlineShowId, BH.BOBookingCode INTO #bh
	FROM Show S, BookHistory BH, Seat SE WHERE
	SE.ShowID = S.ShowID AND
	SE.QuotaType = 3 AND
	S.[IsAdvanceToken] = 0 AND 
	S.OnlineShowId <> '' AND 
	BH.ShowID = S.ShowID AND 
	BH.BOBookingCode IS NOT NULL AND 
	BH.IsReconciled = 0 AND
	BH.BookedOn < DATEADD(minute, -20, GETDATE()) AND
	S.IsHandoff = 0

	INSERT INTO #bh
	SELECT DISTINCT S.OnlineShowId, BH.BOBookingCode
	FROM Show S, BookHistory BH, Seat SE, UnpaidBookings UB WHERE
	SE.ShowID = S.ShowID AND
	SE.QuotaType = 3 AND
	S.[IsAdvanceToken] = 1 AND 
	UB.BookingCode = BH.BOBookingCode AND
	S.OnlineShowId <> '' AND 
	BH.ShowID = S.ShowID AND 
	BH.BOBookingCode IS NOT NULL AND 
	BH.IsReconciled = 0 AND
	BH.BookedOn < DATEADD(minute, -20, GETDATE()) AND
	S.IsHandoff = 0
       
	SELECT DISTINCT #bh.OnlineShowId, (SELECT STUFF((SELECT DISTINCT ',' +  b.BOBookingCode FROM #bh b WHERE b.OnlineShowId = #bh.OnlineShowId FOR XML PATH('')),1,1,'')) AS BookingCode 
	FROM #bh 
	DROP TABLE #bh
END
GO


/*[DeleteNonSyncedBOBookings]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteNonSyncedBOBookings]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeleteNonSyncedBOBookings]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteNonSyncedBOBookings](
@BOBookingCode VARCHAR(8),
@onlineShowID NVARCHAR(64)
)
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @BookedOn DATETIME = DATEADD(minute, -20, GETDATE())
		DECLARE @showID INT
		SELECT @showID = ShowID FROM Show WHERE OnlineShowID = @onlineShowID
		IF EXISTS (SELECT SeatID FROM BookHistory WHERE BOBookingCode = @BOBookingCode AND BookedOn < @BookedOn AND ShowID = @showID)
		BEGIN
			DECLARE @patronInfo VARCHAR(256) = NULL
			SELECT TOP 1 @patronInfo = BookingCode + '|' + EmailId + '|' + CAST(MobileNumber AS VARCHAR) + '|' + UserName  + '||' FROM UnpaidBookings WHERE BookingCode = @BOBookingCode AND ShowId = @showID

			IF @patronInfo IS NOT NULL
			BEGIN
				UPDATE Seat SET StatusType = 6, QuotaType = 0, PatronInfo = @patronInfo, LastSoldOn = NULL 
				WHERE SeatID IN (SELECT SeatId FROM UnpaidBookings WHERE BookingCode = @BOBookingCode AND ShowId = @showID) 
				AND SeatID IN (SELECT SeatID FROM BookHistory WHERE BOBookingCode = @BOBookingCode AND ShowID = @showID) AND ShowID = @showID
			END
			ELSE
				UPDATE Seat SET StatusType = 0, QuotaType = 0, LastSoldOn = NULL WHERE SeatID IN (SELECT SeatID FROM BookHistory WHERE BOBookingCode = @BOBookingCode AND ShowID = @showID) AND ShowID = @showID

			INSERT INTO [BookingsReconcilliation](ShowID, SeatID, [SeatClassInfo], BlockCode, BOBookingCode, PatronInfo, BookedOn, PriceCardId, DeletedOn)
			SELECT ShowID, SeatID, [SeatClassInfo], BlockCode, BOBookingCode, PatronInfo, BookedOn, PriceCardId, GETDATE() FROM BookHistory WHERE BOBookingCode = @BOBookingCode AND ShowID = @showID

			INSERT INTO Log(TableType, TransactionByID, TransactionByIP, TransactionByName, ObjectID, ObjectName, TransactionDetail, TransactionTime, Action)
			SELECT 21, 0, 0, '', 0, 'Admin', 'ShowId: ' + CAST(@showID AS VARCHAR) + ' BOBookingCode: ' + @BOBookingCode, GETDATE(), 'BookingsRecon'

			DELETE FROM BookHistory WHERE BOBookingCode = @BOBookingCode AND ShowID = @showID
		END
	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
END CATCH
END
GO

/* [CanProcessAutomaticHandoff] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CanProcessAutomaticHandoff]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].CanProcessAutomaticHandoff
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[CanProcessAutomaticHandoff] 0
CREATE PROCEDURE [dbo].CanProcessAutomaticHandoff
(
@IsUpdateLastHandoffDate BIT
)
AS
BEGIN
DECLARE @isEligible BIT = 0
IF NOT EXISTS(SELECT LastAutomaticHandoffDate FROM Complex WHERE LastAutomaticHandoffDate = CONVERT(VARCHAR(10),GETDATE(),110))
	IF EXISTS(SELECT TOP 1 HandoffTime FROM Complex WHERE HandoffTime < CONVERT(VARCHAR(12),GETDATE(),114))
		IF NOT EXISTS(SELECT TOP 1 BookingCode FROM UnpaidBookings WHERE ShowId IN (SELECT ShowId FROM Show WHERE IsRealTime = 1 AND ShowTime > GETDATE()))
		BEGIN
			SET @isEligible = 1
			IF (@IsUpdateLastHandoffDate = 1)
				UPDATE Complex SET LastAutomaticHandoffDate = CONVERT(VARCHAR(10),GETDATE(),110)
		END

SELECT @isEligible
END
GO

/*[UpdateReconStatus]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateReconStatus]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateReconStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateReconStatus](
@BOBookingCode VARCHAR(8),
@onlineShowID NVARCHAR(64)
)
AS
BEGIN
	DECLARE @showID INT
	SELECT @showID = ShowID FROM Show WHERE OnlineShowID = @onlineShowID
	IF EXISTS (SELECT SeatID FROM BookHistory WHERE BOBookingCode = @BOBookingCode AND BookedOn < DATEADD(minute, -20, GETDATE()) AND ShowID = @showID)
		UPDATE BookHistory SET IsReconciled = 1 WHERE BOBookingCode = @BOBookingCode AND ShowID = @showID
END
GO