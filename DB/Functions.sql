USE [YourScreensBoxOffice]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 08/27/2014 11:07:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString]
(
	@RowData nvarchar(2000),
	@SplitOn nvarchar(5)
)  
RETURNS @RtnValue table 
(
	--Id int identity(1,1),
	Data nvarchar(100)
) 
AS  
BEGIN 
	Declare @Cnt int
	Set @Cnt = 1

	While (Charindex(@SplitOn,@RowData)>0)
	Begin
		Insert Into @RtnValue (data)
		Select 
			Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))

		Set @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+1,len(@RowData))
		Set @Cnt = @Cnt + 1
	End
	IF (ltrim(rtrim(@RowData))<>'')
	BEGIN
		Insert Into @RtnValue (data)
		Select Data = ltrim(rtrim(@RowData))
	END

	Return
END
GO
/****** Object:  UserDefinedFunction [dbo].[SPLIT]    Script Date: 08/27/2014 11:07:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SPLIT] 
   (  @DELIMITER VARCHAR(5), 
      @LIST      VARCHAR(MAX) 
   ) 
   RETURNS @TABLEOFVALUES TABLE 
      (  ROWID   SMALLINT IDENTITY(1,1), 
         [VALUE] VARCHAR(MAX) 
      ) 
AS 
   BEGIN
    
      DECLARE @LENSTRING INT 
 
      WHILE LEN( @LIST ) > 0 
         BEGIN 
         
            SELECT @LENSTRING = 
               (CASE CHARINDEX( @DELIMITER, @LIST ) 
                   WHEN 0 THEN LEN( @LIST ) 
                   ELSE ( CHARINDEX( @DELIMITER, @LIST ) -1 )
                END
               ) 
                                
            INSERT INTO @TABLEOFVALUES 
               SELECT SUBSTRING( @LIST, 1, @LENSTRING )
                
            SELECT @LIST = 
               (CASE ( LEN( @LIST ) - @LENSTRING ) 
                   WHEN 0 THEN '' 
                   ELSE RIGHT( @LIST, LEN( @LIST ) - @LENSTRING - 1 ) 
                END
               ) 
         END
          
      RETURN 
      
   END
GO
/****** Object:  UserDefinedFunction [dbo].[GetSeatsbyTicketid]    Script Date: 08/27/2014 11:07:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetSeatsbyTicketid]
(
	-- Add the parameters for the function here
	@TicketID Int,
	@StartDate Date,
	@EndDate Date 
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @response varchar(max)
	DECLARE @SeatLabel varchar(max)
	set @response='';

	-- Add the T-SQL statements to compute the return value here
	 
	 select  @response = COALESCE(@response+',' ,'') +M.SeatLabel from (Select * From Seat where (StatusType=2 or StatusType=3) and TicketID=@TicketID and LastSoldByID>0 and LastSoldOn>=@Startdate and LastSoldOn<@Enddate Union All Select * From SeatMIS where (StatusType=2 or StatusType=3) and TicketID=@TicketID and LastSoldByID>0 and LastSoldOn>=@Startdate and LastSoldOn<@Enddate) M where  M.TicketID=@TicketID
	--DECLARE curItems CURSOR FOR select M.SeatLabel from (Select * From Seat where (StatusType=2 or StatusType=3) and TicketID=@TicketID and LastSoldByID>0 and LastSoldOn>=@Startdate and LastSoldOn<@Enddate Union All Select * From SeatMIS where (StatusType=2 or StatusType=3) and TicketID=@TicketID and LastSoldByID>0 and LastSoldOn>=@Startdate and LastSoldOn<@Enddate) M
	--OPEN curItems
	--FETCH NEXT FROM curItems INTO @SeatLabel
	--WHILE @@FETCH_STATUS = 0
	--begin
	--	set @response=@response+@SeatLabel+','
	--	FETCH NEXT FROM curItems INTO @SeatLabel
	--END
	--close curItems;
	--deallocate curItems;

	-- Return the result of the function
	RETURN @response;

END
GO

/* UserDefinedFunction [dbo].[GETITEMS] */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[GETITEMS]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GETITEMS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GETITEMS] 
(  
	@LIST VARCHAR(MAX) 
) 
RETURNS @TABLEOFVALUES TABLE 
(   
    [VALUE] VARCHAR(MAX) 
) 
AS 
BEGIN    
    INSERT INTO @TABLEOFVALUES 
    SELECT t.ItemName FROM Items t WHERE t.ItemID IN 
	(SELECT 
	(SELECT CASE WHEN(CHARINDEX('-',Value)>0) THEN SUBSTRING(Value,0,CHARINDEX('-',Value)) ELSE Value END) Val
	FROM dbo.SPLIT(',',@LIST))
          
    RETURN
END
GO

--/* [GetPriceCardDetailsByID] */
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetPriceCardDetailsByID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
--DROP FUNCTION [dbo].[GetPriceCardDetailsByID]
--GO

