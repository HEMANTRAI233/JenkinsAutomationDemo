USE [YourScreensBoxOffice]
GO

/* [spSeatEditUnBlock] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSeatEditUnBlock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSeatEditUnBlock]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSeatEditUnBlock]
	@SeatIDs VARCHAR(256)
AS
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRANSACTION

		UPDATE Seat SET  TicketID = 0, 
					StatusType = 0, 
					NoBlocks = (case when NoBlocks = 0 then 0 else NoBlocks - 1 end), 
					LastBlockedByID = 0
					WHERE SeatID IN (select * from dbo.fnsplit(@SeatIDs, ','))
					AND StatusType = 1

	COMMIT TRANSACTION
	RETURN
	ERR_HANDLER:
	ROLLBACK TRANSACTION
	RAISERROR('Not Updated', 11, 1)
	RETURN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSeatEditBlock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSeatEditBlock]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSeatEditBlock]
	@TicketID INT OUTPUT,
	@SeatIDs VARCHAR(256),
	@PatronInfo VARCHAR(256),
	@ReleaseBefore INT,
	@LastBlockedByID INT,
	@LastBlockedOn VARCHAR(256)
AS
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRANSACTION
		DECLARE @SQL NVARCHAR(4000)
		DECLARE @TmpTicketID INT

		SET @TmpTicketID = 0
		SELECT @TmpTicketID = MIN(Seat.SeatID) FROM Seat INNER JOIN Show ON Seat.ShowID = Show.ShowID WHERE Seat.SeatID IN (select * from dbo.fnsplit(@SeatIDs, ',')) AND 
		Seat.StatusType = 0  AND (Seat.QuotaType <> 3 OR GETDATE() > DATEADD(minute, -1 * Seat.ReleaseBefore, Show.ShowTime))

		IF @@ERROR <> 0 OR @@ROWCOUNT = 0 OR @TmpTicketID = 0 GOTO ERR_HANDLER

		UPDATE Seat SET TicketID = CAST(@TmpTicketID AS VARCHAR(10)), StatusType = 1 , PatronInfo = @PatronInfo , ReleaseBefore = CAST(@ReleaseBefore AS VARCHAR(10)), 
					NoBlocks = NoBlocks + 1, LastBlockedByID = CAST(@LastBlockedByID AS VARCHAR(10)), LastBlockedOn = @LastBlockedOn 
					WHERE SeatID IN (select * from dbo.fnsplit(@SeatIDs, ',')) AND StatusType = 0
		INSERT INTO BlockHistory(ShowId, SeatId, SeatClassInfo, PatronInfo, [BlockCode], [BlockedById], [BlockedOn], [ExpiresAt]) 
			SELECT ShowId, SeatId, SeatClassInfo, PatronInfo, SUBSTRING(PatronInfo, 1, 6) , CAST(@LastBlockedByID AS VARCHAR(10)), @LastBlockedOn, @LastBlockedOn 
				FROM Seat WHERE SeatId IN (select * from dbo.fnsplit(@SeatIDs, ','))
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0 GOTO ERR_HANDLER
		SET @TicketID = @TmpTicketID
	COMMIT TRANSACTION
	RETURN
	ERR_HANDLER:
	ROLLBACK TRANSACTION
	RAISERROR('CONCURRENTFAIL', 11, 1)
	RETURN
GO

/****** Object:  StoredProcedure [dbo].[sp00SearchSP]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp00SearchSP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp00SearchSP]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp00SearchSP]
	@Search VARCHAR(128)
AS
	SELECT DISTINCT sysobjects.Name
	FROM sysobjects INNER JOIN syscomments ON sysobjects.ID = syscomments.ID
	WHERE sysobjects.Name <> 'sp00SearchSP' AND sysobjects.Name LIKE 'sp%'
	AND syscomments.Text LIKE '%' + @Search + '%'
GO

/****** Object:  StoredProcedure [dbo].[spItemNames]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spItemNames]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spItemNames]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spItemNames]
(
@ItemName as Varchar(50)
)
as 
begin 
select distinct ItemName,ItemID from Item where ItemName like '%'+@ItemName+'%'
end
GO

/****** Object:  StoredProcedure [dbo].[spItemIngredientLoad]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spItemIngredientLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spItemIngredientLoad]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spItemIngredientLoad]
	@ItemID INT
AS
	SELECT
		IngredientId,
		ItemId,
		ItemName,
		Quantity,
		Cost,
		Metric 
	FROM ItemIngredient
	WHERE ItemID = @ItemID
GO

/****** Object:  StoredProcedure [dbo].[spItemIngredientEdit]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spItemIngredientEdit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spItemIngredientEdit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spItemIngredientEdit]
	@IngredientId INT,
	@ItemID INT,
	@ItemName VARCHAR(16),
	@Quantity NUMERIC(9,2),
	@Cost NUMERIC(9,2),
	@Metric VARCHAR(50)
AS
	UPDATE ItemIngredient
	SET ItemID = @ItemID,
		ItemName = @ItemName,
		Quantity = @Quantity,
		Cost = @Cost,
		Metric = @Metric 
	WHERE IngredientId = @IngredientId
GO

/****** Object:  StoredProcedure [dbo].[spItemIngredientDelete]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spItemIngredientDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spItemIngredientDelete]
GO
SET ANSI_NULLS ON
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spItemIngredientDelete]
	@ItemId Int,
	@IngredientId VARCHAR(max),
	@ReferredBy VARCHAR(32) OUTPUT
AS
	SET @ReferredBy = ''
	IF EXISTS ( SELECT NULL FROM CanteenIngredient WHERE ItemId=@ItemId and IngredientId not in ( select VALUE from dbo.split(',',@IngredientId) ) )
		SET @ReferredBy = 'CanteenIngredient'
	
	If @ReferredBy = ''
	BEGIN	
		DELETE FROM ItemIngredient WHERE ItemId=@ItemId and IngredientId not in ( select VALUE from dbo.split(',',@IngredientId) )
	END
GO

/****** Object:  StoredProcedure [dbo].[spItemIngredientAdd]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spItemIngredientAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spItemIngredientAdd]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spItemIngredientAdd]
	@IngredientId INT OUTPUT,
	@ItemID INT,
	@ItemName VARCHAR(16),
	@Quantity NUMERIC(9,2),
	@Cost NUMERIC(9,2),
	@Metric VARCHAR(50)
AS
	INSERT INTO ItemIngredient (
		ItemId,
		ItemName,
		Quantity,
		Cost,
		Metric
	) VALUES (
		@ItemId,
		@ItemName,
		@Quantity,
		@Cost,
		@Metric
	); SET @IngredientId = SCOPE_IDENTITY();
	insert into ItemIngredientStock(IngredientId,ItemID,Quantity) values(@IngredientId,@ItemID,@Quantity);
GO

/* [spDCRLoad] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spDCRLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spDCRLoad]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDCRLoad]
	@DCRID INT
AS
	SELECT
		DCRID,
		DCRName,
		DCRStartingNo,
		DCRMax
	FROM DCR
	WHERE DCRID = @DCRID
GO

/* [spDCREdit] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spDCREdit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spDCREdit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDCREdit]
	@DCRID INT,
	@DCRName VARCHAR(32)
AS
	IF EXISTS (SELECT DCRNo FROM DCR WHERE DCRName = @DCRName AND DCRID <> @DCRID)
	BEGIN
		RAISERROR('DCR Name already exists', 11, 1)
		RETURN
	END
	
	UPDATE DCR
	SET DCRName = @DCRName
	WHERE DCRID = @DCRID
GO

/* [spDCRDelete] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spDCRDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spDCRDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDCRDelete]
	@DCRID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		SET @ReferredBy = ''
		IF EXISTS ( SELECT NULL FROM Class WHERE DCRID = @DCRID )
			SET @ReferredBy = 'Class'
		ELSE IF EXISTS ( SELECT NULL FROM ClassMIS WHERE DCRID = @DCRID )
			SET @ReferredBy = 'ClassMIS'
	
		If @ReferredBy = ''
		BEGIN
			DELETE FROM Log
			WHERE TableType = ( SELECT TOP 1 Value FROM Type WHERE TypeNo = 1 AND Expression = 'DCR' )
			AND ObjectID = @DCRID
	
			DELETE FROM DCR
			WHERE DCRID = @DCRID

			DELETE FROM DCRClassLayoutCollections WHERE DCRId = @DCRID
			UPDATE ClassLayout SET DCRId = NULL WHERE DCRId= @DCRID
		END
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
GO

/* [spDCRAdd] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spDCRAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spDCRAdd]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDCRAdd]
	@DCRID INT OUTPUT,
	@DCRName VARCHAR(32),
	@DCRStartingNo INT,
	@DCRMaxNo INT,
	@CreatedBy INT
AS
	IF EXISTS (SELECT DCRNo FROM DCR WHERE DCRName = @DCRName)
	BEGIN
		RAISERROR('DCR Name already exists', 11, 1)
		RETURN
	END
	
	INSERT INTO DCR (
		DCRName,
		DCRStartingNo,
		DCRMax,
		CreatedBy,
		CreatedOn,
		DCRNo,
		DCRCount
	) VALUES (
		@DCRName,
		@DCRStartingNo,
		@DCRMaxNo,
		@CreatedBy,
		GETDATE(),
		@DCRStartingNo - 1,
		@DCRStartingNo - 1
	) SET @DCRID = SCOPE_IDENTITY()
GO


/* [spComplexManage] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spComplexManage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spComplexManage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spComplexManage]
	@TYPE VARCHAR(8)='',
	@ComplexID INT=0,
	@ChainGUID VARCHAR(64),
	@ChainName VARCHAR(64),
	@ComplexCity VARCHAR(32),
	@ComplexState VARCHAR(32),
	@ComplexAddress VARCHAR(64),
	@ComplexGUID VARCHAR(64),
	@ComplexName NVARCHAR(64),
	@TransactionLogType TINYINT,
	@IsStaticIP BIT,
	@StaticIP VARCHAR(128),
	@IsAllowBlocking BIT,
	@NoMaxSeatsPerTicket INT,
	@IsSendSeatSoldEvent BIT,
	@IsSendSeatOccupiedEvent BIT,
	@IsSendSeatCancelledEvent BIT,
	@IsClearExpiredShows BIT,
	@IsFandBBillWithTaxBreakUp BIT,
	@GSTIN VARCHAR(15),
	@SAC INT,
	@IsSC BIT,
	@AT INT,
	@ET INT,
	@IsPrintADP BIT,
	@IsHighlightScreenNameOnTicket BIT,
	@IsDisplaySCNumberDiv BIT,
	@IsDisplayShowNameOn3x3 BIT,
	@IsPrintTandCOn3x3 BIT,
	@IsETaxIncludesFDF BIT,
	@IsPrintETaxIncludesFDF BIT,
	@IsPrintRefundTextOn6x3TktFormat BIT,
	@TheatreType VARCHAR(100),
	@TownType VARCHAR(100)
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
		IF(@TYPE='ADD')
		BEGIN
			IF NOT EXISTS(SELECT ComplexID FROM Complex WHERE ComplexGUID = @ComplexGUID)
			BEGIN
				INSERT INTO Complex (ChainID, ComplexGUID, ComplexName, ComplexType, ComplexAddress1, ComplexAddress2, ComplexCity,
					ComplexState, ComplexCountry, ComplexZip, ComplexPhone, ComplexEmail, TransactionLogType, IsStaticIP, StaticIP,
					BoxOfficeName ,BoxOfficeLicenseType, BoxOfficeLicenseFrom, BoxOfficeLicenseTo, BoxOfficeLicenseKey, IsWebService,
					CentralServerName, CentralServerURL, CentralServerPassword, MovieImageURL, BoxOfficeURL, IsAllowBlocking, NoMaxSeatsPerTicket,
					IsSendSeatSoldEvent, IsSendSeatOccupiedEvent, IsSendSeatCancelledEvent, ChainGUID, ChainName,
					IsClearExpiredShows, IsFandBBillWithTaxBreakUp, GSTIN, SAC, IsSC, AT, ET, IsPrintADP, IsHighlightScreenNameOnTicket, IsETaxIncludesFDF,
					IsPrintETaxIncludesFDF, IsPrintRefundTextOn6x3TktFormat, IsDisplaySCNumberDiv, IsDisplayShowNameOn3x3, IsPrintTandCOn3x3, TheatreType, TownType)
				Values (0, @ComplexGUID, @ComplexName, 0, @ComplexAddress, '', @ComplexCity, @ComplexState, '', '', '', '',
					@TransactionLogType, @IsStaticIP, @StaticIP, '', '', '', '', '', '', '', '', '', '', '', @IsAllowBlocking,
					@NoMaxSeatsPerTicket, @IsSendSeatSoldEvent, @IsSendSeatOccupiedEvent, 
					@IsSendSeatCancelledEvent, @ChainGUID, @ChainName, @IsClearExpiredShows, @IsFandBBillWithTaxBreakUp, @GSTIN, @SAC, @IsSC, @AT, @ET,
					@IsPrintADP, @IsHighlightScreenNameOnTicket, @IsETaxIncludesFDF, @IsPrintETaxIncludesFDF, @IsPrintRefundTextOn6x3TktFormat, @IsDisplaySCNumberDiv, @IsDisplayShowNameOn3x3, @IsPrintTandCOn3x3, @TheatreType, @TownType)
			END
			ELSE
			BEGIN
				RAISERROR('Complex name already exists!',11,1);
				RETURN
			END
		END
		ELSE IF(@TYPE='EDIT')
		BEGIN
			UPDATE Complex
			SET 
				ChainID = 0,
				ComplexGUID = @ComplexGUID,
				ComplexName = @ComplexName,
				ComplexAddress1 = @ComplexAddress,
				ComplexCity = @ComplexCity,
				ComplexType = 0,
				ComplexAddress2 = '',
				ComplexState = @ComplexState,
				ComplexCountry = '',
				ComplexZip = '',
				ComplexPhone = '',
				ComplexEmail = '',
				TransactionLogType = @TransactionLogType,
				IsStaticIP=@IsStaticIP,
				StaticIP=@StaticIP,
				BoxOfficeName = '',
				BoxOfficeLicenseType = '',
				BoxOfficeLicenseFrom = '',
				BoxOfficeLicenseTo = '',
				BoxOfficeLicenseKey = '',
				IsWebService = '',
				CentralServerName = '',
				CentralServerURL = '',
				CentralServerPassword = '',
				MovieImageURL = '',
				BoxOfficeURL = '',
				IsAllowBlocking = @IsAllowBlocking,
				NoMaxSeatsPerTicket = @NoMaxSeatsPerTicket,
				IsSendSeatSoldEvent = @IsSendSeatSoldEvent,
				IsSendSeatOccupiedEvent = @IsSendSeatOccupiedEvent,
				IsSendSeatCancelledEvent = @IsSendSeatCancelledEvent,
				ChainGUID=@ChainGUID,
				ChainName=@ChainName,
				IsClearExpiredShows = @IsClearExpiredShows,
				IsFandBBillWithTaxBreakUp = @IsFandBBillWithTaxBreakUp,
				GSTIN = @GSTIN,
				SAC = @SAC,
				IsSC = @IsSC,
				AT = @AT,
				ET = @ET,
				IsPrintADP = @IsPrintADP,
				IsHighlightScreenNameOnTicket = @IsHighlightScreenNameOnTicket,
				IsDisplaySCNumberDiv = @IsDisplaySCNumberDiv,
				IsDisplayShowNameOn3x3 = @IsDisplayShowNameOn3x3,
				IsPrintTandCOn3x3 = @IsPrintTandCOn3x3,
				IsETaxIncludesFDF = @IsETaxIncludesFDF,
				IsPrintETaxIncludesFDF = @IsPrintETaxIncludesFDF,
				IsPrintRefundTextOn6x3TktFormat = @IsPrintRefundTextOn6x3TktFormat
			WHERE ComplexID = @ComplexID
		END
		UPDATE Complex SET IsSC = @IsSC, AT = @AT, ET = @ET, IsPrintADP = @IsPrintADP, IsHighlightScreenNameOnTicket = @IsHighlightScreenNameOnTicket, 
		IsETaxIncludesFDF = @IsETaxIncludesFDF, IsPrintETaxIncludesFDF = @IsPrintETaxIncludesFDF,
		IsDisplaySCNumberDiv = @IsDisplaySCNumberDiv,
				IsDisplayShowNameOn3x3 = @IsDisplayShowNameOn3x3,
				IsPrintTandCOn3x3 = @IsPrintTandCOn3x3,IsPrintRefundTextOn6x3TktFormat = @IsPrintRefundTextOn6x3TktFormat
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
	SELECT @ComplexID;
END
GO

/* [spComplexUpdate] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spComplexUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spComplexUpdate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spComplexUpdate]
	@ComplexID INT=0,
	@TransactionLogType TINYINT,
	@NoMaxSeatsPerTicket INT,
	@IsClearExpiredShows BIT,
	@IsFandBBillWithTaxBreakUp BIT,
	@GSTIN VARCHAR(15),
	@SAC INT,
	@IsSC BIT,
	@AT INT,
	@ET INT,
	@IsPrintADP BIT,
	@IsHighlightScreenNameOnTicket BIT,
	@IsDisplaySCNumberDiv BIT,
	@IsDisplayShowNameOn3x3 BIT,
	@IsPrintTandCOn3x3 BIT,
	@IsETaxIncludesFDF BIT,
	@IsPrintETaxIncludesFDF BIT,
	@IsPrintRefundTextOn6x3TktFormat BIT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE Complex
				SET 
					TransactionLogType = @TransactionLogType,
					NoMaxSeatsPerTicket= @NoMaxSeatsPerTicket,
					IsClearExpiredShows = @IsClearExpiredShows,
					IsFandBBillWithTaxBreakUp = @IsFandBBillWithTaxBreakUp,
					GSTIN = @GSTIN,
					SAC = @SAC,
					IsSC = @IsSC,
					AT = @AT,
					ET = @ET,
					IsPrintADP = @IsPrintADP,
					IsHighlightScreenNameOnTicket = @IsHighlightScreenNameOnTicket,
					IsDisplaySCNumberDiv = @IsDisplaySCNumberDiv,
					IsDisplayShowNameOn3x3 = @IsDisplayShowNameOn3x3,
					IsPrintTandCOn3x3 = @IsPrintTandCOn3x3,
					IsETaxIncludesFDF = @IsETaxIncludesFDF,
					IsPrintETaxIncludesFDF = @IsPrintETaxIncludesFDF,
					IsPrintRefundTextOn6x3TktFormat = @IsPrintRefundTextOn6x3TktFormat
				WHERE ComplexID = @ComplexID
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
	SELECT @ComplexID;
END
GO

/* [spComplexLoad] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spComplexLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spComplexLoad]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spComplexLoad]
	@BoxOfficeVersion VARCHAR(16),
	@ComplexID int=0
AS
BEGIN
	UPDATE Complex SET BoxOfficeVersion = @BoxOfficeVersion	WHERE ComplexID = @ComplexID
	IF @ComplexID > 0
		SELECT ComplexID, ComplexName, 1 AS ComplexType, ComplexAddress1, '' AS ComplexAddress2, ComplexCity, ComplexState,
			'' AS ComplexCountry, '' AS ComplexZip,	'' AS ComplexPhone,	'' AS ComplexEmail,	TransactionLogType,	LastMaintenanceTime,
			0 AS BoxOfficeID, '' AS BoxOfficeName, '' AS BoxOfficeVersion, '' AS BoxOfficeLicenseType, '' AS BoxOfficeLicenseFrom,
			'' AS BoxOfficeLicenseTo, '' AS BoxOfficeLicenseKey, 0 AS IsWebService,	'' AS CentralServerName, '' AS CentralServerURL,
			'' AS CentralServerPassword, '' AS MovieImageURL, IsAllowBlocking, NoMaxSeatsPerTicket,	IsPrintRefundTextOn6x3TktFormat, IsSendSeatSoldEvent,
			IsSendSeatOccupiedEvent, IsSendSeatCancelledEvent, ISNULL(BoxOfficeURL,''),	ISNULL(IsStaticIP,0), ISNULL(StaticIP,'') AS StaticIP,
			0 AS ChainID, ComplexGUID, ChainGUID, ChainName, IsClearExpiredShows, IsFandBBillWithTaxBreakUp, ISNULL(GSTIN, ''), LockShowTime, IsSC, AT, IsPrintADP,
			IsHighlightScreenNameOnTicket, IsETaxIncludesFDF, IsPrintETaxIncludesFDF, ISNULL(SAC, 0), ET, IsDisplaySCNumberDiv, IsDisplayShowNameOn3x3, IsPrintTandCOn3x3,
			TheatreType, TownType
		FROM Complex
		WHERE ComplexID = @ComplexID
	ELSE
		SELECT TOP 1 ComplexID, ComplexName, 1 AS ComplexType, ComplexAddress1, '' AS ComplexAddress2, ComplexCity, ComplexState,
			'' AS ComplexCountry, '' AS ComplexZip,	'' AS ComplexPhone,	'' AS ComplexEmail,	TransactionLogType,	LastMaintenanceTime,
			0 AS BoxOfficeID, '' AS BoxOfficeName, '' AS BoxOfficeVersion, '' AS BoxOfficeLicenseType, '' AS BoxOfficeLicenseFrom,
			'' AS BoxOfficeLicenseTo, '' AS BoxOfficeLicenseKey, 0 AS IsWebService,	'' AS CentralServerName, '' AS CentralServerURL,
			'' AS CentralServerPassword, '' AS MovieImageURL, IsAllowBlocking, NoMaxSeatsPerTicket,	IsPrintRefundTextOn6x3TktFormat, IsSendSeatSoldEvent,
			IsSendSeatOccupiedEvent, IsSendSeatCancelledEvent, ISNULL(BoxOfficeURL,''),	ISNULL(IsStaticIP,0), ISNULL(StaticIP,'') AS StaticIP,
			0 AS ChainID, ComplexGUID, ChainGUID, ChainName, IsClearExpiredShows, IsFandBBillWithTaxBreakUp, ISNULL(GSTIN, ''), LockShowTime, IsSC, AT, IsPrintADP,
			IsHighlightScreenNameOnTicket, IsETaxIncludesFDF, IsPrintETaxIncludesFDF, ISNULL(SAC, 0), ET, IsDisplaySCNumberDiv, IsDisplayShowNameOn3x3, IsPrintTandCOn3x3,
			TheatreType, TownType
		FROM Complex
		ORDER BY ComplexID
END
GO

/****** Object:  StoredProcedure [dbo].[spComplexEditLastMaintenanceTime]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spComplexEditLastMaintenanceTime]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spComplexEditLastMaintenanceTime]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spComplexEditLastMaintenanceTime]
	@ComplexID INT,
	@LastMaintenanceTime DATETIME
AS
	UPDATE Complex
	SET LastMaintenanceTime = @LastMaintenanceTime
	WHERE ComplexID = @ComplexID
GO
/****** Object:  StoredProcedure [dbo].[spComplexEditComplex]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spComplexEditComplex]
	@ComplexID INT,
	@ComplexName NVARCHAR(32),
	@ComplexType TINYINT,
	@ComplexAddress1 VARCHAR(64),
	@ComplexAddress2 VARCHAR(64),
	@ComplexCity VARCHAR(32),
	@ComplexState VARCHAR(32),
	@ComplexCountry VARCHAR(32),
	@ComplexZip VARCHAR(8),
	@ComplexPhone VARCHAR(32),
	@ComplexEmail VARCHAR(64),
	@TransactionLogType TINYINT,
	@IsStaticIP BIT,
	@StaticIP VARCHAR(128)
AS
	UPDATE Complex
	SET ComplexName = @ComplexName,
		ComplexType = @ComplexType,
		ComplexAddress1 = @ComplexAddress1,
		ComplexAddress2 = @ComplexAddress2,
		ComplexCity = @ComplexCity,
		ComplexState = @ComplexState,
		ComplexCountry = @ComplexCountry,
		ComplexZip = @ComplexZip,
		ComplexPhone = @ComplexPhone,
		ComplexEmail = @ComplexEmail,
		TransactionLogType = @TransactionLogType,
		IsStaticIP=@IsStaticIP,
		StaticIP=@StaticIP 
	WHERE ComplexID = @ComplexID
GO
/****** Object:  StoredProcedure [dbo].[spComplexEditBoxOfficeID]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spComplexEditBoxOfficeID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spComplexEditBoxOfficeID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spComplexEditBoxOfficeID]
	@ComplexID INT,
	@BoxOfficeID INT
AS
	UPDATE Complex
	SET BoxOfficeID = @BoxOfficeID
	WHERE ComplexID = @ComplexID
GO

/* spClassLayoutLoad */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spClassLayoutLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spClassLayoutLoad]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spClassLayoutLoad]
	@ClassLayoutID INT
AS
	SELECT
		ScreenID,
		ClassLayoutID,
		ClassNo,
		ClassName,
		NoRows,
		NoCols,
		NoMaxSeatsPerTicket,
		IsPrintOneTicketPerSeat,
		PrintType,
		PrintOrientationType,
		IsPrintAuditNos,
		IsPrintDCRNo,
		IsPrintSeatLabel,
		AllowedUsers,
		ClassPosition,
		PriceCardId,
		DCRId,
		clout.ClassType,
		ISNULL(prccrd.[Name],'') as 'PriceCardName'
	FROM ClassLayout clout LEFT OUTER JOIN PriceCard prccrd ON clout.PriceCardId = prccrd.Id
	WHERE ClassLayoutID = @ClassLayoutID
GO

/* [spClassLayoutEdit] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spClassLayoutEdit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spClassLayoutEdit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spClassLayoutEdit]
	@ScreenID INT,
	@ClassLayoutID INT,
	@ClassNo VARCHAR(2),
	@ClassName VARCHAR(16),
	@NoMaxSeatsPerTicket INT,
	@IsPrintOneTicketPerSeat BIT,
	@PrintType TINYINT,
	@PrintOrientationType TINYINT,
	@IsPrintAuditNos BIT,
	@IsPrintDCRNo BIT,
	@IsPrintSeatLabel BIT,
	@AllowedUsers VARCHAR(128),
	@UserId Int=0,
	@ClassPosition VARCHAR(4),
	@PriceCardId INT,
	@DCRId INT,
	@ClassType TINYINT
AS
BEGIN
	IF EXISTS (SELECT ScreenID FROM ClassLayout where ScreenID=@ScreenID AND ClassNo=@ClassNo and ClassLayoutID <> @ClassLayoutID)
	BEGIN
		RAISERROR('Class number already exists!', 11, 1)
		RETURN
	END
	IF EXISTS (SELECT ScreenID FROM ClassLayout where ScreenID=@ScreenID AND ClassPosition =@ClassPosition and ClassLayoutID <> @ClassLayoutID)
	BEGIN
		RAISERROR('Class position already exists!', 11, 1)
		RETURN
	END
	
	BEGIN TRY			
		UPDATE ClassLayout
		SET ClassNo = @ClassNo,
			ClassName = @ClassName,
			NoMaxSeatsPerTicket = @NoMaxSeatsPerTicket,
			IsPrintOneTicketPerSeat = @IsPrintOneTicketPerSeat,
			PrintType = @PrintType,
			PrintOrientationType = @PrintOrientationType,
			IsPrintAuditNos = @IsPrintAuditNos,
			IsPrintDCRNo = @IsPrintDCRNo,
			IsPrintSeatLabel = @IsPrintSeatLabel,
			AllowedUsers = @AllowedUsers,
			ClassPosition=@ClassPosition,
			PriceCardId = (case @PriceCardId when 0 then PriceCardId else @PriceCardId end),
			DCRId = @DCRId
		WHERE ClassLayoutID = @ClassLayoutID;
		
	END TRY
	BEGIN CATCH
		If (@@TRANCOUNT > 0)
			ROLLBACK
		DECLARE @error NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@error, 11, 1)
	END CATCH
END
GO

/* [spClassLayoutDelete] */ 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spClassLayoutDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spClassLayoutDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spClassLayoutDelete]
	@ClassLayoutID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		SET @ReferredBy = ''
		IF EXISTS ( SELECT NULL FROM Class WHERE ClassLayoutID = @ClassLayoutID )
			SET @ReferredBy = 'Class'
		ELSE IF EXISTS ( SELECT NULL FROM ClassMIS WHERE ClassLayoutID = @ClassLayoutID )
			SET @ReferredBy = 'ClassMIS'
		ELSE IF EXISTS ( SELECT NULL FROM Seat WHERE ClassLayoutID = @ClassLayoutID )
			SET @ReferredBy = 'Seat'
		ELSE IF EXISTS ( SELECT NULL FROM SeatMIS WHERE ClassLayoutID = @ClassLayoutID )
			SET @ReferredBy = 'SeatMIS'
	
		If @ReferredBy = ''
		BEGIN
			DELETE FROM Log
			WHERE TableType = ( SELECT TOP 1 Value FROM Type WHERE TypeNo = 1 AND Expression = 'ClassLayout' )
			AND ObjectID = @ClassLayoutID

			DELETE FROM SeatLayout
			WHERE ClassLayoutID = @ClassLayoutID

			DELETE FROM ClassLayout
			WHERE ClassLayoutID = @ClassLayoutID
		END
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
GO

/* [spClassLayoutAdd] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spClassLayoutAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spClassLayoutAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spClassLayoutAdd]
	@ScreenID INT,
	@ClassLayoutID INT OUTPUT,
	@ClassNo VARCHAR(2),
	@ClassName VARCHAR(16),
	@NoRows INT,
	@NoCols INT,
	@NoMaxSeatsPerTicket INT,
	@IsPrintOneTicketPerSeat BIT,
	@PrintType TINYINT,
	@PrintOrientationType TINYINT,
	@IsPrintAuditNos BIT,
	@IsPrintDCRNo BIT,
	@IsPrintSeatLabel BIT,
	@AllowedUsers VARCHAR(128),
	@UserId Int=0,
	@ClassPosition VARCHAR(4),
	@PriceCardId INT,
	@DCRId INT,
	@ClassType TINYINT
AS
	IF EXISTS (SELECT ScreenID FROM ClassLayout where ScreenID=@ScreenID AND ClassNo=@ClassNo)
	BEGIN
		RAISERROR('Class number already exists!', 11, 1)
		RETURN
	END
	IF EXISTS (SELECT ScreenID FROM ClassLayout where ScreenID=@ScreenID AND ClassPosition =@ClassPosition)
	BEGIN
		RAISERROR('Class position already exists!', 11, 1)
		RETURN
	END
	IF EXISTS (SELECT ScreenID FROM ClassLayout where ScreenID=@ScreenID AND ClassName = @ClassName)
    BEGIN
        RAISERROR('Class Name already exists!', 11, 1)
        RETURN
    END
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO ClassLayout (
				ScreenID,
				ClassNo,
				ClassName,
				NoRows,
				NoCols,
				NoMaxSeatsPerTicket,
				IsPrintOneTicketPerSeat,
				PrintType,
				PrintOrientationType,
				IsPrintAuditNos,
				IsPrintDCRNo,
				IsPrintSeatLabel,
				AllowedUsers,
				ClassPosition,
				PriceCardId,
				DCRId,
				ClassType
			) VALUES (
				@ScreenID,
				@ClassNo,
				@ClassName,
				@NoRows,
				@NoCols,
				@NoMaxSeatsPerTicket,
				@IsPrintOneTicketPerSeat,
				@PrintType,
				@PrintOrientationType,
				@IsPrintAuditNos,
				@IsPrintDCRNo,
				@IsPrintSeatLabel,
				@AllowedUsers,
				@ClassPosition,
				@PriceCardId,
				@DCRId,
				@ClassType
			) SET @ClassLayoutID = SCOPE_IDENTITY()

			DECLARE @RowNo INT
			DECLARE @ColNo INT
			SET @RowNo = 0
			WHILE (@RowNo < @NoRows)
			BEGIN
				SET @ColNo = 0
				WHILE (@ColNo < @NoCols)
				BEGIN
					INSERT INTO SeatLayout (
						ScreenID,
						ClassLayoutID,
						RowNo,
						ColNo
					) VALUES (
						@ScreenID,
						@ClassLayoutID,
						@RowNo,
						@ColNo
					)
					SET @ColNo = @ColNo + 1
				END
				SET @RowNo = @RowNo + 1
			END
		COMMIT
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
			ROLLBACK
		DECLARE @error NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@error, 11, 1)
	END CATCH
GO

/****** Object:  StoredProcedure [dbo].[spCheckItem]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- spCheckItem 43
CREATE PROC [dbo].[spCheckItem]
(
@ItemId as int
)
as 
begin 
declare @IsIngredients as Bit
select @IsIngredients=IsIngredients from Item where ItemId=@ItemId
if (@IsIngredients>0)
begin 
	select 1;
end
else
begin
	select 0;
end
end
GO
/****** Object:  StoredProcedure [dbo].[spChainManage]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Truncate Table Chain;
-- spChainManage 0,'FIRST CHAIN','8765GHJK-SDFD','HYDERABAD','500045','ADD'
CREATE PROCEDURE [dbo].[spChainManage]
@ID INT=0,
@NAME VARCHAR(64)='',
@GUID VARCHAR(32)='',
@CITY VARCHAR(32)='',
@PIN VARCHAR(8)='',
@TYPE VARCHAR(8)='',
@STATUS INT=0
AS
BEGIN
	IF(@TYPE='ADD')
	BEGIN
		IF NOT EXISTS(SELECT ID FROM Chain WHERE Name=@NAME)
		BEGIN
			INSERT INTO Chain(NAME,[GUID],CITY,PIN,[STATUS])
			VALUES (@NAME,@GUID,@CITY,@PIN,@STATUS);
			SET @ID=@@IDENTITY;
		END
		ELSE
		BEGIN
			RAISERROR('Chain name already exists!',-1,-1);
		END
	END
	ELSE IF(@TYPE='EDIT')
	BEGIN
		UPDATE Chain SET NAME=@NAME,[GUID]=@GUID,CITY=@CITY,PIN=@PIN,[Status]=@STATUS WHERE ID=@ID;
	END
	ELSE IF(@TYPE='DELETE')
	BEGIN
		UPDATE Chain SET [Status]=2 WHERE ID=@ID;
	END
	SELECT @ID;
END
GO
/****** Object:  StoredProcedure [dbo].[spChainLoad]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChainLoad]
	@ID INT
AS
BEGIN
	SELECT ID,NAME,[GUID],CITY,PIN,[Status] FROM Chain
	WHERE ID = @ID
END
GO
/****** Object:  StoredProcedure [dbo].[spCanteenItemIngredientAdd]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spCanteenItemIngredientAdd]
	@BillID INT,
	@BilledById INT,
	@BillType INT,
	@IngredientId INT,
	@ItemID INT,
	@ItemName VARCHAR(16),
	@Quantity NUMERIC(9,2),
	@Cost NUMERIC(9,2),
	@Metric VARCHAR(50)
AS
begin
	INSERT INTO CanteenIngredient (
		BillID,
		BilledById,
		BillType,
		IngredientId,
		ItemId,
		ItemName,
		Quantity,
		Cost,
		Metric,
		TransactionTime
	) VALUES (
		@BillID,
		@BilledById,
		@BillType,
		@IngredientId,
		@ItemId,
		@ItemName,
		@Quantity,
		@Cost,
		@Metric,
		getdate()
	);
	if(@BillType=4)
	begin
		insert into ItemIngredientStock(IngredientId,ItemID,Quantity,StockType) values(@IngredientId,@ItemID,@Quantity,4);
	end
	
	
end
GO
/****** Object:  StoredProcedure [dbo].[spCanteenEditPrint]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spCanteenEditPrint 283,'28_1,21_1',2,0,0,2
CREATE PROCEDURE [dbo].[spCanteenEditPrint]
	@BillID INT OUTPUT,
	@Items VARCHAR(512),
	@BillType TINYINT,
	@PaymentType TINYINT,
	@PaymentReceived NUMERIC(9,2),
	@BilledByID INT,
	@ComplexID INT
AS
	DECLARE @TransactionID INT
	DECLARE @ItemID INT
	DECLARE @ItemName VARCHAR(16)
	DECLARE @Price NUMERIC(9,2)
	DECLARE @Tax NUMERIC(9,2)
	DECLARE @VAT NUMERIC(9,2)
	DECLARE @ComboItems VARCHAR(128)
	DECLARE @Quantity INT

	DECLARE @TmpComItems VARCHAR(512)

	DECLARE @TmpItems VARCHAR(512)
	DECLARE @TmpItem VARCHAR(24)
	DECLARE @TmpItemID INT
	DECLARE @TmpQuantity INT
	DECLARE @CPos INT
	DECLARE @UPos INT
	SET @TransactionID = 0
	--SET @BillID = 0
	SET @TmpItems = @Items
	WHILE @TmpItems <> ''
	BEGIN
		SET @CPos = CHARINDEX(',', @TmpItems)
		IF @CPos > 0
			SELECT @TmpItem = SUBSTRING(@TmpItems, 1, @CPos - 1), @UPos = CHARINDEX('_', @TmpItem), @TmpItemID = CAST(SUBSTRING(@TmpItem, 1, @UPos - 1) AS INT), @TmpQuantity = CAST(SUBSTRING(@TmpItem, @UPos + 1, @CPos - 1) AS INT), @TmpItems = SUBSTRING(@TmpItems, @CPos + 1, LEN(@TmpItems))
		ELSE
			SELECT @UPos = CHARINDEX('_', @TmpItems), @TmpItemID = CAST(SUBSTRING(@TmpItems, 1, @UPos - 1) AS INT), @TmpQuantity = CAST(SUBSTRING(@TmpItems, @UPos + 1, LEN(@TmpItems)) AS INT), @TmpItems = ''

		SELECT
			@ItemID = ItemID,
			@ItemName = ItemName,
			@Price = Price,
			@Tax = Tax,
			@VAT = VAT,
			@ComboItems = ComboItems,
			@Quantity = Quantity
		FROM Item
		WHERE ItemID = @TmpItemID
		
		
	if(@BillType=4)
	begin
		insert into ItemStock(ItemID,Quantity,StockType) values(@ItemID,@Quantity,4);
	end

		IF @BillID = 0
		BEGIN
			INSERT INTO Canteen (
				ItemID,
				ItemName,
				BillType,
				Price,
				Tax,
				VAT,
				ComboItems,
				Quantity,
				PaymentType,
				PaymentReceived,
				BilledByID,
				ComplexID
			) VALUES (
				@ItemID,
				@ItemName,
				@BillType,
				@Price,
				@Tax,
				@VAT,
				@ComboItems,
				@TmpQuantity,
				@PaymentType,
				@PaymentReceived,
				@BilledByID,
				@ComplexID
			) SET @TransactionID = SCOPE_IDENTITY()
			SET @BillID = @TransactionID
			UPDATE Canteen SET BillID = @TransactionID WHERE TransactionID = @TransactionID
		END
		ELSE
		BEGIN
					DECLARE @CountAll INT;
					DECLARE @CountCancel INT;
					DECLARE @CountDamage INT;
					select @CountDamage=count(*) from Canteen where BillID=@BillID and BillType=3;
					select @CountCancel=count(*) from Canteen where BillID=@BillID and BillType=2;
					select @CountAll=count(*) from Canteen where BillID=@BillID and BillType=0;
					if (@CountCancel=@CountAll)
					begin
						RAISERROR('Bill already cancelled.  Duplicate entry failed.', 11, 1)
						Return
					end
					else if (@CountDamage=@CountAll)
					begin
						RAISERROR('Bill already sent to Damage.  Duplicate entry failed.', 11, 1)
						Return
					end
				
				INSERT INTO Canteen (
					BillID,
					ItemID,
					ItemName,
					BillType,
					Price,
					Tax,
					VAT,
					ComboItems,
					Quantity,
					PaymentType,
					PaymentReceived,
					BilledByID,
				ComplexID
				) VALUES (
					@BillID,
					@ItemID,
					@ItemName,
					@BillType,
					@Price,
					@Tax,
					@VAT,
					@ComboItems,
					@TmpQuantity,
					(select top(1) PaymentType from Canteen where BillId=@BillId),
					@PaymentReceived,
					@BilledByID,
				@ComplexID
				)
		END
		if(@ComboItems='')
		begin
			UPDATE Item
			SET Quantity = CASE WHEN (@BillType = 1 OR @BillType = 2) THEN Quantity + @TmpQuantity ELSE Quantity - @TmpQuantity END
			WHERE ItemID = @ItemID
		end
		else
		begin
		
			UPDATE Item
			SET Quantity = CASE WHEN (@BillType = 1 OR @BillType = 2) THEN Quantity + @TmpQuantity ELSE Quantity - @TmpQuantity END
			WHERE ItemID = @ItemID
		
			DECLARE curComboItems CURSOR FOR SELECT value from dbo.split(',',@ComboItems)
			OPEN curComboItems
			FETCH NEXT FROM curComboItems INTO @TmpComItems
			WHILE @@FETCH_STATUS = 0
			begin
				
				DECLARE @TmpComItemID INT
				DECLARE @TmpComQuantity INT
				if(charindex('-',@TmpComItems)>0)
				begin
					SELECT  top(1) @TmpComItemID=value from dbo.split('-',@TmpComItems)
					SELECT  top(1) @TmpComQuantity=value from dbo.split('-',@TmpComItems) order by rowid desc
					UPDATE Item
					SET Quantity = CASE WHEN (@BillType = 1 OR @BillType = 2) THEN Quantity + (@TmpQuantity*@TmpComQuantity) ELSE Quantity - (@TmpQuantity*@TmpComQuantity) END
					WHERE ItemID = @TmpComItemID
				end
				else
				begin
					UPDATE Item
					SET Quantity = CASE WHEN (@BillType = 1 OR @BillType = 2) THEN Quantity + (@TmpQuantity*1) ELSE Quantity - (@TmpQuantity*1) END
					WHERE ItemID = @TmpComItems
				end
				
				FETCH NEXT FROM curComboItems INTO @TmpComItems
			END
				close curComboItems;
				deallocate curComboItems;
			
			--print @TmpQuantity;
		end
		
	END
GO


/* spBoxOfficeUserLogout]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserLogout]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserLogout]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserLogout]
	@UserID INTEGER
AS
	UPDATE BoxOfficeUser
	SET NoFailedLoginAttempts = 0,
		LastLoggedInIP = '', IsUserEnabled = 1
	WHERE UserID = @UserID
GO

/* spBoxOfficeUserLogin */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserLogin]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserLogin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserLogin]
	@UserName VARCHAR(16),
	@PasswordValid Bit,
	@LastLoggedInIP VARCHAR(48)
AS
	DECLARE @TmpUserID AS INT
	DECLARE @TmpNoFailedLoginAttempts AS INT
	DECLARE @TmpNoLeftLoginAttempts AS INT
	DECLARE @TmpLastLoggedInIP AS VARCHAR(32)
	DECLARE @TmpIsSingleSession AS BIT
	DECLARE @TmpIsUserEnabled AS BIT
	
	SELECT @TmpUserID = 0, @TmpNoFailedLoginAttempts = 0, @TmpNoLeftLoginAttempts = 0, @TmpLastLoggedInIP = '', @TmpIsSingleSession = 0, @TmpIsUserEnabled = 0

	SELECT
		@TmpUserID = UserID,
		@TmpNoFailedLoginAttempts = NoFailedLoginAttempts,
		@TmpIsSingleSession = IsSingleSession,
		@TmpLastLoggedInIP = LastLoggedInIP,
		@TmpIsUserEnabled = IsUserEnabled
	FROM BoxOfficeUser
	WHERE UserName = @UserName

	IF @TmpUserID = 0
	BEGIN
		RAISERROR('Username/Password is Incorrect!', 11, 1)
		RETURN
	END
	
	IF @TmpNoFailedLoginAttempts >= 5
	BEGIN
		RAISERROR('Your account is locked. Contact support team!', 11, 1)
		RETURN
	END
	
	IF @PasswordValid = 0
	BEGIN
		SET @TmpNoFailedLoginAttempts = @TmpNoFailedLoginAttempts + 1
		IF @TmpNoFailedLoginAttempts >= 5
		BEGIN
			SET @TmpIsUserEnabled = 0
		END
		UPDATE BoxOfficeUser
		SET NoFailedLoginAttempts = @TmpNoFailedLoginAttempts, IsUserEnabled = @TmpIsUserEnabled
		WHERE UserID = @TmpUserID
		SET @TmpNoLeftLoginAttempts = 5 - @TmpNoFailedLoginAttempts
		if @TmpIsUserEnabled = 0 
		BEGIN
			RAISERROR('Your account is locked. Contact support team!', 11, 1)
		END
		ELSE
		BEGIN
			RAISERROR('Username/Password is Incorrect!', 11, 1)
		END
		RETURN
	END
	
	IF @TmpIsUserEnabled = 0
	BEGIN
		RAISERROR('Your account is locked. Contact support team!', 11, 1)
		RETURN
	END
	
	IF @TmpIsSingleSession = 1 AND @TmpLastLoggedInIP <> ''
	BEGIN
		RAISERROR('Your account is locked. Contact support team!', 11, 1)
		RETURN
	END
		
	UPDATE BoxOfficeUser
	SET NoFailedLoginAttempts = 0,
		LastLoggedInIP = @LastLoggedInIP
	WHERE UserID = @TmpUserID

	SELECT
		UserID,
		UserName,
		Password,
		UserRoleType,
		NoFailedLoginAttempts,
		LastLoggedInIP,
		IsSingleSession,
		IsUserEnabled,
		StartPageType,
		NoMaxVisibleShowDays,
		NoMinsToLockAfterShowTime,
		IsEditBoxOfficeSettings,
		IsEditComplexSettings,
		IsListUsers,
		IsEditUser,
		IsDeleteUser,
		IsListScreens,
		IsEditScreen,
		IsDeleteScreen,
		IsListDCRs,
		IsEditDCR,
		IsDeleteDCR,
		IsListShows,
		IsEditShow,
		IsDeleteShow,
		IsEditSeat,
		IsEditSeatBlock,
		IsEditSeatSell,
		IsEditSeatCancel,
		IsEditSeatOccupy,
		IsRePrintSoldSeat,
		IsViewKioskInterface,
		IsViewQRSentry,
		IsViewBookingStatusDisplay,
		IsListCanteenItems,
		IsFoodBillReprint,
		IsListReports,
		IsPrintInternetTicket,
		IsSellManagerQuotaBlockedTicket,
		IsSendtoOnline,
		IsFoodBillCancel,
		IsEditCanteenPurchase,
		IsViewCancel,
		IsDCRReport,
		IsAdvanceSalesSummaryReport,
		IsTransactionReport,
		IsPerformanceReport,
		IsCashierReport,
		IsMarketingReport,
		IsQuickTicketsSalesSummaryReport,
		IsScreeningSchedule,
		IsConcessionReport,
		IsReleaseOnlineSeats,
		IsAllowManagerQuotaBooking,
		IsHandoff,
		IsBoxOfficeSummary,
		IsManageDistributor,
		IsDistributorReport,
		IsBoxOfficeReceiptsSummary,
		IsCancelledShowDetails,
		IsCompleteSalesSummaryInfo,
		IsPrintSalesSummaryInfo,
		IsManageVendor,
		IsManageIngredients,
		IsManageItems,
		IsManageCounter,
		IsManageSetupOrder,
		IsItemSalesReport,
		IsProductSalesReport,
		IsAuditRefundReport,
		IsListParkingTypes,
		IsEditParkingTypes,
		IsDeleteParkingTypes,
		IsListParkingEntry,
		IsDailyCollectionSummaryReport,
		IsFourWeeklyReport,
		IsWeeklyReport,
		IsFormBReport,
		IsForm3BReport,
		IsForm17Report,
		IsForm3Report,
		IsFourWeeklyPercentageReport,
		IsEastMarketReport,
		IsMunicipalTaxReport,
		IsTaxLossReport,
		IsUserwisePaymentTypeSummaryReport
	FROM BoxOfficeUser
	WHERE UserID = @TmpUserID
FINISH:
GO

/* [spBoxOfficeUserLoad] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserLoad]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserLoad]
	@UserID INT
AS
	SELECT
		UserID,
		UserName,
		Password,
		UserRoleType,
		NoFailedLoginAttempts,
		LastLoggedInIP,
		IsSingleSession,
		IsUserEnabled,
		StartPageType,
		NoMaxVisibleShowDays,
		NoMinsToLockAfterShowTime,
		IsEditBoxOfficeSettings,
		IsEditComplexSettings,
		IsListUsers,
		IsEditUser,
		IsDeleteUser,
		IsListScreens,
		IsEditScreen,
		IsDeleteScreen,
		IsListDCRs,
		IsEditDCR,
		IsDeleteDCR,
		IsListShows,
		IsEditShow,
		IsDeleteShow,
		IsReleaseOnlineSeats,
		IsEditSeat,
		IsEditSeatBlock,
		IsEditSeatSell,
		IsEditSeatCancel,
		IsEditSeatOccupy,
		IsRePrintSoldSeat,
		IsViewKioskInterface,
		IsViewQRSentry,
		IsViewBookingStatusDisplay,
		IsListCanteenItems,
		IsFoodBillReprint,
		IsListReports,
		IsPrintInternetTicket,
		IsSellManagerQuotaBlockedTicket,
		IsSendtoOnline,
		IsFoodBillCancel,
		IsEditCanteenPurchase,
		IsViewCancel,
		IsDCRReport,
		IsAdvanceSalesSummaryReport,
		IsTransactionReport,
		IsPerformanceReport,
		IsCashierReport,
		IsMarketingReport,
		IsQuickTicketsSalesSummaryReport,
		IsScreeningSchedule,
		IsConcessionReport,
		IsAllowManagerQuotaBooking,
		IsHandoff,
		IsBoxOfficeSummary,
		IsManageDistributor,
		IsDistributorReport,
		IsBoxOfficeReceiptsSummary,
		IsCancelledShowDetails,
		IsCompleteSalesSummaryInfo,
		IsPrintSalesSummaryInfo,
		IsManageVendor,
		IsManageIngredients,
		IsManageItems,
		IsManageCounter,
		IsManageSetupOrder,
		IsItemSalesReport,
		IsProductSalesReport,
		IsAuditRefundReport,
		IsListParkingTypes,
		IsEditParkingTypes,
		IsDeleteParkingTypes,
		IsListParkingEntry,
		IsDailyCollectionSummaryReport,
		IsFourWeeklyReport,
		IsWeeklyReport,
		IsFormBReport,
		IsForm3BReport,
		IsForm17Report,
		IsForm3Report,
		IsFourWeeklyPercentageReport,
		IsEastMarketReport,
		IsMunicipalTaxReport,
		IsTaxLossReport,
		IsUserwisePaymentTypeSummaryReport
			FROM BoxOfficeUser
	WHERE UserID = @UserID
GO

/* spBoxOfficeUserEditSettings */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserEditSettings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserEditSettings]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserEditSettings]
	@UserID INT,
	@Password VARCHAR(100)
AS
	UPDATE BoxOfficeUser
	SET Password = CASE WHEN @Password <> '' THEN @Password ELSE Password END
	WHERE UserID = @UserID
GO

/* spBoxOfficeUserEdit */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserEdit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserEdit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserEdit]
	@UserID INT,
	@UserName VARCHAR(16),
	@Password VARCHAR(100),
	@UserRoleType TINYINT,
	@IsSingleSession BIT,
	@IsUserEnabled BIT,
	@StartPageType TINYINT,
	@NoMaxVisibleShowDays TINYINT,
	@NoMinsToLockAfterShowTime INT,
	@IsEditBoxOfficeSettings BIT,
	@IsEditComplexSettings BIT,
	@IsListUsers BIT,
	@IsEditUser BIT,
	@IsDeleteUser BIT,
	@IsListScreens BIT,
	@IsEditScreen BIT,
	@IsDeleteScreen BIT,
	@IsListDCRs BIT,
	@IsEditDCR BIT,
	@IsDeleteDCR BIT,
	@IsListShows BIT,
	@IsEditShow BIT,
	@IsDeleteShow BIT,
	@IsReleaseOnlineSeats BIT,
	@IsEditSeat BIT,
	@IsEditSeatBlock BIT,
	@IsEditSeatSell BIT,
	@IsEditSeatCancel BIT,
	@IsEditSeatOccupy BIT,
	@IsRePrintSoldSeat BIT,
	@IsViewKioskInterface BIT,
	@IsViewQRSentry BIT,
	@IsViewBookingStatusDisplay BIT,
	@IsListCanteenItems BIT,
	@IsFoodBillReprint BIT,
	@IsListReports BIT,
	@IsPrintInternetTicket BIT,
	@IsSellManagerQuotaBlockedTicket BIT,
	@IsSendtoOnline BIT,
	@IsFoodBillCancel BIT,
	@IsEditCanteenPurchase BIT,
	@IsListParkingTypes BIT,
	@IsEditParkingTypes BIT,
	@IsDeleteParkingTypes BIT,
	@IsListParkingEntry BIT,
	@IsViewCancel BIT,
	@IsDCRReport BIT,
	@IsAdvanceSalesSummaryReport BIT,
	@IsTransactionReport BIT,
	@IsPerformanceReport BIT,
	@IsAuditRefundReport BIT,
	@IsCashierReport BIT,
	@IsMarketingReport BIT,
	@IsQuickTicketsSalesSummaryReport BIT,
	@IsScreeningSchedule BIT,
	@IsConcessionReport BIT,
	@IsAllowManagerQuotaBooking BIT,
	@IsHandoff BIT,
	@IsBoxOfficeSummary BIT,
	@IsManageDistributor BIT,
	@IsDistributorReport BIT,
	@IsBoxOfficeReceiptsSummary BIT,
	@IsCancelledShowDetails BIT,
	@IsCompleteSalesSummaryInfo BIT,
	@IsPrintSalesSummaryInfo BIT,
	@IsManageVendor BIT,
	@IsManageIngredients BIT,
	@IsManageItems BIT,
	@IsManageCounter BIT,
	@IsManageSetupOrder BIT,
	@IsItemSalesReport BIT,
	@IsProductSalesReport BIT,
	@IsDailyCollectionSummaryReport BIT,
	@IsFourWeeklyReport BIT,
	@IsWeeklyReport BIT,
	@IsFormBReport BIT,
	@IsForm3BReport BIT,
	@IsForm17Report BIT,
	@IsForm3Report BIT,
	@IsFourWeeklyPercentageReport BIT,
	@IsEastMarketReport BIT,
	@IsMunicipalTaxReport BIT,
	@IsTaxLossReport BIT,
	@IsUserwisePaymentTypeSummaryReport BIT
AS
	UPDATE BoxOfficeUser
	SET UserName = @UserName,
		[Password] = CASE WHEN @Password = '' THEN [Password] ELSE @Password END,
		UserRoleType = @UserRoleType,
		/*NoFailedLoginAttempts = @NoFailedLoginAttempts,
		LastLoggedInIP = @LastLoggedInIP,*/
		IsSingleSession = @IsSingleSession,
		IsUserEnabled = @IsUserEnabled,
		StartPageType = @StartPageType,
		NoMaxVisibleShowDays = @NoMaxVisibleShowDays,
		NoMinsToLockAfterShowTime = (CASE WHEN ISNULL((SELECT TOP 1 LockShowTime FROM Complex), 0) >= @NoMinsToLockAfterShowTime THEN @NoMinsToLockAfterShowTime ELSE ISNULL((SELECT TOP 1 LockShowTime FROM Complex), 0) END),
		IsEditBoxOfficeSettings = @IsEditBoxOfficeSettings,
		IsEditComplexSettings = @IsEditComplexSettings,
		IsListUsers = @IsListUsers,
		IsEditUser = @IsEditUser,
		IsDeleteUser = @IsDeleteUser,
		IsListScreens = @IsListScreens,
		IsEditScreen = @IsEditScreen,
		IsDeleteScreen = @IsDeleteScreen,
		IsListDCRs = @IsListDCRs,
		IsEditDCR = @IsEditDCR,
		IsDeleteDCR = @IsDeleteDCR,
		IsListShows = @IsListShows,
		IsEditShow = @IsEditShow,
		IsDeleteShow = @IsDeleteShow,
		IsReleaseOnlineSeats = @IsReleaseOnlineSeats,
		IsEditSeat = @IsEditSeat,
		IsEditSeatBlock = @IsEditSeatBlock,
		IsEditSeatSell = @IsEditSeatSell,
		IsEditSeatCancel = @IsEditSeatCancel,
		IsEditSeatOccupy = @IsEditSeatOccupy,
		IsRePrintSoldSeat = @IsRePrintSoldSeat,
		IsViewKioskInterface = @IsViewKioskInterface,
		IsViewQRSentry = @IsViewQRSentry,
		IsViewBookingStatusDisplay = @IsViewBookingStatusDisplay,
		IsListCanteenItems = @IsListCanteenItems,
		IsFoodBillReprint = @IsFoodBillReprint,
		IsListReports = @IsListReports,
		IsPrintInternetTicket=@IsPrintInternetTicket,
		IsSellManagerQuotaBlockedTicket=@IsSellManagerQuotaBlockedTicket,
		IsSendtoOnline=@IsSendtoOnline,
		IsFoodBillCancel =@IsFoodBillCancel,
		IsEditCanteenPurchase=@IsEditCanteenPurchase,
		IsListParkingTypes=@IsListParkingTypes ,
		IsEditParkingTypes =@IsEditParkingTypes ,
		IsDeleteParkingTypes=@IsDeleteParkingTypes ,
		IsListParkingEntry=@IsListParkingEntry,
		IsViewCancel=@IsViewCancel,
		IsDCRReport=@IsDCRReport,
		IsAdvanceSalesSummaryReport=@IsAdvanceSalesSummaryReport,
		IsTransactionReport=@IsTransactionReport,
		IsPerformanceReport=@IsPerformanceReport,
		IsAuditRefundReport=@IsAuditRefundReport,
		IsCashierReport=@IsCashierReport,
		IsMarketingReport=@IsMarketingReport,
		IsQuickTicketsSalesSummaryReport=@IsQuickTicketsSalesSummaryReport,
		IsScreeningSchedule=@IsScreeningSchedule,
		IsConcessionReport=@IsConcessionReport,
		IsAllowManagerQuotaBooking=@IsAllowManagerQuotaBooking,
		IsHandoff = @IsHandoff,
		IsBoxOfficeSummary = @IsBoxOfficeSummary,
		IsManageDistributor = @IsManageDistributor,
		IsDistributorReport = @IsDistributorReport,
		IsBoxOfficeReceiptsSummary = @IsBoxOfficeReceiptsSummary,
		IsCancelledShowDetails = @IsCancelledShowDetails,
		IsCompleteSalesSummaryInfo = @IsCompleteSalesSummaryInfo,
		IsPrintSalesSummaryInfo = @IsPrintSalesSummaryInfo,
		IsManageVendor = @IsManageVendor,
		IsManageIngredients = @IsManageIngredients,
		IsManageItems = @IsManageItems,
		IsManageCounter = @IsManageCounter,
		IsManageSetupOrder = @IsManageSetupOrder,
		IsItemSalesReport = @IsItemSalesReport,
		IsProductSalesReport = @IsProductSalesReport,
		IsDailyCollectionSummaryReport = @IsDailyCollectionSummaryReport,
		IsFourWeeklyReport = @IsFourWeeklyReport,
		IsWeeklyReport = @IsWeeklyReport,
		IsFormBReport = @IsFormBReport,
		IsForm3BReport = @IsForm3BReport,
		IsForm17Report = @IsForm17Report,
		IsForm3Report = @IsForm3Report,
		IsFourWeeklyPercentageReport = @IsFourWeeklyPercentageReport,
		IsEastMarketReport = @IsEastMarketReport,
		IsMunicipalTaxReport = @IsMunicipalTaxReport,
		IsTaxLossReport = @IsTaxLossReport,
		IsUserwisePaymentTypeSummaryReport = @IsUserwisePaymentTypeSummaryReport

	WHERE UserID = @UserID
GO

/* spBoxOfficeUserDelete */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserDelete]
	@UserID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
	SET @ReferredBy = ''
	IF EXISTS ( SELECT NULL FROM Seat WHERE LastBlockedByID = @UserID OR LastSoldByID = @UserID OR LastPrintedByID = @UserID OR LastOccupiedByID = @UserID OR LastCancelledByID = @UserID )
		SET @ReferredBy = 'Seat'
	ELSE IF EXISTS ( SELECT NULL FROM SeatMIS WHERE LastBlockedByID = @UserID OR LastSoldByID = @UserID OR LastPrintedByID = @UserID OR LastOccupiedByID = @UserID OR LastCancelledByID = @UserID )
		SET @ReferredBy = 'SeatMIS'
	ELSE IF EXISTS ( SELECT NULL FROM DCR WHERE CreatedBy = @UserID)
		SET @ReferredBy = 'DCR'
	ELSE IF EXISTS ( SELECT NULL FROM Distributors WHERE CreatedBy = @UserID )
		SET @ReferredBy = 'Distributors'
	ELSE IF EXISTS ( SELECT NULL FROM DistributorMovieCollections WHERE CreatedBy = @UserID OR ModifiedBy = @UserID)
		SET @ReferredBy = 'Distributor Movie Collections'
	
	If @ReferredBy = ''
	BEGIN
		DELETE FROM Log
		WHERE TableType = ( SELECT TOP 1 Value FROM Type WHERE TypeNo = 1 AND Expression = 'BoxOfficeUser' )
		AND ObjectID = @UserID
		
		DELETE FROM BoxOfficeUser 
		WHERE UserID = @UserID
	END
GO

/* spBoxOfficeUserAdd */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spBoxOfficeUserAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spBoxOfficeUserAdd]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBoxOfficeUserAdd]
	@UserID INT OUTPUT,
	@UserName VARCHAR(16),
	@Password VARCHAR(100),
	@UserRoleType TINYINT,
	@IsSingleSession BIT,
	@IsUserEnabled BIT,
	@StartPageType TINYINT,
	@NoMaxVisibleShowDays TINYINT,
	@NoMinsToLockAfterShowTime INT,
	@IsEditBoxOfficeSettings BIT,
	@IsEditComplexSettings BIT,
	@IsListUsers BIT,
	@IsEditUser BIT,
	@IsDeleteUser BIT,
	@IsListScreens BIT,
	@IsEditScreen BIT,
	@IsDeleteScreen BIT,
	@IsListDCRs BIT,
	@IsEditDCR BIT,
	@IsDeleteDCR BIT,
	@IsListShows BIT,
	@IsEditShow BIT,
	@IsDeleteShow BIT,
	@IsReleaseOnlineSeats BIT,
	@IsEditSeat BIT,
	@IsEditSeatBlock BIT,
	@IsEditSeatSell BIT,
	@IsEditSeatCancel BIT,
	@IsEditSeatOccupy BIT,
	@IsRePrintSoldSeat BIT,
	@IsViewKioskInterface BIT,
	@IsViewQRSentry BIT,
	@IsViewBookingStatusDisplay BIT,
	@IsListCanteenItems BIT,
	@IsFoodBillReprint BIT,
	@IsListReports BIT,
	@IsPrintInternetTicket BIT,
	@IsSellManagerQuotaBlockedTicket BIT,
	@IsSendtoOnline BIT,
	@IsFoodBillCancel BIT,
	@IsEditCanteenPurchase BIT,
	@IsListParkingTypes BIT,
	@IsEditParkingTypes BIT,
	@IsDeleteParkingTypes BIT,
	@IsListParkingEntry BIT,
	@IsViewCancel BIT,
	@IsDCRReport BIT,
	@IsAdvanceSalesSummaryReport BIT,
	@IsTransactionReport BIT,
	@IsPerformanceReport BIT,
	@IsAuditRefundReport BIT,
	@IsCashierReport BIT,
	@IsMarketingReport BIT,
	@IsQuickTicketsSalesSummaryReport BIT,
	@IsScreeningSchedule BIT,
	@IsConcessionReport BIT,
	@IsAllowManagerQuotaBooking BIT,
	@IsHandoff BIT,
	@IsBoxOfficeSummary BIT,
	@IsManageDistributor BIT,
	@IsDistributorReport BIT,
	@IsBoxOfficeReceiptsSummary BIT,
	@IsCancelledShowDetails BIT,
	@IsCompleteSalesSummaryInfo BIT,
	@IsPrintSalesSummaryInfo BIT,
	@IsManageVendor BIT,
	@IsManageIngredients BIT,
	@IsManageItems BIT,
	@IsManageCounter BIT,
	@IsManageSetupOrder BIT,
	@IsItemSalesReport BIT,
	@IsProductSalesReport BIT,
	@IsDailyCollectionSummaryReport BIT,
	@IsFourWeeklyReport BIT,
	@IsWeeklyReport BIT,
	@IsFormBReport BIT,
	@IsForm3BReport BIT,
	@IsForm17Report BIT,
	@IsForm3Report BIT,
	@IsFourWeeklyPercentageReport BIT,
	@IsEastMarketReport BIT,
	@IsMunicipalTaxReport BIT,
	@IsTaxLossReport BIT,
	@IsUserwisePaymentTypeSummaryReport BIT
AS
	INSERT INTO BoxOfficeUser (
		UserName,
		Password,
		UserRoleType,
		IsSingleSession,
		IsUserEnabled,
		StartPageType,
		NoMaxVisibleShowDays,
		NoMinsToLockAfterShowTime,
		IsEditBoxOfficeSettings,
		IsEditComplexSettings,
		IsListUsers,
		IsEditUser,
		IsDeleteUser,
		IsListScreens,
		IsEditScreen,
		IsDeleteScreen,
		IsListDCRs,
		IsEditDCR,
		IsDeleteDCR,
		IsListShows,
		IsEditShow,
		IsDeleteShow,
		IsReleaseOnlineSeats,
		IsEditSeat,
		IsEditSeatBlock,
		IsEditSeatSell,
		IsEditSeatCancel,
		IsEditSeatOccupy,
		IsRePrintSoldSeat,
		IsViewKioskInterface,
		IsViewQRSentry,
		IsViewBookingStatusDisplay,
		IsListCanteenItems,
		IsFoodBillReprint,
		IsListReports,
		IsPrintInternetTicket,
		IsSellManagerQuotaBlockedTicket,
		IsSendtoOnline,
		IsFoodBillCancel,
		IsEditCanteenPurchase,
		IsListParkingTypes,
		IsEditParkingTypes,
		IsDeleteParkingTypes,
		IsListParkingEntry,
		IsViewCancel,
		IsDCRReport,
		IsAdvanceSalesSummaryReport,
		IsTransactionReport,
		IsPerformanceReport,
		IsAuditRefundReport,
		IsCashierReport,
		IsMarketingReport,
		IsScreeningSchedule,
		IsConcessionReport,
		IsQuickTicketsSalesSummaryReport,
		IsAllowManagerQuotaBooking,
		IsHandoff,
		IsBoxOfficeSummary,
		IsManageDistributor,
		IsDistributorReport,
		IsBoxOfficeReceiptsSummary,
		IsCancelledShowDetails,
		IsCompleteSalesSummaryInfo,
		IsPrintSalesSummaryInfo,
		IsManageVendor,
		IsManageIngredients,
		IsManageItems,
		IsManageCounter,
		IsManageSetupOrder,
		IsItemSalesReport,
		IsProductSalesReport,
		IsDailyCollectionSummaryReport,
		IsFourWeeklyReport,
		IsWeeklyReport,
		IsFormBReport,
		IsForm3BReport,
		IsForm17Report,
		IsForm3Report,
		IsFourWeeklyPercentageReport,
		IsEastMarketReport,
		IsMunicipalTaxReport,
		IsTaxLossReport,
		IsUserwisePaymentTypeSummaryReport

	) VALUES (
		@UserName,
		@Password,
		@UserRoleType,
		@IsSingleSession,
		@IsUserEnabled,
		@StartPageType,
		@NoMaxVisibleShowDays,
		(CASE WHEN ISNULL((SELECT TOP 1 LockShowTime FROM Complex), 0) >= @NoMinsToLockAfterShowTime THEN @NoMinsToLockAfterShowTime ELSE ISNULL((SELECT TOP 1 LockShowTime FROM Complex), 0) END),
		@IsEditBoxOfficeSettings,
		@IsEditComplexSettings,
		@IsListUsers,
		@IsEditUser,
		@IsDeleteUser,
		@IsListScreens,
		@IsEditScreen,
		@IsDeleteScreen,
		@IsListDCRs,
		@IsEditDCR,
		@IsDeleteDCR,
		@IsListShows,
		@IsEditShow,
		@IsDeleteShow,
		@IsReleaseOnlineSeats,
		@IsEditSeat,
		@IsEditSeatBlock,
		@IsEditSeatSell,
		@IsEditSeatCancel,
		@IsEditSeatOccupy,
		@IsRePrintSoldSeat,
		@IsViewKioskInterface,
		@IsViewQRSentry,
		@IsViewBookingStatusDisplay,
		@IsListCanteenItems,
		@IsFoodBillReprint,
		@IsListReports,
		@IsPrintInternetTicket,
		@IsSellManagerQuotaBlockedTicket,
		@IsSendtoOnline,
		@IsFoodBillCancel,
		@IsEditCanteenPurchase ,
		@IsListParkingTypes,
		@IsEditParkingTypes,
		@IsDeleteParkingTypes,
		@IsListParkingEntry,
		@IsViewCancel,
		@IsDCRReport,
		@IsAdvanceSalesSummaryReport,
		@IsTransactionReport,
		@IsPerformanceReport,
		@IsAuditRefundReport,
		@IsCashierReport,
		@IsMarketingReport,
		@IsScreeningSchedule,
		@IsConcessionReport,
		@IsQuickTicketsSalesSummaryReport,
		@IsAllowManagerQuotaBooking,
		@IsHandoff,
		@IsBoxOfficeSummary,
		@IsManageDistributor,
		@IsDistributorReport,
		@IsBoxOfficeReceiptsSummary,
		@IsCancelledShowDetails,
		@IsCompleteSalesSummaryInfo,
		@IsPrintSalesSummaryInfo,
		@IsManageVendor,
		@IsManageIngredients,
		@IsManageItems,
		@IsManageCounter,
		@IsManageSetupOrder,
		@IsItemSalesReport,
		@IsProductSalesReport,
		@IsDailyCollectionSummaryReport,
		@IsFourWeeklyReport,
		@IsWeeklyReport,
		@IsFormBReport,
		@IsForm3BReport,
		@IsForm17Report,
		@IsForm3Report,
		@IsFourWeeklyPercentageReport,
		@IsEastMarketReport,
		@IsMunicipalTaxReport,
		@IsTaxLossReport,
		@IsUserwisePaymentTypeSummaryReport

	) SET @UserID = SCOPE_IDENTITY()
GO

/****** Object:  StoredProcedure [dbo].[spAutoShowCopy]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spAutoShowCopy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spAutoShowCopy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spAutoShowCopy '2013-04-16 20:00:00.000',0
CREATE PROCEDURE [dbo].[spAutoShowCopy]
	@ShowTime DATETIME,
	@NoMaxVisibleShowDays TINYINT
AS
	IF DATEADD(day, 1, @ShowTime) < GETDATE()
	BEGIN
		RAISERROR('Show time over!', 11, 1)
		RETURN
	END

	IF @NoMaxVisibleShowDays > 0
	BEGIN
		IF DATEADD(day, 1, @ShowTime) > DATEADD(day, @NoMaxVisibleShowDays, GETDATE())
		BEGIN
			RAISERROR('Show time exceeds your visible show days limit!', 11, 1)
			RETURN
		END
	END
	
	CREATE TABLE #CopyShows ( CopyShowID INT PRIMARY KEY,CopyShowTime Datetime,CopyScreenID int )
	DECLARE @NewShowID AS INT
set @NewShowID=0;
	INSERT INTO #CopyShows (
		CopyShowID,
		CopyShowTime,
		CopyScreenID
	)	SELECT DISTINCT
			A.ShowID,A.ShowTime,A.ScreenID
		FROM Show A
		WHERE 
		 A.ShowTime=@ShowTime
		--A.IsPaused = 0
		--AND DATEDIFF(day, A.ShowTime, @ShowTime) = 1
		--AND DATEADD(day, 1, A.ShowTime) NOT IN ( SELECT B.ShowTime FROM Show B WHERE B.ScreenID = A.ScreenID AND B.ShowTime = DATEADD(day, 1, A.ShowTime) )
		

	DECLARE @CopyShowID INT
	declare @scrnid as int;
	declare @shwtime as datetime;
	DECLARE curCopyShows CURSOR	FOR SELECT CopyShowID,CopyShowTime,CopyScreenID FROM #CopyShows
	OPEN curCopyShows
	FETCH NEXT FROM curCopyShows INTO @CopyShowID,@shwtime,@scrnid
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--select @shwtime=ShowTime,@scrnid=ScreenID from show where ShowID = @CopyShowID
		if not exists(select Showid from Show where showtime=DATEADD(day, 1, @shwtime) and ScreenID=@scrnid)
		begin
		INSERT INTO Show (
			ScreenID,
			
			ScreenNo,
			ScreenName,
			OnlineMovieID,
			OnlineMovieName,
			MovieName,
			Experiences,
			MovieLanguageType,
			MovieCensorRatingType,
			ShowName,
			ShowTime,
			IsPaused,
			ResumeBefore,
			AllowedUsers,
			Duration,
		IsOnlinePublish
		)	SELECT
				ScreenID,
				
				ScreenNo,
				ScreenName,
				OnlineMovieID,
				OnlineMovieName,
				MovieName,
				Experiences,
				MovieLanguageType,
				MovieCensorRatingType,
				ShowName,
				DATEADD(day, 1, ShowTime),
				IsPaused, 
				ResumeBefore,
				AllowedUsers,
				Duration,
		IsOnlinePublish 
			FROM Show WHERE ShowID  = @CopyShowID
			SET @NewShowID = SCOPE_IDENTITY()

		INSERT INTO Class (
			ScreenID,
			ShowID,
			
			ClassLayoutID,
			ClassNo,
			ClassName,
			NoRows,
			NoCols,
			Price,
			ETax,
			ATax,
			MC,
			NoMaxSeatsPerTicket,
			AllowedUsers,
			DCRID
		)	SELECT
				ScreenID,
				@NewShowID,
				
				ClassLayoutID,
				ClassNo,
				ClassName,
				NoRows,
				NoCols,
				Price,
				ETax,
				ATax,
				MC,
				NoMaxSeatsPerTicket,
				AllowedUsers,
			DCRID
			FROM Class
			WHERE ShowID = @CopyShowID
				
				INSERT INTO Seat (
		ScreenID,
		ShowID,
		ClassID,
		ClassLayoutID,
		SeatLayoutID,
		SeatType,
		SeatLabel,
		RowNo,
		ColNo,
		QuotaType,
		ReleaseBefore
	)	SELECT
			(select top(1) ScreenID from Show where ShowID=@NewShowID),
					@NewShowID,
			( SELECT TOP 1 Class.ClassID FROM Class WHERE Class.ShowID = @NewShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID order by Classid desc ),
			SeatLayout.ClassLayoutID,
			SeatLayout.SeatLayoutID,
			SeatLayout.SeatType,
			SeatLayout.SeatLabel,
			SeatLayout.RowNo,
			SeatLayout.ColNo,
			SeatLayout.QuotaType,
			SeatLayout.ReleaseBefore
		FROM SeatLayout
		WHERE SeatLayout.ScreenID = (select top(1) ScreenID from Show where ShowID=@NewShowID)

		End
		FETCH NEXT FROM curCopyShows INTO @CopyShowID,@shwtime,@scrnid
	END
		
	DROP TABLE #CopyShows
	
	select @NewShowID;
GO

/* [DropDBO] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DropDBO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DropDBO]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DropDBO]
AS
BEGIN TRANSACTION
	TRUNCATE TABLE [Complex]
	TRUNCATE TABLE [BoxOfficeUser]
	TRUNCATE TABLE [Screen]
	TRUNCATE TABLE [ClassLayout]
	TRUNCATE TABLE [SeatLayout]
	TRUNCATE TABLE [Show]
	TRUNCATE TABLE [ShowMIS]
	TRUNCATE TABLE [Class]
	TRUNCATE TABLE [ClassMIS]
	TRUNCATE TABLE [Seat]
	TRUNCATE TABLE [SeatMIS]
	TRUNCATE TABLE [Item]
	TRUNCATE TABLE [ItemHeads]
	TRUNCATE TABLE [Canteen]
	TRUNCATE TABLE [CanteenMIS]
	TRUNCATE TABLE [Log]
	TRUNCATE TABLE [LogMIS]
	TRUNCATE TABLE [DCR]
	TRUNCATE TABLE [PriceCardDetails]
	TRUNCATE TABLE [PriceCard]
	TRUNCATE TABLE [Chain]
	TRUNCATE TABLE [CanteenIngredient]
	TRUNCATE TABLE [ItemStock]
	TRUNCATE TABLE [ItemIngredient]
	TRUNCATE TABLE [ItemIngredientStock]
	TRUNCATE TABLE [ParkingType]
	TRUNCATE TABLE [Parking]
	TRUNCATE TABLE [Report]
	TRUNCATE TABLE [Type]

	DROP TABLE [Complex]
	DROP TABLE [BoxOfficeUser]
	DROP TABLE [Screen]
	DROP TABLE [ClassLayout]
	DROP TABLE [SeatLayout]
	DROP TABLE [Show]
	DROP TABLE [ShowMIS]
	DROP TABLE [Class]
	DROP TABLE [ClassMIS]
	DROP TABLE [Seat]
	DROP TABLE [SeatMIS]
	DROP TABLE [Item]
	DROP TABLE [ItemHeads]
	DROP TABLE [Canteen]
	DROP TABLE [CanteenMIS]
	DROP TABLE [Log]
	DROP TABLE [LogMIS]
	DROP TABLE [DCR]
	DROP TABLE [PriceCardDetails]
	DROP TABLE [PriceCard]
	DROP TABLE [Chain]
	DROP TABLE [CanteenIngredient]
	DROP TABLE [ItemStock]
	DROP TABLE [ItemIngredient]
	DROP TABLE [ItemIngredientStock]
	DROP TABLE [ParkingType]
	DROP TABLE [Parking]
	DROP TABLE [Report]
	DROP TABLE [Type] 

	DECLARE @sql NVARCHAR(MAX) = N'';

	SELECT @sql += N'DROP PROCEDURE dbo.'
	  + QUOTENAME(name) + ';
	' FROM sys.procedures
	WHERE 
	SCHEMA_NAME(schema_id) = N'dbo';
	EXEC sp_executesql @sql;


	DECLARE @sql1 NVARCHAR(MAX) = N'';

	SELECT @sql1 += N'DROP function dbo.'
	  + QUOTENAME(name) + ';
	' FROM sys.objects
	WHERE type_desc LIKE '%FUNCTION%';
	EXEC sp_executesql @sql1;
COMMIT
GO

/* WipeAllData */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WipeAllData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WipeAllData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WipeAllData]
AS
BEGIN TRANSACTION
	TRUNCATE TABLE [Complex]
	TRUNCATE TABLE [BoxOfficeUser]
	TRUNCATE TABLE [Screen]
	TRUNCATE TABLE [ClassLayout]
	TRUNCATE TABLE [SeatLayout]
	TRUNCATE TABLE [Show]
	TRUNCATE TABLE [ShowMIS]
	TRUNCATE TABLE [Class]
	TRUNCATE TABLE [ClassMIS]
	TRUNCATE TABLE [Seat]
	TRUNCATE TABLE [SeatMIS]
	TRUNCATE TABLE [Item]
	TRUNCATE TABLE [Itemheads]
	TRUNCATE TABLE [Canteen]
	TRUNCATE TABLE [CanteenMIS]
	TRUNCATE TABLE [Log]
	TRUNCATE TABLE [LogMIS]
	TRUNCATE TABLE [DCR]
	TRUNCATE TABLE [PriceCardDetails]
	TRUNCATE TABLE [PriceCard]
	TRUNCATE TABLE [BookHistory]
	TRUNCATE TABLE [BlockHistory]
	TRUNCATE TABLE [CancelHistory]
	TRUNCATE TABLE BookingsReconcilliation

	INSERT INTO [BoxOfficeUser](
	[UserName]
	,[Password]
	,[UserRoleType]
	,[NoFailedLoginAttempts]
	,[LastLoggedInIP]
	,[IsSingleSession]
	,[IsUserEnabled]
	,[StartPageType]
	,[NoMaxVisibleShowDays]
	,[NoMinsToLockAfterShowTime]
	,[IsEditBoxOfficeSettings]
	,[IsEditComplexSettings]
	,[IsListUsers]
	,[IsEditUser]
	,[IsDeleteUser]
	,[IsListScreens]
	,[IsEditScreen]
	,[IsDeleteScreen]
	,[IsListDCRs]
	,[IsEditDCR]
	,[IsDeleteDCR]
	,[IsListShows]
	,[IsEditShow]
	,[IsDeleteShow]
	,[IsReleaseOnlineSeats]
	,[IsEditSeat]
	,[IsEditSeatBlock]
	,[IsEditSeatSell]
	,[IsEditSeatCancel]
	,[IsEditSeatOccupy]
	,[IsRePrintSoldSeat]
	,[IsViewKioskInterface]
	,[IsViewQRSentry]
	,[IsViewBookingStatusDisplay]
	,[IsListCanteenItems]
	,[IsFoodBillReprint]
	,[IsListReports]
	,[IsPrintInternetTicket]
	,[IsSellManagerQuotaBlockedTicket]
	,[IsSendtoOnline]
	,[IsFoodBillCancel]
	,[IsEditCanteenPurchase]
	,[IsListParkingTypes]
	,[IsEditParkingTypes]
	,[IsDeleteParkingTypes]
	,[IsListParkingEntry]
	,[IsViewCancel]
	,[IsDCRReport]
	,[IsAdvanceSalesSummaryReport]
	,[IsTransactionReport]
	,[IsPerformanceReport]
	,[IsAuditRefundReport]
	,[IsCashierReport]
	,[IsMarketingReport]
	,[IsQuickTicketsSalesSummaryReport]
	,[IsScreeningSchedule],
	IsAllowManagerQuotaBooking,
	IsHandoff,
	IsBoxOfficeSummary,
	IsManageDistributor,
	IsDistributorReport,
	IsBoxOfficeReceiptsSummary,
	IsCancelledShowDetails,
	IsCompleteSalesSummaryInfo,
	IsManageVendor,
	IsManageIngredients,
	IsManageItems,
	[IsPrintSalesSummaryInfo],
	IsManageCounter,
	IsManageSetupOrder,
	IsItemSalesReport,
	IsProductSalesReport,
	[IsConcessionReport],
	IsDailyCollectionSummaryReport,
	IsFourWeeklyReport,
	IsWeeklyReport,
	IsFormBReport,
	IsForm3BReport,
	IsForm17Report,
	IsForm3Report,
	IsFourWeeklyPercentageReport,
	IsEastMarketReport,
	IsMunicipalTaxReport,
	IsTaxLossReport
) VALUES (
	'YSAdmin'
	,'$2a$11$OXh5h/eYrYoJBQFgO/xVdOAPxBlzf4szO.qQFoFrZuTCZNj0mvH9m' 
	,0
	,0
	,''
	,0
	,1
	,0
	,0
	,0
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
)

INSERT INTO [BoxOfficeUser](
	[UserName]
	,[Password]
	,[UserRoleType]
	,[NoFailedLoginAttempts]
	,[LastLoggedInIP]
	,[IsSingleSession]
	,[IsUserEnabled]
	,[StartPageType]
	,[NoMaxVisibleShowDays]
	,[NoMinsToLockAfterShowTime]
	,[IsEditBoxOfficeSettings]
	,[IsEditComplexSettings]
	,[IsListUsers]
	,[IsEditUser]
	,[IsDeleteUser]
	,[IsListScreens]
	,[IsEditScreen]
	,[IsDeleteScreen]
	,[IsListDCRs]
	,[IsEditDCR]
	,[IsDeleteDCR]
	,[IsListShows]
	,[IsEditShow]
	,[IsDeleteShow]
	,[IsReleaseOnlineSeats]
	,[IsEditSeat]
	,[IsEditSeatBlock]
	,[IsEditSeatSell]
	,[IsEditSeatCancel]
	,[IsEditSeatOccupy]
	,[IsRePrintSoldSeat]
	,[IsViewKioskInterface]
	,[IsViewQRSentry]
	,[IsViewBookingStatusDisplay]
	,[IsListCanteenItems]
	,[IsFoodBillReprint]
	,[IsListReports]
	,[IsPrintInternetTicket]
	,[IsSellManagerQuotaBlockedTicket]
	,[IsSendtoOnline]
	,[IsFoodBillCancel]
	,[IsEditCanteenPurchase]
	,[IsListParkingTypes]
	,[IsEditParkingTypes]
	,[IsDeleteParkingTypes]
	,[IsListParkingEntry]
	,[IsViewCancel]
	,[IsDCRReport]
	,[IsAdvanceSalesSummaryReport]
	,[IsTransactionReport]
	,[IsPerformanceReport]
	,[IsAuditRefundReport]
	,[IsCashierReport]
	,[IsMarketingReport]
	,[IsQuickTicketsSalesSummaryReport]
	,[IsScreeningSchedule],
	IsAllowManagerQuotaBooking,
	IsHandoff,
	IsBoxOfficeSummary,
	IsManageDistributor,
	IsDistributorReport,
	IsBoxOfficeReceiptsSummary,
	IsCancelledShowDetails,
	IsCompleteSalesSummaryInfo,
	IsManageVendor,
	IsManageIngredients,
	IsManageItems,
	[IsPrintSalesSummaryInfo],
	IsManageCounter,
	IsManageSetupOrder,
	IsItemSalesReport,
	IsProductSalesReport,
	[IsConcessionReport],
	IsDailyCollectionSummaryReport,
	IsFourWeeklyReport,
	IsWeeklyReport,
	IsFormBReport,
	IsForm3BReport,
	IsForm17Report,
	IsForm3Report,
	IsFourWeeklyPercentageReport,
	IsEastMarketReport,
	IsMunicipalTaxReport,
	IsTaxLossReport
) VALUES (
	'YSBOAdmin'
	,'$2a$11$Nqd0MBy8vohN/miO69h1BulFQXcdbLYXDJGUfNHLfLTjByjToCMPu' 
	,0
	,0
	,''
	,0
	,1
	,0
	,0
	,0
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
	,1
)
		--/* Zero Price Card Details master entry */
		--SET IDENTITY_INSERT PriceCard ON
		--INSERT INTO PriceCard(Id, Name, Amount, CreatedBy, CreatedOn, TicketType)
		--VALUES (0, 'ZeroPriceCard', 0, 1, GETDATE(), 0)
		--SET IDENTITY_INSERT PriceCard OFF
COMMIT
GO

/* [WipeArchivedData] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WipeArchivedData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WipeArchivedData]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WipeArchivedData]
AS
BEGIN TRANSACTION
	TRUNCATE TABLE ShowMIS;
	TRUNCATE TABLE SeatMIS;
	TRUNCATE TABLE CanteenMIS;
	TRUNCATE TABLE ClassMIS;
	TRUNCATE TABLE LogMIS;
COMMIT
GO

/* ArchiveData */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ArchiveData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ArchiveData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ArchiveData]
AS
BEGIN

SET XACT_ABORT ON

UPDATE Complex SET LastMaintenanceTime = GETDATE()

BEGIN TRANSACTION
    SELECT ShowID INTO #Show
    FROM Show
	WHERE 
		IsHandoff = 0 AND 
		ShowTime < (CASE WHEN ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexID IN (SELECT ComplexID FROM Complex WHERE IsClearExpiredShows = 1)) THEN GETDATE() ELSE DATEADD(day, -1, GETDATE()) END) AND 
		IsLocked = 1 AND 
		IsSalesDataSent = (CASE WHEN OnlineShowId != '' THEN 1 ELSE IsSalesDataSent END) AND 
		IsBlockSalesDataSent = (CASE WHEN OnlineShowId != '' THEN 1 ELSE IsBlockSalesDataSent END) AND 
		IsSentBOSalesStatus = (CASE WHEN OnlineShowId != '' THEN 1 ELSE IsSentBOSalesStatus END) AND 
		ShowID NOT IN (SELECT ShowID FROM Class WHERE DCRID > 0 AND OpeningDCRNo IS NULL) AND
		ShowID NOT IN (SELECT ShowID FROM BookHistory WHERE IsReconciled = 0)
	
    INSERT INTO ShowMIS (
	ScreenID,
	ShowID,
	ScreenNo,
	ScreenName,
	OnlineMovieID,
	OnlineMovieName,
	MovieName,
	Experiences,
	MovieLanguageType,
	MovieCensorRatingType,
	ShowName,
	ShowTime,
	IsPaused,
	IsOnlinePaused,
	IsOnlineEdit,
	ResumeBefore,
	AllowedUsers,
	Duration,
	IsCancel,
	IsOnlineCancel,
	CancelRemarks,
	IsOnlinePublish,
	OnlineShowId,
	Uuid,
	EntryTime,
	IntervalTime,
	ExitTime,
	IsAdvanceToken,
	IsDisplaySeatNos,
	IsOnlineSaleClosed,
	[IsSalesDataSent],
	[IsPrintTicketAmount],
	IsPrintSlip,
	[MaintenanceCharge],
	[IsPrintPriceInSlip],
	[AdvanceTokenReleaseTime],
	[IsBlockSalesDataSent],
	IsRealTime,
	CreationType,
	[IsSentBOSalesStatus],
	[IsHandoff],
	DistributorMovieID,
	ShowCancelledOn,
	ShowCancelledByID,
	AdvanceTokenBufferTime,
	ManagerQuotaReleaseTime,
	IsLocked,
	UnpaidBookingReleaseTime,
	CreatedOn,
	LockShowTime,
	MovieMergedTo
	) SELECT
	ScreenID,
	ShowID,
	ScreenNo,
	ScreenName,
	OnlineMovieID,
	OnlineMovieName,
	MovieName,
	Experiences,
	MovieLanguageType,
	MovieCensorRatingType,
	ShowName,
	ShowTime,
	IsPaused,
	IsOnlinePaused,
	IsOnlineEdit,
	ResumeBefore,
	AllowedUsers,
	Duration,
	IsCancel,
	IsOnlineCancel,
	CancelRemarks,
	IsOnlinePublish,
	OnlineShowId,
	Uuid,
	EntryTime,
	IntervalTime,
	ExitTime,
	IsAdvanceToken,
	IsDisplaySeatNos,
	IsOnlineSaleClosed,
	[IsSalesDataSent],
	[IsPrintTicketAmount],
	IsPrintSlip,
	[MaintenanceCharge],
	[IsPrintPriceInSlip],
	[AdvanceTokenReleaseTime],
	[IsBlockSalesDataSent],
	IsRealTime,
	CreationType,
	[IsSentBOSalesStatus],
	[IsHandoff],
	DistributorMovieID,
	ShowCancelledOn,
	ShowCancelledByID,
	AdvanceTokenBufferTime,
	ManagerQuotaReleaseTime,
	IsLocked,
	UnpaidBookingReleaseTime,
	CreatedOn,
	LockShowTime,
	MovieMergedTo
	FROM Show WHERE ShowID IN (SELECT ShowID FROM #Show)
	
	DELETE FROM Show WHERE ShowID IN (SELECT ShowID FROM ShowMIS WHERE ShowID IN (SELECT ShowID FROM #Show))

	INSERT INTO ClassMIS (
	ScreenID,
	ShowID,
	ClassID,
	ClassLayoutID,
	ClassNo,
	ClassName,
	NoRows,
	NoCols,
	DCRID,
	Price,
	ETax,
	ATax,
	MC,
	BlockFee,
	NoMaxSeatsPerTicket,
	AllowedUsers,
	PriceCardId,
	OpeningDCRNo,
	ClosingDCRNo,
	IsPrintSeatLabel
	) SELECT
	ScreenID,
	ShowID,
	ClassID,
	ClassLayoutID,
	ClassNo,
	ClassName,
	NoRows,
	NoCols,
	DCRID,
	Price,
	ETax,
	ATax,
	MC,
	BlockFee,
	NoMaxSeatsPerTicket,
	AllowedUsers,
	PriceCardId,
	OpeningDCRNo,
	ClosingDCRNo,
	IsPrintSeatLabel
	FROM Class
	WHERE ShowID IN (SELECT ShowID FROM ShowMIS WHERE ShowID IN (SELECT ShowID FROM #Show))

	DELETE FROM Class WHERE ShowID IN (SELECT ShowID FROM ShowMIS WHERE ShowID IN (SELECT ShowID FROM #Show))

	INSERT INTO SeatMIS (
	ScreenID,
	ShowID,
	ClassID,
	ClassLayoutID,
	SeatLayoutID,
	TicketID,
	SeatID,
	DCRNo,
	SeatType,
	SeatLabel,
	RowNo,
	ColNo,
	PaymentType,
	PaymentReceived,
	StatusType,
	QuotaServicerID,
	QuotaServicerName,
	QuotaType,
	ReleaseBefore,
	PatronInfo,
	PatronFee,
	NoBlocks,
	NoSales,
	NoPrints,
	NoOccupies,
	NoCancels,
	LastBlockedByID,
	LastSoldByID,
	LastPrintedByID,
	LastOccupiedByID,
	LastCancelledByID,
	LastSoldOn,
	LastCancelledOn,
	LastBlockedOn,
	LastOccupiedOn,
	LastPrintedOn,
	PriceCardId,
	CoupleSeatIds,
	SeatClassInfo
	) SELECT
	ScreenID,
	ShowID,
	ClassID,
	ClassLayoutID,
	SeatLayoutID,
	TicketID,
	SeatID,
	DCRNo,
	SeatType,
	SeatLabel,
	RowNo,
	ColNo,
	PaymentType,
	PaymentReceived,
	StatusType,
	QuotaServicerID,
	QuotaServicerName,
	QuotaType,
	ReleaseBefore,
	PatronInfo,
	PatronFee,
	NoBlocks,
	NoSales,
	NoPrints,
	NoOccupies,
	NoCancels,
	LastBlockedByID,
	LastSoldByID,
	LastPrintedByID,
	LastOccupiedByID,
	LastCancelledByID,
	LastSoldOn,
	LastCancelledOn,
	LastBlockedOn,
	LastOccupiedOn,
	LastPrintedOn,
	PriceCardId,
	CoupleSeatIds,
	SeatClassInfo
	FROM Seat
	WHERE ShowID IN (SELECT ShowID FROM ShowMIS WHERE ShowID IN (SELECT ShowID FROM #Show))

	DELETE FROM Seat WHERE ShowID IN (SELECT ShowID FROM ShowMIS WHERE ShowID IN (SELECT ShowID FROM #Show))
	
    DROP TABLE #Show

	INSERT INTO LogMIS (
		LogID,
		TableType,
		ObjectID,
		ObjectName,
		TransactionType,
		TransactionLogType,
		TransactionDetail,
		TransactionTime,
		TransactionByIP,
		TransactionByID,
		TransactionByName,
		[Action]
	) SELECT
		LogID,
		TableType,
		ObjectID,
		ObjectName,
		TransactionType,
		TransactionLogType,
		TransactionDetail,
		TransactionTime,
		TransactionByIP,
		TransactionByID,
		TransactionByName,
		[Action]
	FROM Log
	WHERE TransactionTime < DATEADD(day, -1, GETDATE())

	DELETE FROM Log WHERE TransactionTime < DATEADD(day, -1, GETDATE())
COMMIT
SET XACT_ABORT OFF
END
GO

/****** Object:  StoredProcedure [dbo].[spWebServiceClientLoad]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spWebServiceClientLoad]
	@ClientID INT
AS
	SELECT
		ClientID,
		ClientName,
		ClientType,
		ClientPassword,
		IsAllowBlocking,
		NoMaxSeatsPerTicket
	FROM WebServiceClient
	WHERE ClientID = @ClientID
GO
/****** Object:  StoredProcedure [dbo].[spWebServiceClientEdit]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spWebServiceClientEdit]
	@ClientID INT,
	@ClientName VARCHAR(32),
	@ClientType TINYINT,
	@ClientPassword VARCHAR(32),
	@IsAllowBlocking BIT,
	@NoMaxSeatsPerTicket INT
AS
	UPDATE WebServiceClient
	SET ClientName = @ClientName,
		ClientType = @ClientType,
		ClientPassword = @ClientPassword,
		IsAllowBlocking = @IsAllowBlocking,
		NoMaxSeatsPerTicket = @NoMaxSeatsPerTicket
	WHERE ClientID = @ClientID
GO
/****** Object:  StoredProcedure [dbo].[spWebServiceClientDelete]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spWebServiceClientDelete]
	@ClientID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
	SET @ReferredBy = ''
	IF EXISTS ( SELECT NULL FROM Seat WHERE QuotaServicerID = @ClientID )
		SET @ReferredBy = 'Seat'
	ELSE IF EXISTS ( SELECT NULL FROM SeatMIS WHERE QuotaServicerID = @ClientID )
		SET @ReferredBy = 'SeatMIS'
	ELSE IF EXISTS ( SELECT NULL FROM Canteen WHERE QuotaServicerID = @ClientID )
		SET @ReferredBy = 'Canteen'
	ELSE IF EXISTS ( SELECT NULL FROM CanteenMIS WHERE QuotaServicerID = @ClientID )
		SET @ReferredBy = 'CanteenMIS'
	
	If @ReferredBy = ''
	BEGIN
		DELETE FROM Log
		WHERE TableType = ( SELECT TOP 1 Value FROM Type WHERE TypeNo = 1 AND Expression = 'WebServiceClient' )
		AND ObjectID = @ClientID
	
		DELETE FROM WebServiceClient
		WHERE ClientID = @ClientID
	END
GO
/****** Object:  StoredProcedure [dbo].[spWebServiceClientAdd]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spWebServiceClientAdd]
	@ClientID INT OUTPUT,
	@ClientName VARCHAR(32),
	@ClientType TINYINT,
	@ClientPassword VARCHAR(32),
	@IsAllowBlocking BIT,
	@NoMaxSeatsPerTicket INT
AS
	INSERT INTO WebServiceClient (
		ClientName,
		ClientType,
		ClientPassword,
		IsAllowBlocking,
		NoMaxSeatsPerTicket

	) VALUES (
		@ClientName,
		@ClientType,
		@ClientPassword,
		@IsAllowBlocking,
		@NoMaxSeatsPerTicket
	) SET @ClientID = SCOPE_IDENTITY()
GO

/****** Object:  StoredProcedure [dbo].[spUserNames]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spUserNames]
(
@UserName as Varchar(50)
)
as 
begin 
select distinct UserName from BoxOfficeUser where UserName like '%'+@UserName+'%'
end
GO
/****** Object:  StoredProcedure [dbo].[spUpdateBlockFee]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spUpdateBlockFee]
(
@BlockFee decimal,
@ClassID int
)
as
begin
update Class set BlockFee=@BlockFee where ClassID=@ClassID
end
GO

/* spTypeLoadAll */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTypeLoadAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTypeLoadAll]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spTypeLoadAll]
AS
	SELECT
		MAX(TypeNo),
		MAX(Value)
	FROM Type;
	 select 
		TypeNo,
		Value,
		Expression from Type where TypeName<>'PrintType' and TypeName<>'PrintOrientationType' and TypeName <> 'QuotaType' and TypeName <> 'PaymentType'
union
select 
		TypeNo,
		Value,
		Expression from Type where TypeName='PrintType'
		union
select 
		TypeNo,
		Value,
		Expression from Type where TypeName='PrintOrientationType' and Value=0
union
select 
		TypeNo,
		Value,
		Expression from Type where TypeName='QuotaType' and (Value=1 or Value=0 or Value=2 or Value=3)
union
select 
		TypeNo,
		Value,
		Expression from Type where TypeName='PaymentType' and Value<>6

GO
/****** Object:  StoredProcedure [dbo].[spShowUpdateOnlineShowId]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spShowUpdateOnlineShowId]
	@ShowID INT,
	@OnlineShowID NVARCHAR(64)
AS
UPDATE Show SET OnlineShowId = @OnlineShowID WHERE ShowID=@ShowID;
GO

/* [spShowSync] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowSync]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowSync]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spShowSync]
(
	@SessionId VARCHAR(64)='',
	@SeatClassInfo NVARCHAR(MAX),
	@BEBookingCode VARCHAR(64),
	@Patron VARCHAR(128)=''
)
AS
BEGIN
	SELECT items INTO #SeatClassInfo FROM dbo.fnsplit(@SeatClassInfo, ',')
	IF ((SELECT IsAdvanceToken FROM Show WHERE OnlineShowId = @SessionId) = 1)
	BEGIN
		UPDATE Seat SET StatusType = 1, PatronInfo = @Patron, TicketID = ISNULL((SELECT Top 1 SeatID FROM Seat WHERE PatronInfo = @Patron ORDER BY SeatID), (SELECT Top 1 SeatID FROM Seat WHERE SeatClassInfo IN (SELECT items FROM #SeatClassInfo) AND ShowID = (SELECT ShowID FROM Show where OnlineShowId = @SessionId) ORDER BY SeatID)), PaymentType = 1 
		WHERE SeatType <> 1 AND StatusType NOT IN (1,2,3) AND QuotaType = 3 AND SeatClassInfo IN (SELECT items FROM #SeatClassInfo) AND ShowID = (SELECT ShowID FROM Show where OnlineShowId = @SessionId) 
	END
	ELSE
	BEGIN
		UPDATE Seat SET StatusType = 2, PatronInfo = @Patron, TicketID = ISNULL((SELECT Top 1 SeatID FROM Seat WHERE PatronInfo = @Patron ORDER BY SeatID), (SELECT Top 1 SeatID FROM Seat WHERE SeatClassInfo IN (SELECT items FROM #SeatClassInfo) AND ShowID = (SELECT ShowID FROM Show where OnlineShowId = @SessionId) ORDER BY SeatID)), PaymentType = 1, LastSoldOn = GETDATE()
		WHERE SeatType <> 1 AND StatusType NOT IN (2,3) AND QuotaType = 3 AND SeatClassInfo IN (SELECT items FROM #SeatClassInfo) AND ShowID = (SELECT ShowID FROM Show where OnlineShowId = @SessionId)
			
		IF (@BEBookingCode <> '' AND NOT EXISTS(SELECT SeatId FROM BookHistory WHERE BEBookingCode = @BEBookingCode))
		BEGIN
			SELECT S.SeatID, S.PriceCardID, PC.ItemID, PC.ItemPriceID, PC.Quantity, PC.DiscountPerItem, S.ShowID, SC.ComplexID INTO #tempSeat FROM Seat S, PriceCardItemDetails PC, Screen SC WHERE S.SeatClassInfo IN (SELECT items FROM #SeatClassInfo) AND ShowID = (SELECT ShowID FROM Show where OnlineShowId = @SessionId) AND S.QuotaType = 3 AND S.StatusType = 2 AND S.PatronInfo = @Patron AND S.PriceCardID = PC.PriceCardID AND S.ScreenID = SC.ScreenID 
					
			DECLARE @transactionID VARCHAR(10)
					
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
				SELECT @transactionID, ItemID, ItemPriceID, Quantity, 3, 1, 0, ComplexID, 0, GETDATE(), DiscountPerItem, SeatID, 1 FROM #tempSeat
						
				SELECT I.ItemID, SUM(t.Quantity) AS Quantity INTO #ItemQuantity FROM #tempSeat t, Items I WHERE I.ItemID = t.ItemID GROUP BY I.ItemID
						
				UPDATE I SET I.BlockedStock = I.BlockedStock + IQ.Quantity FROM Items I, #ItemQuantity IQ WHERE I.ItemID = IQ.ItemID
				DROP TABLE #ItemQuantity
			END
					
			INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, BEBookingCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID, IsReconciled)
			SELECT ShowId, SeatId, SeatClassInfo, '', @BEBookingCode, PatronInfo, 0, GETDATE(), PaymentType, PriceCardId, CASE WHEN SeatID IN (SELECT TS.SeatID FROM #tempSeat TS) THEN @transactionID ELSE NULL END, 1 FROM Seat WHERE SeatClassInfo IN (SELECT items FROM #SeatClassInfo) AND ShowID = (SELECT ShowID FROM Show where OnlineShowId = @SessionId) AND QuotaType = 3 AND StatusType = 2 AND PatronInfo = @Patron
					
			DROP TABLE #tempSeat
		END
	END
END
GO

/*[UpdatePauseResume]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdatePauseResume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdatePauseResume
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].UpdatePauseResume
	@ShowID INT,
	@IsPaused BIT
AS
BEGIN
	UPDATE Show SET IsPaused = @IsPaused WHERE ShowID = @ShowID
END
GO

/*[spShowNames]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowNames]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowNames]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spShowNames]
@ShowName AS VARCHAR(25)
AS
BEGIN
	SELECT DISTINCT * FROM
	(
	SELECT DISTINCT ShowName FROM Show WHERE ShowName LIKE '%'+@ShowName+'%'
	UNION ALL
	SELECT DISTINCT ShowName FROM ShowMIS WHERE ShowName LIKE '%'+@ShowName+'%'
	) ShowNames
END
GO

/* [spShowEdit]  */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowEdit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowEdit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spShowEdit]
	@UserId Int=0,
	@ClassPriceDetails NVARCHAR(4000) = '',
	@ScreenID INT,
	@ShowID INT,
	@Experiences NVARCHAR(MAX),
	@ShowName VARCHAR(25),
	@ShowTime DATETIME,
	@IsPaused BIT,
	@ResumeBefore INT,
	@AllowedUsers VARCHAR(128),
	@NoMaxVisibleShowDays TINYINT,
	@Duration INT,
	@IsOnlinePublish BIT,
	@EntryTime INT,
	@IntervalTime INT,
	@ExitTime INT,
	@AdvanceTokenBufferTime INT,
	@IsPrintSlip BIT,
	@LockShowTime INT,
	@IsPrintTicketAmount BIT,
	@ManagerQuotaReleaseTime INT

AS
	IF @ShowTime < GETDATE()
	BEGIN
		RAISERROR('Show time over!', 11, 1)
		RETURN
	END

	IF @NoMaxVisibleShowDays > 0
	BEGIN
		IF @ShowTime > DATEADD(day, @NoMaxVisibleShowDays, GETDATE())
		BEGIN
			RAISERROR('Show time exceeds your visible show days limit!', 11, 1)
			RETURN
		END
	END

	IF EXISTS ( SELECT ShowID FROM Show WHERE ShowID <> @ShowID And isCancel=0 AND ScreenID = @ScreenID AND ShowTime = @ShowTime )
	BEGIN
		RAISERROR('Show time conflict!', 11, 1)
		RETURN
	END

	
	IF EXISTS ( SELECT ShowID FROM Show WHERE ScreenID = @ScreenID And ShowID <> @ShowID And isCancel=0  AND (ShowTime between @ShowTime and dateadd(mi,@Duration + @EntryTime + @IntervalTime + @ExitTime,@ShowTime) ))
	BEGIN
		RAISERROR('There is a Show within Duration, Please check Duration Field!', 11, 1)
		RETURN
	END
	
	if(@ShowTime<=(select top(1) dateadd(mi,duration + entryTime + intervalTime + exitTime,showtime) from Show where ScreenID =@ScreenID And isCancel=0 and ShowID<>@ShowID and showtime<@ShowTime order by showtime desc))
	BEGIN
		RAISERROR('Previous Show is Still Playing, Please adjust Showtime accordingly !', 11, 1)
		RETURN
	END

	IF NOT EXISTS ( SELECT ShowID FROM Show WHERE ShowID = @ShowID AND (@ShowTime BETWEEN dateadd(mi, -120, ShowTime) and dateadd(mi, 120, ShowTime)))
	BEGIN
		RAISERROR('Session time can be modified + or - 120 minutes while editing a session.', 11, 1)
		RETURN
	END

	DECLARE @OldScreenID INT
	DECLARE @OldShowTime DATETIME
	DECLARE @ScreenNo VARCHAR(2)
	DECLARE @ScreenName NVARCHAR(256)
	DECLARE @OldManagerQuotaReleaseTime INT
	SELECT @OldScreenID = ScreenID,
		@OldShowTime = ShowTime,
		@OldManagerQuotaReleaseTime=ManagerQuotaReleaseTime
	FROM Show
	WHERE ShowID = @ShowID

	IF @OldShowTime < GETDATE()
	BEGIN
		RAISERROR('Show time over!', 11, 1)
		RETURN
	END

	if @OldManagerQuotaReleaseTime != @ManagerQuotaReleaseTime
	BEGIN
		If dateadd(mi, -1*@OldManagerQuotaReleaseTime, @OldShowTime) < GETDATE()
		BEGIN
			RAISERROR('Manager Quota already Released!', 11, 1)
			RETURN
		END

		If dateadd(mi, -1*@ManagerQuotaReleaseTime, @ShowTime) < GETDATE()
		BEGIN
			RAISERROR('Invalid Manager Quota Release Time', 11, 1)
			RETURN
		END
	END

	SELECT @ScreenNo = ScreenNo,
		@ScreenName = ScreenName
	FROM Screen
	WHERE ScreenID = @ScreenID
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE Show
			SET ScreenID = @ScreenID,
				/*ShowID = @ShowID,*/
				ScreenNo = @ScreenNo,
				ScreenName = @ScreenName,
				Experiences = @Experiences,
				ShowName = @ShowName,
				ShowTime = @ShowTime,
				--IsPaused = @IsPaused,
				--IsOnlinePaused = @IsPaused,
				ResumeBefore = @ResumeBefore,
				AllowedUsers = @AllowedUsers,
				Duration = @Duration,
				IsOnlinePublish=@IsOnlinePublish ,
				EntryTime=@EntryTime,
				IntervalTime=@IntervalTime,
				--IsOnlineEdit = 0,
				ExitTime=@ExitTime,
				AdvanceTokenBufferTime = @AdvanceTokenBufferTime,
				IsPrintSlip = @IsPrintSlip,
				LockShowTime = @LockShowTime,
				IsPrintTicketAmount = @IsPrintTicketAmount,
				ManagerQuotaReleaseTime=@ManagerQuotaReleaseTime
			WHERE ShowID = @ShowID

			CREATE TABLE #Class ( ClassID INT, ValueType INT, PRIMARY KEY(ClassID, ValueType) )
			CREATE TABLE #PriceClassLayout (ClassLayoutID INT, PriceCardID INT)
			
			DECLARE @ClassLayoutID INT
			DECLARE @ValueType INT
			DECLARE @Value NUMERIC(9,2)

			DECLARE @ROWID1 AS INT;
				DECLARE @VALUE1 AS VARCHAR(MAX);
				DECLARE @ROWID2 AS INT;
				DECLARE @VALUE2 AS VARCHAR(MAX);
				DECLARE @CMDSTR AS NVARCHAR(MAX)='';
				DECLARE SECONDCURSOR CURSOR -- DECLARE CURSOR
				LOCAL SCROLL STATIC
				FOR
				SELECT *  FROM DBO.SPLIT('#', @ClassPriceDetails)
				OPEN SECONDCURSOR -- OPEN THE CURSOR
				FETCH NEXT FROM SECONDCURSOR
				INTO @ROWID1,@VALUE1
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF (@VALUE1 <>'')
					BEGIN
						DECLARE @classLayout INT
						DECLARE @priceCardID INT
						DECLARE @IsPrintSeatLabel BIT
						DECLARE @currnetDCRId INT
						DECLARE @DCRId INT
					
						SELECT @classLayout = VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =1					
						SELECT @priceCardID = VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =2
						SELECT @currnetDCRId = VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =3
						SELECT @IsPrintSeatLabel = VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =4

						SELECT @DCRId = DCRId FROM Class WHERE ShowId = @ShowId and ClassLayoutID = @classLayout
						
						IF @DCRId != @currnetDCRId
							IF EXISTS(SELECT SeatID FROM Seat WHERE ShowID = @ShowId AND StatusType != 0)
								RAISERROR('Unable to edit DCR at this time. Some of the seats are unavailable.', 11, 1)
						
						DECLARE @PriceCards NVARCHAR(MAX) 
						SELECT @PriceCards = Value FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =5
						SELECT items INTO #priceIDs FROM dbo.fnsplit(@PriceCards, ',')
						
						IF NOT EXISTS (SELECT * FROM #priceIDs WHERE items = @priceCardID)
						BEGIN
							DROP TABLE #priceIDs
							DROP TABLE #Class
							DROP TABLE #PriceClassLayout
							RAISERROR('Set Master Price Card Properly', 11, 1)
						END
					
						INSERT INTO #PriceClassLayout (ClassLayoutID, PriceCardID)
						SELECT @classLayout, items FROM #priceIDs
					
						DROP TABLE #priceIDs
					
						UPDATE Class SET PriceCardId = @priceCardID, IsPrintSeatLabel = @IsPrintSeatLabel, DCRID = @currnetDCRId
						WHERE ShowId = @ShowId and ClassLayoutID = @classLayout

						UPDATE Seat SET PriceCardId = @priceCardID
						WHERE ShowId = @ShowId and ClassLayoutID = @classLayout AND StatusType = 0
						
						DELETE FROM ClassPriceCards WHERE ClassID IN (SELECT ClassID FROM Class WHERE ClassLayoutID = @classLayout AND ShowID = @showID) AND ShowID = @showID AND ClassLayoutID = @classLayout
						
						INSERT INTO ClassPriceCards (ShowID, ClassID, PriceCardID, ClassLayoutID)
						SELECT ShowID, ClassID, PC.PriceCardID, Class.ClassLayoutID FROM Class 
						INNER JOIN #PriceClassLayout PC ON PC.ClassLayoutID = Class.ClassLayoutID AND PC.ClassLayoutID = @classLayout
						WHERE ShowID = @ShowID AND Class.ClassLayoutID = @classLayout
					END	
				FETCH NEXT FROM SECONDCURSOR
				INTO @ROWID1,@VALUE1
				END
				CLOSE SECONDCURSOR -- CLOSE THE CURSOR
				DEALLOCATE SECONDCURSOR -- DEALLOCATE THE CURSOR

			DROP TABLE #Class
			DROP TABLE #PriceClassLayout 

			DECLARE @jobStatusNew INT = 0

			IF NOT EXISTS(SELECT Id FROM ShowSyncJobs WHERE ShowId = @ShowID AND [Status] = @jobStatusNew)
				INSERT INTO ShowSyncJobs(ShowId, OnlineShowId)
				SELECT ShowId, OnlineShowId FROM Show WHERE ShowID = @ShowID AND OnlineShowId != ''

			IF @OldShowTime != @ShowTime
			BEGIN
				UPDATE ShowSyncJobs SET Data = (SELECT (SELECT CONVERT(VARCHAR(19), CONVERT(DATETIME,SWITCHOFFSET(CONVERT(DATETIMEOFFSET, @OldShowTime),'-05:30')), 126))+ 'Z' + '|' + (SELECT CONVERT(VARCHAR(19), CONVERT(DATETIME,SWITCHOFFSET(CONVERT(DATETIMEOFFSET, @ShowTime),'-05:30')), 126))+ 'Z')
				WHERE ShowId = @ShowID AND [Status] = @jobStatusNew
			END

		COMMIT 
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT>0)
			ROLLBACK

		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SET @ErrorMessage = ERROR_MESSAGE();  
		SET @ErrorSeverity = ERROR_SEVERITY();  
		SET @ErrorState = ERROR_STATE();  

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
	END CATCH
GO

/* [spShowCopy] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowCopy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowCopy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spShowCopy]
	@ShowTime DATETIME,
	@NoMaxVisibleShowDays TINYINT
AS
	IF DATEADD(day, 1, @ShowTime) < GETDATE()
	BEGIN
		RAISERROR('Show time over!', 11, 1)
		RETURN
	END

	IF @NoMaxVisibleShowDays > 0
	BEGIN
		IF DATEADD(day, 1, @ShowTime) > DATEADD(day, @NoMaxVisibleShowDays, GETDATE())
		BEGIN
			RAISERROR('Show time exceeds your visible show days limit!', 11, 1)
			RETURN
		END
	END

	
	IF  EXISTS (select sh.screenid,count(*) AvlShows, max(scr.NumberOfShowsAllowed) AlwShows from show sh JOIN Screen scr ON sh.ScreenID=scr.ScreenID
	where iscancel = 0 and (CONVERT(date,ShowTime) = CONVERT(date,@ShowTime)or CONVERT(date,ShowTime) = CONVERT(date,dateadd(day,1,@ShowTime))) group by sh.screenid having count(*) > max(scr.NumberOfShowsAllowed))
		begin
			RAISERROR(' Show Limit For Screen Mismatch !',11,1)
			return
		end

	CREATE TABLE #CopyShows ( CopyShowID INT PRIMARY KEY )
	DECLARE @NewShowID AS INT

	INSERT INTO #CopyShows (
		CopyShowID
	)	SELECT ShowID FROM Show
		WHERE 
		DATEDIFF(day, ShowTime, @ShowTime) = 0
		AND IsCancel = 0
		AND ShowID NOT IN
		(SELECT DISTINCT C.ShowID
		FROM
		(SELECT DISTINCT ShowID, ScreenID, ShowTime,
		DATEADD(minute, Duration + EntryTime + IntervalTime + ExitTime, ShowTime) as EndTime  FROM Show 
		WHERE
		DATEDIFF(day, ShowTime, @ShowTime) = 0 AND IsCancel = 0
		)C,
		(select ScreenID, CAST(ShowTime AS DATE) as CurrentDate , ShowTime as StartTime, 
		DATEADD(minute, Duration + EntryTime + IntervalTime + ExitTime, ShowTime) as EndTime
		from show where ShowTime > DATEADD(day, 1,@ShowTime) AND IsCancel = 0)D
		where 
		C.Screenid = D.Screenid
		AND (DATEADD(day, 1, C.ShowTime) BETWEEN D.StartTime AND D.EndTime OR D.StartTime BETWEEN DATEADD(day, 1, C.ShowTime) AND DATEADD(day, 1, C.EndTime))
		)	
	DECLARE @allShowCopy NVARCHAR(50)
	DECLARE @CopyShowID INT
	DECLARE @errorMessage NVARCHAR(200) = ''
	DECLARE curCopyShows CURSOR	FOR SELECT CopyShowID FROM #CopyShows
	OPEN curCopyShows
	FETCH NEXT FROM curCopyShows INTO @CopyShowID
	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE @CountClassLayout as INT
		DECLARE @CountClass as INT
		SET @CountClassLayout=(Select Count(Distinct ClassLayoutID) From ClassLayout Where ScreenID in (SELECT ScreenID FROM Show WHERE ShowID =@CopyShowID) AND ClassLayout.ClassLayoutID IN (SELECT DISTINCT ClassLayoutID FROM SeatLayout WHERE ScreenID IN (SELECT ScreenID FROM Show WHERE ShowID =@CopyShowID) and SeatType <> 1))
		SET @CountClass=(SELECT COUNT(ClassLayoutID) FROM Class WHERE ShowID=@CopyShowID )
		IF(@CountClassLayout != @CountClass)
		BEGIN
			SET @errorMessage = 'Since New ClassLayout is added'
			FETCH NEXT FROM curCopyShows INTO @CopyShowID
			CONTINUE
		END
		IF NOT EXISTS (SELECT ScreenID FROM SeatLayout WHERE ScreenId IN (SELECT ScreenID FROM Class WHERE ShowID = @CopyShowID) AND SeatLabel = '' AND SeatType != 1)
		BEGIN
		BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO Show (
				ScreenID,
				ScreenNo,
				ScreenName,
				OnlineMovieID,
				OnlineMovieName,
				MovieName,
				Experiences,
				MovieLanguageType,
				MovieCensorRatingType,
				ShowName,
				ShowTime,
				IsPaused,
				IsOnlinePaused,
				ResumeBefore,
				AllowedUsers,
				Duration,
				IsOnlinePublish,
				EntryTime,
				IntervalTime,
				ExitTime,
				IsAdvanceToken,
				IsDisplaySeatNos,
				[IsPrintTicketAmount],
				IsPrintSlip,
				AdvanceTokenReleaseTime,
				IsRealTime,
				CreationType,
				DistributorMovieId,
				AdvanceTokenBufferTime,
				ManagerQuotaReleaseTime,
				UnpaidBookingReleaseTime,
				LockShowTime,
				MovieMergedTo
				
			)	SELECT
				ScreenID,
				ScreenNo,
				ScreenName,
				OnlineMovieID,
				OnlineMovieName,
				MovieName,
				Experiences,
				MovieLanguageType,
				MovieCensorRatingType,
				ShowName,
				DATEADD(day, 1, ShowTime),
				1, /* IsPaused Safe Side */
				1,
				ResumeBefore,
				AllowedUsers,
				Duration,
				IsOnlinePublish,
				EntryTime,
				IntervalTime,
				ExitTime,
				IsAdvanceToken,
				IsDisplaySeatNos,
				[IsPrintTicketAmount],
				IsPrintSlip,
				AdvanceTokenReleaseTime,
				IsRealTime,
				CreationType,
				DistributorMovieID,
				--CASE WHEN DistributorMovieID = 0 THEN 0 ELSE (CASE WHEN OnlineMovieID = '0' THEN DistributorMovieID ELSE (SELECT DMC.Id FROM DistributorMovieCollections DMC WHERE DMC.OnlineMovieId = Show.OnlineMovieId AND IsDeleted = 0) END) END,
				AdvanceTokenBufferTime,
				ManagerQuotaReleaseTime,
				UnpaidBookingReleaseTime,
				LockShowTime,
				MovieMergedTo
				FROM Show WHERE ShowID  = @CopyShowID
				SET @NewShowID = SCOPE_IDENTITY()

			INSERT INTO Class (
				ScreenID,
				ShowID,
				ClassLayoutID,
				ClassNo,
				ClassName,
				NoRows,
				NoCols,
				Price,
				ETax,
				ATax,
				MC,
				NoMaxSeatsPerTicket,
				AllowedUsers,
				DCRID,
				PriceCardId,
				IsPrintSeatLabel
			)	SELECT
				ScreenID,
				@NewShowID,
				ClassLayoutID,
				ClassNo,
				ClassName,
				NoRows,
				NoCols,
				Price,
				ETax,
				ATax,
				MC,
				NoMaxSeatsPerTicket,
				AllowedUsers,
				DCRID,
				PriceCardId,
				IsPrintSeatLabel
				FROM Class
				WHERE ShowID = @CopyShowID

			INSERT INTO Seat (
				ScreenID,
				ShowID,
				ClassID,
				ClassLayoutID,
				CoupleSeatIds,
				SeatLayoutID,
				SeatType,
				SeatLabel,
				RowNo,
				ColNo,
				QuotaType,
				ReleaseBefore,
				PriceCardId,
				SeatClassInfo
			)	SELECT
				(select top(1) ScreenID from Show where ShowID=@NewShowID),
				@NewShowID,
				( SELECT TOP 1 Class.ClassID FROM Class WHERE Class.ShowID = @NewShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID order by Classid desc ),
				SeatLayout.ClassLayoutID,
				SeatLayout.CoupleSeatIds,
				SeatLayout.SeatLayoutID,
				SeatLayout.SeatType,
				SeatLayout.SeatLabel,
				SeatLayout.RowNo,
				SeatLayout.ColNo,
				SeatLayout.QuotaType,
				SeatLayout.ReleaseBefore,
				(SELECT TOP 1 PriceCardId FROM Class WHERE Class.ShowID = @NewShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID order by Classid desc),
				CASE WHEN SeatLayout.SeatLabel <> '' Then ( SELECT TOP 1 Class.ClassName FROM Class WHERE Class.ShowID = @NewShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID ) + '_' + SeatLayout.SeatLabel ELSE NULL END
				FROM SeatLayout
				WHERE SeatLayout.ScreenID = (select top(1) ScreenID from Show where ShowID=@NewShowID)
				AND SeatLayout.ClassLayoutID IN (SELECT DISTINCT ClassLayoutID from SeatLayout where ScreenID = (select top(1) ScreenID from Show where ShowID=@NewShowID) and SeatType <> 1)
			
			INSERT INTO ClassPriceCards (ShowID, ClassID, PriceCardID, ClassLayoutID)
			SELECT @NewShowID, 
			(SELECT TOP 1 Class.ClassID FROM Class WHERE Class.ShowID = @NewShowID AND Class.ClassLayoutID = CPC.ClassLayoutID order by Classid desc),
			PriceCardID,
			ClassLayoutID
			FROM ClassPriceCards CPC WHERE CPC.ShowID = @CopyShowID
		
			IF EXISTS (SELECT ShowID FROM Show WHERE ShowID = @NewShowID AND IsRealTime = 1)
				UPDATE Seat SET QuotaType = 0 WHERE QuotaType = 3 AND ShowID = @NewShowID
		COMMIT
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK
		END CATCH
		END
		ELSE
		BEGIN
			SET @allShowCopy = ''
			SET @allShowCopy = 'Some of the shows are not copied'
		END
		FETCH NEXT FROM curCopyShows INTO @CopyShowID
	END
	
	DROP TABLE #CopyShows
	IF @errorMessage <> ''
	BEGIN
		RAISERROR(@errorMessage, 11, 1)
		RETURN
	END	
	
	IF @allShowCopy <> ''
	BEGIN
		RAISERROR(@allShowCopy, 11, 1)
		RETURN
	END
GO

/* [dbo].[spShowCancel] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowCancel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowCancel]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[spShowCancel]
	@ShowID INT,
	@Remarks VARCHAR(300),
	@IsOnlineCancel BIT,
	@CancelledBy int,
	@IsArchived BIT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		IF @IsArchived = 1
		BEGIN	
			UPDATE ShowMIS SET ShowCancelledOn = GETDATE(), ShowCancelledByID = @CancelledBy, IsCancel=1, IsOnlineCancel = @IsOnlineCancel, CancelRemarks = (CASE CancelRemarks WHEN '' THEN @Remarks ELSE CancelRemarks END) WHERE ShowID=@ShowID;
			UPDATE SeatMIS SET LastCancelledByID=@CancelledBy,LastCancelledOn=GETDATE() WHERE ShowID=@ShowID and statustype>0
		END
		ELSE
		BEGIN
			UPDATE Show SET ShowCancelledOn = GETDATE(), ShowCancelledByID = @CancelledBy, IsCancel=1, IsOnlineCancel = @IsOnlineCancel, CancelRemarks = (CASE CancelRemarks WHEN '' THEN @Remarks ELSE CancelRemarks END) WHERE ShowID=@ShowID;
			UPDATE Seat SET LastCancelledByID=@CancelledBy,LastCancelledOn=GETDATE() WHERE ShowID=@ShowID and statustype>0;
		END
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
GO

/* [dbo].[spShowAdd] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowAdd]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--6&100&0#1&100&0#2&100&0#4&100&0#
CREATE PROCEDURE [dbo].[spShowAdd]
	@UserId Int=0,
	@ClassPriceDetails NVARCHAR(4000) = '',
	@ScreenID INT,
	@ShowID INT OUTPUT,
	@ScreenNo VARCHAR(2) OUTPUT,
	@ScreenName NVARCHAR(256) OUTPUT,
	@OnlineMovieID NVARCHAR(64),
	@OnlineMovieName NVARCHAR(64),
	@MovieName NVARCHAR(64),
	@Experiences NVARCHAR(MAX),
	@MovieLanguageType TINYINT,
	@MovieCensorRatingType TINYINT,
	@ShowName VARCHAR(25),
	@ShowTime DATETIME,
	@IsPaused BIT,
	@IsOnlinePaused BIT,
	@ResumeBefore INT,
	@AllowedUsers VARCHAR(128),
	@NoMaxVisibleShowDays TINYINT,
	@Duration INT,
	@IsCancel BIT,
	@IsOnlinePublish BIT,
	@EntryTime INT,
	@IntervalTime INT,
	@ExitTime INT,
	@IsAdvanceToken BIT,
	@IsDisplaySeatNos BIT,	
	@IsPrintTicketAmount BIT,
	@IsPrintSlip BIT,
	@IsPrintPriceInSlip BIT,
	@AdvanceTokenReleaseTime INT,
	@IsRealTime BIT,
	@CreationType BIT,
	@DistributorMovieId INT,
	@AdvanceTokenBufferTime INT,
	@ManagerQuotaReleaseTime INT,
	@UnpaidBookingReleaseTime INT,
	@LockShowTime INT,
	@MovieMergedTo NVARCHAR(64)
AS
		IF @ShowTime < GETDATE()
	BEGIN
		RAISERROR('Show time over!', 11, 1)
		RETURN
	END

	IF @NoMaxVisibleShowDays > 0
	BEGIN
		IF @ShowTime > DATEADD(day, @NoMaxVisibleShowDays, GETDATE())
		BEGIN
			RAISERROR('Show time exceeds your visible show days limit!', 11, 1)
			RETURN
		END
	END

	IF EXISTS ( SELECT ScreenID FROM SeatLayout WHERE ScreenID =  @ScreenID AND SeatLabel = '' AND SeatType != 1)
	BEGIN
		RAISERROR('Error in selected screen. Check seat label of the class of selected screen ', 11, 1)
		RETURN
	END

	IF EXISTS ( SELECT ShowID FROM Show WHERE ScreenID = @ScreenID AND ShowTime = @ShowTime And isCancel=0 )
	BEGIN
		RAISERROR('Show time conflict!', 11, 1)
		RETURN
	END
	
	IF EXISTS ( SELECT ShowID FROM Show WHERE ScreenID = @ScreenID And isCancel=0 AND (ShowTime between @ShowTime and dateadd(mi,@Duration + @EntryTime + @IntervalTime + @ExitTime,@ShowTime) ))
	BEGIN
		RAISERROR('There is a Show within Duration, Please check Duration Field!', 11, 1)
		RETURN
	END
	
	IF(@ShowTime<=(select top(1) dateadd(mi,duration + entryTime + intervalTime + exitTime,showtime) from Show where ScreenID =@ScreenID And isCancel=0 and showtime<@ShowTime order by showtime desc))
	BEGIN
		RAISERROR('Previous Show is Still Playing, Please adjust Showtime accordingly!', 11, 1)
		RETURN
	END

	IF @DistributorMovieId <> 0
		IF NOT EXISTS(SELECT Id FROM DistributorMovieCollections WHERE Id = @DistributorMovieId AND (OnlineMovieID = @OnlineMovieID OR OnlineMovieId = @MovieMergedTo OR MovieMergedTo = @OnlineMovieID OR MovieName = @MovieName))
		BEGIN
			RAISERROR('Selected Movie is not mapped with the selected Distributor. Check again or Update Movie Details!', 11, 1)
			RETURN
		END

	SET @ScreenNo = ''
	SET @ScreenName = ''
		
	SELECT @ScreenNo = ScreenNo,
		@ScreenName = ScreenName
	FROM Screen
	WHERE ScreenID = @ScreenID
	
	BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		BEGIN TRANSACTION

		INSERT INTO Show (
			ScreenID,
			ScreenNo,
			ScreenName,
			OnlineMovieID,
			OnlineMovieName,
			MovieName,
			Experiences,
			MovieLanguageType,
			MovieCensorRatingType,
			ShowName,
			ShowTime,
			IsPaused,
			IsOnlinePaused,
			ResumeBefore,
			AllowedUsers,
			Duration,
			IsCancel,
			IsOnlinePublish,
			EntryTime,
			IntervalTime,
			ExitTime,
			IsAdvanceToken,
			IsDisplaySeatNos,
			IsPrintTicketAmount,
			IsPrintSlip,
			IsPrintPriceInSlip,
			AdvanceTokenReleaseTime,
			IsRealTime,
			CreationType,
			DistributorMovieId,
			AdvanceTokenBufferTime,
			ManagerQuotaReleaseTime,
			UnpaidBookingReleaseTime,
			LockShowTime,
			MovieMergedTo
		) VALUES (
			@ScreenID,
			@ScreenNo,
			@ScreenName,
			@OnlineMovieID,
			@OnlineMovieName,
			@MovieName,
			@Experiences,
			@MovieLanguageType,
			@MovieCensorRatingType,
			@ShowName,
			@ShowTime,
			@IsPaused,
			@IsOnlinePaused,
			@ResumeBefore,
			@AllowedUsers,
			@Duration,
			@IsCancel,
			@IsOnlinePublish,
			@EntryTime,
			@IntervalTime,
			@ExitTime,
			@IsAdvanceToken,
			@IsDisplaySeatNos,
			@IsPrintTicketAmount,
			@IsPrintSlip,
			@IsPrintPriceInSlip,
			@AdvanceTokenReleaseTime,
			@IsRealTime,
			@CreationType,
			@DistributorMovieId,
			@AdvanceTokenBufferTime,
			@ManagerQuotaReleaseTime,
			@UnpaidBookingReleaseTime,
			@LockShowTime,
			@MovieMergedTo
		) SET @ShowID = SCOPE_IDENTITY()
		
		--2&86&0&86,85#3&87&0&87,86,85#

		CREATE TABLE #ClassLayout ( ClassLayoutID INT, ValueType INT, DCRNo INT, IsPrintSeatLabel BIT, PRIMARY KEY(ClassLayoutID, ValueType) )
		CREATE TABLE #PriceClassLayout (ClassLayoutID INT, PriceCardID INT)

		DECLARE @ClassLayoutID INT
		DECLARE @ValueType INT
		DECLARE @Value NUMERIC(9,2)
		
		DECLARE @ROWID1 AS INT;
			DECLARE @VALUE1 AS VARCHAR(MAX);
			DECLARE @ROWID2 AS INT;
			DECLARE @VALUE2 AS VARCHAR(MAX);
			DECLARE @CMDSTR AS NVARCHAR(MAX)='';
			DECLARE SECONDCURSOR CURSOR -- DECLARE CURSOR
			LOCAL SCROLL STATIC
			FOR
			SELECT *  FROM DBO.SPLIT('#',@ClassPriceDetails);
			OPEN SECONDCURSOR -- OPEN THE CURSOR
			FETCH NEXT FROM SECONDCURSOR
			INTO @ROWID1,@VALUE1
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF (@VALUE1 <>'')
				BEGIN
					DECLARE @classLayout INT
					DECLARE @priceCardID INT
					
					SELECT @classLayout = VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =1					
					SELECT @priceCardID = VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =2
					
					DECLARE @PriceCards NVARCHAR(MAX) 
					SELECT @PriceCards = Value FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =5
					SELECT items INTO #priceIDs FROM dbo.fnsplit(@PriceCards, ',')
					
					IF NOT EXISTS (SELECT * FROM #priceIDs WHERE items = @priceCardID)
					BEGIN
						DROP TABLE #priceIDs
						DROP TABLE #ClassLayout
						DROP TABLE #PriceClassLayout 
						RAISERROR('Set Master Price Card Properly', 11, 1)
					END
					
					INSERT INTO #PriceClassLayout (ClassLayoutID, PriceCardID)
					SELECT @classLayout, items FROM #priceIDs
					
					DROP TABLE #priceIDs
					
					INSERT INTO #ClassLayout (
					ClassLayoutID,
					ValueType, DCRNo, IsPrintSeatLabel
					) VALUES (
					@classLayout, @priceCardID, (SELECT VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID =3), (SELECT VALUE FROM DBO.SPLIT('&',@VALUE1) WHERE ROWID = 4)
					)
				END	
			FETCH NEXT FROM SECONDCURSOR
			INTO @ROWID1,@VALUE1
			END
			CLOSE SECONDCURSOR -- CLOSE THE CURSOR
			DEALLOCATE SECONDCURSOR -- DEALLOCATE THE CURSOR

		INSERT INTO Class (
			ScreenID,
			ShowID,
			ClassLayoutID,
			ClassNo,
			ClassName,
			NoRows,
			NoCols,
			Price,
			ETax,
			ATax,
			MC,
			BlockFee,
			DCRID,
			NoMaxSeatsPerTicket,
			AllowedUsers,
			PriceCardId,
			IsPrintSeatLabel
		)	SELECT
				@ScreenID,
				@ShowID,
				ClassLayout.ClassLayoutID,
				ClassLayout.ClassNo,
				ClassLayout.ClassName,
				ClassLayout.NoRows,
				ClassLayout.NoCols,
				IsNull((SELECT Amount from PriceCard where Id= (SELECT ValueType FROM #ClassLayout WHERE ClassLayoutID=ClassLayout.ClassLayoutID)),0),
				0,
				0,
				0,
				0,
				(SELECT DCRNo FROM #ClassLayout WHERE ClassLayoutID=ClassLayout.ClassLayoutID),
				ClassLayout.NoMaxSeatsPerTicket,
				ClassLayout.AllowedUsers,
				(SELECT ValueType FROM #ClassLayout WHERE ClassLayoutID=ClassLayout.ClassLayoutID),
				(SELECT IsPrintSeatLabel FROM #ClassLayout WHERE ClassLayoutID=ClassLayout.ClassLayoutID)
			FROM ClassLayout
			WHERE ClassLayout.ScreenID = @ScreenID
			AND ClassLayout.ClassLayoutID IN (SELECT DISTINCT ClassLayoutID from SeatLayout where ScreenID = @ScreenID and SeatType <> 1)
		
		DROP TABLE #ClassLayout
		
		INSERT INTO ClassPriceCards (ShowID, ClassID, PriceCardID, ClassLayoutID)
		SELECT ShowID, ClassID, PC.PriceCardID, Class.ClassLayoutID FROM Class 
		INNER JOIN #PriceClassLayout PC ON PC.ClassLayoutID = Class.ClassLayoutID 
		WHERE ShowID = @ShowID 
		
		DROP TABLE #PriceClassLayout

		INSERT INTO Seat (
			ScreenID,
			ShowID,
			ClassID,
			ClassLayoutID,
			SeatLayoutID,
			SeatType,
			SeatLabel,
			RowNo,
			ColNo,
			CoupleSeatIds,
			QuotaType,
			ReleaseBefore,
			PriceCardId,
			SeatClassInfo
		)	SELECT
				@ScreenID,
				@ShowID,
				( SELECT TOP 1 Class.ClassID FROM Class WHERE Class.ShowID = @ShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID ),
				SeatLayout.ClassLayoutID,
				SeatLayout.SeatLayoutID,
				SeatLayout.SeatType,
				SeatLayout.SeatLabel,
				SeatLayout.RowNo,
				SeatLayout.ColNo,
				SeatLayout.CoupleSeatIds,
				SeatLayout.QuotaType,
				SeatLayout.ReleaseBefore,
				( SELECT TOP 1 Class.PriceCardId FROM Class WHERE Class.ShowID = @ShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID ),
				CASE WHEN SeatLayout.SeatLabel <> '' Then ( SELECT TOP 1 Class.ClassName FROM Class WHERE Class.ShowID = @ShowID AND Class.ClassLayoutID = SeatLayout.ClassLayoutID ) + '_' + SeatLayout.SeatLabel ELSE NULL END
			FROM SeatLayout
			WHERE SeatLayout.ScreenID = @ScreenID
			AND SeatLayout.ClassLayoutID IN (SELECT DISTINCT ClassLayoutID from SeatLayout where ScreenID = @ScreenID and SeatType <> 1)

		IF @IsRealTime = 1
			UPDATE Seat SET QuotaType = 0 WHERE QuotaType = 3 AND ShowID = @ShowID

		COMMIT TRANSACTION
		RETURN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
			ROLLBACK 
		DECLARE @errMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR (@errMsg, 11, 1)
		RETURN
	END CATCH
GO

/****** Object:  StoredProcedure [dbo].[spSendOnlineIncrementalSeats]    Script Date: 09/01/2014 10:10:47 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSendOnlineIncrementalSeats]
	@ShowID INT
AS
BEGIN
Begin Try
	DECLARE @SALEPERCENTAGE INT=0;
	DECLARE @SENDSEATS INT=0;
	DECLARE @TOTALSEATS INT=0;
	DECLARE @TOTALSOLDSEATS INT=0;
	DECLARE @SQL NVARCHAR(MAX)='';
	
	SELECT @SALEPERCENTAGE=Incremental FROM SCREEN WHERE SCREENID=(SELECT TOP(1) SCREENID FROM SHOW WHERE SHOWID=@ShowID);
	SELECT @SENDSEATS=OnlineSeat FROM SCREEN WHERE SCREENID=(SELECT TOP(1) SCREENID FROM SHOW WHERE SHOWID=@ShowID);
	SELECT @TOTALSEATS=COUNT(*) FROM SEAT WHERE SHOWID=@ShowID AND QUOTATYPE=3 AND SEATTYPE<>1;
	SELECT @TOTALSOLDSEATS=COUNT(*) FROM SEAT WHERE SHOWID=@ShowID AND QUOTATYPE=3 AND SEATTYPE<>1 AND STATUSTYPE>1;
	
	IF(((100*@TOTALSOLDSEATS)/@TOTALSEATS)>=@SALEPERCENTAGE)
	BEGIN
		
	
		DECLARE @SEATIDS varchar(max);
		DECLARE @LABELS varchar(max);
		set @SEATIDS='';
		set @LABELS='';
		SELECT @SEATIDS = COALESCE(@SEATIDS+',' ,'')+CAST(M.SEATID AS VARCHAR),@LABELS = COALESCE(@LABELS+',' ,'')+CAST(M.SEATLABEL AS VARCHAR) FROM (SELECT TOP(@SENDSEATS) SEATID,SEATLABEL FROM SEAT WHERE STATUSTYPE=0 AND SEATTYPE<>1 AND SHOWID=@ShowID AND QUOTATYPE=0)M;
		
		UPDATE SEAT SET QUOTATYPE=3 WHERE SEATID IN (SELECT VALUE FROM dbo.SPLIT(',',@SEATIDS));
		SELECT @SEATIDS ID,@LABELS LABEL;
		
	END
	ELSE
	BEGIN
		SELECT '' ID,'' LABEL;
	END
end try	
	
BEGIN CATCH
		SELECT '' ID,'' LABEL;
END CATCH
END
GO ******/
/****** Object:  StoredProcedure [dbo].[spSeatSync]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSeatSync]
	@TicketID INT,
	@SeatID INT,
	@StatusType TINYINT,
	@PatronInfo VARCHAR(256),
	@PatronFee NUMERIC(9,2)
	
AS
declare @stat int;
set @stat=0;

if(@StatusType=1)
begin
set @StatusType=-1;
end



declare @isAdvanToken bit;
set @isAdvanToken=0;
select @isAdvanToken=isNull(IsAdvanceToken,0) from Screen where ScreenId=(Select ScreenId from Seat where SeatID = @SeatID)
if(@isAdvanToken>0 and @StatusType=2)
begin
set @StatusType=1;
end

--print @isAdvanToken;

if(@StatusType=2)
begin
select @stat=StatusType from Seat where SeatID = @SeatID and StatusType=2 and QuotaType <>3
end
if(@StatusType=2)
begin
	UPDATE Seat
	SET TicketID = @TicketID,
		StatusType = @StatusType,
		PatronInfo = @PatronInfo,
		PatronFee = @PatronFee,
		PaymentType=1,
		NoSales=NoSales+1,
		NoPrints=NoPrints+1,
		QuotaType=3
	WHERE
		SeatID = @SeatID
		 --AND StatusType<>2
		  and StatusType<>1 and
		StatusType <> @StatusType --and QuotaType=3
end
else if(@StatusType=1 )
begin
	UPDATE Seat
	SET TicketID = @TicketID,
		StatusType = @StatusType,
		PatronInfo = @PatronInfo,
		PatronFee = @PatronFee,
		PaymentType=0,
		NoCancels=NoCancels+1
	WHERE
		SeatID = @SeatID and
		StatusType <> @StatusType --and QuotaType=3
end
else if(@StatusType=0)
begin
	UPDATE Seat
	SET TicketID = @TicketID,
		StatusType = @StatusType,
		PatronInfo = @PatronInfo,
		PatronFee = @PatronFee,
		PaymentType=0,
		NoCancels=NoCancels+1
	WHERE
		SeatID = @SeatID
		 AND PaymentType=1 and
		StatusType <> @StatusType and QuotaType=3
end
select @stat;
GO

/****** Object:  StoredProcedure [dbo].[spSeatLayoutEdit]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSeatLayoutEdit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSeatLayoutEdit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSeatLayoutEdit]
	@IDs VARCHAR(8000),
	@SetType VARCHAR(16),
	@Value VARCHAR(8000)
AS
	CREATE TABLE #Couple (SlNo INT IDENTITY(1,1), CId INT)
	INSERT INTO #Couple(CId) SELECT SeatLayoutID FROM SeatLayout WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@IDs, ',')) AND SeatType = 2

	CREATE TABLE #IDs (ID BIGINT)
	INSERT INTO #IDs SELECT SeatLayoutID FROM SeatLayout WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@IDs, ',')) AND SeatType != 2

	DECLARE @i INT
	SET @i = 1
	DECLARE @maxi INT
	SET @maxi = (SELECT COUNT(*) FROM #couple)
	WHILE (@maxi >= @i)
	BEGIN
		DECLARE @CoupleSeatIds NVARCHAR(50)
		SET @CoupleSeatIds = NULL
		SELECT @CoupleSeatIds = CoupleSeatIds FROM SeatLayout WHERE SeatLayoutID IN (SELECT CId FROM #Couple WHERE #Couple.SlNo = @i)
		INSERT INTO #IDs
		SELECT items FROM dbo.fnsplit(@CoupleSeatIds, ',')
		SET @i = @i + 1
	END
	DROP TABLE #Couple	
				
	IF @SetType = 'SeatType'
	BEGIN
		IF @Value = '2'
		BEGIN			
			CREATE TABLE #SeatLayout( RecNo INT, SeatLayoutID INT, RowNo INT, ColNo INT)
			INSERT INTO #SeatLayout SELECT ROW_NUMBER() OVER (ORDER BY ColNo) As RecNo, SeatLayoutID, RowNo, ColNo FROM SeatLayout 
			WHERE SeatLayoutID IN (select * from dbo.fnsplit(@IDs, ',')) AND SeatType != 2
			
			IF((SELECT ColNo FROM #SeatLayout WHERE RecNo = 1) = (SELECT ColNo-1 FROM #SeatLayout WHERE RecNo = 2) AND (SELECT RowNo FROM #SeatLayout WHERE RecNo = 1) = (SELECT RowNo FROM #SeatLayout WHERE RecNo = 2) AND (SELECT COUNT(*) FROM #SeatLayout) = 2)
			BEGIN
				UPDATE SeatLayout SET SeatType = @Value , CoupleSeatIds = @IDs WHERE SeatLayoutID IN (select * from dbo.fnsplit(@IDs, ',')) -- AND SeatType != 2;
				DROP TABLE #SeatLayout
			END
			ELSE
			BEGIN
				DROP TABLE #SeatLayout
				RAISERROR (N'Connot update seat type!. Select seats properly.', 16, 1);
				RETURN;
           END				
		END
		ELSE
		BEGIN
						
			UPDATE SeatLayout SET SeatType = @Value WHERE SeatLayoutID IN (SELECT ID FROM #IDs)
			IF @Value = '1'
			BEGIN
				UPDATE SeatLayout SET SeatLabel='' Where SeatType=1
			END		
		END
	END
	ELSE IF @SetType = 'QuotaType'
	BEGIN
		UPDATE SeatLayout SET QuotaType = @Value WHERE SeatLayoutID IN (SELECT ID FROM #IDs)
	END
	ELSE IF @SetType = 'SeatLabel'
	BEGIN
		DECLARE @Pos INT
		DECLARE @TmpIDs VARCHAR(8000)
		DECLARE @TmpValue VARCHAR(8000)
		DECLARE @SeatLayoutID INT
		DECLARE @SeatLabel VARCHAR(10)
		SET @TmpIDs = @IDs
		SET @TmpValue = @Value
		SET @SeatLayoutID = 0
		SET @SeatLabel = ''
		WHILE @TmpIDs <> ''
		BEGIN
			SET @Pos = CHARINDEX(',', @TmpIDs)
			IF @Pos > 0
				SELECT @SeatLayoutID = SUBSTRING(@TmpIDs, 1, @Pos - 1), @TmpIDs = SUBSTRING(@TmpIDs, @Pos + 1, LEN(@TmpIDs))
			ELSE
				SELECT @SeatLayoutID = @TmpIDs, @TmpIDs = ''
			SET @Pos = CHARINDEX(',', @TmpValue)
			IF @Pos > 0
				SELECT @SeatLabel = SUBSTRING(@TmpValue, 1, @Pos - 1), @TmpValue = SUBSTRING(@TmpValue, @Pos + 1, LEN(@TmpValue))
			ELSE
				SELECT @SeatLabel = @TmpValue, @TmpValue = ''
			if (SELECT COUNT(IsNull(SeatLayoutID,0)) FROM SeatLayout WHERE SeatLabel=@SeatLabel AND SeatLabel<>'' AND SeatType<>1 AND ClassLayoutID = (SELECT TOP 1 ClassLayoutID FROM SeatLayout WHERE SeatLayoutID =@SeatLayoutID)) =0 
			UPDATE SeatLayout
			SET SeatLabel = @SeatLabel
			WHERE SeatLayoutID = @SeatLayoutID
		END
	END
	ELSE IF @SetType = 'ReleaseBefore'
	BEGIN
		UPDATE SeatLayout SET ReleaseBefore = @Value WHERE SeatLayoutID IN (SELECT ID FROM #IDs)
	END	
	DROP TABLE #IDs
GO

/* [spScreenManage] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spScreenManage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spScreenManage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spScreenManage]
	@TYPE VARCHAR(8)='',
	@ScreenID INT,
	@ScreenNo VARCHAR(2),
	@Code VARCHAR(2),
	@ScreenName NVARCHAR(256),
	@IsFoodBeverages BIT,
	@IsAdvanceToken BIT,
	@IsDisplaySeatNos BIT,	
	@IsPrintTicketAmount BIT,
	@IsPrintSlip BIT,
	@IsPrintPriceInSlip BIT,
	@IsRealTime BIT,
	@ComplexID INT=0,
	@ScreenGUID VARCHAR(64),
	@AdvanceTokenReleaseTime INT,
	@AdvanceTokenBufferTime INT,
	@ManagerQuotaReleaseTime INT,
	@UnpaidBookingReleaseTime INT,
	@PrintSlipSize INT,
	@Experiences NVARCHAR(MAX),
	@TheatreType VARCHAR(100),
	@CoolingType VARCHAR(100),
	@TownType VARCHAR(100),
	@NumberOfShowsAllowed INT,
	@ScreenType TinyInt
AS
BEGIN
	IF(@TYPE='ADD')
	BEGIN
		IF EXISTS ( SELECT ScreenNo FROM Screen  WHERE ComplexID=@ComplexID and (ScreenGUID=@ScreenGUID OR ScreenName=@ScreenName) )
		BEGIN
			RAISERROR('Screen already exists!', 11, 1)
			RETURN
		END
		INSERT INTO Screen (
		ScreenNo,
		Code,
		ScreenName,
		IsFoodBeverages,
		IsAdvanceToken,
		IsDisplaySeatNos,
		IsPrintTicketAmount,
		IsPrintSlip,
		IsPrintPriceInSlip,
		ComplexID,
		ScreenGUID,
		AdvanceTokenReleaseTime,
		IsRealTime,
		AdvanceTokenBufferTime,
		ManagerQuotaReleaseTime,
		UnpaidBookingReleaseTime,
		PrintSlipSize, 
		Experiences,
		CoolingType,
		NumberOfShowsAllowed,
		ScreenType
		) VALUES (
		@ScreenNo,
		@Code,
		@ScreenName,
		@IsFoodBeverages,
		@IsAdvanceToken,
		@IsDisplaySeatNos,
		@IsPrintTicketAmount,
		@IsPrintSlip,
		@IsPrintPriceInSlip,
		@ComplexID,
		@ScreenGUID,
		@AdvanceTokenReleaseTime,
		@IsRealTime,
		@AdvanceTokenBufferTime,
		@ManagerQuotaReleaseTime,
		@UnpaidBookingReleaseTime,
		@PrintSlipSize,
		@Experiences,
		@CoolingType,
		@NumberOfShowsAllowed,
		@ScreenType
		) SET @ScreenID = SCOPE_IDENTITY()
		UPDATE PriceCard SET IsDeleted=0 where TheatreType =@TheatreType AND CoolingType = @CoolingType AND TownType = @TownType AND ScreenType=@ScreenType
	END
	ELSE IF(@TYPE='EDIT')
	BEGIN
		IF EXISTS ( SELECT ScreenNo FROM Screen  WHERE ScreenID <>@ScreenID and ComplexID=@ComplexID and (ScreenGUID=@ScreenGUID OR ScreenName=@ScreenName) )
		BEGIN
			RAISERROR('Screen already exists!', 11, 1)
			RETURN
		END
		DECLARE @OldCoolingType varchar(100)
		SELECT @OldCoolingType=CoolingType,@ScreenType=ScreenType FROM Screen WHERE ScreenID = @ScreenID

		UPDATE Screen
		SET 
			Code=@Code,
			IsFoodBeverages=@IsFoodBeverages,
			IsAdvanceToken=@IsAdvanceToken,
			IsDisplaySeatNos=@IsDisplaySeatNos,
			IsPrintTicketAmount = @IsPrintTicketAmount,
			IsPrintSlip = @IsPrintSlip,
			IsPrintPriceInSlip = @IsPrintPriceInSlip,
			AdvanceTokenReleaseTime=@AdvanceTokenReleaseTime,
			IsRealTime=@IsRealTime,
			AdvanceTokenBufferTime = @AdvanceTokenBufferTime,
			ManagerQuotaReleaseTime = @ManagerQuotaReleaseTime,
			UnpaidBookingReleaseTime = @UnpaidBookingReleaseTime,
			PrintSlipSize = @PrintSlipSize,
			Experiences = @Experiences,
			NumberOfShowsAllowed = @NumberOfShowsAllowed
		WHERE 
		ScreenID =@ScreenID 	

		IF NOT EXISTS ( SELECT NULL FROM Screen WHERE CoolingType=@CoolingType AND ScreenType=@ScreenType )
		BEGIN
			UPDATE PriceCard SET IsDeleted=1 where TheatreType=@TheatreType AND CoolingType=@OldCoolingType AND TownType=@TownType AND ScreenType=@ScreenType 
		END
		UPDATE PriceCard SET IsDeleted=0 where TheatreType =@TheatreType AND CoolingType = @CoolingType AND TownType = @TownType AND ScreenType=@ScreenType 
	END
END
GO

/* [spScreenLoad] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spScreenLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spScreenLoad]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spScreenLoad]
	@ScreenID INT
AS
	SELECT
		ScreenID,
		ScreenNo,
		ScreenName,
		IsNull(IsFoodBeverages,0),
		IsNull(IsAdvanceToken,0),
		IsNull(IsDisplaySeatNos,0),
		IsNull(Code,0),
		IsPrintTicketAmount,
		IsPrintPriceInSlip,
		ComplexID,
		ScreenGUID,
		AdvanceTokenReleaseTime,
		IsRealTime,
		AdvanceTokenBufferTime,
		ManagerQuotaReleaseTime,
		IsNull(PrintSlipSize,0),
		IsPrintSlip,
		UnpaidBookingReleaseTime,
		Experiences,
		CoolingType,
		NumberOfShowsAllowed,
		ScreenType,
		typ.Expression as ScreenTypeName
	FROM Screen scr, (select * from [Type] where TypeNo=31) typ
	WHERE ScreenID = @ScreenID and scr.ScreenType = typ.Value
GO

/****** Object:  StoredProcedure [dbo].[spScreenDelete]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spScreenDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spScreenDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spScreenDelete]
	@ScreenID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
	DECLARE @TheatreType varchar(100)
	DECLARE @CoolingType varchar(100)
	DECLARE @TownType varchar(100)
	DECLARE @ScreenType TinyInt


	SET @ReferredBy = ''
	IF EXISTS ( SELECT NULL FROM ClassLayout WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'ClassLayout'
	ELSE IF EXISTS ( SELECT NULL FROM SeatLayout WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'SeatLayout'
	ELSE IF EXISTS ( SELECT NULL FROM Show WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'Show'
	ELSE IF EXISTS ( SELECT NULL FROM ShowMIS WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'ShowMIS'
	ELSE IF EXISTS ( SELECT NULL FROM Class WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'Class'
	ELSE IF EXISTS ( SELECT NULL FROM ClassMIS WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'ClassMIS'
	ELSE IF EXISTS ( SELECT NULL FROM Seat WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'Seat'
	ELSE IF EXISTS ( SELECT NULL FROM SeatMIS WHERE ScreenID = @ScreenID )
		SET @ReferredBy = 'SeatMIS'
	
	If @ReferredBy = ''
	BEGIN
		DELETE FROM Log
		WHERE TableType = ( SELECT TOP 1 Value FROM Type WHERE TypeNo = 1 AND Expression = 'Screen' )
		AND ObjectID = @ScreenID
	
		SELECT @TheatreType=TheatreType,@TownType=TownType FROM Complex WHERE ComplexID in (select complexid from screen WHERE ScreenID = @ScreenID)
		SELECT @CoolingType=CoolingType, @ScreenType=ScreenType FROM Screen WHERE ScreenID = @ScreenID

		DELETE FROM Screen
		WHERE ScreenID = @ScreenID
		
		IF NOT EXISTS ( SELECT NULL FROM Screen WHERE CoolingType=@CoolingType AND ScreenType=@ScreenType )
		BEGIN
			UPDATE PriceCard SET IsDeleted=1 where TheatreType=@TheatreType AND CoolingType=@CoolingType AND TownType=@TownType AND ScreenType=@ScreenType
		END
	END
GO

/****** Object:  StoredProcedure [dbo].[spParkingTypes]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spParkingTypes]
(
@ParkingType as Varchar(50)
)
as 
begin 
select distinct ParkingTypeID,ParkingType from ParkingType where ParkingType like '%'+@ParkingType+'%'
end
GO

/****** Object:  StoredProcedure [dbo].[spParkingTypeLoad]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spParkingTypeLoad]
	@ParkingTypeID INT
AS
	SELECT
		ParkingTypeID,
		ParkingType,
		Price
	FROM ParkingType
	WHERE ParkingTypeID = @ParkingTypeID
GO

/****** Object:  StoredProcedure [dbo].[spParkingTypeEdit]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spParkingTypeEdit]
	@ParkingTypeID INT,
	@ParkingType VARCHAR(16),
	@Price NUMERIC(9,2)
AS
	UPDATE ParkingType
	SET ParkingType = @ParkingType,
		Price = @Price
	WHERE ParkingTypeID = @ParkingTypeID
GO

/****** Object:  StoredProcedure [dbo].[spParkingTypeDelete]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spParkingTypeDelete]
	@ParkingTypeID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
	SET @ReferredBy = ''
	IF EXISTS ( SELECT NULL FROM Parking WHERE ParkingTypeID = @ParkingTypeID )
		SET @ReferredBy = 'Parking'
	
	If @ReferredBy = ''
	BEGIN
		DELETE FROM Log
		WHERE TableType = ( SELECT TOP 1 Value FROM Type WHERE TypeNo = 1 AND Expression = 'ParkingType' )
		AND ObjectID = @ParkingTypeID
	
		DELETE FROM ParkingType
		WHERE ParkingTypeID = @ParkingTypeID
	END
GO

/****** Object:  StoredProcedure [dbo].[spParkingTypeAdd]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spParkingTypeAdd]
	@ParkingTypeID INT OUTPUT,
	@ParkingType VARCHAR(16),
	@Price NUMERIC(9,2)
AS
begin
	INSERT INTO ParkingType (
		ParkingType,
		Price
	) VALUES (
		@ParkingType,
		@Price
	); SET @ParkingTypeID = SCOPE_IDENTITY();
end
GO

/****** Object:  StoredProcedure [dbo].[spParkingAdd]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spParkingAdd]
	@ParkingTypeID INT,
	@FromDate DateTime,
	@ToDate DateTime,
	@Price NUMERIC(9,2),
	@CreatedBy Int
AS
Begin
	INSERT INTO Parking (
		ParkingTypeID,
		FromTime,
		ToTime,
		ParkingAmount,
		CreatedBy
	) VALUES (
		@ParkingTypeID,
		@FromDate,
		@ToDate,
		@Price,
		@CreatedBy
	); 
End
GO

/****** Object:  StoredProcedure [dbo].[spLogAdd]    Script Date: 09/01/2014 10:10:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spLogAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spLogAdd]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spLogAdd]
	@TableType TINYINT,
	@ObjectID INT,
	@ObjectName VARCHAR(16),
	@TransactionType TINYINT,
	@TransactionLogType TINYINT,
	@TransactionDetail VARCHAR(2048),
	@TransactionTime DATETIME,
	@TransactionByIP VARCHAR(48),
	@TransactionByID INT,
	@TransactionByName VARCHAR(16),
	@Action VARCHAR(100)
AS
	INSERT INTO Log (
		TableType,
		ObjectID,
		ObjectName,
		TransactionType,
		TransactionLogType,
		TransactionDetail,
		TransactionTime,
		TransactionByIP,
		TransactionByID,
		TransactionByName,
		[Action]
	) VALUES (
		@TableType,
		@ObjectID,
		@ObjectName,
		@TransactionType,
		@TransactionLogType,
		@TransactionDetail,
		@TransactionTime,
		@TransactionByIP,
		@TransactionByID,
		@TransactionByName,
		@Action
	)
GO

/* [spSeatEditPrint] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSeatEditPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSeatEditPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSeatEditPrint]  
@TicketID INT OUTPUT,
@DCRNo INT OUTPUT,
@DCRMax INT OUTPUT,
@SeatIDs VARCHAR(256),
@IsRePrint BIT,  
@PaymentType TINYINT,
@PaymentReceived NUMERIC(9,2),
@LastPrintedByID INT,
@CurrentStatusType TINYINT,
@priceCardID INT,
@mobileNumber NVARCHAR(10)
AS
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	DECLARE @LastSoldOn DATETIME = GETDATE()
	DECLARE @LastPrintedOn DATETIME = @LastSoldOn

	CREATE TABLE #Couple (SlNo INT IDENTITY(1,1), CId INT, ShowId INT)
	INSERT INTO #Couple(CId, ShowId) SELECT SeatID, ShowId FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@SeatIDs, ',')) AND SeatType = 2

	CREATE TABLE #IDs (ID BIGINT)
	INSERT INTO #IDs SELECT SeatID FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@SeatIDs, ',')) AND SeatType != 2

	DECLARE @errorMessage VARCHAR(MAX)
	DECLARE @i INT
	SET @i = 1
	DECLARE @maxi INT
	SET @maxi = (SELECT COUNT(*) FROM #couple)
	WHILE (@maxi >= @i)
	BEGIN
		DECLARE @CoupleSeatIds NVARCHAR(50)
		SET @CoupleSeatIds = NULL		
		SELECT @CoupleSeatIds = CoupleSeatIds FROM Seat WHERE SeatID IN (SELECT CId FROM #Couple WHERE #Couple.SlNo = @i)
		
		INSERT INTO #IDs
		SELECT SeatId FROM Seat WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@CoupleSeatIds, ',')) AND ShowID IN (SELECT ShowId FROM #Couple WHERE #Couple.SlNo = @i)
		SET @i = @i + 1
	END
	DROP TABLE #Couple

	BEGIN TRANSACTION  
		--DECLARE @SQL NVARCHAR(4000)  
		DECLARE @TmpTicketID INT  
		DECLARE @TmpDCRID INT  
		DECLARE @TmpNoSeats INT  
		DECLARE @TmpNoSeats2 INT  
		DECLARE @TmpMinStatusType TINYINT  
		DECLARE @TmpMaxStatusType TINYINT  

		SELECT @DCRNo = 0, @DCRMax = 0, @TmpTicketID = 0, @TmpDCRID = 0, @TmpNoSeats = 0  
		
		IF ((SELECT IsLocked FROM Show WHERE ShowID IN (SELECT ShowID FROM Seat WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs))) = 1)
		BEGIN
			SET @errorMessage = 'Failed. Show is locked. SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END

		IF EXISTS(SELECT SeatID FROM ChangeQuotaDetails WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs) AND [Status] = 0)
		BEGIN
			SET @errorMessage = 'Failed. Change Quota is happened. SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END
		
		IF EXISTS(SELECT SeatID FROM Seat WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs) AND StatusType <> @CurrentStatusType)
		BEGIN
			SET @errorMessage = 'Failed. Certain Ticket(s) is/are already Booked. SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END
			
		--SET @SQL = N'SELECT @TmpTicketID = MIN(Seat.SeatID), @TmpDCRID = MIN(Class.DCRID), @TmpMinStatusType = MIN(Seat.StatusType), @TmpMaxStatusType = MAX(Seat.StatusType), @TmpNoSeats = COUNT(Seat.SeatID) FROM Seat INNER JOIN Class ON Seat.ClassID = Class.ClassID WHERE Seat.SeatID IN (SELECT DISTINCT Id FROM #IDs) '  
		--EXEC SP_EXECUTESQL @Statement = @SQL, @params = N'@TmpTicketID INT OUTPUT, @TmpDCRID INT OUTPUT, @TmpMinStatusType INT OUTPUT, @TmpMaxStatusType INT OUTPUT, @TmpNoSeats INT OUTPUT', @TmpTicketID = @TmpTicketID OUTPUT, @TmpDCRID = @TmpDCRID OUTPUT, @TmpMinStatusType = @TmpMaxStatusType OUTPUT, @TmpMaxStatusType = @TmpMaxStatusType OUTPUT, @TmpNoSeats = @TmpNoSeats OUTPUT  
		SELECT @TmpTicketID = MIN(Seat.SeatID), @TmpDCRID = MIN(Class.DCRID), @TmpMinStatusType = MIN(Seat.StatusType), @TmpMaxStatusType = MAX(Seat.StatusType), 
			@TmpNoSeats = COUNT(Seat.SeatID) FROM Seat INNER JOIN Class ON Seat.ClassID = Class.ClassID WHERE Seat.SeatID IN (SELECT DISTINCT Id FROM #IDs)

		IF @@ERROR <> 0 OR @@ROWCOUNT = 0 OR @TmpTicketID = 0 OR @TmpMinStatusType <> @TmpMaxStatusType
		BEGIN
			SET @errorMessage = 'Failed. Mismatching Status. ErrorCode:' + CAST(@@ERROR AS VARCHAR(100)) + ' SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END
		
		IF (SELECT COUNT(DISTINCT TicketID) FROM Seat WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs) AND StatusType = 6) > 1
		BEGIN
			SET @errorMessage = 'Failed. Different Unpaid Bookings Seats are selected. SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END
		
		IF EXISTS(SELECT SeatID FROM Seat WHERE SeatId NOT IN (SELECT DISTINCT Id FROM #IDs) AND StatusType = 6 AND TicketID = (SELECT DISTINCT TicketID FROM Seat WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs)))
		BEGIN
			SET @errorMessage = 'Failed. Partial Booking is not allowed for Unpaid Booking Seat(s). SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END
		
		IF EXISTS(SELECT SeatId FROM BlockHistory WHERE SeatId IN (SELECT SeatID FROM Seat WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs) AND StatusType = 6))
		BEGIN
			SET @errorMessage = 'Failed. Unpaid Booking Seat(s) are blocked for Online payment. SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END

		IF @IsRePrint = 0  
		BEGIN  
			--SET @SQL = N'SELECT @TmpNoSeats2 = COUNT(SeatID) FROM Seat WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs) AND StatusType = (CASE WHEN (QuotaType = 3 AND LastPrintedByID = 0  AND StatusType <> 1) THEN 2 ELSE (CASE WHEN (QuotaType = 3 AND LastPrintedByID = 0  AND StatusType = 1) THEN 1 ELSE (CASE WHEN (QuotaType <> 3  AND StatusType = 1) THEN 1 ELSE (CASE WHEN (QuotaType <> 3  AND StatusType = 6) THEN 6 ELSE 0 END) END) END) END)'
			--EXEC SP_EXECUTESQL @Statement = @SQL, @params = N'@TmpNoSeats2 INT OUTPUT', @TmpNoSeats2 = @TmpNoSeats2 OUTPUT  
			SELECT @TmpNoSeats2 = COUNT(SeatID) FROM Seat WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs) AND 
				StatusType = (CASE WHEN (QuotaType = 3 AND LastPrintedByID = 0  AND StatusType <> 1) THEN 2 ELSE 
					(CASE WHEN (QuotaType = 3 AND LastPrintedByID = 0  AND StatusType = 1) THEN 1 ELSE (CASE WHEN (QuotaType <> 3  AND StatusType = 1) THEN 1 
					ELSE (CASE WHEN (QuotaType <> 3  AND StatusType = 6) THEN 6 ELSE 0 END) END) END) END)
			IF @@ERROR <> 0 OR @@ROWCOUNT = 0 OR @TmpNoSeats2 <> @TmpNoSeats
			BEGIN
				SET @errorMessage = 'Failed. Certain Ticket(s) is/are already Booked. ErrorCode:' + CAST(@@ERROR AS VARCHAR(100)) + ' SeatId(s):' + @SeatIDs
				GOTO ERR_HANDLER
			END 
		END  

		IF @TmpDCRID > 0
		BEGIN
			IF @IsRePrint = 0
				UPDATE DCR SET DCRNo = CASE WHEN ((DCRNo + @TmpNoSeats) % DCRMax) = 0 THEN DCRMax ELSE (DCRNo + @TmpNoSeats) % DCRMax END, @DCRNo = DCRNo, @DCRMax = DCRMax WHERE DCRID = @TmpDCRID
			ELSE
				SELECT @DCRNo = (DCRNo - @TmpNoSeats), @DCRMax = DCRMax FROM DCR WHERE DCRID = @TmpDCRID
		END

		CREATE TABLE #ticketIDDetails(TicketID INT)

		INSERT INTO #ticketIDDetails(TicketID)
		SELECT DISTINCT TicketID FROM Seat WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs)

		IF (SELECT COUNT(TicketID) FROM #ticketIDDetails) > 1
			BEGIN
				SET @errorMessage = 'Failed! Selected seats are from different transation. SeatId(s):' + @SeatIDs
				GOTO ERR_HANDLER
			END

		IF  @IsReprint = 1 AND ((SELECT COUNT(SeatID) FROM Seat WHERE TicketID IN (SELECT TicketID FROM #ticketIDDetails)) <> (SELECT COUNT(SeatID) FROM Seat WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs))) 
			BEGIN
				SET @errorMessage = 'Failed! Partial print is not allowed for a transaction. SeatId(s):' + @SeatIDs
				GOTO ERR_HANDLER
			END
					
		DECLARE @patronInfo VARCHAR(256)
		DECLARE @quotaType INT
		DECLARE @oldMobileNumber VARCHAR(10)
		DECLARE @onlineQuotaType INT = 3

		SELECT TOP 1 @quotaType = QuotaType, @patronInfo = PatronInfo FROM Seat WHERE SeatID IN (SELECT Id FROM #IDs)

		IF (@mobileNumber <> '' AND @quotaType <> @onlineQuotaType)
		BEGIN
			IF (@patronInfo IS NULL OR @patronInfo = '')
				BEGIN
					IF @IsReprint = 0 --Do not allow to update mobile number on reprint if booking was made without mobile number
						SET @patronInfo = '||' + @mobileNumber + '|||'
				END
			ELSE 
				BEGIN
					SELECT @oldMobileNumber = items FROM dbo.FnSplitPatronInfo(@patronInfo, '|') WHERE ID = 3 --the third item in patronInfo is a user mobile number
					IF (@oldMobileNumber <> @mobileNumber)
						SET @patronInfo = REPLACE(@patronInfo, @oldMobileNumber, @mobileNumber)
				END
		END

		DECLARE @shouldNotify BIT
		IF ((@patronInfo IS NULL OR @patronInfo = '') OR (@IsReprint = 1 AND @oldMobileNumber = @mobileNumber))
			SET @shouldNotify = 0
		ELSE
			SET @shouldNotify = (SELECT TOP 1 IsNotifyOnCB FROM Complex)

		IF @IsRePrint = 0
		BEGIN

			DECLARE @I1 INT
			DECLARE @X INT
			SELECT @I1 = @DCRNo, @X = @DCRMax 
			DECLARE @unpaidBookingStatusType INT = 6

			IF (@CurrentStatusType = 0 OR @CurrentStatusType = 1 OR @CurrentStatusType = @unpaidBookingStatusType)
			BEGIN
				IF @priceCardID = 0
				BEGIN
					SET @errorMessage = 'Failed. Choose proper Price Card'
					GOTO ERR_HANDLER
				END 

				DECLARE @isRealTime BIT
				DECLARE @isAdvanceToken BIT
		
				SELECT TOP 1 @isRealTime = IsRealTime, @isAdvanceToken = IsAdvanceToken FROM Show WHERE ShowId IN (SELECT ShowId FROM Seat WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs))
			
				DECLARE @transactionID VARCHAR(10)
			
				SELECT S.SeatID, S.PriceCardID, PC.ItemID, PC.ItemPriceID, PC.Quantity, PC.DiscountPerItem, S.ShowID, SC.ComplexID INTO #tempSeat FROM Seat S, PriceCardItemDetails PC, Screen SC WHERE S.SeatID IN (SELECT Id FROM #IDs) AND PC.PriceCardID = @priceCardID AND S.ScreenID = SC.ScreenID
			
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
					SELECT @transactionID, ItemID, ItemPriceID, Quantity, 3, @PaymentType, 0, ComplexID, @LastPrintedByID, @LastPrintedOn, DiscountPerItem, SeatID, 1 FROM
					#tempSeat
				
					SELECT I.ItemID, SUM(t.Quantity) AS Quantity INTO #ItemQuantity FROM #tempSeat t, Items I WHERE I.ItemID = t.ItemID GROUP BY I.ItemID
				
					UPDATE I SET I.BlockedStock = I.BlockedStock + IQ.Quantity FROM Items I, #ItemQuantity IQ WHERE I.ItemID = IQ.ItemID
					DROP TABLE #ItemQuantity
				END

				DROP TABLE #tempSeat

				IF (@CurrentStatusType = 1 OR @CurrentStatusType = @unpaidBookingStatusType)
				BEGIN
					DECLARE @NewTicketID INT
					SELECT @NewTicketID = MIN(SeatID) FROM Seat WHERE SeatID NOT IN (SELECT DISTINCT Id FROM #IDs) AND TicketID = @TmpTicketID
					UPDATE Seat SET TicketID = @NewTicketID WHERE SeatID NOT IN (SELECT DISTINCT Id FROM #IDs) AND TicketID = @TmpTicketID
				END
						
				IF (@isAdvanceToken = 1 AND @isRealTime = 0 AND @quotaType = @onlineQuotaType)
					INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, BEBookingCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID, IsReconciled, TicketID, ShouldNotify) SELECT ShowId, SeatId, SeatClassInfo, '', SUBSTRING(PatronInfo, 1, 8), PatronInfo, @LastPrintedByID, @LastPrintedOn, @PaymentType, @priceCardID, @transactionID, 1, @TmpTicketID, @shouldNotify FROM Seat WHERE SeatID IN (SELECT Id FROM #IDs)
				ELSE IF (@isAdvanceToken = 1 AND @isRealTime = 1 AND @quotaType = @onlineQuotaType)
					INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, BOBookingCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID, IsReconciled, TicketID, ShouldNotify) SELECT ShowId, SeatId, SeatClassInfo, '', SUBSTRING(PatronInfo, 1, 8), PatronInfo, @LastPrintedByID, @LastPrintedOn, @PaymentType, @priceCardID, @transactionID, 1, @TmpTicketID, @shouldNotify  FROM Seat WHERE SeatID IN (SELECT Id FROM #IDs)
				ELSE IF (@CurrentStatusType = @unpaidBookingStatusType)
					INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, BOBookingCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID, IsReconciled, TicketID, ShouldNotify) SELECT ShowId, SeatId, SeatClassInfo, '', SUBSTRING(PatronInfo, 1, 8), @patronInfo, @LastPrintedByID, @LastPrintedOn, @PaymentType, @priceCardID, @transactionID, 1, @TmpTicketID, @shouldNotify  FROM Seat WHERE SeatID IN (SELECT Id FROM #IDs)
				ELSE
					INSERT INTO BookHistory(ShowId, SeatId, SeatClassInfo, BlockCode, PatronInfo, BookedByID, BookedOn, PaymentType, PriceCardId, ItemTransactionID, IsReconciled, TicketID, ShouldNotify) SELECT ShowId, SeatId, SeatClassInfo, SUBSTRING(PatronInfo, 1, 6), @patronInfo, @LastPrintedByID, @LastPrintedOn, @PaymentType, @priceCardID, @transactionID, 1, @TmpTicketID, @shouldNotify FROM Seat WHERE SeatID IN (SELECT Id FROM #IDs)
			
				UPDATE Seat SET 
					TicketID = @TmpTicketID,  
					StatusType = 2,
					PaymentType = @PaymentType, 
					PaymentReceived = @PaymentReceived,
					@I1 = DCRNo = CASE WHEN @X = 0 OR ((@I1 + 1) % @X) = 0 THEN @X ELSE (@I1 + 1) % @X END,
					NoSales = NoSales + 1,
					NoPrints = NoPrints + 1,
					LastSoldByID = CASE WHEN LastSoldOn <> NULL THEN LastSoldByID ELSE @LastPrintedByID END,
					LastPrintedByID = @LastPrintedByID, 
					LastSoldOn = CASE WHEN LastSoldOn <> NULL THEN LastSoldOn ELSE @LastSoldOn END,
					LastPrintedOn = @LastPrintedOn,
					PriceCardId = @priceCardID,
					PatronInfo = @patronInfo
				WHERE SeatID IN (SELECT SeatId FROM BookHistory WHERE SeatId IN (SELECT DISTINCT Id FROM #IDs) AND BookedOn = @LastPrintedOn)
			
			END
			ELSE
			BEGIN			
				UPDATE Seat SET 
					TicketID = @TmpTicketID,  
					StatusType = 2,
					PaymentType = @PaymentType, 
					PaymentReceived = @PaymentReceived,
					@I1 = DCRNo = CASE WHEN @X = 0 OR ((@I1 + 1) % @X) = 0 THEN @X ELSE (@I1 + 1) % @X END,
					NoSales = NoSales + 1,
					NoPrints = NoPrints + 1,
					LastSoldByID = CASE WHEN LastSoldOn <> NULL THEN LastSoldByID ELSE @LastPrintedByID END,
					LastPrintedByID = @LastPrintedByID, 
					LastSoldOn = CASE WHEN LastSoldOn <> NULL THEN LastSoldOn ELSE @LastSoldOn END,
					LastPrintedOn = @LastPrintedOn,
					PriceCardId = @priceCardID,
					PatronInfo = @patronInfo
				WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs)
			END
		END  
		ELSE  
		BEGIN
			SELECT @TmpTicketID = TicketID FROM #ticketIDDetails

			UPDATE Seat SET
				NoPrints = NoPrints + 1,
				LastPrintedByID = @LastPrintedByID,
				LastPrintedOn = @LastPrintedOn,
				PatronInfo = @patronInfo
				WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs)

			INSERT INTO ReprintHistory(ShowId, SeatId, SeatClassInfo, PrintedById, PrintedOn, PriceCardId, BookedOn, BookedPaymentType, PatronInfo, TicketID, ShouldNotify) 
			SELECT ShowId, SeatId, SeatClassInfo, @LastPrintedByID, @LastPrintedOn, PriceCardId, LastSoldOn, PaymentType, PatronInfo, TicketID, @shouldNotify FROM Seat 
			WHERE SeatID IN (SELECT DISTINCT Id FROM #IDs)
		END


		IF @@ERROR <> 0 OR @TmpTicketID = 0
		BEGIN
			SET @errorMessage = 'Failed. ErrorCode:' + CAST(@@ERROR AS VARCHAR(100))+ ' SeatId(s):' + @SeatIDs
			GOTO ERR_HANDLER
		END 
		  
		-- below query is updating lastsoldon with latest printed person using for online synced seats  
		UPDATE Seat SET
			LastSoldByID = LastPrintedByID,
		    NoSales = NoSales + 1,
		    LastSoldOn = LastPrintedOn
		    WHERE (LastSoldOn=0 or LastSoldOn is null) and StatusType=2 AND SeatID IN (SELECT DISTINCT Id FROM #IDs) 
 
		SET @TicketID = @TmpTicketID  
		DROP TABLE #IDs 
		DROP TABLE #ticketIDDetails  
	COMMIT TRANSACTION  
	RETURN  
	ERR_HANDLER:
	ROLLBACK TRANSACTION
	DECLARE @errMsg NVARCHAR(MAX) = ERROR_MESSAGE()
	IF @errMsg IS NOT NULL
		SET @errorMessage = @errorMessage + @errMsg
	RAISERROR(@errorMessage, 11, 1)
	RETURN
GO

/****** Object:  StoredProcedure [dbo].[spSeatEditOccupy]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spSeatEditOccupy 220,0
CREATE PROCEDURE [dbo].[spSeatEditOccupy]
	@SeatID INT,
	@LastOccupiedByID INT
AS
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRANSACTION
	
				
declare @tmp varchar(250)
SET @tmp = ''
select @tmp = @tmp + st.SeatLabel + ', ' from Seat st where ( SeatID = @SeatID OR TicketID = @SeatID )

	
		DECLARE @SQL NVARCHAR(4000)
if exists( select * from Seat WHERE ( (SeatID = @SeatID OR TicketID = @SeatID) AND StatusType = 2 ) )
begin
 if exists( select * from Seat WHERE ( (SeatID = @SeatID OR TicketID = @SeatID) AND StatusType = 2 ) and ShowID in (select ShowID from Show where ShowTime between DATEADD(HH,-1,GETDATE()) and DATEADD(HH,1,GETDATE())))
 begin
	UPDATE Seat SET
			StatusType = 3,
			LastOccupiedByID = @LastOccupiedByID
			WHERE ( SeatID = @SeatID OR TicketID = @SeatID )
			AND StatusType = 2

			select Cast((select COUNT(*) from Seat where ClassID=st.ClassID and SeatType<>1 and StatusType=3) as varchar)+'/'+Cast((select COUNT(*) from Seat where ClassID=st.ClassID and SeatType<>1 and (StatusType=2 or StatusType=3)) as varchar)+'/'+Cast((select COUNT(*) from Seat where ClassID=st.ClassID and SeatType<>1) as varchar) as SeatInfo,(select ScreenName from Screen where ScreenID=st.ScreenID) ScreenName,(select MovieName from Show where ShowID=st.ShowID) MovieName,(select ShowTime from Show where ShowID=st.ShowID) ShowTime,(select ClassName from Class where ClassID=st.ClassID)+'('+cast(len(@tmp) - len(replace(@tmp,',','')) as varchar)+')' ClassName,PatronInfo,SeatID,'Check In' as stat,@tmp as Seats from Seat st where ( SeatID = @SeatID OR TicketID = @SeatID )
			AND StatusType = 3;
		IF @@ERROR <> 0 GOTO ERR_HANDLER
		end
		else
		begin
RaisError('Check Time',16,1)
		end
end
else if exists( select * from Seat WHERE ( SeatID = @SeatID OR TicketID = @SeatID AND StatusType = 3 ))
begin
			select Cast((select COUNT(*) from Seat where ClassID=st.ClassID and SeatType<>1 and StatusType=3) as varchar)+'/'+Cast((select COUNT(*) from Seat where ClassID=st.ClassID and SeatType<>1 and (StatusType=2 or StatusType=3)) as varchar)+'/'+Cast((select COUNT(*) from Seat where ClassID=st.ClassID and SeatType<>1) as varchar) as SeatInfo,(select ScreenName from Screen where ScreenID=st.ScreenID) ScreenName,(select MovieName from Show where ShowID=st.ShowID) MovieName,(select ShowTime from Show where ShowID=st.ShowID) ShowTime,(select ClassName from Class where ClassID=st.ClassID)+'('+cast(len(@tmp) - len(replace(@tmp,',','')) as varchar)+')' ClassName,PatronInfo,SeatID,'ReEntry' as stat,@tmp as Seats from Seat st where ( SeatID = @SeatID OR TicketID = @SeatID )
			AND StatusType = 3;
end
			
	
	COMMIT TRANSACTION
	RETURN
ERR_HANDLER:
	ROLLBACK TRANSACTION b
	RAISERROR('CONCURRENTFAIL', 11, 1)
	RETURN
GO

/* spSeatEditCancel */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSeatEditCancel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSeatEditCancel]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSeatEditCancel]
	@TicketID INT OUTPUT,
	@IsPriceChange BIT OUTPUT,
	@SeatIDs VARCHAR(256),
	@LastCancelledByID INT
AS
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRANSACTION
		--DECLARE @SQL NVARCHAR(4000)
		DECLARE @TmpTicketID INT
		DECLARE @TmpStatusType TINYINT
		DECLARE @TmpDCRID INT
		DECLARE @Error AS INT
		DECLARE @RowCount AS INT
		SELECT @Error = 0, @RowCount = 0
		DECLARE @onlineQuotaType INT = 3
		DECLARE @bookedStatusType INT = 2

		SELECT @TmpTicketID = 0, @TmpDCRID = 0
		--SET @SQL = N'SELECT TOP 1 @TmpTicketID = Seat.TicketID, @TmpStatusType = Seat.StatusType, @TmpDCRID = Class.DCRID FROM Seat INNER JOIN Class ON Seat.ClassID = Class.ClassID WHERE Seat.SeatID IN (' + @SeatIDs + ') '
		--EXEC SP_EXECUTESQL @Statement = @SQL, @params = N'@TmpTicketID INT OUTPUT, @TmpStatusType TINYINT OUTPUT, @TmpDCRID INT OUTPUT', @TmpTicketID = @TmpTicketID OUTPUT, @TmpStatusType = @TmpStatusType OUTPUT, @TmpDCRID = @TmpDCRID OUTPUT
		SELECT TOP 1 @TmpTicketID = Seat.TicketID, @TmpStatusType = Seat.StatusType, @TmpDCRID = Class.DCRID FROM Seat INNER JOIN Class ON Seat.ClassID = Class.ClassID 
		WHERE Seat.SeatID IN (select * from dbo.fnsplit(@SeatIDs, ','))
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0 OR @TmpTicketID = 0 GOTO ERR_HANDLER

		IF @TmpStatusType = 1
		BEGIN			
			UPDATE Seat SET
				TicketID = 0,
				StatusType = 0,
				PatronInfo = '',
				PatronFee = 0,
				ReleaseBefore = 60,
				DCRNo = 0
				WHERE TicketID = @TmpTicketID
				AND StatusType = 1 AND QuotaType <> @onlineQuotaType
			IF @@ERROR <> 0 OR @@ROWCOUNT = 0 GOTO ERR_HANDLER
		END
		ELSE IF @TmpStatusType = @bookedStatusType
		BEGIN
			DECLARE @LastCancelledOn DATETIME
			SELECT @LastCancelledOn = GETDATE()
			SELECT @IsPriceChange = CASE WHEN S.PriceCardId <> C.PriceCardId THEN 1 ELSE 0 END FROM Seat S, Class C WHERE S.ClassID = C.ClassID AND S.TicketID = @TmpTicketID
			
			INSERT INTO CancelHistory(ShowId, SeatId, SeatClassInfo, CancelledById, CancelledOn, PriceCardId, BookedOn, BookedPaymentType, TicketID, PatronInfo, ShouldNotify) 
			SELECT ShowId, SeatId, SeatClassInfo, @LastCancelledByID, @LastCancelledOn, PriceCardId, LastSoldOn, PaymentType, TicketID, PatronInfo, (CASE WHEN PatronInfo IS NULL OR PatronInfo = '' THEN 0 ELSE (SELECT TOP 1 IsNotifyOnCB FROM Complex) END) 
			FROM Seat WHERE TicketID = @TmpTicketID AND StatusType = @bookedStatusType AND QuotaType <> @onlineQuotaType
			
			CREATE TABLE #ItemSales(SlNo INT IDENTITY(1,1), TransactionID VARCHAR(10) NOT NULL, ItemID INT NOT NULL, ItemPriceID INT NOT NULL, ItemStockID INT NOT NULL, Quantity INT NOT NULL, OrderType INT NOT NULL, CancelledBy INT NOT NULL, CancelledOn DATETIME NOT NULL, SeatID INT NOT NULL, IsBlocked BIT NOT NULL)
			
			INSERT INTO #ItemSales(TransactionID, I.ItemID, ItemPriceID, ItemStockID, Quantity, OrderType, CancelledBy, CancelledOn, SeatID, IsBlocked)
			SELECT DISTINCT TransactionID, I.ItemID, ItemPriceID, ItemStockID, Quantity, 2, @LastCancelledByID, @LastCancelledOn, S.SeatID, IsBlocked FROM ItemSalesHistory I, BookHistory BH, Seat S WHERE BH.SeatID = I.SeatID AND BH.ItemTransactionID = I.TransactionID AND S.SeatID = BH.SeatID AND S.TicketID = @TmpTicketID AND StatusType = @bookedStatusType AND QuotaType <> @onlineQuotaType 
			
			IF EXISTS(SELECT TOP 1 SeatID FROM #ItemSales)
			BEGIN
				INSERT INTO ItemCancelHistory(TransactionID, ItemID, ItemPriceID, ItemStockID, Quantity, OrderType, CancelledBy, CancelledOn) SELECT TransactionID, ItemID, ItemPriceID, ItemStockID, Quantity, OrderType, CancelledBy, CancelledOn FROM #ItemSales
				
				DECLARE @i INT
				SET @i = 1
				DECLARE @maxi INT
				SET @maxi = (SELECT COUNT(*) FROM #ItemSales)
				WHILE (@maxi >= @i)
				BEGIN
					IF EXISTS(SELECT TransactionID FROM #ItemSales WHERE IsBlocked = 1 AND SlNo = @i)
						UPDATE Items SET BlockedStock = BlockedStock - Quantity FROM #ItemSales S WHERE Items.ItemID = S.ItemID AND S.SlNo = @i
						
				SET @i = @i + 1
				END
			END
			
			DROP TABLE #ItemSales
			
			IF @IsPriceChange = 1
			BEGIN
				UPDATE Show SET IsOnlineEdit = 0 WHERE ShowID IN (SELECT ShowID FROM Seat WHERE TicketID = @TmpTicketID AND StatusType = @bookedStatusType AND QuotaType <> @onlineQuotaType) AND OnlineShowId != ''
				INSERT INTO ShowSyncJobs(ShowId, OnlineShowId)
				SELECT DISTINCT ShowId, OnlineShowId FROM Show WHERE ShowID IN (SELECT ShowID FROM Seat WHERE TicketID = @TmpTicketID AND StatusType = @bookedStatusType AND QuotaType <> @onlineQuotaType) AND OnlineShowId != ''
			END

			UPDATE Seat SET
				TicketID = 0,
				StatusType = 0,
				PaymentType = 0,
				PaymentReceived = 0,
				PatronInfo = '',
				PatronFee = 0,
				ReleaseBefore = 60,
				DCRNo = 0,
				LastSoldOn = NULL,
				LastPrintedByID = 0,
				LastBlockedByID = 0,
				NoCancels = NoCancels + 1,
				LastCancelledByID = @LastCancelledByID,
				LastCancelledOn = @LastCancelledOn,
				PriceCardId = (SELECT TOP(1) C.PriceCardId FROM Seat S, Class C WHERE S.ClassID = C.ClassID AND S.TicketID = @TmpTicketID)
				WHERE TicketID = @TmpTicketID
				AND StatusType = @bookedStatusType AND QuotaType <> @onlineQuotaType
			SELECT @Error = @@ERROR, @RowCount = @@ROWCOUNT
			IF @Error <> 0 OR @RowCount = 0 GOTO ERR_HANDLER
		END

		SET @TicketID = @TmpTicketID

	COMMIT TRANSACTION
	RETURN
	ERR_HANDLER:
	ROLLBACK TRANSACTION
	RAISERROR('CONCURRENTFAIL', 11, 1)
	RETURN
GO

/* [dbo].[spShowLoad] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowLoad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowLoad]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spShowLoad]
	@ShowID INT,
	@IsArchived BIT
AS
	IF @IsArchived > 0
		SELECT
			ScreenID,
			ShowID,
			ScreenNo,
			ScreenName,
			OnlineMovieID,
			OnlineMovieName,
			MovieName,
			Experiences,
			MovieLanguageType,
			MovieCensorRatingType,
			ShowName,
			ShowTime,
			IsPaused,
			ResumeBefore,
			AllowedUsers,
			Duration,
			IsCancel,
			CancelRemarks,
			IsOnlinePublish,
			OnlineShowId,
			EntryTime,
			IntervalTime,
			ExitTime,
			IsOnlineSaleClosed,
			IsAdvanceToken,
			AdvanceTokenReleaseTime,
			IsRealTime,
			DistributorMovieId,
			IsLocked,
			UnpaidBookingReleaseTime,
			IsOnlineEdit,
			ISNULL(MovieMergedTo, '')
		FROM ShowMIS
		WHERE ShowID = @ShowID
	ELSE
		SELECT
			ScreenID,
			ShowID,
			ScreenNo,
			ScreenName,
			OnlineMovieID,
			OnlineMovieName,
			MovieName,
			Experiences,
			MovieLanguageType,
			MovieCensorRatingType,
			ShowName,
			ShowTime,
			IsPaused,
			ResumeBefore,
			AllowedUsers,
			Duration,
			IsCancel,
			CancelRemarks,
			IsOnlinePublish,
			OnlineShowId,
			EntryTime,
			IntervalTime,
			ExitTime,
			IsOnlineSaleClosed,
			IsAdvanceToken,
			AdvanceTokenReleaseTime,
			IsRealTime,
			DistributorMovieId,
			IsLocked,
			UnpaidBookingReleaseTime,
			IsOnlineEdit,
			ISNULL(MovieMergedTo, '')
		FROM Show
		WHERE ShowID = @ShowID
GO

/****** Object:  StoredProcedure [dbo].[spShowEditUnlinkOnlineMovie]    Script Date: 09/01/2014 10:10:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spShowEditUnlinkOnlineMovie]
	@ShowID INT
AS
	UPDATE Show
	SET OnlineMovieId = 0,
		OnlineMovieName = ''
	WHERE ShowID = @ShowID
GO

/* [spShowEditJson] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowEditJson]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowEditJson]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- spShowEditJson 9
CREATE PROCEDURE [dbo].[spShowEditJson]
	@ShowID INT
AS
BEGIN
	DECLARE @id UNIQUEIDENTIFIER = NULL
	DECLARE @data NVARCHAR(MAX) = NULL
	SELECT TOP 1 @id = Id, @data = ISNULL(Data, '') FROM ShowSyncJobs WHERE ShowId = @ShowID AND [Status] = 0
	IF @id IS NOT NULL
	BEGIN
		UPDATE ShowSyncJobs SET [Status] = 1 WHERE Id = @id
		DECLARE @IsAdvanceToken BIT
		DECLARE @FreeSeating NVARCHAR(5)
	
		SELECT @IsAdvanceToken = IsAdvanceToken, @FreeSeating = (CASE WHEN ISNULL(IsDisplaySeatNos, 0) > 0 THEN 'false' ELSE 'true' END) FROM Show WHERE ShowID = @ShowID

		DECLARE @SEATDETAILS AS NVARCHAR(MAX)='';
	
		;with SampleDataR as
		(
		select *, ROW_NUMBER() over (partition by seatid order by seatid) rownum,'' value
		from Seat where SeatType<>1 and ShowID=@ShowID
		) 
	
		select distinct top(1) @SEATDETAILS=(
		select value 
		+ '{
		"Row":"'+CAST(RowNo AS VARCHAR)+'",  
		"Column":"'+CAST(ColNo AS VARCHAR)+'",  
		"Label":"'+ SeatLabel+'",  
		"QuotaType":"'+(CASE WHEN QuotaType=3 THEN 'Online' WHEN QuotaType = 1 THEN 'Unavailable' ELSE 'Counter' END)+'",  
		' + CASE WHEN (SeatType <> 2 OR @FreeSeating = 'true') 
				THEN  '"combinations":[]' 
				ELSE '"combinations":['+ ('{"row":"'+ CAST(RowNo AS VARCHAR) +'", "column":"'+ CAST(ColNo AS VARCHAR) +'"}, {"row":"'+ (SELECT DISTINCT CAST(RowNo AS VARCHAR) FROM Seat WHERE seat.ShowID = @ShowID AND seat.SeatLayoutID IN (SELECT items FROM dbo.fnsplit(s1.CoupleSeatIds, ',')) AND seat.SeatLayoutID != s1.SeatLayoutID) + '", "column":"' + (SELECT DISTINCT Cast(ColNo AS VARCHAR) FROM Seat WHERE seat.ShowID = @ShowID AND seat.SeatLayoutID IN (SELECT items FROM dbo.fnsplit(s1.CoupleSeatIds, ',')) AND seat.SeatLayoutID != s1.SeatLayoutID) + '"}') +']' END + ',
		"SeatType":"'+(CASE WHEN SeatType=1 THEN 'Gangway' WHEN (SeatType <> 2 OR  @FreeSeating = 'true') THEN 'Seat' ELSE 'Multi' END)+'",  
		"PriceCardId":"'+ (CASE @IsAdvanceToken WHEN 1 THEN '0' ELSE (SELECT TOP 1 CAST(ISNULL(ID, '') AS VARCHAR) FROM PriceCard WHERE Id=s1.PriceCardID) END)+'",
		"Class":"'+(SELECT TOP 1 ClassName FROM [Class] WHERE Class.ShowID = @ShowID AND ClassId=s1.ClassID )+'",  
		"ClassPosition":"'+(SELECT TOP 1 ClassPosition FROM [ClassLayout] WHERE ClassLayoutId=s1.ClassLayoutID )+'"},' FROM SampleDataR s1  
		for xml path(''),type).value('(.)[1]','NVARCHAR(MAX)'
		) 
		from SampleDataR s2
	
		set @SEATDETAILS=SUBSTRING(@SEATDETAILS ,1, len(@SEATDETAILS)-1);	
		DECLARE @PRICEDETAILS AS NVARCHAR(MAX)='';	
	
		If(@IsAdvanceToken = 0)
		BEGIN
			SELECT @PRICEDETAILS=COALESCE(@PRICEDETAILS+',' ,'')+'{"BoxOfficePriceCardId":"'+CAST(PriceCard.Id AS VARCHAR)+'",  
			"TotalAmount":'+CAST(Amount AS VARCHAR)+',"Options":[  
			'+  SUBSTRING([dbo].[GetFullPriceCardDetailsByID](PriceCard.Id ),2,LEN([dbo].[GetFullPriceCardDetailsByID](PriceCard.Id )))  
			+']
			}  
			'   
			FROM PriceCard WHERE Id IN (SELECT DISTINCT PriceCardID FROM Seat WHERE SeatType<>1 and ShowID=@ShowID);  
		 
			SET @PRICEDETAILS=SUBSTRING(@PRICEDETAILS ,2,LEN(@PRICEDETAILS)) 
		END
		ELSE
		BEGIN
			SELECT @PRICEDETAILS=COALESCE(@PRICEDETAILS+',' ,'')+'{"BoxOfficePriceCardId":"'+CAST(PriceCard.Id AS VARCHAR)+'",  
			"TotalAmount":'+CAST(Amount AS VARCHAR)+',"Options":[]}  
			'   
			FROM PriceCard WHERE Id = 0
		 
			SET @PRICEDETAILS=SUBSTRING(@PRICEDETAILS ,2,LEN(@PRICEDETAILS))
		END  
	
		SELECT  
		'{"SessionTime" : "'+ (SELECT CONVERT(VARCHAR(19), CONVERT(DATETIME,SWITCHOFFSET(CONVERT(DATETIMEOFFSET, Showtime),'-05:30')), 126))+ 'Z'+'",
		"experiences": ["'+(REPLACE (Show.Experiences, ',', '","'))+'"],
		"freeSeating": '+ @FreeSeating +', 
		"Seats":['+@SEATDETAILS+'],"PriceCards": ['+@PriceDetails+']}' AS Seat,
		@id, @data
		FROM Show  
		WHERE ShowID = @ShowID
	END
END
GO

/* spShowLoadJson */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spShowLoadJson]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spShowLoadJson]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [spShowLoadJson] 25
CREATE PROCEDURE [dbo].[spShowLoadJson]  
	@ShowID INT  
AS
	DECLARE @IsAdvanceToken BIT
	DECLARE @IsRealTime BIT
	DECLARE @FreeSeating NVARCHAR(5)
	DECLARE @AdvanceTokenReleaseTime INT
	
	SELECT @IsAdvanceToken = IsAdvanceToken, @IsRealTime = IsRealTime, @FreeSeating = (CASE WHEN ISNULL(IsDisplaySeatNos, 0) > 0 THEN 'false' ELSE 'true' END), @AdvanceTokenReleaseTime = ISNULL(AdvanceTokenReleaseTime, 0) FROM Show WHERE ShowID = @ShowID

	DECLARE @SEATDETAILS AS NVARCHAR(MAX)='';
	
	;WITH SampleDataR as  
	(  
	SELECT *, ROW_NUMBER() OVER (PARTITION BY seatid ORDER BY seatid) rownum,'' value  
	FROM Seat WHERE SeatType<>1 and ShowID = @ShowID 
	)
	
	SELECT DISTINCT TOP(1) @SEATDETAILS=(  
	SELECT value   
	+ '{  
	"id": "'+ (ISNULL(SeatClassInfo, '')) +'",  
	"Row":"'+CAST(RowNo AS VARCHAR)+'",  
	"Column":"'+CAST(ColNo AS VARCHAR)+'",  
	"Label":"'+ SeatLabel+'",  
	"QuotaType":"'+(CASE WHEN QuotaType=3 THEN 'Online' WHEN QuotaType = 1 THEN 'Unavailable' ELSE 'Counter' END)+'",  
	' + CASE WHEN (SeatType <> 2 OR @FreeSeating = 'true') 
			THEN  '"combinations":[]' 
			ELSE '"combinations":['+
			('{"row":"'+ CAST(RowNo AS VARCHAR) +'", "column":"'+ CAST(ColNo AS VARCHAR) +'"}, {"row":"'+ (SELECT DISTINCT CAST(RowNo AS VARCHAR) FROM Seat WHERE seat.ShowID = @ShowID AND seat.SeatLayoutID IN (SELECT items FROM dbo.fnsplit(s1.CoupleSeatIds, ',')) AND seat.SeatLayoutID != s1.SeatLayoutID) + '", "column":"' + (SELECT DISTINCT Cast(ColNo AS VARCHAR) FROM Seat WHERE seat.ShowID = @ShowID AND seat.SeatLayoutID IN (SELECT items FROM dbo.fnsplit(s1.CoupleSeatIds, ',')) AND seat.SeatLayoutID != s1.SeatLayoutID) + '"}') +']' END + ',
	"SeatType":"'+(CASE WHEN SeatType=1 THEN 'Gangway' WHEN (SeatType <> 2 OR  @FreeSeating = 'true') THEN 'Seat' ELSE 'Multi' END)+'",  
	"PriceCardId":"'+ (CASE @IsAdvanceToken WHEN 1 THEN '0' ELSE (SELECT TOP 1 CAST(ISNULL(ID, '') AS VARCHAR) FROM PriceCard WHERE Id=s1.PriceCardID) END)+'",
	"Class":"'+(SELECT TOP 1 ClassName FROM [Class] WHERE Class.ShowID = @ShowID AND ClassId=s1.ClassID )+'",  
	"ClassPosition":"'+(SELECT TOP 1 ClassPosition FROM [ClassLayout] WHERE ClassLayoutId=s1.ClassLayoutID )+'"},' FROM SampleDataR s1  
	FOR XML PATH(''),TYPE).value('(.)[1]','NVARCHAR(MAX)'  
	)   
	FROM SampleDataR s2  
	  
	SET @SEATDETAILS = SUBSTRING(@SEATDETAILS ,1, LEN(@SEATDETAILS) - 1);  
	  
	DECLARE @PRICEDETAILS AS NVARCHAR(MAX)='';	  
	  
	If(@IsAdvanceToken = 0)
	BEGIN
		SELECT @PRICEDETAILS = COALESCE(@PRICEDETAILS+',' ,'')+'{"BoxOfficePriceCardId":"'+CAST(PriceCard.Id AS VARCHAR)+'",  
		"TotalAmount":'+CAST(Amount AS VARCHAR)+',"Options":[  
		'+  SUBSTRING([dbo].[GetFullPriceCardDetailsByID](PriceCard.Id ),2,LEN([dbo].[GetFullPriceCardDetailsByID](PriceCard.Id )))  
		+']}'   
		FROM PriceCard WHERE Id IN (SELECT DISTINCT PriceCardID FROM Seat WHERE SeatType<>1 and ShowID=@ShowID);  
		 
		SET @PRICEDETAILS=SUBSTRING(@PRICEDETAILS ,2,LEN(@PRICEDETAILS)) 
	END
	ELSE
	BEGIN
		SELECT @PRICEDETAILS=COALESCE(@PRICEDETAILS+',' ,'')+'{"BoxOfficePriceCardId":"'+CAST(PriceCard.Id AS VARCHAR)+'",  
		"TotalAmount":'+CAST(Amount AS VARCHAR)+',"Options":[]}'   
		FROM PriceCard WHERE Id = 0
		 
		SET @PRICEDETAILS=SUBSTRING(@PRICEDETAILS ,2,LEN(@PRICEDETAILS))
	END
	
	
	SELECT  
	'{"ChainID" : "'+(SELECT TOP 1 ChainGUID FROM Complex WHERE ComplexID IN (SELECT ComplexID FROM Screen WHERE ScreenID=Show.ScreenID))+'",  
	"TheatreID" : "'+(SELECT TOP 1 ComplexGUID FROM Complex WHERE ComplexID IN (SELECT ComplexID FROM Screen WHERE ScreenID=Show.ScreenID))+'",  
	"ScreenID" : "'+(Select TOP 1 ScreenGUID FROM Screen WHERE ScreenID = Show.ScreenID)+'",  
	"sessionType" : "'+(CASE WHEN @IsRealTime = 0 THEN 'QUOTA' ELSE 'REALTIME' END)+'",
	"SessionTime" : "'+ (SELECT CONVERT(VARCHAR(19), CONVERT(DATETIME,SWITCHOFFSET(CONVERT(DATETIMEOFFSET, Showtime),'-05:30')), 126))+ 'Z'+'",
	"SessionID" : "'+ Show.Uuid + '|' + CAST(Show.ShowId AS NVARCHAR(100)) +'",
	"experiences": ["'+(REPLACE (Show.Experiences, ',', '","'))+'"],
	"MovieId" : "'+OnlineMovieId+'",  
	"freeSeating": '+  @FreeSeating +',  
	"isadvanceToken": '+(CASE WHEN @IsAdvanceToken IS NULL OR @IsAdvanceToken = 0 THEN 'false' ELSE 'true' end)+',
	"pickupTimeInMins" : "'+CAST(@AdvanceTokenReleaseTime AS VARCHAR)+'",
	"Seats":['+@SEATDETAILS+'],"PriceCards": ['+@PriceDetails+']}' AS Seat  
	FROM Show 
	WHERE ShowID = @ShowID  
GO

/* [ScreeningScheduleReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[ScreeningScheduleReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ScreeningScheduleReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec ScreeningScheduleReport 1, 0, '06 Nov 2016', 'all', 'yes', '', 'movi'
CREATE PROCEDURE [dbo].[ScreeningScheduleReport]
(
	@theatreId INT,
	@screenId INT,
	@showDate VARCHAR(11),
	@movieName NVARCHAR(256),
	@openShowsOnly VARCHAR(20),
	@showTime VARCHAR(8),
	@sortBy VARCHAR(20)
) AS
BEGIN
	SELECT * INTO #TempShowMaster FROM 
	(
		SELECT ScreenName, MovieName, MovieLanguageType, ShowID, ShowTime, Duration, IsPaused, IsCancel FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND ShowTime = CASE WHEN @showTime = '' THEN ShowTime ELSE CAST(@showDate + ' ' + @showTime AS DATETIME) END AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND MovieName = CASE WHEN @movieName ='ALL' THEN MovieName ELSE @movieName END
		UNION ALL
		SELECT ScreenName, MovieName, MovieLanguageType, ShowID, ShowTime, Duration, IsPaused, IsCancel FROM ShowMIS WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND ShowTime = CASE WHEN @showTime = '' THEN ShowTime ELSE CAST(@showDate + ' ' + @showTime AS DATETIME) END AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND MovieName = CASE WHEN @movieName ='ALL' THEN MovieName ELSE @movieName END
	) AS TempShowMaster
	
	SELECT * INTO #TempSeatMaster FROM (SELECT SeatID, ShowID, PriceCardId, SeatType, StatusType, ClassID, PaymentType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #TempShowMaster) UNION ALL SELECT SeatID, ShowID, PriceCardId, SeatType, StatusType, ClassID, PaymentType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #TempShowMaster)) AS TempSeatMaster

	SELECT * INTO #TempClassMaster FROM (SELECT ClassName, ClassID, ShowID FROM Class WHERE ShowID IN (SELECT ShowID FROM #TempShowMaster) UNION ALL SELECT ClassName, ClassID, ShowID FROM ClassMIS WHERE ShowID IN (SELECT ShowID FROM #TempShowMaster)) AS TempClassMaster
		
	IF (@openShowsOnly = 'Yes')
	BEGIN
		SELECT
			ScreeningSchedule.[Screen],
			ScreeningSchedule.[Movie Name & Language],
			ScreeningSchedule.[Session Start] AS [Session Time],
			ScreeningSchedule.[Session Status],
			ScreeningSchedule.[Session Start],
			ScreeningSchedule.[Session End],
			ScreeningSchedule.[Class Name],
			(SELECT 'Total Ticket Amount: ' + CAST(PC.Amount AS VARCHAR(8)) FROM PriceCard AS PC WHERE PC.Id = P.ID) [Price Card Breakdown],
			(ROUND(ISNULL((SELECT SUM(PC.Amount) FROM #TempSeatMaster S INNER JOIN PriceCard PC ON S.PriceCardID = PC.Id
			WHERE S.ShowID = ST.ShowID AND S.PriceCardId = ST.PriceCardId AND S.StatusType IN (2,3) AND S.PaymentType <> 5 AND S.ClassID = ScreeningSchedule.ClassID), 0), 2)) Gross,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType IN (2,3) AND PriceCardId = ST.PriceCardId AND PaymentType = 5) FreeSeat,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType IN (2,3) AND PriceCardId = ST.PriceCardId) Sold,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType = 1 AND PriceCardId = ST.PriceCardId) Blocked,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType = 0) Available,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1) Capacity
			INTO #FinalScreeningSchedule 
		FROM
		(
			SELECT DISTINCT 
				Sh.ScreenName As [Screen],
				Sh.MovieName + ' (' + (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) + ')' AS [Movie Name & Language],
				Sh.ShowID,
				CASE WHEN GETDATE() > DATEADD(MINUTE, 120, Sh.ShowTime) THEN 'Closed' ELSE 'Open' END AS [Session Status],
				LTRIM(RIGHT(REPLACE(CONVERT(NVARCHAR(50),CAST(Sh.ShowTime AS SMALLDATETIME), 109),':00:000', ' '), 8)) AS [Session Start],
				LTRIM(RIGHT(REPLACE(CONVERT(NVARCHAR(50),CAST(DATEADD(MINUTE, Sh.Duration, Sh.ShowTime) AS SMALLDATETIME), 109),':00:000', ' '), 8)) AS [Session End],
				C.ClassName AS [Class Name],
				C.ClassID
			FROM 
				#TempShowMaster Sh
				LEFT JOIN #TempClassMaster C ON Sh.ShowID = C.ShowID 
				LEFT JOIN #TempSeatMaster S ON Sh.ShowID = S.ShowID 
			WHERE
				Sh.IsPaused = 0 AND Sh.IsCancel = 0 AND DATEADD(MINUTE, 120, Sh.ShowTime) > GETDATE()
			GROUP BY
				Sh.Screenname, Sh.MovieName, Sh.MovieLanguageType, Sh.ShowID, Sh.ShowTime, Sh.Duration, C.ClassName, C.ClassID, S.PriceCardId
		) ScreeningSchedule
		LEFT JOIN #TempSeatMaster ST ON ST.ShowId = ScreeningSchedule.ShowId AND ST.ClassId = ScreeningSchedule.ClassId
		LEFT JOIN PriceCard P ON ST.PriceCardId = P.Id
		GROUP BY 
		ScreeningSchedule.[Screen],
			ScreeningSchedule.[Movie Name & Language],
			ScreeningSchedule.[Session Start],
			ScreeningSchedule.[Session Status],
			ScreeningSchedule.[Session Start],
			ScreeningSchedule.[Session End],
			ScreeningSchedule.[Class Name],
			P.Id, ST.ShowID, ST.ClassID, ScreeningSchedule.ClassID, ST.PriceCardID

		SELECT * INTO #FinalTotalScreeningSchedule FROM
		(
			SELECT [Movie Name & Language], [Screen], [Session Time], [Session Status], [Session Start], [Session End], 
			[Class Name], [Price Card Breakdown], Capacity, Sold AS [Number of Seats Sold], Blocked AS [Number of Seats Blocked], 
			FreeSeat AS [Number of Free Seats Sold], Available AS [Number of Seats Available], 
			CAST((CASE WHEN Sold = 0 THEN 0 WHEN Sold = FreeSeat THEN Gross/Sold ELSE Gross/(Sold - FreeSeat) END) AS DECIMAL(18,2)) AS [Average Ticket Price], 
			CAST(Sold * 100.00 / (CASE WHEN Capacity = 0 THEN 1 ELSE Capacity END) AS DECIMAL(18,2)) AS [Occupancy in Percentage], 
			CAST(Gross AS DECIMAL(18,2))AS [Total Revenue] FROM #FinalScreeningSchedule
		)FinalTotalScreeningSchedule
		
		DROP TABLE #FinalScreeningSchedule
		
		SELECT
			[Movie Name & Language],
			[Screen],
			[Session Time],
			[Session Status],
			[Session Start],
			[Session End],
			[Class Name],
			[Price Card Breakdown],
			Capacity,
			[Number of Seats Sold],
			[Number of Seats Blocked],
			[Number of Seats Available],
			[Average Ticket Price],
			[Occupancy in Percentage],
			[Total Revenue]
		FROM
			#FinalTotalScreeningSchedule
		ORDER BY CASE WHEN @sortBy = 'Movie' THEN [Movie Name & Language] ELSE [Screen] END, [Session Time], [Class Name]
		
		IF (@sortBy = 'Movie')
		BEGIN
			SELECT
				[Movie Name & Language],
				[Class Name],
				Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				[Number of Seats Available],
				SUM([Number of Free Seats Sold]) AS [Number of Free Seats Sold],
				SUM([Total Revenue]) AS [Total Revenue]
			INTO #FinalMovieTotalScreeningSchedule
			FROM
				#FinalTotalScreeningSchedule
			GROUP BY
				[Movie Name & Language], [Class Name], Capacity, [Number of Seats Available]
			
			SELECT
				[Movie Name & Language],
				'','','','','','','',
				SUM(Capacity) AS Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				SUM([Number of Seats Available]) AS [Number of Seats Available],
				CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price],
				CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage],
				SUM([Total Revenue]) AS [Total Revenue]
			FROM
				#FinalMovieTotalScreeningSchedule
			GROUP BY
				[Movie Name & Language]
			
			SELECT 'Total' AS [Movie Name & Language], '','','','','','','', SUM(Capacity) AS Capacity, SUM([Number of Seats Sold]) AS [Number of Seats Sold], SUM([Number of Seats Blocked]) AS [Number of Seats Blocked], SUM([Number of Seats Available]) AS [Number of Seats Available], CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price], CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage], SUM([Total Revenue]) AS [Total Revenue] FROM #FinalMovieTotalScreeningSchedule
			DROP TABLE #FinalMovieTotalScreeningSchedule
		END
		ELSE
		BEGIN
			SELECT
				[Screen],
				[Class Name],
				Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				[Number of Seats Available],
				SUM([Number of Free Seats Sold]) AS [Number of Free Seats Sold],
				SUM([Total Revenue]) AS [Total Revenue]
			INTO #FinalScreenTotalScreeningSchedule
			FROM
				#FinalTotalScreeningSchedule
			GROUP BY
				[Screen], [Class Name], Capacity, [Number of Seats Available]
				
			SELECT
				'',
				[Screen],
				'','','','','','',
				SUM(Capacity) AS Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				SUM([Number of Seats Available]) AS [Number of Seats Available],
				CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price],
				CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage],
				SUM([Total Revenue]) AS [Total Revenue]
			FROM
				#FinalScreenTotalScreeningSchedule
			GROUP BY
				[Screen]
			
			SELECT 'Total' AS [Movie Name & Language], '','','','','','','', SUM(Capacity) AS Capacity, SUM([Number of Seats Sold]) AS [Number of Seats Sold], SUM([Number of Seats Blocked]) AS [Number of Seats Blocked], SUM([Number of Seats Available]) AS [Number of Seats Available], CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price], CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage], SUM([Total Revenue]) AS [Total Revenue] FROM #FinalScreenTotalScreeningSchedule
			DROP TABLE #FinalScreenTotalScreeningSchedule
		END
		DROP TABLE #FinalTotalScreeningSchedule
	END
	ELSE
	BEGIN
		SELECT DISTINCT
			ScreeningSchedule.[Screen],
			ScreeningSchedule.[Movie Name & Language],
			ScreeningSchedule.[Session Start] AS [Session Time],
			ScreeningSchedule.[Session Status],
			ScreeningSchedule.[Session Start],
			ScreeningSchedule.[Session End],
			ScreeningSchedule.[Class Name],
			(SELECT 'Total Ticket Amount: ' + CAST(PC.Amount AS VARCHAR(8)) FROM PriceCard AS PC WHERE PC.Id = P.ID) [Price Card Breakdown],
			(ROUND(ISNULL((SELECT SUM(PC.Amount) FROM #TempSeatMaster S INNER JOIN PriceCard PC ON S.PriceCardID = PC.Id
			WHERE S.ShowID = ST.ShowID AND S.PriceCardId = ST.PriceCardId AND S.StatusType IN (2,3) AND S.PaymentType <> 5 AND S.ClassID = ScreeningSchedule.ClassID), 0), 2)) Gross,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType IN (2,3) AND PriceCardId = ST.PriceCardId AND PaymentType = 5) FreeSeat,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType IN (2,3) AND PriceCardId = ST.PriceCardId) Sold,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType = 1 AND PriceCardId = ST.PriceCardId) Blocked,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1 AND StatusType = 0) Available,
			(SELECT COUNT(*) FROM #TempSeatMaster WHERE ClassID = ScreeningSchedule.ClassID AND ShowID = ST.ShowID AND SeatType <> 1) Capacity
			INTO #FinalScreeningSchedule1
		FROM
		(
			SELECT DISTINCT 
				Sh.ScreenName As [Screen],
				Sh.MovieName + ' (' + (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) + ')' AS [Movie Name & Language],
				Sh.ShowID,
				CASE WHEN Sh.IsCancel = 1 THEN 'Cancelled' WHEN Sh.IsPaused = 1 THEN 'Paused' WHEN GETDATE() > DATEADD(MINUTE, 120, Sh.ShowTime) THEN 'Closed' ELSE 'Open' END AS [Session Status],
				LTRIM(RIGHT(REPLACE(CONVERT(NVARCHAR(50),CAST(Sh.ShowTime AS SMALLDATETIME), 109),':00:000', ' '), 8)) AS [Session Start],
				LTRIM(RIGHT(REPLACE(CONVERT(NVARCHAR(50),CAST(DATEADD(MINUTE, Sh.Duration, Sh.ShowTime) AS SMALLDATETIME), 109),':00:000', ' '), 8)) AS [Session End],
				C.ClassName AS [Class Name],
				C.ClassID
			FROM 
				#TempShowMaster Sh
				LEFT JOIN #TempClassMaster C ON Sh.ShowID = C.ShowID 
				LEFT JOIN #TempSeatMaster S ON Sh.ShowID = S.ShowID
			GROUP BY
				Sh.Screenname, Sh.MovieName, Sh.MovieLanguageType, Sh.ShowID, Sh.ShowTime, Sh.Duration, C.ClassName, C.ClassID, S.PriceCardId, Sh.IsCancel, Sh.IsPaused
		) ScreeningSchedule
		LEFT JOIN #TempSeatMaster ST ON ST.ShowId = ScreeningSchedule.ShowId AND ST.ClassId = ScreeningSchedule.ClassId
		LEFT JOIN PriceCard P ON ST.PriceCardId = P.Id

		SELECT * INTO #FinalTotalScreeningSchedule1 FROM
		(
			SELECT [Movie Name & Language], [Screen], [Session Time], [Session Status], [Session Start], [Session End], [Class Name], [Price Card Breakdown], Capacity, Sold AS [Number of Seats Sold], Blocked AS [Number of Seats Blocked], FreeSeat AS [Number of Free Seats Sold], Available AS [Number of Seats Available], CAST((CASE WHEN Sold = 0 THEN 0 WHEN Sold = FreeSeat THEN Gross/Sold ELSE Gross/(Sold - FreeSeat) END) AS DECIMAL(18,2)) AS [Average Ticket Price], CAST(Sold * 100.00 / (CASE WHEN Capacity = 0 THEN 1 ELSE Capacity END) AS DECIMAL(18,2)) AS [Occupancy in Percentage], CAST(Gross AS DECIMAL(18,2))AS [Total Revenue] FROM #FinalScreeningSchedule1
		)FinalTotalScreeningSchedule1
		
		DROP TABLE #FinalScreeningSchedule1
		
		SELECT
			[Movie Name & Language],
			[Screen],
			[Session Time],
			[Session Status],
			[Session Start],
			[Session End],
			[Class Name],
			[Price Card Breakdown],
			Capacity,
			[Number of Seats Sold],
			[Number of Seats Blocked],
			[Number of Seats Available],
			[Average Ticket Price],
			[Occupancy in Percentage],
			[Total Revenue]
		FROM
			#FinalTotalScreeningSchedule1
		ORDER BY CASE WHEN @sortBy = 'Movie' THEN [Movie Name & Language] ELSE [Screen] END, [Session Time], [Class Name]
		
		IF (@sortBy = 'Movie')
		BEGIN
			SELECT
				[Movie Name & Language],
				[Class Name],
				Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				[Number of Seats Available],
				SUM([Number of Free Seats Sold]) AS [Number of Free Seats Sold],
				SUM([Total Revenue]) AS [Total Revenue]
			INTO #FinalMovieTotalScreeningSchedule1
			FROM
				#FinalTotalScreeningSchedule1
			GROUP BY
				[Movie Name & Language], [Class Name], Capacity, [Number of Seats Available]
				
			SELECT
				[Movie Name & Language],
				'','','','','','','',
				SUM(Capacity) AS Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				SUM([Number of Seats Available]) AS [Number of Seats Available],
				CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price],
				CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage],
				SUM([Total Revenue]) AS [Total Revenue]
			FROM
				#FinalMovieTotalScreeningSchedule1
			GROUP BY
				[Movie Name & Language]
			
			SELECT 'Total' AS [Movie Name & Language], '','','','','','','', SUM(Capacity) AS Capacity, SUM([Number of Seats Sold]) AS [Number of Seats Sold], SUM([Number of Seats Blocked]) AS [Number of Seats Blocked], SUM([Number of Seats Available]) AS [Number of Seats Available], CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price], CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage], SUM([Total Revenue]) AS [Total Revenue] FROM #FinalMovieTotalScreeningSchedule1
			DROP TABLE #FinalMovieTotalScreeningSchedule1
		END
		ELSE
		BEGIN
			SELECT
				[Screen],
				[Class Name],
				Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				[Number of Seats Available],
				SUM([Number of Free Seats Sold]) AS [Number of Free Seats Sold],
				SUM([Total Revenue]) AS [Total Revenue]
			INTO #FinalScreenTotalScreeningSchedule1
			FROM
				#FinalTotalScreeningSchedule1
			GROUP BY
				[Screen], [Class Name], Capacity, [Number of Seats Available]
				
			SELECT
				'',
				[Screen],
				'','','','','','',
				SUM(Capacity) AS Capacity,
				SUM([Number of Seats Sold]) AS [Number of Seats Sold],
				SUM([Number of Seats Blocked]) AS [Number of Seats Blocked],
				SUM([Number of Seats Available]) AS [Number of Seats Available],
				CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price],
				CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage],
				SUM([Total Revenue]) AS [Total Revenue]
			FROM
				#FinalScreenTotalScreeningSchedule1
			GROUP BY
				[Screen]
			
			SELECT 'Total' AS [Movie Name & Language], '','','','','','','', SUM(Capacity) AS Capacity, SUM([Number of Seats Sold]) AS [Number of Seats Sold], SUM([Number of Seats Blocked]) AS [Number of Seats Blocked], SUM([Number of Seats Available]) AS [Number of Seats Available], CAST((CASE WHEN SUM([Number of Seats Sold]) = 0 THEN 0 WHEN SUM([Number of Seats Sold]) = SUM([Number of Free Seats Sold]) THEN SUM([Total Revenue])/SUM([Number of Seats Sold]) ELSE SUM([Total Revenue])/(SUM([Number of Seats Sold]) - SUM([Number of Free Seats Sold])) END) AS DECIMAL(18,2)) AS [Average Ticket Price], CAST(SUM([Number of Seats Sold]) * 100.00 / SUM(Capacity) AS DECIMAL(18,2)) AS [Occupancy in Percentage], SUM([Total Revenue]) AS [Total Revenue] FROM #FinalScreenTotalScreeningSchedule1
			DROP TABLE #FinalScreenTotalScreeningSchedule1
		END
		DROP TABLE #FinalTotalScreeningSchedule1
	END
		
	DROP TABLE #TempSeatMaster
	DROP TABLE #TempShowMaster
	DROP TABLE #TempClassMaster
END
GO

/* [GetViewPrintSeats] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetViewPrintSeats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetViewPrintSeats]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--GetViewPrintSeats 0, '56733', 1, 0
CREATE PROCEDURE [dbo].[GetViewPrintSeats]
	@seatID INT,
	@seatIDs VARCHAR(8000),
	@priceCardID INT,
	@paymentType INT
AS
BEGIN
	DECLARE @SQL VARCHAR(8000)
	
	CREATE TABLE #Couple (SlNo INT IDENTITY(1,1), CId INT, ShowId INT)
	INSERT INTO #Couple(CId, ShowId) SELECT SeatID, ShowId FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@seatIDs, ',')) AND SeatType = 2 AND StatusType <> 4

	CREATE TABLE #IDs (ID BIGINT)
	INSERT INTO #IDs SELECT SeatID FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@seatIDs, ',')) AND SeatType != 2 AND StatusType <> 4

	DECLARE @i INT
	SET @i = 1
	DECLARE @maxi INT
	SET @maxi = (SELECT COUNT(*) FROM #couple)
	WHILE (@maxi >= @i)
	BEGIN
		DECLARE @CoupleSeatIds NVARCHAR(50)
		SET @CoupleSeatIds = NULL		
		SELECT @CoupleSeatIds = CoupleSeatIds FROM Seat WHERE SeatID IN (SELECT CId FROM #Couple WHERE #Couple.SlNo = @i)
		
		INSERT INTO #IDs
		SELECT SeatId FROM Seat WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@CoupleSeatIds, ',')) AND ShowID IN (SELECT ShowId FROM #Couple WHERE #Couple.SlNo = @i)
		SET @i = @i + 1
	END
	DROP TABLE #Couple
	
	UPDATE Seat set NoBlocks=0,PatronInfo='' where statustype=0 and SeatID IN (SELECT items FROM dbo.FnSplit(@seatIDs, ','))
	
	SELECT
	Seat.ScreenID,
	Seat.ShowID,
	Seat.ClassID,
	Seat.TicketID,
	Seat.SeatID,
	Seat.DCRNo,
	Seat.SeatType,
	(CASE WHEN Class.IsPrintSeatLabel = 1 THEN Seat.SeatLabel ELSE '' END) SeatLabel,
	Seat.StatusType,
	Show.ScreenNo,
	Show.ScreenName,
	Show.MovieName,
	Show.MovieCensorRatingType,
	Show.MovieLanguageType,
	Show.ShowName,
	Show.ShowTime,
	Class.ClassNo,
	Class.ClassName,
	CASE WHEN @paymentType = 5 THEN 0 ELSE (ISNULL((Select Price From PriceCardDetails where PriceCardId = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Ticket_Amount'), 0) - 
	ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Ticket_Amount_Discount'), 0)) END AS TicketAmount,
	Class.ClassLayoutID,
	Seat.NoBlocks,
	Seat.QuotaType,
	Seat.LastPrintedByID,
	show.IsPrintTicketAmount,
	IsNull(Seat.LastPrintedOn,getdate()) LastPrintedOn,
	Complex.ComplexName,
	Complex.ComplexCity,
	(select COUNT(*) from Screen where ComplexID IN (select complexId from complex where complexid in (select ComplexID from Screen where ScreenID in (select ScreenID from Seat where SeatID IN (SELECT ID FROM #IDs))))) As TotalScreen,
	(select COUNT(*) from Class where ShowID in (select ShowID from Seat where SeatID IN (SELECT ID FROM #IDs))) As TotalClass,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'User_Service_Charge'), 0) END AS UserServiceCharge,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Additional_Tax'), 0) END AS AdditionalTax,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Entertainment_Tax'), 0) END AS EntertainmentTax,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select ValueByCalculationType From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'CGST'), 0) END AS CGSTPercent,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'CGST'), 0) END AS CGST,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select ValueByCalculationType From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'SGST'), 0) END AS SGSTPercent,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'SGST'), 0) END AS SGST,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Maintenance_Charge'), 0) END AS MaintenanceCharge,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select ValueByCalculationType From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'User_Service_Charge_CGST_6_Per'), 0) END AS UscCGST,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select ValueByCalculationType From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'User_Service_Charge_SGST_6_Per'), 0) END AS UscSGST,

	CASE WHEN @paymentType = 5 THEN 0 ELSE 
	(ISNULL((Select Price From PriceCardDetails where PriceCardId = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = '3D_Glasses'), 0) - 
	ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = '3D_Glasses_Discount'), 0)) END AS ThreeDPrice,
	ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Base_3D_Glass_Fee'), 0) AS ThreeDNet,
	ISNULL((Select ValueByCalculationType From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'CGST_3D_Glass'), 0) AS ThreeDCGSTPercent,
	ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'CGST_3D_Glass'), 0) AS ThreeDCGST,
	ISNULL((Select ValueByCalculationType From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'SGST_3D_Glass'), 0) AS ThreeDSGSTPercent,
	ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'SGST_3D_Glass'), 0) AS ThreeDSGST,
	(Select CASE WHEN COUNT(PriceCardId) > 0 THEN 1 ELSE 0 END From PriceCardDetails where PriceCardId = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND (Code = 'Concession' OR Code = 'Concession_Discount')) AS ConcessionCount,
	CASE WHEN @paymentType = 5 THEN 0 ELSE 
	(ISNULL((Select Price From PriceCardDetails where PriceCardId = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Concession'), 0) - 
	ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Concession_Discount'), 0)) END AS CocessionPrice,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardId = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Other_Theatre_Charges'), 0) END AS OtherTheatreCharges,
	Show.IsPrintPriceInSlip,
	Seat.PatronInfo,
	Show.Experiences AS Experiences,
	ISNULL((Select PrintSlipSize From Screen where ScreenID =  Seat.ScreenID), 0) AS PrintSlipSize,	
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Base_Ticket_Amount'), 0) END AS BaseTicketAmount,
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Film_Development_Fund'), 0) END AS FilmDevelopmentFund,
	Show.IsPrintSlip,
	ISNULL((Select TicketType From PriceCard where Id = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end), 0) As TicketType,
	ISNULL(Complex.GSTIN, '') AS GSTIN,	
	CASE WHEN @paymentType = 5 THEN 0 ELSE ISNULL((Select Price From PriceCardDetails where PriceCardID = case when @priceCardID = 0 then Seat.PriceCardId else @priceCardID end AND Code = 'Flood_Cess'), 0) END AS FloodCess
	FROM Seat INNER JOIN Show ON Seat.ShowID = Show.ShowID INNER JOIN Class ON Seat.ClassID = Class.ClassID INNER JOIN Screen ON Seat.ScreenID = Screen.ScreenID INNER JOIN Complex ON Complex.ComplexId = screen.ComplexId
	WHERE Seat.SeatID IN (SELECT ID FROM #IDs)
	ORDER BY Seat.SeatID
		
	DROP TABLE #IDs
END
GO

/* [PerformanceReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[PerformanceReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[PerformanceReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PerformanceReport '06-01-2016', '06-14-2016', 0
CREATE PROCEDURE [dbo].[PerformanceReport]
(
	@startDate VARCHAR(10),
	@endDate VARCHAR(10),
	@screenId INT
)
AS
BEGIN
	DECLARE @totalBOAdmits AS DECIMAL = 0;
	DECLARE @totalComps AS DECIMAL = 0;
	DECLARE @txnWithTkts AS DECIMAL = 0;
	DECLARE @txnWithFB AS DECIMAL = 0;
	DECLARE @totalBOSeats AS DECIMAL = 0;
	DECLARE @totalBOSessions AS DECIMAL = 0;
	DECLARE @grandFBQty AS NUMERIC(9,2) = 0;
	DECLARE @grandFBNetProfit AS NUMERIC(9,2) = 0;
	DECLARE @netSalesBO AS NUMERIC(9,2) = 0;
	DECLARE @grossSalesBO AS NUMERIC(9,2) = 0;
	DECLARE @netSundriesBO AS NUMERIC(9,2) = 0;
	DECLARE @grossSundriesBO AS NUMERIC(9,2) = 0;
	DECLARE @netSalesFB AS NUMERIC(9,2) = 0;
	DECLARE @grossSalesFB AS NUMERIC(9,2) = 0;
	DECLARE @netCostFB AS NUMERIC(9,2) = 0;
	DECLARE @grossCostFB AS NUMERIC(9,2) = 0;

	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT * FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) >= CONVERT(DATETIME, @startDate, 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 110) AND IsCancel = 0 AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END
		UNION ALL
		SELECT * FROM ShowMIS WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) >= CONVERT(DATETIME, @startDate, 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 110) AND IsCancel = 0 AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT * FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT * FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
		
	SELECT @totalBOAdmits = COUNT(SeatId) FROM #SeatMasterByDate WHERE StatusType IN (2,3);
	SELECT @totalComps = COUNT(SeatId) FROM #SeatMasterByDate WHERE StatusType IN (2,3) AND PaymentType = 5;
	SELECT @txnWithTkts = COUNT(DISTINCT TicketID) FROM #SeatMasterByDate WHERE StatusType IN (2,3);
	
	SELECT @grossSalesBO = SUM(ISNULL(M.TA, 0))
	FROM
	(
		SELECT (ISNULL((SELECT SUM(ISNULL(PCD.Price, 0)) FROM #SeatMasterByDate SM LEFT JOIN PriceCardDetails PCD ON SM.PriceCardId = PCD.PriceCardId
			WHERE SM.StatusType IN (2,3) AND SM.PaymentType <> 5 AND PCD.Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT SUM(ISNULL(PCD.Price, 0)) FROM #SeatMasterByDate SM LEFT JOIN PriceCardDetails PCD ON SM.PriceCardId = PCD.PriceCardId
			WHERE SM.StatusType IN (2,3) AND SM.PaymentType <> 5 AND PCD.Code = 'Ticket_Amount_Discount'), 0)) TA
	)M;
	
	SELECT @netSalesBO = SUM(ISNULL(M.BTA, 0))
	FROM
	(
		SELECT (SELECT ISNULL(SUM(ISNULL(Price, 0)), 0) FROM PriceCardDetails WHERE PriceCardId = #SeatMasterByDate.PriceCardId AND Code = 'Base_Ticket_Amount') BTA
		FROM #SeatMasterByDate WHERE PaymentType <> 5 AND StatusType IN (2,3)
	)M;
	
	SELECT @grossSundriesBO = (SUM(ISNULL(M.G, 0)) - SUM(ISNULL(M.GD, 0)))
	FROM
	(
		SELECT
			(SELECT ISNULL(SUM(ISNULL(Price, 0)), 0) FROM PriceCardDetails WHERE PriceCardId = #SeatMasterByDate.PriceCardId AND Code = '3D_Glasses') G,
			(SELECT ISNULL(SUM(ISNULL(Price, 0)), 0) FROM PriceCardDetails WHERE PriceCardId = #SeatMasterByDate.PriceCardId AND Code = '3D_Glasses_Discount') GD 
		FROM #SeatMasterByDate WHERE PaymentType <> 5 AND StatusType IN (2,3)
	)M;

	SELECT @netSundriesBO = SUM(ISNULL(M.Base, 0))
	FROM
	(
		SELECT
			(SELECT ISNULL(SUM(ISNULL(Price, 0)), 0) FROM PriceCardDetails WHERE PriceCardId = #SeatMasterByDate.PriceCardId AND Code = 'Base_3D_Glass_Fee') Base
		FROM #SeatMasterByDate WHERE PaymentType <> 5 AND StatusType IN (2,3)
	)M;
	
	Select @totalBOSeats = COUNT(SeatLayoutID) FROM SeatLayout WHERE SeatType <> 1 AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END
	
	SELECT ISNULL(MovieName, 'Grand Total') MovieName, Sessions, Admits [Paid Admits], Comps [Free Tickets], Net, Gross, ROUND(CAST([Occupancy %] AS NUMERIC(9, 2)), 2)[Occupancy %], ROUND(CAST(ATP AS NUMERIC(9, 2)), 2)ATP
	INTO #TempMovie
	FROM
	(
		SELECT MovieName, SUM(Sessions) Sessions, SUM(Admits) Admits, SUM(Comps) Comps, SUM(Net) Net, SUM(Gross) Gross, (CASE WHEN SUM(Occupancy) <> 0 THEN ((SUM(Admits) + SUM(Comps)) / (SUM(Occupancy) + SUM(Sessions))) * 100 ELSE 0 END)[Occupancy %], (CASE WHEN SUM(Admits) <> 0 OR SUM(Comps) <> 0 THEN SUM(Gross) / (SUM(Admits) + SUM(Comps)) ELSE 0 END)ATP
		FROM
		(
			SELECT MovieName, Sessions, Admits, Comps, Net, Gross, ROUND((CASE WHEN ISNULL(occupancy, 0) > 0 THEN (ROUND(CAST((ISNULL(admits, 0) + ISNULL(Comps, 0)) * 100 AS NUMERIC(9, 2)), 2)) / ROUND(CAST(ISNULL(occupancy, 0) AS NUMERIC(9, 2)), 2) ELSE 0 END), 2) [Occupancy %], ATP, ROUND(CAST(ISNULL(occupancy, 0) AS NUMERIC(9, 2)), 2) Occupancy
			FROM
			(
				SELECT
					MovieName
					,SUM(Sessions) Sessions
					,SUM(Admits) Admits
					,SUM(Comps) Comps
					,SUM(Net) Net
					,SUM(Gross) Gross
					,(SELECT COUNT(SeatId) FROM #SeatMasterByDate WHERE ShowId IN (SELECT ShowId FROM #ShowMasterByDate WHERE MovieName = M.MovieName)) Occupancy
					,(CASE WHEN SUM(Gross) <> 0 THEN (SUM(Admits) + SUM(Comps)) / SUM(Gross) ELSE 0 END) ATP
				FROM
					(
						SELECT
							Sh.MovieName
							,(SELECT COUNT(DISTINCT ShowID) FROM #SeatMasterByDate WHERE ShowID = Sh.ShowID) Sessions
							,(SELECT COUNT(SeatId) FROM #SeatMasterByDate WHERE ShowID = Sh.ShowID AND StatusType IN (2,3) AND PaymentType <> 5) Admits
							,(SELECT COUNT(SeatId) FROM #SeatMasterByDate WHERE ShowID = Sh.ShowID AND StatusType IN (2,3) AND PaymentType = 5) Comps 
							,ROUND(ISNULL((SELECT SUM(PCD.Price) FROM #SeatMasterByDate SM LEFT JOIN PriceCardDetails PCD ON SM.PriceCardId = PCD.PriceCardId
								WHERE SM.ShowID = Sh.ShowID AND SM.StatusType IN (2,3) AND SM.PaymentType <> 5 AND PCD.Code = 'Base_Ticket_Amount'), 0), 2)	Net
							,ROUND(ISNULL((SELECT SUM(PCD.Price) FROM #SeatMasterByDate SM LEFT JOIN PriceCardDetails PCD ON SM.PriceCardId = PCD.PriceCardId
								WHERE SM.ShowID = Sh.ShowID AND SM.StatusType IN (2,3) AND SM.PaymentType <> 5 AND PCD.Code = 'Ticket_Amount'), 0) - 
									ISNULL((SELECT SUM(PCD.Price) FROM #SeatMasterByDate SM LEFT JOIN PriceCardDetails PCD ON SM.PriceCardId = PCD.PriceCardId
								WHERE SM.ShowID = Sh.ShowID AND SM.StatusType IN (2,3) AND SM.PaymentType <> 5 AND PCD.Code = 'Ticket_Amount_Discount'), 0), 2)	Gross
						FROM
							#ShowMasterByDate Sh
					)M
					GROUP BY M.MovieName
				)Final
			)F
			GROUP BY ROLLUP(F.MovieName)
		)AS T;
	
	SELECT @totalBOSessions = Sessions FROM #TempMovie WHERE MovieName = 'Grand Total'
	SELECT * FROM #TempMovie;
	
	IF @screenId = 0
	BEGIN
		SELECT
			[Item Class],
			[Item Name],
			SUM(Quantity) Quantity,
			[Net Amount] [Net Amount per item],
			[Gross Amount] [Selling Price per item],
			([Net Amount] - Cost) [Standard Profit],
			CASE WHEN [Net Amount] > 0 THEN ROUND(CAST(ISNULL((([Net Amount] - Cost) / [Net Amount]) * 100, 0) AS NUMERIC(9,2)), 2) ELSE 0 END [Standard Profit %],
			SUM([Total Net Amount]) [Net Sales],
			SUM([Total Gross Amount]) [Gross Sales],
			CAST(0 AS NUMERIC(9,2)) [Sales Mix %],
			SUM(Quantity) * ([Net Amount] - Cost) [Net Profit],
			CAST(0 AS NUMERIC(9,2)) [Profit Mix %],
			Cost,
			SUM(Quantity) * [Net Amount] [TotalNetAmount],
			SUM(Quantity) * [Gross Amount] [TotalGrossAmount],
			SUM(Quantity) * ([Net Amount] - Cost) [TotalStdProfit]
		INTO #FBSales
		FROM
		(
		SELECT ItemID, [Item Class], [Item Name], SUM(Quantity) Quantity, [Net Amount], [Gross Amount], Cost, SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount]
		FROM
		(
			SELECT
				SH.TransactionID,
				I.ItemID,
				(SELECT Expression FROM Type WHERE TypeName = 'ItemClass' AND Value = I.ItemClassID) AS [Item Class], 
				I.ItemName [Item Name],
				SUM(SH.Quantity) - ISNULL(SUM(ICH.Quantity), 0) Quantity,
				IP.NetAmount [Net Amount],
				IP.Price [Gross Amount],
				CASE WHEN SH.ItemStockID = 0 THEN (SELECT SUM(Cost) FROM ItemStock WHERE ItemStockID IN (SELECT ItemStockID FROM ItemPackageSalesHistory WHERE TransactionID = SH.TransactionID))
				ELSE (SELECT Cost FROM ItemStock WHERE ItemStockID = SH.ItemStockID) END Cost,
				(SUM(SH.Quantity) - ISNULL(SUM(ICH.Quantity), 0)) * IP.NetAmount [Total Net Amount],
				(SUM(SH.Quantity) - ISNULL(SUM(ICH.Quantity), 0)) * IP.Price [Total Gross Amount]
			FROM
				ItemSalesHistory SH 
			INNER JOIN Items I ON I.ItemID = SH.ItemID 
			INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID
			lEFT JOIN ItemCancelHistory ICH ON ICH.TransactionID = SH.TransactionID AND ICH.ItemID = SH.ItemID AND ICH.ItemStockID = SH.ItemStockID
			WHERE
				SH.PaymentType <> 5
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), SH.SoldOn, 110)) >= CONVERT(DATETIME, @startDate, 110)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), SH.SoldOn, 110)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 110)
				AND (SH.SeatID IS NULL OR (SH.SeatID IS NOT NULL AND IsBlocked = 0))
			GROUP BY SH.TransactionID, I.ItemID, SH.ItemStockID, I.ItemClassID, I.ItemName, SH.Quantity, IP.NetAmount, IP.Price
			)A
		WHERE A.Quantity > 0
		GROUP BY ItemID, [Item Class], [Item Name], [Net Amount], [Gross Amount], Cost

		UNION ALL

		SELECT SH.ItemID, (SELECT Expression FROM Type WHERE TypeName = 'ItemClass' AND Value = I.ItemClassID) AS [Item Class], I.ItemName [Item Name],
			SUM(SH.Quantity)- ISNULL(SUM(ICH.Quantity),0) Quantity, 0 [Net Amount], 0 [Gross Amount],
			CASE WHEN SH.ItemStockID = 0 THEN (SELECT SUM(Cost) FROM ItemStock WHERE ItemStockID IN (SELECT ItemStockID FROM ItemPackageSalesHistory WHERE TransactionID = SH.TransactionID))
			ELSE (SELECT Cost FROM ItemStock WHERE ItemStockID = SH.ItemStockID) END Cost, 0 [Total Net Amount], 0 [Total Gross Amount]
		FROM
			ItemSalesHistory SH INNER JOIN Items I ON I.ItemID = SH.ItemID
			lEFT JOIN ItemCancelHistory ICH ON ICH.TransactionID = SH.TransactionID AND ICH.ItemID = SH.ItemID
		WHERE
			SH.PaymentType = 5
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), SH.SoldOn, 110)) >= CONVERT(DATETIME, @startDate, 110)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), SH.SoldOn, 110)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 110)
			AND (SH.SeatID IS NULL OR (SH.SeatID IS NOT NULL AND IsBlocked = 0))
		GROUP BY SH.TransactionID, SH.ItemID, I.ItemName, I.ItemClassID, SH.ItemStockID
		)A
		WHERE A.Quantity > 0
		GROUP BY [Item Class], [Item Name], [Net Amount], [Gross Amount], Cost
		
		SELECT @grandFBQty = SUM(Quantity), @grandFBNetProfit = SUM([Net Profit]) FROM #FBSales
		
		UPDATE
			#FBSales
		SET
			[Sales Mix %] = CASE WHEN @grandFBQty > 0 THEN ROUND(CAST(ISNULL((Quantity / @grandFBQty) * 100, 0) AS NUMERIC(9,2)), 2) ELSE 0 END,
			[Profit Mix %] = CASE WHEN @grandFBNetProfit <> 0 THEN ROUND(CAST(ISNULL(([Net Profit] / @grandFBNetProfit) * 100, 0) AS NUMERIC(9,2)), 2) ELSE 0 END
			
		SELECT
			[Item Class],
			[Item Name],
			ISNULL(Quantity, 0) Quantity,
			ISNULL([Net Amount per item], 0) [Net Amount per item],
			ISNULL([Selling Price per item], 0) [Selling Price per item],
			ISNULL([Standard Profit], 0) [Standard Profit],
			ISNULL([Standard Profit %], 0) [Standard Profit %],
			ISNULL([Net Sales], 0) [Net Sales],
			ISNULL([Sales Mix %], 0) [Sales Mix %],
			ISNULL([Net Profit], 0) [Net Profit],
			ISNULL([Profit Mix %], 0) [Profit Mix %]
		FROM
			#FBSales
		ORDER BY [Item Class]
		
		SELECT
			[Item Class] + ' Totals' [Item Class],
			''[Item Name],
			SUM(Quantity) Quantity,
			ROUND(CAST(SUM([TotalNetAmount])/SUM(Quantity) AS NUMERIC(9,2)), 2) [Net Amount per item],
			ROUND(CAST(SUM([TotalGrossAmount])/SUM(Quantity) AS NUMERIC(9,2)), 2) [Selling Price per item],
			ROUND(CAST(SUM([TotalStdProfit])/SUM(Quantity) AS NUMERIC(9,2)), 2) [Standard Profit],
			CASE WHEN SUM([TotalNetAmount]) > 0 THEN ROUND(CAST(((SUM([TotalStdProfit])/SUM(Quantity)) / (SUM([TotalNetAmount])/SUM(Quantity))) * 100 AS NUMERIC(9,2)), 2) ELSE 0 END [Standard Profit %],
			SUM([Net Sales]) [Net Sales],
			SUM([Gross Sales]) [Gross Sales],
			SUM([Sales Mix %]) [Sales Mix %],
			SUM([Net Profit]) [Net Profit],
			CASE WHEN @grandFBNetProfit <> 0 THEN ROUND(CAST(ISNULL((SUM([Net Profit]) / @grandFBNetProfit) * 100, 0) AS NUMERIC(9,2)), 2) ELSE 0 END [Profit Mix %],
			ROUND(CAST(SUM([TotalNetAmount])/SUM(Quantity) AS NUMERIC(9,2)), 2) * SUM(Quantity) [TotalNetAmount],
			ROUND(CAST(SUM([TotalGrossAmount])/SUM(Quantity) AS NUMERIC(9,2)), 2) * SUM(Quantity) [TotalGrossAmount],
			ROUND(CAST(SUM([TotalStdProfit])/SUM(Quantity) AS NUMERIC(9,2)), 2) * SUM(Quantity) [TotalStdProfit]
		INTO #FBSalesGrand
		FROM
			#FBSales
		GROUP BY [Item Class]
		ORDER BY [Item Class]
		
		SELECT
			[Item Class],
			[Item Name],
			ISNULL(Quantity, 0) Quantity,
			ISNULL([Net Amount per item], 0) [Net Amount per item],
			ISNULL([Selling Price per item], 0) [Selling Price per item],
			ISNULL([Standard Profit], 0) [Standard Profit],
			ISNULL([Standard Profit %], 0) [Standard Profit %],
			ISNULL([Net Sales], 0) [Net Sales],
			ISNULL([Sales Mix %], 0) [Sales Mix %],
			ISNULL([Net Profit], 0) [Net Profit],
			ISNULL([Profit Mix %], 0) [Profit Mix %]
		FROM
			#FBSalesGrand
		
		SELECT
			'Grand Totals' [Item Class],
			''[Item Name],
			ISNULL(SUM(Quantity), 0) Quantity,
			ROUND(CAST(ISNULL(SUM([TotalNetAmount])/SUM(Quantity), 0) AS NUMERIC(9,2)), 2) [Net Amount per item],
			ROUND(CAST(ISNULL(SUM([TotalGrossAmount])/SUM(Quantity), 0) AS NUMERIC(9,2)), 2) [Selling Price per item],
			ROUND(CAST(ISNULL(SUM([TotalStdProfit])/SUM(Quantity), 0) AS NUMERIC(9,2)), 2) [Standard Profit],
			CASE WHEN SUM([TotalNetAmount]) > 0 THEN ROUND(CAST(ISNULL(((SUM([TotalStdProfit])/SUM(Quantity)) / (SUM([TotalNetAmount])/SUM(Quantity))) * 100, 0) AS NUMERIC(9,2)), 2) ELSE 0 END [Standard Profit %],
			ISNULL(SUM([Net Sales]), 0) [Net Sales],
			ISNULL(SUM([Sales Mix %]), 0) [Sales Mix %],
			ISNULL(SUM([Net Profit]), 0) [Net Profit],
			CASE WHEN @grandFBNetProfit <> 0 THEN ROUND(CAST(ISNULL((SUM([Net Profit]) / @grandFBNetProfit) * 100, 0) AS NUMERIC(9,2)), 2) ELSE 0 END [Profit Mix %]
		FROM
			#FBSalesGrand
		
		SELECT
			@txnWithFB = COUNT(DISTINCT TransactionID)
		FROM
			ItemSalesHistory
		WHERE
			CONVERT(DATETIME, CONVERT(VARCHAR(10), SoldOn, 110)) >= CONVERT(DATETIME, @startDate, 110)
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), SoldOn, 110)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 110)
		
		SELECT @netSalesFB = SUM([Net Sales]), @grossSalesFB = SUM([Gross Sales]), @netCostFB = SUM([Net Sales]) - SUM([Net Profit]), @grossCostFB = SUM([Gross Sales]) - SUM([Net Profit]) FROM #FBSalesGrand
		
		Drop Table #FBSales
		Drop Table #FBSalesGrand
	END
	
	SELECT
		ISNULL(@totalBOAdmits, 0)
		,ISNULL(@totalComps, 0)
		,ISNULL(@txnWithTkts, 0)
		,ISNULL(@txnWithFB, 0)
		,ISNULL(@grandFBQty, 0)
		,ISNULL(@netSalesBO, 0)
		,ISNULL(@grossSalesBO, 0)
		,ISNULL(@netSundriesBO, 0)
		,ISNULL(@grossSundriesBO, 0)
		,ISNULL(@netSalesFB, 0)
		,ISNULL(@grossSalesFB, 0)
		,ISNULL(@netCostFB, 0)
		,ISNULL(@grossCostFB, 0)
		,ISNULL(@totalBOSeats, 0)
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@grandFBQty/@totalBOAdmits, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@txnWithFB, 0) > 0 THEN CAST(ISNULL(@grandFBQty/@txnWithFB, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL((@totalBOSeats * @totalBOSessions), 0) > 0 THEN CAST(ISNULL(@totalBOAdmits * 100/(@totalBOSeats * @totalBOSessions), 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@txnWithFB * 100/@totalBOAdmits, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@txnWithTkts, 0) > 0 THEN CAST(ISNULL(@txnWithFB * 100/@txnWithTkts, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@netSalesFB/@totalBOAdmits, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@grossSalesFB/@totalBOAdmits, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@grandFBQty, 0) > 0 THEN CAST(ISNULL(@netSalesFB/@grandFBQty, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@grandFBQty, 0) > 0 THEN CAST(ISNULL(@grossSalesFB/@grandFBQty, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@txnWithFB, 0) > 0 THEN CAST(ISNULL(@netSalesFB/@txnWithFB, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@txnWithFB, 0) > 0 THEN CAST(ISNULL(@grossSalesFB/@txnWithFB, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@netSalesBO/@totalBOAdmits, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@grossSalesBO/@totalBOAdmits, 0) AS NUMERIC(9,2))	 ELSE 0 END	
		,CASE WHEN ISNULL((@totalBOAdmits-@totalComps), 0) > 0 THEN CAST(ISNULL(@netSalesBO/(@totalBOAdmits-@totalComps), 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL((@totalBOAdmits-@totalComps), 0) > 0 THEN CAST(ISNULL(@grossSalesBO/(@totalBOAdmits-@totalComps), 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@netSalesBO/@totalBOSeats, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL(@grossSalesBO/@totalBOSeats, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL((@netSalesBO + @netSundriesBO + @netSalesFB)/@totalBOSeats, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL((@grossSalesBO + @grossSundriesBO + @grossSalesFB)/@totalBOSeats, 0) AS NUMERIC(9,2)) ELSE 0 END
		,ISNULL(@netSalesFB - @netCostFB, 0)
		,CASE WHEN ISNULL(@netSalesFB, 0) > 0 THEN CAST(ISNULL((@netSalesFB - @netCostFB) * 100/@netSalesFB, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@grandFBQty, 0) > 0 THEN CAST(ISNULL((@netSalesFB - @netCostFB)/@grandFBQty, 0) AS NUMERIC(9,2)) ELSE 0 END
		,CASE WHEN ISNULL(@totalBOAdmits, 0) > 0 THEN CAST(ISNULL((@netSalesFB - @netCostFB)/@totalBOAdmits, 0) AS NUMERIC(9,2)) ELSE 0 END

	Drop Table #SeatMasterByDate
	Drop Table #ShowMasterByDate
	Drop Table #TempMovie	
	
	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip, ComplexPhone, CASE WHEN @screenId = 0 THEN 'All' ELSE (SELECT ScreenName FROM Screen WHERE ScreenID = @screenId) END ScreenName FROM Complex
End
GO

/* [spHeadLoad] */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spHeadLoad]
	@HEADID INT
AS
	SELECT
		id,
		Name
	FROM ItemHeads
	WHERE id = @HEADID
GO
/****** Object:  StoredProcedure [dbo].[spHEADEdit]    Script Date: 10/13/2014 10:16:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spHEADEdit]
	@HEADID INT,
	@HEADName VARCHAR(32)
AS
	UPDATE ItemHeads
	SET Name = @HEADName
		
	WHERE id = @HEADID
GO
/****** Object:  StoredProcedure [dbo].[spHEADDelete]    Script Date: 10/13/2014 10:16:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spHEADDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spHEADDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[spHEADDelete]
	@HEADID INT,
	@ReferredBy VARCHAR(32) OUTPUT
AS
	SET @ReferredBy = ''
	IF EXISTS ( SELECT NULL FROM Item WHERE HeadID = @HEADID )
		SET @ReferredBy = 'Item'
	
	If @ReferredBy = ''
	BEGIN
		DELETE FROM ItemHeads
		WHERE ID = @HEADID
	END
GO
/****** Object:  StoredProcedure [dbo].[spHEADAdd]    Script Date: 10/13/2014 10:16:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spHEADAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spHEADAdd]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spHEADAdd]
	@HEADID INT OUTPUT,
	@HEADName VARCHAR(64)
AS
	INSERT INTO ItemHeads (
		name
	) VALUES (
		@HEADName
	) SET @HEADID = SCOPE_IDENTITY()
GO



/* MarketingReport */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MarketingReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[MarketingReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec MarketingReport @StartDate='2-5-2015',@EndDate='2-5-2015',@ScreenId=0,@ValueType=2
CREATE Procedure [dbo].[MarketingReport]
(
	@StartDate Varchar(10)='',
	@EndDate Varchar(10)='',
	@ScreenId Int=0,
	@ValueType Int=1
)
As
Begin
	Declare @Occupancy as decimal=0;Declare @BoAdmits as decimal=0;Declare @PaidAdmits as decimal=0;Declare @Redemptions as decimal;Declare @RedemptionsPerc as decimal=0;Declare @Comps as decimal=0;Declare @TxnwithTkts as decimal=0;Declare @TxnwithConc as decimal=0;Declare @QntofItems as decimal=0;Declare @RedemptionsvsSales as decimal=0;
	Declare @BoSalesGross as decimal=0;Declare @BoSalesNet as decimal=0;Declare @BoVoucherGross as decimal=0;Declare @BoVoucherNet as decimal=0;
	Declare @BoSundriesAdmits as decimal=0;Declare @BoSundriesGross as decimal=0;Declare @BoSundriesNet as decimal=0;Declare @ConcSalesGross as decimal=0;Declare @ConcSalesNet as decimal=0;
	Declare @ConcCostGross as decimal=0;Declare @ConcCostNet as decimal=0;Declare @Seats as decimal=0;
	Declare @ProfitStdCost as decimal=0;Declare @Avgspendconcperguest as decimal=0;

	--Screen
	CREATE TABLE #TempScreenMaster(
	[ScreenID] [int],
	[ScreenNo] [varchar](2),
	[Code] [varchar](2),
	[ScreenName] [nvarchar](256),
	[IsFoodBeverages] [bit],
	[IsAdvanceToken] [bit],
	[IsDisplaySeatNos] [bit],
	[ComplexID] [int],
	[ScreenGUID] [varchar](64),
	[IsPrintTicketAmount] [bit]);
	
	IF(@ScreenId>0)
	BEGIN
		TRUNCATE TABLE #TempScreenMaster;
		INSERT INTO #TempScreenMaster ([ScreenId]
		,[ScreenNo]
		,[Code]
		,[ScreenName]
		,[IsFoodBeverages]
		,[IsAdvanceToken]
		,[IsDisplaySeatNos]
		,[ComplexID]
		,[ScreenGUID]
		,[IsPrintTicketAmount]) 
		SELECT 
		[ScreenId]
		,[ScreenNo]
		,[Code]
		,[ScreenName]
		,[IsFoodBeverages]
		,[IsAdvanceToken]
		,[IsDisplaySeatNos]
		,[ComplexID]
		,[ScreenGUID]
		,[IsPrintTicketAmount] FROM Screen WHERE ScreenId=@ScreenId
	END
	ELSE
	BEGIN
		TRUNCATE TABLE #TempScreenMaster;
		INSERT INTO #TempScreenMaster ([ScreenId]
		,[ScreenNo]
		,[Code]
		,[ScreenName]
		,[IsFoodBeverages]
		,[IsAdvanceToken]
		,[IsDisplaySeatNos]
		,[ComplexID]
		,[ScreenGUID]
		,[IsPrintTicketAmount]) 
		SELECT 
		[ScreenId]
		,[ScreenNo]
		,[Code]
		,[ScreenName]
		,[IsFoodBeverages]
		,[IsAdvanceToken]
		,[IsDisplaySeatNos]
		,[ComplexID]
		,[ScreenGUID]
		,[IsPrintTicketAmount] FROM Screen
	END


	--Seat Union with SeatMIS
	Select * into #TempSeatMaster from  (Select * from Seat where seattype<>1 and ShowID in (select ShowID from Show  where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster)) 
	Union All Select * from SeatMIS where seattype<>1 and ShowID in (select ShowID from ShowMIS where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster))) As TempSeatMaster

	--Show Union with ShowMIS
	Select * into #TempShowMaster from  (Select * From Show where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster) Union All Select * From ShowMIS where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster)) As TempShowMaster

	--Class Union with ClassMIS
	Select * into #TempClassMaster from  (Select * From Class where ShowID in (select ShowID from Show where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster)) Union All Select * From ClassMIS where ShowID in (select ShowID from ShowMIS where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster))) As TempClassMaster


	--Canteen Union with CanteenMIS
	Select * into #TempCanteenMaster from  (Select * From Canteen where BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate) Union All Select * From CanteenMIS where BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) As TempCanteenMaster

	Select @BoAdmits=count(Seatid)  from #TempSeatMaster where StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster);
	Select @Comps=count(Seatid)  from #TempSeatMaster where StatusType IN (2,3) and PaymentType=5 and showid in(select ShowID from #TempShowMaster);

	Select @PaidAdmits=count(Seatid) from #TempSeatMaster where StatusType IN (2,3) and PaymentType<>5 and PaymentType<>4 and showid in(select ShowID from #TempShowMaster);


	Select @BoSalesGross=Sum(IsNull(M.TA,0)) from(Select 
	(select IsNull(Sum(IsNull(Amount,0)),0) from PriceCard where Id=#TempSeatMaster.PriceCardId) TA
	from #TempSeatMaster where SeatType<>1 and PaymentType <> 5 
	and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;
	
	Select @BoSalesNet= @BoSalesGross - Sum(IsNull(M.AT,0)) - Sum(IsNull(M.SC,0)) - Sum(IsNull(M.ET,0)) - Sum(IsNull(M.GST,0)) from (Select 
	(select IsNull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and Code='Additional_Tax') AT,
	(select IsNull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and Code='Service_Charge') SC,
	(select IsNull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and Code='Entertainment_Tax') ET,
	(select IsNull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and Code='GST') GST
	from #TempSeatMaster where SeatType<>1 and PaymentType <> 5
	and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;


	if(@ValueType=2)
	begin
	Select @Redemptions=(Sum(Cast(Round(IsNull(M.price,0),2) as Decimal))-SUM(Cast(Round(IsNull(M.discountprice,0),2) as Decimal))) from(Select 
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and (Code='3D_Glasses' or Code='Ticket_Amount') and [Type]='1') price,
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2') discountprice  from #TempSeatMaster where SeatType<>1 and PaymentType=4 and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;
	end
	else
	begin
	Select @Redemptions=(Sum(Cast(Round(IsNull(M.price,0),2) as Decimal))-SUM(Cast(Round(IsNull(M.discountprice,0),2) as Decimal))) from(Select (select IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1') price,(select IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2') discountprice  from #TempSeatMaster where SeatType<>1 and PaymentType=4 and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;
	end

	if(@ValueType=2)
	begin
	Select @RedemptionsPerc=(case when @BoSalesNet>0 then (@Redemptions/@BoSalesNet)*100 else 0 end);
	end
	else
	begin
	Select @RedemptionsPerc=(case when @BoSalesGross>0 then (@Redemptions/@BoSalesGross)*100 else 0 end);
	end

	Select @ConcSalesNet=Sum(IsNull(Price,0)*IsNull(Quantity,0))  from #TempCanteenMaster;
	Select @ConcSalesGross=Sum((IsNull(Price,0)+IsNull(Tax,0)+IsNull(VAT,0))*IsNull(Quantity,0))  from #TempCanteenMaster;
	Select @ConcCostNet=Sum(IsNull(IT.Cost,0)) from #TempCanteenMaster CN left join Item IT on IT.ItemID =CN.ItemID;
	Select @ConcCostGross=Sum(IsNull(IT.Cost,0)) from #TempCanteenMaster CN left join Item IT on IT.ItemID =CN.ItemID;
	Select @TxnwithConc=count(distinct BillID)  from #TempCanteenMaster ;
	Select @QntofItems=Sum(Quantity)  from #TempCanteenMaster;

	select @BoSundriesAdmits=Count(*)  from #TempSeatMaster where SeatType<>1 and PaymentType=0 and StatusType IN (2,3) and priceCardId in (select PriceCardid from PriceCardDetails where Code='3D_Glasses') and showid in(select ShowID from #TempShowMaster);
	
	Select @BoSundriesGross=(Sum(IsNull(M.G,0))-SUM(IsNull(M.GD,0))) from(Select 
	(select IsNull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and Code='3D_Glasses') G,
	(select IsNull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and Code='3D_Glasses_Discount') GD 
	from #TempSeatMaster where SeatType<>1 and PaymentType <> 5 
	and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;
	
	Select @BoSundriesNet= @BoSundriesGross

	Select @TxnwithTkts=count(distinct TicketID)  from #TempSeatMaster where StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster);

	Select @Seats=count(SeatLayoutid)  from SeatLayout where ScreenID in (select ScreenId from #TempScreenMaster);

	Select @Occupancy=count(Seatid)  from #TempSeatMaster where SeatType<>1 and showid in(select ShowID from #TempShowMaster);

	Select @BoVoucherNet=(Sum(IsNull(M.price,0))-SUM(IsNull(M.discountprice,0))) from(Select (select top(1) IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and (Code='3D_Glasses' or Code='Ticket_Amount') and [Type]='1') price,(select top(1) IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2') discountprice  from #TempSeatMaster where SeatType<>1 and PaymentType=4 and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;
	Select @BoVoucherGross=(Sum(IsNull(M.price,0))-SUM(IsNull(M.discountprice,0))) from(Select (select IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1') price,(select IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2') discountprice  from #TempSeatMaster where SeatType<>1 and PaymentType=4 and StatusType IN (2,3) and showid in(select ShowID from #TempShowMaster))M;
	Select @ProfitStdCost=Sum(IsNull(t.Quantity,0)*(case when (isNull(i.Cost,0)>0) then (IsNull(t.Price,0)+IsNull(t.Tax,0)+IsNull(t.VAT,0))-isNull(i.Cost,0) else 0 end))  from #TempCanteenMaster t left join Item i on t.ItemID=i.ItemID;
	Select @Avgspendconcperguest=Sum((IsNull(Price,0)+IsNull(Tax,0)+IsNull(VAT,0))*IsNull(Quantity,0)) from #TempCanteenMaster where PaymentType=5;


select MovieName,Sessions,Admits,Comps,Net,Gross,Round(Cast([Occupancy %] as numeric(9,2)),2)[Occupancy %],Round(Cast(ATP as numeric(9,2)),2)ATP into #TempMovie from 
	
	( select MovieName,Sum(Sessions)Sessions,Sum(Admits)Admits,Sum(Comps)Comps,Sum(Net)Net,Sum(Gross)Gross, (case when sum(Occupancy) <> 0 then ((SUM(Admits) + Sum(Comps))/SUM(Occupancy) * 100)else 0 end)[Occupancy %],(case when sum(Admits) <> 0 then SUM(Gross)/SUM(Admits) else 0 end)ATP from
	
	(Select MovieName,Sessions,Admits,Comps,Net,Gross,Round((case when isnull(occupancy,0)>0 then 
	(Round(cast((isnull(admits,0)+isnull(Comps,0))*100 as numeric(9,2)),2))/Round(cast(isnull(occupancy,0) as numeric(9,2)),2) else 0 end),2) [Occupancy %],ATP, Round(cast(isnull(occupancy,0) as numeric(9,2)),2) Occupancy from
	
	(select IsNull(MovieName,'Grand Total')MovieName,SUM(Sessions)Sessions,SUM(Admits)Admits,SUM(Comps)Comps,SUM(Net)Net,SUM(Gross)Gross
	,(Select Count(SeatId) from #TempSeatMaster where ShowId in (select showid from #TempShowMaster where MovieName=M.MovieName)) Occupancy
	--,SUM(isnull(Admits,0))+SUM(isnull(Comps,0)) Occupancy
	,(case when sum(Gross) <> 0 then SUM(Admits)/SUM(Gross) else 0 end) ATP from (Select Sh.MovieName
	,(select COUNT(distinct ShowID) from #TempSeatMaster where ShowID=sh.ShowID) Sessions
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) and PaymentType<>5) Admits 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) and PaymentType=5) Comps 		
	,Round(Isnull((Select Sum(pc.amount) from #TempSeatMaster ts left join pricecard pc on ts.pricecardid = pc.id
	where ts.ShowID=sh.ShowID and ts.StatusType IN (2,3) and ts.PaymentType <> 5),0),2)
	-Round(Isnull((Select Sum(pcd.price) from #TempSeatMaster ts left join pricecarddetails pcd on ts.pricecardid = pcd.pricecardid
	where ts.ShowID=sh.ShowID and ts.StatusType IN (2,3) and ts.PaymentType <> 5 and pcd.Code='Service_Charge'),0),2)
	-Round(Isnull((Select Sum(pcd.price) from #TempSeatMaster ts left join pricecarddetails pcd on ts.pricecardid = pcd.pricecardid
	where ts.ShowID=sh.ShowID and ts.StatusType IN (2,3) and ts.PaymentType <> 5 and pcd.Code='Entertainment_Tax'),0),2)
	-Round(Isnull((Select Sum(pcd.price) from #TempSeatMaster ts left join pricecarddetails pcd on ts.pricecardid = pcd.pricecardid
	where ts.ShowID=sh.ShowID and ts.StatusType IN (2,3) and ts.PaymentType <> 5 and pcd.Code='GST'),0),2)
	-Round(Isnull((Select Sum(pcd.price) from #TempSeatMaster ts left join pricecarddetails pcd on ts.pricecardid = pcd.pricecardid
	where ts.ShowID=sh.ShowID and ts.StatusType IN (2,3) and ts.PaymentType <> 5 and pcd.Code='Additional_Tax'),0),2)
	Net
	,Round(Isnull((Select Sum(pc.amount) from #TempSeatMaster ts left join pricecard pc on ts.pricecardid = pc.id
	where ts.ShowID=sh.ShowID and ts.StatusType IN (2,3) and ts.PaymentType <> 5),0),2)
	Gross
	from #TempShowMaster Sh)M	
	group by M.MovieName)
	Final)
	F group by Rollup(F.MovieName))
	 As T ;

	select MovieName,(select top(1) min(Convert(varchar(10),showtime,105)) from #TempShowMaster where MovieName=#TempMovie.movieName)[Opening Date],1+DATEPART( wk, getdate())-DATEPART( wk, (select top(1) min(showtime) from #TempShowMaster where MovieName=#TempMovie.movieName))[Week of Play],Sessions,Admits,Comps,Net,Gross,[Occupancy %],ATP from #TempMovie;

	Select (case when @ValueType=2 then IsNull(@BoSalesNet,0) else IsNull(@BoSalesGross,0) end) BOSales
	,IsNull(@BoAdmits,0) BoAdmits
	,IsNull(@Comps,0) Comps
	,IsNull(@PaidAdmits,0) PaidAdmits
	,IsNull(@TxnwithTkts,0) TxnwithTkts
	,IsNull(@RedemptionsPerc/100,0) Redemptions
	,IsNull(@RedemptionsPerc,0) RedemptionsPerc
	, (case when @ValueType=2 then IsNull(@ConcSalesNet,0) else IsNull(@ConcSalesGross,0) end) ConcSales
	,IsNull(@QntofItems,0) QntofItems
	,IsNull(@TxnwithConc,0) TxnwithConc
	, (case when @ValueType=2 then IsNull(@BoVoucherNet,0) else IsNull(@BoVoucherGross,0) end) VocherSales
	, (case when @ValueType=2 then (case when IsNull(@BoSalesNet,0)>0 then (IsNull(@BoVoucherNet,0)/IsNull(@BoSalesNet,0))*100 else 0 end) else (case when IsNull(@BoSalesGross,0)>0 then (IsNull(@BoVoucherGross,0)/IsNull(@BoSalesGross,0))*100 else 0 end) end) RedemptionsvsSales
	, (case when @ValueType=2 then IsNull(@BoSundriesNet,0) else IsNull(@BoSundriesGross,0) end) BOSundries
	,(IsNull(@TxnwithTkts,0)+IsNull(@TxnwithConc,0)) TotalTxn
	,(select [Occupancy %] from #TempMovie where MovieName IS NULL) as Occupancyrate
	, (case when @ValueType=2 then (Case when (isnull(@BoAdmits,0)>0) then IsNull((@BoSalesNet/@BoAdmits),0) else 0 end) else (Case when (@BoAdmits>0) then IsNull((@BoSalesGross/@BoAdmits),0) else 0 end) end) ATPincludecomps
	, (case when @ValueType=2 then (Case when ((isnull(@BoAdmits,0)-isnull(@Comps,0))>0) then IsNull((@BoSalesNet/(isnull(@BoAdmits,0)-isnull(@Comps,0))),0) else 0 end) else (Case when ((isnull(@BoAdmits,0)-isnull(@Comps,0))>0) then IsNull((@BoSalesGross/(isnull(@BoAdmits,0)-isnull(@Comps,0))),0) else 0 end) end) ATPnotincludecomps
	,(case when (isnull(@BoAdmits,0)>0) then (case when @ValueType=2 then IsNull(@ConcSalesNet,0) else IsNull(@ConcSalesGross,0) end)/isnull(@BoAdmits,0) else 0 end)SpendperAdmit
	,(case when (isnull(@PaidAdmits,0)>0) then (case when @ValueType=2 then IsNull(@ConcSalesNet,0) else IsNull(@ConcSalesGross,0) end)/isnull(@PaidAdmits,0) else 0 end)SpendperPaidAdmit
	,IsNull(((Case when (@BoAdmits>0) then @TxnwithConc/@BoAdmits else 0 end)),0) as Admissionstrikerate
	,IsNull(((Case when (@TxnwithTkts>0) then @TxnwithConc/@TxnwithTkts else 0 end)),0) as Txnstrikerate
	,(case when (isnull(@TxnwithConc,0)>0) then (case when @ValueType=2 then IsNull(@ConcSalesNet,0) else IsNull(@ConcSalesGross,0) end)/isnull(@TxnwithConc,0) else 0 end)Avgvalueperconctxn
	,IsNull(@BoSundriesAdmits,0) BoSundriesAdmits
	,IsNull(@BoSundriesNet,0) BoSundriesNet
	,IsNull(@BoSundriesGross,0) BoSundriesGross

	,(Case when ((@BoAdmits-@Comps)>0) then IsNull((@BoSalesNet/(@BoAdmits-@Comps)),0) else 0 end) as ATPnotincludecompsNet
	,(Case when ((@BoAdmits-@Comps)>0) then IsNull((@BoSalesGross/(@BoAdmits-@Comps)),0) else 0 end) as ATPnotincludecompsGross	
	,(Case when (@BoAdmits>0) then IsNull((@BoSalesNet/@BoAdmits),0) else 0 end) as ATPincludecompsNet
	,(Case when (@BoAdmits>0) then IsNull((@BoSalesGross/@BoAdmits),0) else 0 end) as ATPincludecompsGross
	,IsNull(@ConcSalesGross,0) ConcSalesGross
	,Round(IsNull(@Occupancy,0),2) Occupancy	
	,Round(IsNull((Round((Case when @BoAdmits>0 then IsNull(@QntofItems,0)/IsNull(@BoAdmits,0) else 0 end),2)),0),2) as Itemsperhead
	,(Case when (@TxnwithConc>0) then IsNull((IsNull(@QntofItems,0)/IsNull(@TxnwithConc,0)),0) else 0 end) as Itemspertxn
	,(select IsNull(Max([Occupancy %]),0) from #TempMovie) as Occupancyrate
	,IsNull(@BoSalesNet,0) BoSalesNet
	,IsNull(@BoSalesGross,0) BoSalesGross
	,IsNull(@BoVoucherNet,0) BoVoucherNet
	,IsNull(@BoVoucherGross,0) BoVoucherGross
	,IsNull(@ConcCostNet,0) ConcCostNet
	,IsNull(@ConcCostGross,0) ConcCostGross
	,IsNull(@Seats,0) Seats
	,IsNull((Case when @BoAdmits>0 then @ConcSalesNet/@BoAdmits else 0 end),0) as SpendperheadNet
	,IsNull((Case when @BoAdmits>0 then @ConcSalesGross/@BoAdmits else 0 end),0) as SpendperheadGross
	,(Case when (@QntofItems>0) then IsNull((@ConcSalesNet/@QntofItems),0) else 0 end) as AvgpriceperConcNet
	,(Case when (@QntofItems>0) then IsNull((@ConcSalesGross/@QntofItems),0) else 0 end) as AvgpriceperConcGross
	,(Case when (@QntofItems>0) then IsNull((@TxnwithConc/@QntofItems),0) else 0 end) as AvgvalueperConcNet
	,(Case when (@QntofItems>0) then IsNull((@TxnwithConc/@QntofItems),0) else 0 end) as AvgvalueperConcGross
	,(Case when (@BoAdmits>0) then IsNull((@BoSalesNet/@BoAdmits),0) else 0 end) as ATPincludecompsNet
	,(Case when (@BoAdmits>0) then IsNull((@BoSalesGross/@BoAdmits),0) else 0 end) as ATPincludecompsGross
	,(Case when ((@BoAdmits-@Comps)>0) then IsNull((@BoSalesNet/(@BoAdmits-@Comps)),0) else 0 end) as ATPnotincludecompsNet
	,(Case when ((@BoAdmits-@Comps)>0) then IsNull((@BoSalesGross/(@BoAdmits-@Comps)),0) else 0 end) as ATPnotincludecompsGross
	,(Case when (@Seats>0) then IsNull((@BoSalesNet/@Seats),0) else 0 end) as BOrevenueperseatNet
	,(Case when (@Seats>0) then IsNull((@BoSalesGross/@Seats),0) else 0 end) as BOrevenueperseatGross
	,(Case when (@Seats>0) then IsNull(((IsNull(@BoSalesNet,0)+IsNull(@BoSundriesNet,0)+IsNull(@ConcSalesNet,0))/IsNull(@Seats,0)),0) else 0 end) as TotalrevenueperseatNet
	,(Case when (@Seats>0) then IsNull(((IsNull(@BoSalesGross,0)+IsNull(@BoSundriesGross,0)+IsNull(@ConcSalesGross,0))/@Seats),0) else 0 end) as TotalrevenueperseatGross
	,ISNULL(@ProfitStdCost,0) ProfitStdCost
	,(Case when (@ConcSalesNet>0) then ((Round(ISNULL(@ProfitStdCost,0)/@ConcSalesNet,2))*100) else 0 end)AvgProfperc
	,(Case when (@QntofItems>0) then (Round(ISNULL(@ProfitStdCost,0)/@QntofItems,2)) else 0 end)AvgProfperitem
	,(Case when (@BoAdmits>0) then (Round(ISNULL(@ProfitStdCost,0)/@BoAdmits,2)) else 0 end)AvgProfperhead
	,(Case when (@Comps>0) then (Round(ISNULL(@Avgspendconcperguest,0)/@Comps,2)) else 0 end)Avgspendconcperguest;


	select isNull([Payment Type],'*Total')[Payment Type],cast(Value as numeric(9,2)) Value into #TempPaymentType from
	(Select (case when M.PaymentType=0 then 'Cash' when M.PaymentType=1 then 'Online' when M.PaymentType=2 then 'Credit Card' when M.PaymentType=3 then 'Debit Card' when M.PaymentType=4 then 'Coupon' when M.PaymentType=5 then 'Free' else null end)[Payment Type],Sum(M.Price)-Sum(M.discountprice) Value from
	(Select isNull(PaymentType,'*Total')PaymentType,
	(case when @ValueType=2 then 
	(select IsNull(Sum(Price),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and (Code='3D_Glasses' or Code='Ticket_Amount') and [Type]='1') else 
	(select IsNull(Sum(Price),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1') end) price,
	(select IsNull(Sum(Price),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2') discountprice  
	from #TempSeatMaster where SeatType<>1 and StatusType IN (2,3))M group by Rollup(M.PaymentType))Final;	
	select isNull([Payment Type],'*Total')[Payment Type],Value,cast((case when Isnull((select max(Value) from #TempPaymentType),0) >0 then
	Value /(select max(Value) from #TempPaymentType)
	else 0 end)*100 as numeric(9,2)) [Value %] from #TempPaymentType group by [Payment Type],Value order by [Payment Type] desc;
	Drop table #TempPaymentType


	select * into #TempCanteenPaymentType from
	(Select (case when M.PaymentType=0 then 'Cash' when M.PaymentType=1 then 'Online' when M.PaymentType=2 then 'Credit Card' when M.PaymentType=3 then 'Debit Card' when M.PaymentType=4 then 'Coupon' when M.PaymentType=5 then 'Free' else null end)[Payment Type],Sum(M.Price) Value from
	(Select isNull(PaymentType,'*Total')PaymentType,
	(case when @ValueType=2 then Price*Quantity else (Price+Tax+VAT)*Quantity end) price from #TempCanteenMaster)M group by Rollup(M.PaymentType))Final;	
	select isNull([Payment Type],'*Total')[Payment Type],Value,Round(

	(case when Isnull((select max(Value) from #TempCanteenPaymentType),0) >0 then
	Value/(select max(Value) from #TempCanteenPaymentType)
	else 0 end)
	,2)*100[Value %] from #TempCanteenPaymentType group by [Payment Type],Value order by [Payment Type] desc;
	Drop table #TempCanteenPaymentType

	select * into #TempPaymentVoucherType from
	(Select distinct 'Payment Voucher'[Voucher Type],Sum(M.Admits) Admits,Sum(M.Price)-Sum(M.discountprice) Value from
	(Select PaymentType,Count(*) Admits,
	(select IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1') price,
	(select IsNull(isnull(Sum(IsNull(Price,0)),0),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2') discountprice  
	from #TempSeatMaster where SeatType<>1 and PaymentType=4 and StatusType IN (2,3) group by PaymentType,PriceCardId)M group by Rollup(M.PaymentType))Final;	
	select * from #TempPaymentVoucherType order by [Voucher Type] desc;
	Drop table #TempPaymentVoucherType

	select * into #TempPriceCards from(select Top 20
	pc.Name [Ticket Type]
	,((select IsNull(Price,0) from PriceCardDetails where PriceCardid=pc.id and [Type]='1' and Code='Ticket_Amount')-(select IsNull(Sum(Price),0) from PriceCardDetails where PriceCardid=pc.id and [Type]='2' and Code='Ticket_Amount_Discount')) [Average Price]
	,Convert(numeric(9,2),(Select count(seatid) from #TempSeatMaster where StatusType IN (2,3) and pricecardid=pc.id)) [Admits] 
	,(Select count(seatid) from #TempSeatMaster where StatusType IN (2,3) and pricecardid=pc.id)*
	((select IsNull(Price,0) from PriceCardDetails where PriceCardid=pc.id and [Type]='1' and Code='Ticket_Amount')-(select IsNull(Sum(Price),0) from PriceCardDetails where PriceCardid=pc.id and [Type]='2' and Code='Ticket_Amount_Discount')-(select distinct MaintenanceCharge from Show where ShowID in (select ShowID from Seat where PriceCardId = pc.id))) Net
	,(Select count(seatid) from #TempSeatMaster where StatusType IN (2,3) and pricecardid=pc.id)*
	((select IsNull(Price,0) from PriceCardDetails where PriceCardid=pc.id and [Type]='1' and Code='Ticket_Amount')-(select IsNull(Sum(Price),0) from PriceCardDetails where PriceCardid=pc.id and [Type]='2' and Code='Ticket_Amount_Discount')) Gross
	from pricecard pc order by pc.CreatedOn desc)M
	
	select [Ticket Type],[Average Price],[Admits],cast((
	(case when Isnull((Select Sum(Admits) from #TempPriceCards),0) >0 then
	[Admits]/(Select Sum(Admits) from #TempPriceCards)
	else 0 end)
	)*100 as numeric(9,2)) [% Admits mix],IsNull(Net,0) Net,Gross,cast((
	(case when Isnull((Select Sum(Gross) from #TempPriceCards),0) >0 then
	Gross/(Select Sum(Gross) from #TempPriceCards)
	else 0 end)
	)*100 as numeric(9,2)) [% Gross mix]  from #TempPriceCards 

	drop table #TempPriceCards


	select MovieName,[Counter Admits],IsNull([Counter Gross],0) [Counter GBO],[Internet Admits],IsNull([Internet Gross],0) [Internet GBO],[TeleBooking Admits],IsNull([TeleBooking Gross],0) [TeleBooking GBO],[Total Admits],IsNull([Total Gross],0) [Total GBO] into #TempSaleChannelAnalysis from 
	(
	select IsNull(MovieName,'*Total')MovieName,SUM([Counter Admits])[Counter Admits],SUM([Counter Gross])[Counter Gross]
	,SUM([Internet Admits])[Internet Admits],SUM([Internet Gross])[Internet Gross] ,SUM([TeleBooking Admits])[TeleBooking Admits],SUM([TeleBooking Gross])[TeleBooking Gross] ,SUM([Total Admits])[Total Admits],SUM([Total Gross])[Total Gross] 
	from (Select Sh.MovieName

	,(select COUNT(SeatID) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) and Quotatype in (0,1)) [Counter Admits] 
	,(Select Sum(IsNull(M1.total,0)) from (Select 
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1' and Code='Ticket_Amount') -
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2' and Code='Ticket_Amount_Discount') total 
	from #TempSeatMaster where ShowID=sh.ShowID and Quotatype in (0,1) and StatusType IN (2,3) --
	) M1)[Counter Gross]

	,(select COUNT(SeatID) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) and Quotatype=3 ) [Internet Admits] 
	,(Select Sum(IsNull(M1.total,0)) from (Select 
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1' and Code='Ticket_Amount') -
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2' and Code='Ticket_Amount_Discount') total 
	from #TempSeatMaster where ShowID=sh.ShowID and Quotatype=3 and StatusType IN (2,3) --
	) M1)[Internet Gross]

	,(select COUNT(SeatID) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) and Quotatype=2 ) [TeleBooking Admits] 
	,(Select Sum(IsNull(M1.total,0)) from (Select 
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1' and Code='Ticket_Amount') -
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2' and Code='Ticket_Amount_Discount') total 
	from #TempSeatMaster where ShowID=sh.ShowID and Quotatype=2 and StatusType IN (2,3) --
	) M1)[TeleBooking Gross]

	,(select COUNT(SeatID) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) ) [Total Admits] 
	,(Select Sum(IsNull(M1.total,0)) from (Select 
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='1' and Code='Ticket_Amount') -
	(select isnull(Sum(IsNull(Price,0)),0) from PriceCardDetails where PriceCardid=#TempSeatMaster.PriceCardId and [Type]='2' and Code='Ticket_Amount_Discount') total 
	from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) --
	) M1)[Total Gross]

	from #TempShowMaster Sh)M

	group by Rollup(M.MovieName))

	As T ;

	insert into #TempSaleChannelAnalysis select '%',
	Round((

	(case when Isnull(Cast([Total Admits] as numeric(9,2)),0) >0 then
	Cast([Counter Admits] as numeric(9,2))/Cast([Total Admits] as numeric(9,2))
	else 0 end)


	)*100,2),
	Round((


	(case when Isnull(Cast([Total GBO] as numeric(9,2)),0) >0 then
	Cast([Counter GBO] as numeric(9,2))/Cast([Total GBO] as numeric(9,2))
	else 0 end)

	)*100,2),
	Round((



	(case when Isnull(Cast([Total Admits] as numeric(9,2)),0) >0 then
	Cast([Internet Admits] as numeric(9,2))/Cast([Total Admits] as numeric(9,2))
	else 0 end)
	)*100,2),
	Round((

	(case when Isnull(Cast([Total GBO] as numeric(9,2)),0) >0 then
	Cast([Internet GBO] as numeric(9,2))/Cast([Total GBO] as numeric(9,2))
	else 0 end)

	)*100,2),
	Round((
	(case when Isnull(Cast([Total Admits] as numeric(9,2)),0) >0 then
	Cast([TeleBooking Admits] as numeric(9,2))/Cast([Total Admits] as numeric(9,2))
	else 0 end)
	)*100,2),
	Round((
	(case when Isnull(Cast([Total GBO] as numeric(9,2)),0) >0 then
	Cast([TeleBooking GBO] as numeric(9,2))/Cast([Total GBO] as numeric(9,2))
	else 0 end)
	)*100,2),100.00,100.00
	from #TempSaleChannelAnalysis where MovieName='*Total';
	select * from #TempSaleChannelAnalysis order by MovieName desc;

	drop table #TempSaleChannelAnalysis; 

	select MovieName
	,Cast([4 Days Before] as numeric(9,2))[4 Days Before]
	,Cast([2 Days Before] as numeric(9,2))[2 Days Before]
	,Cast([Day Before] as numeric(9,2))[Day Before]
	,Cast(Lastgr2hr as numeric(9,2)) [>2 Hrs]
	,Cast(Last12hr as numeric(9,2)) [1-2 Hrs]
	,Cast(Last1560 as numeric(9,2)) [15-60 Mins]
	,Cast(Last15 as numeric(9,2))[Last 15 Mins]
	,Cast(befor as numeric(9,2))[After Start]
	,Cast(TotalAdmits as numeric(9,2)) TotalAdmits
	into #TempTKTvs#TempShowMaster from 
	(
	select IsNull(MovieName,'*Total')MovieName,SUM([4 Days Before])[4 Days Before],SUM([2 Days Before])[2 Days Before],SUM([Day Before])[Day Before],SUM(Lastgr2hr)Lastgr2hr,SUM(Last12hr)Last12hr,SUM(Last1560)Last1560,SUM(Last15)Last15,Sum(befor)befor,SUM(TotalAdmits)TotalAdmits
	from (Select Sh.MovieName
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>5760 ) [4 Days Before]
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=2881 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=5760 ) [2 Days Before] 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=1441 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=2880 ) [Day Before] 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=121 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=1440 ) Lastgr2hr 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=61 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=120 ) Last12hr 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=16 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=60 ) Last1560 

	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=0 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=15 ) Last15 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3)  and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<0) befor 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) ) TotalAdmits 

	from #TempShowMaster Sh)M

	group by Rollup(M.MovieName))

	As T ;

	insert into #TempTKTvs#TempShowMaster select '%'
	,((case when Isnull(TotalAdmits,0) >0 then [4 Days Before]/TotalAdmits
	else 0 end)

	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then 
	[2 Days Before]/TotalAdmits
	else 0 end)
	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then
	[Day Before]/TotalAdmits
	else 0 end)


	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then [>2 Hrs]/TotalAdmits
	else 0 end)

	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then [1-2 Hrs]/TotalAdmits
	else 0 end)

	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then
	[15-60 Mins]/TotalAdmits
	else 0 end)

	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then
	[Last 15 Mins]/TotalAdmits
	else 0 end)

	)*100
	,(

	(case when Isnull(TotalAdmits,0) >0 then [After Start]/TotalAdmits
	else 0 end)

	)*100
	,100.00
	from #TempTKTvs#TempShowMaster where MovieName='*Total';
	select * from #TempTKTvs#TempShowMaster order by MovieName desc

	drop table #TempTKTvs#TempShowMaster; 	



	select (select case when IsNull(M.QuotaType,9)=0 then 'Counter' when M.QuotaType=1 then 'Manager' when M.QuotaType=2 then 'TeleBooking' when M.QuotaType=3 then 'Online' else '*Total' end)QuotaType
	,Cast(Sum([4 Days Before]) as numeric(9,2))[4 Days Before]
	,Cast(Sum([2 Days Before]) as numeric(9,2))[2 Days Before]
	,Cast(Sum([Day Before]) as numeric(9,2))[Day Before]
	,Cast(Sum([>2 Hrs]) as numeric(9,2))[>2 Hrs]
	,Cast(Sum([1-2 Hrs]) as numeric(9,2))[1-2 Hrs]
	,Cast(Sum([15-60 Mins]) as numeric(9,2))[15-60 Mins]
	,Cast(Sum([Last 15 Mins]) as numeric(9,2))[Last 15 Mins]
	,Cast(Sum([After Start]) as numeric(9,2))[After Start]
	,Cast(Sum(TotalAdmits) as numeric(9,2))TotalAdmits
	into  #TempChannelvsShow from 
	(select QuotaType
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>5760 ) [4 Days Before]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=2881 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=5760) [2 Days Before]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=1441 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=2880) [Day Before]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=121 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=1440) [>2 Hrs]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=61 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=120 ) [1-2 Hrs]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=16 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=60 ) [15-60 Mins]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)>=0 and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<=15 ) [Last 15 Mins]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3) and DATEDIFF(MINUTE, LastSoldOn,Sh.ShowTime)<0) [After Start]
	,(select Count(*) from #TempSeatMaster where quotatype=st.quotatype and showid=sh.showid and StatusType IN (2,3)) TotalAdmits
	from #TempSeatMaster st
	left join #TempShowMaster Sh
	on st.showid=sh.showid
	where st.StatusType IN (2,3)
	group by st.QuotaType,sh.showid,sh.ShowTime)M group by Rollup(M.QuotaType)

	insert into  #TempChannelvsShow select '%'
	,((case when Isnull(TotalAdmits,0) >0 then [4 Days Before]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [2 Days Before]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [Day Before]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [>2 Hrs]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [1-2 Hrs]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [15-60 Mins]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [Last 15 Mins]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [After Start]/TotalAdmits else 0 end))*100
	,100.00
	from  #TempChannelvsShow where QuotaType='*Total';
	select * from  #TempChannelvsShow order by QuotaType desc

	drop table  #TempChannelvsShow; 



	select isNull(M.MovieName,'*Total')MovieName
	,cast(Sum(isNull(M.[> 4],0)) as numeric(9,2))[> 4]
	,cast(Sum(isNull(M.[4],0)) as numeric(9,2))[4]
	,cast(Sum(isNull(M.[3],0)) as numeric(9,2))[3]
	,cast(Sum(isNull(M.[2],0)) as numeric(9,2))[2]
	,cast(Sum(isNull(M.[Single],0)) as numeric(9,2))[Single]
	,cast(Sum(M.TotalAdmits) as numeric(9,2)) TotalAdmits into  #TempGroupSize from 
	(select 
	MovieName
	,(Select sum(Value) Val from ((select Count(*) Value from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) group by (TicketId) having Count(*)>4))Gr4) [> 4] 
	,(Select sum(Value) Val from ((select Count(*) Value from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) group by (TicketId) having Count(*)=4))G4) [4] 
	,(Select sum(Value) Val from ((select Count(*) Value from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) group by (TicketId) having Count(*)=3))G4) [3] 
	,(Select sum(Value) Val from ((select Count(*) Value from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) group by (TicketId) having Count(*)=2))G4) [2] 
	,(Select sum(Value) Val from ((select Count(*) Value from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) group by (TicketId) having Count(*)=1))G4) [Single] 
	,(select COUNT(SeatId) from #TempSeatMaster where ShowID=sh.ShowID and StatusType IN (2,3) ) TotalAdmits 
	from #TempShowMaster Sh)M
	group by Rollup(M.MovieName);

	insert into  #TempGroupSize select '%'
	,((case when Isnull(TotalAdmits,0) >0 then [> 4]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [4]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [3]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [2]/TotalAdmits else 0 end))*100
	,((case when Isnull(TotalAdmits,0) >0 then [Single]/TotalAdmits else 0 end))*100
	,100.00
	from  #TempGroupSize where MovieName='*Total';
	select * from  #TempGroupSize order by MovieName desc

	drop table  #TempGroupSize; 	


	select * into #TempConcClasAnls from (select isNull(M.name,'Total') Head,Sum(M.Value) Value from
	(select name,IsNull((select Sum(Quantity*(price+vat+tax)) from #TempCanteenMaster where itemid in (select itemid from item where HeadId=ih.id)),0) Value from itemheads ih)M group by rollup(M.name))
	Final
	select Head,Value,(
	(case when isnull((select max(Value) from #TempConcClasAnls),0)>0 then 
	Value/(select max(Value) from #TempConcClasAnls)
	else 0 end)

	*100) [%],(Case when isnull(@PaidAdmits,0)>0 then (Value/@PaidAdmits) else 0 end) [Per Admit] from #TempConcClasAnls
	drop table #TempConcClasAnls

	select * into #TempByQnt from (select isNull(M.Item,'Total') Head,Cast(Sum(M.Qty) as numeric(9,2)) Qty from
	(select top(10) ItemName [Item],Sum(Quantity) [Qty] from #TempCanteenMaster group by ItemName order by Sum(Quantity) desc) M group by rollup(M.Item))Final
	select *,Round((

	(case when isnull((select max(Qty) from #TempByQnt),0)>0 then 
	Qty/(select max(Qty) from #TempByQnt)*100
	else 0 end)
	)
	,3) [%] from #TempByQnt
	drop table #TempByQnt

	select * into #TempByVal from (select isNull(M.Item,'Total') Head,Cast(Sum(M.[Value]) as numeric(9,2)) [Value] from
	(select top(10) ItemName [Item],Sum(Quantity*(price+vat+tax)) [Value] from #TempCanteenMaster group by ItemName order by Sum(Quantity*(price+vat+tax)) desc) M group by rollup(M.Item))Final
	select *,Round((

	(case when isnull((select max([Value]) from #TempByVal),0)>0 then 
	[Value]/(select max([Value]) from #TempByVal)*100
	else 0 end)
	)
	,3) [%] from #TempByVal
	drop table #TempByVal


	select * into #TempByMargin from (select isNull(M.Item,'Total') Head,Cast(Sum(M.[Margin]) as numeric(9,2)) [Margin] from
	(select top(10) cn.ItemName [Item],Sum(cn.Quantity*it.cost) [Margin] from #TempCanteenMaster cn
	join item it on cn.itemid=it.itemid group by cn.ItemName,cn.ItemId order by [Margin] desc) M  group by rollup(M.Item))Final
	select *,
	Round((

	(case when isnull((select max([Margin]) from #TempByMargin),0)>0 then 
	[Margin]/(select max([Margin]) from #TempByMargin)*100
	else 0 end)

	),3) [%] from #TempByMargin
	drop table #TempByMargin

	Select * into #TempItemMaster from  (Select (Case when (ISNULL(M.ItemName,'')<>'') then ISNULL(IH.name,'') else '' end) [--],
	ISNULL(M.ItemName,'total')[Item Name],	Round(Sum(M.Quantity),2)Quantity,Round(Sum(M.Net),2)Net,
	Round(Sum(M.Gross),2)Gross,
	Round(Sum((M.Gross-M.Quantity*M.Cost)),2)StdProfit,Round(Sum((case when Net>0 then((Round(M.Gross,2)-Round(M.Quantity,2)*Round(M.Cost,2))/Round(M.Net,2)) else 0 end)),2)[Std Profit %],Round(Sum(M.NetSales),2) NetSales,
	Round(Sum(M.NetProfit),2)NetProfit	

	from 
	(select ItemId,ItemName,SUM(Quantity)Quantity,SUM(Price*Quantity)Net,SUM((Price+Tax+VAT)*Quantity)Gross,(Select top(1) Cost from Item where ItemID=#TempCanteenMaster.ItemID)Cost,(SUM(Quantity)*SUM(Price*Quantity))NetSales
	,(SUM((Price+Tax+VAT)*Quantity)-SUM(Quantity)*(Select top(1) Cost from Item where ItemID=#TempCanteenMaster.ItemID))*(SUM(Quantity))NetProfit 	
	from #TempCanteenMaster group by ItemID,ItemName)M
	left join Item I on M.ItemID=I.ItemID
	left join ItemHeads IH on I.HeadId=Ih.id
	group by rollup(Ih.name,M.ItemName)) As TempItemMaster;

	Select M.[--],M.[Item Name],M.Quantity,M.Net,M.Gross,M.[StdProfit],M.[Std Profit %],M.[NetSales],M.[NetSalesMix] [NetSales Mix %],M.NetProfit,M.NetProfitMix [NetProfit Mix %] from
	(select *,(NetSales*100/(select max(isnull(NetSales,1)) from #TempItemMaster)) NetSalesMix,(NetProfit*100/(select max(isnull(NetProfit,1)) from #TempItemMaster)) NetProfitMix from #TempItemMaster)M;

	Drop Table #TempSeatMaster
	Drop Table #TempShowMaster
	Drop Table #TempClassMaster
	Drop Table #TempItemMaster
	Drop Table #TempCanteenMaster
	Drop Table #TempScreenMaster
	Drop Table #TempMovie

End
GO

/* Concession Report */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ConcessionReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ConcessionReport]
GO

CREATE Procedure [dbo].[ConcessionReport]
(
	@StartDate Varchar(10)='',
	@EndDate Varchar(10)='',
	@ComplexId Int=0,
	@UserId Int=0,
	@ItemType Int=0
)
As
Begin
--Canteen Union with CanteenMIS
CREATE TABLE #TempCanteenMaster
(
			BillID int
			,TransactionID int 
           ,ItemID int
           ,ItemName varchar(16)
           ,BillType tinyint
           ,Price numeric(9,2)
           ,Tax numeric(9,2)
           ,VAT numeric(9,2)
           ,ComboItems varchar(128)
           ,Quantity int
           ,PaymentType tinyint
           ,PaymentReceived numeric(9,2)
           ,QuotaServicerID int
           ,QuotaServicerName varchar(32)
           ,QuotaType tinyint
           ,SeatID int
           ,ShowTime datetime
           ,PatronInfo varchar(256)
           ,BilledByID int
           ,TransactionTime datetime
           ,ComplexId int
           )
if(@ComplexId=0 and @UserId=0 and @ItemType=0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId]) 
	(Select * From Canteen where BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end
else if(@ComplexId>0 and @UserId=0 and @ItemType=0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId])  
	(Select * From Canteen where ComplexID=@complexID and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where ComplexID=@complexID and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end
else if(@ComplexId=0 and @UserId>0 and @ItemType=0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId])  
	(Select * From Canteen where BilledByID=@UserId and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where BilledByID=@UserId and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end
else if(@ComplexId>0 and @UserId>0 and @ItemType=0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId])  
	(Select * From Canteen where ComplexID=@complexID and BilledByID=@UserId and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where ComplexID=@complexID and BilledByID=@UserId and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end
else if(@ComplexId=0 and @UserId=0 and @ItemType>0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId])  
	(Select * From Canteen where itemid in (select itemid from item where HeadId=@ItemType) and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where itemid in (select itemid from item where HeadId=@ItemType) and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end
else if(@ComplexId=0 and @UserId>0 and @ItemType>0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId])  
	(Select * From Canteen where BilledByID=@UserId and itemid in (select itemid from item where HeadId=@ItemType) and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where BilledByID=@UserId and itemid in (select itemid from item where HeadId=@ItemType) and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end
else if(@ComplexId>0 and @UserId>0 and @ItemType>0)
begin
	truncate table #TempCanteenMaster;
	insert into  #TempCanteenMaster ([BillID],[TransactionID],[ItemID],[ItemName],[BillType],[Price],[Tax],[VAT],[ComboItems],[Quantity],[PaymentType],[PaymentReceived],[QuotaServicerID],[QuotaServicerName],[QuotaType],[SeatID],[ShowTime],[PatronInfo],[BilledByID],[TransactionTime],[ComplexId])  
	(Select * From Canteen where ComplexID=@complexID and BilledByID=@UserId and itemid in (select itemid from item where HeadId=@ItemType) and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) Union All 
	(Select * From CanteenMIS where ComplexID=@complexID and BilledByID=@UserId and itemid in (select itemid from item where HeadId=@ItemType) and BillType=0 and TransactionTime>@StartDate and TransactionTime<DateAdd(day,1,@EndDate)) 
end

select * into #tempSummary from (select isNull(cp.Complexname,'') [Complex],isNull(ih.name,'--') [Head],cm.itemname [item Name],'Each' as UOM, Sum(cm.Quantity) Quantity,0 as Discount,Sum(cm.Price) Net,Sum(cm.VAT+cm.Tax) Tax  
,Sum(cm.Price+cm.VAT+cm.Tax) NetSales
,(Sum(cm.Quantity*isnull(im.cost,0))) [Cost (Excl. Tax)]
,Sum(cm.Price+cm.VAT+cm.Tax)-Sum(cm.Quantity*isnull(im.cost,0)) [Margin (on Net)]
from #TempCanteenMaster cm
left join Item  im on cm.Itemid=im.itemid
left join ItemHeads  ih on im.headId=ih.id
left join Complex  cp on cp.ComplexId=cm.ComplexId
 group by cm.ItemName,cm.itemid,im.headId,ih.name,cm.ComplexId,cp.ComplexName)t
insert into #tempSummary
Select top(1) '*' Complex,'*Total' Head,'' ItemName,'' UOM, Sum(m.Quantity) Quantity, Sum(m.Discount)Discount,Sum(m.Net)Net,Sum(m.Tax)Tax,Sum(m.NetSales)NetSales,Sum(m.[Cost (Excl. Tax)])[Cost (Excl. Tax)],Sum(m.[Margin (on Net)])[Margin (on Net)] from
(select ''AllRec,isNull(cp.Complexname,'') [Complex],isNull(ih.name,'') [Head],cm.itemname [item Name],'Each' as UOM, Sum(cm.Quantity) Quantity,0 as Discount,Sum(cm.Price) Net,Sum(cm.VAT+cm.Tax) Tax  
,Sum(cm.Price+cm.VAT+cm.Tax) NetSales
,(Sum((cm.Quantity*isnull(im.cost,0)))) [Cost (Excl. Tax)]
,Sum(cm.Price+cm.VAT+cm.Tax)-Sum(cm.Quantity*isnull(im.cost,0)) [Margin (on Net)]
from #TempCanteenMaster cm
left join Item  im on cm.Itemid=im.itemid
left join ItemHeads  ih on im.headId=ih.id
left join Complex  cp on cp.ComplexId=cm.ComplexId
 group by cm.ItemName,cm.itemid,im.headId,ih.name,cm.ComplexId,cp.ComplexName) m group by rollup(m.AllRec)


select Complex,Head,[Item Name],UOM, Sum(m.Quantity) Quantity, Sum(m.Discount)Discount,Sum(m.Net)Net,Sum(m.Tax)Tax,Sum(m.NetSales)NetSales,Sum(m.[Cost (Excl. Tax)])[Cost (Excl. Tax)],Sum(m.[Margin (on Net)])[Margin (on Net)],Sum(m.[% of Total Sales])[% of Total Sales] from
(select *,(case when (select isnull(max(NetSales),0) from #tempSummary)>0 then (NetSales/(select isnull(max(NetSales),0) from #tempSummary))*100 else 0 end)[% of Total Sales] from #tempSummary)m group by Complex,Head,[Item Name],UOM order by Head desc
 
 drop table #tempSummary
 drop table #TempCanteenMaster
end
Go

/* Cashier Report */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CashierReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CashierReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[CashierReport] 1, 0, 0, '05 Dec 2016', '06 Dec 2016'

CREATE PROCEDURE [dbo].[CashierReport]
(
	@theatreId INT,
	@screenId INT,
	@userId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
)
AS
BEGIN
	
	SELECT * INTO #TempShowMaster
	FROM
	(
		SELECT * FROM Show WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT * FROM ShowMIS WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	)
	AS TempShowMaster
	
	SELECT * INTO #TempBookHistory FROM BookHistory WHERE ShowId IN (SELECT ShowId FROM #TempShowMaster) AND BookedById = (CASE WHEN @userId = 0 THEN BookedById ELSE @userId END) AND BookedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	
	SELECT * INTO #TempCancelHistory FROM CancelHistory WHERE ShowId IN (SELECT ShowId FROM #TempShowMaster) AND CancelledById = CASE WHEN @userId = 0 THEN CancelledById ELSE @userId END AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)

	DROP TABLE #TempShowMaster
	
	SELECT
	ISNULL(Booked.UserName, Cancelled.UserName) As [User Name],
	ISNULL(Booked.TotalTransactionCount, 0) [Total No. Of Booked Transactions],
	ISNULL(Cancelled.TotalRefundTransactionCount, 0) [Total No. Of Refund Transactions],
	--ISNULL(Booked.TotalPOSSeatsSold, 0) [Total No. Of POS Phone Bookings],
	--ISNULL(Booked.TotalUnpaidBookingsPaymentReceived, 0) [Total No.Of Unpaid Bookings Payment Received],
	IsNULL(Booked.RegularSeatsSold, 0) [No. Of Regular Seats Sold],
	--IsNULL(Booked.DefenceSeatsSold, 0) [No. Of Defence Seats Sold],
	--IsNULL(Booked.ComplimentarySeatsSold, 0) [No. Of Complimentary Seats Sold],
	ISNULL(Booked.TotalSeatsSold, 0) [Total No. Of Seats Sold],
	--ISNULL(Booked.[TotalConcessionSeatsSold], 0) [Total No. Of Food and Beverage Package Sold],
	ISNULL(Booked.[TotalThreeDSeatsSold], 0) [Total No. Of 3D Glass Package Sold],
	ISNULL(Cancelled.[TotalSeatsRefunded], 0) [Total No. Of Seats Cancelled],
	--ISNULL(Cancelled.[TotalConcessionSeatsCancelled], 0) [Total No. Of Food and Beverage Package Cancelled],
	ISNULL(Cancelled.[TotalThreeDSeatsCancelled], 0) [Total No. Of 3D Glass Package Cancelled],
	ISNULL(Booked.TotalTktPrice, 0) [Cash Collected for Tickets],
	--ISNULL(Booked.TotalConcessionTktPrice, 0) [Cash Collected for Food and Beverage Package],
	ISNULL(Booked.TotalThreeDTktPrice, 0) [Cash Collected for 3D Glass Package],
	ISNULL(Booked.TotalOtherTheatreCharges, 0) [Other Theatre Charges Collected],
	ISNULL(Cancelled.TotalRefundTktPrice, 0) + ISNULL(Cancelled.TotalRefundTktConcessionPrice, 0) + ISNULL(Cancelled.TotalRefundTktThreeDPrice, 0) + ISNULL(Cancelled.TotalOtherTheatreChargesRefunded, 0) AS [Total Cash Refunded],
	(ISNULL(Booked.TotalTktPrice, 0) + ISNULL(Booked.TotalConcessionTktPrice, 0) + ISNULL(Booked.TotalThreeDTktPrice, 0) + ISNULL(Booked.TotalOtherTheatreCharges, 0)) -
	(ISNULL(Cancelled.TotalRefundTktPrice, 0) + ISNULL(Cancelled.TotalRefundTktConcessionPrice, 0) + ISNULL(Cancelled.TotalRefundTktThreeDPrice, 0) + ISNULL(Cancelled.TotalOtherTheatreChargesRefunded, 0)) AS [Total Cash Collected]	
	INTO #CashierReport FROM
	(
	SELECT
		BookHistory.BookedByID,
		BookHistory.UserName,
		COUNT(BookHistory.TransactionCount) AS TotalTransactionCount,
		SUM(BookHistory.POSSeatsSold) AS TotalPOSSeatsSold,
		SUM(BookHistory.UnpaidBookingsPaymentReceived) AS TotalUnpaidBookingsPaymentReceived,
		SUM(BookHistory.RegularSeatsSold) AS RegularSeatsSold,
		SUM(BookHistory.DefenceSeatsSold) AS DefenceSeatsSold,
		SUM(BookHistory.ComplimentarySeatsSold) AS ComplimentarySeatsSold,
		SUM(BookHistory.SeatsSold) AS TotalSeatsSold,
		SUM(BookHistory.ConcessionSeatsSold) AS [TotalConcessionSeatsSold],
		SUM(BookHistory.ThreeDSeatsSold) AS [TotalThreeDSeatsSold],
		SUM(BookHistory.TktPrice) AS TotalTktPrice,
		SUM(BookHistory.ConcessionTktPrice) AS TotalConcessionTktPrice,
		SUM(BookHistory.ThreeDTktPrice) AS TotalThreeDTktPrice,
		SUM(BookHistory.OtherTheatreCharges) AS TotalOtherTheatreCharges
		FROM
		(
			SELECT
				BH.BookedByID,
				(SELECT UserName FROM BoxOfficeUser WHERE UserId = BH.BookedByID) UserName,
				BH.BookedOn AS TransactionCount,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.BlockCode IN (SELECT BlockCode FROM BlockHistory BlH WHERE BlH.BlockCode <> '' AND BlH.BlockedById <> 0)) AS POSSeatsSold,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.BOBookingCode IN (SELECT BookingCode FROM UnpaidBookings U WHERE U.BookedById <> 0)) AS UnpaidBookingsPaymentReceived,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 0)) AS RegularSeatsSold,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 1)) AS DefenceSeatsSold,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 2)) AS ComplimentarySeatsSold,
				COUNT(BH.SeatId) SeatsSold,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Concession' OR Code = 'Concession_Discount')) AS ConcessionSeatsSold,
				(SELECT COUNT(TBH.SeatId) FROM #TempBookHistory TBH WHERE TBH.BookedByID = BH.BookedByID AND TBH.BookedOn = BH.BookedOn AND TBH.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = '3D_Glasses' OR Code = '3D_Glasses_Discount')) AS ThreeDSeatsSold,
				((SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = BH.PriceCardId AND BH.PaymentType <> 5 and Code = 'Ticket_Amount')
				-(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = BH.PriceCardId AND BH.PaymentType <> 5 and Code = 'Ticket_Amount_Discount')) * Count(BH.SeatId) TktPrice,
				((SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardid = BH.PriceCardId AND BH.PaymentType <> 5 and Code = 'Concession')
				-(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardid = BH.PriceCardId AND BH.PaymentType <> 5 and Code = 'Concession_Discount')) * Count(BH.SeatId) ConcessionTktPrice,
				((SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardid = BH.PriceCardId AND BH.PaymentType <> 5 and Code = '3D_Glasses')
				-(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardid = BH.PriceCardId AND BH.PaymentType <> 5 and Code = '3D_Glasses_Discount')) * Count(BH.SeatId) ThreeDTktPrice,
				(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardid = BH.PriceCardId AND BH.PaymentType <> 5 and Code = 'Other_Theatre_Charges') * Count(BH.SeatId) OtherTheatreCharges
			FROM
				#TempBookHistory BH
			GROUP BY
				BH.BookedByID, BH.BookedOn, BH.PriceCardId, BH.PaymentType, BH.BlockCode
		)BookHistory GROUP BY BookHistory.BookedByID, BookHistory.UserName
	)Booked
	
	FULL OUTER JOIN
	
	(
	SELECT
		CancelHistory.CancelledByID,
		CancelHistory.UserName,
		COUNT(CancelHistory.TransactionCount) AS [TotalRefundTransactionCount],
		SUM(CancelHistory.SeatsRefunded) AS [TotalSeatsRefunded],
		SUM(CancelHistory.ConcessionSeatsCancelled) AS [TotalConcessionSeatsCancelled],
		SUM(CancelHistory.ThreeDSeatsCancelled) AS [TotalThreeDSeatsCancelled],
		SUM(CancelHistory.TktPrice) AS TotalRefundTktPrice,
		SUM(CancelHistory.TktConcessionPrice) AS TotalRefundTktConcessionPrice,
		SUM(CancelHistory.TktThreeDPrice) AS TotalRefundTktThreeDPrice,
		SUM(CancelHistory.OtherTheatreCharges) AS TotalOtherTheatreChargesRefunded
	FROM
		(
			SELECT
				CH.CancelledByID,
				(SELECT UserName FROM BoxOfficeUser WHERE UserId = CH.CancelledByID) UserName,
				CH.CancelledOn TransactionCount,
				COUNT(CH.SeatId) SeatsRefunded,
				(SELECT COUNT(TCH.SeatId) FROM #TempCancelHistory TCH WHERE TCH.CancelledByID = CH.CancelledByID AND TCH.CancelledOn = CH.CancelledOn AND TCH.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE (Code = 'Concession' OR Code = 'Concession_Discount'))) AS ConcessionSeatsCancelled,
				(SELECT COUNT(TCH.SeatId) FROM #TempCancelHistory TCH WHERE TCH.CancelledByID = CH.CancelledByID AND TCH.CancelledOn = CH.CancelledOn AND TCH.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE (Code = '3D_Glasses' OR Code = '3D_Glasses_Discount'))) AS ThreeDSeatsCancelled,
				((SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = CH.PriceCardId AND CH.BookedPaymentType <> 5 AND Code = 'Ticket_Amount')
				-(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = CH.PriceCardId AND CH.BookedPaymentType <> 5 AND Code = 'Ticket_Amount_Discount')) * Count(CH.SeatId) TktPrice,
				((SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = CH.PriceCardId AND CH.BookedPaymentType <> 5 AND Code = 'Concession')
				-(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = CH.PriceCardId AND CH.BookedPaymentType <> 5 AND Code = 'Concession_Discount')) * Count(CH.SeatId) TktConcessionPrice,
				((SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = CH.PriceCardId AND CH.BookedPaymentType <> 5 AND Code = '3D_Glasses')
				-(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardId = CH.PriceCardId AND CH.BookedPaymentType <> 5 AND Code = '3D_Glasses_Discount')) * Count(CH.SeatId) TktThreeDPrice,
				(SELECT ISNULL(SUM(ISNULL(Price,0)),0) FROM PriceCardDetails WHERE PriceCardid = CH.PriceCardId AND CH.BookedPaymentType <> 5 and Code = 'Other_Theatre_Charges') * Count(CH.SeatId) OtherTheatreCharges
			FROM
				#TempCancelHistory CH
			GROUP BY CH.CancelledByID, CH.PriceCardId, CH.BookedPaymentType, CH.CancelledOn
		) CancelHistory
		GROUP BY CancelHistory.CancelledByID, CancelHistory.UserName)
		Cancelled ON Booked.BookedByID = Cancelled.CancelledByID
	
	--Food and Beverage
	SELECT
		ISNULL(SalesH.UserName, (ISNULL(CancelH.UserName, RH.UserName))) As [User Name],
		ISNULL(SalesH.SoldCount, 0) [Total No. Of Transactions],
		ISNULL(CancelH.CancelledCount, 0) [Total No. Of Transactions (Order Cancellations)],
		ISNULL(RH.CancelledCount, 0) [Total No. Of Transactions (Cancel due to damage)],
		ISNULL(SalesH.Price, 0) [Cash Collected],
		ISNULL(CancelH.Price, 0) + ISNULL(RH.Price, 0) AS [Total Cash Refunded],
		(ISNULL(SalesH.Price, 0) - (ISNULL(CancelH.Price, 0) + ISNULL(RH.Price, 0))) AS [Total Cash Collected]
	INTO #SalesMaster
	FROM
	(
		SELECT
			SoldBy,
			[User Name] UserName,
			COUNT(DISTINCT TransactionID) SoldCount,
			SUM(SellingPrice) Price
		FROM	
		(	
			SELECT
				SH.SoldBy,
				(SELECT UserName FROM BoxOfficeUser WHERE UserID = SH.SoldBy) [User Name],
				SH.SoldOn AS TransactionID,
				SUM(Quantity * (CASE WHEN SH.PaymentType = 5 THEN 0 ELSE IP.Price END)) SellingPrice
			FROM ItemSalesHistory SH
			INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID 
			WHERE
				SH.SeatID IS NULL 
				AND SH.SoldBy = (CASE WHEN @userID = 0 THEN SH.SoldBy ELSE @userID END)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) >= CONVERT(DATETIME, @startDate, 106) 
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
				AND SH.ComplexID = @theatreId	
			GROUP BY SH.SoldBy, SH.TransactionID, SH.PaymentType, SH.ItemPriceID, SH.SoldOn
		)SalesHistory GROUP BY SoldBy, [User Name]
	)SalesH		
	
	FULL OUTER JOIN
	(
		SELECT
			CancelledBy,
			[User Name] UserName,
			COUNT(DISTINCT TransactionID) CancelledCount,
			SUM(SellingPrice) Price
		FROM	
		(	
			SELECT
				CH.CancelledBy,
				(SELECT UserName FROM BoxOfficeUser WHERE UserID = CH.CancelledBy) [User Name],
				CH.CancelledOn AS TransactionID,
				Quantity * (SELECT IP.Price FROM ItemPrice IP WHERE IP.ItemPriceID IN (SELECT ItemPriceID FROM ItemSalesHistory WHERE ItemSalesHistory.ItemID = CH.ItemID AND ItemSalesHistory.ItemPriceID = CH.ItemPriceID AND ItemSalesHistory.ItemStockID = CH.ItemStockID AND ItemSalesHistory.TransactionID = CH.TransactionID AND ItemSalesHistory.PaymentType <> 5)) SellingPrice
			FROM ItemCancelHistory CH 
			WHERE
				CH.OrderType = 2
				AND CH.CancelledBy = (CASE WHEN @userID = 0 THEN CH.CancelledBy ELSE @userID END)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CH.CancelledOn, 106)) >= CONVERT(DATETIME, @startDate, 106) 
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CH.CancelledOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
				AND CH.TransactionID IN (SELECT TransactionID FROM ItemSalesHistory WHERE ComplexID = @theatreId AND SeatID IS NULL)
			GROUP BY CH.CancelledBy, CH.TransactionID, CH.ItemID, CH.Quantity, CH.CancelledOn, CH.ItemStockID, CH.ItemPriceID
		)CancelHistory GROUP BY CancelledBy, [User Name]
	)CancelH ON SalesH.SoldBy = CancelH.CancelledBy
	
	FULL OUTER JOIN
	(
		SELECT
			CancelledBy,
			[User Name] UserName,
			COUNT(DISTINCT TransactionID) CancelledCount,
			SUM(SellingPrice) Price
		FROM	
		(	
			SELECT
				CH.CancelledBy,
				(SELECT UserName FROM BoxOfficeUser WHERE UserID = CH.CancelledBy) [User Name],
				CH.CancelledOn AS TransactionID,
				Quantity * (SELECT IP.Price FROM ItemPrice IP WHERE IP.ItemPriceID IN (SELECT ItemPriceID FROM ItemSalesHistory WHERE ItemSalesHistory.ItemID = CH.ItemID AND ItemSalesHistory.TransactionID = CH.TransactionID AND ItemSalesHistory.ItemPriceID = CH.ItemPriceID AND ItemSalesHistory.ItemStockID = CH.ItemStockID AND ItemSalesHistory.PaymentType <> 5)) SellingPrice
			FROM ItemCancelHistory CH 
			WHERE
				CH.OrderType = 1
				AND CH.CancelledBy = (CASE WHEN @userID = 0 THEN CH.CancelledBy ELSE @userID END)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CH.CancelledOn, 106)) >= CONVERT(DATETIME, @startDate, 106) 
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CH.CancelledOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
				AND CH.TransactionID IN (SELECT TransactionID FROM ItemSalesHistory WHERE ComplexID = @theatreId AND SeatID IS NULL)
			GROUP BY CH.CancelledBy, CH.TransactionID, CH.ItemID, CH.Quantity, CH.CancelledOn, CH.ItemStockID, CH.ItemPriceID
		)ReturnHistory GROUP BY CancelledBy, [User Name]
	)RH ON SalesH.SoldBy = RH.CancelledBy
	
	-- Select data

	IF EXISTS(SELECT [User Name] FROM #CashierReport)
	BEGIN
		SELECT * INTO #Code
		FROM
		(		
			SELECT Code FROM PriceCardItems WHERE Code IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #TempBookHistory) AND Code = 'Other_Theatre_Charges')
			UNION ALL
			SELECT Code FROM PriceCardItems WHERE Code IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #TempCancelHistory) AND Code = 'Other_Theatre_Charges')
		) PCCode

		IF EXISTS(SELECT * FROM #Code)
		BEGIN
			SELECT [User Name], [Total No. Of Booked Transactions], [Total No. Of Refund Transactions], [No. Of Regular Seats Sold],
			--[No. Of Defence Seats Sold], [No. Of Complimentary Seats Sold], 
			[Total No. Of Seats Sold], [Total No. Of 3D Glass Package Sold],
			[Cash Collected for Tickets], [Cash Collected for 3D Glass Package], [Other Theatre Charges Collected],
			[Total Cash Refunded], [Total Cash Collected] FROM #CashierReport ORDER BY [User Name]
			/*SELECT [User Name], [Total No. Of Booked Transactions], [Total No. Of Refund Transactions], [Total No. Of POS Phone Bookings], [Total No.Of Unpaid Bookings Payment Received], [No. Of Regular Seats Sold],
			[No. Of Defence Seats Sold], [No. Of Complimentary Seats Sold], [Total No. Of Seats Sold], [Total No. Of Food and Beverage Package Sold], [Total No. Of 3D Glass Package Sold],
			[Cash Collected for Tickets], [Cash Collected for Food and Beverage Package], [Cash Collected for 3D Glass Package], [Other Theatre Charges Collected],
			[Total Cash Refunded], [Total Cash Collected] FROM #CashierReport ORDER BY [User Name]*/

			IF @userId = 0
				SELECT 
				'All Users' [User Name], 
				SUM([Total No. Of Booked Transactions]) [Total No. Of Booked Transactions], 
				SUM([Total No. Of Refund Transactions]) [Total No. Of Refund Transactions], 
				--SUM([Total No. Of POS Phone Bookings]) [Total No. Of POS Phone Bookings],
				--SUM([Total No.Of Unpaid Bookings Payment Received]) [Total No.Of Unpaid Bookings Payment Received],
				SUM([No. Of Regular Seats Sold]) [No. Of Regular Seats Sold],
				--SUM([No. Of Defence Seats Sold]) [No. Of Defence Seats Sold],
				--SUM([No. Of Complimentary Seats Sold]) [No. Of Complimentary Seats Sold],
				SUM([Total No. Of Seats Sold]) [Total No. Of Seats Sold], 
				--SUM([Total No. Of Food and Beverage Package Sold]) [Total No. Of Food and Beverage Package Sold], 
				SUM([Total No. Of 3D Glass Package Sold]) [Total No. Of 3D Glass Package Sold], 
				SUM([Total No. Of Seats Cancelled]) [Total No. Of Seats Cancelled], 
				--SUM([Total No. Of Food and Beverage Package Cancelled]) [Total No. Of Food and Beverage Package Cancelled], 
				SUM([Total No. Of 3D Glass Package Cancelled]) [Total No. Of 3D Glass Package Cancelled], 
				SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
				--SUM([Cash Collected for Food and Beverage Package]) [Cash Collected for Food and Beverage Package], 
				SUM([Cash Collected for 3D Glass Package]) [Cash Collected for 3D Glass Package],
				SUM([Other Theatre Charges Collected]) [Other Theatre Charges Collected],
				SUM([Total Cash Refunded]) [Total Cash Refunded], 
				SUM([Total Cash Collected]) [Total Cash Collected] 
				FROM #CashierReport
		END
		ELSE
		BEGIN
			SELECT [User Name], [Total No. Of Booked Transactions], [Total No. Of Refund Transactions], [No. Of Regular Seats Sold],
			--[No. Of Defence Seats Sold], [No. Of Complimentary Seats Sold], [Total No. Of Seats Sold], 
			[Total No. Of 3D Glass Package Sold],
			[Cash Collected for Tickets], [Cash Collected for 3D Glass Package],
			[Total Cash Refunded], [Total Cash Collected] FROM #CashierReport ORDER BY [User Name]
			/*SELECT [User Name], [Total No. Of Booked Transactions], [Total No. Of Refund Transactions], [Total No. Of POS Phone Bookings], [Total No.Of Unpaid Bookings Payment Received], [No. Of Regular Seats Sold],
			[No. Of Defence Seats Sold], [No. Of Complimentary Seats Sold], [Total No. Of Seats Sold], [Total No. Of Food and Beverage Package Sold], [Total No. Of 3D Glass Package Sold],
			[Cash Collected for Tickets], [Cash Collected for Food and Beverage Package], [Cash Collected for 3D Glass Package],
			[Total Cash Refunded], [Total Cash Collected] FROM #CashierReport ORDER BY [User Name]*/

			IF @userId = 0
				SELECT 
				'All Users' [User Name], 
				SUM([Total No. Of Booked Transactions]) [Total No. Of Booked Transactions], 
				SUM([Total No. Of Refund Transactions]) [Total No. Of Refund Transactions], 
				--SUM([Total No. Of POS Phone Bookings]) [Total No. Of POS Phone Bookings],
				--SUM([Total No.Of Unpaid Bookings Payment Received]) [Total No.Of Unpaid Bookings Payment Received],
				SUM([No. Of Regular Seats Sold]) [No. Of Regular Seats Sold],
				--SUM([No. Of Defence Seats Sold]) [No. Of Defence Seats Sold],
				--SUM([No. Of Complimentary Seats Sold]) [No. Of Complimentary Seats Sold],
				SUM([Total No. Of Seats Sold]) [Total No. Of Seats Sold], 
				--SUM([Total No. Of Food and Beverage Package Sold]) [Total No. Of Food and Beverage Package Sold], 
				SUM([Total No. Of 3D Glass Package Sold]) [Total No. Of 3D Glass Package Sold], 
				SUM([Total No. Of Seats Cancelled]) [Total No. Of Seats Cancelled], 
				--SUM([Total No. Of Food and Beverage Package Cancelled]) [Total No. Of Food and Beverage Package Cancelled], 
				SUM([Total No. Of 3D Glass Package Cancelled]) [Total No. Of 3D Glass Package Cancelled], 
				SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
				--SUM([Cash Collected for Food and Beverage Package]) [Cash Collected for Food and Beverage Package], 
				SUM([Cash Collected for 3D Glass Package]) [Cash Collected for 3D Glass Package],
				SUM([Total Cash Refunded]) [Total Cash Refunded], 
				SUM([Total Cash Collected]) [Total Cash Collected] 
				FROM #CashierReport
		END

		DROP TABLE #Code
	END

	DROP TABLE #TempBookHistory
	DROP TABLE #TempCancelHistory
	
	IF EXISTS(SELECT [User Name] FROM #SalesMaster)
	BEGIN
		SELECT * FROM #SalesMaster ORDER BY [User Name]

		IF @userId = 0
			SELECT 
				'All Users' [User Name], 
				SUM([Total No. Of Transactions]) [Total No. Of Transactions], 
				SUM([Total No. Of Transactions (Order Cancellations)]) [Total No. Of Transactions (Order Cancellations)], 
				SUM([Total No. Of Transactions (Cancel due to damage)]) [Total No. Of Transactions (Cancel due to damage)], 
				SUM([Cash Collected]) [Cash Collected], SUM([Total Cash Refunded]) [Total Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] 
			FROM #SalesMaster
	END

	IF (SELECT COUNT([User Name]) FROM #CashierReport) > 0 AND (SELECT COUNT([User Name]) FROM #SalesMaster) > 0
	BEGIN	
		SELECT 
			ISNULL(CR.[User Name], SM.[User Name]) [User Name],
			ISNULL(SUM(CR.[Total Cash Refunded]), 0) + ISNULL(SUM(SM.[Total Cash Refunded]), 0) [Total Cash Refunded],
			ISNULL(SUM(CR.[Total Cash Collected]), 0) + ISNULL(SUM(SM.[Total Cash Collected]), 0) [Total Cash Collected]
		INTO #GrandTotal
		FROM #CashierReport CR
		FULL OUTER JOIN
		#SalesMaster SM ON CR.[User Name] = SM.[User Name]
		GROUP BY CR.[User Name], SM.[User Name]
		
		IF EXISTS(SELECT [User Name] FROM #GrandTotal)
			SELECT * FROM #GrandTotal ORDER BY [User Name]
		IF @userId = 0
			IF EXISTS(SELECT [User Name] FROM #GrandTotal)
				SELECT 
					'All Users' [User Name], 
					SUM([Total Cash Refunded]) [Total Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] 
				FROM #GrandTotal
	
		DROP TABLE #GrandTotal
	END
	
	DROP TABLE #SalesMaster
	DROP TABLE #CashierReport
END
GO

/* GetSalesInfoByShow */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetSalesInfoByShow]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].GetSalesInfoByShow
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- [GetSalesInfoByShow] 5294
CREATE PROCEDURE [dbo].GetSalesInfoByShow  
	@ShowID INT  
AS
	IF EXISTS(SELECT ShowId FROM Show WHERE ShowID = @ShowId AND IsSalesDataSent = 0)
	BEGIN
		DECLARE @SEATDETAILS AS NVARCHAR(MAX)='';  
		DECLARE @SHOWDETAILS AS NVARCHAR(1000)='';
		DECLARE @PRICECARDDETAILS AS NVARCHAR(max)='';
		;WITH SampleDataR as  
		(  
		SELECT *, ROW_NUMBER() OVER (PARTITION BY seatid ORDER BY seatid) rownum,'' value  
		FROM Seat WHERE SeatType<>1 and ShowID=@ShowID 
		)  
		SELECT DISTINCT TOP(1) @SEATDETAILS=(  
		SELECT value   
		+ '{
		"className":"'+(SELECT ClassName FROM [Class] WHERE ClassId=s1.ClassID )+'",
		"row":"'+CAST(RowNo AS VARCHAR)+'",
		"column":"'+CAST(ColNo AS VARCHAR)+'",  
		"label":"'+CAST(SeatLabel AS VARCHAR)+'",  
		"available":"'+ (CASE WHEN TicketId = 0 THEN 'true' ELSE 'false' END)+'",
		"pricecardID":"'+CAST(PriceCardId AS VARCHAR)+'",
		"onlineSeatId":"'+CAST(SeatClassInfo AS VARCHAR)+'",
		"onlineBooked":"'+ (CASE WHEN PatronInfo = '' THEN 'false' ELSE 'true' END)+'"
		},' FROM SampleDataR s1  
		FOR XML PATH(''),TYPE).value('(.)[1]','NVARCHAR(MAX)'  
		)   
		FROM SampleDataR s2  
		SET @SEATDETAILS= CASE WHEN @SEATDETAILS <> '' THEN SUBSTRING(@SEATDETAILS ,1, LEN(@SEATDETAILS)-1) ELSE '' END;

		;with SampleDataR as  
		(  
		SELECT DISTINCT st.PRICECARDID AS PCID,pc.PriceCardGuid AS PCGUID FROM SEAT st join pricecard as pc on st.PriceCardId=pc.Id  WHERE SeatType<>1 and ShowID=@ShowId
		)  
		SELECT @PRICECARDDETAILS=(SELECT
								'{"priceCardId":"' + CAST(S3.PCID AS VARCHAR) +
								'","onlinePriceCardId":"' + S3.PCGUID +
								'","totalAmount":' + CAST((SELECT PRICE FROM PriceCardDetails WHERE Code='Ticket_Amount' AND PriceCardId=S3.PCID)as VARCHAR)+
								',"priceBreakUp":[  
			'+  SUBSTRING([dbo].[GetFullPriceCardDetailsByID](S3.PCID ),2,LEN([dbo].[GetFullPriceCardDetailsByID](S3.PCID )))  
			+']},' FROM SampleDataR S3
		FOR XML PATH(''),TYPE).value('(.)[1]','NVARCHAR(MAX)'
		)FROM SampleDataR S4 
		SET @PRICECARDDETAILS= CASE WHEN @PRICECARDDETAILS <> '' THEN SUBSTRING(@PRICECARDDETAILS ,1, LEN(@PRICECARDDETAILS)-1) ELSE '' END;

		SELECT @SHOWDETAILS = (SELECT 
								'"boxofficeSessionId":"'+ UUID + '_' + CAST(ShowID AS VARCHAR) +
								'","screenId":"'+(SELECT ScreenGUID FROM Screen WHERE ScreenID=Show.ScreenID)+
								'","movieId":"'+ OnlineMovieID +
								'","sessionTime":"'+ convert(varchar(19), ShowTime, 126) + '+05:30' +
								'","createdAt":"'+ convert(varchar(19), CreatedOn, 126) + '+05:30' +
								'","updatedAt":"'+ convert(varchar(19), getdate(), 126) + '+05:30' +
								'","status":"'+CASE WHEN IsCancel = 1 THEN 'cancelled' ELSE 'closed' END+'"' FROM Show WHERE ShowID=@ShowID AND OnlineMovieID IS NOT NULL)
		UPDATE Show SET [IsSalesDataSent] = 1 WHERE ShowID = @ShowID

		SELECT OnlineShowID, 
		'{' + @SHOWDETAILS + ', "seats":['+@SEATDETAILS+'], "priceCards":['+@PRICECARDDETAILS+']}' AS Seat  
		FROM Show  
		WHERE ShowID = @ShowID 
	END
GO

/* [AuditRefundReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AuditRefundReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AuditRefundReport]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--Exec AuditRefundReport @StartDate='08-20-2014',@EndDate='11-30-2014',@ScreenId=0,@UserId=0,@Minutes=0
CREATE Procedure [dbo].[AuditRefundReport]
(
	@StartDate Varchar(10)='',
	@EndDate Varchar(10)='',
	@ScreenId Int=0,
	@UserId Int=0,
	@Minutes Int=0
)
As
Begin

--Screen

select * into #TempScreenMaster from (select * from Screen where ScreenId=(case when @ScreenId=0 then ScreenId else @ScreenId end)) As TempScreenMaster

	
--Seat Union with SeatMIS
Select * into #TempSeatMaster from  (Select * from Seat where SeatType<>1 and LastCancelledByID>0 and  ShowID in (
select ShowID from Show  where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster)) 
Union All Select * from SeatMIS where SeatType<>1 and LastCancelledByID>0 and ShowID in (select ShowID from ShowMIS  where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster))) As TempSeatMaster

--Show Union with ShowMIS
Select * into #TempShowMaster from  (Select * From Show where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster) Union All Select * From ShowMIS where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster)) As TempShowMaster

--Class Union with ClassMIS
Select * into #TempClassMaster from  (Select * From Class where ShowID in (select ShowID from Show  where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster)) Union All Select * From ClassMIS  where ShowID in (select ShowID from Show  where ShowTime>@StartDate and ShowTime<DateAdd(day,1,@EndDate) and ScreenID in (select ScreenId from #TempScreenMaster))) As TempClassMaster

declare @cmdStr as nVarchar(max)='';

set @cmdStr='select
 Convert(varchar,LastCancelledOn,110) [Refund Date],
CASE WHEN DATEPART(HOUR,LastCancelledOn) >12 then Convert(VARCHAR(28), Cast(LastCancelledOn AS DATETIME), 8) +'' PM'' ELSE Convert(VARCHAR(28), Cast(LastCancelledOn AS DATETIME), 8) +'' AM'' END [Refund Time],
(select username from BoxOfficeUser where userid=tmpseat.LastCancelledByID) Username,
Cast(SeatId as varchar(10))[Transaction Number]
 ,(select Name from pricecard where id=tmpSeat.pricecardid)[Ticket Type] 
 ,tmpShow.Moviename [Film]
 , Convert(varchar,tmpshow.Showtime,110) [Session Date],
CASE WHEN DATEPART(HOUR,tmpshow.Showtime) >12 then Convert(VARCHAR(28), Cast(tmpshow.Showtime AS DATETIME), 8) +'' PM'' ELSE Convert(VARCHAR(28), Cast(LastCancelledOn AS DATETIME), 8) +'' AM'' END [Session Time]
,Cast(datediff(mi,tmpshow.Showtime,tmpseat.LastCancelledOn) as varchar(10))[Minutes After Session]
,1 [Refund Qty] --we are not maintaining transaction number after transaction cancel, so we are displaying individual seat thats why we fixed 1 here
,(select Amount from pricecard where id=tmpSeat.pricecardid)[Refund Value] 
 from #TempSeatMaster tmpseat
left join #TempShowMaster tmpshow on tmpseat.ShowId=tmpshow.Showid
 where tmpseat.LastCancelledOn>'''+@StartDate+''' 
 and tmpseat.LastCancelledOn<DateAdd(day,1,'''+@EndDate+''') 
  and LastCancelledByID=(case when '+Cast(@UserId as Varchar(10))+'=0 then LastCancelledByID else '+Cast(@UserId as Varchar(10))+' end)'
if(@Minutes<0)
begin
set @cmdStr+=' and tmpseat.LastCancelledOn<tmpshow.Showtime'
end
else if(@Minutes=0)
begin
set @cmdStr+=' and (tmpseat.LastCancelledOn>=tmpshow.Showtime or tmpseat.LastCancelledOn<=tmpshow.Showtime)'
end
else if(@Minutes>0 and @Minutes<=240)
begin
set @cmdStr+=' and tmpseat.LastCancelledOn>=tmpshow.Showtime and datediff(mi,tmpshow.Showtime,tmpseat.LastCancelledOn)<='+Cast(@Minutes as Varchar(10))
end
else
begin
set @cmdStr+=' and tmpseat.LastCancelledOn>=tmpshow.Showtime and datediff(mi,tmpshow.Showtime,tmpseat.LastCancelledOn)>='+Cast(@Minutes as Varchar(10))
end

  --exec sp_executesql @cmdstr;
  --set @cmdStr='';
  
  set @cmdStr+=' union select '''','''','''','''','''','''','''','''','''',
Sum(1) [Refund Qty] 
,Sum(prc.Amount)[Refund Value] 
 from #TempSeatMaster tmpseat
left join #TempShowMaster tmpshow on tmpseat.ShowId=tmpshow.Showid
left join pricecard prc on prc.id=tmpSeat.pricecardid
 where tmpseat.LastCancelledOn>'''+@StartDate+''' 
 and tmpseat.LastCancelledOn<DateAdd(day,1,'''+@EndDate+''') 
  and LastCancelledByID=(case when '+Cast(@UserId as Varchar(10))+'=0 then LastCancelledByID else '+Cast(@UserId as Varchar(10))+' end)'
if(@Minutes<0)
begin
set @cmdStr+=' and tmpseat.LastCancelledOn<tmpshow.Showtime'
end
else if(@Minutes=0)
begin
set @cmdStr+=' and (tmpseat.LastCancelledOn>=tmpshow.Showtime or tmpseat.LastCancelledOn<=tmpshow.Showtime)'
end
else if(@Minutes>0 and @Minutes<=240)
begin
set @cmdStr+=' and tmpseat.LastCancelledOn>=tmpshow.Showtime and datediff(mi,tmpshow.Showtime,tmpseat.LastCancelledOn)<='+Cast(@Minutes as Varchar(10))
end
else
begin
set @cmdStr+=' and tmpseat.LastCancelledOn>=tmpshow.Showtime and datediff(mi,tmpshow.Showtime,tmpseat.LastCancelledOn)>='+Cast(@Minutes as Varchar(10))
end
print @cmdstr;
set @cmdstr+=' order by [Refund Value]';
  exec sp_executesql @cmdstr;

	Drop Table #TempScreenMaster
	Drop Table #TempSeatMaster
	Drop Table #TempShowMaster
	Drop Table #TempClassMaster
	End
GO


/* [GetSeatSalesSummary] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetSeatSalesSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetSeatSalesSummary]
GO
-- [GetSeatSalesSummary] 274, 1
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[GetSeatSalesSummary]
 @ShowId INT,
 @UserId INT
AS
BEGIN
	SELECT
		shwname, shwtime, scrname, mvname, ClassNo, ClassName,
		NoCounters, NoOnlines, ISNULL(TotalBookedSeats, 0) totBlockCount, FreeSeat,
		(SELECT COUNT(SeatId) FROM CancelHistory WHERE ShowId = @ShowId) CancelNos, SUM(NoSales) SalesNos,
		CounterTA, OnlineTA, CounterThreeD, OnlineThreeD, CounterFandB, OnlineFandB,
		(SELECT IsAdvanceToken FROM Show WHERE ShowID = @ShowId) AS IsAdvanceToken, ET, SC, AT, FDF,
		SUM(ConcessionCounterSeatsSold) CounterFAndBCount, SUM(ConcessionOnlineSeatsSold) OnlineFAndBCount, 
		SUM(ThreeDCounterSeatsSold) CounterThreeDCount, SUM(ThreeDOnlineSeatsSold) OnlineThreeDCount, CounterOTC, OnlineOTC, SUM(OTCCounterSeatsSold) CounterOTCCount, 
		SUM(OTCOnlineSeatsSold) OnlineOTCCount, CGST, SGST, FC
	FROM  
	(	
		SELECT DISTINCT
		(SELECT COUNT(SeatId) FROM BookHistory WHERE ShowId = @ShowId AND SeatId IN (SELECT SeatId FROM Seat WHERE ClassID=Class.ClassID AND QuotaType!=3) AND BOBookingCode IS NULL AND BEBookingCode IS NULL AND BlockCode <> '') AS TotalBookedSeats,
		(SELECT COUNT(1) FROM Seat WHERE StatusType IN (2,3) AND (QuotaType=3 OR (PaymentType = 1 AND QuotaType!=3)) AND ShowID = @ShowId AND ClassID=Class.ClassID) AS NoOnlines,
		(SELECT COUNT(1) FROM Seat WHERE StatusType IN (2,3) AND QuotaType!=3 AND ShowID = @ShowId AND ClassID=Class.ClassID AND PaymentType <> 1) AS NoCounters,
		MIN(Show.ShowName) AS shwname,  
		MIN(Show.ShowTime) AS shwtime,  
		MIN(Show.ScreenName) AS scrname, MIN(Show.MovieName) AS mvname, Class.ClassName,
		Class.ClassNo, 
		SUM(1) AS NoSales,
		(SELECT COUNT(1) FROM Seat WHERE StatusType IN (2,3) AND PaymentType = 5 AND ShowID = @ShowId AND ClassID=Class.ClassID) AS FreeSeat,

		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Ticket_Amount'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Ticket_Amount_Discount'),0),2)) CounterTA,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='Ticket_Amount'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID and ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='Ticket_Amount_Discount'),0),2)) OnlineTA,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='3D_Glasses'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='3D_Glasses_Discount'),0),2)) CounterThreeD,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID and ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='3D_Glasses'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID and ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='3D_Glasses_Discount'),0),2)) OnlineThreeD,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Concession'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd on ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Concession_Discount'),0),2)) CounterFandB,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='Concession'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='Concession_Discount'),0),2)) OnlineFandB,
		
		ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Other_Theatre_Charges'),0),2) CounterOTC,
		
		ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType = 1 AND pcd.Code='Other_Theatre_Charges'),0),2) OnlineOTC,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='Entertainment_Tax'),0),2)) ET,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='CGST'),0),2)) CGST,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='SGST'),0),2)) SGST,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='Service_Charge'),0),2)) SC,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='Additional_Tax'),0),2)) AT,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='Film_Development_Fund'),0),2)) FDF,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.PaymentType <> 5 AND pcd.Code='Flood_Cess'),0),2)) FC,
		
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND S1.PaymentType = 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Concession' OR Code = 'Concession_Discount')) AS ConcessionOnlineSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND S1.PaymentType = 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = '3D_Glasses' OR Code = '3D_Glasses_Discount')) AS ThreeDOnlineSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND S1.PaymentType = 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges')) AS OTCOnlineSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND S1.PaymentType <> 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Concession' OR Code = 'Concession_Discount')) AS ConcessionCounterSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND S1.PaymentType <> 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = '3D_Glasses' OR Code = '3D_Glasses_Discount')) AS ThreeDCounterSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND S1.PaymentType <> 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges')) AS OTCCounterSeatsSold

		FROM Seat S
			INNER JOIN Class ON S.ClassID = Class.ClassID
			INNER JOIN Show ON S.ShowID = Show.ShowID
		WHERE StatusType IN (2,3) AND S.ShowID =  @ShowId
		GROUP BY Class.ClassName, Class.ClassNo, Class.ClassID
	) P		
	GROUP BY NoOnlines, shwname, shwtime, scrname, mvname, ClassName, ClassNo, NoCounters, TotalBookedSeats, FreeSeat, CounterTA, OnlineTA, CounterThreeD, OnlineThreeD, 
	CounterFandB, OnlineFandB, ET, CGST, SGST, SC, AT, FDF, FC, CounterOTC, OnlineOTC ORDER BY ClassNo

	
	SELECT
		shwname, shwtime, scrname, mvname, ClassNo, ClassName, NoCounters, ISNULL(TotalBookedSeats, 0) totBlockCount,
		CounterTA, CounterThreeD, CounterFandB, SUM(ConcessionSeatsSold) CounterFAndBCount , SUM(ThreeDSeatsSold)CounterThreeDCount, CounterOTC, SUM(OTCSeatsSold) CounterOTCSeatsSold
	FROM
	(	
		SELECT DISTINCT MIN(Show.ShowName) AS shwname, MIN(Show.ShowTime) AS shwtime, MIN(Show.ScreenName) AS scrname,
		MIN(Show.MovieName) AS mvname,
		Class.ClassName, Class.ClassNo, MIN(Seat.DCRNo) AS StartDCRNo, MAX(Seat.DCRNo) AS EndDCRNo,
		(SELECT COUNT(1) FROM Seat WHERE StatusType IN (2,3) AND (QuotaType != 3 OR QuotaType = CASE WHEN Show.IsAdvanceToken = 1 THEN 3 ELSE 0 END) AND ShowID = @ShowId AND ClassID=Class.ClassID AND Seat.LastSoldByID = @UserId AND PaymentType <> 1) AS NoCounters,
		(SELECT COUNT(SeatId) FROM BookHistory WHERE ShowId = @ShowId AND SeatId IN (SELECT SeatId FROM Seat WHERE ClassID=Class.ClassID AND QuotaType!=3) AND BOBookingCode IS NULL AND BEBookingCode IS NULL AND BlockCode <> '' AND BookedById = @UserId) AS TotalBookedSeats,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Ticket_Amount'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) from seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Ticket_Amount_Discount'),0),2)) CounterTA,

		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='3D_Glasses'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='3D_Glasses_Discount'),0),2)) CounterThreeD,
		
		(ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Concession'),0),2)
		-ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Concession_Discount'),0),2)) CounterFandB,
		
		ROUND(ISNULL((SELECT SUM(pcd.price) FROM seat ts LEFT JOIN pricecarddetails pcd ON ts.pricecardid = pcd.pricecardid
		WHERE ts.ShowID=@ShowID AND ts.ClassID=Class.ClassID AND ts.StatusType IN (2,3) AND ts.LastSoldByID = @UserId AND ts.PaymentType <> 1 AND ts.PaymentType <> 5 AND pcd.Code='Other_Theatre_Charges'),0),2) CounterOTC,
		
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND LastSoldByID = @UserId AND S1.PaymentType <> 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Concession' OR Code = 'Concession_Discount')) AS ConcessionSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND LastSoldByID = @UserId AND S1.PaymentType <> 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = '3D_Glasses' OR Code = '3D_Glasses_Discount')) AS ThreeDSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM Seat S1 WHERE S1.ClassID = Class.ClassID AND LastSoldByID = @UserId AND S1.PaymentType <> 1 AND S1.StatusType IN (2, 3) AND PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges')) AS OTCSeatsSold
		
		FROM Seat			
			INNER JOIN Class ON Seat.ClassID = Class.ClassID
			INNER JOIN Show ON Seat.ShowID = Show.ShowID
		WHERE (StatusType=2 or StatusType=3) AND Seat.ShowID = @ShowId AND Seat.LastSoldByID = @UserId
		GROUP BY Class.ClassName, Class.ClassNo,Class.ClassID, Show.IsAdvanceToken
	) P
	GROUP BY shwname, shwtime, scrname, mvname, ClassName, ClassNo, NoCounters, TotalBookedSeats, CounterTA, CounterThreeD, CounterFandB, CounterOTC ORDER BY ClassNo

	SELECT COUNT(SeatId) FROM CancelHistory WHERE ShowId = @ShowId
	SELECT COUNT(SeatId) FROM CancelHistory WHERE ShowId = @ShowId AND CancelledByID= @UserId
END
GO

/* [QuickTicketsSalesSummaryReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuickTicketsSalesSummaryReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[QuickTicketsSalesSummaryReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [QuickTicketsSalesSummaryReport] 1, 1,0, '05 Jun 2016', '05 Jun 2016'
CREATE PROCEDURE [dbo].[QuickTicketsSalesSummaryReport]
	@theatreId INT,
	@screenId INT,
	@userId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11),
	@reportType INT
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, S.IsAdvanceToken FROM Show S WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND IsCancel = 0 AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, S.IsAdvanceToken FROM ShowMIS S WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND IsCancel = 0 AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType, QuotaType, StatusType, LastSoldByID FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType, QuotaType, StatusType, LastSoldByID FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT
	CONVERT(VARCHAR(20), QTSSR.ShowTime) [Show Time],
	QTSSR.UserId,
	QTSSR.PaymentType,
	QTSSR.MovieName [Movie Name],
	QTSSR.ScreenName [Screen Name],
	QTSSR.Capacity [Capacity],
	SUM(QTSSR.RegularSeatsSold) [No. of Regular Seats Sold],
	SUM(QTSSR.DefenceSeatsSold) [No. of Defence Seats Sold],
	SUM(QTSSR.ComplimentarySeatsSold) [No. of Complimentary Seats Sold],
	SUM(QTSSR.SeatsSold) [Total No. of Seats Sold],
	--SUM(QTSSR.ConcessionSeatsSold) [Total No. of F&B Package Sold],
	SUM(QTSSR.ThreeDSeatsSold) [Total No. of 3D Glass Package Sold],
	(SUM(QTSSR.SeatsSold) - SUM(QTSSR.OnlineSeatsSold)) [Total No. of Counter Sales], --[Total No. of Counter Sales(including POS Phone and Advance Token)],
	/*SUM(QTSSR.POSPhoneBlock) [No. of POS Phone Blockings],
	SUM(QTSSR.POSPhoneSold) [No. of POS Phone Bookings],
	SUM(QTSSR.POSPhoneCancelled) [No. of POS Phone Bookings Cancelled],
	SUM(QTSSR.UnpaidBookings) [No. of Unpaid Bookings],
	SUM(QTSSR.UnpaidBookingsPaymentReceived) [No. of Unpaid Bookings Payment Received (POS)],	
	SUM(QTSSR.UnpaidBookingsPaymentReceivedOnline) [No. of Unpaid Bookings Payment Received (Online)],
	SUM(QTSSR.UnpaidBookingsCancel) [No. of Unpaid Bookings Cancelled],*/
	SUM(QTSSR.OnlineSeatsSold) [Total No. of Online Sales],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.Gross [Gross Collection],
	SUM(QTSSR.PaidOTCSeatsSold) * QTSSR.OTC [Other Theatre Charges],
	SUM(QTSSR.PaidThreeDSeatsSold) * QTSSR.ThreeD [ThreeD Amount],
	SUM(QTSSR.PaidThreeDSeatsSold) * QTSSR.ThreeDBase [ThreeD Amount Base],
	SUM(QTSSR.PaidThreeDSeatsSold) * QTSSR.ThreeDCGST [ThreeD Amount CGST],
	SUM(QTSSR.PaidThreeDSeatsSold) * QTSSR.ThreeDSGST [ThreeD Amount SGST],
	--SUM(QTSSR.PaidConcessionSeatsSold) * QTSSR.FandB [FandB Amount],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.ET [Entertainment Tax Payable],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.CGST [CGST],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.SGST [SGST],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.SC [Service Charge],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.AT [Additional Tax],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.FC [Flood Cess],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.FDF [Film Development Fund],
	SUM(QTSSR.PaidSeatsSold) * QTSSR.BTA [Net Collection]
	INTO #QTSSR
	FROM
	(
	SELECT 
		Sh.Showtime, 
		Sh.MovieName ,
		Sh.ScreenName,
		(CASE WHEN S.QuotaType = 3 AND Sh.IsAdvanceToken = 0 THEN 0 ELSE S.LastSoldByID END) UserId,
		S.PaymentType,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.ShowID = Sh.ShowID) Capacity,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = 'Ticket_Amount_Discount'), 0) AS Gross,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = '3D_Glasses'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = '3D_Glasses_Discount'), 0) AS ThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Concession'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = 'Concession_Discount'), 0) AS FandB,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Other_Theatre_Charges'), 0) AS OTC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Base_3D_Glass_Fee'), 0) AS ThreeDBase,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST_3D_Glass'), 0) AS ThreeDCGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST_3D_Glass'), 0) AS ThreeDSGST,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 0)) AS RegularSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 1)) AS DefenceSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 2)) AS ComplimentarySeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Concession' OR Code = 'Concession_Discount')) AS ConcessionSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = '3D_Glasses' OR Code = '3D_Glasses_Discount')) AS ThreeDSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5 AND S.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Concession' OR Code = 'Concession_Discount')) AS PaidConcessionSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5 AND S.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = '3D_Glasses' OR Code = '3D_Glasses_Discount')) AS PaidThreeDSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5 AND S.PriceCardId IN (SELECT PriceCardId FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges')) AS PaidOTCSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5) AS PaidSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.QuotaType = 3 AND Sh.IsAdvanceToken = 0) AS OnlineSeatsSold,
		(SELECT COUNT(Bl.SeatId) FROM BlockHistory Bl WHERE Bl.SeatID = S.SeatID AND Bl.ShowID = Sh.ShowID AND Bl.BlockCode <> '' AND Bl.BlockedById = CASE WHEN @userId = 0 THEN Bl.BlockedById ELSE @userId END AND Bl.BlockedById <> 0) AS POSPhoneBlock,
		(SELECT COUNT(Bo.SeatId) FROM BookHistory Bo WHERE Bo.SeatID = S.SeatID  AND Bo.ShowId = Sh.ShowId AND Bo.BlockCode <> '' AND Bo.BlockCode IN (SELECT BlockCode FROM BlockHistory Bl WHERE Bl.BlockCode <> '') AND Bo.BookedByID = CASE WHEN @userId = 0 THEN Bo.BookedByID ELSE @userId END AND Bo.BookedByID <> 0) AS POSPhoneSold,
		(SELECT COUNT(C.SeatId) FROM CancelHistory C WHERE C.SeatID = S.SeatID AND C.BookedOn IN (SELECT BookedOn FROM BookHistory Bo WHERE Bo.ShowId = Sh.ShowId AND Bo.BlockCode IN (SELECT BlockCode FROM BlockHistory Bl WHERE Bl.BlockCode <> '' AND BlockedById <> 0)) AND C.ShowId = Sh.ShowID AND C.CancelledByID = CASE WHEN @userId = 0 THEN C.CancelledByID ELSE @userId END AND C.CancelledByID <> 0) AS POSPhoneCancelled,
		(SELECT COUNT(U.SeatId) FROM UnpaidBookings U WHERE U.SeatID = S.SeatID AND U.ShowId = Sh.ShowId AND U.BookedByID = CASE WHEN @userId = 0 THEN U.BookedByID ELSE @userId END AND U.BookedByID <> 0) AS UnpaidBookings,
		(SELECT COUNT(Bo.SeatId) FROM BookHistory Bo WHERE Bo.SeatID = S.SeatID  AND Bo.ShowId = Sh.ShowId AND Bo.BOBookingCode IN (SELECT BookingCode FROM UnpaidBookings U WHERE U.ShowId = Sh.ShowId) AND Bo.BookedByID = CASE WHEN @userId = 0 THEN Bo.BookedByID ELSE @userId END AND Bo.BookedByID <> 0) AS UnpaidBookingsPaymentReceived,
		(SELECT COUNT(Bo.SeatId) FROM BookHistory Bo WHERE Bo.SeatID = S.SeatID  AND Bo.ShowId = Sh.ShowId AND Bo.BOBookingCode IN (SELECT BookingCode FROM UnpaidBookings U WHERE U.ShowId = Sh.ShowId) AND Bo.BookedByID = 0) AS UnpaidBookingsPaymentReceivedOnline,
		(SELECT COUNT(C.SeatId) FROM CancelHistory C WHERE C.SeatID = S.SeatID AND C.BookedOn IN (SELECT BookedOn FROM BookHistory Bo WHERE Bo.ShowId = Sh.ShowId AND Bo.BOBookingCode IN (SELECT BookingCode FROM UnpaidBookings U WHERE U.ShowId = Sh.ShowId)) AND C.ShowId = Sh.ShowID AND C.CancelledByID = CASE WHEN @userId = 0 THEN C.CancelledByID ELSE @userId END AND C.CancelledByID <> 0) AS UnpaidBookingsCancel
	FROM #SeatMasterByDate S INNER JOIN #ShowMasterByDate Sh ON Sh.ShowID = S.ShowID AND S.LastSoldByID = CASE WHEN @userId = 0 THEN S.LastSoldByID ELSE @userId END
	GROUP BY Sh.ScreenName, Sh.ShowTime, Sh.MovieName, S.PriceCardId, S.SeatID, Sh.IsAdvanceToken, Sh.ShowId, S.LastSoldByID, S.PaymentType, S.QuotaType
	) QTSSR
	GROUP BY ScreenName, ShowTime, MovieName, Gross, ThreeD, FandB, ET, CGST, SGST, SC, AT, FC, FDF, OTC, ThreeDBase, ThreeDCGST, ThreeDSGST, SeatsSold, BTA, [Capacity], UserId, PaymentType
		
	SELECT [Show Time], [Movie Name], [Screen Name], Capacity,
	SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
	SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
	SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
	SUM([Total No. of Seats Sold])[Total No. of Seats Sold], 
	--SUM([Total No. of Counter Sales(including POS Phone and Advance Token)]) [Total No. of Counter Sales(including POS Phone and Advance Token)],
	SUM([Total No. of Counter Sales]) [Total No. of Counter Sales],
	/*SUM([No. of POS Phone Blockings]) [No. of POS Phone Blockings], 
	SUM([No. of POS Phone Bookings]) [No. of POS Phone Bookings], 
	SUM([No. of POS Phone Bookings Cancelled]) [No. of POS Phone Bookings Cancelled],
	SUM([No. of Unpaid Bookings]) [No. of Unpaid Bookings],
	SUM([No. of Unpaid Bookings Payment Received (POS)]) [No. of Unpaid Bookings Payment Received (POS)],
	SUM([No. of Unpaid Bookings Payment Received (Online)]) [No. of Unpaid Bookings Payment Received (Online)],
	SUM([No. of Unpaid Bookings Cancelled]) [No. of Unpaid Bookings Cancelled],*/
	SUM([Total No. of Online Sales])[Total No. of Online Sales], 
	--SUM([Total No. of F&B Package Sold]) [Total No. of F&B Package Sold],
	SUM([Total No. of 3D Glass Package Sold]) [Total No. of 3D Glass Package Sold],
	SUM([Gross Collection])[Gross Collection], 
	SUM([Other Theatre Charges]) [Other Theatre Charges],
	SUM([ThreeD Amount]) [ThreeD Amount],
	SUM([ThreeD Amount Base]) [ThreeD Amount Base],
	SUM([ThreeD Amount CGST]) [ThreeD Amount CGST],
	SUM([ThreeD Amount SGST]) [ThreeD Amount SGST],
	--SUM([FandB Amount]) [FandB Amount],
	SUM([Entertainment Tax Payable])[Entertainment Tax Payable],
	SUM([CGST])CGST,
	SUM([SGST])SGST,
	SUM([Service Charge])[Service Charge], 
	SUM([Additional Tax])[Additional Tax],
	SUM([Flood Cess])[Flood Cess],
	SUM([Film Development Fund])[Film Development Fund], 
	SUM([Net Collection])[Net Collection] INTO #QTSSRFinal FROM #QTSSR
	GROUP BY [Show Time], [Movie Name], [Screen Name], Capacity
	
	DROP TABLE #ShowMasterByDate
		
	SELECT [Show Time][Show Date & Time], [Movie Name], [Screen Name], Capacity, 
	CONVERT(VARCHAR, CONVERT(DECIMAL(18,2),(CAST(SUM([Total No. of Seats Sold]) AS NUMERIC(9,2)) * 100) /CAST(Capacity AS NUMERIC(9,2)))) + '%' [Occupancy%],
	SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
	SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
	SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
	SUM([Total No. of Seats Sold])[Total No. of Seats Sold], 
	SUM([Total No. of Counter Sales]) [Total No. of Counter Sales],
	--SUM([Total No. of Counter Sales(including POS Phone and Advance Token)]) [Total No. of Counter Sales(including POS Phone and Advance Token)],
	/*SUM([No. of POS Phone Blockings])[No. of POS Phone Blockings], 
	SUM([No. of POS Phone Bookings])[No. of POS Phone Bookings], 
	SUM([No. of POS Phone Bookings Cancelled]) [No. of POS Phone Bookings Cancelled],
	SUM([No. of Unpaid Bookings]) [No. of Unpaid Bookings],
	SUM([No. of Unpaid Bookings Payment Received (POS)]) [No. of Unpaid Bookings Payment Received (POS)],
	SUM([No. of Unpaid Bookings Payment Received (Online)]) [No. of Unpaid Bookings Payment Received (Online)],
	SUM([No. of Unpaid Bookings Cancelled]) [No. of Unpaid Bookings Cancelled],*/
	SUM([Total No. of Online Sales])[Total No. of Online Sales], 
	SUM([Gross Collection])[Gross Collection],
	SUM([Other Theatre Charges]) [Other Theatre Charges],
	SUM([ThreeD Amount]) [ThreeD Amount],
	SUM([ThreeD Amount Base]) [ThreeD Amount Base],
	SUM([ThreeD Amount CGST]) [ThreeD Amount CGST],
	SUM([ThreeD Amount SGST]) [ThreeD Amount SGST],
	--SUM([FandB Amount]) [FandB Amount],
	SUM([Entertainment Tax Payable])[Entertainment Tax Payable],
	SUM(CGST) CGST,
	SUM([SGST])SGST,
	SUM([Service Charge])[Service Charge], 
	SUM([Additional Tax])[Additional Tax], 
	SUM([Flood Cess])[Flood Cess],
	SUM([Film Development Fund])[Film Development Fund],
	SUM([Net Collection])[Net Collection] INTO #QT FROM #QTSSRFinal
	GROUP BY [Show Time], [Movie Name], [Screen Name], Capacity
	
	INSERT INTO #QT
	SELECT '', '', '', SUM(Capacity), 
	CONVERT(VARCHAR, CONVERT(DECIMAL(18,2),(CAST(SUM([Total No. of Seats Sold]) AS NUMERIC(9,2)) * 100) /CAST(SUM(Capacity) AS NUMERIC(9,2)))) + '%' [Occupancy%], 
	SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
	SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
	SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
	SUM([Total No. of Seats Sold])[Total No. of Seats Sold], 
	SUM([Total No. of Counter Sales]) [Total No. of Counter Sales],
	--SUM([Total No. of Counter Sales(including POS Phone and Advance Token)]) [Total No. of Counter Sales(including POS Phone and Advance Token)],
	/*SUM([No. of POS Phone Blockings])[No. of POS Phone Blockings], 
	SUM([No. of POS Phone Bookings])[No. of POS Phone Bookings], 
	SUM([No. of POS Phone Bookings Cancelled]) [No. of POS Phone Bookings Cancelled],
	SUM([No. of Unpaid Bookings]) [No. of Unpaid Bookings],
	SUM([No. of Unpaid Bookings Payment Received (POS)]) [No. of Unpaid Bookings Payment Received (POS)],
	SUM([No. of Unpaid Bookings Payment Received (Online)]) [No. of Unpaid Bookings Payment Received (Online)],
	SUM([No. of Unpaid Bookings Cancelled]) [No. of Unpaid Bookings Cancelled],*/
	SUM([Total No. of Online Sales])[Total No. of Online Sales], 
	SUM([Gross Collection])[Gross Collection],
	SUM([Other Theatre Charges]) [Other Theatre Charges],
	SUM([ThreeD Amount]) [ThreeD Amount],
	SUM([ThreeD Amount Base]) [ThreeD Amount Base],
	SUM([ThreeD Amount CGST]) [ThreeD Amount CGST],
	SUM([ThreeD Amount SGST]) [ThreeD Amount SGST],
	--SUM([FandB Amount]) [FandB Amount],
	SUM([Entertainment Tax Payable])[Entertainment Tax Payable],
	SUM(CGST) CGST,
	SUM([SGST])SGST,
	SUM([Service Charge])[Service Charge], 
	SUM([Additional Tax])[Additional Tax],
	SUM([Flood Cess])[Flood Cess],
	SUM([Film Development Fund])[Film Development Fund], 
	SUM([Net Collection])[Net Collection] FROM #QT

	INSERT INTO #QT([Show Date & Time], [Movie Name], [Screen Name])
	SELECT '', '', ''
	
	IF (@reportType=0 or @reportType=1)
	BEGIN
		SELECT SUBSTRING(CONVERT(VARCHAR(11), [Show Date & Time] , 101), 1, 11) [Show Date], SUBSTRING(CAST([Show Date & Time] AS VARCHAR), 12, 20) [Show Time],  [Movie Name], [Screen Name], Capacity, 
		[Occupancy%], [No. of Regular Seats Sold], [No. of Defence Seats Sold],	[No. of Complimentary Seats Sold],	[Total No. of Seats Sold],  
		[Total No. of Counter Sales],
		--[Total No. of Counter Sales(including POS Phone and Advance Token)], 
		--[No. of POS Phone Blockings], 	[No. of POS Phone Bookings], 
		--[No. of POS Phone Bookings Cancelled], [No. of Unpaid Bookings], [No. of Unpaid Bookings Payment Received (POS)], [No. of Unpaid Bookings Payment Received (Online)], 
		--[No. of Unpaid Bookings Cancelled], 
		[Total No. of Online Sales], [Gross Collection], [Other Theatre Charges], [ThreeD Amount] [3D Glass Amount], 
		[ThreeD Amount Base] [Base 3D Glass Fee],
		[ThreeD Amount CGST] [CGST 3D Glass], [ThreeD Amount SGST] [SGST 3D Glass],
		--[FandB Amount] [F&B Amount], 
		[Entertainment Tax Payable], CGST, [SGST], [Service Charge], [Additional Tax], [Flood Cess], [Film Development Fund], [Net Collection] FROM #QT 
		ORDER BY CAST([Show Date & Time] AS DATE) DESC, CAST([Show Date & Time] AS TIME) DESC, [Screen Name], [Movie Name], [Capacity]
	END
	DROP TABLE #QT
	
	IF (@reportType=0 or @reportType=2)
	BEGIN
		SELECT
		CONVERT(VARCHAR(11), [Show Time]) [Session Date], SUM(Capacity) Capacity,
		CONVERT(VARCHAR, CONVERT(DECIMAL(18,2),(CAST(SUM([Total No. of Seats Sold]) AS NUMERIC(9,2)) * 100) /CAST(SUM(Capacity) AS NUMERIC(9,2)))) + '%' [Occupancy%], 
		SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
		SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
		SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
		SUM([Total No. of Seats Sold])[Total No. of Seats Sold], 
		SUM([Total No. of Counter Sales]) [Total No. of Counter Sales],
		--SUM([Total No. of Counter Sales(including POS Phone and Advance Token)]) [Total No. of Counter Sales(including POS Phone and Advance Token)],
		/*SUM([No. of POS Phone Blockings])[No. of POS Phone Blockings], 
		SUM([No. of POS Phone Bookings])[No. of POS Phone Bookings], 
		SUM([No. of POS Phone Bookings Cancelled]) [No. of POS Phone Bookings Cancelled],
		SUM([No. of Unpaid Bookings]) [No. of Unpaid Bookings],
		SUM([No. of Unpaid Bookings Payment Received (POS)]) [No. of Unpaid Bookings Payment Received (POS)],
		SUM([No. of Unpaid Bookings Payment Received (Online)]) [No. of Unpaid Bookings Payment Received (Online)],
		SUM([No. of Unpaid Bookings Cancelled]) [No. of Unpaid Bookings Cancelled],*/
		SUM([Total No. of Online Sales])[Total No. of Online Sales], 
		--SUM([Total No. of F&B Package Sold]) [Total No. of F&B Package Sold],
		SUM([Total No. of 3D Glass Package Sold]) [Total No. of 3D Glass Package Sold],
		SUM([Gross Collection]) [Gross Collection],
		SUM([Other Theatre Charges]) [Other Theatre Charges],
		SUM([ThreeD Amount]) [3D Glass Amount],
		SUM([ThreeD Amount Base]) [Base 3D Glass Fee],
		SUM([ThreeD Amount CGST]) [CGST 3D Glass], SUM([ThreeD Amount SGST]) [SGST 3D Glass],
		--SUM([FandB Amount]) [F&B Amount],
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable],
		SUM(CGST) CGST,
		SUM([SGST])SGST,
		SUM([Service Charge]) [Service Charge],
		SUM([Additional Tax]) [Additional Tax],
		SUM([Flood Cess])[Flood Cess],
		SUM([Film Development Fund])[Film Development Fund],
		SUM([Net Collection]) [Net Collection]
		FROM #QTSSRFinal
		GROUP BY CONVERT(VARCHAR(11), [Show Time])
	END

	IF (@reportType=0 or @reportType=3)
	BEGIN
		SELECT
		[Screen Name],
		SUM(Capacity) Capacity,
		CONVERT(VARCHAR, CONVERT(DECIMAL(18,2),(CAST(SUM([Total No. of Seats Sold]) AS NUMERIC(9,2)) * 100) /CAST(SUM(Capacity) AS NUMERIC(9,2)))) + '%' [Occupancy%], 
		SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
		SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
		SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
		SUM([Total No. of Seats Sold])[Total No. of Seats Sold], 
		SUM([Total No. of Counter Sales]) [Total No. of Counter Sales],
		--SUM([Total No. of Counter Sales(including POS Phone and Advance Token)]) [Total No. of Counter Sales(including POS Phone and Advance Token)],
		/*SUM([No. of POS Phone Blockings])[No. of POS Phone Blockings], 
		SUM([No. of POS Phone Bookings])[No. of POS Phone Bookings], 
		SUM([No. of POS Phone Bookings Cancelled]) [No. of POS Phone Bookings Cancelled],
		SUM([No. of Unpaid Bookings]) [No. of Unpaid Bookings],
		SUM([No. of Unpaid Bookings Payment Received (POS)]) [No. of Unpaid Bookings Payment Received (POS)],
		SUM([No. of Unpaid Bookings Payment Received (Online)]) [No. of Unpaid Bookings Payment Received (Online)],
		SUM([No. of Unpaid Bookings Cancelled]) [No. of Unpaid Bookings Cancelled],*/
		SUM([Total No. of Online Sales])[Total No. of Online Sales], 
		--SUM([Total No. of F&B Package Sold]) [Total No. of F&B Package Sold],
		SUM([Total No. of 3D Glass Package Sold]) [Total No. of 3D Glass Package Sold],
		SUM([Gross Collection]) [Gross Collection],
		SUM([Other Theatre Charges]) [Other Theatre Charges],
		SUM([ThreeD Amount]) [3D Glass Amount],
		SUM([ThreeD Amount Base]) [Base 3D Glass Fee],
		SUM([ThreeD Amount CGST]) [CGST 3D Glass], SUM([ThreeD Amount SGST]) [SGST 3D Glass],
		--SUM([FandB Amount]) [F&B Amount],
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable],
		SUM(CGST) CGST,
		SUM([SGST])SGST,
		SUM([Service Charge]) [Service Charge],
		SUM([Additional Tax]) [Additional Tax],
		SUM([Flood Cess])[Flood Cess],
		SUM([Film Development Fund])[Film Development Fund],
		SUM([Net Collection]) [Net Collection]
		FROM #QTSSRFinal
		GROUP BY [Screen Name]
	END
	
	IF (@reportType=0 or @reportType=4)
	BEGIN
		SELECT
		[Movie Name],
		SUM(Capacity) Capacity, 
		CONVERT(VARCHAR, CONVERT(DECIMAL(18,2),(CAST(SUM([Total No. of Seats Sold]) AS NUMERIC(9,2)) * 100) /CAST(SUM(Capacity) AS NUMERIC(9,2)))) + '%' [Occupancy%], 
		SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
		SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
		SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
		SUM([Total No. of Seats Sold])[Total No. of Seats Sold], 
		SUM([Total No. of Counter Sales]) [Total No. of Counter Sales],
		--SUM([Total No. of Counter Sales(including POS Phone and Advance Token)]) [Total No. of Counter Sales(including POS Phone and Advance Token)],
		/*SUM([No. of POS Phone Blockings])[No. of POS Phone Blockings], 
		SUM([No. of POS Phone Bookings])[No. of POS Phone Bookings], 
		SUM([No. of POS Phone Bookings Cancelled]) [No. of POS Phone Bookings Cancelled],
		SUM([No. of Unpaid Bookings]) [No. of Unpaid Bookings],
		SUM([No. of Unpaid Bookings Payment Received (POS)]) [No. of Unpaid Bookings Payment Received (POS)],
		SUM([No. of Unpaid Bookings Payment Received (Online)]) [No. of Unpaid Bookings Payment Received (Online)],
		SUM([No. of Unpaid Bookings Cancelled]) [No. of Unpaid Bookings Cancelled],*/
		SUM([Total No. of Online Sales])[Total No. of Online Sales], 
		--SUM([Total No. of F&B Package Sold]) [Total No. of F&B Package Sold],
		SUM([Total No. of 3D Glass Package Sold]) [Total No. of 3D Glass Package Sold],
		SUM([Gross Collection]) [Gross Collection],
		SUM([Other Theatre Charges]) [Other Theatre Charges],
		SUM([ThreeD Amount]) [3D Glass Amount],
		SUM([ThreeD Amount Base]) [Base 3D Glass Fee],
		SUM([ThreeD Amount CGST]) [CGST 3D Glass], SUM([ThreeD Amount SGST]) [SGST 3D Glass],
		--SUM([FandB Amount]) [F&B Amount],
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable],
		SUM(CGST) CGST,
		SUM([SGST])SGST,
		SUM([Service Charge]) [Service Charge],
		SUM([Additional Tax]) [Additional Tax],
		SUM([Flood Cess])[Flood Cess],
		SUM([Film Development Fund])[Film Development Fund],
		SUM([Net Collection]) [Net Collection]
		FROM #QTSSRFinal
		GROUP BY [Movie Name]
	END

	IF (@reportType=0 or @reportType=5)
	BEGIN
		SELECT
		(SELECT UserName FROM BoxOfficeUser B WHERE B.UserId = #QTSSR.UserId) [User Name],
		SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
		SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
		SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
		SUM([Total No. of Seats Sold])[Total No. of Seats Sold],
		--SUM([Total No. of F&B Package Sold]) [Total No. of F&B Package Sold],
		SUM([Total No. of 3D Glass Package Sold]) [Total No. of 3D Glass Package Sold],
		SUM([Gross Collection]) [Gross Collection],
		SUM([Other Theatre Charges]) [Other Theatre Charges],
		SUM([ThreeD Amount]) [3D Glass Amount],
		SUM([ThreeD Amount Base]) [Base 3D Glass Fee],
		SUM([ThreeD Amount CGST]) [CGST 3D Glass], SUM([ThreeD Amount SGST]) [SGST 3D Glass],
		--SUM([FandB Amount]) [F&B Amount],
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable],
		SUM(CGST) CGST,
		SUM([SGST])SGST,
		SUM([Service Charge]) [Service Charge],
		SUM([Additional Tax]) [Additional Tax],
		SUM([Flood Cess])[Flood Cess],
		SUM([Film Development Fund])[Film Development Fund],
		SUM([Net Collection]) [Net Collection]
		FROM #QTSSR WHERE #QTSSR.UserId <> 0
		GROUP BY UserId
	END

	IF (@reportType=0 or @reportType=6)
	BEGIN
		SELECT
		(SELECT Expression FROM Type T WHERE T.TypeName = 'PaymentType' AND T.Value = #QTSSR.PaymentType) [Payment Type],
		SUM([No. of Regular Seats Sold]) [No. of Regular Seats Sold],
		SUM([No. of Defence Seats Sold]) [No. of Defence Seats Sold],
		SUM([No. of Complimentary Seats Sold]) [No. of Complimentary Seats Sold],
		SUM([Total No. of Seats Sold])[Total No. of Seats Sold],
		--SUM([Total No. of F&B Package Sold]) [Total No. of F&B Package Sold],
		SUM([Total No. of 3D Glass Package Sold]) [Total No. of 3D Glass Package Sold],
		SUM([Gross Collection]) [Gross Collection],
		SUM([Other Theatre Charges]) [Other Theatre Charges],
		SUM([ThreeD Amount]) [3D Glass Amount],
		SUM([ThreeD Amount Base]) [Base 3D Glass Fee],
		SUM([ThreeD Amount CGST]) [CGST 3D Glass], SUM([ThreeD Amount SGST]) [SGST 3D Glass],
		--SUM([FandB Amount]) [F&B Amount],
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable],
		SUM(CGST) CGST,
		SUM([SGST])SGST,
		SUM([Service Charge]) [Service Charge],
		SUM([Additional Tax]) [Additional Tax],
		SUM([Flood Cess])[Flood Cess],
		SUM([Film Development Fund])[Film Development Fund],
		SUM([Net Collection]) [Net Collection]
		FROM #QTSSR
		GROUP BY PaymentType
	END

	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMasterByDate))
	UNION ALL
	SELECT Code FROM PriceCardItems WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMasterByDate) AND Code = 'Other_Theatre_Charges')
	DROP TABLE #SeatMasterByDate
	DROP TABLE #QTSSR
	DROP TABLE #QTSSRFinal
END
GO

/* UpdateSeatAndLoadClass */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateSeatAndLoadClass]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateSeatAndLoadClass
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--UpdateSeatAndLoadClass 27701, 28694
CREATE PROCEDURE [dbo].UpdateSeatAndLoadClass
@ShowID INT,
@ClassID INT
AS
	--To release POS Phone blocked seats
	UPDATE Seat SET QuotaType=0, StatusType=0, TicketID = 0, PatronInfo='', LastBlockedByID = 0 WHERE ShowID = @ShowID AND Quotatype !=3 AND StatusType=1 AND NoBlocks > NoCancels AND NoBlocks > 0 AND LastBlockedByID > 0 AND GETDATE()>DATEADD(mi,-ReleaseBefore,(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release Tele-Booking Quota to counter seats
	UPDATE Seat SET QuotaType=0, PatronInfo='' WHERE ShowID = @ShowID AND quotaType = 2 AND StatusType=0 AND GETDATE()>DATEADD(mi,-ReleaseBefore,(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release Manager quota to counter quota based on Manager Quota Release Time
	UPDATE Seat SET QuotaType=0, PatronInfo='' WHERE ShowID = @ShowID AND quotaType = 1 AND StatusType=0 AND GETDATE()>DATEADD(mi,-(SELECT ManagerQuotaReleaseTime FROM Show WHERE ShowID=Seat.ShowID),(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release online advance token blocked seats to counter seats based on Advance Token Buffer Time
	UPDATE Seat SET StatusType=0, TicketID = 0, QuotaType=0, PatronInfo='' WHERE ShowID = @ShowID AND Quotatype = 3 AND StatusType=1 AND GETDATE()>DATEADD(mi,-(SELECT AdvanceTokenBufferTime FROM Show WHERE ShowID=Seat.ShowID),(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release online unbooked seats
	UPDATE Seat SET QuotaType=0, NoBlocks=0 WHERE ShowId IN (SELECT showId FROM Show WHERE showId=@ShowID AND IsOnlineSaleClosed = 1) AND QuotaType=3 AND StatusType=0;
	--To release Unpaid Bookings to counter available seats based on Unpaid Booking Release Time
	UPDATE Seat SET QuotaType=0, StatusType=0, TicketID = 0, PatronInfo='', LastSoldOn = NULL, LastSoldByID = 0 WHERE StatusType=6 AND GETDATE()>DATEADD(mi,-(SELECT UnpaidBookingReleaseTime FROM Show WHERE ShowID=Seat.ShowID),(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))

	Select
	SeatID,
	TicketID,
	SeatType,
	SeatLabel,
	RowNo,
	ColNo,
	StatusType,
	QuotaType,
	ReleaseBefore,
	ISNULL(lastsoldon,'') AS LastSoldOn,
	ISNULL((select top 1(seatid) from Seat st where statustype=2 and st.ShowID = @ShowID AND st.ClassID = @ClassID order by lastsoldon desc, seatid desc),0) as LastSoldTicket,
	ISNULL((select IsAdvanceToken from Show where ShowId=Seat.ShowId),0) IsAdvanceToken,
	ISNULL((select Experiences from Show where ShowId= Seat.ShowId), 0) Experiences,
	(CASE WHEN SeatID IN (select DISTINCT SeatID from ChangeQuotaDetails WHERE [Status] = 0) THEN 1 ELSE 0 END) AS IsQuotaChangeRequest,
	ISNULL((select AdvanceTokenReleaseTime from Show where ShowId=Seat.ShowId),0) AdvanceTokenReleaseTime,
	PriceCardId,
	PaymentType,
	ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(PatronInfo, '|') WHERE ID = 3), 'nil') AS MobileNumber
	FROM Seat
	WHERE ShowID = @ShowID
	AND ClassID = @ClassID
	GROUP BY  SeatID, TicketID, SeatType, SeatLabel, RowNo, ColNo, StatusType, QuotaType, ReleaseBefore, lastsoldon, ScreenId, ShowId, PriceCardId, PaymentType, PatronInfo ORDER BY SeatID
GO
/* RequestChangeQuota */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].RequestChangeQuota') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].RequestChangeQuota
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--RequestChangeQuota 529, '425843,425844,425883,425884', 2108
CREATE PROCEDURE [dbo].RequestChangeQuota
	@ShowID INT,
	@SeatIDs VARCHAR(MAX),
	@ClassID INT,
	@ReferenceID UNIQUEIDENTIFIER
AS
BEGIN
	IF (SELECT IsOnlineSaleClosed FROM Show WHERE ShowID = @ShowID) = 1
		BEGIN
			RAISERROR('Change quota request cannot be processed as online sales is closed.', 11, 1)
			RETURN
		END
	ELSE IF EXISTS(SELECT SeatId FROM ChangeQuotaDetails WHERE SeatId IN (SELECT SeatId FROM Seat WHERE ShowID = @ShowID) AND [Status] = 0)
		BEGIN
			RAISERROR('The previous change quota request is being processed. Try again later, or contact YourScreens Support Team!', 11, 1)
			RETURN
		END
	ELSE
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION 
					CREATE TABLE #UserSelectedIds (SeatID BIGINT)
					CREATE TABLE #UserSelectedCoupleIds (CoupleId BIGINT)

					INSERT INTO #UserSelectedIds
					SELECT SeatID FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@SeatIDs, ',')) AND SeatType <> 1

					CREATE TABLE #Couple (SlNo INT IDENTITY(1,1), CId INT, ShowId INT)
					INSERT INTO #Couple(CId, ShowId) SELECT SeatID, ShowId FROM Seat WHERE SeatID IN (SELECT SeatID FROM #UserSelectedIds) AND SeatType = 2

					CREATE TABLE #RequestingIds (ID BIGINT)
					INSERT INTO #RequestingIds --Collect all the selected seatIds along with the combination id's of couple seats.
					SELECT SeatID FROM Seat WHERE SeatID IN (SELECT SeatID FROM #UserSelectedIds) AND SeatType != 2

					INSERT INTO #RequestingIds -- Collect all the online seats Ids
					SELECT SeatID FROM Seat WHERE ShowId = @ShowID AND QuotaType = 3 AND SeatID NOT IN (SELECT SeatID FROM #UserSelectedIds)  AND SeatType <> 1

					DECLARE @i INT
					SET @i = 1
					DECLARE @maxi INT
					SET @maxi = (SELECT COUNT(*) FROM #couple)
					WHILE (@maxi >= @i)
					BEGIN
						DECLARE @CoupleSeatIds NVARCHAR(50)
						SET @CoupleSeatIds = NULL		
						SELECT @CoupleSeatIds = CoupleSeatIds FROM Seat WHERE SeatID IN (SELECT CId FROM #Couple WHERE #Couple.SlNo = @i)
					
						INSERT INTO #UserSelectedCoupleIds
						SELECT SeatId FROM Seat WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@CoupleSeatIds, ',')) AND ShowID IN (SELECT ShowId FROM #Couple WHERE #Couple.SlNo = @i)
						SET @i = @i + 1
					END
					DROP TABLE #Couple
					
					INSERT INTO #RequestingIds SELECT CoupleId FROM #UserSelectedCoupleIds
					INSERT INTO #UserSelectedIds SELECT CoupleId FROM #UserSelectedCoupleIds
					
					DROP TABLE #UserSelectedCoupleIds

					INSERT INTO ChangeQuotaDetails(ReferenceID, SeatId, SeatClassInfo, ChangeQuotaType, [Status], [Approved])
					SELECT @ReferenceID, SeatID, SeatClassInfo, (CASE WHEN QuotaType = 3 THEN 1 ELSE 0 END), 0, 0 FROM Seat WHERE SeatID IN (SELECT SeatID FROM #UserSelectedIds) AND StatusType = 0

					DECLARE @ModifiedSeatIds VARCHAR(4000)
					SELECT @ModifiedSeatIds = STUFF((SELECT ','+ CONVERT(NVARCHAR(10),SeatId) FROM ChangeQuotaDetails WHERE ReferenceId = @ReferenceID FOR XML PATH('')),1,1,'')

					--decrease quota
					DELETE FROM #RequestingIds WHERE ID IN (SELECT SeatID FROM Seat WHERE SeatID IN (SELECT SeatID FROM #UserSelectedIds) AND Statustype = 0 AND QuotaType = 3)

					SELECT STUFF((SELECT ',' + '"' + SeatClassInfo + '"'  FROM Seat WHERE SeatID IN (SELECT ID FROM #RequestingIds) AND StatusType IN (CASE WHEN QuotaType <> 3 THEN 0 ELSE StatusType END) AND SeatType <> 1 FOR XML PATH('')),1,1,'') As SeatLabels, @ModifiedSeatIds As modifiedSeatIds
					
					DROP TABLE #UserSelectedIds
					DROP TABLE #RequestingIds
				COMMIT
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
				ROLLBACK
			END CATCH
		END
	END
GO

/* GetActiveReferenceIdByShow */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].GetActiveReferenceIdByShow') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].GetActiveReferenceIdByShow
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--GetActiveReferenceIdByShow '3640eaf5-56c5-4d67-bdf0-d279058bef70'
CREATE PROCEDURE [dbo].GetActiveReferenceIdByShow
	@SessionID VARCHAR(64)
AS
	SELECT DISTINCT ReferenceID FROM ChangeQuotaDetails WHERE [Status] = 0 AND SeatId IN (SELECT SeatId FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE OnlineShowId = @SessionID))
GO

/* UpdateSeatChangeQuotaDetails */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].UpdateSeatChangeQuotaDetails') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateSeatChangeQuotaDetails
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--UpdateSeatChangeQuotaDetails '3640eaf5-56c5-4d67-bdf0-d279058bef70'

CREATE PROCEDURE [dbo].UpdateSeatChangeQuotaDetails
	@SessionId VARCHAR(64),
	@SeatclassInfo VARCHAR(MAX),
	@ReferenceId UNIQUEIDENTIFIER
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION 
			SELECT items INTO #SeatclassInfo FROM dbo.fnsplit(@SeatclassInfo, ',')
			UPDATE ChangeQuotaDetails SET [Status] = 1, Approved = (CASE WHEN SeatclassInfo IN (SELECT Items FROM #SeatclassInfo) THEN 1 ELSE 0 END) WHERE ReferenceId = @ReferenceId AND ChangeQuotaType = 0
			UPDATE ChangeQuotaDetails SET [Status] = 1, Approved = (CASE WHEN SeatclassInfo NOT IN (SELECT Items FROM #SeatclassInfo) THEN 1 ELSE 0 END) WHERE ReferenceId = @ReferenceId AND ChangeQuotaType = 1
			UPDATE Seat SET QuotaType = (CASE WHEN SeatID IN (SELECT SeatID FROM ChangeQuotaDetails WHERE ReferenceId = @ReferenceId AND Approved = 1 AND ChangeQuotaType = 0) THEN 3 ELSE (CASE WHEN SeatID IN (SELECT SeatID FROM ChangeQuotaDetails WHERE ReferenceId = @ReferenceId AND Approved = 1 AND ChangeQuotaType = 1) THEN 0 ELSE QuotaType END) END)
			DROP TABLE #SeatclassInfo
		COMMIT
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0
		   ROLLBACK
	END CATCH
END	
GO

/* [ActivityLog] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivityLog]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ActivityLog]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[ActivityLog] '01-07-2022', '21-07-2022', 1

CREATE PROCEDURE [dbo].[ActivityLog]
	@fromDate VARCHAR(10),
	@toDate VARCHAR(10),
	@userId INT
AS
BEGIN
	DECLARE @sql varchar(2000)
	IF @userId <= 0
	BEGIN
		SELECT TransactionTime, TransactionByName, [Action], TransactionDetail FROM (
			SELECT TransactionTime, TransactionByName, [Action], TransactionDetail, ROW_NUMBER() OVER(ORDER BY LogID DESC) AS Row FROM
				(
					SELECT TransactionTime, TransactionByName, [Action], TransactionDetail, TransactionByID, LogID FROM Log
					UNION
					SELECT TransactionTime, TransactionByName, [Action], TransactionDetail, TransactionByID, LogID FROM LogMIS
				)A
				WHERE
					CONVERT(DATETIME,CONVERT(VARCHAR,TransactionTime,103),103) BETWEEN CONVERT(DATETIME,CONVERT(VARCHAR, @fromDate,103),103)
					AND CONVERT(DATETIME,CONVERT(VARCHAR, @toDate,103),103)) B
	END
	ELSE
	BEGIN
		SELECT TransactionTime, TransactionByName, [Action], TransactionDetail FROM (
			SELECT TransactionTime, TransactionByName, [Action], TransactionDetail, ROW_NUMBER() OVER(ORDER BY LogID DESC) AS Row FROM
				(
					SELECT TransactionTime, TransactionByName, [Action], TransactionDetail, TransactionByID, LogID FROM Log
					UNION
					SELECT TransactionTime, TransactionByName, [Action], TransactionDetail, TransactionByID, LogID FROM LogMIS
				)A
				WHERE
					CONVERT(DATETIME,CONVERT(VARCHAR,TransactionTime,103),103) BETWEEN CONVERT(DATETIME,CONVERT(VARCHAR, @fromDate,103),103)
					AND CONVERT(DATETIME,CONVERT(VARCHAR, @toDate,103),103) AND TransactionByID = @userId) B
	END
END
GO

/* DeleteChangeQuotaRequests */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].DeleteChangeQuotaRequests') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].DeleteChangeQuotaRequests
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--DeleteChangeQuotaRequests '425843,425844,425883,425884'
CREATE PROCEDURE [dbo].DeleteChangeQuotaRequests
	@ReferenceId UNIQUEIDENTIFIER
AS
	DELETE FROM ChangeQuotaDetails WHERE ReferenceId = @ReferenceId
GO

/* [GetBlockSalesInfoByShow] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetBlockSalesInfoByShow]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].GetBlockSalesInfoByShow
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[GetBlockSalesInfoByShow] 684

CREATE PROCEDURE [dbo].GetBlockSalesInfoByShow
(@ShowId AS BIGINT)
AS
BEGIN
	IF EXISTS(SELECT ShowId FROM Show WHERE ShowID = @ShowId AND IsBlockSalesDataSent = 0)
	BEGIN
		SELECT (SELECT OnlineShowId FROM Show WHERE ShowID = @ShowID), (SELECT REPLACE(A.BlockCode + A.Seats, ',],', '],') FROM (SELECT DISTINCT  '"' + BH.BlockCode + '": ' AS BlockCode, '[' + ((SELECT '"' + BOH.SeatClassInfo + '",' FROM BookHistory BOH WHERE BOH.BlockCode = BH.BlockCode FOR XML PATH(''),TYPE).value('(.)[1]','NVARCHAR(MAX)')) + '],' AS Seats FROM BookHistory BH WHERE BH.BlockCode <> '' AND BH.BookedByID <> 0 AND BH.ShowId = @ShowId) AS A FOR XML PATH(''),TYPE).value('(.)[1]','NVARCHAR(MAX)')
		UPDATE Show SET IsBlockSalesDataSent = 1 WHERE ShowID = @ShowID
	END
END
GO

/* [TransactionReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TransactionReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TransactionReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[TransactionReport] 1002, 0, 1, '16 Jul 2020', '16 Jul 2020'

CREATE PROCEDURE [dbo].[TransactionReport]
	@theatreId INT,
	@screenId INT,
	@userId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
AS
BEGIN
--TempSeatMaster
	SELECT * INTO #TempSeatMaster
	FROM
	(
		SELECT SeatID, ClassID, SeatLabel, ScreenID, ShowID, PriceCardId FROM Seat WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT SeatID, ClassID, SeatLabel, ScreenID, ShowID, PriceCardId FROM SeatMIS WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	)
	AS TempSeatMaster

	--PrintedSeatsCollection
	SELECT * INTO #PrintedSeatMaster
	FROM
	(			
		SELECT BookHistory.*, S.ClassID, S.SeatLabel FROM BookHistory INNER JOIN #TempSeatMaster S ON S.SeatId = BookHistory.SeatId WHERE BookedById = (CASE WHEN @userId = 0 THEN BookedById ELSE @userId END) AND BookedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	)
	AS PrintedSeatMaster
	
	SELECT * INTO #PrintedShowMaster 
	FROM 
		(
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #PrintedSeatMaster)
		UNION ALL 
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #PrintedSeatMaster)
		)
	AS PrintedShowMaster
	
	--CancelledSeatsCollection
	SELECT * INTO #CancelledSeatMaster
	FROM
	(	
		SELECT CancelHistory.*, S.ClassID, S.SeatLabel FROM CancelHistory INNER JOIN #TempSeatMaster S ON S.SeatId = CancelHistory.SeatId WHERE CancelledById = CASE WHEN @userId = 0 THEN CancelledById ELSE @userId END AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	)
	AS CancelledSeatMaster
	
	SELECT * INTO #CancelledShowMaster
	FROM 
	(
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #CancelledSeatMaster)
		UNION ALL 
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #CancelledSeatMaster)
	)
	As CancelledShowMaster
	
	--BlockedSeatsCollection
	SELECT * INTO #BlockedSeatMaster
	FROM
	(
		SELECT BlockHistory.*, S.ClassID, S.SeatLabel, S.PriceCardId FROM BlockHistory INNER JOIN #TempSeatMaster S ON S.SeatId = BlockHistory.SeatId WHERE BlockedById = CASE WHEN @userId = 0 THEN BlockedById ELSE @userId END AND BlockedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BlockedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BlockedOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	)
	AS BlockedSeatMaster
	
	SELECT * INTO #BlockedShowMaster
	FROM 
	(
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #BlockedSeatMaster)
		UNION ALL 
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #BlockedSeatMaster)
	)
	AS BlockedShowMaster
	
	--UnpaidBookingsSeatsCollection
	SELECT * INTO #UnpaidBookingsSeatMaster
	FROM
	(
		SELECT UnpaidBookings.*, S.ClassID, S.SeatLabel, S.PriceCardId FROM UnpaidBookings INNER JOIN #TempSeatMaster S ON S.SeatId = UnpaidBookings.SeatId WHERE BookedById = CASE WHEN @userId = 0 THEN BookedById ELSE @userId END AND BookedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	)
	AS UnpaidBookingsSeatMaster
	
	SELECT * INTO #UnpaidBookingsShowMaster
	FROM 
	(
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #UnpaidBookingsSeatMaster)
		UNION ALL 
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #UnpaidBookingsSeatMaster)
	)
	AS UnpaidBookingsShowMaster
	
	--ReprintHistory
	SELECT * INTO #ReprintSeatMaster
	FROM
	(	
		SELECT ReprintHistory.*, S.ClassID, S.SeatLabel FROM ReprintHistory INNER JOIN #TempSeatMaster S ON S.SeatId = ReprintHistory.SeatId WHERE PrintedByID = CASE WHEN @userId = 0 THEN PrintedByID ELSE @userId END AND CONVERT(DATETIME, CONVERT(VARCHAR(11), PrintedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), PrintedOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	)
	AS ReprintSeatMaster
	
	SELECT * INTO #ReprintShowMaster
	FROM 
	(
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #ReprintSeatMaster)
		UNION ALL 
		SELECT S.ScreenName, S.MovieName, S.MovieLanguageType, S.ShowTime, S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #ReprintSeatMaster)
	)
	As ReprintShowMaster

	SELECT * INTO #TempTransactionReport
	FROM
	(
		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			(SELECT T.Expression FROM [Type] T WHERE T.Value = S.PaymentType AND T.TypeName = 'PaymentType') AS [Payment Type],
			(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [Ticket Type],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [Ticket Amount],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS [FAndB Charges],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS [ThreeD Charges],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #PrintedSeatMaster B WHERE B.BookedOn = S.BookedOn FOR XML PATH('')), 1, 2, ''),
			'Bookings' AS [Transaction Type],
			ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(S.PatronInfo, '|') WHERE ID = 3), 'Not Applicable') AS [Mobile Number],
			CAST(S.TicketID AS VARCHAR) AS [Ticket ID],
			CAST(S.ShouldNotify AS VARCHAR) [Should Notify],
			CAST(S.Notified AS VARCHAR) AS Notified,
			(SELECT COUNT(SeatID) FROM #PrintedSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.BookedById = S.BookedById) AS [Seats Sold],
			0 AS [Seats Blocked],
			0 AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			0 AS [Seats Reprinted],
			S.BookedOn AS [Transaction Date and Time],
			ISNULL((SELECT UserName FROM BoxOfficeUser BOU WHERE BOU.UserID = (SELECT DISTINCT B.BookedById FROM #PrintedSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.BookedById = S.BookedById)), '') AS [Booked By]--[Booked/Blocked By]
		FROM
			#PrintedSeatMaster S
			INNER JOIN #PrintedShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
			INNER JOIN PriceCard P ON P.Id = S.PriceCardId
			INNER JOIN BoxOfficeUser U ON S.BookedByID = U.UserID
			GROUP BY
				U.UserName, Sh.ScreenName, Sh.Showtime, Sh.MovieName, S.PaymentType, S.PriceCardID, S.SeatId, S.BookedOn, S.BookedById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.PaymentType, S.PatronInfo, S.TicketID, S.ShouldNotify, S.Notified
		 
		UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			'Not Applicable' AS [Payment Type],
			(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [Ticket Type],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [Ticket Amount],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS [FAndB Charges],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS [ThreeD Charges],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #CancelledSeatMaster B WHERE B.CancelledOn = S.CancelledOn FOR XML PATH('')), 1, 2, ''),
			'Cancellations' AS [Transaction Type],
			ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(S.PatronInfo, '|') WHERE ID = 3), 'Not Applicable') AS [Mobile Number],
			CAST(S.TicketID AS VARCHAR) AS [Ticket ID],
			CAST(S.ShouldNotify AS VARCHAR) [Should Notify],
			CAST(S.Notified AS VARCHAR) AS Notified,
			0 AS [Seats Sold],
			0 AS [Seats Blocked],
			0 AS [Seats UnpaidBookings],
			(SELECT COUNT(SeatID) FROM #CancelledSeatMaster B WHERE B.CancelledOn = S.CancelledOn AND B.CancelledById = S.CancelledById) AS [Seats Cancelled],
			0 AS [Seats Reprinted],
			S.CancelledOn AS [Transaction Date and Time],
			ISNULL((SELECT UserName FROM BoxOfficeUser BOU WHERE BOU.UserID IN (SELECT P.BookedByID FROM BookHistory P WHERE P.BookedOn IN (SELECT B.BookedOn FROM #CancelledSeatMaster B WHERE B.CancelledOn = S.CancelledOn) AND P.SeatID = S.SeatID)), '') AS [Booked By]--[Booked/Blocked By]
		From
			#CancelledSeatMaster S
			INNER JOIN #CancelledShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
			INNER JOIN PriceCard P ON P.Id = S.PriceCardId
			INNER JOIN BoxOfficeUser U ON S.CancelledByID = U.UserID
		GROUP BY
			U.UserName, Sh.ScreenName, Sh.Showtime, Sh.MovieName, S.PriceCardID, S.SeatID, S.CancelledOn, S.CancelledById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.BookedPaymentType, S.PatronInfo, S.TicketID, S.ShouldNotify, S.Notified
	 
		UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			'Not Applicable' AS [Payment Type],
			'Not Applicable' AS [Ticket Type],
			0 AS [Ticket Amount],
			0 AS [FAndB Charges],
			0 AS [ThreeD Charges],
			0 AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #BlockedSeatMaster B WHERE B.BlockedOn = S.BlockedOn FOR XML PATH('')), 1, 2, ''),
			'Block' AS [Transaction Type],
			'Not Applicable' AS [Mobile Number],
			'Not Applicable' AS [Ticket ID],
			'Not Applicable' AS [Should Notify],
			'Not Applicable' AS Notified,
			0 AS [Seats Sold],
			(SELECT COUNT(SeatID) FROM #BlockedSeatMaster B WHERE B.BlockedOn = S.BlockedOn AND B.BlockedById = S.BlockedById) AS [Seats Blocked],
			0 AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			0 AS [Seats Reprinted],
			S.BlockedOn AS [Transaction Date and Time],
			ISNULL((SELECT UserName FROM BoxOfficeUser BOU WHERE BOU.UserID = (SELECT DISTINCT B.BlockedById FROM #BlockedSeatMaster B WHERE B.BlockedOn = S.BlockedOn AND B.BlockedById = S.BlockedById)), '') AS [Booked By]--[Booked/Blocked By]
		FROM
				#BlockedSeatMaster S
				INNER JOIN #BlockedShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
				INNER JOIN BoxOfficeUser U ON S.BlockedById = U.UserID
		GROUP BY
				U.UserName, Sh.ScreenName, Sh.Showtime, Sh.MovieName, S.SeatId, S.BlockedOn, S.BlockedById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.PriceCardId
				
		UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			'Not Applicable' AS [Payment Type],
			'Not Applicable' AS [Ticket Type],
			0 AS [Ticket Amount],
			0 AS [FAndB Charges],
			0 AS [ThreeD Charges],
			0 AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #UnpaidBookingsSeatMaster B WHERE B.BookedOn = S.BookedOn FOR XML PATH('')), 1, 2, ''),
			'Unpaid Bookings' AS [Transaction Type],
			'Not Applicable' AS [Mobile Number],
			'Not Applicable' AS [Ticket ID],
			'Not Applicable' AS [Should Notify],
			'Not Applicable' AS Notified,
			0 AS [Seats Sold],
			0 AS [Seats Blocked],
			(SELECT COUNT(SeatID) FROM #UnpaidBookingsSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.BookedById = S.BookedById) AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			0 AS [Seats Reprinted],
			S.BookedOn AS [Transaction Date and Time],
			ISNULL((SELECT UserName FROM BoxOfficeUser BOU WHERE BOU.UserID = (SELECT DISTINCT B.BookedById FROM #UnpaidBookingsSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.BookedById = S.BookedById)), '') AS [Booked By]--[Booked/Blocked By]
		FROM
				#UnpaidBookingsSeatMaster S
				INNER JOIN #UnpaidBookingsShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
				INNER JOIN BoxOfficeUser U ON S.BookedById = U.UserID
		GROUP BY
				U.UserName, Sh.ScreenName, Sh.Showtime, Sh.MovieName, S.SeatId, S.BookedOn, S.BookedById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.PriceCardId

		UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			'Not Applicable' AS [Payment Type],
			(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [Ticket Type],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [Ticket Amount],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS [FAndB Charges],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS [ThreeD Charges],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #ReprintSeatMaster B WHERE B.PrintedOn = S.PrintedOn FOR XML PATH('')), 1, 2, ''),
			'Reprints' AS [Transaction Type],
			ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(S.PatronInfo, '|') WHERE ID = 3), 'Not Applicable') AS [Mobile Number],
			CAST(S.TicketID AS VARCHAR) AS [Ticket ID],
			CAST(S.ShouldNotify AS VARCHAR) [Should Notify],
			CAST(S.Notified AS VARCHAR) AS Notified,
			0 AS [Seats Sold],
			0 AS [Seats Blocked],
			0 AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			(SELECT COUNT(SeatID) FROM #ReprintSeatMaster B WHERE B.PrintedOn = S.PrintedOn AND B.PrintedByID = S.PrintedByID) AS [Seats Reprinted],
			S.PrintedOn AS [Transaction Date and Time],
			ISNULL((SELECT UserName FROM BoxOfficeUser BOU WHERE BOU.UserID IN (SELECT P.BookedByID FROM BookHistory P WHERE P.BookedOn IN (SELECT B.BookedOn FROM #ReprintSeatMaster B WHERE B.PrintedOn = S.PrintedOn) AND P.SeatID = S.SeatID)), '') AS [Booked By]--[Booked/Blocked By]
		From
			#ReprintSeatMaster S
			INNER JOIN #ReprintShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
			INNER JOIN PriceCard P ON P.Id = S.PriceCardId
			INNER JOIN BoxOfficeUser U ON S.PrintedByID = U.UserID
		GROUP BY
			U.UserName, Sh.ScreenName, Sh.Showtime, Sh.MovieName, S.PriceCardID, S.SeatID, S.PrintedOn, S.PrintedByID, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.BookedPaymentType, S.PatronInfo, S.TicketID, S.ShouldNotify, S.Notified
	) AS #TempTransactionReport
	
	SELECT * INTO #Code
	FROM
	(		
		SELECT Code FROM PriceCardItems WHERE Code IN (SELECT Code FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges' AND PriceCardId IN 
		(SELECT PriceCardID FROM (SELECT PriceCardID FROM #PrintedSeatMaster UNION ALL SELECT PriceCardID FROM #CancelledSeatMaster UNION ALL SELECT PriceCardID FROM #BlockedSeatMaster)A))
	) PCCode

	DROP TABLE #PrintedSeatMaster
	DROP TABLE #PrintedShowMaster

	DROP TABLE #CancelledSeatMaster
	DROP TABLE #CancelledShowMaster

	DROP TABLE #BlockedSeatMaster
	DROP TABLE #BlockedShowMaster

	DROP TABLE #UnpaidBookingsSeatMaster
	DROP TABLE #UnpaidBookingsShowMaster

	DROP TABLE #ReprintSeatMaster
	DROP TABLE #ReprintShowMaster
	
	DECLARE @TheatreName NVARCHAR(64) = (SELECT ComplexName FROM Complex WHERE ComplexID = @theatreId)
	
	SELECT DISTINCT
		[User Name],
		--SUM([Seats Blocked]) AS [Total Seats Blocked],
		--SUM([Seats UnpaidBookings]) AS [Total Seats UnpaidBookings],
		SUM([Seats Sold]) AS [Total Seats Sold],
		SUM([Seats Cancelled]) AS [Total Seats Cancelled],
		SUM([Seats Sold] * [Ticket Amount]) AS [Total Cash Collected],
		--SUM([Seats Sold] * [FAndB Charges]) AS [Total Food and Beverage Package Cash Collected],
		SUM([Seats Sold] * [ThreeD Charges]) AS [Total 3D Glass Cash Collected],
		SUM([Seats Sold] * [Other Theatre Charges]) AS [Total Other Theatre Charges Collected],
		SUM([Seats Cancelled] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges])) AS [Total Cash Refunded],
		SUM([Seats Sold] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges])) - (SUM([Seats Cancelled] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges]))) AS [Grand Total Cash Collected]
	INTO #TransactionSummary
	FROM
		#TempTransactionReport
	GROUP BY
		[User Name]
	ORDER BY
	[User Name]
	
	IF EXISTS(SELECT [User Name] FROM #TransactionSummary)
	BEGIN
		IF EXISTS(SELECT * FROM #Code)
		BEGIN
			SELECT * FROM #TransactionSummary
	
			IF @userId = 0
				SELECT 'All Users' [User Name], --SUM([Total Seats Blocked]) [Total Seats Blocked], SUM([Total Seats UnpaidBookings]) [Total Seats UnpaidBookings], 
				SUM([Total Seats Sold]) [Total Seats Sold], SUM([Total Seats Cancelled]) [Total Seats Cancelled], SUM([Total Cash Collected]) [Total Cash Collected], 
				--SUM([Total Food and Beverage Package Cash Collected]) [Total Food and Beverage Package Cash Collected], 
				SUM([Total 3D Glass Cash Collected]) [Total 3D Glass Cash Collected], SUM([Total Other Theatre Charges Collected]) [Total Other Theatre Charges Collected], 
				SUM([Total Cash Refunded]) [Total Cash Refunded], SUM([Grand Total Cash Collected]) [Grand Total Cash Collected] FROM #TransactionSummary
		END
		ELSE
		BEGIN
			SELECT [User Name], --[Total Seats Blocked], [Total Seats UnpaidBookings], 
			[Total Seats Sold],  [Total Seats Cancelled], [Total Cash Collected],  
			--[Total Food and Beverage Package Cash Collected], 
			[Total 3D Glass Cash Collected], [Total Cash Refunded], [Grand Total Cash Collected] FROM #TransactionSummary
	
			IF @userId = 0
				SELECT 'All Users' [User Name], --SUM([Total Seats Blocked]) [Total Seats Blocked], SUM([Total Seats UnpaidBookings]) [Total Seats UnpaidBookings], 
				SUM([Total Seats Sold]) [Total Seats Sold], SUM([Total Seats Cancelled]) [Total Seats Cancelled], SUM([Total Cash Collected]) [Total Cash Collected], 
				--SUM([Total Food and Beverage Package Cash Collected]) [Total Food and Beverage Package Cash Collected], 
				SUM([Total 3D Glass Cash Collected]) [Total 3D Glass Cash Collected], SUM([Total Cash Refunded]) [Total Cash Refunded], SUM([Grand Total Cash Collected]) [Grand Total Cash Collected] FROM #TransactionSummary
		END
	END

	IF EXISTS(SELECT [User Name] FROM #TempTransactionReport)
		IF EXISTS(SELECT * FROM #Code)
			SELECT DISTINCT
				[User Name],
				[Transaction Date and Time],
				SUBSTRING(CONVERT(VARCHAR(11), [Show Time] , 101), 1, 10)[Show Date],
				SUBSTRING(CAST([Show Time] AS VARCHAR), 12, 20)[Show Time],
				[Movie Name],
				[Language],
				[Screen Name],
				[Class],
				[Ticket Amount],
				[Ticket Type],
				--[FAndB Charges] [Food and Beverage Package Charges],
				[ThreeD Charges] [3D Glass Charges],
				[Other Theatre Charges],
				[Seat Lables],
				[Transaction Type],
				[Mobile Number],
				[Ticket ID],
				[Should Notify],
				[Notified],
				--[Seats Blocked],
				--[Seats UnpaidBookings],
				[Seats Sold],
				[Seats Cancelled],
				[Seats Reprinted],
				[Payment Type],
				SUM([Seats Sold] * [Ticket Amount]) AS [Cash Collected],
				--SUM([Seats Sold] * [FAndB Charges]) AS [Food and Beverage Package Cash Collected],
				SUM([Seats Sold] * [ThreeD Charges]) AS [3D Glass Cash Collected],
				SUM([Seats Sold] * [Other Theatre Charges]) AS [Other Theatre Charges Collected],
				SUM([Seats Cancelled] * ([ThreeD Charges] + [Ticket Amount] + [Other Theatre Charges])) AS [Cash Refunded],
				SUM([Seats Sold] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges])) - (SUM([Seats Cancelled] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges]))) AS [Total Cash Collected],
				[Booked By]--[Booked/Blocked By]
			FROM
				#TempTransactionReport
			GROUP BY
				[User Name],
				[Transaction Date and Time],
				[Show Time],
				[Movie Name],
				[Language],
				[Screen Name],
				[Class],
				[Ticket Amount],
				[Ticket Type],
				[FAndB Charges],
				[ThreeD Charges],
				[Other Theatre Charges],
				[Seat Lables],
				[Transaction Type],
				[Mobile Number],
				[Ticket ID],
				[Should Notify],
				[Notified],
				--[Seats Blocked],
				--[Seats UnpaidBookings],
				[Seats Sold],
				[Seats Cancelled],
				[Seats Reprinted],
				[Payment Type],
				[Booked By]--[Booked/Blocked By]
			ORDER BY
				[Transaction Date and Time], [Show Time], [User Name], [Movie Name], [Screen Name]
		ELSE
			SELECT DISTINCT
			[User Name],
			[Transaction Date and Time],
			SUBSTRING(CONVERT(VARCHAR(11), [Show Time] , 101), 1, 10)[Show Date],
			SUBSTRING(CAST([Show Time] AS VARCHAR), 12, 20)[Show Time],
			[Movie Name],
			[Language],
			[Screen Name],
			[Class],
			[Ticket Amount],
			[Ticket Type],
			--[FAndB Charges] [Food and Beverage Package Charges],
			[ThreeD Charges] [3D Glass Charges],
			[Seat Lables],
			[Transaction Type],
			[Mobile Number],
			[Ticket ID],
			[Should Notify],
			[Notified],
			--[Seats Blocked],
			--[Seats UnpaidBookings],
			[Seats Sold],
			[Seats Cancelled],
			[Seats Reprinted],
			[Payment Type],
			SUM([Seats Sold] * [Ticket Amount]) AS [Cash Collected],
			--SUM([Seats Sold] * [FAndB Charges]) AS [Food and Beverage Package Cash Collected],
			SUM([Seats Sold] * [ThreeD Charges]) AS [3D Glass Cash Collected],
			SUM([Seats Cancelled] * ([ThreeD Charges] + [Ticket Amount] + [Other Theatre Charges])) AS [Cash Refunded],
			SUM([Seats Sold] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges])) - (SUM([Seats Cancelled] * ([ThreeD Charges] + [FAndB Charges] + [Ticket Amount] + [Other Theatre Charges]))) AS [Total Cash Collected],
			[Booked By]--[Booked/Blocked By]
		FROM
			#TempTransactionReport
		GROUP BY
			[User Name],
			[Transaction Date and Time],
			[Show Time],
			[Movie Name],
			[Language],
			[Screen Name],
			[Class],
			[Ticket Amount],
			[Ticket Type],
			[Mobile Number],
			[Ticket ID],
			[Should Notify],
			[Notified],
			--[FAndB Charges],
			[ThreeD Charges],
			[Other Theatre Charges],
			[Seat Lables],
			[Transaction Type],
			--[Seats Blocked],
			--[Seats UnpaidBookings],
			[Seats Sold],
			[Seats Cancelled],
			[Seats Reprinted],
			[Payment Type],
			[Booked By]--[Booked/Blocked By]
		ORDER BY
			[Transaction Date and Time], [Show Time], [User Name], [Movie Name], [Screen Name]
	
	--Food and Beverage
	
	--Item Sales		
	SELECT SH.TransactionID, SH.ItemPriceID, SH.Quantity, SH.PaymentType, SH.SoldBy, SH.SoldOn, (CASE WHEN SH.PaymentType = 5 THEN 0 ELSE SUM(IP.Price) END) Price INTO #Sales FROM ItemSalesHistory SH
	INNER JOIN ItemPrice IP ON IP.ItemPriceID =  SH.ItemPriceID
	WHERE SH.SeatID IS NULL AND SoldBy = (CASE WHEN @userId = 0 THEN SoldBy ELSE @userId END) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SoldOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND SH.ComplexID = @theatreId
	GROUP BY SH.TransactionID, SH.ItemPriceID, SH.Quantity, SH.PaymentType, SH.SoldBy, SH.SoldOn
	--Item Cancel		
	SELECT CH.TransactionID, CH.ItemPriceID, CH.Quantity, CH.CancelledBy, CH.CancelledOn, CH.OrderType, CH.ItemID, SH.PaymentType, CH.ItemStockID INTO #Cancel FROM ItemCancelHistory CH 
	INNER JOIN ItemPrice IP ON IP.ItemPriceID =  CH.ItemPriceID
	INNER JOIN ItemSalesHistory SH ON SH.TransactionID = CH.TransactionID
	WHERE SH.SeatID IS NULL AND CancelledBy = (CASE WHEN @userId = 0 THEN CancelledBy ELSE @userId END) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106)
	AND SH.ComplexID = @theatreId
	GROUP BY CH.TransactionID, CH.ItemPriceID, CH.Quantity, CH.CancelledBy, CH.CancelledOn, CH.OrderType, SH.PaymentType, CH.ItemID, CH.ItemStockID
	
	SELECT * INTO #FAndBTransaction
	FROM
	(
		SELECT
			U.UserName AS [User Name],
			S.SoldOn AS [Transaction Date and Time],
			S.TransactionID AS [Transaction Number],
			'Sale' AS [Transaction Type],
			T.Expression AS [Payment Type],
			SUM(Quantity * Price) AS [Cash Collected],
			0 AS [Cash Refunded]
		FROM
			#Sales S
			INNER JOIN BoxOfficeUser U ON S.SoldBy = U.UserID
			INNER JOIN [Type] T ON S.PaymentType = T.Value AND T.TypeName = 'PaymentType'
			GROUP BY
				U.UserName, S.SoldOn, S.TransactionID, T.Expression, S.PaymentType
		 
		UNION ALL

		SELECT
			U.UserName AS [User Name],
			C.CancelledOn AS [Transaction Date and Time],
			C.TransactionID AS [Transaction Number],
			(CASE WHEN C.OrderType = 1 THEN 'Cancel due to damage' ELSE 'Cancel' END) AS [Transaction Type],
			'Not Applicable' AS [Payment Type],			
			0 AS [Cash Collected],
			Quantity * (SELECT IP.Price FROM ItemPrice IP WHERE IP.ItemPriceID IN (SELECT ItemPriceID FROM ItemSalesHistory WHERE ItemSalesHistory.ItemID = C.ItemID AND ItemSalesHistory.ItemPriceID = C.ItemPriceID AND ItemSalesHistory.ItemStockID = C.ItemStockID AND ItemSalesHistory.TransactionID = C.TransactionID AND ItemSalesHistory.PaymentType <> 5)) [Cash Refunded]
		FROM
			#Cancel C
			INNER JOIN BoxOfficeUser U ON C.CancelledBy = U.UserID
			GROUP BY
				U.UserName, C.CancelledOn, C.TransactionID, C.PaymentType, C.OrderType, C.Quantity, C.ItemID, C.ItemPriceID, C.ItemStockID
	) AS #FAndBTransaction
	
	DROP TABLE #Sales
	DROP TABLE #Cancel
	
	SELECT DISTINCT
		[User Name],
		SUM([Cash Collected]) AS [Cash Collected],
		SUM([Cash Refunded]) AS [Total Cash Refunded],
		(SUM([Cash Collected]) - SUM([Cash Refunded])) AS [Total Cash Collected]
	INTO #FAndBSummary
	FROM
		#FAndBTransaction
	GROUP BY
		[User Name]
	ORDER BY
	[User Name]
	
	IF EXISTS(SELECT [User Name] FROM #FAndBSummary)
		SELECT * FROM #FAndBSummary
	
	IF @userId = 0
		IF EXISTS(SELECT [User Name] FROM #FAndBSummary)
			SELECT 
				'All Users' [User Name],
				SUM([Cash Collected]) AS [Cash Collected],
				SUM([Total Cash Refunded]) AS [Total Cash Refunded],
				(SUM([Cash Collected]) - SUM([Total Cash Refunded])) AS [Total Cash Collected]
				FROM #FAndBSummary

	IF EXISTS(SELECT [User Name] FROM #FAndBTransaction)
		SELECT
			[User Name],
			[Transaction Date and Time],
			[Transaction Number],
			[Transaction Type],
			[Payment Type],
			SUM([Cash Collected]) [Cash Collected],
			SUM([Cash Refunded]) [Cash Refunded]
		FROM
			#FAndBTransaction
		GROUP BY
			[User Name],
			[Transaction Date and Time],
			[Transaction Number],
			[Transaction Type],
			[Payment Type]
		ORDER BY
			[Transaction Date and Time]
	
	IF (SELECT COUNT([User Name]) FROM #TransactionSummary) > 0 AND (SELECT COUNT([User Name]) FROM #FAndBSummary) > 0
	BEGIN	
		SELECT 
			ISNULL(BO.[User Name], FAndB.[User Name]) [User Name],
			ISNULL(SUM(BO.[Total Cash Refunded]), 0) + ISNULL(SUM(FAndB.[Total Cash Refunded]), 0) [Total Cash Refunded],
			ISNULL(SUM(BO.[Grand Total Cash Collected]), 0) + ISNULL(SUM(FAndB.[Total Cash Collected]), 0) [Total Cash Collected]
		INTO #GrandTotal
		FROM #TransactionSummary BO
		FULL OUTER JOIN
		#FAndBSummary FAndB ON BO.[User Name] = FAndB.[User Name]
		GROUP BY BO.[User Name], FAndB.[User Name]
		
		IF EXISTS(SELECT [User Name] FROM #GrandTotal)
			SELECT * FROM #GrandTotal ORDER BY [User Name]
		IF @userId = 0
			IF EXISTS(SELECT [User Name] FROM #GrandTotal)
				SELECT 
					'All Users' [User Name], 
					SUM([Total Cash Refunded]) [Total Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] 
				FROM #GrandTotal
		
		DROP TABLE #GrandTotal
	END
	
	DROP TABLE #TempSeatMaster
	DROP TABLE #TempTransactionReport
	DROP TABLE #TransactionSummary
	DROP TABLE #FAndBTransaction
	DROP TABLE #FAndBSummary
	DROP TABLE #Code
END
GO

/*[GetBOSalesStatusByShow]*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetBOSalesStatusByShow]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetBOSalesStatusByShow]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[GetBOSalesStatusByShow] 955
CREATE PROCEDURE [dbo].[GetBOSalesStatusByShow]
	@showID INT
AS
BEGIN
	IF EXISTS(SELECT ShowId FROM Show WHERE ShowID = @ShowId AND IsSentBOSalesStatus = 0 AND IsCancel = 0)
	BEGIN
		SELECT COUNT(SeatID) * ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = s.PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS Net,
		COUNT(SeatID) * (ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = s.PriceCardID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = s.PriceCardID AND Code = 'Ticket_Amount_Discount'), 0)) AS Gross INTO #Amount 
		FROM Seat s WHERE ShowID = @showId AND SeatType <> 1 AND StatusType IN (2,3) AND PaymentType <> 5 GROUP BY PriceCardID
		
		SELECT
		(SELECT OnlineShowId FROM Show WHERE ShowID = @ShowID),
		(SELECT '{"total_seats":' + (SELECT CAST(COUNT(SeatID) AS VARCHAR) FROM Seat WHERE ShowID = @showID AND SeatType <> 1) + 
		',"net_amount": "' + (SELECT ISNULL(CAST(SUM(Net) AS VARCHAR), 0) FROM #Amount) + 
		'" ,"gross_amount": "' + (SELECT ISNULL(CAST(SUM(Gross) AS VARCHAR), 0) FROM #Amount) + '" ,"sold_class_counts":' +	
		(SELECT '[' + STUFF((SELECT ',{"name": "' + (SELECT C.ClassName FROM Class C WHERE C.ClassId = S.ClassId) + '" ,"count": ' + 
		(SELECT CAST(COUNT(A.SeatID) AS VARCHAR) FROM Seat A WHERE A.ShowID = @showID AND A.StatusType IN (2,3) AND A.SeatType <> 1 AND S.ClassID = A.ClassID) + '}'
		FROM Seat S WHERE S.ShowID = @showID GROUP BY ClassId FOR XML PATH('')),1,1,'') + ']') + ',"unsold_class_counts":' +	
		(SELECT '[' + STUFF((SELECT ',{"name": "' + (SELECT C.ClassName FROM Class C WHERE C.ClassId = S.ClassId) + '" ,"count": ' + 
		(SELECT CAST(COUNT(A.SeatID) AS VARCHAR) FROM Seat A WHERE A.ShowID = @showID AND A.StatusType NOT IN (2,3) AND A.SeatType <> 1 AND S.ClassID = A.ClassID) + '}'
		FROM Seat S WHERE S.ShowID = @showID GROUP BY ClassId FOR XML PATH('')),1,1,'') + ']') + '}')
	
		DROP TABLE #Amount
	END

	UPDATE Show SET IsSentBOSalesStatus = 1 WHERE ShowID = @ShowID AND IsSentBOSalesStatus = 0
END	
GO

/*[UpdateComplex]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateComplex]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateComplex]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateComplex]	
	@complexGUID VARCHAR(64),
	@complexName NVARCHAR(64),
	@complexAddress VARCHAR(64),
	@complexCity VARCHAR(32),
	@complexState VARCHAR(32),
	@chainGUID VARCHAR(64),
	@chainName NVARCHAR(64)
AS
BEGIN
	UPDATE Complex SET ComplexName = @complexName, ComplexAddress1 = @complexAddress, ComplexCity = @complexCity, ComplexState = @complexState, ChainGuid = @chainGUID, ChainName = @chainName WHERE ComplexGUID = @complexGUID
END
GO

/*[UpdateScreen]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateScreen]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateScreen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateScreen]
	@screenGUID VARCHAR(64),
	@screenName NVARCHAR(256),
	@screenNo VARCHAR(2)
AS
BEGIN
	UPDATE Screen SET ScreenName = @screenName, ScreenNo = @screenNo WHERE ScreenGUID = @screenGUID
END
GO

/*[GetOnlineMovieIDs]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetOnlineMovieIDs]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetOnlineMovieIDs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetOnlineMovieIDs]
AS
BEGIN
	SELECT DISTINCT OnlineMovieID FROM Show
	UNION
	SELECT DISTINCT OnlineMovieID FROM DistributorMovieCollections
END
GO

/*[UpdateMovieDetails]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateMovieDetails]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateMovieDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateMovieDetails]
	@onlineMovieID VARCHAR(64),
	@movieMergedTo VARCHAR(64),
	@onlineMovieName NVARCHAR(256),
	@language NVARCHAR(64),
	@censorCertification NVARCHAR(8),
	@duration INT
AS
BEGIN
	UPDATE
		Show
	SET
		OnlineMovieName = @onlineMovieName,
		MovieName = CASE WHEN OnlineMovieName = MovieName THEN @onlineMovieName ELSE MovieName END,
		MovieLanguageType = (SELECT Value FROM [Type] WHERE TypeName ='MovieLanguageType' AND Expression = @language),
		MovieCensorRatingType = CASE WHEN @censorCertification <> '' THEN (SELECT Value FROM [Type] WHERE TypeName ='MovieCensorRatingType' AND Expression = @censorCertification) ELSE MovieCensorRatingType END,
		Duration = CASE WHEN @duration <> 0 THEN @duration ELSE Duration END,
		MovieMergedTo = @movieMergedTo
	WHERE
		OnlineMovieID = @onlineMovieID

	UPDATE
		ShowMIS
	SET
		OnlineMovieName = @onlineMovieName,
		MovieName = CASE WHEN OnlineMovieName = MovieName THEN @onlineMovieName ELSE MovieName END,
		MovieLanguageType = (SELECT Value FROM [Type] WHERE TypeName ='MovieLanguageType' AND Expression = @language),
		MovieCensorRatingType = CASE WHEN @censorCertification <> '' THEN (SELECT Value FROM [Type] WHERE TypeName ='MovieCensorRatingType' AND Expression = @censorCertification) ELSE MovieCensorRatingType END,
		Duration = CASE WHEN @duration <> 0 THEN @duration ELSE Duration END,
		MovieMergedTo = @movieMergedTo
	WHERE
		OnlineMovieID = @onlineMovieID
	
	UPDATE
		DistributorMovieCollections
	SET
		OnlineMovieName = @onlineMovieName,
		MovieName = CASE WHEN OnlineMovieName = MovieName THEN @onlineMovieName ELSE MovieName END,
		[Language] = (SELECT Value FROM [Type] WHERE TypeName ='MovieLanguageType' AND Expression = @language),
		CensorRating = CASE WHEN @censorCertification <> '' THEN (SELECT Value FROM [Type] WHERE TypeName ='MovieCensorRatingType' AND Expression = @censorCertification) ELSE CensorRating END,
		MovieMergedTo = @movieMergedTo
	WHERE
		OnlineMovieID = @onlineMovieID
END
GO

/* [AdvanceSalesSummaryReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AdvanceSalesSummaryReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AdvanceSalesSummaryReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[AdvanceSalesSummaryReport] 1, 0, 0, '02 Dec 2016'

CREATE PROCEDURE [dbo].[AdvanceSalesSummaryReport]
	@theatreId INT,
	@screenId INT,
	@userId INT,
	@date VARCHAR(11)
AS
BEGIN
--TempSeatMaster
	SELECT * INTO #TempSeatMaster
	FROM
	(
		SELECT * FROM Seat WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT * FROM SeatMIS WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	)
	AS TempSeatMaster

	--PrintedSeatsCollection
	SELECT * INTO #PrintedSeatMaster
	FROM
	(			
		SELECT BookHistory.*, S.ClassID, S.SeatLabel FROM BookHistory INNER JOIN #TempSeatMaster S ON S.SeatId = BookHistory.SeatId WHERE BookedById = (CASE WHEN @userId = 0 THEN BookedById ELSE @userId END) AND BookedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) = CONVERT(DATETIME, @date, 106)
	)
	AS PrintedSeatMaster
	
	SELECT * INTO #PrintedShowMaster 
	FROM 
		(
		SELECT S.*, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #PrintedSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
		UNION ALL 
		SELECT S.*, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #PrintedSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
		)
	AS PrintedShowMaster
	
	--CancelledSeatsCollection
	SELECT * INTO #CancelledSeatMaster
	FROM
	(	
		SELECT CancelHistory.*, S.ClassID, S.SeatLabel FROM CancelHistory INNER JOIN #TempSeatMaster S ON S.SeatId = CancelHistory.SeatId WHERE CancelledById = CASE WHEN @userId = 0 THEN CancelledById ELSE @userId END AND CONVERT(DATETIME, CONVERT(VARCHAR(11), CancelledOn, 106)) = CONVERT(DATETIME, @date, 106)
	)
	AS CancelledSeatMaster
	
	SELECT * INTO #CancelledShowMaster
	FROM 
	(
		SELECT S.*, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #CancelledSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
		UNION ALL 
		SELECT S.*, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #CancelledSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
	)
	As CancelledShowMaster
	
	--BlockedSeatsCollection
	/*SELECT * INTO #BlockedSeatMaster
	FROM
	(
		SELECT BlockHistory.*, S.ClassID, S.SeatLabel, S.PriceCardId FROM BlockHistory INNER JOIN #TempSeatMaster S ON S.SeatId = BlockHistory.SeatId WHERE BlockedById = CASE WHEN @userId = 0 THEN BlockedById ELSE @userId END AND BlockedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BlockedOn, 106)) = CONVERT(DATETIME, @date, 106)
	)
	AS BlockedSeatMaster
	
	SELECT * INTO #BlockedShowMaster
	FROM 
	(
		SELECT S.*, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #BlockedSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
		UNION ALL 
		SELECT S.*, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #BlockedSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
	)
	AS BlockedShowMaster*/
	
	
	--UnpaidBookingsSeatsCollection
	/*SELECT * INTO #UnpaidBookingsSeatMaster
	FROM
	(
		SELECT A.*, S.ClassID, S.SeatLabel, ISNULL(B.PriceCardId, S.PriceCardId) AS PriceCardId FROM UnpaidBookings A INNER JOIN #TempSeatMaster S ON S.SeatId = A.SeatId LEFT JOIN #PrintedSeatMaster B ON B.SeatId = A.SeatId AND B.BOBookingCode = A.BookingCode WHERE A.BookedById = CASE WHEN @userId = 0 THEN A.BookedById ELSE @userId END AND A.BookedById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), A.BookedOn, 106)) = CONVERT(DATETIME, @date, 106)
	)
	AS UnpaidBookingsSeatMaster
	
	SELECT * INTO #UnpaidBookingsShowMaster
	FROM 
	(
		SELECT S.*, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #UnpaidBookingsSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
		UNION ALL 
		SELECT S.*, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE S.ShowId IN (SELECT ShowId FROM #UnpaidBookingsSeatMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @date, 106)
	)
	AS UnpaidBookingsShowMaster*/
	
	SELECT * INTO #TempTransactionReport
	FROM
	(
		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			--(SELECT COUNT(DISTINCT SeatID) FROM #PrintedSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.SeatId IN (SELECT DISTINCT SeatId FROM #BlockedSeatMaster WHERE BlockedById <> 0 AND #BlockedSeatMaster.BlockCode = B.BlockCode)) AS [POS Phone Booked Seats],
			--0 AS [POS Phone Blocked Seats],
			--0 AS [Unpaid Bookings Seats],
			--0 AS [Unpaid Bookings Seats Payment Received],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS [Class Rate],
			/*ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession_Discount'), 0) AS [FAndB Class Rate],*/
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS [Additional Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges Rate],
			(SELECT T.Expression FROM [Type] T WHERE T.Value = S.PaymentType AND T.TypeName = 'PaymentType') AS [Payment Type],
			(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [Ticket Type],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [Price],
			/*ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS [FAndB price],*/
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS [Additional Price],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #PrintedSeatMaster B WHERE B.BookedOn = S.BookedOn FOR XML PATH('')), 1, 2, ''),
			(SELECT COUNT(SeatID) FROM #PrintedSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.BookedById = S.BookedById) AS [Seats Sold],
			--0 AS [Seats Blocked],
			--0 AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			S.BookedOn AS [Transaction Date and Time]
		FROM
			#PrintedSeatMaster S
			INNER JOIN #PrintedShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
			INNER JOIN PriceCard P ON P.Id = S.PriceCardId
			INNER JOIN BoxOfficeUser U ON S.BookedByID = U.UserID
			GROUP BY
				U.UserName, Sh.ScreenName, Sh.ShowName, Sh.Showtime, Sh.MovieName, S.PaymentType, S.PriceCardID, S.SeatId, S.BookedOn, S.BookedById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.PaymentType
		 
		UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			--0 AS [POS Phone Booked Seats],
			--0 AS [POS Phone Blocked Seats],
			--0 AS [Unpaid Bookings Seats],
			--0 AS [Unpaid Bookings Seats Payment Received],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS [Class Rate],
			/*ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession_Discount'), 0) AS [FAndB Class Rate],*/
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS [Additional Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges Rate],
			'Not Applicable' AS [Payment Type],
			(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [Ticket Type],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [Price],
			/*ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS [FAndB Price],*/
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS [Additional Price],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.BookedPaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #CancelledSeatMaster B WHERE B.CancelledOn = S.CancelledOn FOR XML PATH('')), 1, 2, ''),
			0 AS [Seats Sold],
			--0 AS [Seats Blocked],
			--0 AS [Seats UnpaidBookings],
			(SELECT COUNT(SeatID) FROM #CancelledSeatMaster B WHERE B.CancelledOn = S.CancelledOn AND B.CancelledById = S.CancelledById) AS [Seats Cancelled],
			S.CancelledOn AS [Transaction Date and Time]
		From
			#CancelledSeatMaster S
			INNER JOIN #CancelledShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
			INNER JOIN PriceCard P ON P.Id = S.PriceCardId
			INNER JOIN BoxOfficeUser U ON S.CancelledByID = U.UserID
		GROUP BY
			U.UserName, Sh.ScreenName, Sh.ShowName, Sh.Showtime, Sh.MovieName, S.PriceCardID, S.SeatID, S.CancelledOn, S.CancelledById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.BookedPaymentType
	 
		/*UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			0 AS [POS Phone Booked Seats],
			(SELECT COUNT(DISTINCT SeatID) FROM #BlockedSeatMaster B WHERE B.BlockedOn = S.BlockedOn AND B.SeatId NOT IN (SELECT DISTINCT SeatId FROM #PrintedSeatMaster WHERE #PrintedSeatMaster.BlockCode = B.BlockCode)) AS [POS Phone Blocked Seats],
			0 AS [Unpaid Bookings Seats],
			0 AS [Unpaid Bookings Seats Payment Received],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS [Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession_Discount'), 0) AS [FAndB Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS [Additional Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges Rate],
			'Not Applicable' AS [Payment Type],
			'Not Applicable' AS [Ticket Type],
			0 AS [Price],
			0 AS [FAndB Price],
			0 AS [Additional Price],
			0 AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #BlockedSeatMaster B WHERE B.BlockedOn = S.BlockedOn FOR XML PATH('')), 1, 2, ''),
			0 AS [Seats Sold],
			(SELECT COUNT(SeatID) FROM #BlockedSeatMaster B WHERE B.BlockedOn = S.BlockedOn AND B.BlockedById = S.BlockedById) AS [Seats Blocked],
			0 AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			S.BlockedOn AS [Transaction Date and Time]
		FROM
				#BlockedSeatMaster S
				INNER JOIN #BlockedShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
				INNER JOIN BoxOfficeUser U ON S.BlockedById = U.UserID
		GROUP BY
				U.UserName, Sh.ScreenName, Sh.ShowName, Sh.Showtime, Sh.MovieName, S.SeatId, S.BlockedOn, S.BlockedById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.PriceCardId
				
		UNION

		SELECT
			U.UserName AS [User Name],
			Sh.ScreenName AS [Screen Name],
			0 AS [POS Phone Booked Seats],
			0 AS [POS Phone Blocked Seats],
			(SELECT COUNT(DISTINCT SeatID) FROM #UnpaidBookingsSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.SeatId NOT IN (SELECT DISTINCT SeatId FROM #PrintedSeatMaster WHERE #PrintedSeatMaster.BOBookingCode = B.BookingCode)) AS [Unpaid Bookings Seats],
			(SELECT COUNT(DISTINCT SeatID) FROM #PrintedSeatMaster B WHERE B.PriceCardId = S.PriceCardID AND B.SeatId IN (SELECT DISTINCT SeatId FROM #UnpaidBookingsSeatMaster UPB WHERE UPB.BookingCode = B.BOBookingCode AND UPB.BookedOn = S.BookedOn AND UPB.BookingCode = S.BookingCode)) AS [Unpaid Bookings Seats Payment Received],
			Sh.Showtime AS [Show Time],
			Sh.MovieName AS [Movie Name],
			(SELECT Expression FROM Type WHERE TypeName = 'MovieLanguageType' AND Value = Sh.MovieLanguageType) AS [Language],
			Sh.ClassName AS [Class],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS [Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession_Discount'), 0) AS [FAndB Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS [Additional Class Rate],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges Rate],
			'Not Applicable' AS [Payment Type],
			'Not Applicable' AS [Ticket Type],
			0 AS [Price],
			0 AS [FAndB Price],
			0 AS [Additional Price],
			0 AS [Other Theatre Charges],
			[Seat Lables] = STUFF((SELECT ', ' + SeatLabel FROM #UnpaidBookingsSeatMaster B WHERE B.BookedOn = S.BookedOn FOR XML PATH('')), 1, 2, ''),
			0 AS [Seats Sold],
			0 AS [Seats Blocked],
			(SELECT COUNT(SeatID) FROM #UnpaidBookingsSeatMaster B WHERE B.BookedOn = S.BookedOn AND B.BookedById = S.BookedById) AS [Seats UnpaidBookings],
			0 AS [Seats Cancelled],
			S.BookedOn AS [Transaction Date and Time]
		FROM
				#UnpaidBookingsSeatMaster S
				INNER JOIN #UnpaidBookingsShowMaster Sh ON S.ShowID = Sh.ShowID AND Sh.ClassID = S.ClassID
				INNER JOIN BoxOfficeUser U ON S.BookedById = U.UserID
		GROUP BY
				U.UserName, Sh.ScreenName, Sh.ShowName, Sh.Showtime, Sh.MovieName, S.SeatId, S.BookedOn, S.BookingCode, S.BookedById, Sh.MovieLanguageType, S.ClassId, Sh.ClassName, Sh.ClassID, S.PriceCardId*/
	) AS #TempTransactionReport

	SELECT * INTO #Code
	FROM
	(		
		SELECT Code FROM PriceCardItems WHERE Code IN (SELECT Code FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges' AND PriceCardId IN 
		(SELECT PriceCardID FROM (SELECT PriceCardID FROM #PrintedSeatMaster 
		--UNION ALL SELECT PriceCardID FROM #CancelledSeatMaster UNION ALL SELECT PriceCardID FROM #BlockedSeatMaster
		)A))
	) PCCode
	
	DROP TABLE #PrintedSeatMaster
	DROP TABLE #PrintedShowMaster

	DROP TABLE #CancelledSeatMaster
	DROP TABLE #CancelledShowMaster

--	DROP TABLE #BlockedSeatMaster
--	DROP TABLE #BlockedShowMaster
	
	DECLARE @TheatreName NVARCHAR(64) = (SELECT ComplexName FROM Complex WHERE ComplexID = @theatreId)
	
	SELECT DISTINCT
		[User Name],
		@TheatreName AS [Theatre Name],
		[Screen Name],
		[Class],
		[Class Rate] AS [Ticket Amount],
		--[FAndB Class Rate] AS [Food and Beverage Package Charges],
		[Additional Class Rate] AS [3D Glass Charges],
		[Other Theatre Charges Rate] AS [Other Theatre Charges],
		--SUM([POS Phone Blocked Seats]) AS [POS Phone Blocking Count],
		--SUM([POS Phone Booked Seats]) AS [POS Phone Booking Count],
		--SUM([Unpaid Bookings Seats]) AS [Unpaid Bookings Count],
		--SUM([Unpaid Bookings Seats Payment Received]) AS [Unpaid Bookings Count Payment Received],
		SUM([Seats Sold]) AS [No. of Seats Sold],
		SUM([Seats Cancelled]) AS [No. of Seats Cancelled],
		SUM([Seats Sold] * Price) AS [Cash Collected for Tickets],
		--SUM([Seats Sold] * [FAndB price]) AS [Food and Beverage Package Cash Collected],
		SUM([Seats Sold] * [Additional Price]) AS [3D Glass Cash Collected],
		SUM([Seats Sold] * [Other Theatre Charges]) AS [Other Theatre Charges Collected],
		SUM([Seats Cancelled] * ([Additional Price] + Price + [Other Theatre Charges])) AS [Cash Refunded],
		--SUM([Seats Cancelled] * ([Additional Price] + Price + [FAndB price] + [Other Theatre Charges])) AS [Cash Refunded],
		SUM([Seats Sold] * ([Additional Price] + Price + [Other Theatre Charges])) - (SUM([Seats Cancelled] * ([Additional Price] + Price + [Other Theatre Charges]))) AS [Total Cash Collected]
		--SUM([Seats Sold] * ([Additional Price] + Price + [FAndB price] + [Other Theatre Charges])) - (SUM([Seats Cancelled] * ([Additional Price] + Price + [FAndB price] + [Other Theatre Charges]))) AS [Total Cash Collected]
	INTO #Summary FROM
		#TempTransactionReport
	GROUP BY
		[User Name],
		[Screen Name],
		[Class],
		[Class Rate],
		--[FAndB Class Rate],
		[Additional Class Rate],
		[Other Theatre Charges Rate]
	ORDER BY
	[User Name], [Screen Name]
	
	
	IF EXISTS(SELECT * FROM #Code)
	BEGIN
		SELECT DISTINCT * FROM #Summary ORDER BY [User Name], [Screen Name]
		
		IF @userId = 0
		BEGIN
			SELECT [User Name], '' [Theatre Name], '' [Screen Name], '' [Class], NULL [Ticket Amount], --NULL [Food and Beverage Package Charges], 
			NULL [3D Glass Charges], NULL [Other Theatre Charges], 
			--SUM([POS Phone Blocking Count]) [POS Phone Blocking Count], SUM([POS Phone Booking Count]) [POS Phone Booking Count], 
			--SUM([Unpaid Bookings Count]) [Unpaid Bookings Count], SUM([Unpaid Bookings Count Payment Received]) AS [Unpaid Bookings Count Payment Received], 
			SUM([No. of Seats Sold]) [No. of Seats Sold], SUM([No. of Seats Cancelled]) [No. of Seats Cancelled], SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
			--SUM([Food and Beverage Package Cash Collected]) [Food and Beverage Package Cash Collected], 
			SUM([3D Glass Cash Collected]) [3D Glass Cash Collected], 
			SUM([Other Theatre Charges Collected]) [Other Theatre Charges Collected], SUM([Cash Refunded]) [Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] 
			FROM #Summary GROUP BY [User Name]

			SELECT 'All User' [User Name], '' [Theatre Name], '' [Screen Name], '' [Class], NULL [Ticket Amount], --NULL [Food and Beverage Package Charges], 
			NULL [3D Glass Charges], NULL [Other Theatre Charges], 
			--SUM([POS Phone Blocking Count]) [POS Phone Blocking Count], SUM([POS Phone Booking Count]) [POS Phone Booking Count], 
			--SUM([Unpaid Bookings Count]) [Unpaid Bookings Count], SUM([Unpaid Bookings Count Payment Received]) AS [Unpaid Bookings Count Payment Received],
			SUM([No. of Seats Sold]) [No. of Seats Sold], SUM([No. of Seats Cancelled]) [No. of Seats Cancelled], SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
			--SUM([Food and Beverage Package Cash Collected]) [Food and Beverage Package Cash Collected], 
			SUM([3D Glass Cash Collected]) [3D Glass Cash Collected], 
			SUM([Other Theatre Charges Collected]) [Other Theatre Charges Collected], SUM([Cash Refunded]) [Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] FROM #Summary
		END
		ELSE
			SELECT [User Name], '' [Theatre Name], '' [Screen Name], '' [Class], NULL [Ticket Amount], --NULL [Food and Beverage Package Charges] ,
			NULL [3D Glass Charges], NULL [Other Theatre Charges], 
			--SUM([POS Phone Blocking Count]) [POS Phone Blocking Count], SUM([POS Phone Booking Count]) [POS Phone Booking Count], 
			--SUM([Unpaid Bookings Count]) [Unpaid Bookings Count], SUM([Unpaid Bookings Count Payment Received]) AS [Unpaid Bookings Count Payment Received],
			SUM([No. of Seats Sold]) [No. of Seats Sold], SUM([No. of Seats Cancelled]) [No. of Seats Cancelled], SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
			--SUM([Food and Beverage Package Cash Collected]) [Food and Beverage Package Cash Collected], 
			SUM([3D Glass Cash Collected]) [3D Glass Cash Collected], 
			SUM([Other Theatre Charges Collected]) [Other Theatre Charges Collected], SUM([Cash Refunded]) [Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] FROM #Summary GROUP BY [User Name]
		
		SELECT DISTINCT
			[User Name],
			[Transaction Date and Time],
			SUBSTRING(CONVERT(VARCHAR(11), [Show Time] , 106), 1, 10)[Show Date],
			SUBSTRING(CAST([Show Time] AS VARCHAR), 12, 20)[Show Time],
			[Movie Name],
			[Language],
			@TheatreName AS [Theatre Name],
			[Screen Name],
			[Class],
			[Price] AS [Ticket Amount],
			[Ticket Type],
			--[FAndB price] AS [Food and Beverage Package Charges],
			[Additional Price] AS [3D Glass Charges],
			[Other Theatre Charges] AS [Other Theatre Charges],
			[Seat Lables],
			--[Seats Blocked],
			--[Seats UnpaidBookings],
			[Seats Sold],
			[Seats Cancelled],
			[Payment Type]
		FROM
			#TempTransactionReport
		GROUP BY
			[User Name],
			[Transaction Date and Time],
			[Show Time],
			[Movie Name],
			[Language],
			[Screen Name],
			[Class],
			[Price],
			[Ticket Type],
			--[FAndB price],
			[Additional Price],
			[Other Theatre Charges],
			[Seat Lables],
			--[Seats Blocked],
			--[Seats UnpaidBookings],
			[Seats Sold],
			[Seats Cancelled],
			[Payment Type]
		ORDER BY
			[Transaction Date and Time], [Show Time], [User Name], [Movie Name], [Screen Name]
	END
	ELSE
	BEGIN
		SELECT DISTINCT [User Name], [Theatre Name], [Screen Name], Class, [Ticket Amount], --[Food and Beverage Package Charges], 
		[3D Glass Charges], 
		--[POS Phone Blocking Count], [POS Phone Booking Count], [Unpaid Bookings Count], [Unpaid Bookings Count Payment Received], 
		[No. of Seats Sold], [No. of Seats Cancelled], [Cash Collected for Tickets],
		--[Food and Beverage Package Cash Collected], 
		[3D Glass Cash Collected], [Cash Refunded], [Total Cash Collected] FROM #Summary ORDER BY [User Name], [Screen Name]
		
		IF @userId = 0
		BEGIN
			SELECT [User Name], '' [Theatre Name], '' [Screen Name], '' [Class], NULL [Ticket Amount], --NULL [Food and Beverage Package Charges], 
			NULL [3D Glass Charges], 
			--SUM([POS Phone Blocking Count]) [POS Phone Blocking Count], SUM([POS Phone Booking Count]) [POS Phone Booking Count], 
			--SUM([Unpaid Bookings Count]) [Unpaid Bookings Count], SUM([Unpaid Bookings Count Payment Received]) AS [Unpaid Bookings Count Payment Received],
			SUM([No. of Seats Sold]) [No. of Seats Sold], SUM([No. of Seats Cancelled]) [No. of Seats Cancelled], SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
			--SUM([Food and Beverage Package Cash Collected]) [Food and Beverage Package Cash Collected], 
			SUM([3D Glass Cash Collected]) [3D Glass Cash Collected], 
			SUM([Cash Refunded]) [Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] 
			FROM #Summary GROUP BY [User Name]

			SELECT 'All User' [User Name], '' [Theatre Name], '' [Screen Name], '' [Class], NULL [Ticket Amount], --NULL [Food and Beverage Package Charges], 
			NULL [3D Glass Charges], 
			--SUM([POS Phone Blocking Count]) [POS Phone Blocking Count], SUM([POS Phone Booking Count]) [POS Phone Booking Count], 
			--SUM([Unpaid Bookings Count]) [Unpaid Bookings Count], SUM([Unpaid Bookings Count Payment Received]) AS [Unpaid Bookings Count Payment Received],
			SUM([No. of Seats Sold]) [No. of Seats Sold], SUM([No. of Seats Cancelled]) [No. of Seats Cancelled], SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
			--SUM([Food and Beverage Package Cash Collected]) [Food and Beverage Package Cash Collected], 
			SUM([3D Glass Cash Collected]) [3D Glass Cash Collected], 
			SUM([Cash Refunded]) [Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] FROM #Summary
		END
		ELSE
			SELECT [User Name], '' [Theatre Name], '' [Screen Name], '' [Class], NULL [Ticket Amount], --NULL [Food and Beverage Package Charges] ,
			NULL [3D Glass Charges], 
			--SUM([POS Phone Blocking Count]) [POS Phone Blocking Count], SUM([POS Phone Booking Count]) [POS Phone Booking Count], 
			--SUM([Unpaid Bookings Count]) [Unpaid Bookings Count], SUM([Unpaid Bookings Count Payment Received]) AS [Unpaid Bookings Count Payment Received],
			SUM([No. of Seats Sold]) [No. of Seats Sold], SUM([No. of Seats Cancelled]) [No. of Seats Cancelled], SUM([Cash Collected for Tickets]) [Cash Collected for Tickets], 
			--SUM([Food and Beverage Package Cash Collected]) [Food and Beverage Package Cash Collected], 
			SUM([3D Glass Cash Collected]) [3D Glass Cash Collected], 
			SUM([Cash Refunded]) [Cash Refunded], SUM([Total Cash Collected]) [Total Cash Collected] FROM #Summary GROUP BY [User Name]
		
		SELECT DISTINCT
			[User Name],
			[Transaction Date and Time],
			SUBSTRING(CONVERT(VARCHAR(11), [Show Time] , 106), 1, 10)[Show Date],
			SUBSTRING(CAST([Show Time] AS VARCHAR), 12, 20)[Show Time],
			[Movie Name],
			[Language],
			@TheatreName AS [Theatre Name],
			[Screen Name],
			[Class],
			[Price] AS [Ticket Amount],
			[Ticket Type],
			--[FAndB price] AS [Food and Beverage Package Charges],
			[Additional Price] AS [3D Glass Charges],
			[Seat Lables],
			--[Seats Blocked],
			--[Seats UnpaidBookings],
			[Seats Sold],
			[Seats Cancelled],
			[Payment Type]
		FROM
			#TempTransactionReport
		GROUP BY
			[User Name],
			[Transaction Date and Time],
			[Show Time],
			[Movie Name],
			[Language],
			[Screen Name],
			[Class],
			[Price],
			[Ticket Type],
			--[FAndB price],
			[Additional Price],
			[Other Theatre Charges],
			[Seat Lables],
			--[Seats Blocked],
			--[Seats UnpaidBookings],
			[Seats Sold],
			[Seats Cancelled],
			[Payment Type]
		ORDER BY
			[Transaction Date and Time], [Show Time], [User Name], [Movie Name], [Screen Name]
	END

	DROP TABLE #Code
	DROP TABLE #Summary	
	DROP TABLE #TempSeatMaster
	DROP TABLE #TempTransactionReport

END
GO

/* ListPriceCards */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListPriceCards]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ListPriceCards]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [ListPriceCards] '', 0, 0
CREATE PROCEDURE [dbo].[ListPriceCards]
	@CreatedOn VARCHAR(10),
	@CreatedBy INT
AS
BEGIN
IF @CreatedOn != '' AND @CreatedBy != 0
	SELECT PC.Id, PC.Name, PC.Amount, (SELECT Expression FROM Type WHERE Type.Value = PC.TicketType AND TypeName = 'TicketType'), PC.CreatedOn, U.UserName,PC.PriceCardGuid FROM PriceCard PC INNER JOIN BoxOfficeUser U ON U.UserId = PC.CreatedBy WHERE 
	CONVERT(VARCHAR(10), PC.CreatedOn, 110) = @CreatedOn AND IsDeleted = 0
	AND CreatedBy = @CreatedBy ORDER BY CreatedOn DESC
ELSE IF  @CreatedOn != ''
	SELECT PC.Id, PC.Name, PC.Amount, (SELECT Expression FROM Type WHERE Type.Value = PC.TicketType AND TypeName = 'TicketType'), PC.CreatedOn, U.UserName,PC.PriceCardGuid FROM PriceCard PC INNER JOIN BoxOfficeUser U ON U.UserId = PC.CreatedBy WHERE 
	CONVERT(VARCHAR(10), PC.CreatedOn, 110) = @CreatedOn AND IsDeleted = 0 ORDER BY CreatedOn DESC
ELSE IF @CreatedBy != 0
	SELECT PC.Id, PC.Name, PC.Amount, (SELECT Expression FROM Type WHERE Type.Value = PC.TicketType AND TypeName = 'TicketType'), PC.CreatedOn, U.UserName,PC.PriceCardGuid FROM PriceCard PC INNER JOIN BoxOfficeUser U ON U.UserId = PC.CreatedBy WHERE
	CreatedBy = @CreatedBy AND IsDeleted = 0 ORDER BY CreatedOn DESC
ELSE
	SELECT PC.Id, PC.Name, PC.Amount, (SELECT Expression FROM Type WHERE Type.Value = PC.TicketType AND TypeName = 'TicketType'), PC.CreatedOn, U.UserName,PC.PriceCardGuid FROM PriceCard PC INNER JOIN BoxOfficeUser U ON U.UserId = PC.CreatedBy WHERE IsDeleted = 0 ORDER BY CreatedOn DESC
END
GO

/*[GetPriceCardItems]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetPriceCardItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetPriceCardItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPriceCardItems]
AS
BEGIN
	SELECT Id, Name AS ItemName, '' AS ItemCollectionName, CalculationType, Code FROM PriceCardItems
	
	SELECT B.Id, A.Name As ItemName, A.Name AS ItemCollectionName, A.CalculationType, A.Code FROM PriceCardItemCollections A
	LEFT JOIN PriceCardItems B 
	ON A.PriceCardItemCode = B.Code
END
GO

/*[AddPriceCard]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddPriceCard]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddPriceCard]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddPriceCard]
	@UserId INT,
	@Id INT OUTPUT,
	@Name VARCHAR(64),
	@Amount NUMERIC(9,2),
	@Details VARCHAR(MAX),
	@TicketType TINYINT
AS
BEGIN

	IF EXISTS (SELECT Id FROM PriceCard WHERE Name = @Name AND IsDeleted = 0)
	BEGIN
		RAISERROR('Duplicate PriceCard Name', 11, 1)
		RETURN
	END
	
	INSERT INTO PriceCard(Name, Amount, TicketType, CreatedBy, CreatedOn) VALUES(@Name, @Amount, @TicketType, @UserId, GETDATE());
	SET @Id = @@IDENTITY
		
	DECLARE @ROWID1 AS INT;
	DECLARE @VALUE1 AS VARCHAR(MAX);
	DECLARE @VALUE2 AS VARCHAR(MAX);
	DECLARE @CMDSTR AS NVARCHAR(MAX)='';
	DECLARE FirstCursor CURSOR
	LOCAL SCROLL STATIC
	FOR
	SELECT * FROM DBO.SPLIT('|',@Details);
	OPEN FirstCursor
	FETCH NEXT FROM FirstCursor
	INTO @ROWID1, @VALUE1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CMDSTR = @CMDSTR + 'INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST)';
		SET @CMDSTR = @CMDSTR + ' VALUES('+ CAST(@Id as varchar) +',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=2;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=3;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=4;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=5;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=6;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=7;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''',';
		SELECT @VALUE2 = VALUE FROM  DBO.SPLIT(',', @VALUE1) WHERE ROWID=8;
		SET @CMDSTR = @CMDSTR + ' '''+@VALUE2+''');';
		EXEC sp_executesql  @CMDSTR;
		SET @CMDSTR='';
	FETCH NEXT FROM FirstCursor
	INTO @ROWID1, @VALUE1
	END
	CLOSE FirstCursor
	DEALLOCATE FirstCursor
END
GO

/*[SavePriceCardClassLayoutCollections]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SavePriceCardClassLayoutCollections]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SavePriceCardClassLayoutCollections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SavePriceCardClassLayoutCollections]
	@priceCardId INT,
	@classLayoutIds VARCHAR(1000)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM PriceCardClassLayoutCollections WHERE ClassLayoutId in (SELECT items FROM dbo.FnSplit(@classLayoutIds, ','))
			INSERT INTO PriceCardClassLayoutCollections (PriceCardId, ClassLayoutId) SELECT @priceCardId, items FROM dbo.FnSplit(@classLayoutIds, ',')
			UPDATE ClassLayout SET PriceCardId = 0 WHERE ClassLayoutID NOT IN (SELECT items FROM dbo.FnSplit(@classLayoutIds, ',')) AND PriceCardID = @priceCardId
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
GO

/*[GetClassLayoutIdsByPriceCard]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetClassLayoutIdsByPriceCard]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetClassLayoutIdsByPriceCard]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetClassLayoutIdsByPriceCard]
	@priceCardId INT
AS
BEGIN
	SELECT ClassLayoutId FROM PriceCardClassLayoutCollections WHERE PriceCardId = @priceCardId
END
GO

/* [UpdatePriceCardName] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdatePriceCardName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdatePriceCardName]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdatePriceCardName]
(
@PriceCardId INT,
@Name NVARCHAR(100)
)
AS
	IF NOT EXISTS (SELECT Id FROM PriceCard WHERE Name = @Name AND IsDeleted = 0)
		UPDATE PriceCard SET Name = @Name WHERE Id = @PriceCardId
GO

/*[SaveDCRClassLayoutCollections]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaveDCRClassLayoutCollections]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SaveDCRClassLayoutCollections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveDCRClassLayoutCollections]
	@dcrId INT,
	@classLayoutIds VARCHAR(1000)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM DCRClassLayoutCollections WHERE DCRId = @dcrId
			INSERT INTO DCRClassLayoutCollections (DCRId, ClassLayoutId) SELECT @dcrId, items FROM dbo.FnSplit(@classLayoutIds, ',')
			UPDATE ClassLayout SET DCRId = 0 WHERE ClassLayoutID NOT IN (SELECT items FROM dbo.FnSplit(@classLayoutIds, ',')) AND DCRId = @dcrId
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
GO

/*[GetClassLayoutIdsByDCR]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetClassLayoutIdsByDCR]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetClassLayoutIdsByDCR]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetClassLayoutIdsByDCR]
	@dcrId INT
AS
BEGIN
	SELECT ClassLayoutId FROM DCRClassLayoutCollections WHERE DCRId = @dcrId
END
GO

/*[UpdateDCRCount]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateDCRCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateDCRCount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateDCRCount]
AS
BEGIN
	DECLARE @classMISId AS INT;
	DECLARE classMISCursor CURSOR
	LOCAL SCROLL STATIC
	FOR
	SELECT C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON S.ShowID = C.ShowID WHERE IsLocked = 1 AND IsCancel = 0 AND C.DCRID > 0 AND C.OpeningDCRNo IS NULL AND S.IsHandoff = 0 ORDER BY ShowTime;
	OPEN classMISCursor
	FETCH NEXT FROM classMISCursor
	INTO @classMISId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @seatCountMIS AS INT;
		DECLARE @dcrOpenNoMIS AS INT;
		DECLARE @dcrCloseNoMIS AS INT;
		DECLARE @dcrMaxMIS AS INT;
		DECLARE @dcrStartingNoMIS AS INT;
			
		SELECT @seatCountMIS = COUNT(SeatID) FROM SeatMIS WHERE ClassID = @classMISId AND StatusType IN (2, 3);
			
		IF (@seatCountMIS > 0)
		BEGIN
			SELECT @dcrOpenNoMIS = DCRCount, @dcrMaxMIS = DCRMax, @dcrStartingNoMIS = DCRStartingNo FROM DCR WHERE DCRID = (SELECT DCRID FROM ClassMIS WHERE ClassID = @classMISId);
				
			SET @dcrCloseNoMIS = @dcrOpenNoMIS + @seatCountMIS
			IF (@dcrCloseNoMIS > @dcrMaxMIS)
			BEGIN
				SET @dcrCloseNoMIS = @dcrCloseNoMIS - @dcrMaxMIS
				IF (@dcrStartingNoMIS <> 1)
					SET @dcrCloseNoMIS = @dcrStartingNoMIS + @dcrCloseNoMIS - 1
			END
			
			BEGIN TRY
				BEGIN TRANSACTION
				UPDATE ClassMIS SET OpeningDCRNo = @dcrOpenNoMIS + 1, ClosingDCRNo = @dcrCloseNoMIS WHERE ClassID = @classMISId;
				UPDATE DCR SET DCRCount = @dcrCloseNoMIS, DCRNo = @dcrCloseNoMIS WHERE DCRID = (SELECT DCRID FROM ClassMIS WHERE ClassID = @classMISId);
				COMMIT
			END TRY
			BEGIN CATCH
				 IF @@TRANCOUNT > 0
					ROLLBACK
			END CATCH
		END
		ELSE
			UPDATE ClassMIS SET OpeningDCRNo = 0, ClosingDCRNo = 0 WHERE ClassID = @classMISId;
			
		FETCH NEXT FROM classMISCursor
		INTO @classMISId
	END
	CLOSE classMISCursor
	DEALLOCATE classMISCursor
	
	DECLARE @classId AS INT;
	DECLARE classCursor CURSOR
	LOCAL SCROLL STATIC
	FOR
	SELECT C.ClassID FROM Show S INNER JOIN Class C ON S.ShowID = C.ShowID WHERE IsLocked = 1 AND IsCancel = 0 AND C.DCRID > 0 AND C.OpeningDCRNo IS NULL AND S.IsHandoff = 0 ORDER BY ShowTime;
	OPEN classCursor
	FETCH NEXT FROM classCursor
	INTO @classId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @seatCount AS INT;
		DECLARE @dcrOpenNo AS INT;
		DECLARE @dcrCloseNo AS INT;
		DECLARE @dcrMAX AS INT;
		DECLARE @dcrStartingNo AS INT;
			
		SELECT @seatCount = COUNT(SeatID) FROM Seat WHERE ClassID = @classId AND StatusType IN (2, 3);
			
		IF (@seatCount > 0)
		BEGIN
			SELECT @dcrOpenNo = DCRCount, @dcrMAX = DCRMax, @dcrStartingNo= DCRStartingNo FROM DCR WHERE DCRID = (SELECT DCRID FROM Class WHERE ClassID = @classId);
				
			SET @dcrCloseNo = @dcrOpenNo + @seatCount
			IF (@dcrCloseNo > @dcrMAX)
			BEGIN
				SET @dcrCloseNo = @dcrCloseNo - @dcrMAX
				IF (@dcrStartingNo <> 1)
					SET @dcrCloseNo = @dcrStartingNo + @dcrCloseNo - 1
			END
			
			BEGIN TRY
				BEGIN TRANSACTION
				UPDATE Class SET OpeningDCRNo = @dcrOpenNo + 1, ClosingDCRNo = @dcrCloseNo WHERE ClassID = @classId;
				UPDATE DCR SET DCRCount = @dcrCloseNo, DCRNo = @dcrCloseNo WHERE DCRID = (SELECT DCRID FROM Class WHERE ClassID = @classId);
				COMMIT
			END TRY
			BEGIN CATCH
				 IF @@TRANCOUNT > 0
					ROLLBACK
			END CATCH
		END
		ELSE
			UPDATE Class SET OpeningDCRNo = 0, ClosingDCRNo = 0 WHERE ClassID = @classId;
			
		FETCH NEXT FROM classCursor
		INTO @classId
	END
	CLOSE classCursor
	DEALLOCATE classCursor
END
GO

/* [DailyCollectionReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DailyCollectionReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DailyCollectionReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[DailyCollectionReport] 1, 0, '10 Feb 2017'

CREATE PROCEDURE [dbo].[DailyCollectionReport]
	@theatreId INT,
	@screenId INT,
	@date VARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @date, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @date, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT
	SalesByDate.ScreenName [Screen Name],
	CONVERT(VARCHAR(20), SalesByDate.ShowTime) [Show Time],
	SalesByDate.MovieName [Movie Name],
	SalesByDate.Class [Class],
	SalesByDate.TT [Ticket Type],
	SalesByDate.TA [Ticket Amount],
	SalesByDate.ET [Entertainment Tax Per Ticket],
	SalesByDate.CGSTPercent [CGST %],
	SalesByDate.CGST [CGST Per Ticket],
	SalesByDate.SGSTPercent [SGST %],
	SalesByDate.SGST [SGST Per Ticket],
	SalesByDate.SC [Service Charge Per Ticket],
	SalesByDate.AT [Additional Tax Per Ticket],
	SalesByDate.FDF [Film Development Fund Per Ticket],
	SalesByDate.FC [Flood Cess Per Ticket],
	SalesByDate.OpeningDCRNo [Opening Number],
	SalesByDate.ClosingDCRNo [Closing Number],
	SUM(SalesByDate.SeatsSold) [Total Seats Sold],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.TA [Gross Collection],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.ET [Entertainment Tax Payable],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.CGST [CGST],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.SGST [SGST],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.SC [Service Charge],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.AT [Additional Tax],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.FDF [Film Development Fund],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.FC [Flood Cess],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.BTA [Net Collection],
	SalesByDate.DCRID [DCRID]
	INTO #SalesByDate
	FROM
	(
	SELECT 
		Sh.ScreenName ScreenName, 
		Sh.Showtime ShowTime, 
		Sh.MovieName AS MovieName, 
		Sh.ClassName AS Class,
		Sh.OpeningDCRNo AS OpeningDCRNo,
		Sh.ClosingDCRNo AS ClosingDCRNo,
		(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [TT],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGSTPercent,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGSTPercent,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.ClassID = S.ClassID AND S1.SeatID = S.SeatID AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.ClassID = S.ClassID AND S.SeatID = S1.SeatID AND S1.StatusType IN (2,3) AND S.PaymentType <> 5) AS PaidSeatsSold,
		Sh.DCRID
	FROM #SeatMasterByDate S INNER JOIN #ShowMasterByDate Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY Sh.ScreenName, Sh.ShowTime, Sh.ClassName, sh.MovieName, S.PriceCardId, S.ClassID, Sh.ClassID, Sh.OpeningDCRNo, Sh.ClosingDCRNo, S.PaymentType, S.SeatID, Sh.DCRID
	) SalesByDate
	GROUP BY ShowTime, ScreenName, MovieName, Class, TA, ET, CGST, CGSTPercent, SGST, SGSTPercent, SC, AT, BTA, FDF, TT, FC, OpeningDCRNo, ClosingDCRNo, DCRID
	
	DROP TABLE #ShowMasterByDate
	-- Table 0
	SELECT [Screen Name], 
	SUBSTRING(CONVERT(VARCHAR(11), [Show Time] , 101), 1, 11) [Show Date], 
	SUBSTRING(CAST([Show Time] AS VARCHAR), 12, 20) [Show Time],
	[Movie Name], 
	[Class], 
	[Ticket Type], 
	[Ticket Amount], 
	[Entertainment Tax Per Ticket], 
	[CGST %], 
	[CGST Per Ticket], 
	[SGST %], 
	[SGST Per Ticket], 
	[Service Charge Per Ticket], 
	[Additional Tax Per Ticket],
	[Film Development Fund Per Ticket],	
	[Flood Cess Per Ticket], 
	[Opening Number], 
	[Closing Number], 
	[Total Seats Sold], 
	[Gross Collection], 
	[Entertainment Tax Payable], 
	CGST,
	SGST,
	[Service Charge], 
	[Additional Tax], 
	[Film Development Fund], 
	[Flood Cess], 
	[Net Collection], 
	DCRID, 
	(SELECT DCRStartingNo FROM DCR WHERE DCR.DCRID = #SalesByDate.DCRID) AS DCRStartingNo, 
	(SELECT DCRMax FROM DCR WHERE DCR.DCRID = #SalesByDate.DCRID) AS DCRMax FROM #SalesByDate
	
	SELECT
		[Screen Name], [Show Time], [Movie Name], SUM([Total Seats Sold]) [Total Seats Sold], SUM([Gross Collection]) [Gross Collection], 
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable], 
		SUM(CGST) CGST, SUM(SGST) SGST, SUM([Service Charge]) [Service Charge], SUM([Additional Tax]) [Additional Tax], 
		SUM([Film Development Fund]) [Film Development Fund], SUM([Flood Cess]) [Flood Cess], SUM([Net Collection]) [Net Collection]
	INTO #ScreenWiseSalesByDate
	FROM
	#SalesByDate GROUP BY [Screen Name], [Show Time], [Movie Name]

	-- Table 1
	SELECT [Screen Name], SUBSTRING(CONVERT(VARCHAR(11), [Show Time] , 101), 1, 11) [Show Date], SUBSTRING(CAST([Show Time] AS VARCHAR), 12, 20) [Show Time],
	[Movie Name], [Total Seats Sold], [Gross Collection], [Entertainment Tax Payable], CGST, SGST, [Service Charge], [Additional Tax], [Film Development Fund], 
	[Flood Cess], [Net Collection]FROM #ScreenWiseSalesByDate
	
	-- Table 2
	SELECT 
		[Screen Name], Class, SUM([Total Seats Sold]) [Total Seats Sold], SUM([Gross Collection]) [Gross Collection], SUM([Entertainment Tax Payable]) [Entertainment Tax Payable], 
		SUM(CGST) CGST, SUM(SGST) SGST, SUM([Service Charge]) [Service Charge], SUM([Additional Tax]) [Additional Tax], 
		SUM([Film Development Fund]) [Film Development Fund], SUM([Flood Cess]) [Flood Cess], SUM([Net Collection]) [Net Collection] 
	FROM #SalesByDate  GROUP BY [Screen Name], Class ORDER BY [Screen Name]

	-- Table 3
	SELECT '' [Screen Name], '' [Show Time], '' [Movie Name], ISNULL(SUM([Total Seats Sold]), 0) [Total Seats Sold], 
	ISNULL(SUM([Gross Collection]), 0) [Gross Collection], ISNULL(SUM([Entertainment Tax Payable]), 0) [Entertainment Tax Payable], ISNULL(SUM(CGST), 0) CGST, 
	ISNULL(SUM(SGST), 0) SGST, ISNULL(SUM([Service Charge]), 0) [Service Charge], ISNULL(SUM([Additional Tax]), 0) [Additional Tax], 
	ISNULL(SUM([Film Development Fund]), 0) [Film Development Fund], ISNULL(SUM([Flood Cess]), 0) [Flood Cess], ISNULL(SUM([Net Collection]), 0) [Net Collection] FROM #ScreenWiseSalesByDate
	
	DROP TABLE #SalesByDate
	
	DECLARE @fromDate VARCHAR(11)
	SELECT @fromDate = CONVERT(VARCHAR(11), DATEADD(D, -((DATEPART(WEEKDAY, @date) + 1 + @@DATEFIRST) % 7), @date), 106)

	SELECT * INTO #ShowSummaryByWeek FROM 
	(
		SELECT S.ShowID, S.ScreenName, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.DCRID > 0 AND C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, @date, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ScreenName, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.DCRID > 0 AND C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, @date, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
	) ShowSummaryByWeek
	
	SELECT * INTO #SeatSummaryByWeek FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByWeek) AND StatusType IN (2,3)
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByWeek) AND StatusType IN (2,3)
	) SeatSummaryByWeek
	
	SELECT
		ScreenName AS [Screen Name],
		Class,
		SUM(SeatsSold) AS [Total Seats Sold],
		SUM(PaidSeatsSold) * TA AS [Gross Collection],
		SUM(PaidSeatsSold) * ET AS [Entertainment Tax Payable],
		SUM(PaidSeatsSold) * CGST AS CGST,
		SUM(PaidSeatsSold) * SGST AS SGST,
		SUM(PaidSeatsSold) * SC AS [Service Charge],
		SUM(PaidSeatsSold) * AT AS [Additional Tax],
		SUM(PaidSeatsSold) * FDF AS [Film Development Fund],
		SUM(PaidSeatsSold) * FC AS [Flood Cess],
		SUM(PaidSeatsSold) * BTA AS [Net Collection]
	INTO #SalesByWeek
	FROM
	(
	SELECT 
		Sh.ScreenName ScreenName,
		Sh.ClassName AS Class,
		COUNT(SeatId) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByWeek S1 WHERE S1.ClassID = S.ClassID AND S.SeatID = S1.SeatID AND S.PaymentType <> 5) AS PaidSeatsSold,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS TA
	FROM #SeatSummaryByWeek S INNER JOIN #ShowSummaryByWeek Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY Sh.ScreenName, Sh.ClassName, S.PriceCardId, S.ClassID, Sh.ClassID, S.PaymentType, S.SeatID
	) SalesByWeek
	GROUP BY ScreenName, Class, TA, ET, CGST, SGST, SC, AT, FDF, FC, BTA ORDER BY ScreenName
	
	DROP TABLE #ShowSummaryByWeek
	
	-- Table 4
	SELECT * FROM #SalesByWeek
	SELECT '' [Screen Name], '' Class, ISNULL(SUM([Total Seats Sold]), 0) [Total Seats Sold], ISNULL(SUM([Gross Collection]), 0) [Gross Collection], 
	ISNULL(SUM([Entertainment Tax Payable]), 0) [Entertainment Tax Payable], ISNULL(SUM(CGST), 0) CGST, ISNULL(SUM(SGST), 0) SGST, ISNULL(SUM([Service Charge]), 0) [Service Charge], 
	ISNULL(SUM([Additional Tax]), 0) [Additional Tax], ISNULL(SUM([Film Development Fund]), 0) [Film Development Fund], 
	ISNULL(SUM([Flood Cess]), 0) [Flood Cess], ISNULL(SUM([Net Collection]), 0) [Net Collection] 
	FROM #SalesByWeek
	
	DROP TABLE #SalesByWeek
	
	SELECT * INTO #ShowSummaryByEntireWeek FROM 
	(
		SELECT S.ShowID, S.ScreenName, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.DCRID > 0 AND C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @date, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ScreenName, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.DCRID > 0 AND C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @date, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
	) ShowSummaryByEntireWeek
	
	SELECT * INTO #SeatSummaryByEntireWeek FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByEntireWeek) AND StatusType IN (2,3)
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByEntireWeek) AND StatusType IN (2,3)
	) SeatSummaryByEntireWeek
	
	SELECT
		ScreenName AS [Screen Name],
		Class,
		SUM(SeatsSold) AS [Total Seats Sold],
		SUM(PaidSeatsSold) * TA AS [Gross Collection],
		SUM(PaidSeatsSold) * ET AS [Entertainment Tax Payable],
		SUM(PaidSeatsSold) * CGST AS CGST,
		SUM(PaidSeatsSold) * SGST AS SGST,
		SUM(PaidSeatsSold) * SC AS [Service Charge],
		SUM(PaidSeatsSold) * AT AS [Additional Tax],
		SUM(PaidSeatsSold) * FDF AS [Film Development Fund],
		SUM(PaidSeatsSold) * FC AS [Flood Cess],
		SUM(PaidSeatsSold) * BTA AS [Net Collection]
	INTO #SalesByEntireWeek
	FROM
	(
	SELECT 
		Sh.ScreenName ScreenName,
		Sh.ClassName AS Class,
		COUNT(SeatId) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByEntireWeek S1 WHERE S1.ClassID = S.ClassID AND S1.SeatID = S.SeatID AND S.PaymentType <> 5) AS PaidSeatsSold,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS TA
	FROM #SeatSummaryByEntireWeek S INNER JOIN #ShowSummaryByEntireWeek Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY Sh.ScreenName, Sh.ClassName, S.PriceCardId, S.ClassID, Sh.ClassID, S.PaymentType, S.SeatID
	) SalesByWeek
	GROUP BY ScreenName, Class, TA, ET, CGST, SGST, SC, AT, FDF, FC, BTA ORDER BY ScreenName
	
	DROP TABLE #ShowSummaryByEntireWeek
	
	-- Table 5
	SELECT * FROM #SalesByEntireWeek
	
	-- Table 6
	SELECT '' [Screen Name], '' Class, ISNULL(SUM([Total Seats Sold]), 0) [Total Seats Sold], ISNULL(SUM([Gross Collection]), 0) [Gross Collection], 
	ISNULL(SUM([Entertainment Tax Payable]), 0) [Entertainment Tax Payable], ISNULL(SUM(CGST), 0) CGST, ISNULL(SUM(SGST), 0) SGST, 
	ISNULL(SUM([Service Charge]), 0) [Service Charge], ISNULL(SUM([Additional Tax]), 0) [Additional Tax], 
	ISNULL(SUM([Film Development Fund]), 0) [Film Development Fund], ISNULL(SUM([Flood Cess]), 0) [Flood Cess], ISNULL(SUM([Net Collection]), 0) [Net Collection] FROM #SalesByEntireWeek
	
	DROP TABLE #SalesByEntireWeek
	
	-- Table 7
	SELECT CONVERT(VARCHAR(13), CONVERT(DATE, @fromDate), 106) AS LastFriday
	
	-- Table 8
	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN
	(SELECT PriceCardID FROM (SELECT PriceCardID FROM #SeatMasterByDate UNION SELECT PriceCardID FROM #SeatSummaryByWeek UNION SELECT PriceCardID FROM #SeatSummaryByEntireWeek)A))
	DROP TABLE #SeatMasterByDate
	DROP TABLE #SeatSummaryByWeek
	DROP TABLE #SeatSummaryByEntireWeek
	
	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip, ComplexPhone FROM Complex WHERE ComplexID = @theatreId
END
GO

/* [BoxOfficeSummary] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BoxOfficeSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BoxOfficeSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[BoxOfficeSummary] 1, 0, '05 Nov 2016', '22 Jun 2017'
CREATE PROCEDURE [dbo].[BoxOfficeSummary]
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT ShowID, MovieName, (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = MovieLanguageType) AS MovieLanguage FROM Show WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT ShowID, MovieName, (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = MovieLanguageType) AS MovieLanguage FROM ShowMIS WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND StatusType IN (2,3)
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND StatusType IN (2,3)
	) SeatMaster

	SELECT
		Sales.MovieName [Movie Name],
		Sales.MovieLanguage [Movie Language],
		SUM(Sales.PaidSeatsSold) [Total No. Of Paid Admits],
		SUM(Sales.FreeSeatsSold) [Total No. Of Free Admits],
		SUM(Sales.RegularSeatsSold) [No. Of Regular Seats Sold],
		SUM(Sales.DefenceSeatsSold) [No. Of Defence Seats Sold],
		SUM(Sales.ComplimentarySeatsSold) [No. Of Complimentary Seats Sold],
		SUM(Sales.SeatsSold) [Total Seats Sold],
		SUM(Sales.PaidSeatsSold) * Sales.TA [Gross Collection],
		SUM(Sales.PaidSeatsSold) * Sales.ET [Entertainment Tax Payable],
		Sales.CGSTPercentage [CGST %],
		SUM(Sales.PaidSeatsSold) * Sales.CGST CGST,
		Sales.SGSTPercentage [SGST %],
		SUM(Sales.PaidSeatsSold) * Sales.SGST SGST,
		SUM(Sales.PaidSeatsSold) * Sales.SC [Service Charge],
		SUM(Sales.PaidSeatsSold) * Sales.AT [Additional Tax],
		SUM(Sales.PaidSeatsSold) * Sales.FDF [Film Development Fund],
		SUM(Sales.PaidSeatsSold) * Sales.FC [Flood Cess],
		SUM(Sales.PaidSeatsSold) * Sales.BTA [Net Collection],
		SUM(Sales.PaidSeatsSold) * Sales.OTC [Other Theatre Charges]
	INTO #Sales
	FROM
	(
	SELECT 
		Sh.MovieName, 
		Sh.MovieLanguage,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGSTPercentage,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGSTPercentage,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Other_Theatre_Charges'), 0) AS OTC,
		(SELECT COUNT(S1.SeatID) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S.PaymentType <> 5) AS PaidSeatsSold,
		(SELECT COUNT(S1.SeatID) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S.PaymentType = 5) AS FreeSeatsSold,
		(SELECT COUNT(S1.SeatID) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 0)) AS RegularSeatsSold,
		(SELECT COUNT(S1.SeatID) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 1)) AS DefenceSeatsSold,
		(SELECT COUNT(S1.SeatID) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 2)) AS ComplimentarySeatsSold,
		COUNT(SeatId) AS SeatsSold
	FROM #SeatMaster S INNER JOIN #ShowMaster Sh ON Sh.ShowID = S.ShowID
	GROUP BY Sh.MovieName, Sh.MovieLanguage, S.PriceCardId, S.SeatID, S.PaymentType
	) Sales
	GROUP BY MovieName, MovieLanguage, TA, ET, CGST, SGST, CGSTPercentage, SGSTPercentage, SC, AT, FDF, BTA, OTC, FC
	
	SELECT
		[Movie Name], [Movie Language], SUM([Total No. Of Free Admits]) [Total No. Of Free Admits], SUM([Total No. Of Paid Admits]) [Total No. Of Paid Admits],
		SUM([No. Of Regular Seats Sold]) [No. Of Regular Seats Sold], SUM([No. Of Defence Seats Sold]) [No. Of Defence Seats Sold],
		SUM([No. Of Complimentary Seats Sold]) [No. Of Complimentary Seats Sold], SUM([Total Seats Sold]) [Total Seats Sold],
		SUM([Gross Collection]) [Gross Revenue], SUM([Entertainment Tax Payable]) [Entertainment Tax Payable], [CGST %], SUM(CGST) CGST, [SGST %], SUM(SGST) SGST, 
		SUM([Service Charge]) [Service Charge], SUM([Additional Tax]) [Additional Tax], SUM([Film Development Fund]) [Film Development Fund],
		SUM([Flood Cess]) [Flood Cess], 
		SUM([Net Collection]) [Net Revenue], SUM([Other Theatre Charges]) [Other Theatre Charges]
	INTO #FinalSales
	FROM
	#Sales GROUP BY [Movie Name], [Movie Language], [CGST %], [SGST %]
	
	IF EXISTS(SELECT TOP 1 [Movie Name] FROM #FinalSales)
	BEGIN
		SELECT
			[Movie Name], [Movie Language], [Total No. Of Free Admits], [Total No. Of Paid Admits], [No. Of Regular Seats Sold], [No. Of Defence Seats Sold],
			[No. Of Complimentary Seats Sold], [Total Seats Sold], [Gross Revenue], [Entertainment Tax Payable], [CGST %], CGST, [SGST %], SGST, [Service Charge], 
			[Additional Tax], [Film Development Fund], [Flood Cess], [Net Revenue], [Other Theatre Charges]
		FROM #FinalSales
		
		SELECT
			'' AS [Movie Name], 'Total' AS [Movie Language], SUM([Total No. Of Free Admits]) [Total No. Of Free Admits], SUM([Total No. Of Paid Admits]) [Total No. Of Paid Admits],
			SUM([No. Of Regular Seats Sold]) [No. Of Regular Seats Sold], SUM([No. Of Defence Seats Sold]) [No. Of Defence Seats Sold],
			SUM([No. Of Complimentary Seats Sold]) [No. Of Complimentary Seats Sold], SUM([Total Seats Sold]) [Total Seats Sold],
			SUM([Gross Revenue]) [Gross Revenue], SUM([Entertainment Tax Payable]) [Entertainment Tax Payable], NULL AS [CGST %], SUM(CGST) CGST, NULL AS[SGST %], SUM(SGST) SGST, 
			SUM([Service Charge]) [Service Charge], 
			SUM([Additional Tax]) [Additional Tax], SUM([Film Development Fund]) [Film Development Fund], 
			SUM([Flood Cess]) [Flood Cess], SUM([Net Revenue]) [Net Revenue], SUM([Other Theatre Charges]) [Other Theatre Charges]
		FROM #FinalSales
		
		SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster))
		UNION ALL
		SELECT Code FROM PriceCardItems WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster) AND Code = 'Other_Theatre_Charges')
	END
	
	DROP TABLE #SeatMaster
	DROP TABLE #ShowMaster
	DROP TABLE #Sales
	DROP TABLE #FinalSales
END
GO

/* [AddDistributor] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddDistributor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddDistributor]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddDistributor]
	@UserId INT,
	@Id INT OUTPUT,
	@Name VARCHAR(100)
AS
BEGIN

	IF EXISTS (SELECT Id FROM Distributors WHERE Name = @Name)
	BEGIN
		RAISERROR('Duplicate Distributor Name', 11, 1)
		RETURN
	END
	
	INSERT INTO Distributors(Name, CreatedBy, CreatedOn) VALUES(@Name, @UserId, GETDATE());
	SET @Id = @@IDENTITY
END

GO

/* Update Distributor Name */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateDistributorName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateDistributorName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateDistributorName]
(
@DistributorId INT,
@Name NVARCHAR(64)
)
AS
	IF NOT EXISTS (SELECT Id FROM Distributors WHERE Name = @Name)
		UPDATE Distributors SET Name = @Name WHERE Id = @DistributorId

GO

/* List Distributors */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListDistributors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ListDistributors]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [ListDistributors] '', 0, 0
CREATE PROCEDURE [dbo].[ListDistributors]
	@CreatedOn VARCHAR(10),
	@CreatedBy INT
AS
BEGIN
	IF @CreatedOn != '' AND @CreatedBy != 0
		SELECT D.Id, D.Name, D.CreatedOn, ISNULL(U.UserName, '') FROM Distributors D INNER JOIN BoxOfficeUser U ON U.UserId = D.CreatedBy WHERE 
		CONVERT(VARCHAR(10), D.CreatedOn, 110) = @CreatedOn
		AND CreatedBy = @CreatedBy ORDER BY CreatedOn DESC
	ELSE IF  @CreatedOn != ''
		SELECT D.Id, D.Name, D.CreatedOn, ISNULL(U.UserName, '') FROM Distributors D INNER JOIN BoxOfficeUser U ON U.UserId = D.CreatedBy WHERE 
		CONVERT(VARCHAR(10), D.CreatedOn, 110) = @CreatedOn ORDER BY CreatedOn DESC
	ELSE IF @CreatedBy != 0
		SELECT D.Id, D.Name, D.CreatedOn, ISNULL(U.UserName, '') FROM Distributors D INNER JOIN BoxOfficeUser U ON U.UserId = D.CreatedBy WHERE
		D.CreatedBy = @CreatedBy ORDER BY CreatedOn DESC
	ELSE
		SELECT D.Id, D.Name, D.CreatedOn, ISNULL(U.UserName, '') FROM Distributors D INNER JOIN BoxOfficeUser U ON U.UserId = D.CreatedBy ORDER BY CreatedOn DESC
END
GO

/* [AddDistributorMovieDeductions] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddDistributorMovieDeductions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddDistributorMovieDeductions]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[AddDistributorMovieDeductions] 1, 0, 1, '0', 'ada', 'ada', 1, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
CREATE PROCEDURE [dbo].[AddDistributorMovieDeductions]
	@UserId INT,
	@Id INT OUTPUT,
	@DistributorID INT,
	@OnlineMovieID NVARCHAR(64),
	@OnlineMovieName NVARCHAR(64),
	@MovieName NVARCHAR(64),	
	@Language TINYINT,
	@CensorRating TINYINT,
	@ShowTax NUMERIC(9,2),
	@INR NUMERIC(9,2),
	@Publicity NUMERIC(9,2),
	@Shuttling NUMERIC(9,2),
	@PrintExpenses NUMERIC(9,2),
	@RepresentativeDearnessAllowance NUMERIC(9,2),
	@BannerTax NUMERIC(9,2),
	@AdvertisementTax NUMERIC(9,2),
	@HealthCess NUMERIC(9,2),
	@Others NUMERIC(9,2),
	@MovieMergedTo NVARCHAR(64)
AS
BEGIN
	IF EXISTS (SELECT Id FROM [DistributorMovieCollections] WHERE OnlineMovieID = @OnlineMovieID AND MovieName = @MovieName AND [IsDeleted] = 0)
	BEGIN
		RAISERROR('Movie is already mapped with another Distributor', 11, 1)
		RETURN
	END
BEGIN TRY
BEGIN TRANSACTION
	INSERT INTO [DistributorMovieCollections](OnlineMovieID, OnlineMovieName, MovieName, DistributorID, Language, CensorRating, ShowTax, INR, Publicity, Shuttling, PrintExpenses, RepresentativeDearnessAllowance, BannerTax, AdvertisementTax, HealthCess, Others, CreatedBy, CreatedOn, MovieMergedTo)
	VALUES(@OnlineMovieID, @OnlineMovieName, @MovieName, @DistributorID, @Language, @CensorRating, @ShowTax, @INR, @Publicity, @Shuttling, @PrintExpenses, @RepresentativeDearnessAllowance, @BannerTax, @AdvertisementTax, @HealthCess, @Others, @UserId, GETDATE(), @MovieMergedTo)
	SET @Id = @@IDENTITY
COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
END CATCH
END

GO

/* UpdateDistributorMovieDeductions */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateDistributorMovieDeductions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateDistributorMovieDeductions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- UpdateDistributorMovieDeductions 1, 1, 1, 1, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
CREATE PROCEDURE [dbo].UpdateDistributorMovieDeductions
(
	@UserId INT,
	@Id INT,
	@DistributorID INT,
	@ShowTax NUMERIC(9,2),
	@INR NUMERIC(9,2),
	@Publicity NUMERIC(9,2),
	@Shuttling NUMERIC(9,2),
	@PrintExpenses NUMERIC(9,2),
	@RepresentativeDearnessAllowance NUMERIC(9,2),
	@BannerTax NUMERIC(9,2),
	@AdvertisementTax NUMERIC(9,2),
	@HealthCess NUMERIC(9,2),
	@Others NUMERIC(9,2)
)
AS
BEGIN TRY
BEGIN TRANSACTION
	IF NOT EXISTS (SELECT Id FROM DistributorMovieCollections WHERE Id = @Id AND IsDeleted = 1)
	BEGIN
		IF NOT EXISTS (SELECT ShowID FROM Show WHERE DistributorMovieId = @Id)
			UPDATE [DistributorMovieCollections] SET 
			ShowTax = @ShowTax, INR = @INR, Publicity = @Publicity, Shuttling = @Shuttling, PrintExpenses = @PrintExpenses, RepresentativeDearnessAllowance = @RepresentativeDearnessAllowance, BannerTax = @BannerTax, AdvertisementTax = @AdvertisementTax, HealthCess = @HealthCess, Others = @Others WHERE Id = @Id AND DistributorID = @DistributorId
		ELSE
		BEGIN
			UPDATE [DistributorMovieCollections] SET 
			IsDeleted = 1, ModifiedBy = @UserId, ModifiedOn = GETDATE() WHERE Id = @Id AND DistributorID = @DistributorId
			
			INSERT INTO [DistributorMovieCollections](OnlineMovieID, OnlineMovieName, MovieName, DistributorID, Language, CensorRating, ShowTax, INR, Publicity, Shuttling, PrintExpenses, RepresentativeDearnessAllowance, BannerTax, AdvertisementTax, HealthCess, Others, CreatedBy, CreatedOn)
			SELECT OnlineMovieID, OnlineMovieName, MovieName, @DistributorID, Language, CensorRating, @ShowTax, @INR, @Publicity, @Shuttling, @PrintExpenses, @RepresentativeDearnessAllowance, @BannerTax, @AdvertisementTax, @HealthCess, @Others, @UserId, GETDATE() FROM [DistributorMovieCollections] WHERE Id = @Id AND DistributorID = @DistributorId
		END
	END
COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
END CATCH
GO

/* DeleteDistributorMovieById */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteDistributorMovieById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].DeleteDistributorMovieById
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DeleteDistributorMovieById 1
CREATE PROCEDURE [dbo].DeleteDistributorMovieById
(
	@Id INT
)
AS
BEGIN
	IF NOT EXISTS (SELECT Id FROM DistributorMovieCollections WHERE Id = @Id AND IsDeleted = 1)
		IF NOT EXISTS (SELECT ShowID FROM Show WHERE DistributorMovieId = @Id)
			DELETE FROM [DistributorMovieCollections] WHERE Id = @Id
END
GO

/* [DistributorReport] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[DistributorReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DistributorReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[DistributorReport] 1, 0, '07 Aug 2022', 1, 'K.G.F Chapter 2'

CREATE PROCEDURE [dbo].[DistributorReport]
	@theatreId INT,
	@screenId INT,
	@showDate VARCHAR(11),
	@distributorId INT,
	@movieName NVARCHAR(256)
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT S.ShowID, S.ShowTime, S.MovieName, (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = S.MovieLanguageType) AS MovieLanguage, S.ScreenName, C.ClassName, C.ClassID, S.ShowName FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.MovieName, (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = S.MovieLanguageType) AS MovieLanguage, S.ScreenName, C.ClassName, C.ClassID, S.ShowName FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
	) SeatMaster
	
	SELECT
	SalesByDate.ScreenName [Screen Name],
	SalesByDate.ShowTime,
	SalesByDate.MovieLanguage [Language],
	SalesByDate.Class [Class Name],
	SalesByDate.TT [Ticket Type],
	SUM(SalesByDate.SeatsSold) [Seats Sold],
	SalesByDate.TA [Ticket Cost Per Ticket],
	SalesByDate.CGSTPercent [CGST %],
	SalesByDate.CGST [CGST Per Ticket],
	SalesByDate.SGSTPercent [SGST %],
	SalesByDate.SGST [SGST Per Ticket],
	SalesByDate.SC [Service Charge Per Ticket],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.TA [Gross Receipt],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.ET [Entertainment Tax Payable],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.CGST CGST,
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.SGST SGST,
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.SC [Service Charge],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.AT [Additional Tax],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.FDF [Film Development Fund],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.FC [Flood Cess],
	SUM(SalesByDate.PaidSeatsSold) * SalesByDate.BTA [Net Collection],
	ShowName
	INTO #SalesByDate
	FROM
	(
	SELECT 
		Sh.ScreenName AS ScreenName, 
		Sh.Showtime AS ShowTime,
		Sh.MovieLanguage AS MovieLanguage,
		Sh.ClassName AS Class,
		(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') [TT],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGSTPercent,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGSTPercent,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.PaymentType <> 5 AND S1.StatusType IN (2,3)) AS PaidSeatsSold,
		Sh.ShowName
	FROM #SeatMaster S INNER JOIN #ShowMaster Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY Sh.ScreenName, Sh.ShowTime, Sh.ShowName, Sh.ClassName, Sh.MovieName, Sh.MovieLanguage, S.PriceCardId, S.ClassID, Sh.ClassID
	) SalesByDate
	GROUP BY ScreenName, ShowTime, ShowName, MovieLanguage, Class, TA, ET, CGST, CGSTPercent, SGST, SGSTPercent, SC, AT, SeatsSold, FDF, FC, BTA, TT
	
	DROP TABLE #ShowMaster
	SELECT
		([Screen Name]+' @ ' + SUBSTRING(CAST(CONVERT(VARCHAR(20), ShowTime) AS VARCHAR), 12, 20)+ ' '+ [Language]) [Show Details],
		[Screen Name], SUBSTRING(CAST(CONVERT(VARCHAR(20), ShowTime) AS VARCHAR), 12, 20) [Show Time], [Language], 
		'' [Class Name], '' [Ticket Type], SUM([Seats Sold]) [Seats Sold], 
		SUM([Gross Receipt]) [Gross Receipt], SUM([Entertainment Tax Payable]) [Entertainment Tax Payable], SUM(CGST) CGST, SUM(SGST) SGST, SUM([Service Charge]) [Service Charge], 
		SUM([Additional Tax]) [Additional Tax], SUM([Film Development Fund]) [Film Development Fund], SUM([Flood Cess]) [Flood Cess],SUM([Net Collection]) [Net Collection]
	INTO #ScreenWiseSalesByDate
	FROM
	#SalesByDate GROUP BY [Screen Name], ShowTime, [Language] ORDER BY ShowTime
	
	--Table 0
	SELECT '' [Show Details],[Screen Name], SUBSTRING(CAST(CONVERT(VARCHAR(20), ShowTime) AS VARCHAR), 12, 20) [Show Time], [Language], [Class Name], [Ticket Type], [Ticket Cost Per Ticket], [Seats Sold], 
	[Gross Receipt], [CGST %], [CGST Per Ticket], [SGST %], [SGST Per Ticket], [Service Charge Per Ticket] ,[Entertainment Tax Payable], CGST, SGST, [Additional Tax], [Service Charge], 
	[Film Development Fund], [Flood Cess], [Net Collection], ShowName FROM #SalesByDate
	ORDER BY  [Screen Name], ShowTime, ShowName, [Ticket Cost Per Ticket] DESC	

	DROP TABLE #SalesByDate
	
	DECLARE @fromDate VARCHAR(24)
	SELECT @fromDate = CONVERT(VARCHAR(24), DATEADD(D, -((DATEPART(WEEKDAY, @showDate) + 1 + @@DATEFIRST) % 7), @showDate), 106)

	SELECT * INTO #ShowSummaryByWeek FROM 
	(
		SELECT S.ShowID, CONVERT(VARCHAR(11), S.ShowTime, 6) AS [Show Date], C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID INNER JOIN Seat SE ON SE.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0 AND SE.StatusType = 2 GROUP BY S.ShowID, S.ShowTime, C.ClassName, C.ClassID
		UNION ALL
		SELECT S.ShowID, CONVERT(VARCHAR(11), S.ShowTime, 6) AS [Show Date], C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID INNER JOIN SeatMIS SE ON SE.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0 AND SE.StatusType = 2 GROUP BY S.ShowID, S.ShowTime, C.ClassName, C.ClassID
	) ShowSummaryByWeek
	
	SELECT * INTO #SeatSummaryByWeek FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByWeek) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByWeek) AND SeatType <> 1
	) SeatSummaryByWeek
	
	SELECT
		[Show Date],
		COUNT(ShowID) AS [ShowCount],
		SUM(TotalSeats) AS TotalSeats,
		SUM([HouseFul Net]) AS [HouseFul Net],
		SUM(PaidSeatsSold) AS PaidSeatsSold,
		SUM([PaidSeats Net]) AS [PaidSeats Net],
		SUM(FreeSeatsSold) AS FreeSeatsSold,
		SUM(PaidSeatsSold) + SUM(FreeSeatsSold) AS [Seats Sold],
		ROUND((SUM([PaidSeats Net]) * 100.0 / SUM([HouseFul Net])), 2) AS [Sales Percentage],
		SUM([PaidSeats Gross]) AS [PaidSeats Gross]
	INTO #SalesByWeek
	FROM
	(
		SELECT
			[Show Date],
			ShowID,
			SUM(TotalSeats) AS TotalSeats,
			SUM([HouseFul Net]) AS [HouseFul Net],
			SUM(PaidSeatsSold) AS PaidSeatsSold,
			SUM([PaidSeats Net]) AS [PaidSeats Net],
			SUM([PaidSeats Gross]) AS [PaidSeats Gross],
			SUM(FreeSeatsSold) AS FreeSeatsSold
		FROM
		(
			SELECT
				[Show Date],
				ShowID,
				ClassID,
				TotalSeats,
				TotalSeats * BTA AS [HouseFul Net],
				PaidSeatsSold,
				PaidSeatsSold * BTA AS [PaidSeats Net],
				FreeSeatsSold,
				PaidSeatsSold * TA AS [PaidSeats Gross]
			FROM
			(
				SELECT
					Sh.[Show Date],
					Sh.ShowID,
					Sh.ClassID,
					COUNT(SeatId) AS TotalSeats,
					(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByWeek S1 WHERE S1.ClassID = S.ClassID AND S1.PaymentType <> 5 AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS PaidSeatsSold,
					(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByWeek S1 WHERE S1.ClassID = S.ClassID AND S1.PaymentType = 5 AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS FreeSeatsSold,
					ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
					ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) AS TA
				FROM #SeatSummaryByWeek S INNER JOIN #ShowSummaryByWeek Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
				GROUP BY Sh.[Show Date], Sh.ShowID, S.ClassID, Sh.ClassID, S.PriceCardId
			)A
			GROUP BY [Show Date], ShowID, ClassID, TotalSeats, PaidSeatsSold, FreeSeatsSold, BTA, TA
		)B
		GROUP BY [Show Date], ShowID
	)SalesByWeek
	GROUP BY [Show Date]
	
	DROP TABLE #SeatSummaryByWeek
	DROP TABLE #ShowSummaryByWeek
	
	--Table 1
	SELECT * FROM #ScreenWiseSalesByDate
	
	--Table 2	
	SELECT 'Today''s Total' [Show Details], '' [Screen Name], '' [Show Time], '' [Class Name], '' [Ticket Type], 
	ISNULL(SUM([Seats Sold]), 0) [Seats Sold], 
	ISNULL(SUM([Gross Receipt]), 0) [Gross Receipt], ISNULL(SUM([Entertainment Tax Payable]), 0) [Entertainment Tax Payable], ISNULL(SUM(CGST), 0) CGST, 
	ISNULL(SUM(SGST), 0) SGST, ISNULL(SUM([Service Charge]), 0) [Service Charge], 
	ISNULL(SUM([Additional Tax]), 0) [Additional Tax], ISNULL(SUM([Film Development Fund]), 0) [Film Development Fund], 
	ISNULL(SUM([Flood Cess]), 0) [Flood Cess], ISNULL(SUM([Net Collection]), 0) [Net Collection] FROM #ScreenWiseSalesByDate

	DROP TABLE #ScreenWiseSalesByDate
	
	--Table 3
	SELECT
		LEFT(DATENAME(DW,[Show Date]), 3) + ', ' + [Show Date] AS [Day],
		[ShowCount] AS [Shows],
		TotalSeats AS [Seats in Inventory],
		[Seats Sold] AS [Seats Sold],
		[HouseFul Net] AS [Houseful Nett],
		[PaidSeats Net] AS [Nett],
		CAST([Sales Percentage] AS DECIMAL(10,2)) AS [Sales %]
	FROM
		#SalesByWeek
	--Table 4
	SELECT 'Total' [Day], ISNULL(SUM([ShowCount]), 0) [Shows], ISNULL(SUM([TotalSeats]), 0) [Seats in Inventory], 
	ISNULL(SUM([Seats Sold]), 0) [Seats Sold], ISNULL(SUM([HouseFul Net]), 0) [Houseful Nett], ISNULL(SUM([PaidSeats Net]), 0) [Nett], 
	ISNULL(CAST((SUM([PaidSeats Net]) * 100.0 / SUM([HouseFul Net])) AS DECIMAL(10,2)), 0) [Sales %] FROM #SalesByWeek
	
	SELECT * INTO #ShowSummaryByAllWeek FROM 
	(
		SELECT S.ShowID, CONVERT(VARCHAR(11), S.ShowTime, 106) AS [Show Date], C.ClassName, C.ClassID, S.DistributorMovieID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID INNER JOIN Seat SE ON SE.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0 AND SE.StatusType = 2 GROUP BY S.ShowID, S.ShowTime, C.ClassName, C.ClassID, S.DistributorMovieID 
		UNION ALL
		SELECT S.ShowID, CONVERT(VARCHAR(11), S.ShowTime, 106) AS [Show Date], C.ClassName, C.ClassID, S.DistributorMovieID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID INNER JOIN SeatMIS SE ON SE.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0 AND SE.StatusType = 2 GROUP BY S.ShowID, S.ShowTime, C.ClassName, C.ClassID, S.DistributorMovieID 
	) ShowSummaryByAllWeek
	
	SELECT * INTO #SeatSummaryByAllWeek FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByAllWeek) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByAllWeek) AND SeatType <> 1
	) SeatSummaryByAllWeek
	
	SELECT
		[Show Date],
		ShowID,
		DistributorMovieID,
		SUM(TotalSeats) AS TotalSeats,
		SUM([HouseFul Net]) AS [HouseFul Net],
		SUM(PaidSeatsSold) AS PaidSeatsSold,
		SUM([PaidSeats Net]) AS [PaidSeats Net],
		SUM(FreeSeatsSold) AS FreeSeatsSold
	INTO #TempSalesByAllWeek
	FROM
	(
		SELECT
			[Show Date],
			ShowID,
			ClassID,
			DistributorMovieID,
			TotalSeats,
			TotalSeats * BTA AS [HouseFul Net],
			PaidSeatsSold,
			PaidSeatsSold * BTA AS [PaidSeats Net],
			FreeSeatsSold
		FROM
		(
			SELECT
				Sh.[Show Date],
				Sh.ShowID,
				Sh.ClassID,
				Sh.DistributorMovieID,
				COUNT(SeatId) AS TotalSeats,
				(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByAllWeek S1 WHERE S1.ClassID = S.ClassID AND S1.PaymentType <> 5 AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS PaidSeatsSold,
				(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByAllWeek S1 WHERE S1.ClassID = S.ClassID AND S1.PaymentType = 5 AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS FreeSeatsSold,
				ISNULL((SELECT SUM(Price) FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA
			FROM #SeatSummaryByAllWeek S INNER JOIN #ShowSummaryByAllWeek Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
			GROUP BY Sh.[Show Date], Sh.ShowID, S.ClassID, Sh.ClassID, Sh.DistributorMovieID, S.PriceCardId
		)A
		GROUP BY [Show Date], ShowID, ClassID, DistributorMovieID, TotalSeats, PaidSeatsSold, FreeSeatsSold, BTA
	)TempSalesByAllWeek
	GROUP BY [Show Date], ShowID, DistributorMovieID
	
	SELECT
		[Show Date],
		COUNT(ShowID) AS [ShowCount],
		SUM(TotalSeats) AS TotalSeats,
		SUM([HouseFul Net]) AS [HouseFul Net],
		SUM(PaidSeatsSold) AS PaidSeatsSold,
		SUM([PaidSeats Net]) AS [PaidSeats Net],
		SUM(FreeSeatsSold) AS FreeSeatsSold,
		SUM(PaidSeatsSold) + SUM(FreeSeatsSold) AS [Seats Sold],
		ROUND((SUM([PaidSeats Net]) * 100.0 / SUM([HouseFul Net])), 2) AS [Sales Percentage]
	INTO #SalesByAllWeek
	FROM
		#TempSalesByAllWeek
	GROUP BY [Show Date]
	
	CREATE TABLE #WeeklySales
	(
		[WeekCount] INT NOT NULL,
		[Week] NVARCHAR(50) NOT NULL DEFAULT(''),
		[Shows] INT NOT NULL,
		[Seats in Inventory] INT NOT NULL,
		[Seats Sold] INT NOT NULL,
		[Houseful Nett] NUMERIC(11,2) NOT NULL,
		[Nett] NUMERIC(11,2) NOT NULL,
		[Sales %] NUMERIC(11,2) NOT NULL
	)

	DECLARE @weekCount INT
	SET @weekCount = 0

	WHILE ((SELECT COUNT([Show Date]) FROM #SalesByAllWeek) > 0)
	BEGIN
		SET @weekCount = @weekCount + 1
		INSERT INTO #WeeklySales ([WeekCount], [Week], [Shows], [Seats in Inventory], [Seats Sold], [Houseful Nett], [Nett], [Sales %])
		SELECT
			@weekcount,
			CONVERT(VARCHAR(6), DATEADD(DAY, 0, @fromDate), 6) + '-' + CASE WHEN DATEADD(DAY, 6, @fromDate) >= DATEADD(DAY, 0, @showDate) THEN CONVERT(VARCHAR(6), DATEADD(DAY, 0, @showDate), 6) ELSE CONVERT(VARCHAR(6), DATEADD(DAY, 6, @fromDate), 6) END,
			ISNULL(SUM(ShowCount), 0),
			ISNULL(SUM(TotalSeats), 0),
			ISNULL(SUM(PaidSeatsSold) + SUM(FreeSeatsSold), 0),
			ISNULL(SUM([HouseFul Net]), 0),
			ISNULL(SUM([PaidSeats Net]), 0),			
			ROUND(ISNULL((SUM([PaidSeats Net]) * 100.0 / SUM([HouseFul Net])), 0), 2)
		FROM
			#SalesByAllWeek
		WHERE
			CONVERT(DATETIME,CONVERT(VARCHAR(24),[Show Date],106),106) >= CONVERT(DATETIME,CONVERT(VARCHAR(24),@fromDate,106),106)
			
		DELETE FROM #SalesByAllWeek WHERE CONVERT(DATETIME,CONVERT(VARCHAR(24),[Show Date],106),106) >= CONVERT(DATETIME,CONVERT(VARCHAR(24),@fromDate,106),106)
		SET @fromDate = DATEADD(DAY, -7, @fromDate)
	END
	--Table 5
	SELECT [Week], [Shows], [Seats in Inventory], [Seats Sold], [Houseful Nett], [Nett], [Sales %] FROM #WeeklySales ORDER BY [WeekCount] DESC
	
	--Table 6
	SELECT 'Total' [Week], ISNULL(SUM([Shows]), 0) [Shows], ISNULL(SUM([Seats in Inventory]), 0) [Seats in Inventory], 
	ISNULL(SUM([Seats Sold]), 0) [Seats Sold], ISNULL(SUM([Houseful Nett]), 0) [Houseful Nett], ISNULL(SUM([Nett]), 0) [Nett], 
	ISNULL(CAST((SUM([Nett]) * 100.0 / SUM([Houseful Nett])) AS DECIMAL(10,2)), 0) [Sales %] FROM #WeeklySales
	
	--Table 7
	SELECT TOP 1 ShowTax [Show Tax], INR, Publicity, Shuttling, PrintExpenses [Print Expenses], RepresentativeDearnessAllowance [Representative Dearness Allowance], 
	BannerTax [Banner Tax], AdvertisementTax [Advertisement Tax], HealthCess [Health Cess], Others 
	FROM DistributorMovieCollections WHERE DistributorID = @distributorId AND MovieName = @movieName
	ORDER BY Id DESC
	
	--Table 8
	SELECT
		COUNT(ShowID) AS [ShowCount],
		ISNULL(SUM([PaidSeats Net]), 0) AS [PaidSeats Net],
		COUNT(DISTINCT [Show date]) AS [DayCount]
	FROM
		#TempSalesByAllWeek
	
	--Table 9
	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster))
	DROP TABLE #SeatMaster
	DROP TABLE #SeatSummaryByAllWeek
	DROP TABLE #ShowSummaryByAllWeek
	DROP TABLE #TempSalesByAllWeek
	DROP TABLE #SalesByAllWeek
	DROP TABLE #WeeklySales
	
	--Table 10
	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip, ComplexPhone, isnull(GSTIN,'') [GSTIN] FROM Complex WHERE ComplexID = @theatreId

	--Table 11
	SELECT [Show Details], 
	sum(SeatsSold) [Seats Sold], 
	sum(GrossReceipt) [Gross Receipt],
	sum(NetCollection) [Net Collection] FROM
	(
		SELECT 'Previous Total' [Show Details], 0 [SeatsSold],0 [GrossReceipt], 0 [NetCollection]
		UNION ALL
		SELECT 'Previous Total' [Show Details], sum([Seats Sold]) [SeatsSold], sum([PaidSeats Gross]) [GrossReceipt], sum([PaidSeats Net]) [NetCollection] FROM #SalesByWeek
		where [Show Date] < CONVERT(DATETIME,@showDate,106)
	)PREVTOTAL GROUP BY [Show Details]
	UNION ALL
	SELECT 'Grand Total' [Show Details], 
	ISNULL(SUM([Seats Sold]), 0) [Seats Sold], 
	ISNULL(SUM([PaidSeats Gross]), 0) [Gross Receipt], 
	ISNULL(SUM([PaidSeats Net]), 0) [Net Collection] FROM #SalesByWeek
	
	DROP TABLE #SalesByWeek
END
GO

/* [BoxOfficeReceiptsSummary] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[BoxOfficeReceiptsSummary]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BoxOfficeReceiptsSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[BoxOfficeReceiptsSummary] 1, 1, '01 Nov 2016', '02 Jul 2017'

CREATE PROCEDURE [dbo].[BoxOfficeReceiptsSummary]
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT ShowID FROM ShowMIS WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT SeatID, PriceCardId, PaymentType, LastSoldOn FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND StatusType IN (2,3)
		UNION ALL
		SELECT SeatID, PriceCardId, PaymentType, LastSoldOn FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND StatusType IN (2,3)
	) SeatMaster
	
	SELECT
		SUM(Sales.SeatsSold) [SeatsSold],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.TA [SeatsSold Gross],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.ET [SeatsSold ET],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.CGST [SeatsSold CGST],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.SGST [SeatsSold SGST],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.SC [SeatsSold SC],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.AT [SeatsSold AT],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.FDF [SeatsSold FDF],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.FC [SeatsSold FC],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.BTA [SeatsSold Net],
		(SUM(Sales.SeatsSold) - SUM(Sales.FreeSeat)) * Sales.OTC [SeatsSold OTC],
		SUM(Sales.PriorSaleSeat) [PriorSaleSeat],
		SUM(Sales.PriorSaleSeat) * Sales.TA [PriorSaleSeat Gross],
		SUM(Sales.PriorSaleSeat) * Sales.ET [PriorSaleSeat ET],
		SUM(Sales.PriorSaleSeat) * Sales.CGST [PriorSaleSeat CGST],
		SUM(Sales.PriorSaleSeat) * Sales.SGST [PriorSaleSeat SGST],
		SUM(Sales.PriorSaleSeat) * Sales.SC [PriorSaleSeat SC],
		SUM(Sales.PriorSaleSeat) * Sales.AT [PriorSaleSeat AT],
		SUM(Sales.PriorSaleSeat) * Sales.FDF [PriorSaleSeat FDF],
		SUM(Sales.PriorSaleSeat) * Sales.FC [PriorSaleSeat FC],
		SUM(Sales.PriorSaleSeat) * Sales.BTA [PriorSaleSeat Net],
		SUM(Sales.PriorSaleSeat) * Sales.OTC [PriorSaleSeat OTC],
		SUM(Sales.PriorFreeSeatSale) [PriorFreeSeatSale]
	INTO #Sales
	FROM
	(
	SELECT
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Other_Theatre_Charges'), 0) AS OTC,
		COUNT(SeatId) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatId = S.SeatId AND S1.PaymentType = 5) AS FreeSeat,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatId = S.SeatId AND S1.PaymentType <> 5 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S1.LastSoldOn, 106)) < CONVERT(DATETIME, @startDate, 106)) AS PriorSaleSeat,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatId = S.SeatId AND S1.PaymentType = 5 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S1.LastSoldOn, 106)) < CONVERT(DATETIME, @startDate, 106)) AS PriorFreeSeatSale
	FROM
		#SeatMaster S
	GROUP BY
		S.SeatId, S.PriceCardId
	) Sales
	GROUP BY ET, CGST, SGST, SC, AT, SeatsSold, FDF, FC, BTA, TA, OTC, FreeSeat, PriorSaleSeat, PriorFreeSeatSale
	
	SELECT
		'Total Number of Sold Seats including Free Seats' [Details],
		SUM([SeatsSold]) [Number of Sold Seats],
		SUM([SeatsSold Gross]) [Gross Revenue],
		SUM([SeatsSold ET]) [Entertainment Tax Payable],
		SUM([SeatsSold CGST]) CGST,
		SUM([SeatsSold SGST]) SGST,
		SUM([SeatsSold SC]) [Service Charge],
		SUM([SeatsSold AT]) [Additional Tax],
		SUM([SeatsSold FDF]) [Film Development Fund],
		SUM([SeatsSold FC]) [Flood Cess],
		SUM([SeatsSold Net]) [Net Revenue],
		SUM([SeatsSold OTC]) [Other Theatre Charges]
	FROM
		#Sales
	
	SELECT
		'Prior Sales' [Details],
		SUM([PriorSaleSeat]) [Number of Sold Seats],
		SUM([PriorSaleSeat Gross]) [Gross Revenue],
		SUM([PriorSaleSeat ET]) [Entertainment Tax Payable],
		SUM([PriorSaleSeat CGST]) [CGST],
		SUM([PriorSaleSeat SGST]) SGST,
		SUM([PriorSaleSeat SC]) [Service Charge],
		SUM([PriorSaleSeat AT]) [Additional Tax],
		SUM([PriorSaleSeat FDF]) [Film Development Fund],
		SUM([PriorSaleSeat FC]) [Flood Cess],
		SUM([PriorSaleSeat Net]) [Net Revenue],
		SUM([PriorSaleSeat OTC]) [Other Theatre Charges]
	FROM
		#Sales
	
	SELECT
		'Free Seats' [Details],
		SUM([PriorFreeSeatSale]) [Number of Sold Seats],
		0 [Gross Revenue],
		0 [Entertainment Tax Payable],
		0 CGST,
		0 SGST,
		0 [Service Charge],
		0 [Additional Tax],
		0 [Film Development Fund],
		0 [Flood Cess],
		0 [Net Revenue],
		0 [Other Theatre Charges]
	FROM
		#Sales
		
	SELECT
		SUM([SeatsSold]) - SUM([PriorSaleSeat]) - SUM([PriorFreeSeatSale]) [Number of Sold Seats],
		SUM([SeatsSold Gross]) - SUM([PriorSaleSeat Gross]) [Gross Revenue],
		SUM([SeatsSold ET]) - SUM([PriorSaleSeat ET]) [Entertainment Tax Payable],
		SUM([SeatsSold CGST]) - SUM([PriorSaleSeat CGST]) [CGST],
		SUM([SeatsSold SGST]) - SUM([PriorSaleSeat SGST]) [SGST],
		SUM([SeatsSold SC]) - SUM([PriorSaleSeat SC]) [Service Charge],
		SUM([SeatsSold AT]) - SUM([PriorSaleSeat AT]) [Additional Tax],
		SUM([SeatsSold FDF]) - SUM([PriorSaleSeat FDF]) [Film Development Fund],
		SUM([SeatsSold FC]) - SUM([PriorSaleSeat FC]) [Flood Cess],
		SUM([SeatsSold Net]) - SUM([PriorSaleSeat Net]) [Net Revenue],
		SUM([SeatsSold OTC]) - SUM([PriorSaleSeat OTC]) [Other Theatre Charges]
	INTO #FinalSales
	FROM
		#Sales
	
	SELECT
		'BoxOffice Tax for this period' [Details],
		[Number of Sold Seats],
		[Gross Revenue],
		[Entertainment Tax Payable],
		CGST,
		SGST,
		[Service Charge],
		[Additional Tax],
		[Film Development Fund],
		[Flood Cess],
		[Net Revenue],
		[Other Theatre Charges]
	FROM
		#FinalSales
		
	DROP TABLE #ShowMaster
	DROP TABLE #Sales
	
	SELECT * INTO #AdvanceShowMaster FROM 
	(
		SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @endDate, 106) AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
		UNION ALL
		SELECT ShowID FROM ShowMIS WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) > CONVERT(DATETIME, @endDate, 106) AND ScreenID = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId)
	) AdvanceShowMaster
	
	SELECT * INTO #AdvanceSeatMaster FROM
	(
		SELECT SeatID, PriceCardId, PaymentType, LastSoldOn FROM Seat WHERE StatusType IN (2,3) AND SeatID IN (SELECT SeatID FROM BookHistory WHERE ShowID IN (SELECT ShowID FROM #AdvanceShowMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) <= CONVERT(DATETIME, @endDate, 106))
		UNION ALL
		SELECT SeatID, PriceCardId, PaymentType, LastSoldOn FROM SeatMIS WHERE StatusType IN (2,3) AND SeatID IN (SELECT SeatID FROM BookHistory WHERE ShowID IN (SELECT ShowID FROM #AdvanceShowMaster) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), BookedOn, 106)) <= CONVERT(DATETIME, @endDate, 106))
	) AdvanceSeatMaster
	
	SELECT
		SUM(AdvanceSales.FreeSeat) [FreeSeat],
		SUM(AdvanceSales.AdvanceSaleSeat) [AdvanceSaleSeat],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.TA [AdvanceSaleSeat Gross],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.ET [AdvanceSaleSeat ET],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.CGST [AdvanceSaleSeat CGST],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.SGST [AdvanceSaleSeat SGST],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.SC [AdvanceSaleSeat SC],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.AT [AdvanceSaleSeat AT],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.FDF [AdvanceSaleSeat FDF],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.FC [AdvanceSaleSeat FC],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.BTA [AdvanceSaleSeat Net],
		SUM(AdvanceSales.AdvanceSaleSeat) * AdvanceSales.OTC [AdvanceSaleSeat OTC]
	INTO #AdvanceSales
	FROM
	(
	SELECT
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Maintenance_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge'), 0) AS AT,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_CGST_6_Per'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'User_Service_Charge_SGST_6_Per'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Other_Theatre_Charges'), 0) AS OTC,
		(SELECT COUNT(S1.SeatId) FROM #AdvanceSeatMaster S1 WHERE S1.SeatId = S.SeatId AND S1.PaymentType = 5) AS FreeSeat,
		(SELECT COUNT(S1.SeatId) FROM #AdvanceSeatMaster S1 WHERE S1.SeatId = S.SeatId AND S1.PaymentType <> 5) AS AdvanceSaleSeat
	FROM
		#AdvanceSeatMaster S
	GROUP BY
		S.SeatId, S.PriceCardId
	) AdvanceSales
	GROUP BY ET, CGST, SGST, SC, AT, TA, OTC, FreeSeat, AdvanceSaleSeat, FDF, FC, BTA
	
	SELECT
		'Advance Sales' [Details],
		SUM([AdvanceSaleSeat]) [Number of Sold Seats],
		SUM([AdvanceSaleSeat Gross]) [Gross Revenue],
		SUM([AdvanceSaleSeat ET]) [Entertainment Tax Payable],
		SUM([AdvanceSaleSeat CGST]) CGST,
		SUM([AdvanceSaleSeat SGST]) SGST,
		SUM([AdvanceSaleSeat SC]) [Service Charge],
		SUM([AdvanceSaleSeat AT]) [Additional Tax],
		SUM([AdvanceSaleSeat FDF]) [Film Development Fund],
		SUM([AdvanceSaleSeat FC]) [Flood Cess],
		SUM([AdvanceSaleSeat Net]) [Net Revenue],
		SUM([AdvanceSaleSeat OTC]) [Other Theatre Charges]
	FROM
		#AdvanceSales
	
	SELECT
		'Free Seats' [Details],
		SUM([FreeSeat]) [Number of Sold Seats],
		0 [Gross Revenue],
		0 [Entertainment Tax Payable],
		0 CGST,
		0 SGST,
		0 [Service Charge],
		0 [Additional Tax],
		0 [Film Development Fund],
		0 [Flood Cess],
		0 [Net Revenue],
		0 [Other Theatre Charges]
	FROM
		#AdvanceSales
		
	SELECT
		'Total BoxOffice Receipts' [Details],
		SUM([Number of Sold Seats]) [Number of Sold Seats],
		SUM([Gross Revenue]) [Gross Revenue],
		SUM([Entertainment Tax Payable]) [Entertainment Tax Payable],
		SUM(CGST) CGST,
		SUM(SGST) SGST,
		SUM([Service Charge]) [Service Charge],
		SUM([Additional Tax]) [Additional Tax],
		SUM([Film Development Fund]) [Film Development Fund],
		SUM([Flood Cess]) [Flood Cess],
		SUM([Net Revenue]) [Net Revenue],
		SUM([Other Theatre Charges]) [Other Theatre Charges]
	FROM	
	(
		SELECT
			[Number of Sold Seats],
			[Gross Revenue],
			[Entertainment Tax Payable],
			CGST,
			SGST,
			[Service Charge],
			[Additional Tax],
			[Film Development Fund],
			[Flood Cess],
			[Net Revenue],
			[Other Theatre Charges]
		FROM
			#FinalSales
		
		UNION ALL
		
		SELECT
			SUM([AdvanceSaleSeat]) [Number of Sold Seats],
			SUM([AdvanceSaleSeat Gross]) [Gross Revenue],
			SUM([AdvanceSaleSeat ET]) [Entertainment Tax Payable],
			SUM([AdvanceSaleSeat CGST]) CGST,
			SUM([AdvanceSaleSeat SGST]) SGST,
			SUM([AdvanceSaleSeat SC]) [Service Charge],
			SUM([AdvanceSaleSeat AT]) [Additional Tax],
			SUM([AdvanceSaleSeat FDF]) [Film Development Fund],
			SUM([AdvanceSaleSeat FC]) [Flood Cess],
			SUM([AdvanceSaleSeat Net]) [Net Revenue],
			SUM([AdvanceSaleSeat OTC]) [Other Theatre Charges]
		FROM
			#AdvanceSales
			
		UNION ALL
		
		SELECT
			SUM([FreeSeat]) [Number of Sold Seats],
			0 [Gross Revenue],
			0 [Entertainment Tax Payable],
			0 CGST,
			0 SGST,
			0 [Service Charge],
			0 [Additional Tax],
			0 [Film Development Fund],
			0 [Flood Cess],
			0 [Net Revenue],
			0 [Other Theatre Charges]
		FROM
			#AdvanceSales
		)A
	
	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster))
	UNION ALL
	SELECT Code FROM PriceCardItems WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster) AND Code = 'Other_Theatre_Charges')
	DROP TABLE #SeatMaster
	DROP TABLE #AdvanceSeatMaster
	DROP TABLE #AdvanceShowMaster
	DROP TABLE #AdvanceSales
END
GO

/* [GetCancelledShowDetails] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetCancelledShowDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].GetCancelledShowDetails
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [GetCancelledShowDetails] 1, 0, '15 Jul 2022', '19 Jul 2022', 1
CREATE PROCEDURE [dbo].GetCancelledShowDetails
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11),
	@showDetails BIT
AS
BEGIN
IF @showDetails = 1
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, S.IsAdvanceToken, S.IsRealTime, S.CancelRemarks, S.ShowCancelledOn, S.ShowCancelledByID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 1
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, S.IsAdvanceToken, S.IsRealTime, S.CancelRemarks, S.ShowCancelledOn, S.ShowCancelledByID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 1
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType, ClassID, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType, ClassID, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT
	Sh.ShowID,
	Sh.ShowTime,
	Sh.MovieName,
	Sh.ScreenName,
	Sh.ClassName,
	(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') AS [Ticket Type],
	(CASE WHEN IsRealTime = 1 THEN 'Real Time' ELSE 'Quota Type' END) SessionType,
	Sh.ShowCancelledByID,
	Sh.ShowCancelledOn,
	Sh.CancelRemarks,
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS [Ticket Amount],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS [ThreeD Charges],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession'), 0) - 
	--ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Concession_Discount'), 0) AS [FAndB Charges],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Other_Theatre_Charges'), 0) AS [Other Theatre Charges],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [Cash],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS [ThreeDCash],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession'), 0) - 
	--ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS [FAndBCash],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS [OtherTheatreCash],
	CASE WHEN StatusType IN (2,3) THEN COUNT(SeatId) ELSE 0 END AS SeatsSold--,
	--(SELECT COUNT(Bl.SeatId) FROM BlockHistory Bl WHERE Bl.SeatID = S.SeatID AND Bl.ShowID = Sh.ShowID AND Bl.BlockCode <> '' AND Bl.BlockedById <> 0) AS POSPhoneBlock,
	--(SELECT COUNT(Bo.SeatId) FROM BookHistory Bo WHERE Bo.SeatID = S.SeatID AND Bo.ShowId = Sh.ShowId AND Bo.BlockCode <> '' AND Bo.BlockCode IN (SELECT BlockCode FROM BlockHistory Bl WHERE Bl.BlockCode <> '') AND Bo.BookedByID <> 0) AS POSPhoneBook,
	--(SELECT COUNT(C.SeatId) FROM CancelHistory C WHERE C.SeatID = S.SeatID AND C.BookedOn IN (SELECT BookedOn FROM BookHistory Bo WHERE Bo.ShowId = Sh.ShowId AND Bo.BlockCode IN (SELECT BlockCode FROM BlockHistory Bl WHERE Bl.BlockCode <> '' AND BlockedById <> 0)) AND C.ShowId = Sh.ShowID AND C.CancelledByID <> 0) AS POSPhoneCancel,
	--(SELECT COUNT(U.SeatId) FROM UnpaidBookings U WHERE U.SeatID = S.SeatID AND U.ShowId = Sh.ShowId) AS UnpaidBookings,
	--(SELECT COUNT(Bo.SeatId) FROM BookHistory Bo WHERE Bo.SeatID = S.SeatID AND Bo.ShowId = Sh.ShowId AND Bo.BOBookingCode IN (SELECT BookingCode FROM UnpaidBookings U WHERE U.ShowId = Sh.ShowId) AND Bo.BookedByID <> 0) AS UnpaidBookingsPaymentReceived,
	--(SELECT COUNT(C.SeatId) FROM CancelHistory C WHERE C.SeatID = S.SeatID AND C.BookedOn IN (SELECT BookedOn FROM BookHistory Bo WHERE Bo.ShowId = Sh.ShowId AND Bo.BOBookingCode IN (SELECT BookingCode FROM UnpaidBookings U WHERE U.ShowId = Sh.ShowId)) AND C.ShowId = Sh.ShowID AND C.CancelledByID <> 0) AS UnpaidBookingsCancel
	INTO #CancelledShows
	FROM
	#ShowMasterByDate Sh INNER JOIN #SeatMasterByDate S ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY 
	Sh.ShowID,
	Sh.ShowTime,
	Sh.MovieName,
	Sh.ScreenName,
	Sh.ClassName,
	Sh.ShowCancelledByID,
	Sh.ShowCancelledOn,
	Sh.CancelRemarks,
	S.PriceCardId,
	S.ClassID,
	Sh.ClassID,
	S.PaymentType,
	Sh.IsRealTime,
	S.StatusType,
	S.SeatID
	
	IF EXISTS(SELECT TOP 1 ShowID FROM #CancelledShows)
	BEGIN
		SELECT 
			COUNT(DISTINCT ShowID) [Total No. of Shows Cancelled],
			SUM(SeatsSold) [Total No. of Seats Sold],
			/*SUM(POSPhoneBlock) [No. of POS Phone Blockings],
			SUM(POSPhoneBook) [No. of POS Phone Bookings],
			SUM(POSPhoneCancel) [No. of POS Phone Bookings Cancelled],
			SUM(UnpaidBookings) [No. of Unpaid Bookings],
			SUM(UnpaidBookingsPaymentReceived) [No. of Unpaid Bookings Payment Received],
			SUM(UnpaidBookingsCancel) [No. of Unpaid Bookings Cancelled],*/
			SUM(SeatsSold * Cash) AS [Cash Refunded],
			SUM(SeatsSold * ThreeDCash) AS [3D Glass Cash Refunded],
			--SUM(SeatsSold * FAndBCash) AS [Food and Beverage Cash Refunded],
			SUM(SeatsSold * [OtherTheatreCash]) AS [Other Theatre Charges Refunded],
			--SUM(SeatsSold * Cash) + SUM(SeatsSold * ThreeDCash) + SUM(SeatsSold * FAndBCash) + SUM(SeatsSold * [OtherTheatreCash]) AS [Total Cash Refunded]
			SUM(SeatsSold * Cash) + SUM(SeatsSold * ThreeDCash) + SUM(SeatsSold * [OtherTheatreCash]) AS [Total Cash Refunded]
		FROM #CancelledShows
	
		SELECT		
			SUBSTRING(CONVERT(VARCHAR(11), [ShowTime] , 101), 1, 10) [Show Date],
			SUBSTRING(CAST([ShowTime] AS VARCHAR), 12, 20) [Show Time],
			MovieName [Movie Name], 
			ScreenName [Screen Name], 
			SessionType [Session Type],
			CONVERT(VARCHAR(20), ShowCancelledOn) [Cancelled On],
			(SELECT UserName FROM BoxOfficeUser WHERE UserID = ShowCancelledByID) [Cancelled By],
			CancelRemarks [Reason for cancellation],
			SUM(SeatsSold) [Total No. of Seats Sold],
			/*SUM(POSPhoneBlock) [No. of POS Phone Blockings],
			SUM(POSPhoneBook) [No. of POS Phone Bookings],
			SUM(POSPhoneCancel) [No. of POS Phone Bookings Cancelled],
			SUM(UnpaidBookings) [No. of Unpaid Bookings],
			SUM(UnpaidBookingsPaymentReceived) [No. of Unpaid Bookings Payment Received],
			SUM(UnpaidBookingsCancel) [No. of Unpaid Bookings Cancelled],*/
			SUM(SeatsSold * Cash) AS [Cash Refunded],
			SUM(SeatsSold * ThreeDCash) AS [3D Glass Cash Refunded],
			--SUM(SeatsSold * FAndBCash) AS [Food and Beverage Cash Refunded],
			SUM(SeatsSold * [OtherTheatreCash]) AS [Other Theatre Charges Refunded],
			--SUM(SeatsSold * Cash) + SUM(SeatsSold * ThreeDCash) + SUM(SeatsSold * FAndBCash) + SUM(SeatsSold * [OtherTheatreCash]) AS [Total Cash Refunded]
			SUM(SeatsSold * Cash) + SUM(SeatsSold * ThreeDCash) + SUM(SeatsSold * [OtherTheatreCash]) AS [Total Cash Refunded]
		 FROM #CancelledShows
		 GROUP BY ShowTime, MovieName, ScreenName, SessionType, ShowCancelledOn, ShowCancelledByID, CancelRemarks
		 
		 SELECT		
			SUBSTRING(CONVERT(VARCHAR(11), [ShowTime] , 101), 1, 10) [Show Date],
			SUBSTRING(CAST([ShowTime] AS VARCHAR), 12, 20) [Show Time], 
			MovieName [Movie Name], 
			ScreenName [Screen Name], 
			ClassName [Class Name],
			[Ticket Type],
			[Ticket Amount],
			[ThreeD Charges] [3D Glass Charges],
			--[FAndB Charges] [Food and Beverage Charges],
			[Other Theatre Charges],
			SUM(SeatsSold) [Total No. of Seats Sold],
			/*SUM(POSPhoneBlock) [No. of POS Phone Blockings],
			SUM(POSPhoneBook) [No. of POS Phone Bookings],
			SUM(POSPhoneCancel) [No. of POS Phone Bookings Cancelled],
			SUM(UnpaidBookings) [No. of Unpaid Bookings],
			SUM(UnpaidBookingsPaymentReceived) [No. of Unpaid Bookings Payment Received],
			SUM(UnpaidBookingsCancel) [No. of Unpaid Bookings Cancelled],*/
			SUM(SeatsSold * Cash) AS [Cash Refunded],
			SUM(SeatsSold * ThreeDCash) AS [3D Glass Cash Refunded],
			--SUM(SeatsSold * FAndBCash) AS [Food and Beverage Cash Refunded],
			SUM(SeatsSold * [OtherTheatreCash]) AS [Other Theatre Charges Refunded],
			--SUM(SeatsSold * Cash) + SUM(SeatsSold * ThreeDCash) + SUM(SeatsSold * FAndBCash) + SUM(SeatsSold * [OtherTheatreCash]) AS [Total Cash Refunded]
			SUM(SeatsSold * Cash) + SUM(SeatsSold * ThreeDCash) + SUM(SeatsSold * [OtherTheatreCash]) AS [Total Cash Refunded]
		 FROM #CancelledShows
		 GROUP BY ShowTime, MovieName, ScreenName, ClassName, [Ticket Amount], [ThreeD Charges], [Ticket Type], [Other Theatre Charges]
		 --GROUP BY ShowTime, MovieName, ScreenName, ClassName, [Ticket Amount], [ThreeD Charges], [FAndB Charges], [Ticket Type], [Other Theatre Charges]

		 SELECT Code FROM PriceCardItems WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMasterByDate) AND Code = 'Other_Theatre_Charges')
	END
	
	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate
	DROP TABLE #CancelledShows
END
ELSE
BEGIN
	SELECT SUBSTRING(CONVERT(VARCHAR(11), S.ShowTime , 101), 1, 10) [Show Date], SUBSTRING(CAST(S.ShowTime AS VARCHAR), 12, 20) [Show Time],  S.ScreenName [Screen Name],
	S.ShowName [Show Name], S.MovieName [Movie Name], S.CancelRemarks [Reason], SUBSTRING(CONVERT(VARCHAR(11), S.ShowCancelledOn , 101), 1, 10) [Cancel Date], 
	SUBSTRING(CAST(S.ShowCancelledOn AS VARCHAR), 12, 20) [Cancel Time] FROM Show S 
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND 
	CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND 
	S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) 
	AND S.IsCancel = 1
	UNION ALL
	SELECT SUBSTRING(CONVERT(VARCHAR(11), S.ShowTime , 101), 1, 10) [Show Date], SUBSTRING(CAST(S.ShowTime AS VARCHAR), 12, 20) [Show Time],  S.ScreenName [Screen Name],
	S.ShowName [Show Name], S.MovieName [Movie Name], S.CancelRemarks [Reason], SUBSTRING(CONVERT(VARCHAR(11), S.ShowCancelledOn , 101), 1, 10) [Cancel Date], 
	SUBSTRING(CAST(S.ShowCancelledOn AS VARCHAR), 12, 20) [Cancel Time] FROM ShowMIS S 
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND 
	CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) AND 
	S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) 
	AND S.IsCancel = 1
	 
END
END
GO
/* ReleaseSeatsByQuota */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReleaseSeatsByQuota]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].ReleaseSeatsByQuota
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--ReleaseSeatsByQuota
CREATE PROCEDURE [dbo].ReleaseSeatsByQuota
AS
BEGIN
	--To release POS Phone blocked seats
	UPDATE Seat SET QuotaType=0, StatusType=0, TicketID = 0, PatronInfo='', LastBlockedByID = 0 WHERE Quotatype !=3 AND StatusType=1 AND NoBlocks > NoCancels AND NoBlocks > 0 AND LastBlockedByID > 0 AND GETDATE()>DATEADD(mi,-ReleaseBefore,(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release Tele-Booking Quota to counter seats
	UPDATE Seat SET QuotaType=0, PatronInfo='' WHERE quotaType = 2 AND StatusType=0 AND GETDATE()>DATEADD(mi,-ReleaseBefore,(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release Manager quota to counter quota based on Manager Quota Release Time
	UPDATE Seat SET QuotaType=0, PatronInfo='' WHERE quotaType = 1 AND StatusType=0 AND GETDATE()>DATEADD(mi,-(SELECT ManagerQuotaReleaseTime FROM Show WHERE ShowID=Seat.ShowID),(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
	--To release online advance token blocked seats to counter seats based on Advance Token Buffer Time
	UPDATE Seat SET StatusType=0, TicketID = 0, QuotaType=0, PatronInfo='' WHERE ShowID IN (SELECT ShowID FROM Show WHERE IsAdvanceToken = 1 AND IsHandoff = 0) AND Quotatype = 3 AND StatusType=1 AND GETDATE()>DATEADD(mi,-(SELECT AdvanceTokenBufferTime FROM Show WHERE ShowID=Seat.ShowID AND IsHandoff = 0),(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID AND IsHandoff = 0))
	--To release online unbooked seats
	UPDATE Seat SET QuotaType=0, NoBlocks=0 WHERE ShowId IN (SELECT ShowId FROM Show WHERE IsOnlineSaleClosed = 1 AND IsHandoff = 0) AND QuotaType=3 AND StatusType=0;
	--To release Unpaid Bookings to counter available seats based on Unpaid Booking Release Time
	UPDATE Seat SET QuotaType=0, StatusType=0, TicketID = 0, PatronInfo='', LastSoldOn = NULL, LastSoldByID = 0 WHERE StatusType=6 AND GETDATE()>DATEADD(mi,-(SELECT UnpaidBookingReleaseTime FROM Show WHERE ShowID=Seat.ShowID),(SELECT ShowTime FROM Show WHERE ShowID=Seat.ShowID))
END
GO

/* ChangeManagerQuota */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].ChangeManagerQuota') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].ChangeManagerQuota
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--ChangeManagerQuota 529, '425843,425844,425883,425884', 2108
CREATE PROCEDURE [dbo].ChangeManagerQuota
	@ShowID INT,
	@SeatIDs VARCHAR(8000),
	@ClassID INT
AS
BEGIN
	IF (SELECT DATEADD(mi, -ManagerQuotaReleaseTime, ShowTime) FROM Show WHERE ShowID = @ShowID) < GETDATE()
		BEGIN
			RAISERROR('Change Manager quota request cannot be processed. Crossed Manager quota release time.', 11, 1)
			RETURN
		END
	ELSE
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION 
					CREATE TABLE #UserSelectedIds (SeatID BIGINT)
					CREATE TABLE #UserSelectedCoupleIds (CoupleId BIGINT)
					
					CREATE TABLE #UserSelectedManagerIds (SeatID BIGINT)
					CREATE TABLE #UserSelectedManagerCoupleIds (CoupleId BIGINT)

					INSERT INTO #UserSelectedIds
					SELECT SeatID FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@SeatIDs, ',')) AND SeatType <> 1 AND QuotaType = 0 AND StatusType = 0 AND SeatID NOT IN (SELECT SeatID FROM ChangeQuotaDetails WHERE Status = 0 AND ShowID = @ShowID)

					CREATE TABLE #Couple (SlNo INT IDENTITY(1,1), CId INT, ShowId INT)
					INSERT INTO #Couple(CId, ShowId) SELECT SeatID, ShowId FROM Seat WHERE SeatID IN (SELECT SeatID FROM #UserSelectedIds) AND SeatType = 2
					
					INSERT INTO #UserSelectedManagerIds
					SELECT SeatID FROM Seat WHERE SeatID IN (SELECT items FROM dbo.fnsplit(@SeatIDs, ',')) AND SeatType <> 1 AND QuotaType = 1 AND StatusType = 0

					CREATE TABLE #CoupleManager (SlNo INT IDENTITY(1,1), CId INT, ShowId INT)
					INSERT INTO #CoupleManager(CId, ShowId) SELECT SeatID, ShowId FROM Seat WHERE SeatID IN (SELECT SeatID FROM #UserSelectedManagerIds) AND SeatType = 2

					DECLARE @i INT
					SET @i = 1
					DECLARE @maxi INT
					SET @maxi = (SELECT COUNT(*) FROM #couple)
					WHILE (@maxi >= @i)
					BEGIN
						DECLARE @CoupleSeatIds NVARCHAR(50)
						SET @CoupleSeatIds = NULL		
						SELECT @CoupleSeatIds = CoupleSeatIds FROM Seat WHERE SeatID IN (SELECT CId FROM #Couple WHERE #Couple.SlNo = @i)
					
						INSERT INTO #UserSelectedCoupleIds
						SELECT SeatId FROM Seat WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@CoupleSeatIds, ',')) AND ShowID IN (SELECT ShowId FROM #Couple WHERE #Couple.SlNo = @i)
						SET @i = @i + 1
					END
					DROP TABLE #Couple
					
					INSERT INTO #UserSelectedIds SELECT CoupleId FROM #UserSelectedCoupleIds
					
					DROP TABLE #UserSelectedCoupleIds
					
					UPDATE Seat SET QuotaType = 1 WHERE SeatID IN (SELECT SeatID FROM #UserSelectedIds) AND SeatType <> 1 AND QuotaType = 0 AND StatusType = 0
					DROP TABLE #UserSelectedIds
					
					SET @i = 1
					SET @maxi = (SELECT COUNT(*) FROM #CoupleManager)
					WHILE (@maxi >= @i)
					BEGIN
						SET @CoupleSeatIds = NULL		
						SELECT @CoupleSeatIds = CoupleSeatIds FROM Seat WHERE SeatID IN (SELECT CId FROM #CoupleManager WHERE #CoupleManager.SlNo = @i)
					
						INSERT INTO #UserSelectedManagerCoupleIds
						SELECT SeatId FROM Seat WHERE SeatLayoutID IN (SELECT items FROM dbo.fnsplit(@CoupleSeatIds, ',')) AND ShowID IN (SELECT ShowId FROM #CoupleManager WHERE #CoupleManager.SlNo = @i)
						SET @i = @i + 1
					END
					DROP TABLE #CoupleManager
					
					INSERT INTO #UserSelectedManagerIds SELECT CoupleId FROM #UserSelectedManagerCoupleIds
					
					DROP TABLE #UserSelectedManagerCoupleIds
					
					UPDATE Seat SET QuotaType = 0 WHERE SeatID IN (SELECT SeatID FROM #UserSelectedManagerIds) AND SeatType <> 1 AND QuotaType = 1 AND StatusType = 0
					DROP TABLE #UserSelectedManagerIds
				COMMIT
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
				ROLLBACK
			END CATCH
		END
END
GO


/* [DeletePriceCard] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeletePriceCard]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].DeletePriceCard
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].DeletePriceCard
	@PriceCardID INT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT PriceCardID FROM ClassPriceCards WHERE PriceCardID = @PriceCardID)
			IF NOT EXISTS (SELECT PriceCardId FROM Seat WHERE PriceCardId = @PriceCardID)
				IF NOT EXISTS (SELECT PriceCardId FROM SeatMIS WHERE PriceCardId = @PriceCardID)
				BEGIN
					DELETE FROM PriceCardClassLayoutCollections WHERE PriceCardId = @PriceCardID
					UPDATE ClassLayout SET PriceCardId = 0 WHERE PriceCardId = @PriceCardID
					DELETE FROM PriceCardItemDetails WHERE PriceCardId = @PriceCardID
					DELETE FROM PriceCardDetails WHERE PriceCardId = @PriceCardID
					DELETE FROM PriceCard WHERE Id = @PriceCardID
				END
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
GO

/* [AddVendor] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddVendor]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddVendor]
	@userID INT,
	@vendorCompanyName NVARCHAR(256),
    @address NVARCHAR(256),
    @location NVARCHAR(256),
	@pincode NVARCHAR(20),
    @state NVARCHAR(50),
    @country NVARCHAR(50),
    @telephoneNumber NVARCHAR(20),
    @contactDetails NVARCHAR(MAX),
	@vendorID INT OUTPUT
AS
BEGIN

	IF EXISTS (SELECT VendorID FROM Vendors WHERE VendorCompanyName = @vendorCompanyName)
	BEGIN
		RAISERROR('Duplicate Vendor Company Name', 11, 1)
		RETURN
	END
	
	INSERT INTO Vendors(
	VendorCompanyName, [Address], Location, Pincode, [State], Country, TelephoneNumber, ContactDetails, CreatedBy, CreatedOn) VALUES(
	@vendorCompanyName, @address, @location, @pincode, @state, @country, @telephoneNumber, @contactDetails, @userID, GETDATE());
	SET @VendorID = @@IDENTITY
END

GO

/* UpdateVendorByID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateVendorByID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateVendorByID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].UpdateVendorByID
(
	@userID INT,
	@vendorID INT,
	@vendorCompanyName NVARCHAR(256),
    @address NVARCHAR(256),
    @location NVARCHAR(256),
	@pincode NVARCHAR(20),
    @state NVARCHAR(50),
    @country NVARCHAR(50),
    @telephoneNumber NVARCHAR(20),
    @contactDetails NVARCHAR(MAX)
)
AS
	IF NOT EXISTS (SELECT VendorID FROM Vendors WHERE VendorCompanyName = @VendorCompanyName AND VendorID <> @VendorID)
		UPDATE Vendors SET VendorCompanyName = @vendorCompanyName, [Address] = @address, Location = @location, Pincode = @pincode, [State] = @state, Country = @country, TelephoneNumber = @telephoneNumber, ContactDetails = @contactDetails, LastModifiedBy = @UserID, LastModifiedOn = GETDATE() WHERE VendorID = @VendorId

GO

/* DeleteVendorByID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteVendorByID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].DeleteVendorByID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].DeleteVendorByID
(
	@vendorID INT,
	@referredBy NVARCHAR(256) OUTPUT
)
AS
BEGIN
	SET @referredBy = ''

	IF EXISTS(SELECT VendorID from ItemStock WHERE VendorID = @vendorID)
	BEGIN
		SET @referredBy = 'Vendor exists in Purchase/Return Stock!'
		RETURN
	END
	
	IF EXISTS(SELECT VendorID from IngredientVendorCollections WHERE VendorID = @vendorID)
	BEGIN
		SET @referredBy = 'Vendor details are mapped in Ingredients'
		RETURN
	END

	If @referredBy = ''
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM Vendors WHERE VendorID = @vendorID
			DELETE FROM IngredientVendorCollections WHERE VendorID = @vendorID
		COMMIT
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0
		   ROLLBACK
	END CATCH
END
GO

/* List Vendors */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListVendors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ListVendors]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [ListVendors] '', 0, 0
CREATE PROCEDURE [dbo].[ListVendors]
	@createdOn VARCHAR(10),
	@createdBy INT
AS
BEGIN
	IF @createdOn != '' AND @createdBy != 0
		SELECT V.VendorID, V.VendorCompanyName, U.UserName, V.CreatedOn, V.Location, V.[State] FROM Vendors V INNER JOIN BoxOfficeUser U ON U.UserId = V.CreatedBy WHERE 
		CONVERT(VARCHAR(10), V.CreatedOn, 110) = @createdOn
		AND CreatedBy = @createdBy ORDER BY CreatedOn DESC
	ELSE IF  @createdOn != ''
		SELECT V.VendorID, V.VendorCompanyName, U.UserName, V.CreatedOn, V.Location, V.[State] FROM Vendors V INNER JOIN BoxOfficeUser U ON U.UserId = V.CreatedBy WHERE 
		CONVERT(VARCHAR(10), V.CreatedOn, 110) = @createdOn ORDER BY CreatedOn DESC
	ELSE IF @createdBy != 0
		SELECT V.VendorID, V.VendorCompanyName, U.UserName, V.CreatedOn, V.Location, V.[State] FROM Vendors V INNER JOIN BoxOfficeUser U ON U.UserId = V.CreatedBy WHERE
		V.CreatedBy = @createdBy ORDER BY CreatedOn DESC
	ELSE
		SELECT V.VendorID, V.VendorCompanyName, U.UserName, V.CreatedOn, V.Location, V.[State] FROM Vendors V INNER JOIN BoxOfficeUser U ON U.UserId = V.CreatedBy ORDER BY CreatedOn DESC
END
GO

/* [ListIngredients] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListIngredients]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ListIngredients]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [ListIngredients] '', 1
CREATE PROCEDURE [dbo].[ListIngredients]
	@createdOn VARCHAR(10),
	@createdBy INT
AS
BEGIN
	IF @createdOn != '' AND @createdBy != 0
	BEGIN
		SELECT
			IngredientId, IngredientName, (SELECT Expression FROM [Type] WHERE Value = PriceType AND TypeName = 'PriceType') AS PriceType,
			Cost, (SELECT Expression FROM [Type] WHERE Value = UnitOfMeasure AND TypeName = 'UnitOfMeasureType') AS UnitOfMeasure,
			(SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy,	CreatedOn
		FROM
			Ingredients
		WHERE
			CONVERT(VARCHAR(10), CreatedOn, 110) = @createdOn
			AND  CreatedBy = @createdBy
		ORDER BY IngredientName
	END
	ELSE IF  @createdOn != ''
	BEGIN
		SELECT
			IngredientId, IngredientName, (SELECT Expression FROM [Type] WHERE Value = PriceType AND TypeName = 'PriceType') AS PriceType,
			Cost, (SELECT Expression FROM [Type] WHERE Value = UnitOfMeasure AND TypeName = 'UnitOfMeasureType') AS UnitOfMeasure,
			(SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy,	CreatedOn
		FROM
			Ingredients
		WHERE
			CONVERT(VARCHAR(10), CreatedOn, 110) = @createdOn
		ORDER BY IngredientName
	END
	ELSE IF @createdBy != 0
	BEGIN
		SELECT
			IngredientId, IngredientName, (SELECT Expression FROM [Type] WHERE Value = PriceType AND TypeName = 'PriceType') AS PriceType,
			Cost, (SELECT Expression FROM [Type] WHERE Value = UnitOfMeasure AND TypeName = 'UnitOfMeasureType') AS UnitOfMeasure,
			(SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy,	CreatedOn
		FROM
			Ingredients
		WHERE
			CreatedBy = @createdBy
		ORDER BY IngredientName
	END
	ELSE
	BEGIN
		SELECT
			IngredientId, IngredientName, (SELECT Expression FROM [Type] WHERE Value = PriceType AND TypeName = 'PriceType') AS PriceType,
			Cost, (SELECT Expression FROM [Type] WHERE Value = UnitOfMeasure AND TypeName = 'UnitOfMeasureType') AS UnitOfMeasure,
			(SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy,	CreatedOn
		FROM
			Ingredients
		ORDER BY IngredientName
	END
END
GO

/* [AddIngredient] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddIngredient]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddIngredient]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [AddIngredient] @ingredientID=1, @ingredientName='Chilli', @priceType=0, @cost=100, @unitOfMeasure=5, @createdBy=1, @ingredientVendorIds=''
CREATE PROCEDURE [dbo].[AddIngredient]
	@ingredientID INT OUTPUT,
	@ingredientName VARCHAR(50),
	@priceType INT,
	@cost NUMERIC(9,2),
	@unitOfMeasure INT,
	@createdBy INT,
	@ingredientVendorIds VARCHAR(1000)
AS
BEGIN
	DECLARE @errorMessage VARCHAR(400)
	BEGIN TRY
		BEGIN TRANSACTION  
			IF EXISTS(SELECT IngredientID FROM Ingredients WHERE IngredientName = @ingredientName)
			BEGIN
				SET @errorMessage = 'Ingredient(' + @ingredientName + ') is already Exist.'
				GOTO ERR_HANDLER
			END
			
			INSERT INTO Ingredients (IngredientName, PriceType, Cost, UnitOfMeasure, CreatedBy, CreatedOn)
				VALUES (@ingredientName, @priceType, @cost, @unitOfMeasure, @createdBy, GETDATE())
			
			SET @ingredientID = @@IDENTITY
			
			INSERT INTO IngredientVendorCollections (IngredientID, VendorID) SELECT @ingredientID, items FROM dbo.FnSplit(@ingredientVendorIds, ',')
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
	END CATCH
	RETURN  
	ERR_HANDLER:  
	ROLLBACK TRANSACTION
	RAISERROR(@errorMessage, 11, 1)
	RETURN
END
GO

/* [UpdateIngredientByID] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateIngredientByID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateIngredientByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [UpdateIngredientByID] 1, 'Onion', 0, 100, 5, 1, ''
CREATE PROCEDURE [dbo].[UpdateIngredientByID]
	@ingredientID INT,
	@ingredientName VARCHAR(50),
	@priceType INT,
	@cost NUMERIC(9,2),
	@unitOfMeasure INT,
	@modifiedBy INT,
	@ingredientVendorIds VARCHAR(1000)
AS
BEGIN
	DECLARE @errorMessage VARCHAR(400)
	BEGIN TRY
		BEGIN TRANSACTION  
			UPDATE
				Ingredients
			SET
				IngredientName = @ingredientName,
				PriceType = @priceType,
				Cost = @cost,
				UnitOfMeasure = @unitOfMeasure,
				LastModifiedBy = @modifiedBy,
				LastModifiedOn = GETDATE()
			WHERE
				IngredientID = @ingredientID
			
			DELETE FROM IngredientVendorCollections WHERE IngredientID = @ingredientID
			INSERT INTO IngredientVendorCollections (IngredientID, VendorID) SELECT @ingredientID, items FROM dbo.FnSplit(@ingredientVendorIds, ',')
			
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
	END CATCH
	RETURN  
	ERR_HANDLER:  
	ROLLBACK TRANSACTION
	RAISERROR(@errorMessage, 11, 1)
	RETURN
END
GO

/* [LoadIngredientByID] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadIngredientByID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadIngredientByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [LoadIngredientByID] 1
CREATE PROCEDURE [dbo].[LoadIngredientByID]
	@ingredientID INT
AS
BEGIN
	SELECT IngredientID, IngredientName, PriceType, Cost, UnitOfMeasure FROM Ingredients WHERE IngredientID = @ingredientID
END
GO

/* [DeleteIngredientByID] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteIngredientByID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeleteIngredientByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [DeleteIngredientByID] 1, ''
CREATE PROCEDURE [dbo].[DeleteIngredientByID]
	@ingredientID INT,
	@referredBy VARCHAR(50) OUTPUT
AS
BEGIN
	SET @referredBy = ''
	
	IF EXISTS(SELECT IngredientID from IngredientVendorCollections WHERE IngredientID = @ingredientID)
	BEGIN
		SET @referredBy = 'Ingredient is mapped in Vendor'
		RETURN
	END
	
	IF EXISTS(SELECT IngredientID from ItemIngredientCollections WHERE IngredientID = @ingredientID)
	BEGIN
		SET @referredBy = 'Ingredient is mapped in Item'
		RETURN
	END

	If @referredBy = ''
	BEGIN	
		DELETE FROM Ingredients WHERE IngredientID = @ingredientID
	END
END
GO

/* AddItem */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].AddItem
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].AddItem
	@userID INT,
	@itemClassID INT,
	@itemName VARCHAR(250),
	@price NUMERIC(9,2),
	@priceType NUMERIC(9,2),
	@SGSTPercent NUMERIC(9,2),
	@SGST NUMERIC(9,2),
	@CGSTPercent NUMERIC(9,2),
	@CGST NUMERIC(9,2),
	@compCessPercent NUMERIC(9,2),
	@compCess NUMERIC(9,2),
	@additionalTaxPercent NUMERIC(9,2),
	@additionalTax NUMERIC(9,2),
	@netAmount NUMERIC(9,2),
	@unitOfMeasure INT,
	@isOnline VARCHAR(4),
	@isActive VARCHAR(2),
	@comboItems VARCHAR(MAX),
	@itemIngredientIDs VARCHAR(1000),
	@HSNCode INT,
	@itemID INT OUTPUT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION 
			DECLARE @itemPriceID INT
			SELECT @itemPriceID = ItemPriceID FROM ItemPrice WHERE Price = @price AND [PriceType] = @priceType AND [SGSTPercent] = @SGSTPercent AND [SGST] = @SGST AND [CGSTPercent] = @CGSTPercent AND [CGST] = @CGST AND [CompensationCessPercent] = @compCessPercent AND [CompensationCess] = @compCess AND [AdditionalTaxPercent] = @additionalTaxPercent AND [AdditionalTax] = @additionalTax AND [NetAmount] = @netAmount
			
			IF @itemPriceID IS NULL OR @itemPriceID = 0
			BEGIN
				INSERT INTO ItemPrice (
					[Price],
					[PriceType],
					[IsServiceTax],
					[ServiceTaxPercent],
					[ServiceTax],
					[IsSwachhBharatCess],
					[SwachhBharatPercent],
					[SwachhBharatCess],
					[AdditionalTaxPercent],
					[AdditionalTax],
					[VATPercent],
					[VAT],
					[NetAmount],
					[SGSTPercent],
					[SGST],
					[CGSTPercent],
					[CGST],
					[CompensationCessPercent],
					[CompensationCess]
				)
				VALUES (
					@price,
					@priceType,
					0,
					0,
					0,
					0,
					0,
					0,
					@additionalTaxPercent,
					@additionalTax,
					0,
					0,
					@netAmount,
					@SGSTPercent,
					@SGST,
					@CGSTPercent,
					@CGST,
					@compCessPercent,
					@compCess		
				)
				SET @itemPriceID = SCOPE_IDENTITY();
			END
			
			INSERT INTO Items (
				ItemClassID,
				ItemName,
				HSNCode,
				ItemPriceID,
				UnitOfMeasure,
				IsOnline,
				IsActive,
				ComboItems,
				CreatedBy,
				CreatedOn
			) VALUES (
				@itemClassID,
				@itemName,
				@HSNCode,
				@itemPriceID,
				@unitOfMeasure,
				@isOnline,
				@isActive,
				@comboItems,
				@userID,
				GETDATE()
			); SET @itemID = SCOPE_IDENTITY();

			IF (@comboItems != '')
			BEGIN
				CREATE TABLE #TempQuantity
				(
					Quantity INT NOT NULL
				)
				DECLARE @tmpComItems VARCHAR(MAX)
				DECLARE curComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
				OPEN curComboItems
				FETCH NEXT FROM curComboItems INTO @tmpComItems
				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @tmpComItemID INT
					DECLARE @tmpComQuantity INT
					IF(CHARINDEX('-',@tmpComItems) > 0)
					BEGIN
						SELECT TOP(1) @tmpComItemID = value FROM DBO.SPLIT('-',@tmpComItems)
						SELECT TOP(1) @tmpComQuantity = value FROM DBO.SPLIT('-',@tmpComItems) ORDER BY ROWID DESC
						
						INSERT INTO #TempQuantity
						SELECT StockOnHand/@tmpComQuantity FROM Items WHERE ItemID = @tmpComItemID
					END
					FETCH NEXT FROM curComboItems INTO @TmpComItems
				END
				CLOSE curComboItems
				DEALLOCATE curComboItems
				
				UPDATE Items SET StockOnHand = (SELECT TOP(1) Quantity FROM #TempQuantity ORDER BY Quantity) WHERE ItemID = @itemID
				DROP TABLE #TempQuantity
			END
			
			DELETE FROM ItemIngredientCollections WHERE itemID = @itemID
			INSERT INTO ItemIngredientCollections (ItemID, IngredientID) SELECT @itemID, items FROM dbo.FnSplit(@itemIngredientIDs, ',')

		COMMIT
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0
		   ROLLBACK
	END CATCH
END
GO

/* EditItemByID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EditItemByID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EditItemByID]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EditItemByID]
	@userID INT,
	@itemID INT,
	@itemClassID INT,
	@itemName VARCHAR(250),
	@price NUMERIC(9,2),
	@priceType NUMERIC(9,2),
	@SGSTPercent NUMERIC(9,2),
	@SGST NUMERIC(9,2),
	@CGSTPercent NUMERIC(9,2),
	@CGST NUMERIC(9,2),
	@compCessPercent NUMERIC(9,2),
	@compCess NUMERIC(9,2),
	@additionalTaxPercent NUMERIC(9,2),
	@additionalTax NUMERIC(9,2),
	@netAmount NUMERIC(9,2),
	@unitOfMeasure INT,
	@isOnline VARCHAR(4),
	@isActive VARCHAR(2),
	@comboItems VARCHAR(MAX),
	@itemIngredientIDs VARCHAR(1000),
	@HSNCode INT,
	@packagedTicketsName NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @oldItemPriceID INT
			SELECT @oldItemPriceID = ItemPriceID FROM Items WHERE ItemID = @itemID
			
			DECLARE @itemPriceID INT
			SELECT @itemPriceID = ItemPriceID FROM ItemPrice WHERE Price = @price AND [PriceType] = @priceType AND [SGSTPercent] = @SGSTPercent AND [SGST] = @SGST AND [CGSTPercent] = @CGSTPercent AND [CGST] = @CGST AND [CompensationCessPercent] = @compCessPercent AND [CompensationCess] = @compCess AND [AdditionalTaxPercent] = @additionalTaxPercent AND [AdditionalTax] = @additionalTax AND [NetAmount] = @netAmount
			
			IF @itemPriceID IS NULL OR @itemPriceID = 0
			BEGIN
				INSERT INTO ItemPrice (
					[Price],
					[PriceType],
					[IsServiceTax],
					[ServiceTaxPercent],
					[ServiceTax],
					[IsSwachhBharatCess],
					[SwachhBharatPercent],
					[SwachhBharatCess],
					[AdditionalTaxPercent],
					[AdditionalTax],
					[VATPercent],
					[VAT],
					[NetAmount],
					[SGSTPercent],
					[SGST],
					[CGSTPercent],
					[CGST],
					[CompensationCessPercent],
					[CompensationCess]
				)
				VALUES (
					@price,
					@priceType,
					0,
					0,
					0,
					0,
					0,
					0,
					@additionalTaxPercent,
					@additionalTax,
					0,
					0,
					@netAmount,
					@SGSTPercent,
					@SGST,
					@CGSTPercent,
					@CGST,
					@compCessPercent,
					@compCess		
				)
				SET @itemPriceID = SCOPE_IDENTITY();
			END
			
			IF @oldItemPriceID <> @itemPriceID
			BEGIN
				DECLARE @priceCardID INT
				DECLARE tempPriceCard CURSOR FOR  SELECT ID FROM PriceCard WHERE IsDeleted = 0 AND ID IN (SELECT PriceCardID FROM PriceCardItemDetails WHERE ItemID = @itemID AND ItemPriceID = @oldItemPriceID)
				OPEN tempPriceCard
				FETCH NEXT FROM tempPriceCard INTO @priceCardID
				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @newPriceCardID INT
					
					IF @packagedTicketsName <> '' 
						SET @packagedTicketsName = @packagedTicketsName + ', '

					SELECT @packagedTicketsName = @packagedTicketsName + ' ' + Name FROM PriceCard WHERE Id = @priceCardID

					INSERT INTO PriceCard(Name, Amount, CreatedBy, CreatedOn, TicketType)
					SELECT PC.Name, (SELECT SUM(PCD.Price) FROM PriceCardDetails PCD WHERE PCD.PriceCardID = @priceCardID AND PCD.Code IN ('Ticket_Amount', '3D_Glasses')) - (SELECT ISNULL(SUM(PCD.Price), 0) FROM PriceCardDetails PCD WHERE PCD.PriceCardID = @priceCardID AND PCD.Code IN ('Ticket_Amount_Discount', '3D_Glasses_Discount')), @userID, GETDATE(), PC.TicketType FROM PriceCard PC WHERE PC.ID = @priceCardID
					SET @newPriceCardID = SCOPE_IDENTITY()
					
					INSERT INTO PriceCardDetails(Code, Name, Price, Type, ValueByCalculationType, CalculationType, PriceCardId)
					SELECT Code, Name, Price, Type, ValueByCalculationType, CalculationType, @newPriceCardID FROM PriceCardDetails WHERE PriceCardId = @priceCardID AND Code NOT IN ('Concession', 'Concession_Discount')
					
					UPDATE PriceCard SET IsDeleted = 1 WHERE ID = @priceCardID
					
					SELECT DISTINCT Sh.ShowID INTO #Show FROM Show Sh WHERE Sh.ShowTime > GETDATE() AND Sh.IsHandOff = 0 
					AND (Sh.ShowID IN (SELECT CPC.ShowID FROM ClassPriceCards CPC WHERE CPC.ShowID = Sh.ShowID AND CPC.PriceCardID = @priceCardID) OR 
					Sh.ShowID IN (SELECT S.ShowID FROM Seat S WHERE S.ShowID = Sh.ShowID AND S.PriceCardID = @priceCardID))
					
					UPDATE Class SET PriceCardId = @newPriceCardID WHERE ShowID IN (SELECT ShowID FROM #Show) AND PriceCardId = @priceCardID
					UPDATE Seat SET PriceCardId = @newPriceCardID WHERE StatusType = 0 AND ShowID IN (SELECT ShowID FROM #Show) AND PriceCardId = @priceCardID
					UPDATE PriceCardClassLayoutCollections SET PriceCardID = @newPriceCardID WHERE PriceCardID = @priceCardID
					UPDATE ClassPriceCards SET PriceCardId = @newPriceCardID WHERE ShowID IN (SELECT ShowID FROM #Show) AND PriceCardId = @priceCardID

					UPDATE Show SET IsOnlineEdit = 0 WHERE ShowID IN (SELECT ShowID FROM #Show) AND OnlineShowId != ''
					INSERT INTO ShowSyncJobs(ShowId, OnlineShowId)
					SELECT DISTINCT ShowId, OnlineShowId FROM Show WHERE ShowID IN (SELECT ShowID FROM #Show) AND OnlineShowId != ''
					
					DROP TABLE #Show
					FETCH NEXT FROM tempPriceCard INTO @priceCardID
				END
				CLOSE tempPriceCard
				DEALLOCATE tempPriceCard
			END
			
			UPDATE Items
			SET ItemClassID = @itemClassID,
				ItemName = @itemName,
				HSNCode = @HSNCode,
				ItemPriceID = @itemPriceID,
				UnitOfMeasure = @unitOfMeasure,
				IsOnline = @isOnline,
				IsActive = @isActive,
				ComboItems = @comboItems,
				LastModifiedBy = @userID,
				LastModifiedOn = GETDATE()
			WHERE ItemID = @ItemID

			IF (@comboItems != '')
			BEGIN
				CREATE TABLE #TempQuantity
				(
					Quantity INT NOT NULL
				)
				DECLARE @tmpComItems VARCHAR(MAX)
				DECLARE curComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
				OPEN curComboItems
				FETCH NEXT FROM curComboItems INTO @tmpComItems
				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @tmpComItemID INT
					DECLARE @tmpComQuantity INT
					IF(CHARINDEX('-',@tmpComItems) > 0)
					BEGIN
						SELECT TOP(1) @tmpComItemID = value FROM DBO.SPLIT('-',@tmpComItems)
						SELECT TOP(1) @tmpComQuantity = value FROM DBO.SPLIT('-',@tmpComItems) ORDER BY ROWID DESC
						
						INSERT INTO #TempQuantity
						SELECT StockOnHand/@tmpComQuantity FROM Items WHERE ItemID = @tmpComItemID
					END
					FETCH NEXT FROM curComboItems INTO @TmpComItems
				END
				CLOSE curComboItems
				DEALLOCATE curComboItems
				
				UPDATE Items SET StockOnHand = (SELECT TOP(1) Quantity FROM #TempQuantity ORDER BY Quantity) WHERE ItemID = @itemID
				DROP TABLE #TempQuantity
			END
			
			DELETE FROM ItemIngredientCollections WHERE itemID = @itemID
			INSERT INTO ItemIngredientCollections (ItemID, IngredientID) SELECT @itemID, items FROM dbo.FnSplit(@itemIngredientIDs, ',')
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		DECLARE @errMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR (@errMsg, 11, 1)
	END CATCH
END	
GO

/* DeleteItemByID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteItemByID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].DeleteItemByID
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].DeleteItemByID
	@itemID INT,
	@referredBy VARCHAR(500) OUTPUT
AS
BEGIN
	SET @referredBy = ''
	
	BEGIN
		CREATE TABLE #comboItems
			(
				SlNo INT IDENTITY(1,1) NOT NULL,
				ComboItemID INT,
				ComboItems VARCHAR(128),
				ComboName VARCHAR(256)
			)
		INSERT INTO #comboItems
		SELECT ItemID, ComboItems, ItemName FROM Items WHERE ComboItems != ''
				
		DECLARE @i INT = 1
		DECLARE @maxi INT = (SELECT MAX(SlNo) FROM #comboItems)
		WHILE @maxi >= @i
		BEGIN
			DECLARE @comboItems VARCHAR(128)
			DECLARE @comboName VARCHAR(256)
					
			SELECT @comboItems = ComboItems, @comboName = ComboName FROM #comboItems WHERE SlNo = @i
		
			DECLARE @tempComboItems VARCHAR(MAX)
			DECLARE currentComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
			OPEN currentComboItems
			FETCH NEXT FROM currentComboItems INTO @tempComboItems
			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @tempComboItemID INT
				DECLARE @tempComboQuantity INT
				IF(CHARINDEX('-',@tempComboItems) > 0)
				BEGIN
					SELECT TOP(1) @tempComboItemID = value FROM DBO.SPLIT('-',@tempComboItems)
					IF @tempComboItemID = @itemID
					BEGIN
						SET @referredBy = 'Item details are mapped in Item Packages! Package Name: ' + @comboName
						BREAK
					END
				END
				FETCH NEXT FROM currentComboItems INTO @tempComboItems
			END
			CLOSE currentComboItems
			DEALLOCATE currentComboItems

			SET @i = @i + 1
		END
		DROP TABLE #comboItems
	END
	
	IF @referredBy <> ''
		RETURN
	
	IF EXISTS(SELECT ItemID from ItemStock WHERE ItemID = @itemID)
	BEGIN
		SET @referredBy = 'Item exists in Purchase/Return Stock!'
		RETURN
	END
	
	IF EXISTS(SELECT ItemID from ItemIngredientCollections WHERE ItemID = @itemID)
	BEGIN
		SET @referredBy = 'Item details are mapped in Ingredients'
		RETURN
	END

	IF EXISTS(SELECT ItemID from ItemSalesHistory WHERE ItemID = @itemID)
	BEGIN
		SET @referredBy = 'Item details are mapped in Sales'
		RETURN
	END
	
	IF EXISTS(SELECT ItemID from PriceCardItemDetails WHERE ItemID = @itemID)
	BEGIN
		SET @referredBy = 'Item details are mapped in Packaged Tickets'
		RETURN
	END

	If @referredBy = ''
	BEGIN
	BEGIN TRY
		BEGIN TRANSACTION 
			DELETE FROM Items WHERE ItemID = @itemID
			DELETE FROM ItemIngredientCollections WHERE ItemID = @itemID
		COMMIT
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0
		   ROLLBACK
	END CATCH
	END
END
GO


/* [ListItems] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListItems]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ListItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [ListItems] '', 1
CREATE PROCEDURE [dbo].[ListItems]
	@createdOn VARCHAR(10),
	@createdBy INT
AS
BEGIN
	IF @createdOn != '' AND @createdBy != 0
	BEGIN
		SELECT
			ItemID,	ItemName, (SELECT Expression FROM [Type] WHERE Value = ItemClassID AND TypeName = 'ItemClass') AS Class,
			(SELECT Price FROM ItemPrice IP WHERE IP.ItemPriceID = I.ItemPriceID) AS Price, IsActive, IsOnline, ISNULL(Shortcut, '') Shortcut,
			StockOnHand, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) > CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) UnclaimedStock, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) TodayUnclaimedStock, (SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy, CreatedOn
		FROM
			Items I
		WHERE
			CONVERT(VARCHAR(10), CreatedOn, 110) = @createdOn
		AND  CreatedBy = @createdBy
		ORDER BY ItemName
	END
	ELSE IF  @createdOn != ''
	BEGIN
		SELECT
			ItemID,	ItemName, (SELECT Expression FROM [Type] WHERE Value = ItemClassID AND TypeName = 'ItemClass') AS Class,
			(SELECT Price FROM ItemPrice IP WHERE IP.ItemPriceID = I.ItemPriceID) AS Price, IsActive, IsOnline, ISNULL(Shortcut, '') Shortcut,
			StockOnHand, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) > CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) UnclaimedStock, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) TodayUnclaimedStock, (SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy, CreatedOn
		FROM
			Items I
		WHERE
			CONVERT(VARCHAR(10), CreatedOn, 110) = @createdOn
		ORDER BY ItemName
	END
	ELSE IF @createdBy != 0
	BEGIN
		SELECT
			ItemID,	ItemName, (SELECT Expression FROM [Type] WHERE Value = ItemClassID AND TypeName = 'ItemClass') AS Class,
			(SELECT Price FROM ItemPrice IP WHERE IP.ItemPriceID = I.ItemPriceID) AS Price, IsActive, IsOnline, ISNULL(Shortcut, '') Shortcut,
			StockOnHand, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) > CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) UnclaimedStock, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) TodayUnclaimedStock, (SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy, CreatedOn
		FROM
			Items I
		WHERE
			CreatedBy = @createdBy
		ORDER BY ItemName
	END
	ELSE
	BEGIN
		SELECT
			ItemID,	ItemName, (SELECT Expression FROM [Type] WHERE Value = ItemClassID AND TypeName = 'ItemClass') AS Class,
			(SELECT Price FROM ItemPrice IP WHERE IP.ItemPriceID = I.ItemPriceID) AS Price, IsActive, IsOnline, ISNULL(Shortcut, '') Shortcut,
			StockOnHand, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) > CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) UnclaimedStock, (SELECT ISNULL(SUM(ISH.Quantity), 0) FROM ItemSalesHistory ISH WHERE I.ItemID = ISH.ItemID AND ISH.TransactionID NOT IN (SELECT ICH.TransactionID FROM ItemCancelHistory ICH) AND ISH.SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), ShowTime, 110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110)))) AND IsBlocked = 1) TodayUnclaimedStock, (SELECT UserName FROM BoxOfficeUser WHERE UserID = CreatedBy) AS CreatedBy, CreatedOn
		FROM
			Items I
		ORDER BY ItemName
	END
END
GO

/* [UpdateTaxes] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateTaxes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateTaxes]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--UpdateTaxes '10.00', '10.00', 12
CREATE PROCEDURE [dbo].[UpdateTaxes]
	@serviceTax NUMERIC(9,2),
	@swachhBharatCess NUMERIC(9,2),
	@userID INT,
	@packagedTicketsName NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION 
			SET @packagedTicketsName = ''
			DECLARE @oldServiceTax NUMERIC(9,2)
			DECLARE @oldSwachhBharatCess NUMERIC(9,2)
			SELECT @oldServiceTax = ServiceTax, @oldSwachhBharatCess = SwachhBharatCess FROM Taxes
			
			/* Enter default taxes if not exists */
			IF NOT EXISTS(SELECT ServiceTax FROM Taxes)
				INSERT INTO Taxes(ServiceTax, SwachhBharatCess, LastModifiedBy, LastModifiedOn) SELECT '0.00', '0.00', (SELECT UserID FROM BoxOfficeUser WHERE Username = 'YSAdmin'), GETDATE()
				INSERT INTO Taxes(ServiceTax, SwachhBharatCess, LastModifiedBy, LastModifiedOn) SELECT '0.00', '0.00', (SELECT UserID FROM BoxOfficeUser WHERE Username = 'YSBOAdmin'), GETDATE()	
			
			IF (@serviceTax <> @oldServiceTax OR @swachhBharatCess <> @oldSwachhBharatCess)
			BEGIN
				UPDATE Taxes SET ServiceTax = @serviceTax, SwachhBharatCess = @swachhBharatCess, LastModifiedBy = @userID, LastModifiedOn = GETDATE()
			
				CREATE TABLE #TempTax(SlNo INT IDENTITY(1,1), PriceID INT NOT NULL, ItemID INT NOT NULL)
					
				INSERT INTO #TempTax(PriceID, ItemID) SELECT Items.ItemPriceID, Items.ItemID FROM ItemPrice INNER JOIN Items ON Items.ItemPriceID = ItemPrice.ItemPriceID WHERE (IsServiceTax = 1 OR IsSwachhBharatCess = 1)
				
				DECLARE @i INT
				SET @i = 1
				DECLARE @maxi INT
				SET @maxi = (SELECT COUNT(*) FROM #TempTax)
				WHILE (@maxi >= @i)
				BEGIN
					DECLARE @itemPriceID INT = 0
					DECLARE @itemID INT = 0
					DECLARE @itemNewPriceID INT = 0
					
					DECLARE @price NUMERIC(9,2) = 0
					DECLARE @serviceTaxRupees NUMERIC(9,2) = 0
					DECLARE @swachhBharatCessRupees NUMERIC(9,2) = 0
					DECLARE @netAmount NUMERIC(9,2) = 0
					DECLARE @additionalTax NUMERIC(9,2) = 0
					DECLARE @VAT NUMERIC(9,2) = 0
					DECLARE @isServiceTax BIT = 0
					DECLARE @isSwachhBharatCess BIT = 0
					DECLARE @priceType INT = 0
					DECLARE @additionalTaxPercent NUMERIC(9,2) = 0
					DECLARE @VATPercent NUMERIC(9,2) = 0				
					
					SELECT @itemPriceID = PriceID, @itemID = ItemID FROM #TempTax WHERE #TempTax.SlNo = @i
					
					SELECT @netAmount = NetAmount, @serviceTaxRupees = ServiceTax, @swachhBharatCessRupees = SwachhBharatCess, @isServiceTax = IsServiceTax, @priceType = [PriceType], @isSwachhBharatCess = IsSwachhBharatCess, @additionalTax = AdditionalTax, @additionalTaxPercent = AdditionalTaxPercent, @VATPercent = VATPercent, @VAT = VAT FROM ItemPrice WHERE ItemPriceID = @itemPriceID
					
					IF (@isServiceTax = 1 AND @serviceTax <> @oldServiceTax)
					BEGIN
						SET @serviceTaxRupees = ISNULL(ROUND(((@serviceTax * @netAmount) / 100), 2), 0)
						SET @price = @netAmount + @additionalTax + @VAT + @serviceTaxRupees + @swachhBharatCessRupees
					END
					
					IF (@isSwachhBharatCess = 1 AND @swachhBharatCess <> @oldSwachhBharatCess)
					BEGIN
						SET @swachhBharatCessRupees = ISNULL(ROUND(((@swachhBharatCess * @netAmount) / 100), 2), 0)
						SET @price = @netAmount + @additionalTax + @VAT + @serviceTaxRupees + @swachhBharatCessRupees
					END
					
					IF @price <> 0
					BEGIN
						SELECT @itemNewPriceID = ItemPriceID FROM ItemPrice WHERE Price = @price AND [PriceType] = @priceType AND IsServiceTax = @isServiceTax AND [ServiceTaxPercent] = @serviceTax AND [ServiceTax] =  @serviceTaxRupees AND IsSwachhBharatCess = @isSwachhBharatCess AND [SwachhBharatPercent] = @swachhBharatCess AND [SwachhBharatCess] = @swachhBharatCessRupees AND [AdditionalTaxPercent] = @additionalTaxPercent AND [AdditionalTax] = @additionalTax AND [VATPercent] = @VATPercent AND [VAT] = @VAT AND [NetAmount] = @netAmount
						
						IF @itemNewPriceID IS NULL OR @itemNewPriceID = 0
						BEGIN						
							INSERT INTO ItemPrice (
								[Price],
								[PriceType],
								[IsServiceTax],
								[ServiceTaxPercent],
								[ServiceTax],
								[IsSwachhBharatCess],
								[SwachhBharatPercent],
								[SwachhBharatCess],
								[AdditionalTaxPercent],
								[AdditionalTax],
								[VATPercent],
								[VAT],
								[NetAmount]
							)
							SELECT
								@price,
								[PriceType],
								[IsServiceTax],
								@serviceTax,
								@serviceTaxRupees,
								[IsSwachhBharatCess],
								@swachhBharatCess,
								@swachhBharatCessRupees,
								[AdditionalTaxPercent],
								[AdditionalTax],
								[VATPercent],
								[VAT],
								[NetAmount]
							FROM ItemPrice WHERE ItemPriceID = @itemPriceID
							SET @itemNewPriceID = SCOPE_IDENTITY();
						END
						
						IF @itemNewPriceID <> @itemPriceID
						BEGIN
							DECLARE @priceCardID INT = 0
							DECLARE tempPriceCard CURSOR FOR  SELECT ID FROM PriceCard WHERE IsDeleted = 0 AND ID IN (SELECT PriceCardID FROM PriceCardItemDetails WHERE ItemID = @itemID AND ItemPriceID = @itemPriceID)
							OPEN tempPriceCard
							FETCH NEXT FROM tempPriceCard INTO @priceCardID
							WHILE @@FETCH_STATUS = 0
							BEGIN
								DECLARE @newPriceCardID INT
								
								IF @packagedTicketsName <> '' 
									SET @packagedTicketsName = @packagedTicketsName + ', '

								SELECT @packagedTicketsName = @packagedTicketsName + ' ' + Name FROM PriceCard WHERE Id = @priceCardID
								
								INSERT INTO PriceCard(Name, Amount, CreatedBy, CreatedOn, TicketType)
								SELECT PC.Name, (SELECT SUM(PCD.Price) FROM PriceCardDetails PCD WHERE PCD.PriceCardID = @priceCardID AND PCD.Code IN ('Ticket_Amount', '3D_Glasses')) - (SELECT ISNULL(SUM(PCD.Price), 0) FROM PriceCardDetails PCD WHERE PCD.PriceCardID = @priceCardID AND PCD.Code IN ('Ticket_Amount_Discount', '3D_Glasses_Discount')), @userID, GETDATE(), PC.TicketType FROM PriceCard PC WHERE PC.ID = @priceCardID
								SET @newPriceCardID = SCOPE_IDENTITY()
								
								INSERT INTO PriceCardDetails(Code, Name, Price, Type, ValueByCalculationType, CalculationType, PriceCardId)
								SELECT Code, Name, Price, Type, ValueByCalculationType, CalculationType, @newPriceCardID FROM PriceCardDetails WHERE PriceCardId = @priceCardID AND Code NOT IN ('Concession', 'Concession_Discount')
								
								UPDATE PriceCard SET IsDeleted = 1 WHERE ID = @priceCardID
								
								SELECT DISTINCT Sh.ShowID INTO #Show FROM Show Sh WHERE Sh.ShowTime > GETDATE() AND Sh.IsHandOff = 0 
								AND (Sh.ShowID IN (SELECT CPC.ShowID FROM ClassPriceCards CPC WHERE CPC.ShowID = Sh.ShowID AND CPC.PriceCardID = @priceCardID) OR 
								Sh.ShowID IN (SELECT S.ShowID FROM Seat S WHERE S.ShowID = Sh.ShowID AND S.PriceCardID = @priceCardID))
								
								UPDATE Class SET PriceCardId = @newPriceCardID WHERE ShowID IN (SELECT ShowID FROM #Show) AND PriceCardId = @priceCardID
								UPDATE Seat SET PriceCardId = @newPriceCardID WHERE StatusType = 0 AND ShowID IN (SELECT ShowID FROM #Show) AND PriceCardId = @priceCardID
								UPDATE PriceCardClassLayoutCollections SET PriceCardID = @newPriceCardID WHERE PriceCardID = @priceCardID
								UPDATE ClassPriceCards SET PriceCardId = @newPriceCardID WHERE ShowID IN (SELECT ShowID FROM #Show) AND PriceCardId = @priceCardID

								UPDATE Show SET IsOnlineEdit = 0 WHERE ShowID IN (SELECT ShowID FROM #Show) AND OnlineShowId != ''
								INSERT INTO ShowSyncJobs(ShowId, OnlineShowId)
								SELECT DISTINCT ShowId, OnlineShowId FROM Show WHERE ShowID IN (SELECT ShowID FROM #Show) AND OnlineShowId != ''
								
								DROP TABLE #Show

								FETCH NEXT FROM tempPriceCard INTO @priceCardID
							END
							CLOSE tempPriceCard
							DEALLOCATE tempPriceCard
						END
			
						UPDATE Items SET ItemPriceID = @itemNewPriceID WHERE ItemPriceID = @itemPriceID AND ItemID = @itemID
					END							
					SET @i = @i + 1
				END				
				DROP TABLE #TempTax
			END
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		DECLARE @errMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR (@errMsg, 11, 1)
	END CATCH
END
GO

/* LoadItemsByIngredientID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadItemsByIngredientID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadItemsByIngredientID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LoadItemsByIngredientID]
	@ingredientID INT
AS
BEGIN
	SELECT ItemID, ItemName FROM Items WHERE ItemID IN (SELECT ItemID FROM ItemIngredientCollections WHERE IngredientID = @ingredientID)
END
GO

/* LoadVendorsByActionAndIngredientID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadVendorsByActionAndIngredientID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadVendorsByActionAndIngredientID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [LoadVendorsByActionAndIngredientID] 0, ''
CREATE PROCEDURE [dbo].[LoadVendorsByActionAndIngredientID]
	@ingredientID INT,
	@action VARCHAR(20)
AS
BEGIN
	IF (@action = 'SelectedVendor')
		SELECT VendorID, VendorCompanyName + '-' + Location + '-' + State + '-' + Country FROM Vendors WHERE VendorID IN 
		(SELECT VendorID FROM IngredientVendorCollections WHERE IngredientID = @ingredientID)
	ELSE
		SELECT VendorID, VendorCompanyName + '-' + Location + '-' + State + '-' + Country FROM Vendors  WHERE VendorID NOT IN
		(SELECT VendorID FROM IngredientVendorCollections WHERE IngredientID = @ingredientID)
END
GO

/* LoadItemsByVendorID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadItemsByVendorID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].LoadItemsByVendorID
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].LoadItemsByVendorID
	@vendorID INT
AS
BEGIN
	SELECT ItemID, ItemName FROM Items WHERE ItemID IN (SELECT ItemID FROM ItemStock WHERE VendorID = @vendorID)
END
GO

/* LoadIngredientsByVendorID */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadIngredientsByVendorID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].LoadIngredientsByVendorID
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].LoadIngredientsByVendorID
	@vendorID INT
AS
BEGIN
	SELECT IngredientID, IngredientName FROM Ingredients WHERE IngredientID IN (SELECT IngredientID FROM IngredientVendorCollections WHERE VendorID = @vendorID)
END
GO

/* PurchaseOrReturnStock */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PurchaseOrReturnStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PurchaseOrReturnStock]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PurchaseOrReturnStock]
	@userID INT,
	@itemID INT,
	@vendorID INT,
	@quantity INT,
	@cost NUMERIC(9,2),
	@stockType INT,
	@purchaseID INT OUTPUT
AS
BEGIN
	IF @stockType = 1
	BEGIN
		IF EXISTS(SELECT StockOnHand FROM Items WHERE ItemID = @itemID AND StockOnHand < @quantity)
		BEGIN
			RAISERROR('Cannot return stock. Insufficient stock or stock not available to return.', 11, 1)
			RETURN
		END
	END

	BEGIN TRY
		BEGIN TRANSACTION 
			INSERT INTO ItemStock
			(ItemID, VendorID, Quantity, AvailableQuantity, Cost, StockType, CreatedOn, CreatedBy) 
			VALUES 
			(@itemID, @vendorID, @quantity, CASE WHEN @stockType = 0 THEN @quantity ELSE 0 END, CASE WHEN @stockType = 0 THEN @cost ELSE 0 END, @stockType, GETDATE(), @userID)

			SET @purchaseID = SCOPE_IDENTITY();
			UPDATE Items SET StockOnHand = CASE WHEN @stockType = 0 THEN StockOnHand + @quantity ELSE StockOnHand - @quantity END WHERE ItemID = @itemID
			
			IF @stockType = 1
			BEGIN
				DECLARE @reduceTotalQty INT = @quantity
				WHILE @reduceTotalQty <> 0
				BEGIN
					DECLARE @itemStockID INT
					DECLARE @availableQuantity INT

					SELECT TOP 1 @itemStockID = ItemStockID, @availableQuantity = AvailableQuantity FROM ItemStock WHERE AvailableQuantity > 0 AND ItemID = @itemID ORDER BY Cost DESC

					DECLARE @reduceQty INT

					IF @availableQuantity >= @reduceTotalQty
						SET @reduceQty = @reduceTotalQty
					ELSE
						SET @reduceQty = @availableQuantity
					
					UPDATE ItemStock SET AvailableQuantity = AvailableQuantity - @reduceQty WHERE ItemStockID = @itemStockID
					
					SET @reduceTotalQty = @reduceTotalQty - @reduceQty
				END
			END
		COMMIT
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0
		   ROLLBACK
	END CATCH
END
GO

/* [UpdateSetupOrderWindow] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateSetupOrderWindow]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateSetupOrderWindow
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE UpdateSetupOrderWindow(
@itemPosition VARCHAR(MAX)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @val AS VARCHAR(MAX);
			DECLARE @row AS INT;
			DECLARE @cmd AS NVARCHAR(MAX)='';
				
			UPDATE SetupOrder SET ItemID = 0
			UPDATE Items SET Shortcut = NULL
				
			DECLARE parseData CURSOR -- DECLARE CURSOR
				
			LOCAL SCROLL STATIC
			FOR
				SELECT *  FROM DBO.SPLIT(',', @itemPosition)
				OPEN parseData -- OPEN THE CURSOR
					FETCH NEXT FROM parseData INTO @row,@val
						WHILE @@FETCH_STATUS = 0
						BEGIN
							IF (@val <> '')
							BEGIN
								DECLARE @itemID INT = (SELECT VALUE FROM DBO.SPLIT(':', @val) WHERE ROWID = 2)
								
								IF @itemID <> 0
								BEGIN
									DECLARE @setupOrderID INT = (SELECT VALUE FROM DBO.SPLIT(':', @val) WHERE ROWID = 1)
									DECLARE @shortcut VARCHAR(2) = (SELECT CAST(Row AS VARCHAR(MAX)) + CAST([Column] AS VARCHAR(MAX)) FROM SetupOrder WHERE ID = @setupOrderID)
								
									UPDATE SetupOrder SET ItemID = @itemID WHERE ID = @setupOrderID
									UPDATE Items SET Shortcut = @shortcut WHERE ItemID = @itemID
								END
							END	
							FETCH NEXT FROM parseData
							INTO @row,@val
						END
				CLOSE parseData -- CLOSE THE CURSOR
			DEALLOCATE parseData -- DEALLOCATE THE CURSOR
		COMMIT
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
			ROLLBACK
		DECLARE @error NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@error, 11, 1)
	END CATCH
END
GO

/* [ItemSalesAndCancellation] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemSalesAndCancellation]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ItemSalesAndCancellation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec ItemSalesAndCancellation '','5_1,6_2,4_2',1,0,1,1
CREATE PROCEDURE [dbo].[ItemSalesAndCancellation]
	@transactionID VARCHAR(10) OUTPUT,
	@items VARCHAR(512),
	@orderType TINYINT,
	@paymentType TINYINT,
	@userID INT,
	@complexID INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @itemID INT
			DECLARE @itemPriceID INT
			DECLARE @comboItems VARCHAR(MAX)
			DECLARE @quantity INT

			DECLARE @tmpComItems VARCHAR(MAX)
			DECLARE @tmpItemQtyList VARCHAR(MAX)
			DECLARE @tmpItemQty VARCHAR(24)
			DECLARE @tmpItemID INT
			DECLARE @tmpQuantity INT
			DECLARE @commaPosition INT
			DECLARE @underlinePosition INT
			DECLARE @itemStockID INT
			DECLARE @availableQuantity INT
			DECLARE @actualQuantity INT
			DECLARE @dateTime DATETIME
			
			SET @tmpItemQtyList = @items
			SET @dateTime = GETDATE()
			
			IF @orderType = 0
			BEGIN
				DECLARE @isDuplicate BIT = 1
				WHILE (@isDuplicate > 0)
				BEGIN
					SELECT @transactionID = RIGHT(NEWID(), 10)
					IF NOT EXISTS(SELECT TransactionID FROM ItemSalesHistory WHERE TransactionID = @transactionID)
						SET @isDuplicate = 0
				END
			END
			
			IF EXISTS(SELECT TransactionID FROM ItemCancelHistory WHERE TransactionID = @transactionID AND OrderType = 2)
			BEGIN
				ROLLBACK
				RAISERROR('Order is already cancelled!', 11, 1)
				RETURN
			END
			
			WHILE @tmpItemQtyList <> ''
			BEGIN
				SET @commaPosition = CHARINDEX(',', @tmpItemQtyList)
				IF @commaPosition > 0
					SELECT @tmpItemQty = SUBSTRING(@tmpItemQtyList, 1, @commaPosition - 1), @underlinePosition = CHARINDEX('_', @tmpItemQty), @tmpItemID = CAST(SUBSTRING(@tmpItemQty, 1, @underlinePosition - 1) AS INT), @tmpQuantity = CAST(SUBSTRING(@tmpItemQty, @underlinePosition + 1, @commaPosition - 1) AS INT), @tmpItemQtyList = SUBSTRING(@tmpItemQtyList, @commaPosition + 1, LEN(@tmpItemQtyList))
				ELSE
					SELECT @underlinePosition = CHARINDEX('_', @tmpItemQtyList), @tmpItemID = CAST(SUBSTRING(@tmpItemQtyList, 1, @underlinePosition - 1) AS INT), @tmpQuantity = CAST(SUBSTRING(@tmpItemQtyList, @underlinePosition + 1, LEN(@tmpItemQtyList)) AS INT), @tmpItemQtyList = ''

				SELECT
					@itemID = ItemID,
					@itemPriceID = ItemPriceID,
					@comboItems = ComboItems,
					@quantity = StockOnHand
				FROM Items
				WHERE ItemID = @tmpItemID			
			
				IF (@orderType = 1 OR @orderType = 2)
				BEGIN					
					IF (@orderType = 2)
						UPDATE Items SET StockOnHand = StockOnHand + @tmpQuantity WHERE ItemID = @itemID
					
					IF(@comboItems='')
					BEGIN
						SELECT ISH.ItemID, ISH.Quantity AS OrderQuantity, ISH.ItemPriceID,
						(SELECT ISNULL(SUM(Quantity), 0) FROM ItemCancelHistory WHERE ISH.TransactionID = TransactionID AND ISH.ItemID = ItemID AND ItemStockID = ISH.ItemStockID) TotalCancelQuantity,
						ISH.ItemStockID, (SELECT Cost FROM ItemStock WHERE ItemStockID = ISH.ItemStockID) Cost, ROW_NUMBER() OVER (ORDER BY ISH.ItemID) AS RowNumber
						INTO #CancelStock
						FROM ItemSalesHistory ISH WHERE ISH.TransactionID = @transactionID AND ISH.ItemID = @itemID ORDER BY Cost DESC
						
						DECLARE @rowNum INT
						DECLARE cursorStock CURSOR FOR SELECT RowNumber FROM #CancelStock
						OPEN cursorStock
						FETCH NEXT FROM cursorStock INTO @rowNum
						WHILE @@FETCH_STATUS = 0
						BEGIN				
							DECLARE @orderQty INT
							SELECT @orderQty = OrderQuantity - TotalCancelQuantity, @itemPriceID = ItemPriceID, @itemStockID = ItemStockID FROM #CancelStock WHERE RowNumber = @rowNum
							IF @orderQty > 0
							BEGIN
								IF @tmpQuantity <= @orderQty
								BEGIN
									INSERT INTO ItemCancelHistory (TransactionID, ItemID, ItemPriceID, ItemStockID, Quantity, OrderType, CancelledBy, CancelledOn)
									VALUES (@transactionID, @tmpItemID, @itemPriceID, @itemStockID, @tmpQuantity, @orderType, @userID, @dateTime)
									
									IF (@orderType = 2)
										UPDATE ItemStock SET AvailableQuantity = AvailableQuantity + @tmpQuantity WHERE ItemStockID = @itemStockID
									
									BREAK
								END
								ELSE
								BEGIN
									INSERT INTO ItemCancelHistory (TransactionID, ItemID, ItemPriceID, ItemStockID, Quantity, OrderType, CancelledBy, CancelledOn)
									VALUES (@transactionID, @tmpItemID, @itemPriceID, @itemStockID, @orderQty, @orderType, @userID, @dateTime)
									
									IF (@orderType = 2)
										UPDATE ItemStock SET AvailableQuantity = AvailableQuantity + @orderQty WHERE ItemStockID = @itemStockID
									
									SET @tmpQuantity = @tmpQuantity - @orderQty
								END
							END
							FETCH NEXT FROM cursorStock INTO @rowNum
						END
						CLOSE cursorStock
						DEALLOCATE cursorStock
						DROP TABLE #CancelStock
					END
					ELSE
					BEGIN
						INSERT INTO ItemCancelHistory (TransactionID, ItemID, ItemPriceID, ItemStockID, Quantity, OrderType, CancelledBy, CancelledOn)
						VALUES (@transactionID, @tmpItemID, @itemPriceID, 0, @tmpQuantity, @orderType, @userID, @dateTime)
						
						DECLARE cursorComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
						OPEN cursorComboItems
						FETCH NEXT FROM cursorComboItems INTO @tmpComItems
						WHILE @@FETCH_STATUS = 0
						BEGIN				
							DECLARE @tmpComboItemID INT
							DECLARE @tmpComboQuantity INT
							IF(CHARINDEX('-',@tmpComItems) > 0)
							BEGIN
								SELECT TOP(1) @tmpComboItemID = value FROM DBO.SPLIT('-',@tmpComItems)
								SELECT TOP(1) @tmpComboQuantity = value FROM DBO.SPLIT('-',@tmpComItems) ORDER BY ROWID DESC
								
								SELECT IPSH.ItemID, IPSH.Quantity AS OrderQuantity,
								(SELECT ISNULL(SUM(Quantity), 0) FROM ItemPackageSalesHistory WHERE IPSH.TransactionID = TransactionID AND IPSH.ItemID = ItemID AND IPSH.ItemPackageID = ItemPackageID AND ItemStockID = IPSH.ItemStockID AND IPSH.OrderType IN (1,2)) TotalCancelQuantity,
								IPSH.ItemStockID, (SELECT Cost FROM ItemStock WHERE ItemStockID = IPSH.ItemStockID) Cost, ROW_NUMBER() OVER (ORDER BY IPSH.ItemID) AS RowNumber
								INTO #ItemPackageCancelStock
								FROM ItemPackageSalesHistory IPSH WHERE IPSH.TransactionID = @transactionID AND IPSH.ItemID = @tmpComboItemID AND IPSH.ItemPackageID = @itemID ORDER BY Cost DESC
								
								DECLARE @rowNum1 INT
								DECLARE @totalTmpQuantity INT = @tmpQuantity * @tmpComboQuantity
								DECLARE cursorStock CURSOR FOR SELECT RowNumber FROM #ItemPackageCancelStock
								OPEN cursorStock
								FETCH NEXT FROM cursorStock INTO @rowNum1
								WHILE @@FETCH_STATUS = 0
								BEGIN				
									DECLARE @orderQty1 INT
									SELECT @orderQty1 = OrderQuantity - TotalCancelQuantity, @itemStockID = ItemStockID FROM #ItemPackageCancelStock WHERE RowNumber = @rowNum1
									IF @orderQty1 > 0
									BEGIN
										IF @totalTmpQuantity <= @orderQty1
										BEGIN
											INSERT INTO ItemPackageSalesHistory (TransactionID, ItemPackageID, ItemID, Quantity, OrderType, ItemStockID)
											VALUES (@transactionID, @itemID, @tmpComboItemID, @totalTmpQuantity, @orderType, @itemStockID)
											
											IF (@orderType = 2)
											BEGIN
												UPDATE ItemStock SET AvailableQuantity = AvailableQuantity + @totalTmpQuantity WHERE ItemStockID = @itemStockID
												UPDATE Items SET StockOnHand = StockOnHand + @totalTmpQuantity WHERE ItemID = @tmpComboItemID
											END
											
											BREAK
										END
										ELSE
										BEGIN
											INSERT INTO ItemPackageSalesHistory (TransactionID, ItemPackageID, ItemID, Quantity, OrderType, ItemStockID)
											VALUES (@transactionID, @itemID, @tmpComboItemID, @orderQty1, @orderType, @itemStockID)
											
											IF (@orderType = 2)
											BEGIN
												UPDATE ItemStock SET AvailableQuantity = AvailableQuantity + @orderQty1 WHERE ItemStockID = @itemStockID
												UPDATE Items SET StockOnHand = StockOnHand + @orderQty1 WHERE ItemID = @tmpComboItemID
											END
											
											SET @totalTmpQuantity = @totalTmpQuantity - @orderQty1
										END
									END
									FETCH NEXT FROM cursorStock INTO @rowNum1
								END
								CLOSE cursorStock
								DEALLOCATE cursorStock								
								DROP TABLE #ItemPackageCancelStock
							END			
							FETCH NEXT FROM cursorComboItems INTO @tmpComItems
						END
						CLOSE cursorComboItems
						DEALLOCATE cursorComboItems
					END
				END
				
				IF (@orderType = 3)
				BEGIN
					IF(@comboItems='')
					BEGIN
						IF (@quantity < @tmpQuantity)
						BEGIN
							ROLLBACK
							RAISERROR('Stock is Insufficient!', 11, 1)
							RETURN
						END

						SELECT SeatID INTO #Temp FROM ItemSalesHistory WHERE TransactionID = @transactionID AND ItemID = @itemID

						IF EXISTS (SELECT TOP 1 SeatID FROM #Temp WHERE SeatID IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE IsCancel = 1)))
						BEGIN
							ROLLBACK
							RAISERROR('Show Cancelled!', 11, 1)
							RETURN
						END

						IF EXISTS (SELECT TOP 1 SeatID FROM #Temp WHERE SeatID IN (SELECT SeatID FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM ShowMIS WHERE IsCancel = 1)))
						BEGIN
							ROLLBACK
							RAISERROR('Show Cancelled!', 11, 1)
							RETURN
						END
						
						IF EXISTS (SELECT SeatID FROM ItemSalesHistory WHERE TransactionID = @transactionID AND ItemID = @itemID AND IsBlocked = 0)
						BEGIN
							ROLLBACK
							RAISERROR('This Transaction is already printed!', 11, 1)
							RETURN
						END

						SET @availableQuantity = 0					
						WHILE (@availableQuantity < @tmpQuantity)
						BEGIN
							SELECT TOP (1) @availableQuantity = ST.AvailableQuantity, @itemStockID = ST.ItemStockID
							FROM ItemStock ST, Items I
							WHERE ST.AvailableQuantity > 0 AND ST.StockType = 0 AND I.ItemID = ST.ItemID
							AND I.ItemID = @tmpItemID
							ORDER BY ST.Cost
							
							IF @availableQuantity >= @tmpQuantity
								SET @actualQuantity = @tmpQuantity
							ELSE
							BEGIN
								SET @actualQuantity = @availableQuantity
								SET @tmpQuantity = @tmpQuantity - @availableQuantity
								SET @availableQuantity = 0
							END
							
							DECLARE @count INT = 0
							DECLARE @seatID INT
							
							WHILE @actualQuantity > @count
							BEGIN
								SELECT TOP 1 @seatID = SeatID FROM #Temp
								UPDATE ItemSalesHistory SET ItemStockID = @itemStockID, IsBlocked = 0, @count = @count + Quantity WHERE TransactionID = @transactionID AND ItemID = @itemID AND SeatID = @seatID
								DELETE FROM #Temp WHERE SeatID = @seatID
							END
							
							UPDATE Items SET StockOnHand = StockOnHand - @actualQuantity, BlockedStock = BlockedStock - @actualQuantity WHERE ItemID = @itemID
							
							UPDATE ItemStock SET AvailableQuantity = AvailableQuantity - @actualQuantity WHERE ItemStockID = @itemStockID
						END
						
						DROP Table #Temp
					END
					ELSE
					BEGIN		
						UPDATE ItemSalesHistory SET IsBlocked = 0 WHERE TransactionID = @transactionID AND ItemID = @itemID
						
						UPDATE Items SET StockOnHand = StockOnHand - @tmpQuantity, BlockedStock = BlockedStock - @tmpQuantity WHERE ItemID = @itemID
						
						DECLARE curComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
						OPEN curComboItems
						FETCH NEXT FROM curComboItems INTO @tmpComItems
						WHILE @@FETCH_STATUS = 0
						BEGIN				
							DECLARE @tmpPackageItemID INT
							DECLARE @tmpPackageQuantity INT
							IF(CHARINDEX('-',@tmpComItems) > 0)
							BEGIN
								SELECT TOP(1) @tmpPackageItemID = value FROM DBO.SPLIT('-',@tmpComItems)
								SELECT TOP(1) @tmpPackageQuantity = value FROM DBO.SPLIT('-',@tmpComItems) ORDER BY ROWID DESC
								
								SELECT @quantity = StockOnHand FROM Items WHERE ItemID = @tmpPackageItemID
								
								IF (@quantity < (@tmpQuantity*@tmpPackageQuantity))
								BEGIN
									ROLLBACK
									RAISERROR('Stock is Insufficient!', 11, 1)
									RETURN
								END
								
								DECLARE @totalTmpPackageQuantity INT = (@tmpQuantity*@tmpPackageQuantity)
								
								SET @availableQuantity = 0
								WHILE (@availableQuantity < @totalTmpPackageQuantity)
								BEGIN
									SELECT TOP (1) @availableQuantity = ST.AvailableQuantity, @itemStockID = ST.ItemStockID
									FROM ItemStock ST, Items I
									WHERE ST.AvailableQuantity > 0 AND ST.StockType = 0 AND I.ItemID = ST.ItemID
									AND I.ItemID = @tmpPackageItemID
									ORDER BY ST.Cost
																
									IF @availableQuantity >= @totalTmpPackageQuantity
										SET @actualQuantity = @totalTmpPackageQuantity
									ELSE
									BEGIN
										SET @actualQuantity = @availableQuantity
										SET @totalTmpPackageQuantity = @totalTmpPackageQuantity - @availableQuantity
										SET @availableQuantity = 0
									END
									
									INSERT INTO ItemPackageSalesHistory (TransactionID, ItemPackageID, ItemID, Quantity, OrderType, ItemStockID)
									VALUES (@transactionID, @itemID, @tmpPackageItemID, @actualQuantity, @orderType, @itemStockID)
									
									UPDATE Items SET StockOnHand = StockOnHand - @actualQuantity WHERE ItemID = @tmpPackageItemID
									
									UPDATE ItemStock SET AvailableQuantity = AvailableQuantity - @actualQuantity WHERE ItemStockID = @itemStockID
								END
							END			
							FETCH NEXT FROM curComboItems INTO @tmpComItems
						END
						CLOSE curComboItems
						DEALLOCATE curComboItems
					END
				END
				
				IF (@orderType = 0)
				BEGIN
					IF(@comboItems='')
					BEGIN
						IF (@quantity < @tmpQuantity)
						BEGIN
							ROLLBACK
							RAISERROR('Stock is Insufficient!', 11, 1)
							RETURN
						END
						
						SET @availableQuantity = 0					
						WHILE (@availableQuantity < @tmpQuantity)
						BEGIN
							SELECT TOP (1) @availableQuantity = ST.AvailableQuantity, @itemStockID = ST.ItemStockID
							FROM ItemStock ST, Items I
							WHERE ST.AvailableQuantity > 0 AND ST.StockType = 0 AND I.ItemID = ST.ItemID
							AND I.ItemID = @tmpItemID
							ORDER BY ST.Cost
							
							IF @availableQuantity >= @tmpQuantity
								SET @actualQuantity = @tmpQuantity
							ELSE
							BEGIN
								SET @actualQuantity = @availableQuantity
								SET @tmpQuantity = @tmpQuantity - @availableQuantity
								SET @availableQuantity = 0
							END
							
							INSERT INTO ItemSalesHistory (TransactionID, ItemID, ItemPriceID, Quantity, OrderType, PaymentType, ItemStockID, ComplexID, SoldBy, SoldOn, IsBlocked, DiscountPerItem)
							VALUES (@transactionID, @itemID, @itemPriceID, @actualQuantity, @orderType, @paymentType, @itemStockID, @complexID, @userID, @dateTime, 0, 0.00)
							
							UPDATE Items SET StockOnHand = StockOnHand - @actualQuantity WHERE ItemID = @itemID
							
							UPDATE ItemStock SET AvailableQuantity = AvailableQuantity - @actualQuantity WHERE ItemStockID = @itemStockID
						END
					END
					ELSE
					BEGIN		
						INSERT INTO ItemSalesHistory (TransactionID, ItemID, ItemPriceID, Quantity, OrderType, PaymentType, ItemStockID, ComplexID, SoldBy, SoldOn, IsBlocked, DiscountPerItem)
						VALUES (@transactionID, @itemID, @itemPriceID, @tmpQuantity, @orderType, @paymentType, 0, @complexID, @userID, @dateTime, 0, 0.00)
						
						UPDATE Items SET StockOnHand = StockOnHand - @tmpQuantity WHERE ItemID = @itemID
						
						DECLARE curComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
						OPEN curComboItems
						FETCH NEXT FROM curComboItems INTO @tmpComItems
						WHILE @@FETCH_STATUS = 0
						BEGIN				
							DECLARE @tmpComItemID INT
							DECLARE @tmpComQuantity INT
							IF(CHARINDEX('-',@tmpComItems) > 0)
							BEGIN
								SELECT TOP(1) @tmpComItemID = value FROM DBO.SPLIT('-',@tmpComItems)
								SELECT TOP(1) @tmpComQuantity = value FROM DBO.SPLIT('-',@tmpComItems) ORDER BY ROWID DESC
								
								SELECT @quantity = StockOnHand FROM Items WHERE ItemID = @tmpComItemID
								
								IF (@quantity < (@tmpQuantity*@tmpComQuantity))
								BEGIN
									ROLLBACK
									RAISERROR('Stock is Insufficient!', 11, 1)
									RETURN
								END
								
								DECLARE @totalTmpComQuantity INT = (@tmpQuantity*@tmpComQuantity)
								
								SET @availableQuantity = 0
								WHILE (@availableQuantity < @totalTmpComQuantity)
								BEGIN
									SELECT TOP (1) @availableQuantity = ST.AvailableQuantity, @itemStockID = ST.ItemStockID
									FROM ItemStock ST, Items I
									WHERE ST.AvailableQuantity > 0 AND ST.StockType = 0 AND I.ItemID = ST.ItemID
									AND I.ItemID = @tmpComItemID
									ORDER BY ST.Cost
																
									IF @availableQuantity >= @totalTmpComQuantity
										SET @actualQuantity = @totalTmpComQuantity
									ELSE
									BEGIN
										SET @actualQuantity = @availableQuantity
										SET @totalTmpComQuantity = @totalTmpComQuantity - @availableQuantity
										SET @availableQuantity = 0
									END
									
									INSERT INTO ItemPackageSalesHistory (TransactionID, ItemPackageID, ItemID, Quantity, OrderType, ItemStockID)
									VALUES (@transactionID, @itemID, @tmpComItemID, @actualQuantity, @orderType, @itemStockID)
									
									UPDATE Items SET StockOnHand = StockOnHand - @actualQuantity WHERE ItemID = @tmpComItemID
									
									UPDATE ItemStock SET AvailableQuantity = AvailableQuantity - @actualQuantity WHERE ItemStockID = @itemStockID
								END
							END			
							FETCH NEXT FROM curComboItems INTO @tmpComItems
						END
						CLOSE curComboItems
						DEALLOCATE curComboItems
					END
				END
			END
		COMMIT
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
			ROLLBACK
		DECLARE @error NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@error, 11, 1)
	END CATCH
END
GO

/* [FoodAndBeverageItemSales] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FoodAndBeverageItemSales]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].FoodAndBeverageItemSales
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--[FoodAndBeverageItemSales] 1, '12-23-2015','12-29-2015', -1, 0, 0
CREATE PROCEDURE [dbo].FoodAndBeverageItemSales
	@theatreId INT,
	@fromDate VARCHAR(11),
	@toDate VARCHAR(11),
	@itemClassID INT,
	@itemID INT,
	@userID INT
AS
BEGIN 
	SELECT * INTO #ItemSales
	FROM
	(
		SELECT SH.*, 
			(SELECT SUM(Quantity) FROM ItemCancelHistory CH WHERE SH.TransactionID = CH.TransactionID AND SH.ItemID = CH.ItemID AND SH.ItemPriceID = CH.ItemPriceID AND SH.ItemStockID = CH.ItemStockID) AS CancelQuantity,
			(SELECT SUM(Cost) FROM ItemStock WHERE ItemStockID IN (SELECT ItemStockID FROM ItemPackageSalesHistory WHERE TransactionID = SH.TransactionID)) PackageCost,
			'F&B Counter' AS [Sales Type]
		FROM ItemSalesHistory SH
			INNER JOIN Items I ON I.ItemID = SH.ItemID 
			INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID
		WHERE 
			SH.SoldBy = (CASE WHEN @userID = 0 THEN SH.SoldBy ELSE @userID END)
			AND I.ItemClassID = (CASE WHEN @itemClassID = -1 THEN I.ItemClassID ELSE @itemClassID END)
			AND I.ItemID = (CASE WHEN @itemID = 0 THEN I.ItemID ELSE @itemID END)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) >= CONVERT(DATETIME, @fromDate, 106)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106)
			AND SH.ComplexID = @theatreId
			AND SH.SeatID IS NULL
	UNION
		 SELECT SH.*, 
			(SELECT SUM(Quantity) FROM ItemCancelHistory CH WHERE SH.TransactionID = CH.TransactionID AND SH.ItemID = CH.ItemID AND SH.ItemPriceID = CH.ItemPriceID AND SH.ItemStockID = CH.ItemStockID) AS CancelQuantity,
			(SELECT SUM(Cost) FROM ItemStock WHERE ItemStockID IN (SELECT ItemStockID FROM ItemPackageSalesHistory WHERE TransactionID = SH.TransactionID)) PackageCost,
			'Packaged Ticket' AS [Sales Type]
		FROM ItemSalesHistory SH
			INNER JOIN Items I ON I.ItemID = SH.ItemID 
			INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID
		WHERE 
			SH.SoldBy = (CASE WHEN @userID = 0 THEN SH.SoldBy ELSE @userID END)
			AND I.ItemClassID = (CASE WHEN @itemClassID = -1 THEN I.ItemClassID ELSE @itemClassID END)
			AND I.ItemID = (CASE WHEN @itemID = 0 THEN I.ItemID ELSE @itemID END)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) >= CONVERT(DATETIME, @fromDate, 106)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106)
			AND SH.ComplexID = @theatreId
			AND SH.SeatID IS NOT NULL
			AND IsBlocked = 0
	)A
	
	SELECT 
		(SELECT DISTINCT Expression FROM Type WHERE TypeName = 'ItemClass' AND Value = I.ItemClassID) AS [Item Class], 
		I.ItemName [Item Name],
		(SELECT DISTINCT Expression FROM Type WHERE TypeName = 'UnitOfMeasureType' AND Value = I.UnitOfMeasure) AS [Unit of Measure], 
		ISNULL(SUM(SH.Quantity), 0) - ISNULL(SUM(SH.CancelQuantity), 0) Quantity,
		IP.NetAmount [Net Amount Per Item],
		IP.VAT [VAT Per Item], 
		IP.AdditionalTax [Additional Tax Per Item], 
		IP.ServiceTax [Service Tax Per Item], 
		IP.SwachhBharatCess [Swachh Bharat Cess Per Item], 
		IP.SGST [SGST Per Item],
		IP.CGST [CGST Per Item],
		IP.CompensationCess [Compensation Cess Per Item],
		(CASE WHEN SH.ItemStockID <> 0 THEN (SELECT Cost FROM ItemStock WHERE ItemStock.ItemStockID = SH.ItemStockID) ELSE PackageCost END) [Cost Price Per Item], 
		IP.Price [Selling Price Per Item],
		SH.DiscountPerItem,
		SH.[Sales Type],
		SH.PaymentType
	INTO #SalesHistoryByPayment
	FROM #ItemSales SH 
		INNER JOIN Items I ON I.ItemID = SH.ItemID 
		INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID	
	GROUP BY SH.PackageCost, SH.PaymentType, I.ItemClassID, I.ItemID, I.ItemName, I.UnitOfMeasure, SH.ItemStockID, IP.Price, IP.VAT, IP.AdditionalTax, IP.ServiceTax, IP.SwachhBharatCess, IP.SGST, IP.CGST, IP.CompensationCess, IP.NetAmount, SH.DiscountPerItem, SH.[Sales Type]
	
	DROP TABLE #ItemSales
	
	SELECT 
		SH.[Item Class], SH.[Item Name], SH.[Unit of Measure], SUM(SH.Quantity) Quantity,
		(SELECT ISNULL(SUM(SH1.Quantity), 0) FROM #SalesHistoryByPayment SH1 
		WHERE SH1.[Item Class] = SH.[Item Class] AND SH1.[Item Name] = SH.[Item Name] AND SH.[Unit of Measure] = SH1.[Unit of Measure] AND 
		SH.[Net Amount Per Item] = SH1.[Net Amount Per Item] AND 
		SH.[VAT Per Item] = SH1.[VAT Per Item] AND SH.[Additional Tax Per Item] = SH1.[Additional Tax Per Item] AND
		SH.[Service Tax Per Item] = SH1.[Service Tax Per Item] AND SH.[Swachh Bharat Cess Per Item] = SH1.[Swachh Bharat Cess Per Item] AND
		SH.[SGST Per Item] = SH1.[SGST Per Item] AND SH.[CGST Per Item] = SH1.[CGST Per Item] AND SH.[Compensation Cess Per Item] = SH1.[Compensation Cess Per Item] AND
		SH.[Cost Price Per Item] = SH1.[Cost Price Per Item] AND SH.[Selling Price Per Item] = SH1.[Selling Price Per Item] AND 
		SH1.PaymentType = 5 AND SH.[Sales Type] = SH1.[Sales Type] AND SH.DiscountPerItem = SH1.DiscountPerItem) [Total Quanity Sold As Free],
		SH.[Net Amount Per Item], SH.[VAT Per Item], SH.[Additional Tax Per Item], SH.[Service Tax Per Item], SH.[Swachh Bharat Cess Per Item],
		SH.[SGST Per Item], SH.[CGST Per Item], SH.[Compensation Cess Per Item], 
		SH.[Cost Price Per Item], SH.[Selling Price Per Item], SH.DiscountPerItem, SH.[Sales Type]
	INTO #SalesHistory
	FROM #SalesHistoryByPayment SH
	GROUP BY SH.[Item Class], SH.[Item Name], SH.[Unit of Measure], SH.[Net Amount Per Item],
	SH.[VAT Per Item], SH.[Additional Tax Per Item], SH.[Service Tax Per Item], SH.[Swachh Bharat Cess Per Item], 
	SH.[SGST Per Item], SH.[CGST Per Item], SH.[Compensation Cess Per Item],
	SH.[Cost Price Per Item], SH.[Selling Price Per Item], SH.DiscountPerItem, SH.[Sales Type]
	ORDER BY [Item Class], [Item Name]
	
	DROP TABLE #SalesHistoryByPayment
	
	SELECT [Item Class], [Item Name], [Sales Type], Quantity, [Net Amount Per Item], [VAT Per Item], [Additional Tax Per Item], [Service Tax Per Item],
	[Swachh Bharat Cess Per Item], [SGST Per Item], [CGST Per Item], [Compensation Cess Per Item], [Cost Price Per Item], DiscountPerItem [Discount Per Item], ([Selling Price Per Item] - DiscountPerItem) [Selling Price Per Item],
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * ([Net Amount Per Item] - DiscountPerItem)) [Total Net Amount], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [VAT Per Item]) [Total VAT], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [Additional Tax Per Item]) [Total Additional Tax], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [Service Tax Per Item]) [Total Service Tax], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [Swachh Bharat Cess Per Item]) [Total Swachh Bharat Cess], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [SGST Per Item]) [Total SGST], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [CGST Per Item]) [Total CGST], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [Compensation Cess Per Item]) [Total Compensation Cess],
	(Quantity * [Cost Price Per Item]) [Total Cost Price], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * ([Selling Price Per Item] - DiscountPerItem)) [Total Selling Price], 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * ([Net Amount Per Item] - DiscountPerItem))
	- 
	((CASE WHEN Quantity >= [Total Quanity Sold As Free] THEN (Quantity - [Total Quanity Sold As Free]) ELSE ([Total Quanity Sold As Free] - Quantity) END) * [Cost Price Per Item]) [Profit or Loss On Net Amount]
	 INTO #SalesMaster
	 FROM #SalesHistory
	 
	DROP TABLE #SalesHistory
	
	DECLARE @totalSellingPrice NUMERIC(9,2) = (SELECT SUM([Total Selling Price]) FROM #SalesMaster)
	
	SELECT *, CAST(ROUND(CAST((CASE WHEN @totalSellingPrice = 0 THEN @totalSellingPrice ELSE ISNULL(([Total Selling Price]/@totalSellingPrice)* 100, 0) END) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage] FROM #SalesMaster
	WHERE Quantity <> 0
	ORDER BY [Item Class], [Item Name]

	IF @itemID = 0
		SELECT [Item Class], ''[Item Name], [Sales Type], ''[Unit of Measure], SUM(Quantity) Quantity, NULL[Net Amount Per Item], NULL[VAT Per Item], NULL[Additional Tax Per Item], NULL[Service Tax Per Item], NULL[Swachh Bharat Cess Per Item],
		NULL[SGST Per Item], NULL[CGST Per Item], NULL[Compensation Cess Per Item], NULL[Cost Price Per Item], NULL[Discount Per Item], NULL[Selling Price Per Item], SUM([Total Net Amount]) [Total Net Amount], SUM([Total VAT]) [Total VAT],
		SUM([Total Additional Tax]) [Total Additional Tax], SUM([Total Service Tax]) [Total Service Tax], SUM([Total Swachh Bharat Cess]) [Total Swachh Bharat Cess], SUM([Total SGST]) [Total SGST], SUM([Total CGST]) [Total CGST], SUM([Total Compensation Cess]) [Total Compensation Cess],
		SUM([Total Cost Price]) [Total Cost Price], SUM([Total Selling Price]) [Total Selling Price], SUM([Profit or Loss On Net Amount]) [Profit or Loss On Net Amount], 
		CAST(ROUND(CAST((CASE WHEN @totalSellingPrice = 0 THEN @totalSellingPrice ELSE ISNULL((SUM([Total Selling Price])/@totalSellingPrice)* 100, 0) END) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage]
		FROM #SalesMaster	
		GROUP BY [Item Class], [Sales Type]
		ORDER BY [Item Class]
	
	IF @itemClassID = -1 OR (SELECT COUNT([Item Name]) FROM #SalesMaster) > 1
		SELECT 'Grand Total'[Item Class], ''[Item Name], [Sales Type], ''[Unit of Measure], SUM(Quantity) Quantity, NULL[Net Amount Per Item], NULL[VAT Per Item], NULL[Additional Tax Per Item], NULL[Service Tax Per Item], NULL[Swachh Bharat Cess Per Item],
		NULL[SGST Per Item], NULL[CGST Per Item], NULL[Compensation Cess Per Item], NULL[Cost Price Per Item], NULL[Discount Per Item], NULL[Selling Price Per Item], SUM([Total Net Amount]) [Total Net Amount], SUM([Total VAT]) [Total VAT],
		SUM([Total Additional Tax]) [Total Additional Tax], SUM([Total Service Tax]) [Total Service Tax], SUM([Total Swachh Bharat Cess]) [Total Swachh Bharat Cess], SUM([Total SGST]) [Total SGST], SUM([Total CGST]) [Total CGST], SUM([Total Compensation Cess]) [Total Compensation Cess],
		SUM([Total Cost Price]) [Total Cost Price], SUM([Total Selling Price]) [Total Selling Price], SUM([Profit or Loss On Net Amount]) [Profit or Loss On Net Amount], 
		CAST(ROUND(CAST((CASE WHEN @totalSellingPrice = 0 THEN @totalSellingPrice ELSE ISNULL((SUM([Total Selling Price])/@totalSellingPrice)* 100, 0) END) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage] 
		FROM #SalesMaster	
		GROUP BY [Sales Type]
			
	DROP TABLE #SalesMaster
END
GO

/* [UpdateStockOnHandForItemPackage] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[UpdateStockOnHandForItemPackage]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateStockOnHandForItemPackage
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--[UpdateStockOnHandForItemPackage]
CREATE PROCEDURE [dbo].UpdateStockOnHandForItemPackage
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION
			CREATE TABLE #comboItems
				(
					SlNo INT IDENTITY(1,1) NOT NULL,
					ItemID INT,
					ComboItems VARCHAR(128)
				)
			INSERT INTO #comboItems
			SELECT ItemID, ComboItems FROM Items WHERE ComboItems != ''
			
			DECLARE @i INT = 1
			DECLARE @maxi INT = (SELECT MAX(SlNo) FROM #comboItems)
			WHILE @maxi >= @i
			BEGIN
				DECLARE @comboItems VARCHAR(128)
				DECLARE @itemID INT
				
				SELECT @comboItems = ComboItems, @itemID = ItemID FROM #comboItems WHERE SlNo = @i
			
				CREATE TABLE #Quantity
				(
					Quantity INT NOT NULL
				)
				
				DECLARE @tempComboItems VARCHAR(MAX)
				DECLARE currentComboItems CURSOR FOR SELECT value FROM DBO.SPLIT(',',@comboItems)
				OPEN currentComboItems
				FETCH NEXT FROM currentComboItems INTO @tempComboItems
				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @tempComboItemID INT
					DECLARE @tempComboQuantity INT
					IF(CHARINDEX('-',@tempComboItems) > 0)
					BEGIN
						SELECT TOP(1) @tempComboItemID = value FROM DBO.SPLIT('-',@tempComboItems)
						SELECT TOP(1) @tempComboQuantity = value FROM DBO.SPLIT('-',@tempComboItems) ORDER BY ROWID DESC
						
						INSERT INTO #Quantity
						SELECT StockOnHand/@tempComboQuantity FROM Items WHERE ItemID = @tempComboItemID
					END
					FETCH NEXT FROM currentComboItems INTO @tempComboItems
				END
				CLOSE currentComboItems
				DEALLOCATE currentComboItems
				
				UPDATE Items SET StockOnHand = (SELECT TOP(1) Quantity FROM #Quantity ORDER BY Quantity) WHERE ItemID = @itemID
				DROP TABLE #Quantity

				SET @i = @i + 1
			END
			DROP TABLE #comboItems
		COMMIT
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0
		   ROLLBACK
	END CATCH
END
GO

/* [ProductSales] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[ProductSales]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProductSales]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[ProductSales] 0, '05 Jan 2016','05 Jan 2016', 0
CREATE PROCEDURE [dbo].[ProductSales]
	@theatreID INT,
	@fromDate VARCHAR(11),
	@toDate VARCHAR(11),
	@userID INT
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT ShowID FROM Show WHERE ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = (CASE WHEN @theatreID = 0 THEN ComplexID ELSE @theatreID END))
		UNION ALL
		SELECT ShowID FROM ShowMIS WHERE ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = (CASE WHEN @theatreID = 0 THEN ComplexID ELSE @theatreID END))
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND StatusType IN (2,3) AND LastSoldByID = (CASE WHEN @userID = 0 THEN LastSoldByID ELSE @userID END) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastSoldOn, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastSoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106)
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND StatusType IN (2,3) AND LastSoldByID = (CASE WHEN @userID = 0 THEN LastSoldByID ELSE @userID END) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastSoldOn, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastSoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106)
	) SeatMaster
	
	SELECT [Price Card], [Ticket Type], SUM([Quantity]) [Quantity], [Net Amount], [Gross Amount], SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount], --SUM([Total Food and Beverage Amount]) [Total Food and Beverage Amount], 
	SUM([Total 3D Glass Amount]) [Total 3D Glass Amount], SUM([Total Other Theatre Charges]) [Total Other Theatre Charges], SUM([Total Amount]) [Total Amount]
	INTO
		#BOSales
	FROM
	(
		SELECT
			Sales.[Price Card] [Price Card],
			Sales.[Ticket Type] [Ticket Type],
			Sales.SeatsSold [Quantity],
			Sales.BTA [Net Amount],
			Sales.TA [Gross Amount],
			Sales.SeatsSold * Sales.BTA [Total Net Amount],
			Sales.SeatsSold * Sales.TA [Total Gross Amount],
			--Sales.SeatsSold * Sales.FB [Total Food and Beverage Amount],
			Sales.SeatsSold * Sales.ThreeD [Total 3D Glass Amount],
			Sales.SeatsSold * Sales.OTC [Total Other Theatre Charges],
			Sales.SeatsSold * Sales.Price [Total Amount],
			Sales.PaymentType
		FROM
		(
		SELECT
			(SELECT Name FROM PriceCard WHERE Id = S.PriceCardID) AS [Price Card],
			(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') AS [Ticket Type],
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Concession_Discount'), 0) AS FB,
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses'), 0) - 
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.PaymentType <> 5 AND Code = '3D_Glasses_Discount'), 0) AS ThreeD,
			ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Other_Theatre_Charges'), 0) AS OTC,
			ISNULL((SELECT Amount FROM PriceCard WHERE Id = S.PriceCardId AND S.PaymentType <> 5), 0) AS Price,
			COUNT(SeatId) AS SeatsSold,
			S.PaymentType
		FROM
			#SeatMaster S INNER JOIN #ShowMaster Sh ON Sh.ShowID = S.ShowID
		GROUP BY
			S.PriceCardId, S.PaymentType
		) Sales
		GROUP BY
			[Price Card], [Ticket Type], SeatsSold, Price, BTA, TA, PaymentType, FB, ThreeD, OTC
	)A GROUP BY [Price Card], [Ticket Type], [Net Amount], [Gross Amount]
	
	SELECT [Item Class], [Item Name], SUM(Quantity) Quantity, [Net Amount], [Gross Amount], SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount]
	INTO #FBSales
	FROM
	(
	SELECT ItemID, [Item Class], [Item Name], SUM(Quantity) Quantity, [Net Amount], [Gross Amount], SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount]
	FROM
	(
		SELECT
			SH.TransactionID,
			I.ItemID,
			(SELECT Expression FROM Type WHERE TypeName = 'ItemClass' AND Value = I.ItemClassID) AS [Item Class], 
			I.ItemName [Item Name],
			SH.Quantity - ISNULL(SUM(ICH.Quantity),0) Quantity,
			IP.NetAmount [Net Amount], 
			IP.Price [Gross Amount],
			(SH.Quantity - ISNULL(SUM(ICH.Quantity),0)) * IP.NetAmount [Total Net Amount],
			(SH.Quantity - ISNULL(SUM(ICH.Quantity),0)) * IP.Price [Total Gross Amount]

		FROM
			ItemSalesHistory SH 
		INNER JOIN Items I ON I.ItemID = SH.ItemID 
		INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID
		lEFT JOIN ItemCancelHistory ICH ON ICH.TransactionID = SH.TransactionID AND ICH.ItemID = SH.ItemID AND ICH.ItemStockID = SH.ItemStockID
		WHERE
			SH.PaymentType <> 5
			AND SH.SoldBy = (CASE WHEN @userID = 0 THEN SH.SoldBy ELSE @userID END)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) >= CONVERT(DATETIME, @fromDate, 106)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106)
			AND SH.ComplexID = (CASE WHEN @theatreID = 0 THEN SH.ComplexID ELSE @theatreID END)
			AND SH.SeatID IS NULL
		GROUP BY SH.TransactionID, I.ItemID, SH.ItemStockID, I.ItemClassID, I.ItemName, SH.Quantity, IP.NetAmount, IP.Price
		)A
	WHERE A.Quantity > 0
	GROUP BY ItemID, [Item Class], [Item Name], [Net Amount], [Gross Amount]

	UNION ALL

	SELECT SH.ItemID, (SELECT Expression FROM Type WHERE TypeName = 'ItemClass' AND Value = I.ItemClassID) AS [Item Class], I.ItemName [Item Name],
		SUM(SH.Quantity)- ISNULL(SUM(ICH.Quantity),0) Quantity, 0 [Net Amount], 0 [Gross Amount], 0 [Total Net Amount], 0 [Total Gross Amount]
	FROM
		ItemSalesHistory SH INNER JOIN Items I ON I.ItemID = SH.ItemID
		lEFT JOIN ItemCancelHistory ICH ON ICH.TransactionID = SH.TransactionID AND ICH.ItemID = SH.ItemID
	WHERE
		SH.PaymentType = 5
		AND SH.SoldBy = (CASE WHEN @userID = 0 THEN SH.SoldBy ELSE @userID END)
		AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) >= CONVERT(DATETIME, @fromDate, 106)
		AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106)
		AND SH.ComplexID = (CASE WHEN @theatreID = 0 THEN SH.ComplexID ELSE @theatreID END)
		AND SH.SeatID IS NULL
	GROUP BY SH.ItemID, I.ItemName, I.ItemClassID
	)A
	GROUP BY [Item Class], [Item Name], [Net Amount], [Gross Amount]
	
	DECLARE @totalBOGrossAmount NUMERIC(9,2) = (SELECT ISNULL(SUM([Total Gross Amount]),0) FROM #BOSales)
	DECLARE @totalFBGrossAmount NUMERIC(9,2) = (SELECT ISNULL(SUM([Total Gross Amount]),0) FROM #FBSales)
	DECLARE @totalGrossAmount NUMERIC(9,2) = @totalBOGrossAmount + @totalFBGrossAmount
	IF @totalGrossAmount = 0
	BEGIN
		SET @totalBOGrossAmount = 1
		SET @totalFBGrossAmount = 1
		SET @totalGrossAmount = 1
	END
	
	SELECT * INTO #Code
	FROM
	(		
		SELECT Code FROM PriceCardItems WHERE Code IN (SELECT Code FROM PriceCardDetails WHERE Code = 'Other_Theatre_Charges' AND PriceCardId IN 
		(SELECT PriceCardID FROM #SeatMaster))
	) PCCode

	IF EXISTS(SELECT * FROM #Code)
	BEGIN
		SELECT '', *, CAST(ROUND(CAST(ISNULL(([Total Gross Amount]/@totalBOGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Group],
		CAST(ROUND(CAST(ISNULL(([Total Gross Amount]/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
		FROM #BOSales
	
		SELECT 'Grand Box Office Total', ''[Price Card], ''[Ticket Type], SUM(Quantity) Quantity, NULL[Net Amount], NULL[Gross Amount], SUM([Total Net Amount]) [Total Net Amount],
		SUM([Total Gross Amount]) [Total Gross Amount], --SUM([Total Food and Beverage Amount]) [Total Food and Beverage Amount], 
		SUM([Total 3D Glass Amount]) [Total 3D Glass Amount], SUM([Total Other Theatre Charges]) [Total Other Theatre Charges], SUM([Total Amount]) [Total Amount], '' [Sales Percentage of Group],
		CAST(ROUND(CAST(ISNULL((SUM([Total Gross Amount])/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
		FROM #BOSales
	END
	ELSE
	BEGIN
		SELECT '', [Price Card], [Ticket Type], Quantity, [Net Amount], [Gross Amount], [Total Net Amount], [Total Gross Amount], 
		--[Total Food and Beverage Amount], 
		[Total 3D Glass Amount], [Total Amount],
		CAST(ROUND(CAST(ISNULL(([Total Gross Amount]/@totalBOGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Group],
		CAST(ROUND(CAST(ISNULL(([Total Gross Amount]/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
		FROM #BOSales
	
		SELECT 'Grand Box Office Total', ''[Price Card], ''[Ticket Type], SUM(Quantity) Quantity, NULL[Net Amount], NULL[Gross Amount], SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount], 
		--SUM([Total Food and Beverage Amount]) [Total Food and Beverage Amount], 
		SUM([Total 3D Glass Amount]) [Total 3D Glass Amount], SUM([Total Amount]) [Total Amount], 
		'' [Sales Percentage of Group],
		CAST(ROUND(CAST(ISNULL((SUM([Total Gross Amount])/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
		FROM #BOSales
	END
	
	SELECT *, CAST(ROUND(CAST(ISNULL(([Total Gross Amount]/@totalFBGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Group],
	CAST(ROUND(CAST(ISNULL(([Total Gross Amount]/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
	FROM #FBSales
	ORDER BY [Item Class], [Item Name]
	
	SELECT [Item Class], ''[Item Name], SUM(Quantity) Quantity, NULL[Net Amount], NULL[Gross Amount], SUM([Total Net Amount]) [Total Net Amount],
	SUM([Total Gross Amount]) [Total Gross Amount], CAST(ROUND(CAST(ISNULL((SUM([Total Gross Amount])/@totalFBGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Group],
	CAST(ROUND(CAST(ISNULL((SUM([Total Gross Amount])/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
	FROM #FBSales
	GROUP BY [Item Class]
	ORDER BY [Item Class]
	
	/*SELECT 'Grand Food and Beverage Total' [Item Class], ''[Item Name], SUM(Quantity) Quantity, NULL[Net Amount], NULL[Gross Amount], SUM([Total Net Amount]) [Total Net Amount],
	SUM([Total Gross Amount]) [Total Gross Amount], '' [Sales Percentage of Group],
	CAST(ROUND(CAST(ISNULL((SUM([Total Gross Amount])/@totalGrossAmount)* 100, 0) AS NUMERIC(9,2)), 2) AS VARCHAR(11)) + '%' [Sales Percentage of Total]
	FROM #FBSales*/
	
	SELECT SUM(Quantity) Quantity, SUM([Total Net Amount]) [Total Net Amount],
	SUM([Total Gross Amount]) [Total Gross Amount],
	SUM([Total Amount Collected]) [Total Amount Collected]
	FROM
	(SELECT SUM(Quantity) Quantity, SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount], SUM([Total Amount]) [Total Amount Collected] FROM #BOSales
	UNION ALL
	SELECT SUM(Quantity) Quantity, SUM([Total Net Amount]) [Total Net Amount], SUM([Total Gross Amount]) [Total Gross Amount], SUM([Total Gross Amount]) [Total Amount Collected] FROM #FBSales)A
	
	DROP TABLE #Code
	DROP TABLE #SeatMaster
	DROP TABLE #ShowMaster
	DROP TABLE #BOSales
	DROP TABLE #FBSales
END
GO

/* FoodAndBeverageSalesSummary */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FoodAndBeverageSalesSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FoodAndBeverageSalesSummary]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--FoodAndBeverageSalesSummary 1  
CREATE PROCEDURE [dbo].[FoodAndBeverageSalesSummary]
 @userID INT
AS
BEGIN
	SELECT
		SH.TransactionID,
		SH.ItemID, 
		SH.ItemPriceID,
		SH.ItemStockID,
		SH.Quantity,
		SH.PaymentType,
		C.ComplexName,
		(SELECT SUM(Quantity) FROM ItemCancelHistory CH WHERE SH.TransactionID = CH.TransactionID AND SH.ItemID = CH.ItemID AND SH.ItemPriceID = CH.ItemPriceID AND SH.ItemStockID = CH.ItemStockID) AS CancelQuantity
	INTO #ItemSales 
	FROM ItemSalesHistory SH
		INNER JOIN Items I ON I.ItemID = SH.ItemID 
		INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID
		INNER JOIN Complex C ON C.ComplexID = SH.ComplexID
	WHERE
		SH.SeatID IS NULL
		AND SH.SoldBy = @userID
		AND CONVERT(VARCHAR(12), SoldOn, 101) = CONVERT(VARCHAR(12), GETDATE(), 101)

	SELECT
		SH.ComplexName,
		I.ItemName [Item Name],
		ISNULL(SUM(SH.Quantity), 0) - ISNULL(SUM(SH.CancelQuantity), 0) SalesQuantity,
		ISNULL(SUM(SH.CancelQuantity), 0) CancelQuantity, 
		IP.Price [Selling Price Per Item],
		IP.NetAmount [Net Amount Per Item],
		SH.PaymentType
	INTO #SalesHistoryByPayment
	FROM #ItemSales SH 
		INNER JOIN Items I ON I.ItemID = SH.ItemID 
		INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID	
	GROUP BY SH.PaymentType, I.ItemName, IP.Price, IP.NetAmount, SH.ComplexName
	
	DROP TABLE #ItemSales
	
	SELECT 
		SH.ComplexName,
		SH.[Item Name], 
		SUM(SH.SalesQuantity) SalesQuantity,
		SUM(SH.CancelQuantity) CancelQuantity,
		(SELECT ISNULL(SUM(SH1.SalesQuantity), 0) FROM #SalesHistoryByPayment SH1 
		WHERE SH1.[Item Name] = SH.[Item Name] AND 
		SH.[Net Amount Per Item] = SH1.[Net Amount Per Item] AND SH.[Selling Price Per Item] = SH1.[Selling Price Per Item] AND 
		SH1.PaymentType = 5) [FreeQuantity],
		SH.[Net Amount Per Item],
		SH.[Selling Price Per Item]
	INTO #SalesHistory
	FROM #SalesHistoryByPayment SH
	GROUP BY SH.[Item Name], SH.[Net Amount Per Item], SH.[Selling Price Per Item], SH.ComplexName
	ORDER BY [Item Name]
	
	DROP TABLE #SalesHistoryByPayment
	
	SELECT
		ComplexName,
		[Item Name] ItemName, 
		SUM(SalesQuantity), 
		SUM(CancelQuantity),
		SUM((CASE WHEN SalesQuantity >= [FreeQuantity] THEN (SalesQuantity - [FreeQuantity]) ELSE ([FreeQuantity] - SalesQuantity) END) * [Net Amount Per Item]) [TotalNetAmount], 
		SUM((CASE WHEN SalesQuantity >= [FreeQuantity] THEN (SalesQuantity - [FreeQuantity]) ELSE ([FreeQuantity] - SalesQuantity) END) * [Selling Price Per Item]) [TotalSellingPrice]
	 FROM #SalesHistory
	 GROUP BY ComplexName, [Item Name]
	 ORDER BY ComplexName, [Item Name]
	 
	DROP TABLE #SalesHistory	
END
GO

/* [ViewTransaction] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ViewTransaction]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ViewTransaction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec ViewTransaction '5B498C1D85'
CREATE PROCEDURE [dbo].[ViewTransaction]
	@transactionID VARCHAR(20)
AS
BEGIN
	IF CHARINDEX(',',@transactionID) > 0
	BEGIN
		DECLARE @code VARCHAR(10) = (SELECT TOP 1 DATA FROM DBO.[SPLITstring](@transactionID, ','))
		DECLARE @mobile VARCHAR(10) = (SELECT TOP 1 DATA FROM DBO.[SPLITstring](@transactionID, ',') ORDER BY DATA DESC)
		
		CREATE TABLE #tranID(TransactionID NVARCHAR(10))
		IF EXISTS (SELECT SeatId FROM BookHistory WHERE BEBookingCode = @code AND PatronInfo LIKE '%' + @mobile + '%' AND SeatId IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE IsAdvanceToken = 0)))
			INSERT INTO #tranID SELECT DISTINCT ItemTransactionID FROM BookHistory WHERE BEBookingCode = @code AND PatronInfo LIKE '%' + @mobile + '%' AND ItemTransactionID IS NOT NULL
		ELSE IF EXISTS (SELECT SeatId FROM BookHistory WHERE BOBookingCode = @code AND PatronInfo LIKE '%' + @mobile + '%' AND SeatId IN (SELECT SeatID FROM Seat WHERE ShowID IN (SELECT ShowID FROM Show WHERE IsAdvanceToken = 0)))
			INSERT INTO #tranID SELECT DISTINCT ItemTransactionID FROM BookHistory WHERE BOBookingCode = @code AND PatronInfo LIKE '%' + @mobile + '%' AND ItemTransactionID IS NOT NULL
		ELSE
			SELECT @transactionID = '' 
			
		IF @transactionID <> ''
		BEGIN
			IF (SELECT COUNT(*) FROM #tranID) > 1
				SELECT @transactionID = ''
			ELSE
				SELECT @transactionID = TransactionID FROM #tranID
		END
		
		DROP TABLE #tranID
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT TOP 1 ItemTransactionID FROM BookHistory WHERE SeatId IN (SELECT SeatID FROM SEAT WHERE CAST(TicketID AS VARCHAR) = @transactionID) AND ItemTransactionID NOT IN (SELECT TransactionID FROM ItemCancelHistory) AND ItemTransactionID IS NOT NULL)
			SELECT TOP 1 @transactionID = ItemTransactionID FROM BookHistory WHERE SeatId IN (SELECT SeatID FROM SEAT WHERE CAST(TicketID AS VARCHAR) = @transactionID) AND ItemTransactionID NOT IN (SELECT TransactionID FROM ItemCancelHistory) AND ItemTransactionID IS NOT NULL
	END
	
	SELECT
		TransactionID,
		ItemID,
		SUM(Quantity) - (SELECT ISNULL(SUM(Quantity),0) FROM ItemCancelHistory WHERE TransactionID = ISH.TransactionID AND ItemID = ISH.ItemID),
		(SELECT ISNULL(SUM(Quantity),0) FROM ItemCancelHistory WHERE TransactionID = ISH.TransactionID AND ItemID = ISH.ItemID) AS CancelledCount,
		OrderType,
		IsBlocked,
		PaymentType
	FROM
		ItemSalesHistory ISH
	WHERE
		TransactionID = @transactionID
	GROUP BY
		TransactionID, ItemID, OrderType, IsBlocked, PaymentType
END
GO

/* [ListItemsByTransaction] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListItemsByTransaction]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ListItemsByTransaction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec ListItemsByTransaction '5B498C1D85'
CREATE PROCEDURE [dbo].[ListItemsByTransaction]
	@transactionID VARCHAR(20)
AS
BEGIN
	IF @transactionID <> ''
	BEGIN
		SELECT
			ISH.ItemID, ItemName, Price, SGST, SGSTPercent, AdditionalTax, AdditionalTaxPercent, CompensationCess, CompensationCessPercent, CGST, CGSTPercent, NetAmount,
            (SELECT SUM(Quantity) FROM ItemSalesHistory WHERE TransactionID = ISH.TransactionID AND ItemID = ISH.ItemID) - (SELECT ISNULL(SUM(Quantity),0) FROM ItemCancelHistory WHERE TransactionID = ISH.TransactionID AND ItemID = ISH.ItemID),
            IsOnline, Shortcut, Row, [Column], ISNULL(ComboItems, ''), IsNull(Replace(Replace(Replace((select * from dbo.GETITEMS(ComboItems) for xml path),'</VALUE></row><row><VALUE>',','),'<row><VALUE>',''),'</VALUE></row>',''),''), ISH.DiscountPerItem, HSNCode
        FROM
			ItemSalesHistory ISH, Items I, ItemPrice, SetupOrder
		WHERE
			ISH.ItemID = SetupOrder.ItemID AND ISH.ItemPriceID = ItemPrice.ItemPriceID AND ISH.ItemID = I.ItemID
            AND (SELECT SUM(Quantity) FROM ItemSalesHistory WHERE TransactionID = ISH.TransactionID AND ItemID = ISH.ItemID) > (SELECT ISNULL(SUM(Quantity),0) FROM ItemCancelHistory WHERE TransactionID = ISH.TransactionID AND ItemID = ISH.ItemID)
            AND ISH.TransactionID = @transactionID
		GROUP BY
			ISH.TransactionID, ISH.ItemID, ItemName, IsOnline, Shortcut, Row, [Column], ComboItems, Price, SGST, SGSTPercent, AdditionalTax, AdditionalTaxPercent, CompensationCess, CompensationCessPercent, CGST, CGSTPercent, NetAmount, DiscountPerItem, HSNCode
        ORDER BY
			Shortcut 
	END
	ELSE
	BEGIN
		SELECT
			I.ItemID, ItemName, Price, SGST, SGSTPercent, AdditionalTax, AdditionalTaxPercent, CompensationCess, CompensationCessPercent, CGST, CGSTPercent, NetAmount,
            StockOnHand, IsOnline, Shortcut, Row, [Column], ISNULL(ComboItems, ''),
            IsNull(Replace(Replace(Replace((select * from dbo.GETITEMS(ComboItems) for xml path),'</VALUE></row><row><VALUE>',','),'<row><VALUE>',''),'</VALUE></row>',''),''), 0.00, HSNCode
        FROM
			Items I, ItemPrice, SetupOrder
		WHERE
			I.IsActive = 1 AND I.ItemID = SetupOrder.ItemID AND I.ItemPriceID = ItemPrice.ItemPriceID
        ORDER BY
			Shortcut
	END
END
GO

/* [GetUnclaimedStock] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[GetUnclaimedStock]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].GetUnclaimedStock
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--[GetUnclaimedStock] 1, 0, '02 Jan 2016','02 Jan 2016'
CREATE PROCEDURE [dbo].GetUnclaimedStock
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
AS
BEGIN	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, C.ClassName, SE.TicketID, SE.SeatID, (SELECT Name FROM PriceCard WHERE ID = SE.PriceCardId) PriceCardName FROM Seat SE 
		INNER JOIN Show S ON S.ShowID = SE.ShowID
		INNER JOIN Class C ON C.ClassID = SE.ClassID
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106)  
			AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END 
			AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) 
			AND S.IsCancel = 0
			AND SE.PriceCardID IN (SELECT PriceCardID FROM PriceCardItemDetails)
			AND SE.SeatType <> 1
			AND SE.StatusType IN (2,3)
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.MovieName, S.ScreenName, C.ClassName, SE.TicketID, SE.SeatID, (SELECT Name FROM PriceCard WHERE ID = SE.PriceCardId) PriceCardName FROM SeatMIS SE 
		INNER JOIN ShowMIS S ON S.ShowID = SE.ShowID
		INNER JOIN ClassMIS C ON C.ClassID = SE.ClassID
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106)  
			AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END 
			AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) 
			AND S.IsCancel = 0
			AND SE.PriceCardID IN (SELECT PriceCardID FROM PriceCardItemDetails)
			AND SE.SeatType <> 1
			AND SE.StatusType IN (2,3)
	) SeatMasterByDate

	SELECT DISTINCT S.ShowTime, S.MovieName, S.ScreenName, S.ClassName, S.PriceCardName, ISH.SoldOn AS TransactionDate, ISNULL(BEBookingCode, ISNULL(BOBookingCode, S.TicketID)) AS BookingID, ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(PatronInfo, '|') WHERE ID = 3), 'Not Applicable') AS MobileNumber FROM ItemSalesHistory ISH
	INNER JOIN #SeatMasterByDate S ON ISH.SeatID = S.SeatID
	INNER JOIN BookHistory BH ON BH.ItemTransactionID = ISH.TransactionID
	WHERE IsBlocked = 1 AND ISH.TransactionID NOT IN (SELECT TransactionID FROM ItemCancelHistory)
	ORDER BY S.ShowTime, S.MovieName, S.ScreenName, S.ClassName, S.PriceCardName, ISH.SoldOn DESC
	
	DROP TABLE #SeatMasterByDate
END
GO

/* [LoadPriceCardsByClassLayoutID] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadPriceCardsByClassLayoutID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadPriceCardsByClassLayoutID]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LoadPriceCardsByClassLayoutID]
	@classLayoutID INT
AS
BEGIN
	SELECT ID, Name FROM PriceCard WHERE ID IN (SELECT PriceCardID FROM PriceCardClassLayoutCollections WHERE ClassLayoutID = @classLayoutID)
END
GO

/* LoadPriceCardsForShow */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadPriceCardsForShow]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].LoadPriceCardsForShow
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--LoadPriceCardsForShow 5, 87, 105
CREATE PROCEDURE [dbo].LoadPriceCardsForShow
	@classLayoutID INT,
	@priceCardID INT,
	@classID INT
AS
BEGIN
	CREATE TABLE #PC (ID INT, Name NVARCHAR(100), ClassID INT)
	IF EXISTS(SELECT ClassLayoutId FROM PriceCardClassLayoutCollections WHERE ClassLayoutId = @classLayoutID)
	BEGIN
		INSERT INTO #PC
		SELECT Id, Name, 0 FROM PriceCard WHERE
		(Id IN (SELECT PriceCardId FROM PriceCardClassLayoutCollections WHERE ClassLayoutId = @classLayoutID) OR Id = @priceCardID)	AND Id != 0 
		AND Id NOT IN (SELECT PriceCardID FROM ClassPriceCards WHERE ClassID = @classID)
		INSERT INTO #PC
		SELECT Id, Name, ClassID FROM PriceCard, ClassPriceCards WHERE Id = PriceCardID AND ClassID = @classID
	END
	ELSE
	BEGIN
		INSERT INTO #PC
		SELECT Id, Name, 0 FROM PriceCard
		WHERE Id != 0 AND (IsDeleted = 0 OR Id = @priceCardID) 
		AND Id NOT IN (SELECT PriceCardID FROM ClassPriceCards WHERE ClassID = @classID)
		INSERT INTO #PC
		SELECT Id, Name, ClassID FROM PriceCard, ClassPriceCards WHERE Id = PriceCardID AND ClassID = @classID
		
	END
	SELECT * FROM #PC ORDER BY ID DESC
	DROP TABLE #PC
END
GO


/* [WeeklyReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WeeklyReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WeeklyReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[WeeklyReport] 1, 0, '06 Jan 2016', '06 Jan 2016', 1
CREATE PROCEDURE [dbo].[WeeklyReport]
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11),
	@showDCR BIT
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowTime, UPPER(S.ShowName) ShowName, S.ScreenName, C.ClassName, C.ClassID, C.DCRID, (SELECT DCRName FROM DCR WHERE DCRId = C.DCRID) DCRName, C.OpeningDCRNo, C.ClosingDCRNo FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND C.OpeningDCRNo IS NOT NULL AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, UPPER(S.ShowName) ShowName, S.ScreenName, C.ClassName, C.ClassID, C.DCRID, (SELECT DCRName FROM DCR WHERE DCRId = C.DCRID) DCRName, C.OpeningDCRNo, C.ClosingDCRNo FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND C.OpeningDCRNo IS NOT NULL AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType, ClassID, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType, ClassID, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT ShowName, DCRName, DCRID, CONVERT(VARCHAR(19), ShowTime) ShowTime, ScreenName, ClassName, TicketType, BTA, ET, 
	CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC, OpeningDCRNo, ClosingDCRNo, 
	SUM(SeatsSold) AS SeatsSold, SUM(PaidSeatsSold) PaidSeatsSold
	INTO #WeeklyReport 
	FROM
		(SELECT
		Sh.DCRName,
		Sh.ShowName,
		Sh.ShowID,
		Sh.ShowTime,
		Sh.ScreenName,
		Sh.ClassName,
		Sh.DCRID,
		ISNULL(Sh.OpeningDCRNo, 0) OpeningDCRNo,
		ISNULL(Sh.ClosingDCRNo,0) ClosingDCRNo,
		(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') AS [TicketType],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGSTPercent,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT ValueByCalculationType FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGSTPercent,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Film_Development_Fund'), 0) AS FDF,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Flood_Cess'), 0) AS FC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5) PaidSeatsSold
		FROM
		#ShowMasterByDate Sh INNER JOIN #SeatMasterByDate S ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID 
		GROUP BY 
		Sh.DCRName,
		Sh.ShowName,
		Sh.ShowID,
		Sh.ShowTime,
		Sh.ScreenName,
		Sh.ClassName,
		Sh.DCRID,
		S.PriceCardId,
		S.SeatID,
		Sh.OpeningDCRNo,
		Sh.ClosingDCRNo) WR
	GROUP BY DCRName, DCRID, ShowName, ShowTime, ScreenName, ClassName, TicketType, BTA, ET, CGST, SGST, CGSTPercent, SGSTPercent, FDF, FC, OpeningDCRNo, ClosingDCRNo
	ORDER BY ShowTime
	--ORDER BY DCRName, ScreenName, ClassName, TicketType, BTA, ET, FDF, OpeningDCRNo, ClosingDCRNo 
	
	DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX);

	SET @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(ShowName) 
            FROM #WeeklyReport
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
    
    IF @showDCR = 1
		SET @query = 
		N'SELECT * FROM(
		SELECT ShowName, DCRName, ScreenName, ClassName, TicketType, BTA, ET, CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC, 
		ISNULL(SUM(SeatsSold), 0) AS SeatsSold
		FROM #WeeklyReport 
		GROUP BY ShowName, DCRName, ScreenName, ClassName, TicketType, BTA, ET, CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC) AS p
		PIVOT
		(SUM(SeatsSold) FOR ShowName IN (' + @cols + ')) AS PVTTable ORDER BY DCRName, ClassName, TicketType DESC'
	ELSE
		SET @query = 
		N'SELECT * FROM(
		SELECT ShowName, ScreenName, ClassName, TicketType, BTA, ET, CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC, 
		ISNULL(SUM(SeatsSold), 0) AS SeatsSold
		FROM #WeeklyReport 
		GROUP BY ShowName, ScreenName, ClassName, TicketType, BTA, ET, CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC) AS p
		PIVOT
		(SUM(SeatsSold) FOR ShowName IN (' + @cols + ')) AS PVTTable ORDER BY ClassName, TicketType DESC'

	EXEC sp_executesql @query
	
	SELECT ShowName, DCRName, (SELECT DCRStartingNo FROM DCR WHERE DCR.DCRID = W.DCRID) AS DCRStartingNo, 
	(SELECT DCRMax FROM DCR WHERE DCR.DCRID = W.DCRID) AS DCRMax, ScreenName, ClassName, TicketType, BTA, ET, CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC,
	ISNULL(OpeningDCRNo, 0) AS OpeningDCRNo,
	ISNULL(ClosingDCRNo, 0) AS ClosingDCRNo,
	SUM(SeatsSold) AS SeatsSold,  SUM(PaidSeatsSold) * ET AS TET, SUM(PaidSeatsSold) * CGST AS TCGST, SUM(PaidSeatsSold) * SGST AS TSGST,
	SUM(PaidSeatsSold) * FDF AS TFDF, SUM(PaidSeatsSold) * FC AS TFC, SUM(PaidSeatsSold) * BTA AS TBTA 
	FROM #WeeklyReport W
	GROUP BY ShowName, DCRID, DCRName, ScreenName, ClassName, TicketType, BTA, ET, CGSTPercent, CGST, SGSTPercent, SGST, FDF, FC, OpeningDCRNo, ClosingDCRNo
	--ORDER BY TicketType DESC
	
	SELECT ShowName, SUM(SeatsSold) AS SeatsSold FROM #WeeklyReport GROUP BY ShowName
	
	SELECT ScreenName, ShowName FROM #ShowMasterByDate GROUP BY ShowTime, ScreenName, ShowName ORDER BY ShowTime, ScreenName, ShowName
	
	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMasterByDate))
	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate
	DROP TABLE #WeeklyReport
END
GO

/* [DailyCollectionSummaryReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DailyCollectionSummaryReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DailyCollectionSummaryReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[DailyCollectionSummaryReport] 1, 0, '06 Nov 2016', 1, 'Billa'

CREATE PROCEDURE [dbo].[DailyCollectionSummaryReport]
	@theatreId INT,
	@screenId INT,
	@showDate VARCHAR(11),
	@distributorId INT,
	@movieName NVARCHAR(256)
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT S.ShowID, S.ShowName, S.ShowTime, S.ScreenName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, (SELECT DCRName FROM DCR WHERE DCRId = C.DCRID) DCRName, C.DCRID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowName, S.ShowTime, S.ScreenName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, (SELECT DCRName FROM DCR WHERE DCRId = C.DCRID) DCRName, C.DCRID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
	) ShowMaster

	SELECT * INTO #SeatMaster FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
	) SeatMaster
 
	SELECT
		SalesByDate.[Screen Name],
		SalesByDate.[Class Name],
		SalesByDate.DCRName,
		SalesByDate.TicketType,
		SalesByDate.[Nett Price],
		SalesByDate.[Opening Number],
		SalesByDate.[Closing Number],
		SUM(SalesByDate.[Total Tickets]) [Total Tickets],
		SUM(SalesByDate.[Nett Amount]) [Nett Amount],
		SalesByDate.[Show Name],
		SalesByDate.DCRID
	INTO #SalesByDate
	FROM
	(
	SELECT
		Sales.ScreenName [Screen Name],
		Sales.Class [Class Name],
		Sales.DCRName,
		Sales.TicketType,
		Sales.BTA [Nett Price],
		CASE WHEN SUM(Sales.SeatsSold) > 0 THEN Sales.OpeningDCRNo ELSE 0 END [Opening Number],
		CASE WHEN SUM(Sales.SeatsSold) > 0 THEN Sales.ClosingDCRNo ELSE 0 END [Closing Number],
		SUM(Sales.SeatsSold) [Total Tickets],
		SUM(Sales.PaidSeatsSold) * Sales.BTA [Nett Amount],
		Sales.ShowName [Show Name],
		Sales.DCRID
	FROM
	(
	SELECT 
		Sh.ScreenName AS ScreenName, 
		Sh.ShowName AS ShowName,
		Sh.ClassName AS Class,
		Sh.DCRName AS DCRName,
		Sh.OpeningDCRNo AS OpeningDCRNo,
		Sh.ClosingDCRNo AS ClosingDCRNo,
		Sh.DCRID AS DCRID,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		CASE WHEN S.StatusType IN (2,3) THEN COUNT(SeatId) ELSE 0 END AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.ClassID = S.ClassID AND S.SeatID = S1.SeatID AND S.PaymentType <> 5 AND StatusType IN (2,3)) AS PaidSeatsSold,
		(SELECT Expression FROM [Type] WHERE TypeName ='TicketType' AND Value = PC.TicketType) AS TicketType
	FROM
		#SeatMaster S
		INNER JOIN #ShowMaster Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
		INNER JOIN PriceCard PC ON PC.Id = S.PriceCardID
	WHERE
		PC.TicketType <> 2
	GROUP BY Sh.ScreenName, Sh.ShowName, Sh.ClassName, Sh.OpeningDCRNo, Sh.ClosingDCRNo, Sh.DCRName, Sh.DCRID, S.PaymentType, S.PriceCardId, S.ClassID, Sh.ClassID, S.SeatID, PC.TicketType, S.StatusType
	) Sales
	GROUP BY ScreenName, ShowName, Class, BTA, OpeningDCRNo, ClosingDCRNo, DCRName, TicketType, DCRID
	) SalesByDate
	GROUP BY [Screen Name], [Class Name], DCRName, TicketType, [Nett Price], [Opening Number], [Closing Number], [Show Name], DCRID
	
	SELECT ScreenName, ShowName FROM #ShowMaster GROUP BY ShowTime, ScreenName, ShowName ORDER BY ShowTime, ScreenName, ShowName
	
	DROP TABLE #SeatMaster
	DROP TABLE #ShowMaster
	
	SELECT [Screen Name], [Class Name], TicketType [Ticket Type], [Nett Price] FROM #SalesByDate
	GROUP BY [Screen Name], [Class Name], TicketType, [Nett Price]
	ORDER BY [Class Name], TicketType DESC
	
	SELECT [Show Name] FROM (
	SELECT [Show Name], COUNT([Show Name]) SHOWCOUNT FROM #SalesByDate
	GROUP BY [Screen Name], [Class Name], TicketType, [Nett Price], [Show Name]
	HAVING COUNT([Show Name]) > 1)A GROUP BY [Show Name], SHOWCOUNT
	
	SELECT *, (SELECT DCRStartingNo FROM DCR WHERE DCR.DCRID = #SalesByDate.DCRID) AS DCRStartingNo, (SELECT DCRMax FROM DCR WHERE DCR.DCRID = #SalesByDate.DCRID) AS DCRMax FROM #SalesByDate ORDER BY DCRID, [Opening Number], [Closing Number]
	
	SELECT [Show Name] [Show], SUM([Nett Amount]) [Total Nett Amount] FROM #SalesByDate
	GROUP BY [Show Name]
	
	SELECT 'TOTAL NETT COLLECTED' [Show], SUM([Nett Amount]) [Total Nett Amount] FROM #SalesByDate
	
	DROP TABLE #SalesByDate
	
	DECLARE @fromDate VARCHAR(11)
	SELECT @fromDate = CONVERT(VARCHAR(11), DATEADD(D, -((DATEPART(WEEKDAY, @showDate) + 1 + @@DATEFIRST) % 7), @showDate), 106)

	SELECT * INTO #ShowSummaryByWeek FROM 
	(	
		SELECT S.ShowID, S.ShowTime, S.ScreenName, C.ClassName, C.ClassID, C.DCRID, S.DistributorMovieID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.ScreenName, C.ClassName, C.ClassID, C.DCRID, S.DistributorMovieID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
	) ShowSummaryByWeek
	
	SELECT * INTO #SeatSummaryByWeek FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByWeek) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowSummaryByWeek) AND SeatType <> 1
	) SeatSummaryByWeek
	
	SELECT
		ScreenName [Screen Name],
		CONVERT(VARCHAR(11), ShowTime, 106) [Day],
		Class [Class Name],
		TicketType,
		BTA [Nett Price],
		SUM(SeatsSold) [Total Tickets],
		SUM(PaidSeatsSold) * BTA [Nett Amount]
	INTO #SalesByWeek
	FROM
	(
	SELECT 
		Sh.ScreenName AS ScreenName, 
		Sh.Showtime AS ShowTime,
		Sh.ClassName AS Class,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		CASE WHEN S.StatusType IN (2,3) THEN COUNT(SeatId) ELSE 0 END AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatSummaryByWeek S1 WHERE S1.ClassID = S.ClassID AND S.SeatID = S1.SeatID AND S.PaymentType <> 5 AND StatusType IN (2,3)) AS PaidSeatsSold,
		(SELECT Expression FROM [Type] WHERE TypeName ='TicketType' AND Value = PC.TicketType) AS TicketType
	FROM
		#SeatSummaryByWeek S
		INNER JOIN #ShowSummaryByWeek Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
		INNER JOIN PriceCard PC ON PC.Id = S.PriceCardID
	WHERE
		PC.TicketType <> 2
	AND Sh.DCRID > 0
	GROUP BY Sh.ScreenName, Sh.ShowTime, Sh.ClassName, S.PaymentType, S.PriceCardId, S.ClassID, Sh.ClassID, S.SeatID, PC.TicketType, S.StatusType 
	) SalesByWeek
	GROUP BY ScreenName, ShowTime, Class, SeatsSold, BTA, TicketType
	
	SELECT CAST(DATENAME(DW,[Day]) AS VARCHAR) [Day], SUM([Nett Amount]) [Net Revenue Collected], SUM([Total Tickets]) [Total Tickets] FROM #SalesByWeek GROUP BY [Day]
	
	SELECT 'TOTAL NETT COLLECTED' [Day], SUM([Nett Amount]) [Net Revenue Collected], SUM([Total Tickets]) [Total Tickets] FROM #SalesByWeek
	
	SELECT ShowTax [Show Tax], INR, Publicity, Shuttling, PrintExpenses [Print Expenses], RepresentativeDearnessAllowance [Representative Dearness Allowance], BannerTax [Banner Tax], AdvertisementTax [Advertisement Tax], HealthCess [Health Cess], Others FROM DistributorMovieCollections WHERE Id IN (SELECT DistributorMovieID FROM #ShowSummaryByWeek)
	ORDER BY Id
	
	SELECT
		DistributorMovieID,
		COUNT(DISTINCT ShowID) AS [ShowCount],
		(SELECT SUM([Nett Amount]) FROM #SalesByWeek) AS [PaidSeats Net]
	FROM
		#ShowSummaryByWeek
	GROUP BY DistributorMovieID
	ORDER BY DistributorMovieID
		
	DROP TABLE #SeatSummaryByWeek
	DROP TABLE #ShowSummaryByWeek		
	DROP TABLE #SalesByWeek
	
END
GO

/* [FourWeeklyReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FourWeeklyReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FourWeeklyReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[FourWeeklyReport] 1, 0, '05 Dec 2015', '05 Dec 2015'

CREATE PROCEDURE [dbo].[FourWeeklyReport]
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ScreenName, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND IsCancel = 0 AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0 AND S.IsLocked = 1
		UNION ALL
		SELECT S.ShowID, S.ScreenName, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND IsCancel = 0 AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0 AND S.IsLocked = 1
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT
		FourWeeklyReport.ShowID,
		FourWeeklyReport.ScreenName,
		FourWeeklyReport.ClassName,
		FourWeeklyReport.[Class Capacity],
		FourWeeklyReport.BTA [Net Amount],
		FourWeeklyReport.ET [ET],
		FourWeeklyReport.CGST [CGST],
		FourWeeklyReport.SGST [SGST],
		FourWeeklyReport.PriceCardID,
		FourWeeklyReport.TicketType,
		SUM(FourWeeklyReport.DefenceSeatsSold) [No. of Defence Tickets],
		SUM(FourWeeklyReport.RegularSeatsSold) + SUM(FourWeeklyReport.ComplimentarySeatsSold) [No. of Others Tickets],
		SUM(FourWeeklyReport.FreeSeatsSold) [FreeSeatsSold],
		SUM(FourWeeklyReport.RegularSeatsSold) + SUM(FourWeeklyReport.DefenceSeatsSold) + SUM(FourWeeklyReport.ComplimentarySeatsSold) + SUM(FourWeeklyReport.FreeSeatsSold) [TOTAL ADMITS]
	INTO #FourWeeklyReport
	FROM
	(
	SELECT 
		Sh.ShowID,
		Sh.ScreenName,
		Sh.ClassName,
		CPC.PriceCardID,
		(SELECT TicketType FROM PriceCard WHERE Id = CPC.PriceCardId) TicketType,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.ShowID = Sh.ShowID AND Sh.ClassID = S1.ClassID) [Class Capacity],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE CPC.PriceCardID = PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE CPC.PriceCardID = PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE CPC.PriceCardID = PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE CPC.PriceCardID = PriceCardID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5 AND S1.PriceCardId = S.PriceCardID AND CPC.PriceCardID = S.PriceCardID AND S1.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 0)) AS RegularSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5 AND S1.PriceCardId = S.PriceCardID AND CPC.PriceCardID = S.PriceCardID AND S1.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 1)) AS DefenceSeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5 AND S1.PriceCardId = S.PriceCardID AND CPC.PriceCardID = S.PriceCardID AND S1.PriceCardId IN (SELECT Id FROM PriceCard WHERE TicketType = 2)) AS ComplimentarySeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType = 5 AND CPC.PriceCardID = S.PriceCardID AND S1.PriceCardId = S.PriceCardID) AS FreeSeatsSold
	FROM #SeatMasterByDate S 
	INNER JOIN #ShowMasterByDate Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	INNER JOIN ClassPriceCards CPC ON CPC.ClassID = Sh.ClassID
	GROUP BY Sh.ShowID, Sh.ScreenName, Sh.ClassID, Sh.ClassName, S.SeatID, S.PriceCardId, CPC.PriceCardID, CPC.ClassID
	) FourWeeklyReport
	GROUP BY ShowID, ScreenName, ClassName, [Class Capacity], ET, CGST, SGST, BTA, PriceCardID, TicketType

	SELECT
		ScreenName,
		ClassName [Class Name],
		[Class Capacity],
		[ET] [Entertainment Tax Per Ticket],
		[CGST] [CGST Per Ticket],
		[SGST] [SGST Per Ticket],
		SUM([No. of Defence Tickets]) [No. of Defence Tickets],
		SUM([No. of Others Tickets]) [No. of Others Tickets],
		SUM([TOTAL ADMITS]) [Total Admits],
		SUM([No. of Others Tickets]) * [ET] [E.Tax Collected],
		SUM([No. of Others Tickets]) * [CGST] [CGST Collected],
		SUM([No. of Others Tickets]) * [SGST] [SGST Collected]
	INTO #FourWeeklyReportFinal
	FROM #FourWeeklyReport
	GROUP BY ScreenName, ClassName,	[Class Capacity], [ET], [CGST], [SGST]

	SELECT * FROM #FourWeeklyReportFinal

	SELECT
		ShowID,
		ScreenName,
		ClassName [Class Name],
		[Class Capacity],
		AVG([ET]) [AverageET],
		AVG([CGST]) [AverageCGST],
		AVG([SGST]) [AverageSGST]
	INTO #AverageET
	FROM #FourWeeklyReport 
	WHERE TicketType <> 1
	GROUP BY ScreenName, ClassName,	[Class Capacity], ShowID
	
	SELECT
		CAST((SELECT COUNT(ShowID) FROM #ShowMasterByDate WHERE ScreenName = #FourWeeklyReportFinal.ScreenName AND ClassName = #FourWeeklyReportFinal.[Class Name]) AS VARCHAR) [Number of Shows],
		ScreenName,
		[Class Name],
		CAST([Class Capacity] AS VARCHAR) [Class Capacity],
		SUM([No. of Defence Tickets]) [No. of Defence Tickets],
		SUM([No. of Others Tickets]) [No. of Others Tickets],
		SUM([Total Admits]) [Total Admits],
		(SELECT COUNT(ShowID) FROM #ShowMasterByDate WHERE ScreenName = #FourWeeklyReportFinal.ScreenName AND ClassName = #FourWeeklyReportFinal.[Class Name]) * [Class Capacity] [Maximum Occupancy],
		CAST((SELECT SUM(AverageET) FROM #AverageET WHERE ScreenName = #FourWeeklyReportFinal.ScreenName AND [Class Name] = #FourWeeklyReportFinal.[Class Name]) * [Class Capacity] AS DECIMAL(18,2)) [Average Max Receivable E.Tax Revenue],
		SUM([E.Tax Collected]) [E.Tax Collected],
		CAST((SELECT SUM(AverageCGST) FROM #AverageET WHERE ScreenName = #FourWeeklyReportFinal.ScreenName AND [Class Name] = #FourWeeklyReportFinal.[Class Name]) * [Class Capacity] AS DECIMAL(18,2)) [Average Max Receivable CGST Revenue],
		SUM([CGST Collected]) [CGST Collected],
		CAST((SELECT SUM(AverageSGST) FROM #AverageET WHERE ScreenName = #FourWeeklyReportFinal.ScreenName AND [Class Name] = #FourWeeklyReportFinal.[Class Name]) * [Class Capacity] AS DECIMAL(18,2)) [Average Max Receivable SGST Revenue],
		SUM([SGST Collected]) [SGST Collected],
		CAST(SUM([TOTAL ADMITS]) * 100.00/((SELECT COUNT(ShowID) FROM #ShowMasterByDate WHERE ScreenName = #FourWeeklyReportFinal.ScreenName AND ClassName = #FourWeeklyReportFinal.[Class Name]) * [Class Capacity]) AS DECIMAL(18,2)) [OCCUPANCY %]
	INTO #FourWeeklyReportClassTotal
	FROM #FourWeeklyReportFinal
	GROUP BY ScreenName, [Class Name], [Class Capacity] 
	ORDER BY ScreenName, [Class Name]

	SELECT * FROM #FourWeeklyReportClassTotal ORDER BY ScreenName, [Class Name], [Number of Shows]
	
	SELECT '' [Number of Shows], '' ScreenName, '' [Class Name], 
	'' [Class Capacity],
	SUM([No. of Defence Tickets]) [No. of Defence Tickets],
	SUM([No. of Others Tickets]) [No. of Others Tickets],
	SUM([Total Admits]) [Total Admits], 
	SUM([Maximum Occupancy]) [Maximum Occupancy], 
	SUM([Average Max Receivable E.Tax Revenue]) [Average Max Receivable E.Tax Revenue],
	SUM([E.Tax Collected]) [E.Tax Collected],
	SUM([Average Max Receivable CGST Revenue]) [Average Max Receivable CGST Revenue],
	SUM([CGST Collected]) [CGST Collected],
	SUM([Average Max Receivable SGST Revenue]) [Average Max Receivable SGST Revenue],
	SUM([SGST Collected]) [SGST Collected],
	CAST(SUM([Total Admits]) * 100.00/SUM([Maximum Occupancy]) AS DECIMAL(18,2)) [OCCUPANCY %]
	FROM #FourWeeklyReportClassTotal 
	
	DROP TABLE #SeatMasterByDate
	DROP TABLE #ShowMasterByDate
	DROP TABLE #FourWeeklyReport
	DROP TABLE #FourWeeklyReportFinal
	DROP TABLE #FourWeeklyReportClassTotal
	DROP TABLE #AverageET
END
GO

/*[RollBackDCRCount]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RollBackDCRCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[RollBackDCRCount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RollBackDCRCount]
AS
BEGIN
	DECLARE @classMISId AS INT;
	DECLARE classMISCursor CURSOR
	LOCAL SCROLL STATIC
	FOR
	SELECT C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON S.ShowID = C.ShowID WHERE S.IsLocked = 1 AND C.DCRID > 0 AND (C.OpeningDCRNo <> 0 OR C.OpeningDCRNo IS NULL) AND S.IsHandoff = 0 AND S.IsCancel = 1 ORDER BY ShowTime;
	OPEN classMISCursor
	FETCH NEXT FROM classMISCursor
	INTO @classMISId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @DCRIDMIS AS INT;
		DECLARE @dcrOpenNoMIS AS INT;
		DECLARE @dcrCloseNoMIS AS INT;
		DECLARE @showTimeMIS DATETIME
		
		SELECT TOP 1 @showTimeMIS = ShowTime FROM ShowMIS WHERE ShowID IN (SELECT ShowID FROM ClassMIS WHERE ClassID = @classMISID)
		SELECT @DCRIDMIS = DCRID, @dcrOpenNoMIS = OpeningDCRNo, @dcrCloseNoMIS = ClosingDCRNo FROM ClassMIS WHERE ClassID = @classMISId
			
		IF (@dcrOpenNoMIS IS NOT NULL AND @dcrOpenNoMIS <> 0)
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION
				UPDATE Class SET OpeningDCRNo = NULL, ClosingDCRNo = NULL WHERE DCRID = @DCRIDMIS AND ShowID IN (SELECT ShowID FROM Show WHERE ShowTime >= @showTimeMIS)
				UPDATE ClassMIS SET OpeningDCRNo = NULL, ClosingDCRNo = NULL WHERE DCRID = @DCRIDMIS AND ShowID IN (SELECT ShowID FROM ShowMIS WHERE ShowTime >= @showTimeMIS)
				UPDATE DCR SET DCRCount = @dcrOpenNoMIS - 1 WHERE DCRID = @DCRIDMIS
				COMMIT
			END TRY
			BEGIN CATCH
				 IF @@TRANCOUNT > 0
					ROLLBACK
			END CATCH
		END
		ELSE
			UPDATE ClassMIS SET OpeningDCRNo = 0, ClosingDCRNo = 0 WHERE ClassID = @classMISId;
			
		FETCH NEXT FROM classMISCursor
		INTO @classMISId
	END
	CLOSE classMISCursor
	DEALLOCATE classMISCursor
	
	DECLARE @classId AS INT;
	DECLARE classCursor CURSOR
	LOCAL SCROLL STATIC
	FOR
	SELECT C.ClassID FROM Show S INNER JOIN Class C ON S.ShowID = C.ShowID WHERE S.IsLocked = 1 AND C.DCRID > 0 AND (C.OpeningDCRNo <> 0 OR C.OpeningDCRNo IS NULL) AND S.IsHandoff = 0 AND S.IsCancel = 1 ORDER BY ShowTime;
	OPEN classCursor
	FETCH NEXT FROM classCursor
	INTO @classId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @DCRID AS INT;
		DECLARE @dcrOpenNo AS INT;
		DECLARE @dcrCloseNo AS INT;
		DECLARE @dcrMAX AS INT;
		DECLARE @showTime DATETIME
		
		SELECT TOP 1 @showTime = ShowTime FROM Show WHERE ShowID IN (SELECT ShowID FROM Class WHERE ClassID = @classID)
			
		SELECT @DCRID = DCRID, @dcrOpenNo = OpeningDCRNo, @dcrCloseNo = ClosingDCRNo FROM Class WHERE ClassID = @classId
			
		IF (@dcrOpenNo IS NOT NULL AND @dcrOpenNo <> 0)
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION
				UPDATE Class SET OpeningDCRNo = NULL, ClosingDCRNo = NULL WHERE DCRID = @DCRID AND ShowID IN (SELECT ShowID FROM Show WHERE ShowTime >= @showTime)
				UPDATE DCR SET DCRCount = @dcrOpenNo - 1 WHERE DCRID = @DCRID
				COMMIT
			END TRY
			BEGIN CATCH
				 IF @@TRANCOUNT > 0
					ROLLBACK
			END CATCH
		END
		ELSE
			UPDATE Class SET OpeningDCRNo = 0, ClosingDCRNo = 0 WHERE ClassID = @classId;
			
		FETCH NEXT FROM classCursor
		INTO @classId
	END
	CLOSE classCursor
	DEALLOCATE classCursor
END
GO

/* [FormBReport] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FormBReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[FormBReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[FormBReport] 3, '06 Nov 2015', '02 Feb 2017', '09:00 AM'

CREATE PROCEDURE [dbo].[FormBReport]
	@screenId INT,
	@startDate NVARCHAR(11),
	@showDate NVARCHAR(11),
	@showTime NVARCHAR(8)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowName, S.MovieName, S.DistributorMovieID, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, ShowTime, 106) = CONVERT(DATETIME, CAST(@showDate + ' ' + @showTime AS DATETIME), 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowName, S.MovieName, S.DistributorMovieID, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, ShowTime, 106) = CONVERT(DATETIME, CAST(@showDate + ' ' + @showTime AS DATETIME), 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMaster
	
	SELECT
		SalesByDate.Class [Class],
		SalesByDate.ClassID,
		SalesByDate.TT [Ticket Type],
		SalesByDate.TA [Aggregate Value],
		SalesByDate.ET [ETax],
		SalesByDate.CGST CGST,
		SalesByDate.SGST SGST,
		SalesByDate.OpeningDCRNo [Opening No],
		SalesByDate.ClosingDCRNo [Closing No],
		SUM(SalesByDate.SeatsSold) [Total Tickets],
		SUM(SalesByDate.PaidSeatsSold) * SalesByDate.TA [Gross Amount],
		SUM(SalesByDate.PaidSeatsSold) * SalesByDate.ET [Total ETax Collected],
		SUM(SalesByDate.PaidSeatsSold) * SalesByDate.CGST [Total CGST Collected],
		SUM(SalesByDate.PaidSeatsSold) * SalesByDate.SGST [Total SGST Collected],
		SalesByDate.DCRID [DCRID],
		SalesByDate.ShowName [ShowName],
		SalesByDate.MovieName AS MovieName,
		SalesByDate.DistributorName AS DistributorName
	INTO #SalesByDate
	FROM
	(
	SELECT 
		Sh.ShowName ShowName,
		Sh.MovieName AS MovieName,
		(SELECT Name FROM Distributors WHERE Id = (SELECT DistributorID FROM DistributorMovieCollections WHERE Id = Sh.DistributorMovieID)) AS DistributorName,
		Sh.ClassName AS Class,
		Sh.ClassID As ClassID,
		Sh.OpeningDCRNo AS OpeningDCRNo,
		Sh.ClosingDCRNo AS ClosingDCRNo,
		(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT DISTINCT TicketType FROM PriceCard WHERE ID = CPC.PriceCardId) AND T.TypeName = 'TicketType') [TT],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = CPC.PriceCardID AND CPC.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = CPC.PriceCardID AND CPC.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = CPC.PriceCardID AND CPC.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = CPC.PriceCardID AND CPC.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = CPC.PriceCardID AND CPC.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = CPC.ClassID AND S1.PriceCardId = CPC.PriceCardID AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = CPC.ClassID AND S1.PriceCardId = CPC.PriceCardID AND S1.StatusType IN (2,3) AND S.PaymentType <> 5) AS PaidSeatsSold,
		Sh.DCRID
	FROM #SeatMasterByDate S INNER JOIN #ShowMasterByDate Sh ON Sh.ClassID = S.ClassID
	INNER JOIN ClassPriceCards CPC ON CPC.ClassID = Sh.ClassID
	GROUP BY Sh.ClassName, Sh.ShowName, sh.MovieName, S.PriceCardId, S.ClassID, Sh.ClassID, Sh.OpeningDCRNo, Sh.ClosingDCRNo, S.PaymentType, S.SeatID, 
	Sh.DCRID, Sh.DistributorMovieID, CPC.PriceCardID, CPC.ClassID
	) SalesByDate
	GROUP BY Class, ClassID, TA, ET, CGST, SGST, TT, OpeningDCRNo, ClosingDCRNo, DCRID, ShowName, MovieName, DistributorName
	
	SELECT
		[Class], [Ticket Type], [Aggregate Value], [ETax], CGST, SGST, [Opening No], [Closing No], [Total Tickets], [Gross Amount], [Total ETax Collected], [Total CGST Collected], [Total SGST Collected], '' [Other],
		DCRID, (SELECT DCRStartingNo FROM DCR WHERE DCR.DCRID = #SalesByDate.DCRID) AS DCRStartingNo, (SELECT DCRMax FROM DCR WHERE DCR.DCRID = #SalesByDate.DCRID) AS DCRMax, ShowName, MovieName, DistributorName
	FROM #SalesByDate
	ORDER BY ClassID
	
	SELECT
		'Today Total' [Class], '' [Ticket Type], NULL [Aggregate Value], NULL [ETax], NULL CGST, NULL SGST, NULL [Opening No], NULL [Closing No], SUM([Total Tickets]) [Total Tickets], 
		SUM([Gross Amount]) [Gross Amount], SUM([Total ETax Collected]) [Total ETax Collected], SUM([Total CGST Collected]) [Total CGST Collected], 
		SUM([Total SGST Collected]) [Total SGST Collected], '' [Other]
	FROM #SalesByDate
	
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT S.ShowID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, ShowTime, 106) < CONVERT(DATETIME, CAST(@showDate + ' ' + @showTime AS DATETIME), 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, ShowTime, 106) < CONVERT(DATETIME, CAST(@showDate + ' ' + @showTime AS DATETIME), 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT SeatID, PriceCardId, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
		UNION ALL
		SELECT SeatID, PriceCardId, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
	) SeatMaster
	
	SELECT
		'Previous Total' [Class], '' [Ticket Type], NULL [Aggregate Value], NULL [ETax], NULL CGST, NULL SGST, NULL [Opening No], NULL [Closing No],
		ISNULL(SUM([Total Tickets]), 0) [Total Tickets],
		ISNULL(SUM([Gross Amount]), 0) [Gross Amount],
		ISNULL(SUM([Total ETax Collected]), 0) [Total ETax Collected],
		ISNULL(SUM([Total CGST Collected]), 0) [Total CGST Collected],
		ISNULL(SUM([Total SGST Collected]), 0) [Total SGST Collected],
		'' [Other]
	FROM
	(
		SELECT
			SUM(Sales.SeatsSold) [Total Tickets],
			SUM(Sales.PaidSeatsSold) * Sales.TA [Gross Amount],
			SUM(Sales.PaidSeatsSold) * Sales.ET [Total ETax Collected],
			SUM(Sales.PaidSeatsSold) * Sales.CGST [Total CGST Collected],
			SUM(Sales.PaidSeatsSold) * Sales.SGST [Total SGST Collected]
		FROM
		(
			SELECT 
				ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Ticket_Amount'), 0) - 
				ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
				ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
				ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'CGST'), 0) AS CGST,
				ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND Code = 'SGST'), 0) AS SGST,
				(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3)) AS SeatsSold,
				(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S.SeatID = S1.SeatID AND S1.StatusType IN (2,3) AND S.PaymentType <> 5) AS PaidSeatsSold
			FROM #SeatMaster S
			GROUP BY S.PriceCardId, S.PaymentType, S.SeatID
		) Sales
		GROUP BY TA, ET, CGST, SGST
	) FinalSales

	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip FROM Complex WHERE ComplexID = (SELECT ComplexID FROM Screen WHERE ScreenID = @screenId)

	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster
	UNION SELECT PriceCardID FROM #SeatMasterByDate))
	
	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate
	DROP TABLE #SalesByDate
	DROP TABLE #ShowMaster
	DROP TABLE #SeatMaster
END
GO

/* [Form3BReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Form3BReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Form3BReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[Form3BReport] 1, 1, '06 Feb 2017', '10 Dec 2017'
CREATE PROCEDURE [dbo].[Form3BReport]
	@theatreId INT,
	@screenId INT,
	@startDate NVARCHAR(11),
	@endDate NVARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowTime, UPPER(S.ShowName) ShowName, S.ScreenName, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, UPPER(S.ShowName) ShowName, S.ScreenName, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @endDate), 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType, ClassID, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType, ClassID, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT
		ShowName, ScreenName, ClassName, TT, TA, ET, CGST, SGST, SUM(SeatsSold) AS SeatsSold, SUM(PaidSeatsSold) PaidSeatsSold
	INTO #Form3BReport
	FROM
	(
	SELECT
		Sh.ShowName,
		Sh.ScreenName,
		Sh.ShowID,
		Sh.ShowTime,
		Sh.ClassName,
		(SELECT T.Expression FROM [Type] T WHERE T.Value IN (SELECT TicketType FROM PriceCard WHERE ID = S.PriceCardID) AND T.TypeName = 'TicketType') AS [TT],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Ticket_Amount_Discount'), 0) AS TA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.StatusType IN (2,3) AND S1.PaymentType <> 5) PaidSeatsSold
	FROM
		#ShowMasterByDate Sh INNER JOIN #SeatMasterByDate S ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID 
	GROUP BY
		Sh.ShowName, Sh.ShowID, S.ClassID, Sh.ClassID, Sh.ShowTime, Sh.ClassName, Sh.ScreenName, S.PriceCardId, S.SeatID
	) FR
	GROUP BY ShowName, ScreenName, ClassName, TT, TA, ET, CGST, SGST
	ORDER BY ShowName
	
	DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX);

	SET @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(ShowName) 
            FROM #Form3BReport
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
    
	SET @query = 
	N'SELECT * FROM(
	SELECT ShowName, ScreenName, ClassName, TT, TA, ET, CGST, SGST,
	ISNULL(SUM(SeatsSold), 0) AS SeatsSold
	FROM #Form3BReport 
	GROUP BY ShowName, ScreenName, ClassName, TT, TA, ET, CGST, SGST) AS p
	PIVOT
	(SUM(SeatsSold) FOR ShowName IN (' + @cols + ')) AS PVTTable ORDER BY ClassName, TT DESC'

	EXEC sp_executesql @query
	
	SELECT
		ShowName, ScreenName, ClassName, TT, TA, ET, CGST, SGST, SUM(SeatsSold) AS SeatsSold,  SUM(PaidSeatsSold) * ET AS TotalET, SUM(PaidSeatsSold) * CGST AS TotalCGST, SUM(PaidSeatsSold) * SGST AS TotalSGST
	FROM
		#Form3BReport
	GROUP BY
		ShowName, ScreenName, ClassName, TT, TA, ET, CGST, SGST
	
	SELECT ShowName, SUM(SeatsSold) AS SeatsSold FROM #Form3BReport GROUP BY ShowName
	
	SELECT ShowName FROM #ShowMasterByDate GROUP BY ShowTime, ShowName ORDER BY ShowTime, ShowName

	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip, ComplexPhone FROM Complex WHERE ComplexID = @theatreId

	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMasterByDate))
	
	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate
	DROP TABLE #Form3BReport
END
GO

/* [Form17Report] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Form17Report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[Form17Report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[Form17Report] 1, '08 Jul 2017', '11 Jul 2017'

CREATE PROCEDURE [dbo].[Form17Report]
	@screenId INT,
	@startDate NVARCHAR(11),
	@showDate NVARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, S.ShowTime, S.ShowName, S.MovieName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.ShowName, S.MovieName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) = CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMaster
	
	SELECT
		SalesByDate.ShowTime,
		SalesByDate.TimeInHour,
		SalesByDate.Class,
		(SalesByDate.BTA + SalesByDate.ET + SalesByDate.CGST + SalesByDate.SGST) Base,
		SalesByDate.SC,
		(SalesByDate.BTA + SalesByDate.ET + SalesByDate.SC + SalesByDate.CGST + SalesByDate.SGST) Rate,
		SalesByDate.OpeningDCRNo [OpeningNo],
		SalesByDate.ClosingDCRNo [ClosingNo],
		((SalesByDate.BTA + SalesByDate.ET + SalesByDate.CGST + SalesByDate.SGST) * SUM(SalesByDate.PaidSeatsSold)) Gross,
		ROUND(CAST(ISNULL(SalesByDate.ET * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalET,
		ROUND(CAST(ISNULL(SalesByDate.CGST * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalCGST,
		ROUND(CAST(ISNULL(SalesByDate.SGST * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalSGST,
		(SalesByDate.SC * SUM(SalesByDate.PaidSeatsSold)) TotalSC,
		ROUND(CAST(ISNULL(SalesByDate.CGSTThreeD * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalCGSTThreeD,
		ROUND(CAST(ISNULL(SalesByDate.SGSTThreeD * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalSGSTThreeD,
		(SalesByDate.ThreeD * SUM(SalesByDate.PaidSeatsSold)) TotalThreeD,
		SUM(SalesByDate.SeatsSold) SeatsSold,
		SalesByDate.ShowName [ShowName],
		SalesByDate.MovieName AS MovieName,
		SalesByDate.DCRID [DCRID],
		(SELECT DCRStartingNo FROM DCR WHERE DCR.DCRID = SalesByDate.DCRID) AS DCRStartingNo, 
		(SELECT DCRMax FROM DCR WHERE DCR.DCRID = SalesByDate.DCRID) AS DCRMax
		INTO #ShowDateData
	FROM
	(
	SELECT
		SUBSTRING(CAST(Sh.ShowTime AS VARCHAR), 12, 20) ShowTime,
		convert(varchar(2), ShowTime, 108) TimeInHour,
		Sh.ShowName ShowName,
		Sh.MovieName AS MovieName,
		Sh.ClassName AS Class,
		Sh.OpeningDCRNo AS OpeningDCRNo,
		Sh.ClosingDCRNo AS ClosingDCRNo,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Service_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS ThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST_3D_Glass'), 0) AS CGSTThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST_3D_Glass'), 0) AS SGSTThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_3D_Glass_Fee'), 0) AS BaseThreeD,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.PaymentType <> 5 AND S1.StatusType IN (2,3)) AS PaidSeatsSold,
		Sh.DCRID
	FROM #SeatMasterByDate S INNER JOIN #ShowMasterByDate Sh ON Sh.ClassID = S.ClassID
	GROUP BY Sh.ClassName, Sh.ShowName, Sh.ShowTime, Sh.MovieName, S.PriceCardId, S.ClassID, Sh.ClassID, Sh.OpeningDCRNo, Sh.ClosingDCRNo, S.PaymentType, S.SeatID, 
	Sh.DCRID
	) SalesByDate
	GROUP BY Class, ET, CGST, SGST, SC, BTA, ThreeD, CGSTThreeD, SGSTThreeD, OpeningDCRNo, ClosingDCRNo, DCRID, ShowName, MovieName, ShowTime, TimeInHour
	ORDER BY ShowTime
	
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, @showDate, 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT SeatID, ClassID, PriceCardId, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
		UNION ALL
		SELECT SeatID, ClassID, PriceCardId, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
	) SeatMaster
	
	SELECT
		P.Class,
		(P.BTA + P.ET + P.CGST + P.SGST) Base,
		P.SC,
		(P.BTA + P.ET + P.SC + P.CGST + P.SGST) Rate,
		((P.BTA + P.ET + P.CGST + P.SGST) * SUM(P.PaidSeatsSold)) Gross,
		ROUND(CAST(ISNULL(P.ET * SUM(P.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalET,
		ROUND(CAST(ISNULL(P.CGST * SUM(P.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalCGST,
		ROUND(CAST(ISNULL(P.SGST * SUM(P.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalSGST,
		(P.SC * SUM(P.PaidSeatsSold)) TotalSC,
		(P.ThreeD * SUM(P.PaidSeatsSold)) TotalThreeD,
		ROUND(CAST(ISNULL(P.CGSTThreeD * SUM(P.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalCGSTThreeD,
		ROUND(CAST(ISNULL(P.SGSTThreeD * SUM(P.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalSGSTThreeD,
		SUM(P.SeatsSold) SeatsSold
		INTO #PreviousTotal
	FROM
	(
	SELECT
		Sh.ClassName AS Class,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Service_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses'), 0) - 
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardID = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = '3D_Glasses_Discount'), 0) AS ThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST_3D_Glass'), 0) AS CGSTThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST_3D_Glass'), 0) AS SGSTThreeD,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_3D_Glass_Fee'), 0) AS BaseThreeD,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.PaymentType <> 5 AND S1.StatusType IN (2,3)) AS PaidSeatsSold
	FROM #SeatMaster S INNER JOIN #ShowMaster Sh ON Sh.ClassID = S.ClassID
	GROUP BY Sh.ClassName, S.PriceCardId, S.ClassID, Sh.ClassID, S.PaymentType, S.SeatID
	) P
	GROUP BY Class, ET, CGST, SGST, SC, BTA, ThreeD, CGSTThreeD, SGSTThreeD
	
	SELECT * FROM #ShowDateData
	
	SELECT Class, SC, Base, SUM(SeatsSold) TotalSeatsSold, SUM(Gross) TotalGross, SUM(TotalET) TotalET, SUM(TotalCGST) TotalCGST, SUM(TotalSGST) TotalSGST, SUM(TotalSC) TotalSC, 
	SUM(TotalThreeD) TotalThreeD, SUM(TotalCGSTThreeD) TotalCGSTThreeD, SUM(TotalSGSTThreeD) TotalSGSTThreeD
	FROM #ShowDateData GROUP BY Class, SC, Base
	
	SELECT Class, SUM(SeatsSold) TotalSeatsSold, SUM(Gross) TotalGross, SUM(TotalET) TotalET, SUM(TotalCGST) TotalCGST, SUM(TotalSGST) TotalSGST, SUM(TotalSC) TotalSC, 
	SUM(TotalThreeD) TotalThreeD
	, SUM(TotalCGSTThreeD) TotalCGSTThreeD, SUM(TotalSGSTThreeD) TotalSGSTThreeD
	INTO #TotalShowDateData FROM #ShowDateData GROUP BY Class
	
	SELECT Class, SUM(SeatsSold) TotalSeatsSold, SUM(Gross) TotalGross, SUM(TotalET) TotalET, SUM(TotalCGST) TotalCGST, SUM(TotalSGST) TotalSGST, SUM(TotalSC) TotalSC, 
	SUM(TotalThreeD) TotalThreeD, SUM(TotalCGSTThreeD) TotalCGSTThreeD, SUM(TotalSGSTThreeD) TotalSGSTThreeD 
	INTO #TotalPreviousData FROM #PreviousTotal GROUP BY Class
	
	DROP TABLE #ShowDateData
	DROP TABLE #PreviousTotal

	SELECT * FROM #TotalPreviousData

	SELECT ISNULL(SD.Class, PD.Class) Class, (ISNULL(SD.TotalSeatsSold, 0) + ISNULL(PD.TotalSeatsSold, 0)) TotalSeatsSold, 
	(ISNULL(SD.TotalGross, 0) + ISNULL(PD.TotalGross, 0)) TotalGross, 
	(ISNULL(SD.TotalET, 0) + ISNULL(PD.TotalET, 0)) TotalET,
	(ISNULL(SD.TotalCGST, 0) + ISNULL(PD.TotalCGST, 0)) TotalCGST,
	(ISNULL(SD.TotalSGST, 0) + ISNULL(PD.TotalSGST, 0)) TotalSGST,
	(ISNULL(SD.TotalSC, 0) + ISNULL(PD.TotalSC, 0)) TotalSC, 
	(ISNULL(SD.TotalThreeD, 0) + ISNULL(PD.TotalThreeD, 0)) TotalThreeD,
	(ISNULL(SD.TotalCGSTThreeD, 0) + ISNULL(PD.TotalCGSTThreeD, 0)) TotalCGSTThreeD,
	(ISNULL(SD.TotalSGSTThreeD, 0) + ISNULL(PD.TotalSGSTThreeD, 0)) TotalSGSTThreeD FROM 
	#TotalShowDateData SD FULL OUTER JOIN #TotalPreviousData PD ON SD.Class = PD.Class

	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip FROM Complex WHERE ComplexID = (SELECT ComplexID FROM Screen WHERE ScreenID = @screenId)

	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster
	UNION SELECT PriceCardID FROM #SeatMasterByDate))

	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate
	DROP TABLE #ShowMaster
	DROP TABLE #SeatMaster
	DROP TABLE #TotalShowDateData
	DROP TABLE #TotalPreviousData
	
END
GO

/* [Form3Report] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Form3Report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[Form3Report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[Form3Report] 1, '06 Nov 2015', '10 Dec 2015'

CREATE PROCEDURE [dbo].[Form3Report]
	@screenId INT,
	@fromDate NVARCHAR(11),
	@toDate NVARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @toDate, 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @toDate, 106) AND S.ScreenID = @screenId AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1 AND StatusType IN (2, 3)
		UNION ALL
		SELECT SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1 AND StatusType IN (2, 3)
	) SeatMaster
	
	SELECT
		SalesByDate.Class,
		(SalesByDate.ET + SalesByDate.CGST + SalesByDate.SGST + SalesByDate.BTA) Rate,
		((SalesByDate.ET + SalesByDate.CGST + SalesByDate.SGST + SalesByDate.BTA) * SUM(SalesByDate.PaidSeatsSold)) TotalRate,
		ROUND(CAST(ISNULL(SalesByDate.ET * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalET,
		ROUND(CAST(ISNULL(SalesByDate.CGST * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalCGST,
		ROUND(CAST(ISNULL(SalesByDate.SGST * SUM(SalesByDate.PaidSeatsSold), 0) AS NUMERIC(9, 2)), 2) TotalSGST,
		SUM(SalesByDate.SeatsSold) SeatsSold
	FROM
	(
	SELECT
		Sh.ClassName AS Class,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.SeatID = S.SeatID AND S1.ClassID = S.ClassID AND S.PriceCardId = S1.PriceCardId AND S1.PaymentType <> 5 AND S1.StatusType IN (2,3)) AS PaidSeatsSold
	FROM #SeatMaster S INNER JOIN #ShowMaster Sh ON Sh.ClassID = S.ClassID
	GROUP BY Sh.ClassName, S.PriceCardId, S.ClassID, Sh.ClassID, S.PaymentType, S.SeatID
	) SalesByDate
	GROUP BY Class, ET, CGST, SGST, BTA
	ORDER BY Class

	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster))
	
	DROP TABLE #ShowMaster
	DROP TABLE #SeatMaster
END
GO

/* spUnpaidBook */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spUnpaidBook]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spUnpaidBook]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- spunpaidbook 0, '147187,147188', 'F6139993|bsridhar@realimage.com|9994067232|Sridhar||', 120, 1, '2017-03-13 20:03:14.190', '7365b385-6875-40d6-9f40-735be61b4ba1', 'F6139993', 'Sridhar', 'bsridhar@realimage.com', 9994067232

CREATE PROCEDURE [dbo].[spUnpaidBook]
	@TicketID INT OUTPUT,
	@SeatIDs VARCHAR(256),
	@PatronInfo VARCHAR(256),
	@ReleaseBefore INT,
	@LastSoldByID INT,
	@OnlineShowId NVARCHAR(64),
	@BookingCode NVARCHAR(8),
	@UserName NVARCHAR(256),
	@EmailId NVARCHAR(256),
	@MobileNumber BIGINT
AS
BEGIN
	DECLARE @TmpTicketID INT
	DECLARE @actualRows INT = 0
	DECLARE @LastSoldOn DATETIME = GETDATE()
	
	IF EXISTS(SELECT OnlineShowId FROM UnpaidBookings WHERE OnlineShowId = @OnlineShowId AND BookingCode = @BookingCode)
		GOTO ERR_HANDLER

	SET @TmpTicketID = 0
	SELECT @TmpTicketID = MIN(Seat.SeatID), @actualRows = COUNT(SeatID) FROM Seat WHERE SeatID IN (select * from dbo.fnsplit(@SeatIDs, ','))

	IF @@ERROR <> 0 OR @@ROWCOUNT = 0 OR @TmpTicketID = 0 GOTO ERR_HANDLER

	UPDATE Seat SET TicketID = CAST(@TmpTicketID AS VARCHAR(10)), StatusType = 6, PatronInfo = @PatronInfo, ReleaseBefore = CAST(@ReleaseBefore AS VARCHAR(10)) 
	WHERE SeatID IN (select * from dbo.fnsplit(@SeatIDs, ',')) AND StatusType = 0 AND Seat.QuotaType <> 3
	IF @@ERROR <> 0 OR @actualRows <> @@ROWCOUNT GOTO ERR_HANDLER

	SET @TicketID = @TmpTicketID
	
	INSERT INTO UnpaidBookings (ShowId, SeatId, OnlineShowId, SeatClassInfo, BookingCode, UserName, EmailId, MobileNumber, ReleaseTime, BookedByID, BookedOn) 
		SELECT ShowID, SeatID, @OnlineShowId, SeatClassInfo, @BookingCode, @UserName, @EmailId, CAST(@MobileNumber AS VARCHAR(10)), CAST(@ReleaseBefore AS VARCHAR(10)), 
		CAST(@LastSoldByID AS VARCHAR(10)), CONVERT(VARCHAR(24), @LastSoldOn, 113) FROM Seat WHERE SeatID IN (select * from dbo.fnsplit(@SeatIDs, ','))
	IF @@ERROR <> 0 OR @actualRows <> @@ROWCOUNT GOTO ERR_HANDLER
	RETURN

	ERR_HANDLER:
	RAISERROR('CONCURRENTFAIL', 11, 1)
	RETURN

END
GO

/* GetUnpaidBookings */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetUnpaidBookings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetUnpaidBookings]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- GetUnpaidBookings
CREATE PROCEDURE [dbo].[GetUnpaidBookings]
AS
BEGIN
	SELECT DISTINCT OnlineShowId, STUFF((SELECT ',' + SeatClassInfo FROM UnpaidBookings WHERE OnlineShowId = A.OnlineShowId AND BookingCode = A.BookingCode FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'') , BookingCode, UserName, ISNULL(EmailId, ''), MobileNumber, ReleaseTime FROM UnpaidBookings A WHERE IsSent = 0
END
GO

/*[UpdateOnlinePauseResume]*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateOnlinePauseResume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateOnlinePauseResume
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].UpdateOnlinePauseResume
	@ShowID INT,
	@IsPaused BIT
AS
BEGIN
	UPDATE Show SET IsOnlinePaused = IsPaused WHERE ShowID = @ShowID AND IsPaused = @IsPaused
END
GO

/* [UpdateOnlineEditStatus] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateOnlineEditStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].UpdateOnlineEditStatus
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].UpdateOnlineEditStatus
	@id UNIQUEIDENTIFIER,
	@showID INT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		DELETE FROM ShowSyncJobs WHERE Id = @id AND ShowID = @showID AND [Status] = 1

		IF NOT EXISTS(SELECT Id FROM ShowSyncJobs WHERE ShowID = @showID)
			UPDATE Show SET IsOnlineEdit = 1 WHERE ShowID = @showID
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT>0)
			ROLLBACK
	END CATCH	

END
GO

/* [FourWeeklyPercentageReport] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FourWeeklyPercentageReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[FourWeeklyPercentageReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[FourWeeklyPercentageReport] 4, '20 Mar 2017', '30 Mar 2017'

CREATE PROCEDURE [dbo].[FourWeeklyPercentageReport]
	@screenId INT,
	@fromDate NVARCHAR(11),
	@toDate NVARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID, C.ClassName, C.ClassID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID INNER JOIN Seat SE ON SE.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106) AND S.ScreenID = @screenId AND S.IsCancel = 0 AND S.IsLocked = 1 AND SE.StatusType = 2
		UNION ALL
		SELECT S.ShowID, C.ClassName, C.ClassID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID INNER JOIN SeatMIS SE ON SE.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106) AND S.ScreenID = @screenId AND S.IsCancel = 0 AND S.IsLocked = 1 AND SE.StatusType = 2
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT SeatID, ShowID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
		UNION ALL
		SELECT SeatID, ShowID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1
	) SeatMasterByDate
	
	SELECT B.[Ticket Rate], B.[Show Count], B.ClassName, B.[Class Capacity], B.ETSC, SUM(B.[SeatsSold]) [SeatsSold] INTO #FourWeeklyPercentageReport
	FROM
	(SELECT 
		A.[Ticket Rate],
		A.[Show Count],
		A.ClassName,
		A.[Class Capacity],
		(A.ET + A.SC + A.CGST + A.SGST) ETSC,		
		SUM(A.PaidSeatsSold) [SeatsSold],
		A.PriceCardId			
	FROM
	(
	SELECT
		(SELECT Amount FROM PriceCard WHERE Id = S.PriceCardId) [Ticket Rate],
		(SELECT COUNT(DISTINCT S1.ShowID) FROM #ShowMasterByDate S1) [Show Count],
		Sh.ClassName,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.ShowID = Sh.ShowID AND Sh.ClassID = S1.ClassID) [Class Capacity],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE S.PriceCardID = PriceCardID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE S.PriceCardID = PriceCardID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE S.PriceCardID = PriceCardID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE S.PriceCardID = PriceCardID AND Code = 'Service_Charge'), 0) AS SC,
		(SELECT COUNT(S1.SeatId) FROM #SeatMasterByDate S1 WHERE S1.ClassID = S.ClassID AND S.SeatId = S1.SeatId AND S1.PaymentType <> 5 AND S1.StatusType IN (2,3)) AS PaidSeatsSold,
		S.PriceCardId
	FROM #SeatMasterByDate S 
	INNER JOIN #ShowMasterByDate Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY Sh.ClassName, S.PriceCardId, S.ClassID, Sh.ClassID, Sh.ShowID, S.PaymentType, S.SeatID
	)A
	GROUP BY [Ticket Rate], [Show Count], ClassName, [Class Capacity], ET, SC, CGST, SGST, PaidSeatsSold, PriceCardId
	)B
	GROUP BY [Ticket Rate], [Show Count], ClassName, [Class Capacity], ETSC
	
	SELECT
		*,
		[Show Count] * [Class Capacity] * ETSC [Max Tax Revenue],
		ETSC * [SeatsSold] [Actual ETSC],
		CAST((CASE WHEN ETSC <> 0 THEN ETSC * [SeatsSold] * 100.00 / ([Show Count] * [Class Capacity] * ETSC) ELSE 0 END) AS DECIMAL(16,2))  [Full House %],
		[Show Count] * [Class Capacity] [Total Capacity],
		CAST(([SeatsSold] * 100.00 / ([Show Count] * [Class Capacity])) AS DECIMAL(16,2)) [Occupancy %]
	FROM #FourWeeklyPercentageReport

	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate	
	DROP TABLE #FourWeeklyPercentageReport	
END
GO

/* [EastMarketReport] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[EastMarketReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[EastMarketReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[EastMarketReport] 1, '05 Sep 2016', '30 Jun 2017', 1, 'Madras'
CREATE PROCEDURE [dbo].[EastMarketReport]
	@screenId INT,
	@fromDate NVARCHAR(11),
	@toDate NVARCHAR(11),
	@distributorId INT,
	@movieName NVARCHAR(256)
AS
BEGIN
	SELECT * INTO #ShowMaster FROM 
	(
		SELECT S.ShowID, S.ShowTime, S.ShowName, S.MovieName, (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = S.MovieLanguageType) AS MovieLanguage, S.ScreenName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM Show S INNER JOIN Class C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106) AND S.ScreenID = @screenId AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
		UNION ALL
		SELECT S.ShowID, S.ShowTime, S.ShowName, S.MovieName, (SELECT Expression FROM [Type] WHERE TypeName = 'MovieLanguageType' AND Value = S.MovieLanguageType) AS MovieLanguage, S.ScreenName, C.ClassName, C.ClassID, C.OpeningDCRNo, C.ClosingDCRNo, C.DCRID FROM ShowMIS S INNER JOIN ClassMIS C ON C.ShowID = S.ShowID WHERE C.DCRID > 0 AND IsLocked = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106) AND S.ScreenID = @screenId AND S.DistributorMovieID IN (SELECT Id FROM DistributorMovieCollections WHERE DistributorID = @distributorId) AND S.MovieName = @movieName AND S.IsCancel = 0
	) ShowMaster
	
	SELECT * INTO #SeatMaster FROM
	(
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, ClassID, PaymentType, StatusType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMaster) AND SeatType <> 1
	) SeatMaster
	
	SELECT
	Report.ScreenName [Screen Name],
	Report.ShowName	[Show Name],
	Report.MovieName [Movie Name],
	Report.MovieLanguage [Language],
	Report.Class [Class Name],
	Report.OpeningDCRNo [OpeningNo],
	Report.ClosingDCRNo [ClosingNo],
	Report.[Class Capacity] [Class Capacity],
	SUM(Report.SeatsSold) [SeatsSold],
	Report.ET [ET],
	Report.CGST [CGST],
	Report.SGST [SGST],
	Report.SC [SC],
	Report.BTA [BTA],
	SUM(Report.PaidSeatsSold) * Report.ET [ETax Total],
	SUM(Report.PaidSeatsSold) * Report.CGST [CGST Total],
	SUM(Report.PaidSeatsSold) * Report.SGST [SGST Total],
	SUM(Report.PaidSeatsSold) * Report.SC [SC Total],
	SUM(Report.PaidSeatsSold) * Report.BTA [Net],
	Report.DCRID [DCRID],
	(SELECT DCRStartingNo FROM DCR WHERE DCR.DCRID = Report.DCRID) AS DCRStartingNo, 
	(SELECT DCRMax FROM DCR WHERE DCR.DCRID = Report.DCRID) AS DCRMax
	INTO #Report
	FROM
	(
	SELECT 
		Sh.ScreenName AS ScreenName, 
		Sh.Showtime AS ShowTime,
		Sh.ShowName AS ShowName,
		Sh.MovieName AS MovieName,
		Sh.MovieLanguage AS MovieLanguage,
		Sh.ClassName AS Class,
		Sh.OpeningDCRNo AS OpeningDCRNo,
		Sh.ClosingDCRNo AS ClosingDCRNo,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.ShowID = Sh.ShowID AND Sh.ClassID = S1.ClassID) [Class Capacity],
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Entertainment_Tax'), 0) AS ET,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'CGST'), 0) AS CGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'SGST'), 0) AS SGST,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Service_Charge'), 0) AS SC,
		ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.ClassID = Sh.ClassID AND Code = 'Base_Ticket_Amount'), 0) AS BTA,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.ClassID = S.ClassID AND S1.SeatID = S.SeatID AND S1.StatusType IN (2,3)) AS SeatsSold,
		(SELECT COUNT(S1.SeatId) FROM #SeatMaster S1 WHERE S1.ClassID = S.ClassID AND S1.SeatID = S.SeatID AND S1.PaymentType <> 5 AND S1.StatusType IN (2,3)) AS PaidSeatsSold,
		Sh.DCRID
	FROM #SeatMaster S INNER JOIN #ShowMaster Sh ON Sh.ShowID = S.ShowID AND Sh.ClassID = S.ClassID
	GROUP BY Sh.ClassName, Sh.ShowName, Sh.ShowTime, Sh.MovieName, S.PriceCardId, S.ClassID, Sh.ClassID, Sh.ShowID, Sh.OpeningDCRNo, Sh.ClosingDCRNo, S.PaymentType, S.SeatID, Sh.ScreenName, Sh.MovieLanguage, Sh.DCRID
	) Report
	GROUP BY ScreenName, Class, ShowTime, ShowName, MovieName, MovieLanguage, ET, CGST, SGST, SC, SeatsSold, [Class Capacity], BTA, OpeningDCRNo, ClosingDCRNo, DCRID
	
	SELECT
		[Screen Name], [Show Name], [Movie Name], [Language], [Class Name], [OpeningNo],
		[ClosingNo], SUM([SeatsSold]) [SeatsSold], SUM([ET]) [ET], SUM([CGST]) [CGST], SUM([SGST]) [SGST], SUM([SC]) [SC], SUM([ETax Total]) [ETax Total],
		SUM([CGST Total]) [CGST Total], SUM([SGST Total]) [SGST Total], SUM([SC Total]) [SC Total], [DCRID], DCRStartingNo, DCRMax
	FROM #Report
	GROUP BY
		[Screen Name], [Show Name], [Movie Name], [Language], [Class Name], [OpeningNo], [ClosingNo], [DCRID], DCRStartingNo, DCRMax
	
	SELECT (SUM([ETax Total]) + SUM([CGST Total]) + SUM([SGST Total])) [TotalTax] FROM #Report
	
	SELECT [Class Name], [BTA], [Class Capacity], SUM([SeatsSold]) [SeatsSold] FROM #Report
	GROUP BY [Class Name], [BTA], [Class Capacity]
	
	SELECT SUM([SeatsSold]) [SeatsSold], SUM([SC Total]) [SC Total] FROM #Report
	
	SELECT
		[Class Name], [ET], [CGST], [SGST], SUM([ETax Total]) [ETax Total], SUM([CGST Total]) [CGST Total], SUM([SGST Total]) [SGST Total], [SC], SUM([SC Total]) [SC Total]
	FROM #Report
	GROUP BY
		[Class Name], [ET], [CGST], [SGST], [SC]
		
	SELECT ComplexName, ComplexAddress1, ComplexAddress2, ComplexCity, ComplexState, ComplexZip, ComplexPhone FROM Complex WHERE ComplexID = (SELECT ComplexID FROM Screen WHERE ScreenID = @screenId)
	
	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMaster))
		
	DROP TABLE #ShowMaster
	DROP TABLE #SeatMaster
	DROP TABLE #Report
	
END
GO

/* [MunicipalTaxReport] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[MunicipalTaxReport]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[MunicipalTaxReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[MunicipalTaxReport] 1, 0, '01 Mar 2017', '30 Mar 2017'

CREATE PROCEDURE [dbo].[MunicipalTaxReport]
	@theatreId INT,
	@screenId INT,
	@fromDate NVARCHAR(11),
	@toDate NVARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT DISTINCT S.ShowID, CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) ShowTime FROM Show S INNER JOIN Seat SE ON SE.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0 AND S.IsLocked = 1 AND SE.StatusType = 2
		UNION ALL
		SELECT DISTINCT S.ShowID, CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) ShowTime FROM ShowMIS S INNER JOIN SeatMIS SE ON SE.ShowID = S.ShowID WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) >= CONVERT(DATETIME, @fromDate, 106) AND CONVERT(DATETIME, CONVERT(VARCHAR(11), S.ShowTime, 106)) < CONVERT(DATETIME, DATEADD(DAY, 1, @toDate), 106) AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND S.IsCancel = 0 AND S.IsLocked = 1 AND SE.StatusType = 2
	) ShowMasterByDate ORDER BY ShowTime
	
	SELECT CONVERT(VARCHAR(11), ShowTime, 106) [Show Date], COUNT(ShowID) [No. of Shows] FROM #ShowMasterByDate GROUP BY ShowTime
	
	SELECT COUNT(ShowID) [Total Shows] FROM #ShowMasterByDate

	DROP TABLE #ShowMasterByDate
	
	SELECT DATENAME(mm, CONVERT(DATETIME, @fromDate, 106))
	
	SELECT ComplexName, ComplexCity FROM Complex WHERE ComplexID = @theatreId
END
GO

/* [TaxLossReport] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TaxLossReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].TaxLossReport
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [TaxLossReport] 1, 0, '05 Jan 2016', '05 Dec 2016'
CREATE PROCEDURE [dbo].TaxLossReport
	@theatreId INT,
	@screenId INT,
	@startDate VARCHAR(11),
	@endDate VARCHAR(11)
AS
BEGIN
	SELECT * INTO #ShowMasterByDate FROM 
	(
		SELECT S.ShowID FROM Show S WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106) 
		AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) 
		AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) 
		AND S.IsCancel = 0 AND S.IsLocked = 1
		UNION ALL
		SELECT S.ShowID FROM ShowMIS S WHERE CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) >= CONVERT(DATETIME, @startDate, 106)
		AND CONVERT(DATETIME, CONVERT(VARCHAR(11), ShowTime, 106)) <= CONVERT(DATETIME, @endDate, 106) 
		AND S.ScreenID = CASE WHEN @screenId = 0 THEN S.ScreenId ELSE @screenId END AND S.ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) 
		AND S.IsCancel = 0 AND S.IsLocked = 1
	) ShowMasterByDate
	
	SELECT * INTO #SeatMasterByDate FROM
	(
		SELECT ShowID, SeatID, PriceCardId, PaymentType FROM Seat WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1 AND StatusType IN (2,3)
		UNION ALL
		SELECT ShowID, SeatID, PriceCardId, PaymentType FROM SeatMIS WHERE ShowID IN (SELECT ShowID FROM #ShowMasterByDate) AND SeatType <> 1 AND StatusType IN (2,3)
	) SeatMasterByDate
	
	SELECT
	Sh.ShowID,
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount'), 0) - 
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Ticket_Amount_Discount'), 0) AS [TA],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Service_Charge'), 0) AS [SC],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'Entertainment_Tax'), 0) AS [ET],
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'CGST'), 0) AS CGST,
	ISNULL((SELECT Price FROM PriceCardDetails WHERE PriceCardId = S.PriceCardID AND S.PaymentType <> 5 AND Code = 'SGST'), 0) AS SGST,
	S.SeatID
	INTO #TaxLoss
	FROM
	#ShowMasterByDate Sh INNER JOIN #SeatMasterByDate S ON Sh.ShowID = S.ShowID
	GROUP BY 
	Sh.ShowID,
	S.PriceCardId,
	S.PaymentType,
	S.SeatID

	SELECT 
		CONVERT(VARCHAR(3), CONVERT(DATETIME, @startDate)) + ' ' + CAST(DATEPART(YEAR, CONVERT(DATETIME, @startDate)) AS VARCHAR)  AS [Month/Year],
		COUNT(DISTINCT ShowID) Shows,
		COUNT(SeatID) Attendance,
		SUM(ET) [Entertainment Tax],
		SUM(CGST) CGST,
		SUM(SGST) SGST,
		SUM(SC) [Service Charge],
		SUM(TA) Gross
	FROM #TaxLoss

	SELECT Code FROM PriceCardItemCollections WHERE Code NOT IN (SELECT Code FROM PriceCardDetails WHERE PriceCardId IN (SELECT PriceCardID FROM #SeatMasterByDate))
	
	DROP TABLE #ShowMasterByDate
	DROP TABLE #SeatMasterByDate
	DROP TABLE #TaxLoss
END
GO

/* [UserwisePaymentTypeSummaryReport] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserwisePaymentTypeSummaryReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserwisePaymentTypeSummaryReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--[UserwisePaymentTypeSummaryReport] 1, 0, 0, '14 Feb 2018'

CREATE PROCEDURE [dbo].[UserwisePaymentTypeSummaryReport]
	@theatreId INT,
	@screenId INT,
	@userId INT,
	@date VARCHAR(11)
AS
BEGIN
	--TempSeatMaster
	SELECT * INTO #TempSeatMaster
	FROM
	(
		SELECT * FROM Seat WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND ((LastSoldById = (CASE WHEN @userId = 0 THEN LastSoldById ELSE @userId END) AND LastSoldById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastSoldOn, 106)) = CONVERT(DATETIME, @date, 106)) OR (LastPrintedByID = (CASE WHEN @userId = 0 THEN LastPrintedByID ELSE @userId END) AND LastPrintedByID <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastPrintedOn, 106)) = CONVERT(DATETIME, @date, 106))) AND StatusType = 2 AND ShowID IN (SELECT ShowID FROM Show WHERE IsCancel = 0)
		UNION ALL
		SELECT * FROM SeatMIS WHERE ScreenId = CASE WHEN @screenId = 0 THEN ScreenId ELSE @screenId END AND ScreenID IN (SELECT ScreenID FROM Screen WHERE ComplexId = @theatreId) AND ((LastSoldById = (CASE WHEN @userId = 0 THEN LastSoldById ELSE @userId END) AND LastSoldById <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastSoldOn, 106)) = CONVERT(DATETIME, @date, 106)) OR (LastPrintedByID = (CASE WHEN @userId = 0 THEN LastPrintedByID ELSE @userId END) AND LastPrintedByID <> 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(11), LastPrintedOn, 106)) = CONVERT(DATETIME, @date, 106))) AND StatusType = 2 AND ShowID IN (SELECT ShowID FROM ShowMIS WHERE IsCancel = 0)
	)
	AS TempSeatMaster

	SELECT * INTO #TempTicketSoldReport
	FROM
	(
		SELECT
			A.[User Name],
			A.[Total Seats Sold],
			SUM(A.[Ticket Rate]) [Ticket Rate],
			A.[Payment Type]
		FROM
		(
			SELECT
				U.UserName AS [User Name],
				(SELECT COUNT(DISTINCT B.SeatID) FROM #TempSeatMaster B WHERE B.LastSoldById = S.LastSoldById) AS [Total Seats Sold],
				(ISNULL((SELECT Amount FROM PriceCard WHERE Id = S.PriceCardID), 0) *
				(SELECT COUNT(DISTINCT B.SeatID) FROM #TempSeatMaster B WHERE B.LastSoldById = S.LastSoldById AND B.PriceCardID = S.PriceCardID AND B.PaymentType = S.PaymentType)) AS [Ticket Rate],
				(SELECT T.Expression FROM [Type] T WHERE T.Value = S.PaymentType AND T.TypeName = 'PaymentType') AS [Payment Type]
			FROM
				#TempSeatMaster S
				INNER JOIN PriceCard P ON P.Id = S.PriceCardId
				INNER JOIN BoxOfficeUser U ON S.LastSoldById = U.UserID OR S.LastPrintedByID = U.UserID
				GROUP BY
					U.UserName, S.PaymentType, S.PriceCardID, S.LastSoldById, S.PaymentType
		)A
		GROUP BY
			A.[User Name], A.[Payment Type], A.[Total Seats Sold]
	) AS #TempTransactionReport

	/*SELECT * INTO #TempFandBSoldReport
	FROM
	(
		SELECT
			A.[User Name],
			SUM(A.[Quantity]) [Total FandB Invoice],
			SUM(A.[Gross Amount]) [Total Gross Amount],
			A.[Payment Type]
		FROM
		(
			SELECT
				U.UserName AS [User Name],
				(SELECT T.Expression FROM [Type] T WHERE T.Value = SH.PaymentType AND T.TypeName = 'PaymentType') AS [Payment Type],
				SH.Quantity - ISNULL(SUM(ICH.Quantity),0) Quantity,
				(SH.Quantity - ISNULL(SUM(ICH.Quantity),0)) * IP.Price [Gross Amount]
			FROM
				ItemSalesHistory SH 
				INNER JOIN ItemPrice IP ON IP.ItemPriceID = SH.ItemPriceID
				INNER JOIN BoxOfficeUser U ON SH.SoldBy = U.UserID
				lEFT JOIN ItemCancelHistory ICH ON ICH.TransactionID = SH.TransactionID AND ICH.ItemID = SH.ItemID AND ICH.ItemStockID = SH.ItemStockID
			WHERE
				SH.SoldBy = (CASE WHEN @userID = 0 THEN SH.SoldBy ELSE @userID END)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(11), SH.SoldOn, 106)) = CONVERT(DATETIME, @date, 106)
				AND SH.ComplexID = (CASE WHEN @theatreId = 0 THEN SH.ComplexID ELSE @theatreId END)
				AND SH.SeatID IS NULL
			GROUP BY U.UserName, SH.PaymentType, SH.ItemStockID, SH.Quantity, IP.Price
		)A
		GROUP BY
			A.[User Name], A.[Payment Type]
	) AS #TempFandBSoldReport*/
	
	select * from #TempTicketSoldReport
	--select * from #TempFandBSoldReport
	
	DROP TABLE #TempSeatMaster
	DROP TABLE #TempTicketSoldReport
	--DROP TABLE #TempFandBSoldReport

END
GO

/* GetUnnotifiedBookings */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetUnnotifiedBookings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetUnnotifiedBookings]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- GetUnnotifiedBookings
CREATE PROCEDURE [dbo].[GetUnnotifiedBookings]
AS
BEGIN
	SELECT DISTINCT S.OnlineShowID, 
	A.ShowId,
	STUFF((SELECT ',' + SeatClassInfo FROM BookHistory WHERE ShowId = A.ShowId AND TicketID = A.TicketID AND BookedOn = A.BookedOn FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'') AS SeatIDs, 
	ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(PatronInfo, '|') WHERE ID = 3), '') AS MobileNumber,
	BookedOn,
	TicketID
	FROM BookHistory A, Show S WHERE S.ShowId = A.ShowId AND S.IsOnlineCancel <> 1 AND A.ShouldNotify = 1 AND A.Notified = 0
	--checking show cancellation online status as we don't need to notify user if the session is cancelled before notifying the booking confirmation to the user
END
GO

/* GetUnnotifiedCancelledBookings */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetUnnotifiedCancelledBookings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetUnnotifiedCancelledBookings]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- GetUnnotifiedCancelledBookings
CREATE PROCEDURE [dbo].[GetUnnotifiedCancelledBookings]
AS
BEGIN
	SELECT DISTINCT S.OnlineShowID, 
	CH.ShowId,
	BookedOn,
	TicketID
	FROM CancelHistory CH, Show S WHERE S.ShowId = CH.ShowId AND S.IsOnlineCancel <> 1 AND CH.ShouldNotify = 1 AND CH.Notified = 0
	--checking show cancellation online status as we don't need to notify user if the session is cancelled before notifying the booking cancellation to the user
END
GO

/* GetUnnotifiedReprintBookings */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetUnnotifiedReprintBookings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].GetUnnotifiedReprintBookings
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- GetUnnotifiedReprintBookings
CREATE PROCEDURE [dbo].GetUnnotifiedReprintBookings
AS
BEGIN
	SELECT DISTINCT S.OnlineShowID, 
	RH.ShowId,
	ISNULL((SELECT items FROM dbo.FnSplitPatronInfo(PatronInfo, '|') WHERE ID = 3), '') AS MobileNumber,
	BookedOn,
	TicketID,
	PrintedOn
	FROM ReprintHistory RH, Show S WHERE S.ShowId = RH.ShowId AND S.IsOnlineCancel <> 1 AND RH.ShouldNotify = 1 AND RH.Notified = 0
	--checking show cancellation online status as we don't need to notify user if the session is cancelled before notifying the booking reprints to the user
END
GO

/* [spGetSeatDetails] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetSeatDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetSeatDetails]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetSeatDetails]
(
    @SeatIds varchar(max)
)
AS
BEGIN
WITH seatDetails(SeatId, StringData) AS
(
    SELECT
        LEFT(@SeatIds, CHARINDEX(',', @SeatIds + ',') - 1),
        STUFF(@SeatIds, 1, CHARINDEX(',', @SeatIds + ','), '')
    UNION all

    SELECT
        LEFT(StringData, CHARINDEX(',', StringData + ',') - 1),
        STUFF(StringData, 1, CHARINDEX(',', StringData + ','), '')
    FROM seatDetails
    WHERE
        StringData > ''
)
SELECT
    SeatId into #tmpSeatIds
FROM seatDetails;


SELECT Seat.ScreenID, Seat.ShowID, Seat.ClassID, Seat.TicketID, Seat.SeatID, Seat.DCRNo, Seat.SeatType, Seat.SeatLabel, Seat.StatusType, Show.ScreenNo, Show.ScreenName, 
Show.MovieName, Show.MovieCensorRatingType, Show.MovieLanguageType, Show.ShowName, Show.ShowTime, Class.ClassName, Class.Price, Class.ClassLayoutID, Seat.NoBlocks, 
Seat.QuotaType, Seat.ReleaseBefore, Seat.LastPrintedByID, Seat.CoupleSeatIds, Seat.SeatLayoutId, (CASE WHEN Seat.SeatID IN 
(select DISTINCT SeatID from ChangeQuotaDetails WHERE [Status] = 0) THEN 1 ELSE 0 END) AS IsQuotaChangeRequest 
FROM Seat INNER JOIN Show ON Seat.ShowID = Show.ShowID INNER JOIN Class ON Seat.ClassID = Class.ClassID 
WHERE Seat.SeatID  in (select SeatID from #tmpSeatIds)  ORDER BY Seat.SeatID

DROP TABLE #tmpSeatIds

END

/* [spGetPriceCards]  */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetPriceCards]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetPriceCards]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetPriceCards]
@ClassLayoutID INT
AS
IF EXISTS(SELECT ClassLayoutId FROM PriceCardClassLayoutCollections WHERE ClassLayoutId = @ClassLayoutID)
SELECT Id, Name FROM PriceCard WHERE (Id IN (SELECT PriceCardId FROM PriceCardClassLayoutCollections WHERE ClassLayoutId = @ClassLayoutID))  AND Id != 0 ORDER BY Id DESC
GO

/* [spGetDCRs]  */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetDCRs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetDCRs]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetDCRs]
@ClassLayoutID INT
AS
IF EXISTS(SELECT ClassLayoutId FROM DCRClassLayoutCollections WHERE ClassLayoutId = @ClassLayoutID)
SELECT DCRId, DCRName FROM DCR WHERE (DCRId IN (SELECT DCRId FROM DCRClassLayoutCollections WHERE ClassLayoutId = @ClassLayoutID)) ORDER BY DCRId DESC
GO

/* [spGetClassLayouts]  */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetClassLayouts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetClassLayouts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetClassLayouts]
@ScreenID INT
AS
SELECT ClassLayoutID, ClassName, NoRows, NoCols FROM ClassLayout WHERE ScreenID = @ScreenID ORDER BY ClassNo, ClassLayoutID
GO

/* [spGetSeatLayouts] */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetSeatLayouts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetSeatLayouts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetSeatLayouts]
@ClassLayoutID INT
AS
SELECT SeatLayoutID, SeatType, SeatLabel, RowNo, ColNo, QuotaType, ReleaseBefore FROM SeatLayout WHERE ClassLayoutID = @ClassLayoutID
GO

/* [spGetSeats] */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetSeats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetSeats]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetSeats]
@ScreenID INT,
@ShowID INT,
@QuotaID INT
AS
SELECT TicketID,COUNT(*), PatronInfo, Replace(Replace((select SeatLabel from Seat ST1 where ST1.ClassID = ST.ClassID AND ST1.TicketID=sT.TicketID and ST1.StatusType=ST.StatusType 
for XML path ),'<row><SeatLabel>',''),'</SeatLabel></row>',',') as SeatLabels,StatusType,isNull((select UserName from BoxOfficeUser where UserID=st.LastBlockedByID),'') Blockedby, 
ISNULL((select DISTINCT ClassName from Class Cl where Cl.ClassID = ST.ClassID), '') Class FROM Seat ST 
WHERE ST.ScreenID = @ScreenID and ST.ShowID = @ShowID and ST.QuotaType = @QuotaID  and SeatType<>1 and ST.StatusType IN (1,2,3,6) 
group by ST.ClassID, ST.TicketID,st.PatronInfo,st.StatusType,st.LastBlockedByID ORDER BY st.StatusType; 
SELECT COUNT(*) FROM Seat ST WHERE ST.ScreenID = @ScreenID and ST.ShowID = @ShowID and ST.QuotaType = @QuotaID and SeatType <> 1
GO

/* [spGetComplexDetails] */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetComplexDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetComplexDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetComplexDetails]
@ComplexID INT
AS
SELECT ComplexID, ComplexName, ComplexAddress1, ComplexCity, ComplexState, IsFandBBillWithTaxBreakUp, ISNULL(GSTIN, '') FROM Complex WHERE ComplexID = @ComplexID
GO

/* [spGetItemsByClass] */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spGetItemsByClass]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGetItemsByClass]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetItemsByClass]
@ClassID INT
AS
SELECT ItemID, ItemName FROM Items WHERE ItemClassID = @ClassID
GO