--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE FUNCTION [dbo].[GetPriceCardDetailsByID]
--(
--	@PriceCardID INT
--)
--RETURNS VARCHAR(MAX)
--AS
--BEGIN
--	DECLARE @PriceCardDetails AS NVARCHAR(MAX)='';
	
--	SELECT @PriceCardDetails = COALESCE(@PriceCardDetails + ',' ,'') + 
--	'{
--	"code" : "'+ Code +'",
--	"name": "'+ Name +'",
--	"price": '+ CAST(Price AS VARCHAR) +',
--	"priceType":"'+ Type +'"
--	}'
--	FROM PriceCardDetails WHERE PriceCardId = @PriceCardID AND Code IN (SELECT Code FROM PriceCardItems);
--	RETURN @PriceCardDetails;
--END

GO

/* [GetFullPriceCardDetailsByID] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFullPriceCardDetailsByID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GetFullPriceCardDetailsByID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetFullPriceCardDetailsByID]
(
    @PriceCardID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @PriceCardDetails AS NVARCHAR(MAX)='';
    SELECT @PriceCardDetails = COALESCE(@PriceCardDetails + ',' ,'') + 
    '{
    "code" : "'+ Code +'",
    "name": "'+ Name +'",
    "price": '+ CAST(Price AS VARCHAR) +',
    "priceType":"'+ Type +'"
    }'
    FROM PriceCardDetails WHERE PriceCardId = @PriceCardID AND Code NOT IN (SELECT Code FROM PriceCardItems);
    RETURN @PriceCardDetails;
END

GO

/****** Object:  UserDefinedFunction [dbo].[GetCancelSeatsbyTicketid]    Script Date: 08/27/2014 11:07:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetCancelSeatsbyTicketid]
(
	-- Add the parameters for the function here
	@TicketID Int,
	@StartDate Date,
	@EndDate Date 
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @response varchar(max)
	DECLARE @SeatLabel varchar(max)
	set @response='';

	-- Add the T-SQL statements to compute the return value here
	
	select @response = COALESCE(@response+',' ,'') +M.SeatLabel from(Select * From Seat where LastCancelledByID>0 and SeatID=@TicketID and LastCancelledOn>= @Startdate and LastCancelledOn<  @Enddate Union All Select * From SeatMIS where LastCancelledByID>0 and SeatID=@TicketID and LastCancelledOn>= @Startdate and LastCancelledOn<  @Enddate) M where M.SeatId=@TicketID
	
	--DECLARE curItems CURSOR FOR select M.SeatLabel from(Select * From Seat where LastCancelledByID>0 and LastCancelledOn>= @Startdate and LastCancelledOn<  @Enddate Union All Select * From SeatMIS where LastCancelledByID>0 and LastCancelledOn>= @Startdate and LastCancelledOn<  @Enddate) M where M.SeatId=@TicketID
	--OPEN curItems
	--FETCH NEXT FROM curItems INTO @SeatLabel
	--WHILE @@FETCH_STATUS = 0
	--begin
	--	set @response=@response+@SeatLabel+','
	--	FETCH NEXT FROM curItems INTO @SeatLabel
	--END
	--close curItems;
	--deallocate curItems;

	-- Return the result of the function
	RETURN @response;

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetBlockSeatsbyTicketid]    Script Date: 08/27/2014 11:07:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetBlockSeatsbyTicketid]
(
	-- Add the parameters for the function here
	@TicketID Int,
	@StartDate Date,
	@EndDate Date 
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @response varchar(max)
	DECLARE @SeatLabel varchar(max)
	set @response='';

	-- Add the T-SQL statements to compute the return value here
	
	select @response = COALESCE(@response+',' ,'') +M.SeatLabel from(Select * From Seat where LastBlockedByID>0 and SeatID=@TicketID and LastBlockedOn>= @Startdate and LastBlockedOn<  @Enddate Union All Select * From SeatMIS where LastBlockedByID>0 and SeatID=@TicketID and LastBlockedOn>= @Startdate and LastBlockedOn<  @Enddate) M where M.seatid=@TicketID
	
	--DECLARE curItems CURSOR FOR select M.SeatLabel from(Select * From Seat where LastBlockedByID>0 and LastBlockedOn>= @Startdate and LastBlockedOn<  @Enddate Union All Select * From SeatMIS where LastBlockedByID>0 and LastBlockedOn>= @Startdate and LastBlockedOn<  @Enddate) M where M.seatid=@TicketID
	--OPEN curItems
	--FETCH NEXT FROM curItems INTO @SeatLabel
	--WHILE @@FETCH_STATUS = 0
	--begin
	--	set @response=@response+@SeatLabel+','
	--	FETCH NEXT FROM curItems INTO @SeatLabel
	--END
	--close curItems;
	--deallocate curItems;

	-- Return the result of the function
	RETURN @response;

END
GO

USE [YourScreensBoxOffice]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FnSplit]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnSplit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnSplit](@String varchar(max), @Delimiter char(1))     
returns @temptable TABLE (items varchar(max))     
as     
begin     
declare @idx int     
declare @slice varchar(max)     

select @idx = 1     
    if len(@String)<1 or @String is null  return     

while @idx!= 0     
begin     
    set @idx = charindex(@Delimiter,@String)     
    if @idx!=0     
        set @slice = left(@String,@idx - 1)     
    else     
        set @slice = @String     

    if(len(@slice)>0)
        insert into @temptable(Items) values(@slice)     

    set @String = right(@String,len(@String) - @idx)     
    if len(@String) = 0 break     
end 
return     
end
GO

/* [FnSplitPatronInfo] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FnSplitPatronInfo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnSplitPatronInfo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnSplitPatronInfo](@String varchar(8000), @Delimiter char(1))     
RETURNS @temptable TABLE (ID INT IDENTITY(1,1), Items varchar(8000))     
AS     
BEGIN     
DECLARE @idx INT     
DECLARE @slice VARCHAR(8000)     

SELECT @idx = 1     
    IF LEN(@String)<1 OR @String IS NULL RETURN     

WHILE @idx!= 0     
BEGIN     
    SET @idx = CHARINDEX(@Delimiter,@String)     
    IF @idx!=0     
        SET @slice = LEFT(@String,@idx - 1)     
    ELSE     
        SET @slice = @String     

    INSERT INTO @temptable(Items) VALUES(@slice)     

    SET @String = RIGHT(@String,LEN(@String) - @idx)     
    IF LEN(@String) = 0 BREAK     
END 
RETURN     
END
GO

/* FnGetUserPassword */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FnGetUserPassword]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnGetUserPassword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnGetUserPassword]
(
	@UserName VARCHAR(16)
)
Returns VARCHAR(100)
AS
BEGIN
	DECLARE @TmpPassword AS VARCHAR(100)=''
	SELECT
		@TmpPassword = Password
	FROM BoxOfficeUser
	WHERE UserName = @UserName
	Return @TmpPassword
END
GO

/* FnValidatePriceCard */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FnValidatePriceCard]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnValidatePriceCard]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnValidatePriceCard]
(
    @classID INT,
    @priceCardID INT,
	@statusType INT,
	@seatID INT,
	@ShowID INT
)
Returns Bit
AS
BEGIN
    DECLARE @ValidPriceCard AS bit=0
	Declare @SeatClassID AS INT = 0
	Declare @SeatShowID AS INT = 0
	IF (@statusType=0)
	BEGIN
		SELECT TOP 1 @ClassID = ClassID, @ShowID=ShowID  from Seat where SeatID in (@seatID) AND ClassID=@classID AND ShowID=(case @ShowID when 0 then ShowID else @ShowID end)
	    IF  EXISTS (select * from ClassPriceCards where ShowID= @ShowID and ClassId = @ClassID AND PriceCardId = @priceCardID) 
			SET @ValidPriceCard = 1;
	END
	ELSE
	BEGIN
		IF  EXISTS (SELECT * FROM Seat WHERE ShowID= (case @ShowID when 0 then ShowID else @ShowID end) and SeatID = @seatID AND PriceCardId = @priceCardID) 
			SET @ValidPriceCard = 1;
	END
    Return @ValidPriceCard
END
GO

/* FnValidateClassPriceCard */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FnValidateClassPriceCard]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnValidateClassPriceCard]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnValidateClassPriceCard]
(
    @classLayoutID INT,
    @priceCardID INT
)
Returns Bit
AS
BEGIN
    DECLARE @ValidPriceCard AS bit=0
	IF  EXISTS (SELECT * FROM PriceCardClassLayoutCollections WHERE ClassLayoutId = @classLayoutID AND PriceCardId = @priceCardID) 
		SET @ValidPriceCard = 1;
    Return @ValidPriceCard
END
GO

/* FnValidateScreenExperienceValue */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FnValidateScreenExperienceValue]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnValidateScreenExperienceValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnValidateScreenExperienceValue]
(
    @screenExperienceValue varchar(100)
)
Returns Bit
AS
BEGIN
    DECLARE @ValidScreenExperienceValue AS bit=0
	IF  EXISTS (SELECT * FROM [Type] WHERE TypeNo in (13,14,30) and replace(Expression,'_',' ') = @screenExperienceValue) 
		SET @ValidScreenExperienceValue = 1;
    Return @ValidScreenExperienceValue
END
GO

/* GetPriceCardId */
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[GetPriceCardId]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GetPriceCardId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetPriceCardId]
(
    @priceCardName varchar(100),
	@TheatreType varchar(100),
	@CoolingType varchar(100),
	@TownType varchar(100),
	@ScreenType TinyInt
)
Returns TinyInt
AS
BEGIN
    DECLARE @PriceCardId AS TinyInt=0
	  SELECT @PriceCardId = Id FROM PriceCard WHERE [Name] = @priceCardName and TheatreType = @TheatreType and CoolingType = @CoolingType and TownType = @TownType and ScreenType = @ScreenType and IsDeleted=0
    Return @PriceCardId
END
GO
