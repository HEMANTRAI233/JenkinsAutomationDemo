USE YourScreensBoxOffice
GO

/* [ClassPriceCards] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ClassPriceCards]') AND type in (N'U'))
DROP TABLE [dbo].[ClassPriceCards]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ClassPriceCards](
  [ShowID] [INT] NOT NULL,
  [ClassID] [INT] NOT NULL,
  [ClassLayoutID] [INT] NOT NULL,
  [PriceCardID] [INT] NOT NULL,
) ON [PRIMARY]
GO

/* PriceCardItemDetails */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceCardItemDetails]') AND type in (N'U'))
DROP TABLE [dbo].PriceCardItemDetails
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].PriceCardItemDetails(
	PriceCardID INT NOT NULL,
	ItemID INT NOT NULL,
	ItemPriceID INT NOT NULL,
	Quantity INT NOT NULL,
	SellingPricePerItem NUMERIC(9,2) NOT NULL,
	DiscountPerItem NUMERIC(9,2) NOT NULL
)
GO

/* SetupOrder */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupOrder]') AND type in (N'U'))
DROP TABLE [dbo].SetupOrder
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].SetupOrder(
	ID INT IDENTITY(1,1) NOT NULL,
	Row INT NOT NULL,
	[Column] INT NOT NULL,
	ItemID INT NULL
)
GO

/* Table Taxes */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Taxes]') AND type in (N'U'))
DROP TABLE [dbo].Taxes
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].Taxes(
	ServiceTax NUMERIC(9,2) NOT NULL,
	SwachhBharatCess NUMERIC(9,2) NOT NULL,
	LastModifiedBy INT NOT NULL,
	LastModifiedOn DATETIME NOT NULL
	)
GO

/* ItemCancelHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemCancelHistory]') AND type in (N'U'))
DROP TABLE [dbo].[ItemCancelHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemCancelHistory](
	[TransactionID] [VARCHAR](10) NOT NULL,
	[ItemID] [INT] NOT NULL,
	[ItemPriceID] [INT] NOT NULL,
	[ItemStockID] [INT] NOT NULL,
	[Quantity] [INT] NOT NULL,
	[OrderType] [TINYINT] NOT NULL,
	[CancelledBy] [INT] NULL,
	[CancelledOn] [DATETIME] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* ItemSalesHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemSalesHistory]') AND type in (N'U'))
DROP TABLE [dbo].ItemSalesHistory
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemSalesHistory](
	[TransactionID] [VARCHAR](10) NOT NULL,
	[ItemID] [INT] NOT NULL,
	[ItemPriceID] [INT] NOT NULL,
	[Quantity] [INT] NOT NULL,
	[OrderType] [TINYINT] NOT NULL,
	[PaymentType] [TINYINT] NOT NULL,
	[ItemStockID] [INT] NOT NULL,
	[ComplexID] [INT] NOT NULL,
	[SoldBy] [INT] NOT NULL,
	[SoldOn] [DATETIME] NOT NULL,
	[IsBlocked] BIT NOT NULL DEFAULT(0),
	DiscountPerItem NUMERIC(9,2) NOT NULL DEFAULT(0.00),
	SeatID INT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* ItemPackageSalesHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemPackageSalesHistory]') AND type in (N'U'))
DROP TABLE [dbo].ItemPackageSalesHistory
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemPackageSalesHistory](
	[TransactionID] [VARCHAR](10) NOT NULL,
	[ItemPackageID] [INT] NOT NULL,
	[ItemID] [INT] NOT NULL,
	[Quantity] [INT] NOT NULL,
	[OrderType] [TINYINT] NOT NULL,
	[ItemStockID] [INT] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* Items */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Items]') AND type in (N'U'))
DROP TABLE [dbo].[Items]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Items](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[ItemClassID] [INT] NULL,
	[ItemName] VARCHAR(256) NOT NULL,
	[HSNCode] INT NOT NULL,
	[ItemPriceID] INT NOT NULL,
	[UnitOfMeasure] [INT] NOT NULL,
	[ComboItems] VARCHAR(MAX) NULL,
	[IsOnline] BIT NOT NULL,
	[Shortcut] VARCHAR(4) NULL,
	[IsActive] BIT NOT NULL,
	[StockOnHand] INT NOT NULL DEFAULT(0),
	[CreatedBy] [INT] NOT NULL,
	[CreatedOn] [DATETIME] NOT NULL,
	[LastModifiedBy] [INT] NULL,
	[LastModifiedOn] [DATETIME] NULL,
	BlockedStock INT NOT NULL DEFAULT(0)
 CONSTRAINT [PKC_Items_ItemID] PRIMARY KEY CLUSTERED
(
	[ItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_Items_ItemName] UNIQUE NONCLUSTERED
(
	[ItemName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* Table ItemPrice */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemPrice]') AND type in (N'U'))
DROP TABLE [dbo].[ItemPrice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ItemPrice](
	[ItemPriceID] INT IDENTITY(1,1) NOT NULL,
	[Price] NUMERIC(9, 2) NOT NULL,
	[PriceType] [INT] NOT NULL,
	[IsServiceTax] BIT NOT NULL,
	[ServiceTaxPercent] NUMERIC(9,2) NOT NULL,
	[ServiceTax] NUMERIC(9,2) NOT NULL,
	[IsSwachhBharatCess] BIT NOT NULL,
	[SwachhBharatPercent] NUMERIC(9,2) NOT NULL,
	[SwachhBharatCess] NUMERIC(9,2) NOT NULL,
	[AdditionalTaxPercent] NUMERIC(9,2) NOT NULL,
	[AdditionalTax] NUMERIC(9,2) NOT NULL,
	[VATPercent] NUMERIC(9,2) NOT NULL,
	[VAT] NUMERIC(9,2) NOT NULL,
	[SGSTPercent] NUMERIC(9,2) NOT NULL,
	[SGST] NUMERIC(9,2) NOT NULL,
	[CGSTPercent] NUMERIC(9,2) NOT NULL,
	[CGST] NUMERIC(9,2) NOT NULL,
	[CompensationCessPercent] NUMERIC(9,2) NOT NULL,
	[CompensationCess] NUMERIC(9,2) NOT NULL,
	[NetAmount] NUMERIC(9,2) NOT NULL
 CONSTRAINT [PK_ItemPriceID] PRIMARY KEY CLUSTERED
(
	[ItemPriceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/* Vendors */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Vendors]') AND type in (N'U'))
DROP TABLE [dbo].Vendors
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].Vendors(
    [VendorID] [INT] IDENTITY(1,1) NOT NULL,
    [VendorCompanyName] [NVARCHAR](256) NOT NULL,
    [Address] [NVARCHAR](256) NOT NULL,
    [Location] [NVARCHAR](256) NOT NULL,
	[Pincode] [NVARCHAR](20) NOT NULL,
    [State] [NVARCHAR](50) NOT NULL,
    [Country] [NVARCHAR](50) NOT NULL,
    [TelephoneNumber] [NVARCHAR](20) NOT NULL,
    [ContactDetails] [NVARCHAR](MAX) NOT NULL,
    [CreatedBy] [INT] NOT NULL,
    [CreatedOn] [DATETIME] NOT NULL,
    [LastModifiedBy] [INT] NULL,
    [LastModifiedOn] [DATETIME] NULL,
) ON [PRIMARY]
GO

/* ItemIngredientCollections */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemIngredientCollections]') AND TYPE IN (N'U'))
DROP TABLE [dbo].[ItemIngredientCollections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ItemIngredientCollections](
   [ItemID] [INT] NOT NULL,
   [IngredientID] [INT] NOT NULL
) ON [PRIMARY]
GO

/* BookingsReconcilliation */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BookingsReconcilliation]') AND type in (N'U'))
DROP TABLE [dbo].[BookingsReconcilliation]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BookingsReconcilliation](
    [ShowId] [INT] NOT NULL,
    [SeatId] [INT] NOT NULL,
    [SeatClassInfo] [NVARCHAR](30) NOT NULL,
    [BlockCode] [NVARCHAR](36) NOT NULL,
	[BOBookingCode] [NVARCHAR](8) NOT NULL,
    [PatronInfo] [NVARCHAR](256) NOT NULL,
    [BookedOn] [DATETIME] NOT NULL,
    [PriceCardId] [INT] NOT NULL,
    [DeletedOn] [DATETIME] NOT NULL,
) ON [PRIMARY]
GO

/* Ingredients */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Ingredients]') AND TYPE IN (N'U'))
DROP TABLE [dbo].[Ingredients]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ingredients](
	[IngredientID] [INT] IDENTITY(1,1) NOT NULL,
	[IngredientName] [VARCHAR](50) NOT NULL,
	[PriceType] [INT] NOT NULL,
	[Cost] [NUMERIC](9, 2) NOT NULL,
	[UnitOfMeasure] [INT] NOT NULL,
	[CreatedBy] [INT] NOT NULL,
	[CreatedOn] [DATETIME] NOT NULL,
	[LastModifiedBy] [INT] NULL,
	[LastModifiedOn] [DATETIME] NULL
) ON [PRIMARY]
GO

/* IngredientVendorCollections */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IngredientVendorCollections]') AND TYPE IN (N'U'))
DROP TABLE [dbo].[IngredientVendorCollections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IngredientVendorCollections](
   [IngredientID] [INT] NOT NULL,
   [VendorID] [INT] NOT NULL
) ON [PRIMARY]
GO

/* [Distributors] */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Distributors]') AND type in (N'U'))
DROP TABLE [dbo].[Distributors]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Distributors](
	[Id] INT IDENTITY(1,1) NOT NULL,
	[Name] NVARCHAR(100) NOT NULL,
	[CreatedBy] INT NOT NULL,
	[CreatedOn] DATETIME NOT NULL
)
GO

/* [DistributorMovieCollections] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorMovieCollections]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorMovieCollections]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorMovieCollections](
	[Id] INT IDENTITY(1,1) NOT NULL,
	[DistributorID] INT NOT NULL,
	OnlineMovieID NVARCHAR(64) NOT NULL,
	OnlineMovieName NVARCHAR(64) NOT NULL,
	MovieName NVARCHAR(64) NOT NULL,
	Language TINYINT NOT NULL,
	CensorRating TINYINT NOT NULL,
	ShowTax NUMERIC(9,2) NOT NULL,
	INR NUMERIC(9,2) NOT NULL,
	Publicity NUMERIC(9,2) NOT NULL,
	Shuttling NUMERIC(9,2) NOT NULL,
	PrintExpenses NUMERIC(9,2) NOT NULL,
	RepresentativeDearnessAllowance NUMERIC(9,2) NOT NULL,
	BannerTax NUMERIC(9,2) NOT NULL,
	AdvertisementTax NUMERIC(9,2) NOT NULL,
	HealthCess NUMERIC(9,2) NOT NULL,
	Others NUMERIC(9,2) NOT NULL,
	[CreatedBy] INT NOT NULL,
	[CreatedOn] DATETIME NOT NULL,
	[IsDeleted] BIT DEFAULT(0) NOT NULL,
	[ModifiedBy] INT NULL,
	[ModifiedOn] DATETIME NULL,
	MovieMergedTo NVARCHAR(64) NULL,
	)
GO

/* PriceCardClassLayoutCollections */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceCardClassLayoutCollections]') AND type in (N'U'))
DROP TABLE [dbo].[PriceCardClassLayoutCollections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceCardClassLayoutCollections](
   [PriceCardId] [INT] NOT NULL,
   [ClassLayoutId] [INT] NOT NULL
) ON [PRIMARY]
GO

/* DCRClassLayoutCollections */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DCRClassLayoutCollections]') AND type in (N'U'))
DROP TABLE [dbo].[DCRClassLayoutCollections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DCRClassLayoutCollections](
   [DCRId] [INT] NOT NULL,
   [ClassLayoutId] [INT] NOT NULL
) ON [PRIMARY]
GO

/* PriceCardItems */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceCardItems]') AND type in (N'U'))
DROP TABLE [dbo].[PriceCardItems]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceCardItems](
    [Id] [INT] IDENTITY(1,1) NOT NULL,
	[Code] [NVARCHAR](256) NOT NULL,
	[Name] [NVARCHAR](256) NOT NULL,
    [CalculationType] [NVARCHAR](100) NOT NULL,
    [Type] [NVARCHAR](100) NOT NULL
) ON [PRIMARY]
GO

/* PriceCardItemCollections */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceCardItemCollections]') AND type in (N'U'))
DROP TABLE [dbo].[PriceCardItemCollections]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceCardItemCollections](
    [Id] [INT] IDENTITY(1,1) NOT NULL,
	[Code] [NVARCHAR](256) NOT NULL,
	[Name] [NVARCHAR](256) NOT NULL,
    [CalculationType] [NVARCHAR](100) NOT NULL,
    [Type] [NVARCHAR](100) NOT NULL,
    [PriceCardItemCode] [NVARCHAR](256) NOT NULL
) ON [PRIMARY]
GO

/* Schema Versions */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SchemaVersions](
	[DBVersion] [int] NOT NULL,
	[QTVersion] NVARCHAR(50) NOT NULL,
	[DateInstalled] [datetime] DEFAULT GETDATE() NOT NULL,
	[DateModified] [datetime] DEFAULT GETDATE() NOT NULL
	)ON [PRIMARY]
GO

/* HandoffDetails */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HandoffDetails]') AND type in (N'U'))
DROP TABLE [dbo].HandoffDetails
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].HandoffDetails(
	[Id] NVARCHAR(36) NOT NULL,
	[CreatedOn] DATETIME DEFAULT(GETDATE()) NOT NULL,
	[ActivationStartedOn] DATETIME NULL,
	[ActivationFinishedOn] DATETIME NULL,
	[StartWithdraw] BIT DEFAULT(0) NOT NULL,
	[WithdrawStartedOn] DATETIME NULL,
	[WithdrawFinishedOn] DATETIME NULL)
GO

/****** Object:  Table [dbo].[Type]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Type](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeNo] [tinyint] NOT NULL,
	[TypeName] [varchar](32) NOT NULL,
	[Value] [tinyint] NOT NULL,
	[Expression] [varchar](64) NOT NULL,
 CONSTRAINT [PKC_Type_TypeID] PRIMARY KEY CLUSTERED
(
	[TypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShowMIS]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShowMIS](
	[ScreenID] [int] NOT NULL,
	[ShowID] [int] NOT NULL,
	[ScreenNo] [varchar](2) NOT NULL,
	[ScreenName] [nvarchar](256) NOT NULL,
	[OnlineMovieID] [nvarchar](64) NOT NULL,
	[OnlineMovieName] [nvarchar](64) NOT NULL,
	[MovieName] [nvarchar](64) NOT NULL,
	[Experiences] [nvarchar](max) NOT NULL,
	[MovieLanguageType] [tinyint] NOT NULL,
	[MovieCensorRatingType] [tinyint] NOT NULL,
	[ShowName] [varchar](25) NOT NULL,
	[ShowTime] [datetime] NOT NULL,
	[IsPaused] [bit] NOT NULL,
	[IsOnlinePaused] BIT NOT NULL,
	[IsOnlineEdit] [Bit] NOT NULL DEFAULT(1),
	[ResumeBefore] [int] NOT NULL,
	[AllowedUsers] [varchar](128) NOT NULL,
	[Duration] [int] NOT NULL,
	[IsCancel] [bit] NOT NULL,
	[IsOnlineCancel] [Bit] NOT NULL DEFAULT(0),
	[CancelRemarks] [varchar](300) NOT NULL,
	[IsOnlinePublish] [bit] NOT NULL,
	[OnlineShowId] [varchar](64) NOT NULL,
	[Uuid] [varchar](64) NOT NULL,
	[EntryTime] [int] NOT NULL,
	[IntervalTime] [int] NOT NULL,
	[ExitTime] [int] NOT NULL,
	[IsAdvanceToken] [BIT],
	[IsDisplaySeatNos] [BIT],
	[IsOnlineSaleClosed] [BIT] NOT NULL DEFAULT(0),
	[IsSalesDataSent] [BIT] NOT NULL DEFAULT(0),
	[IsPrintTicketAmount] [BIT] NOT NULL DEFAULT(1),
	[MaintenanceCharge] [NUMERIC](9, 2) NOT NULL DEFAULT('0.00'),
	[IsPrintSlip] [BIT] NOT NULL DEFAULT(1),
	[IsPrintPriceInSlip] [BIT] NOT NULL DEFAULT(1),
	[AdvanceTokenReleaseTime] [int] NOT NULL,
	[IsBlockSalesDataSent] [BIT] NOT NULL DEFAULT(0),
	[IsRealTime] [BIT] NOT NULL DEFAULT(0),
	[CreationType] [BIT] NOT NULL DEFAULT(0),
	[IsSentBOSalesStatus] [BIT] NOT NULL DEFAULT(0),
	[IsHandoff] [BIT] NOT NULL DEFAULT(0),
	DistributorMovieID INT NOT NULL,
	ShowCancelledOn DATETIME NULL,
	ShowCancelledByID INT NULL,
	[AdvanceTokenBufferTime] [int] NOT NULL,
	ManagerQuotaReleaseTime [INT] NOT NULL,
	[IsLocked] [BIT] NOT NULL DEFAULT(0),
	UnpaidBookingReleaseTime [INT] NOT NULL,
	LockShowTime INT NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	MovieMergedTo NVARCHAR(64) NULL,
 CONSTRAINT [PKC_ShowMIS_ShowID] PRIMARY KEY CLUSTERED
(
	[ShowID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Show]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Show](
	[ScreenID] [int] NOT NULL,
	[ShowID] [int] IDENTITY(1,1) NOT NULL,
	[ScreenNo] [varchar](2) NOT NULL,
	[ScreenName] [nvarchar](256) NOT NULL,
	[OnlineMovieID] [varchar](64) NOT NULL,
	[OnlineMovieName] [nvarchar](64) NOT NULL,
	[MovieName] [nvarchar](64) NOT NULL,
	[Experiences] [nvarchar](max) NOT NULL,
	[MovieLanguageType] [tinyint] NOT NULL,
	[MovieCensorRatingType] [tinyint] NOT NULL,
	[ShowName] [varchar](25) NOT NULL,
	[ShowTime] [datetime] NOT NULL,
	[IsPaused] [bit] NOT NULL,
	[IsOnlinePaused] BIT NOT NULL,
	[IsOnlineEdit] [Bit] NOT NULL DEFAULT(1),
	[ResumeBefore] [int] NOT NULL,
	[AllowedUsers] [varchar](128) NOT NULL,
	[Duration] [int] NOT NULL,
	[IsCancel] [bit] NOT NULL,
	[IsOnlineCancel] [Bit] NOT NULL DEFAULT(0),
	[CancelRemarks] [varchar](300) NOT NULL,
	[IsOnlinePublish] [bit] NOT NULL,
	[OnlineShowId] [varchar](64) NOT NULL,
	[Uuid] [varchar](64) NOT NULL,
	[EntryTime] [int] NOT NULL,
	[IntervalTime] [int] NOT NULL,
	[ExitTime] [int] NOT NULL,
	[IsAdvanceToken] [BIT],
	[IsDisplaySeatNos] [BIT],
	[IsOnlineSaleClosed] [BIT] NOT NULL DEFAULT(0),
	[IsSalesDataSent] [BIT] NOT NULL DEFAULT(0),
	[IsPrintTicketAmount] [BIT] NOT NULL DEFAULT(1),
	[MaintenanceCharge] [NUMERIC](9, 2) NOT NULL DEFAULT('0.00'),
	[IsPrintSlip] [BIT] NOT NULL DEFAULT(1),
	[IsPrintPriceInSlip] [BIT] NOT NULL DEFAULT(1),
	[AdvanceTokenReleaseTime] [int] NOT NULL,
	[IsBlockSalesDataSent] [BIT] NOT NULL DEFAULT(0),
	[IsRealTime] [BIT] NOT NULL DEFAULT(0),
	[CreationType] [BIT] NOT NULL DEFAULT(0),
	[IsSentBOSalesStatus] [BIT] NOT NULL DEFAULT(0),
	[IsHandoff] [BIT] NOT NULL DEFAULT(0),
	DistributorMovieID INT NOT NULL,
	ShowCancelledOn DATETIME NULL,
	ShowCancelledByID INT NULL,
	[AdvanceTokenBufferTime] [int] NOT NULL,
	ManagerQuotaReleaseTime [INT] NOT NULL,
	[IsLocked] [BIT] NOT NULL DEFAULT(0),
	UnpaidBookingReleaseTime [INT] NOT NULL,
	LockShowTime INT NOT NULL,
	[CreatedOn] [datetime] NOT NULL DEFAULT(GETDATE()),
	MovieMergedTo NVARCHAR(64) NULL,
 CONSTRAINT [PK_Show] PRIMARY KEY CLUSTERED
(
	[ShowID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SeatMIS]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SeatMIS](
	[ScreenID] [int] NOT NULL,
	[ShowID] [int] NOT NULL,
	[ClassID] [int] NOT NULL,
	[ClassLayoutID] [int] NOT NULL,
	[SeatLayoutID] [int] NOT NULL,
	[TicketID] [int] NOT NULL,
	[SeatID] [int] NOT NULL,
	[DCRNo] [int] NOT NULL,
	[SeatType] [tinyint] NOT NULL,
	[SeatLabel] [varchar](8) NOT NULL,
	[RowNo] [int] NOT NULL,
	[ColNo] [int] NOT NULL,
	[PaymentType] [tinyint] NOT NULL,
	[PaymentReceived] [numeric](9, 2) NOT NULL,
	[StatusType] [tinyint] NOT NULL,
	[QuotaServicerID] [int] NOT NULL,
	[QuotaServicerName] [varchar](32) NOT NULL,
	[QuotaType] [tinyint] NOT NULL,
	[ReleaseBefore] [int] NOT NULL,
	[PatronInfo] [varchar](256) NOT NULL,
	[PatronFee] [numeric](9, 2) NOT NULL,
	[NoBlocks] [int] NOT NULL,
	[NoSales] [int] NOT NULL,
	[NoPrints] [int] NOT NULL,
	[NoOccupies] [int] NOT NULL,
	[NoCancels] [int] NOT NULL,
	[LastBlockedByID] [int] NOT NULL,
	[LastSoldByID] [int] NOT NULL,
	[LastPrintedByID] [int] NOT NULL,
	[LastOccupiedByID] [int] NOT NULL,
	[LastCancelledByID] [int] NOT NULL,
	[LastSoldOn] [datetime] NULL,
	[LastCancelledOn] [datetime] NULL,
	[LastBlockedOn] [datetime] NULL,
	[LastOccupiedOn] [datetime] NULL,
	[LastPrintedOn] [datetime] NULL,
	[PriceCardId] [int] NOT NULL,
	[CoupleSeatIds] NVARCHAR(50) NULL,
	[SeatClassInfo] NVARCHAR(30) NULL,
 CONSTRAINT [PKC_SeatMIS_SeatID] PRIMARY KEY CLUSTERED
(
	[SeatID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SeatLayout]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SeatLayout](
	[ScreenID] [int] NOT NULL,
	[ClassLayoutID] [int] NOT NULL,
	[SeatLayoutID] [int] IDENTITY(1,1) NOT NULL,
	[SeatType] [tinyint] NOT NULL,
	[SeatLabel] [varchar](8) NOT NULL,
	[RowNo] [int] NOT NULL,
	[ColNo] [int] NOT NULL,
	[QuotaType] [tinyint] NOT NULL,
	[ReleaseBefore] [int] NOT NULL,
	[PriceCardId] [int] NOT NULL,
	[CoupleSeatIds] NVARCHAR(50) NULL,
 CONSTRAINT [PKC_SeatLayout_SeatLayoutID] PRIMARY KEY CLUSTERED
(
	[SeatLayoutID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Seat]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Seat](
	[ScreenID] [int] NOT NULL,
	[ShowID] [int] NOT NULL,
	[ClassID] [int] NOT NULL,
	[ClassLayoutID] [int] NOT NULL,
	[SeatLayoutID] [int] NOT NULL,
	[TicketID] [int] NOT NULL,
	[SeatID] [int] IDENTITY(1,1) NOT NULL,
	[DCRNo] [int] NOT NULL,
	[SeatType] [tinyint] NOT NULL,
	[SeatLabel] [varchar](8) NOT NULL,
	[RowNo] [int] NOT NULL,
	[ColNo] [int] NOT NULL,
	[PaymentType] [tinyint] NOT NULL,
	[PaymentReceived] [numeric](9, 2) NOT NULL,
	[StatusType] [tinyint] NOT NULL,
	[QuotaServicerID] [int] NOT NULL,
	[QuotaServicerName] [varchar](32) NOT NULL,
	[QuotaType] [tinyint] NOT NULL,
	[ReleaseBefore] [int] NOT NULL,
	[PatronInfo] [varchar](256) NOT NULL,
	[PatronFee] [numeric](9, 2) NOT NULL,
	[NoBlocks] [int] NOT NULL,
	[NoSales] [int] NOT NULL,
	[NoPrints] [int] NOT NULL,
	[NoOccupies] [int] NOT NULL,
	[NoCancels] [int] NOT NULL,
	[LastBlockedByID] [int] NOT NULL,
	[LastSoldByID] [int] NOT NULL,
	[LastPrintedByID] [int] NOT NULL,
	[LastOccupiedByID] [int] NOT NULL,
	[LastCancelledByID] [int] NOT NULL,
	[LastSoldOn] [datetime] NULL,
	[LastCancelledOn] [datetime] NULL,
	[LastBlockedOn] [datetime] NULL,
	[LastOccupiedOn] [datetime] NULL,
	[LastPrintedOn] [datetime] NULL,
	[PriceCardId] [int] NOT NULL,
	[CoupleSeatIds] NVARCHAR(50) NULL,
	[SeatClassInfo] NVARCHAR(30) NULL,
 CONSTRAINT [PKC_Seat_SeatID] PRIMARY KEY CLUSTERED
(
	[SeatID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* [Screen] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Screen]') AND type in (N'U'))
DROP TABLE [dbo].[Screen]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Screen](
	[ScreenID] [int] IDENTITY(1,1) NOT NULL,
	[ScreenNo] [varchar](2) NOT NULL,
	[Code] [varchar](2) NOT NULL,
	[ScreenName] [nvarchar](256) NOT NULL,
	[IsFoodBeverages] [bit] NOT NULL,
	[IsAdvanceToken] [bit] NOT NULL,
	[IsDisplaySeatNos] [bit] NOT NULL,
	[IsPrintTicketAmount] [BIT] NOT NULL DEFAULT(1),
	[IsPrintSlip] [BIT] NOT NULL DEFAULT(1),
	[IsPrintPriceInSlip] [BIT] NOT NULL DEFAULT(1),
	[PrintSlipSize] [INT] NOT NULL DEFAULT(1),
	[ComplexID] [int] NOT NULL,
	[ScreenGUID] [varchar](64) NOT NULL,
	[AdvanceTokenReleaseTime] [int] NOT NULL,
	[IsRealTime] [bit] NOT NULL DEFAULT(0),
	[AdvanceTokenBufferTime] INT NOT NULL,
	ManagerQuotaReleaseTime [INT] NOT NULL,
	UnpaidBookingReleaseTime [INT] NOT NULL,
	[Experiences] [nvarchar](max) NOT NULL,
	[CoolingType] [nvarchar](100) NOT NULL,
	NumberOfShowsAllowed [TINYINT] NOT NULL,
	[ScreenType] TINYINT NOT NULL,
 CONSTRAINT [PKC_Screen_ScreenID] PRIMARY KEY CLUSTERED
(
	[ScreenID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Report]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Report](
	[ReportID] [int] IDENTITY(1,1) NOT NULL,
	[PhaseName] [varchar](32) NOT NULL,
	[TableName] [varchar](32) NOT NULL,
	[ReportName] [varchar](64) NOT NULL,
 CONSTRAINT [PKC_Report_ReportID] PRIMARY KEY CLUSTERED
(
	[ReportID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/* [PriceCardDetails] */

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_PriceCardDetails_Price]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[PriceCardDetails] DROP CONSTRAINT [DF_PriceCardDetails_Price]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_PriceCardDetails_PriceCardId]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[PriceCardDetails] DROP CONSTRAINT [DF_PriceCardDetails_PriceCardId]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceCardDetails]') AND type in (N'U'))
DROP TABLE [dbo].[PriceCardDetails]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[PriceCardDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](32) NOT NULL,
	[Name] [varchar](32) NOT NULL,
	[Price] [numeric](9, 2) NOT NULL,
	[Type] [nvarchar](100) NULL,
	[PriceCardId] [int] NOT NULL,
	[CalculationType] [nvarchar](100) NOT NULL,
	[ValueByCalculationType] [numeric](9, 2) NOT NULL,
	[ApplyGST] BIT NOT NULL,
 CONSTRAINT [PK_PriceCardDetails] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Discount, 1 - Surcharge' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceCardDetails', @level2type=N'COLUMN',@level2name=N'Type'
GO

ALTER TABLE [dbo].[PriceCardDetails] ADD  CONSTRAINT [DF_PriceCardDetails_Price]  DEFAULT ((0)) FOR [Price]
GO

ALTER TABLE [dbo].[PriceCardDetails] ADD  CONSTRAINT [DF_PriceCardDetails_PriceCardId]  DEFAULT ((0)) FOR [PriceCardId]
GO

/****** Object:  Table [dbo].[PriceCard]    Script Date: 08/27/2014 11:05:49 ******/
/* [Screen] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceCard]') AND type in (N'U'))
DROP TABLE [dbo].[PriceCard]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceCard](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name]  NVARCHAR(100) NOT NULL,
	[TicketType] TINYINT NOT NULL,
	[Amount] [numeric](9, 2) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[IsDeleted] BIT DEFAULT(0) NOT NULL,
	[TheatreType]  NVARCHAR(100) NOT NULL,
	[CoolingType]  NVARCHAR(100) NOT NULL,
	[TownType]  NVARCHAR(100) NOT NULL,
	[ScreenType] TINYINT NOT NULL DEFAULT (0),
	[ClassType] TINYINT NOT NULL DEFAULT (0),
	[PriceCardGuid] NVARCHAR(100) NOT NULL,
 CONSTRAINT [PK_PriceCard] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[ParkingType]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ParkingType](
	[ParkingTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ParkingType] [varchar](50) NOT NULL,
	[Price] [numeric](10, 2) NOT NULL,
 CONSTRAINT [PK_ParkingType] PRIMARY KEY CLUSTERED
(
	[ParkingTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Parking]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parking](
	[ParkingID] [int] IDENTITY(1,1) NOT NULL,
	[ParkingTypeID] [int] NOT NULL,
	[ParkingAmount] [numeric](9, 2) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[FromTime] [datetime] NOT NULL,
	[ToTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Parking] PRIMARY KEY CLUSTERED
(
	[ParkingID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LogMIS]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogMIS](
	[LogID] [int] NOT NULL,
	[TableType] [tinyint] NOT NULL,
	[ObjectID] [int] NOT NULL,
	[ObjectName] [varchar](16) NOT NULL,
	[TransactionType] [tinyint] NOT NULL,
	[TransactionLogType] [tinyint] NOT NULL,
	[TransactionDetail] [varchar](2048) NOT NULL,
	[TransactionTime] [datetime] NOT NULL,
	[TransactionByIP] [varchar](48) NOT NULL,
	[TransactionByID] [int] NOT NULL,
	[TransactionByName] [varchar](16) NOT NULL,
	[Action] [varchar](100) NOT NULL,
 CONSTRAINT [PKC_LogMIS_LogID] PRIMARY KEY CLUSTERED
(
	[LogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Log]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Log](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[TableType] [tinyint] NOT NULL,
	[ObjectID] [int] NOT NULL,
	[ObjectName] [varchar](16) NOT NULL,
	[TransactionType] [tinyint] NOT NULL,
	[TransactionLogType] [tinyint] NOT NULL,
	[TransactionDetail] [varchar](2048) NOT NULL,
	[TransactionTime] [datetime] NOT NULL,
	[TransactionByIP] [varchar](48) NOT NULL,
	[TransactionByID] [int] NOT NULL,
	[TransactionByName] [varchar](16) NOT NULL,
	[Action] [varchar](100) NOT NULL,
 CONSTRAINT [PKC_Log_LogID] PRIMARY KEY CLUSTERED
(
	[LogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* Table [ItemStock] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemStock]') AND type in (N'U'))
DROP TABLE [dbo].[ItemStock]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemStock](
	[ItemStockID] INT IDENTITY(1,1) NOT NULL,
	[ItemID] INT NOT NULL,
	[VendorID] INT NOT NULL,
	[Quantity] INT NOT NULL,
	[AvailableQuantity] INT NOT NULL,
	[Cost] NUMERIC(9,2) NOT NULL,
	[StockType] INT NOT NULL,
	[CreatedOn] DATETIME NOT NULL,
	[CreatedBy] INT NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ItemIngredientStock]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemIngredientStock](
	[IngredientId] [int] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Quantity] [numeric](10, 2) NOT NULL,
	[StockType] [int] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ItemIngredient]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemIngredient](
	[IngredientId] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NOT NULL,
	[ItemName] [varchar](50) NOT NULL,
	[Quantity] [numeric](10, 2) NOT NULL,
	[Cost] [numeric](10, 2) NOT NULL,
	[Metric] [varchar](50) NOT NULL,
	[TransactionTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ItemIngrediant] PRIMARY KEY CLUSTERED
(
	[IngredientId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Item]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Item](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [varchar](16) NOT NULL,
	[Price] [numeric](9, 2) NOT NULL,
	[Tax] [numeric](9, 2) NOT NULL,
	[VAT] [numeric](9, 2) NOT NULL,
	[ComboItems] [varchar](128) NOT NULL,
	[Quantity] [int] NOT NULL,
	[IsOnline] [bit] NOT NULL,
	[Shortcut] [varchar](4) NOT NULL,
	[GroupNo] [varchar](2) NOT NULL,
	[Cost] [numeric](9, 2) NOT NULL,
	[IsIngredients] [bit] NOT NULL,
	[HeadId] [int] NULL,
 CONSTRAINT [PKC_Item_ItemID] PRIMARY KEY CLUSTERED
(
	[ItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_Item_ItemName] UNIQUE NONCLUSTERED
(
	[ItemName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DCR]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DCR](
	[DCRID] [INT] IDENTITY(1,1) NOT NULL,
	[DCRName] [VARCHAR](32) NOT NULL,
	[DCRStartingNo] [INT] NOT NULL,
	[DCRMax] [INT] NOT NULL,
	[DCRNo] [INT] NOT NULL,
	[DCRCount] [INT] NOT NULL,
	[CreatedBy] [INT] NOT NULL,
    [CreatedOn] [DATETIME] NOT NULL,
 CONSTRAINT [PKC_DCR_DCRID] PRIMARY KEY CLUSTERED
(
	[DCRID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_DCR_DCRName] UNIQUE NONCLUSTERED
(
	[DCRName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF

GO
/****** Object:  Table [dbo].[Complex]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Complex](
	[ComplexID] [int] IDENTITY(1,1) NOT NULL,
	[ComplexName] [nvarchar](64) NOT NULL,
	[ComplexType] [tinyint] NOT NULL,
	[ComplexAddress1] [varchar](64) NOT NULL,
	[ComplexAddress2] [varchar](64) NOT NULL,
	[ComplexCity] [varchar](32) NOT NULL,
	[ComplexState] [varchar](32) NOT NULL,
	[ComplexCountry] [varchar](32) NOT NULL,
	[ComplexZip] [varchar](8) NOT NULL,
	[ComplexPhone] [varchar](32) NOT NULL,
	[ComplexEmail] [varchar](64) NOT NULL,
	[TransactionLogType] [tinyint] NOT NULL,
	[LastMaintenanceTime] [datetime] NOT NULL,
	[BoxOfficeID] [int] NOT NULL,
	[BoxOfficeName] [varchar](32) NOT NULL,
	[BoxOfficeVersion] [varchar](16) NOT NULL,
	[BoxOfficeLicenseType] [tinyint] NOT NULL,
	[BoxOfficeLicenseFrom] [datetime] NOT NULL,
	[BoxOfficeLicenseTo] [datetime] NOT NULL,
	[BoxOfficeLicenseKey] [varchar](32) NOT NULL,
	[IsWebService] [bit] NOT NULL,
	[CentralServerName] [varchar](32) NOT NULL,
	[CentralServerURL] [varchar](64) NOT NULL,
	[CentralServerPassword] [varchar](32) NOT NULL,
	[MovieImageURL] [varchar](128) NOT NULL,
	[BoxOfficeURL] [varchar](128) NOT NULL,
	[IsAllowBlocking] [bit] NOT NULL,
	[NoMaxSeatsPerTicket] [int] NOT NULL,
	[IsSendSeatSoldEvent] [bit] NOT NULL,
	[IsSendSeatOccupiedEvent] [bit] NOT NULL,
	[IsSendSeatCancelledEvent] [bit] NOT NULL,
	[IsStaticIP] [bit] NOT NULL,
	[StaticIP] [varchar](128) NOT NULL,
	[GSTIN] [varchar](15) NULL,
	[SAC] [int] NULL,
	[ChainID] [int] NOT NULL,
	[ComplexGUID] [varchar](64) NOT NULL,
	[ChainGUID] [varchar](64) NOT NULL,
	[ChainName] [varchar](64) NOT NULL,
	IsClearExpiredShows BIT NOT NULL DEFAULT(0),
	HandoffTime [Time] NOT NULL CONSTRAINT DF_HandoffTimeComplex DEFAULT ('22:30:00'),
	LastAutomaticHandoffDate DATE NOT NULL CONSTRAINT DF_LastAutomaticHandoffDateComplex DEFAULT (CONVERT(VARCHAR(10),GETDATE()-1,110)),
	[IsFandBBillWithTaxBreakUp] [bit] NOT NULL,
	LockShowTime INT NOT NULL DEFAULT(120),
	IsSC BIT NOT NULL DEFAULT(1),
	AT INT NOT NULL DEFAULT(1),
	ET INT NOT NULL DEFAULT(1),
	IsPrintADP BIT NOT NULL DEFAULT(0),
	IsHighlightScreenNameOnTicket BIT NOT NULL DEFAULT(1),
	IsDisplaySCNumberDiv BIT NOT NULL CONSTRAINT DF_IsDisplaySCNumberDiv DEFAULT(0),
	IsDisplayShowNameOn3x3 BIT NOT NULL CONSTRAINT DF_IsDisplayShowNameOn3x3 DEFAULT(0),
	IsPrintTandCOn3x3 BIT NOT NULL CONSTRAINT DF_IsPrintTandCOn3x3 DEFAULT(0),
	IsETaxIncludesFDF BIT NOT NULL DEFAULT(0),
	IsPrintETaxIncludesFDF BIT NOT NULL DEFAULT(0),
	IsPrintRefundTextOn6x3TktFormat BIT NOT NULL DEFAULT(0),
	IsAutoSessionSync BIT NOT NULL DEFAULT(1),
	IsNotifyOnCB BIT NOT NULL DEFAULT(0),
	IsMobileMandatoryOnCB BIT NOT NULL DEFAULT(0),
	[TheatreType] [nvarchar](100) NOT NULL DEFAULT(''),
	[TownType] [nvarchar](100) NOT NULL  DEFAULT('')
 CONSTRAINT [PKC_Complex_ComplexID] PRIMARY KEY CLUSTERED
(
	[ComplexID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassMIS]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClassMIS](
	[ScreenID] [int] NOT NULL,
	[ShowID] [int] NOT NULL,
	[ClassID] [int] NOT NULL,
	[ClassLayoutID] [int] NOT NULL,
	[ClassNo] [varchar](2) NOT NULL,
	[ClassName] [varchar](16) NOT NULL,
	[NoRows] [int] NOT NULL,
	[NoCols] [int] NOT NULL,
	[DCRID] [int] NOT NULL,
	[OpeningDCRNo] [int] NULL,
	[ClosingDCRNo] [int] NULL,
	[Price] [numeric](9, 2) NOT NULL,
	[ETax] [numeric](9, 2) NOT NULL,
	[ATax] [numeric](9, 2) NOT NULL,
	[MC] [numeric](9, 2) NOT NULL,
	[BlockFee] [numeric](9, 2) NOT NULL,
	[NoMaxSeatsPerTicket] [int] NOT NULL,
	[AllowedUsers] [varchar](128) NOT NULL,
	[PriceCardId] [int] NOT NULL,
	[IsPrintSeatLabel] BIT NOT NULL DEFAULT(1),
 CONSTRAINT [PKC_ClassMIS_ClassID] PRIMARY KEY CLUSTERED
(
	[ClassID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassLayout]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClassLayout](
	[ScreenID] [int] NOT NULL,
	[ClassLayoutID] [int] IDENTITY(1,1) NOT NULL,
	[ClassNo] [varchar](2) NOT NULL,
	[ClassName] [varchar](16) NOT NULL,
	[NoRows] [int] NOT NULL,
	[NoCols] [int] NOT NULL,
	[NoMaxSeatsPerTicket] [int] NOT NULL,
	[IsPrintOneTicketPerSeat] [bit] NOT NULL,
	[PrintType] [tinyint] NOT NULL,
	[PrintOrientationType] [tinyint] NOT NULL,
	[IsPrintAuditNos] [bit] NOT NULL,
	[IsPrintDCRNo] [bit] NOT NULL,
	[IsPrintSeatLabel] [BIT] NOT NULL DEFAULT(1),
	[AllowedUsers] [varchar](128) NOT NULL,
	PriceCardId INT NOT NULL CONSTRAINT DF_PriceCardIdClassLayout DEFAULT (0),
	DCRId INT NOT NULL CONSTRAINT DF_DCRIdClassLayout DEFAULT (0),
	[ClassPosition] [varchar](4) NOT NULL,
	ClassType TINYINT NOT NULL DEFAULT (0),
CONSTRAINT [PKC_ClassLayout_ClassLayoutID] PRIMARY KEY CLUSTERED
(
	[ClassLayoutID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Class]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Class](
	[ScreenID] [int] NOT NULL,
	[ShowID] [int] NOT NULL,
	[ClassID] [int] IDENTITY(1,1) NOT NULL,
	[ClassLayoutID] [int] NOT NULL,
	[ClassNo] [varchar](2) NOT NULL,
	[ClassName] [varchar](16) NOT NULL,
	[NoRows] [int] NOT NULL,
	[NoCols] [int] NOT NULL,
	[DCRID] [int] NOT NULL,
	[OpeningDCRNo] [int] NULL,
	[ClosingDCRNo] [int] NULL,
	[Price] [numeric](9, 2) NOT NULL,
	[ETax] [numeric](9, 2) NOT NULL,
	[ATax] [numeric](9, 2) NOT NULL,
	[MC] [numeric](9, 2) NOT NULL,
	[BlockFee] [numeric](9, 2) NOT NULL,
	[NoMaxSeatsPerTicket] [int] NOT NULL,
	[AllowedUsers] [varchar](128) NOT NULL,
	[PriceCardId] [int] NOT NULL,
	[IsPrintSeatLabel] BIT NOT NULL DEFAULT(1),
 CONSTRAINT [PKC_Class_ClassID] PRIMARY KEY CLUSTERED
(
	[ClassID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Chain]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Chain](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](64) NOT NULL,
	[City] [varchar](32) NOT NULL,
	[Pin] [varchar](8) NOT NULL,
	[GUID] [varchar](32) NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_Chain] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0- InActive, 1-Active, 2- Delete' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Chain', @level2type=N'COLUMN',@level2name=N'Status'
GO
/****** Object:  Table [dbo].[CanteenMIS]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CanteenMIS](
	[BillID] [int] NOT NULL,
	[TransactionID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[ItemName] [varchar](16) NOT NULL,
	[BillType] [tinyint] NOT NULL,
	[Price] [numeric](9, 2) NOT NULL,
	[Tax] [numeric](9, 2) NOT NULL,
	[VAT] [numeric](9, 2) NOT NULL,
	[ComboItems] [varchar](128) NOT NULL,
	[Quantity] [int] NOT NULL,
	[PaymentType] [tinyint] NOT NULL,
	[PaymentReceived] [numeric](9, 2) NOT NULL,
	[QuotaServicerID] [int] NOT NULL,
	[QuotaServicerName] [varchar](32) NOT NULL,
	[QuotaType] [tinyint] NOT NULL,
	[SeatID] [int] NOT NULL,
	[ShowTime] [datetime] NOT NULL,
	[PatronInfo] [varchar](256) NOT NULL,
	[BilledByID] [int] NOT NULL,
	[TransactionTime] [datetime] NOT NULL,
	[ComplexID] [int] NOT NULL,
 CONSTRAINT [PKC_CanteenMIS_TransactionID] PRIMARY KEY CLUSTERED
(
	[TransactionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CanteenIngredient]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CanteenIngredient](
	[BillID] [int] NOT NULL,
	[BillType] [int] NOT NULL,
	[TransactionTime] [datetime] NOT NULL,
	[ItemID] [int] NOT NULL,
	[IngredientId] [int] NOT NULL,
	[ItemName] [varchar](50) NOT NULL,
	[Quantity] [numeric](10, 2) NOT NULL,
	[Cost] [numeric](10, 2) NOT NULL,
	[Metric] [varchar](50) NOT NULL,
	[BilledById] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Canteen]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Canteen](
	[BillID] [int] NOT NULL,
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[ItemID] [int] NOT NULL,
	[ItemName] [varchar](16) NOT NULL,
	[BillType] [tinyint] NOT NULL,
	[Price] [numeric](9, 2) NOT NULL,
	[Tax] [numeric](9, 2) NOT NULL,
	[VAT] [numeric](9, 2) NOT NULL,
	[ComboItems] [varchar](128) NOT NULL,
	[Quantity] [int] NOT NULL,
	[PaymentType] [tinyint] NOT NULL,
	[PaymentReceived] [numeric](9, 2) NOT NULL,
	[QuotaServicerID] [int] NOT NULL,
	[QuotaServicerName] [varchar](32) NOT NULL,
	[QuotaType] [tinyint] NOT NULL,
	[SeatID] [int] NOT NULL,
	[ShowTime] [datetime] NOT NULL,
	[PatronInfo] [varchar](256) NOT NULL,
	[BilledByID] [int] NOT NULL,
	[TransactionTime] [datetime] NOT NULL,
	[ComplexID] [int] NOT NULL,
 CONSTRAINT [PKC_Canteen_TransactionID] PRIMARY KEY CLUSTERED
(
	[TransactionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BoxOfficeUser]    Script Date: 08/27/2014 11:05:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BoxOfficeUser](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](16) NOT NULL,
	[Password] [varchar](100) NOT NULL,
	[UserRoleType] [tinyint] NOT NULL,
	[NoFailedLoginAttempts] [tinyint] NOT NULL,
	[LastLoggedInIP] [varchar](48) NOT NULL,
	[IsSingleSession] [bit] NOT NULL,
	[IsUserEnabled] [bit] NOT NULL,
	[StartPageType] [tinyint] NOT NULL,
	[NoMaxVisibleShowDays] [tinyint] NOT NULL,
	[NoMinsToLockAfterShowTime] [int] NOT NULL,
	[IsEditBoxOfficeSettings] [bit] NOT NULL,
	[IsEditComplexSettings] [bit] NOT NULL,
	[IsListUsers] [bit] NOT NULL,
	[IsEditUser] [bit] NOT NULL,
	[IsDeleteUser] [bit] NOT NULL,
	[IsListScreens] [bit] NOT NULL,
	[IsEditScreen] [bit] NOT NULL,
	[IsDeleteScreen] [bit] NOT NULL,
	[IsListDCRs] [bit] NOT NULL,
	[IsEditDCR] [bit] NOT NULL,
	[IsDeleteDCR] [bit] NOT NULL,
	[IsListShows] [bit] NOT NULL,
	[IsEditShow] [bit] NOT NULL,
	[IsDeleteShow] [bit] NOT NULL,
	[IsReleaseOnlineSeats] [BIT] NOT NULL DEFAULT(0),
	[IsEditSeat] [bit] NOT NULL,
	[IsEditSeatBlock] [bit] NOT NULL,
	[IsEditSeatSell] [bit] NOT NULL,
	[IsEditSeatCancel] [bit] NOT NULL,
	[IsEditSeatOccupy] [bit] NOT NULL,
	[IsRePrintSoldSeat] [bit] NOT NULL,
	[IsViewKioskInterface] [bit] NOT NULL,
	[IsViewQRSentry] [bit] NOT NULL,
	[IsViewBookingStatusDisplay] [bit] NOT NULL,
	[IsListCanteenItems] [bit] NOT NULL,
	[IsFoodBillReprint] [bit] NOT NULL,
	[IsListReports] [bit] NOT NULL,
	[IsPrintInternetTicket] [bit] NOT NULL,
	[IsSellManagerQuotaBlockedTicket] [bit] NOT NULL,
	[IsSendtoOnline] [bit] NOT NULL,
	[IsFoodBillCancel] [bit] NOT NULL,
	[IsEditCanteenPurchase] [bit] NOT NULL,
	[IsListParkingTypes] [bit] NOT NULL,
	[IsEditParkingTypes] [bit] NOT NULL,
	[IsDeleteParkingTypes] [bit] NOT NULL,
	[IsListParkingEntry] [bit] NOT NULL,
	[IsViewCancel] [bit] NOT NULL,
	[IsDCRReport] [bit] NOT NULL,
	[IsAdvanceSalesSummaryReport] [bit] NOT NULL,
	[IsTransactionReport] [bit] NOT NULL,
	[IsPerformanceReport] [bit] NOT NULL Default (0),
	[IsAuditRefundReport] [bit] NOT NULL Default (0),
	[IsCashierReport] [bit] NOT NULL Default (0),
	[IsMarketingReport] [bit] NOT NULL Default (0),
	[IsQuickTicketsSalesSummaryReport] [bit] NOT NULL Default (0),
	[IsScreeningSchedule] [bit] NOT NULL Default (0),
	[IsConcessionReport] [bit] NOT NULL Default (0),
	[IsAllowManagerQuotaBooking] [bit] NOT NULL Default (0),
	[IsHandoff] [BIT] NOT NULL DEFAULT (0),
	[IsManageDistributor] [BIT] NOT NULL DEFAULT (0),
	[IsDistributorReport] [BIT] NOT NULL DEFAULT (0),
	[IsBoxOfficeReceiptsSummary] [BIT] NOT NULL DEFAULT (0),
	[IsCompleteSalesSummaryInfo] [BIT] NOT NULL DEFAULT (0),
	[IsPrintSalesSummaryInfo] [BIT] NOT NULL DEFAULT (0),
	[IsBoxOfficeSummary] [BIT] NOT NULL DEFAULT(0),
	IsCancelledShowDetails [BIT] NOT NULL DEFAULT(0),
	IsManageVendor [BIT] NOT NULL DEFAULT(0),
	IsManageIngredients [BIT] NOT NULL DEFAULT(0),
	IsManageItems [BIT] NOT NULL DEFAULT(0),
	IsManageCounter [BIT] NOT NULL DEFAULT(0),
	IsManageSetupOrder BIT NOT NULL DEFAULT(0),
	IsItemSalesReport BIT NOT NULL DEFAULT(0),
	IsProductSalesReport BIT NOT NULL DEFAULT(0),
	IsDailyCollectionSummaryReport BIT NOT NULL DEFAULT(0),
	IsFourWeeklyReport BIT NOT NULL DEFAULT(0),
	IsWeeklyReport BIT NOT NULL DEFAULT(0),
	IsFormBReport BIT NOT NULL DEFAULT(0),
	IsForm3BReport BIT NOT NULL DEFAULT(0),
	IsForm17Report BIT NOT NULL DEFAULT(0),
	IsForm3Report BIT NOT NULL DEFAULT(0),
	IsFourWeeklyPercentageReport BIT NOT NULL DEFAULT(0),
	IsEastMarketReport BIT NOT NULL DEFAULT(0),
	IsMunicipalTaxReport BIT NOT NULL DEFAULT(0),
	IsTaxLossReport BIT NOT NULL DEFAULT(0),
	IsUserwisePaymentTypeSummaryReport BIT NOT NULL DEFAULT(0),
 CONSTRAINT [PKC_BoxOfficeUser_UserID] PRIMARY KEY CLUSTERED
(
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_BoxOfficeUser_UserName] UNIQUE NONCLUSTERED
(
	[UserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/* [ChangeQuotaDetails] */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChangeQuotaDetails]') AND type in (N'U'))
DROP TABLE [dbo].[ChangeQuotaDetails]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ChangeQuotaDetails](
	[SeatId] INT NOT NULL,
	[SeatClassInfo] VARCHAR(30) NOT NULL,
	[ChangeQuotaType] INT NULL,
	[ReferenceId] UNIQUEIDENTIFIER NULL,
	[Status] BIT NOT NULL,
	[Approved] BIT NOT NULL
) ON [PRIMARY]

GO

/* BlockHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BlockHistory]') AND type in (N'U'))
DROP TABLE [dbo].[BlockHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlockHistory](
    [ShowId] [INT] NOT NULL,
    [SeatId] [INT] NOT NULL,
    [SeatClassInfo] [NVARCHAR](30) NOT NULL,
    [PatronInfo] [NVARCHAR](256) NOT NULL,
    [BlockCode] [NVARCHAR](36) NOT NULL,
    [BlockedById] [INT] NOT NULL,
    [BlockedOn] [DATETIME] NOT NULL,
	[ExpiresAt] [DATETIME] NOT NULL
) ON [PRIMARY]
GO

/* BookHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BookHistory]') AND type in (N'U'))
DROP TABLE [dbo].[BookHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BookHistory](
    [ShowId] [INT] NOT NULL,
    [SeatId] [INT] NOT NULL,
    [SeatClassInfo] [NVARCHAR](30) NOT NULL,
    [BlockCode] [NVARCHAR](36) NOT NULL,
    [BEBookingCode] [NVARCHAR](8) NULL,
	[BOBookingCode] [NVARCHAR](8) NULL,
    [PatronInfo] [NVARCHAR](256) NULL,
    [BookedByID] [INT] NOT NULL,
    [BookedOn] [DATETIME] NOT NULL,
	[PaymentType] [tinyint] NOT NULL,
    [PriceCardId] [INT] NOT NULL,
	ItemTransactionID VARCHAR(10) NULL,
	[IsReconciled] BIT NOT NULL DEFAULT(0),
	TicketID INT NULL,
	ShouldNotify BIT NOT NULL DEFAULT(0),
	Notified BIT NOT NULL DEFAULT(0)
) ON [PRIMARY]
GO

/* CancelHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CancelHistory]') AND type in (N'U'))
DROP TABLE [dbo].[CancelHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CancelHistory](
    [ShowId] [INT] NOT NULL,
    [SeatID] [int] NOT NULL,
	[SeatClassInfo] [NVARCHAR](30) NOT NULL,
    [CancelledByID] [int] NOT NULL,
    [CancelledOn] [datetime] NOT NULL,
	[PriceCardId] [INT] NOT NULL,
	[BookedOn] [datetime] NOT NULL,
	[BookedPaymentType] [tinyint] NOT NULL,
	PatronInfo [NVARCHAR](256) NULL,
	TicketID INT NULL,
	ShouldNotify BIT NOT NULL DEFAULT(0),
	Notified BIT NOT NULL DEFAULT(0)
) ON [PRIMARY]
GO

/* UnpaidBookings */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UnpaidBookings]') AND type in (N'U'))
DROP TABLE [dbo].[UnpaidBookings]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UnpaidBookings](
    [ShowId] [INT] NOT NULL,
	[SeatId] [INT] NOT NULL,
	[OnlineShowId] [NVARCHAR](64) NOT NULL,
    [SeatClassInfo] [NVARCHAR](30) NOT NULL,
	[BookingCode] [NVARCHAR](8) NOT NULL,
	[UserName] [NVARCHAR](256) NOT NULL,
	[EmailId] [NVARCHAR](256) NULL,
	[MobileNumber] [BIGINT] NOT NULL,
    [ReleaseTime] [INT] NOT NULL,
	[BookedByID] [INT] NOT NULL,
    [BookedOn] [DATETIME] NOT NULL,
	[IsSent] BIT NOT NULL DEFAULT(0)
)
GO

/* ShowSyncJobs */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ShowSyncJobs]') AND type in (N'U'))
DROP TABLE [dbo].ShowSyncJobs
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].ShowSyncJobs(
	[Id] UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    [ShowId] [INT] NOT NULL,
	[OnlineShowId] [NVARCHAR](64) NOT NULL,
	[Status] BIT NOT NULL DEFAULT(0),
	[Data] NVARCHAR(MAX) NULL
)
GO

/* ReprintHistory */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReprintHistory]') AND type in (N'U'))
DROP TABLE [dbo].ReprintHistory
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].ReprintHistory(
    [ShowId] [INT] NOT NULL,
    [SeatID] [INT] NOT NULL,
	[SeatClassInfo] [NVARCHAR](30) NOT NULL,
    [PrintedByID] [INT] NOT NULL,
    [PrintedOn] [DATETIME] NOT NULL,
	[PriceCardId] [INT] NOT NULL,
	[BookedOn] [DATETIME] NOT NULL,
	[BookedPaymentType] [TINYINT] NOT NULL,
	PatronInfo [NVARCHAR](256) NULL,
	TicketID INT NULL,
	ShouldNotify BIT NOT NULL DEFAULT(0),
	Notified BIT NOT NULL DEFAULT(0)
) ON [PRIMARY]
GO

/****** Object:  Default [DF__BoxOffice__UserN__17036CC0]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ('') FOR [UserName]
GO
/****** Object:  Default [DF__BoxOffice__Passw__17F790F9]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ('') FOR [Password]
GO
/****** Object:  Default [DF__BoxOffice__UserR__18EBB532]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((7)) FOR [UserRoleType]
GO
/****** Object:  Default [DF__BoxOffice__NoFai__19DFD96B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [NoFailedLoginAttempts]
GO
/****** Object:  Default [DF__BoxOffice__LastL__1AD3FDA4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ('') FOR [LastLoggedInIP]
GO
/****** Object:  Default [DF__BoxOffice__IsSin__1BC821DD]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsSingleSession]
GO
/****** Object:  Default [DF__BoxOffice__IsUse__1CBC4616]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsUserEnabled]
GO
/****** Object:  Default [DF__BoxOffice__Start__1DB06A4F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [StartPageType]
GO
/****** Object:  Default [DF__BoxOffice__NoMax__1EA48E88]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [NoMaxVisibleShowDays]
GO
/****** Object:  Default [DF__BoxOffice__NoMin__1F98B2C1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [NoMinsToLockAfterShowTime]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__208CD6FA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsEditBoxOfficeSettings]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__2180FB33]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsEditComplexSettings]
GO
/****** Object:  Default [DF__BoxOffice__IsLis__236943A5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsListUsers]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__245D67DE]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditUser]
GO
/****** Object:  Default [DF__BoxOffice__IsDel__25518C17]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsDeleteUser]
GO
/****** Object:  Default [DF__BoxOffice__IsLis__2645B050]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsListScreens]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__2739D489]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditScreen]
GO
/****** Object:  Default [DF__BoxOffice__IsDel__282DF8C2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsDeleteScreen]
GO
/****** Object:  Default [DF__BoxOffice__IsLis__29221CFB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsListDCRs]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__2A164134]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditDCR]
GO
/****** Object:  Default [DF__BoxOffice__IsDel__2B0A656D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsDeleteDCR]
GO
/****** Object:  Default [DF__BoxOffice__IsLis__2BFE89A6]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsListShows]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__2CF2ADDF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditShow]
GO
/****** Object:  Default [DF__BoxOffice__IsDel__2DE6D218]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsDeleteShow]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__2EDAF651]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditSeat]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__2FCF1A8A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsEditSeatBlock]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__30C33EC3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((1)) FOR [IsEditSeatSell]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__31B762FC]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditSeatCancel]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__32AB8735]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsEditSeatOccupy]
GO
/****** Object:  Default [DF__BoxOffice__IsReP__339FAB6E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsRePrintSoldSeat]
GO
/****** Object:  Default [DF__BoxOffice__IsVie__3493CFA7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsViewKioskInterface]
GO
/****** Object:  Default [DF__BoxOffice__IsVie__3587F3E0]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsViewQRSentry]
GO
/****** Object:  Default [DF__BoxOffice__IsVie__367C1819]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsViewBookingStatusDisplay]
GO
/****** Object:  Default [DF__BoxOffice__IsLis__3A4CA8FD]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsListCanteenItems]
GO
/****** Object:  Default [DF__BoxOffice__IsEdi__3B40CD36]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsFoodBillReprint]
GO
/****** Object:  Default [DF__BoxOffice__IsLis__3C34F16F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsListReports]
GO
/****** Object:  Default [DF__BoxOffice__IsPri__3D2915A8]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsPrintInternetTicket]
GO
/****** Object:  Default [DF__BoxOffice__IsSel__3E1D39E1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsSellManagerQuotaBlockedTicket]
GO
/****** Object:  Default [DF__BoxOffice__IsSen__3F115E1A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  DEFAULT ((0)) FOR [IsSendtoOnline]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsFoodBillCancel]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsFoodBillCancel]  DEFAULT ((0)) FOR [IsFoodBillCancel]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsEditCanteenPurchase]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsEditCanteenPurchase]  DEFAULT ((0)) FOR [IsEditCanteenPurchase]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsEditParkingEntry]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsEditParkingEntry]  DEFAULT ((0)) FOR [IsListParkingTypes]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsEditParkingType]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsEditParkingType]  DEFAULT ((0)) FOR [IsEditParkingTypes]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsDeleteParkingTypes]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsDeleteParkingTypes]  DEFAULT ((0)) FOR [IsDeleteParkingTypes]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsListParkingEntry]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsListParkingEntry]  DEFAULT ((0)) FOR [IsListParkingEntry]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsViewCancel]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsViewCancel]  DEFAULT ((0)) FOR [IsViewCancel]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsDCRReport]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsDCRReport]  DEFAULT ((0)) FOR [IsDCRReport]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsAdvanceSalesSummaryReport]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsAdvanceSalesSummaryReport]  DEFAULT ((0)) FOR [IsAdvanceSalesSummaryReport]
GO
/****** Object:  Default [DF_BoxOfficeUser_IsTransactionReport]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[BoxOfficeUser] ADD  CONSTRAINT [DF_BoxOfficeUser_IsTransactionReport]  DEFAULT ((0)) FOR [IsTransactionReport]
GO
/****** Object:  Default [DF__Canteen__BillID__55F4C372]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [BillID]
GO
/****** Object:  Default [DF__Canteen__ItemID__56E8E7AB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [ItemID]
GO
/****** Object:  Default [DF__Canteen__ItemNam__57DD0BE4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ('') FOR [ItemName]
GO
/****** Object:  Default [DF__Canteen__BillTyp__58D1301D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [BillType]
GO
/****** Object:  Default [DF__Canteen__Price__59C55456]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [Price]
GO
/****** Object:  Default [DF__Canteen__Tax__5AB9788F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [Tax]
GO
/****** Object:  Default [DF__Canteen__VAT__5BAD9CC8]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [VAT]
GO
/****** Object:  Default [DF__Canteen__ComboIt__5CA1C101]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ('') FOR [ComboItems]
GO
/****** Object:  Default [DF__Canteen__Quantit__5D95E53A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [Quantity]
GO
/****** Object:  Default [DF__Canteen__Payment__5E8A0973]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [PaymentType]
GO
/****** Object:  Default [DF__Canteen__Payment__5F7E2DAC]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [PaymentReceived]
GO
/****** Object:  Default [DF__Canteen__QuotaSe__607251E5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [QuotaServicerID]
GO
/****** Object:  Default [DF__Canteen__QuotaSe__6166761E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ('') FOR [QuotaServicerName]
GO
/****** Object:  Default [DF__Canteen__QuotaTy__625A9A57]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [QuotaType]
GO
/****** Object:  Default [DF__Canteen__SeatID__634EBE90]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [SeatID]
GO
/****** Object:  Default [DF__Canteen__ShowTim__6442E2C9]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT (getdate()) FOR [ShowTime]
GO
/****** Object:  Default [DF__Canteen__PatronI__65370702]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ('') FOR [PatronInfo]
GO
/****** Object:  Default [DF__Canteen__BilledB__662B2B3B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT ((0)) FOR [BilledByID]
GO
/****** Object:  Default [DF__Canteen__Transac__671F4F74]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Canteen] ADD  DEFAULT (getdate()) FOR [TransactionTime]
GO
/****** Object:  Default [DF_CanteenIngrediant_BillID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_BillID]  DEFAULT ((0)) FOR [BillID]
GO
/****** Object:  Default [DF_CanteenIngrediant_BillType]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_BillType]  DEFAULT ((0)) FOR [BillType]
GO
/****** Object:  Default [DF_CanteenIngrediant_TransactionTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_TransactionTime]  DEFAULT (getdate()) FOR [TransactionTime]
GO
/****** Object:  Default [DF_CanteenIngrediant_ItemID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_ItemID]  DEFAULT ((0)) FOR [ItemID]
GO
/****** Object:  Default [DF_CanteenIngrediant_IngrediantId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_IngrediantId]  DEFAULT ((0)) FOR [IngredientId]
GO
/****** Object:  Default [DF_CanteenIngrediant_ItemName]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_ItemName]  DEFAULT ('') FOR [ItemName]
GO
/****** Object:  Default [DF_CanteenIngrediant_Quantity]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
/****** Object:  Default [DF_CanteenIngrediant_Cost]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_Cost]  DEFAULT ((0)) FOR [Cost]
GO
/****** Object:  Default [DF_CanteenIngrediant_Metric]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_Metric]  DEFAULT ('') FOR [Metric]
GO
/****** Object:  Default [DF_CanteenIngrediant_BilledById]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenIngredient] ADD  CONSTRAINT [DF_CanteenIngrediant_BilledById]  DEFAULT ((0)) FOR [BilledById]
GO
/****** Object:  Default [DF__CanteenMI__BillI__0B5CAFEA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [BillID]
GO
/****** Object:  Default [DF__CanteenMI__Trans__0C50D423]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((1)) FOR [TransactionID]
GO
/****** Object:  Default [DF__CanteenMI__ItemI__0D44F85C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [ItemID]
GO
/****** Object:  Default [DF__CanteenMI__ItemN__0E391C95]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ('') FOR [ItemName]
GO
/****** Object:  Default [DF__CanteenMI__BillT__0F2D40CE]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [BillType]
GO
/****** Object:  Default [DF__CanteenMI__Price__10216507]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [Price]
GO
/****** Object:  Default [DF__CanteenMIS__Tax__11158940]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [Tax]
GO
/****** Object:  Default [DF__CanteenMIS__VAT__1209AD79]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [VAT]
GO
/****** Object:  Default [DF__CanteenMI__Combo__12FDD1B2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ('') FOR [ComboItems]
GO
/****** Object:  Default [DF__CanteenMI__Quant__13F1F5EB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [Quantity]
GO
/****** Object:  Default [DF__CanteenMI__Payme__14E61A24]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [PaymentType]
GO
/****** Object:  Default [DF__CanteenMI__Payme__15DA3E5D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [PaymentReceived]
GO
/****** Object:  Default [DF__CanteenMI__Quota__16CE6296]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [QuotaServicerID]
GO
/****** Object:  Default [DF__CanteenMI__Quota__17C286CF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ('') FOR [QuotaServicerName]
GO
/****** Object:  Default [DF__CanteenMI__Quota__18B6AB08]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [QuotaType]
GO
/****** Object:  Default [DF__CanteenMI__SeatI__19AACF41]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [SeatID]
GO
/****** Object:  Default [DF__CanteenMI__ShowT__1A9EF37A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT (getdate()) FOR [ShowTime]
GO
/****** Object:  Default [DF__CanteenMI__Patro__1B9317B3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ('') FOR [PatronInfo]
GO
/****** Object:  Default [DF__CanteenMI__Bille__1C873BEC]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT ((0)) FOR [BilledByID]
GO
/****** Object:  Default [DF__CanteenMI__Trans__1D7B6025]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[CanteenMIS] ADD  DEFAULT (getdate()) FOR [TransactionTime]
GO
/****** Object:  Default [DF_Chain_Status]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Chain] ADD  CONSTRAINT [DF_Chain_Status]  DEFAULT ((0)) FOR [Status]
GO
/****** Object:  Default [DF__Class__ScreenID__1E6F845E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__Class__ShowID__1F63A897]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [ShowID]
GO
/****** Object:  Default [DF__Class__ClassLayo__2057CCD0]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [ClassLayoutID]
GO
/****** Object:  Default [DF__Class__ClassNo__214BF109]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ('') FOR [ClassNo]
GO
/****** Object:  Default [DF__Class__ClassName__22401542]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ('') FOR [ClassName]
GO
/****** Object:  Default [DF__Class__NoRows__2334397B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [NoRows]
GO
/****** Object:  Default [DF__Class__NoCols__24285DB4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [NoCols]
GO
/****** Object:  Default [DF__Class__DCRID__251C81ED]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [DCRID]
GO
/****** Object:  Default [DF__Class__Price__2610A626]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [Price]
GO
/****** Object:  Default [DF__Class__ETax__2704CA5F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [ETax]
GO
/****** Object:  Default [DF__Class__ATax__27F8EE98]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [ATax]
GO
/****** Object:  Default [DF__Class__MC__28ED12D1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [MC]
GO
/****** Object:  Default [DF__Class__BlockFee__29E1370A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [BlockFee]
GO
/****** Object:  Default [DF__Class__NoMaxSeat__2AD55B43]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ((0)) FOR [NoMaxSeatsPerTicket]
GO
/****** Object:  Default [DF__Class__AllowedUs__2BC97F7C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  DEFAULT ('') FOR [AllowedUsers]
GO
/****** Object:  Default [DF_Class_PriceCardId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Class] ADD  CONSTRAINT [DF_Class_PriceCardId]  DEFAULT ((0)) FOR [PriceCardId]
GO
/****** Object:  Default [DF__ClassLayo__Scree__2EA5EC27]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__ClassLayo__Class__2F9A1060]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ('') FOR [ClassNo]
GO
/****** Object:  Default [DF__ClassLayo__Class__308E3499]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ('') FOR [ClassName]
GO
/****** Object:  Default [DF__ClassLayo__NoRow__318258D2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((0)) FOR [NoRows]
GO
/****** Object:  Default [DF__ClassLayo__NoCol__32767D0B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((0)) FOR [NoCols]
GO
/****** Object:  Default [DF__ClassLayo__NoMax__336AA144]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((8)) FOR [NoMaxSeatsPerTicket]
GO
/****** Object:  Default [DF__ClassLayo__IsPri__3552E9B6]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((0)) FOR [IsPrintOneTicketPerSeat]
GO
/****** Object:  Default [DF__ClassLayo__Print__36470DEF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((1)) FOR [PrintType]
GO
/****** Object:  Default [DF__ClassLayo__Print__373B3228]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((0)) FOR [PrintOrientationType]
GO
/****** Object:  Default [DF__ClassLayo__IsPri__3CF40B7E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((1)) FOR [IsPrintAuditNos]
GO
/****** Object:  Default [DF__ClassLayo__IsPri__3DE82FB7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ((1)) FOR [IsPrintDCRNo]
GO
/****** Object:  Default [DF__ClassLayo__Allow__41B8C09B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  DEFAULT ('') FOR [AllowedUsers]
GO
/****** Object:  Default [DF_ClassLayout_ClassPosition]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassLayout] ADD  CONSTRAINT [DF_ClassLayout_ClassPosition]  DEFAULT ('') FOR [ClassPosition]
GO
/****** Object:  Default [DF__ClassMIS__Screen__42ACE4D4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__ClassMIS__ShowID__43A1090D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [ShowID]
GO
/****** Object:  Default [DF__ClassMIS__ClassI__44952D46]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((1)) FOR [ClassID]
GO
/****** Object:  Default [DF__ClassMIS__ClassL__4589517F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [ClassLayoutID]
GO
/****** Object:  Default [DF__ClassMIS__ClassN__467D75B8]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ('') FOR [ClassNo]
GO
/****** Object:  Default [DF__ClassMIS__ClassN__477199F1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ('') FOR [ClassName]
GO
/****** Object:  Default [DF__ClassMIS__NoRows__4865BE2A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [NoRows]
GO
/****** Object:  Default [DF__ClassMIS__NoCols__4959E263]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [NoCols]
GO
/****** Object:  Default [DF__ClassMIS__DCRID__4A4E069C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [DCRID]
GO
/****** Object:  Default [DF__ClassMIS__Price__4B422AD5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [Price]
GO
/****** Object:  Default [DF__ClassMIS__ETax__4C364F0E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [ETax]
GO
/****** Object:  Default [DF__ClassMIS__ATax__4D2A7347]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [ATax]
GO
/****** Object:  Default [DF__ClassMIS__MC__4E1E9780]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [MC]
GO
/****** Object:  Default [DF__ClassMIS__BlockF__4F12BBB9]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [BlockFee]
GO
/****** Object:  Default [DF__ClassMIS__NoMaxS__5006DFF2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ((0)) FOR [NoMaxSeatsPerTicket]
GO
/****** Object:  Default [DF__ClassMIS__Allowe__50FB042B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  DEFAULT ('') FOR [AllowedUsers]
GO
/****** Object:  Default [DF_ClassMIS_PriceCardId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ClassMIS] ADD  CONSTRAINT [DF_ClassMIS_PriceCardId]  DEFAULT ((0)) FOR [PriceCardId]
GO
/****** Object:  Default [DF__Complex__Complex__54CB950F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__54CB950F]  DEFAULT ('') FOR [ComplexName]
GO
/****** Object:  Default [DF__Complex__Complex__55BFB948]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__55BFB948]  DEFAULT ((0)) FOR [ComplexType]
GO
/****** Object:  Default [DF__Complex__Complex__56B3DD81]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__56B3DD81]  DEFAULT ('') FOR [ComplexAddress1]
GO
/****** Object:  Default [DF__Complex__Complex__57A801BA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__57A801BA]  DEFAULT ('') FOR [ComplexAddress2]
GO
/****** Object:  Default [DF__Complex__Complex__589C25F3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__589C25F3]  DEFAULT ('') FOR [ComplexCity]
GO
/****** Object:  Default [DF__Complex__Complex__59904A2C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__59904A2C]  DEFAULT ('') FOR [ComplexState]
GO
/****** Object:  Default [DF__Complex__Complex__5A846E65]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__5A846E65]  DEFAULT ('') FOR [ComplexCountry]
GO
/****** Object:  Default [DF__Complex__Complex__5B78929E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__5B78929E]  DEFAULT ('') FOR [ComplexZip]
GO
/****** Object:  Default [DF__Complex__Complex__5C6CB6D7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__5C6CB6D7]  DEFAULT ('') FOR [ComplexPhone]
GO
/****** Object:  Default [DF__Complex__Complex__5D60DB10]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Complex__5D60DB10]  DEFAULT ('') FOR [ComplexEmail]
GO
/****** Object:  Default [DF__Complex__Transac__5E54FF49]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Transac__5E54FF49]  DEFAULT ((2)) FOR [TransactionLogType]
GO
/****** Object:  Default [DF__Complex__LastMai__5F492382]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__LastMai__5F492382]  DEFAULT (getdate()) FOR [LastMaintenanceTime]
GO
/****** Object:  Default [DF__Complex__BoxOffi__603D47BB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__603D47BB]  DEFAULT ((0)) FOR [BoxOfficeID]
GO
/****** Object:  Default [DF__Complex__BoxOffi__61316BF4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__61316BF4]  DEFAULT ('') FOR [BoxOfficeName]
GO
/****** Object:  Default [DF__Complex__BoxOffi__6225902D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__6225902D]  DEFAULT ('') FOR [BoxOfficeVersion]
GO
/****** Object:  Default [DF__Complex__BoxOffi__6319B466]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__6319B466]  DEFAULT ((0)) FOR [BoxOfficeLicenseType]
GO
/****** Object:  Default [DF__Complex__BoxOffi__640DD89F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__640DD89F]  DEFAULT (getdate()) FOR [BoxOfficeLicenseFrom]
GO
/****** Object:  Default [DF__Complex__BoxOffi__6501FCD8]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__6501FCD8]  DEFAULT (getdate()) FOR [BoxOfficeLicenseTo]
GO
/****** Object:  Default [DF__Complex__BoxOffi__65F62111]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__65F62111]  DEFAULT ('') FOR [BoxOfficeLicenseKey]
GO
/****** Object:  Default [DF__Complex__IsWebSe__66EA454A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__IsWebSe__66EA454A]  DEFAULT ((0)) FOR [IsWebService]
GO
/****** Object:  Default [DF__Complex__Central__67DE6983]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Central__67DE6983]  DEFAULT ('') FOR [CentralServerName]
GO
/****** Object:  Default [DF__Complex__Central__68D28DBC]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Central__68D28DBC]  DEFAULT ('') FOR [CentralServerURL]
GO
/****** Object:  Default [DF__Complex__Central__69C6B1F5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__Central__69C6B1F5]  DEFAULT ('') FOR [CentralServerPassword]
GO
/****** Object:  Default [DF__Complex__MovieIm__6ABAD62E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__MovieIm__6ABAD62E]  DEFAULT ('') FOR [MovieImageURL]
GO
/****** Object:  Default [DF__Complex__BoxOffi__6BAEFA67]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__BoxOffi__6BAEFA67]  DEFAULT ('') FOR [BoxOfficeURL]
GO
/****** Object:  Default [DF__Complex__IsAllow__6CA31EA0]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__IsAllow__6CA31EA0]  DEFAULT ((1)) FOR [IsAllowBlocking]
GO
/****** Object:  Default [DF__Complex__NoMaxSe__6D9742D9]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__NoMaxSe__6D9742D9]  DEFAULT ((8)) FOR [NoMaxSeatsPerTicket]
GO
/****** Object:  Default [DF__Complex__IsSendS__6F7F8B4B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__IsSendS__6F7F8B4B]  DEFAULT ((0)) FOR [IsSendSeatSoldEvent]
GO
/****** Object:  Default [DF__Complex__IsSendS__7073AF84]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__IsSendS__7073AF84]  DEFAULT ((0)) FOR [IsSendSeatOccupiedEvent]
GO
/****** Object:  Default [DF__Complex__IsSendS__7167D3BD]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF__Complex__IsSendS__7167D3BD]  DEFAULT ((0)) FOR [IsSendSeatCancelledEvent]
GO
/****** Object:  Default [DF_Complex_ChainID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF_Complex_ChainID]  DEFAULT ((0)) FOR [ChainID]
GO
/****** Object:  Default [DF_Complex_ChainGUID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF_Complex_ChainGUID]  DEFAULT ('') FOR [ChainGUID]
GO
/****** Object:  Default [DF_Complex_ChainName]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Complex] ADD  CONSTRAINT [DF_Complex_ChainName]  DEFAULT ('') FOR [ChainName]
GO
/****** Object:  Default [DF__DCR__DCRName__73501C2F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[DCR] ADD  DEFAULT ('') FOR [DCRName]
GO
/****** Object:  Default [DF__DCR__DCRNo__74444068]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[DCR] ADD  DEFAULT ((0)) FOR [DCRNo]
GO
/****** Object:  Default [DF__DCR__DCRMax__753864A1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[DCR] ADD  DEFAULT ((100000)) FOR [DCRMax]
GO
/****** Object:  Default [DF__Item__ItemName__762C88DA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ('') FOR [ItemName]
GO
/****** Object:  Default [DF__Item__Price__7720AD13]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ((0)) FOR [Price]
GO
/****** Object:  Default [DF__Item__Tax__7814D14C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ((0)) FOR [Tax]
GO
/****** Object:  Default [DF__Item__VAT__7908F585]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ((0)) FOR [VAT]
GO
/****** Object:  Default [DF__Item__ComboItems__79FD19BE]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ('') FOR [ComboItems]
GO
/****** Object:  Default [DF__Item__Quantity__7AF13DF7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ((0)) FOR [Quantity]
GO
/****** Object:  Default [DF__Item__IsOnline__7BE56230]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ((0)) FOR [IsOnline]
GO
/****** Object:  Default [DF__Item__Shortcut__7CD98669]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ('') FOR [Shortcut]
GO
/****** Object:  Default [DF__Item__GroupNo__7DCDAAA2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  DEFAULT ('') FOR [GroupNo]
GO
/****** Object:  Default [DF_Item_Cost]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  CONSTRAINT [DF_Item_Cost]  DEFAULT ((0)) FOR [Cost]
GO
/****** Object:  Default [DF_Item_IsIngrediants]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Item] ADD  CONSTRAINT [DF_Item_IsIngrediants]  DEFAULT ((0)) FOR [IsIngredients]
GO
/****** Object:  Default [DF_ItemIngrediant_ItemId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredient] ADD  CONSTRAINT [DF_ItemIngrediant_ItemId]  DEFAULT ((0)) FOR [ItemId]
GO
/****** Object:  Default [DF_ItemIngrediant_ItemName]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredient] ADD  CONSTRAINT [DF_ItemIngrediant_ItemName]  DEFAULT ('') FOR [ItemName]
GO
/****** Object:  Default [DF_ItemIngrediant_Cost]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredient] ADD  CONSTRAINT [DF_ItemIngrediant_Cost]  DEFAULT ((0)) FOR [Cost]
GO
/****** Object:  Default [DF_ItemIngrediant_Metric]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredient] ADD  CONSTRAINT [DF_ItemIngrediant_Metric]  DEFAULT ('') FOR [Metric]
GO
/****** Object:  Default [DF_ItemIngrediant_CreatedOn]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredient] ADD  CONSTRAINT [DF_ItemIngrediant_CreatedOn]  DEFAULT (getdate()) FOR [TransactionTime]
GO
/****** Object:  Default [DF_ItemIngredientStock_IngredientId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredientStock] ADD  CONSTRAINT [DF_ItemIngredientStock_IngredientId]  DEFAULT ((0)) FOR [IngredientId]
GO
/****** Object:  Default [DF_ItemIngredientStock_ItemId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredientStock] ADD  CONSTRAINT [DF_ItemIngredientStock_ItemId]  DEFAULT ((0)) FOR [ItemId]
GO
/****** Object:  Default [DF_Table_1_date]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredientStock] ADD  CONSTRAINT [DF_Table_1_date]  DEFAULT (getdate()) FOR [Date]
GO
/****** Object:  Default [DF_ItemIngredientStock_Quantity]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredientStock] ADD  CONSTRAINT [DF_ItemIngredientStock_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
/****** Object:  Default [DF_ItemIngredientStock_StockType]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemIngredientStock] ADD  CONSTRAINT [DF_ItemIngredientStock_StockType]  DEFAULT ((0)) FOR [StockType]
GO
/****** Object:  Default [DF_ItemStock_ItemID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemStock] ADD  CONSTRAINT [DF_ItemStock_ItemID]  DEFAULT ((0)) FOR [ItemID]
GO
/****** Object:  Default [DF_ItemStock_Quantity]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemStock] ADD  CONSTRAINT [DF_ItemStock_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
/****** Object:  Default [DF_ItemStock_StockType]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ItemStock] ADD  CONSTRAINT [DF_ItemStock_StockType]  DEFAULT ((0)) FOR [StockType]
GO
/****** Object:  Default [DF__Log__TableType__0E04126B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ((0)) FOR [TableType]
GO
/****** Object:  Default [DF__Log__ObjectID__0EF836A4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ((0)) FOR [ObjectID]
GO
/****** Object:  Default [DF__Log__ObjectName__0FEC5ADD]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ('') FOR [ObjectName]
GO
/****** Object:  Default [DF__Log__Transaction__10E07F16]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ((0)) FOR [TransactionType]
GO
/****** Object:  Default [DF__Log__Transaction__11D4A34F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ((0)) FOR [TransactionLogType]
GO
/****** Object:  Default [DF__Log__Transaction__12C8C788]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ('') FOR [TransactionDetail]
GO
/****** Object:  Default [DF__Log__Transaction__13BCEBC1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT (getdate()) FOR [TransactionTime]
GO
/****** Object:  Default [DF__Log__Transaction__14B10FFA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ('') FOR [TransactionByIP]
GO
/****** Object:  Default [DF__Log__Transaction__15A53433]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ((0)) FOR [TransactionByID]
GO
/****** Object:  Default [DF__Log__Transaction__1699586C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Log] ADD  DEFAULT ('') FOR [TransactionByName]
GO
/****** Object:  Default [DF__LogMIS__LogID__178D7CA5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ((1)) FOR [LogID]
GO
/****** Object:  Default [DF__LogMIS__TableTyp__1881A0DE]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ((0)) FOR [TableType]
GO
/****** Object:  Default [DF__LogMIS__ObjectID__1975C517]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ((0)) FOR [ObjectID]
GO
/****** Object:  Default [DF__LogMIS__ObjectNa__1A69E950]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ('') FOR [ObjectName]
GO
/****** Object:  Default [DF__LogMIS__Transact__1B5E0D89]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ((0)) FOR [TransactionType]
GO
/****** Object:  Default [DF__LogMIS__Transact__1C5231C2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ((0)) FOR [TransactionLogType]
GO
/****** Object:  Default [DF__LogMIS__Transact__1D4655FB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ('') FOR [TransactionDetail]
GO
/****** Object:  Default [DF__LogMIS__Transact__1E3A7A34]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT (getdate()) FOR [TransactionTime]
GO
/****** Object:  Default [DF__LogMIS__Transact__1F2E9E6D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ('') FOR [TransactionByIP]
GO
/****** Object:  Default [DF__LogMIS__Transact__2022C2A6]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ((0)) FOR [TransactionByID]
GO
/****** Object:  Default [DF__LogMIS__Transact__2116E6DF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[LogMIS] ADD  DEFAULT ('') FOR [TransactionByName]
GO
/****** Object:  Default [DF_Parking_ParkingTypeID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Parking] ADD  CONSTRAINT [DF_Parking_ParkingTypeID]  DEFAULT ((0)) FOR [ParkingTypeID]
GO
/****** Object:  Default [DF_Table_1_RegNo]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Parking] ADD  CONSTRAINT [DF_Table_1_RegNo]  DEFAULT ((0)) FOR [ParkingAmount]
GO
/****** Object:  Default [DF_Parking_CreatedBy]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Parking] ADD  CONSTRAINT [DF_Parking_CreatedBy]  DEFAULT ((0)) FOR [CreatedBy]
GO
/****** Object:  Default [DF_Parking_CreatedOn]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Parking] ADD  CONSTRAINT [DF_Parking_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
/****** Object:  Default [DF_Parking_FromTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Parking] ADD  CONSTRAINT [DF_Parking_FromTime]  DEFAULT (getdate()) FOR [FromTime]
GO
/****** Object:  Default [DF_Parking_ToTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Parking] ADD  CONSTRAINT [DF_Parking_ToTime]  DEFAULT (getdate()) FOR [ToTime]
GO
/****** Object:  Default [DF_ParkingType_ParkingType]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ParkingType] ADD  CONSTRAINT [DF_ParkingType_ParkingType]  DEFAULT ('') FOR [ParkingType]
GO
/****** Object:  Default [DF_ParkingType_Price]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ParkingType] ADD  CONSTRAINT [DF_ParkingType_Price]  DEFAULT ((0)) FOR [Price]
GO
/****** Object:  Default [DF_PriceCard_Amount]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[PriceCard] ADD  CONSTRAINT [DF_PriceCard_Amount]  DEFAULT ((0)) FOR [Amount]
GO
/****** Object:  Default [DF_PriceCard_CreatedBy]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[PriceCard] ADD  CONSTRAINT [DF_PriceCard_CreatedBy]  DEFAULT ((0)) FOR [CreatedBy]
GO
/****** Object:  Default [DF_PriceCard_CreatedOn]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[PriceCard] ADD  CONSTRAINT [DF_PriceCard_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
/****** Object:  Default [DF__Report__PhaseNam__29AC2CE0]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Report] ADD  DEFAULT ('') FOR [PhaseName]
GO
/****** Object:  Default [DF__Report__TableNam__2AA05119]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Report] ADD  DEFAULT ('') FOR [TableName]
GO
/****** Object:  Default [DF__Report__ReportNa__2B947552]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Report] ADD  DEFAULT ('') FOR [ReportName]
GO
/****** Object:  Default [DF__Screen__ScreenNo__2C88998B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Screen] ADD  CONSTRAINT [DF__Screen__ScreenNo__2C88998B]  DEFAULT ('') FOR [ScreenNo]
GO
/****** Object:  Default [DF__Screen__ScreenNa__2D7CBDC4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Screen] ADD  CONSTRAINT [DF__Screen__ScreenNa__2D7CBDC4]  DEFAULT ('') FOR [ScreenName]
GO
/****** Object:  Default [DF__Screen__IsFoodBe__324172E1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Screen] ADD  CONSTRAINT [DF__Screen__IsFoodBe__324172E1]  DEFAULT ((0)) FOR [IsFoodBeverages]
GO
/****** Object:  Default [DF__Screen__IsAdvanc__3335971A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Screen] ADD  CONSTRAINT [DF__Screen__IsAdvanc__3335971A]  DEFAULT ((0)) FOR [IsAdvanceToken]
GO
/****** Object:  Default [DF_Screen_IsDisplaySeatNos]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Screen] ADD  CONSTRAINT [DF_Screen_IsDisplaySeatNos]  DEFAULT ((0)) FOR [IsDisplaySeatNos]
GO
/****** Object:  Default [DF_Screen_ComplexID]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Screen] ADD  CONSTRAINT [DF_Screen_ComplexID]  DEFAULT ((0)) FOR [ComplexID]
GO
/****** Object:  Default [DF__Seat__ScreenID__351DDF8C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__Seat__ShowID__361203C5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [ShowID]
GO
/****** Object:  Default [DF__Seat__ClassID__370627FE]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [ClassID]
GO
/****** Object:  Default [DF__Seat__ClassLayou__37FA4C37]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [ClassLayoutID]
GO
/****** Object:  Default [DF__Seat__SeatLayout__38EE7070]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [SeatLayoutID]
GO
/****** Object:  Default [DF__Seat__TicketID__39E294A9]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [TicketID]
GO
/****** Object:  Default [DF__Seat__DCRNo__3AD6B8E2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [DCRNo]
GO
/****** Object:  Default [DF__Seat__SeatType__3BCADD1B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [SeatType]
GO
/****** Object:  Default [DF__Seat__SeatLabel__3CBF0154]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ('') FOR [SeatLabel]
GO
/****** Object:  Default [DF__Seat__RowNo__3DB3258D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [RowNo]
GO
/****** Object:  Default [DF__Seat__ColNo__3EA749C6]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [ColNo]
GO
/****** Object:  Default [DF__Seat__PaymentTyp__3F9B6DFF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [PaymentType]
GO
/****** Object:  Default [DF__Seat__PaymentRec__408F9238]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [PaymentReceived]
GO
/****** Object:  Default [DF__Seat__StatusType__4183B671]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [StatusType]
GO
/****** Object:  Default [DF__Seat__QuotaServi__4277DAAA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [QuotaServicerID]
GO
/****** Object:  Default [DF__Seat__QuotaServi__436BFEE3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ('') FOR [QuotaServicerName]
GO
/****** Object:  Default [DF__Seat__QuotaType__4460231C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [QuotaType]
GO
/****** Object:  Default [DF__Seat__ReleaseBef__45544755]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((60)) FOR [ReleaseBefore]
GO
/****** Object:  Default [DF__Seat__PatronInfo__46486B8E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ('') FOR [PatronInfo]
GO
/****** Object:  Default [DF__Seat__PatronFee__473C8FC7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [PatronFee]
GO
/****** Object:  Default [DF__Seat__NoBlocks__4830B400]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [NoBlocks]
GO
/****** Object:  Default [DF__Seat__NoSales__4924D839]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [NoSales]
GO
/****** Object:  Default [DF__Seat__NoPrints__4A18FC72]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [NoPrints]
GO
/****** Object:  Default [DF__Seat__NoOccupies__4B0D20AB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [NoOccupies]
GO
/****** Object:  Default [DF__Seat__NoCancels__4C0144E4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [NoCancels]
GO
/****** Object:  Default [DF__Seat__LastBlocke__4CF5691D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [LastBlockedByID]
GO
/****** Object:  Default [DF__Seat__LastSoldBy__4DE98D56]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [LastSoldByID]
GO
/****** Object:  Default [DF__Seat__LastPrinte__4EDDB18F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [LastPrintedByID]
GO
/****** Object:  Default [DF__Seat__LastOccupi__4FD1D5C8]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [LastOccupiedByID]
GO
/****** Object:  Default [DF__Seat__LastCancel__50C5FA01]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  DEFAULT ((0)) FOR [LastCancelledByID]
GO
/****** Object:  Default [DF_Seat_PriceCardId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Seat] ADD  CONSTRAINT [DF_Seat_PriceCardId]  DEFAULT ((0)) FOR [PriceCardId]
GO
/****** Object:  Default [DF__SeatLayou__Scree__08162EEB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__SeatLayou__Class__090A5324]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((0)) FOR [ClassLayoutID]
GO
/****** Object:  Default [DF__SeatLayou__SeatT__09FE775D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((0)) FOR [SeatType]
GO
/****** Object:  Default [DF__SeatLayou__SeatL__0AF29B96]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ('') FOR [SeatLabel]
GO
/****** Object:  Default [DF__SeatLayou__RowNo__0BE6BFCF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((0)) FOR [RowNo]
GO
/****** Object:  Default [DF__SeatLayou__ColNo__0CDAE408]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((0)) FOR [ColNo]
GO
/****** Object:  Default [DF__SeatLayou__Quota__0DCF0841]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((0)) FOR [QuotaType]
GO
/****** Object:  Default [DF__SeatLayou__Relea__0EC32C7A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  DEFAULT ((60)) FOR [ReleaseBefore]
GO
/****** Object:  Default [DF_SeatLayout_PriceCardId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatLayout] ADD  CONSTRAINT [DF_SeatLayout_PriceCardId]  DEFAULT ((0)) FOR [PriceCardId]
GO
/****** Object:  Default [DF__SeatMIS__ScreenI__0FB750B3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__SeatMIS__ShowID__10AB74EC]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [ShowID]
GO
/****** Object:  Default [DF__SeatMIS__ClassID__119F9925]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [ClassID]
GO
/****** Object:  Default [DF__SeatMIS__ClassLa__1293BD5E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [ClassLayoutID]
GO
/****** Object:  Default [DF__SeatMIS__SeatLay__1387E197]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [SeatLayoutID]
GO
/****** Object:  Default [DF__SeatMIS__TicketI__147C05D0]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [TicketID]
GO
/****** Object:  Default [DF__SeatMIS__SeatID__15702A09]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((1)) FOR [SeatID]
GO
/****** Object:  Default [DF__SeatMIS__DCRNo__16644E42]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [DCRNo]
GO
/****** Object:  Default [DF__SeatMIS__SeatTyp__1758727B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [SeatType]
GO
/****** Object:  Default [DF__SeatMIS__SeatLab__184C96B4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ('') FOR [SeatLabel]
GO
/****** Object:  Default [DF__SeatMIS__RowNo__1940BAED]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [RowNo]
GO
/****** Object:  Default [DF__SeatMIS__ColNo__1A34DF26]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [ColNo]
GO
/****** Object:  Default [DF__SeatMIS__Payment__1B29035F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [PaymentType]
GO
/****** Object:  Default [DF__SeatMIS__Payment__1C1D2798]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [PaymentReceived]
GO
/****** Object:  Default [DF__SeatMIS__StatusT__1D114BD1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [StatusType]
GO
/****** Object:  Default [DF__SeatMIS__QuotaSe__1E05700A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [QuotaServicerID]
GO
/****** Object:  Default [DF__SeatMIS__QuotaSe__1EF99443]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ('') FOR [QuotaServicerName]
GO
/****** Object:  Default [DF__SeatMIS__QuotaTy__1FEDB87C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [QuotaType]
GO
/****** Object:  Default [DF__SeatMIS__Release__20E1DCB5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((60)) FOR [ReleaseBefore]
GO
/****** Object:  Default [DF__SeatMIS__PatronI__21D600EE]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ('') FOR [PatronInfo]
GO
/****** Object:  Default [DF__SeatMIS__PatronF__22CA2527]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [PatronFee]
GO
/****** Object:  Default [DF__SeatMIS__NoBlock__23BE4960]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [NoBlocks]
GO
/****** Object:  Default [DF__SeatMIS__NoSales__24B26D99]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [NoSales]
GO
/****** Object:  Default [DF__SeatMIS__NoPrint__25A691D2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [NoPrints]
GO
/****** Object:  Default [DF__SeatMIS__NoOccup__269AB60B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [NoOccupies]
GO
/****** Object:  Default [DF__SeatMIS__NoCance__278EDA44]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [NoCancels]
GO
/****** Object:  Default [DF__SeatMIS__LastBlo__2882FE7D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [LastBlockedByID]
GO
/****** Object:  Default [DF__SeatMIS__LastSol__297722B6]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [LastSoldByID]
GO
/****** Object:  Default [DF__SeatMIS__LastPri__2A6B46EF]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [LastPrintedByID]
GO
/****** Object:  Default [DF__SeatMIS__LastOcc__2B5F6B28]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [LastOccupiedByID]
GO
/****** Object:  Default [DF__SeatMIS__LastCan__2C538F61]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  DEFAULT ((0)) FOR [LastCancelledByID]
GO
/****** Object:  Default [DF_SeatMIS_PriceCardId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[SeatMIS] ADD  CONSTRAINT [DF_SeatMIS_PriceCardId]  DEFAULT ((0)) FOR [PriceCardId]
GO
/****** Object:  Default [DF__Show__ScreenID__2D47B39A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__ScreenID__2D47B39A]  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__Show__ScreenNo__2E3BD7D3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__ScreenNo__2E3BD7D3]  DEFAULT ('') FOR [ScreenNo]
GO
/****** Object:  Default [DF__Show__ScreenName__2F2FFC0C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__ScreenName__2F2FFC0C]  DEFAULT ('') FOR [ScreenName]
GO
/****** Object:  Default [DF__Show__OnlineMovi__30242045]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__OnlineMovi__30242045]  DEFAULT ((0)) FOR [OnlineMovieID]
GO
/****** Object:  Default [DF__Show__OnlineMovi__3118447E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__OnlineMovi__3118447E]  DEFAULT ('') FOR [OnlineMovieName]
GO
/****** Object:  Default [DF__Show__MovieName__320C68B7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__MovieName__320C68B7]  DEFAULT ('') FOR [MovieName]
GO
/****** Object:  Default [DF__Show__MovieLangu__33F4B129]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__MovieLangu__33F4B129]  DEFAULT ((0)) FOR [MovieLanguageType]
GO
/****** Object:  Default [DF__Show__MovieCenso__34E8D562]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__MovieCenso__34E8D562]  DEFAULT ((0)) FOR [MovieCensorRatingType]
GO
/****** Object:  Default [DF__Show__ShowName__36D11DD4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__ShowName__36D11DD4]  DEFAULT ('') FOR [ShowName]
GO
/****** Object:  Default [DF__Show__ShowTime__37C5420D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__ShowTime__37C5420D]  DEFAULT (getdate()) FOR [ShowTime]
GO
/****** Object:  Default [DF__Show__IsPaused__38B96646]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__IsPaused__38B96646]  DEFAULT ((0)) FOR [IsPaused]
GO
/****** Object:  Default [DF__Show__ResumeBefo__39AD8A7F]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__ResumeBefo__39AD8A7F]  DEFAULT ((240)) FOR [ResumeBefore]
GO
/****** Object:  Default [DF__Show__AllowedUse__3AA1AEB8]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__AllowedUse__3AA1AEB8]  DEFAULT ('') FOR [AllowedUsers]
GO
/****** Object:  Default [DF__Show__Duration__3B95D2F1]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__Duration__3B95D2F1]  DEFAULT ((180)) FOR [Duration]
GO
/****** Object:  Default [DF__Show__IsCancel__3C89F72A]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__IsCancel__3C89F72A]  DEFAULT ((0)) FOR [IsCancel]
GO
/****** Object:  Default [DF__Show__CancelRema__3D7E1B63]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF__Show__CancelRema__3D7E1B63]  DEFAULT ('') FOR [CancelRemarks]
GO
/****** Object:  Default [DF_Show_IsOnlinePublish]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_IsOnlinePublish]  DEFAULT ((0)) FOR [IsOnlinePublish]
GO
/****** Object:  Default [DF_Show_OnlineShowId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_OnlineShowId]  DEFAULT ('') FOR [OnlineShowId]
GO
/****** Object:  Default [DF_Show_Uuid]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_Uuid]  DEFAULT (newid()) FOR [Uuid]
GO
/****** Object:  Default [DF_Show_EntryTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_EntryTime]  DEFAULT ((0)) FOR [EntryTime]
GO
/****** Object:  Default [DF_Show_IntervalTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_IntervalTime]  DEFAULT ((0)) FOR [IntervalTime]
GO
/****** Object:  Default [DF_Show_ExitTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_ExitTime]  DEFAULT ((0)) FOR [ExitTime]
GO
/****** Object:  Default [DF__ShowMIS__ScreenI__3F6663D5]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((0)) FOR [ScreenID]
GO
/****** Object:  Default [DF__ShowMIS__ShowID__405A880E]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((1)) FOR [ShowID]
GO
/****** Object:  Default [DF__ShowMIS__ScreenN__414EAC47]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [ScreenNo]
GO
/****** Object:  Default [DF__ShowMIS__ScreenN__4242D080]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [ScreenName]
GO
/****** Object:  Default [DF__ShowMIS__OnlineM__4336F4B9]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((0)) FOR [OnlineMovieID]
GO
/****** Object:  Default [DF__ShowMIS__OnlineM__442B18F2]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [OnlineMovieName]
GO
/****** Object:  Default [DF__ShowMIS__MovieNa__451F3D2B]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [MovieName]
GO
/****** Object:  Default [DF__ShowMIS__MovieLa__4707859D]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((0)) FOR [MovieLanguageType]
GO
/****** Object:  Default [DF__ShowMIS__MovieCe__47FBA9D6]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((0)) FOR [MovieCensorRatingType]
GO
/****** Object:  Default [DF__ShowMIS__ShowNam__49E3F248]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [ShowName]
GO
/****** Object:  Default [DF__ShowMIS__ShowTim__4AD81681]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT (getdate()) FOR [ShowTime]
GO
/****** Object:  Default [DF__ShowMIS__IsPause__4BCC3ABA]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((0)) FOR [IsPaused]
GO
/****** Object:  Default [DF__ShowMIS__ResumeB__4CC05EF3]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((240)) FOR [ResumeBefore]
GO
/****** Object:  Default [DF__ShowMIS__Allowed__4DB4832C]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [AllowedUsers]
GO
/****** Object:  Default [DF__ShowMIS__Duratio__4EA8A765]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ((180)) FOR [Duration]
GO
/****** Object:  Default [DF_ShowMIS_IsCancel]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_IsCancel]  DEFAULT ((0)) FOR [IsCancel]
GO
/****** Object:  Default [DF__ShowMIS__CancelR__5090EFD7]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  DEFAULT ('') FOR [CancelRemarks]
GO
/****** Object:  Default [DF_ShowMIS_IsOnlinePublish]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_IsOnlinePublish]  DEFAULT ((0)) FOR [IsOnlinePublish]
GO
/****** Object:  Default [DF_ShowMIS_OnlineShowId]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_OnlineShowId]  DEFAULT ('') FOR [OnlineShowId]
GO
/****** Object:  Default [DF_ShowMIS_Uuid]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_Uuid]  DEFAULT (newid()) FOR [Uuid]
GO
/****** Object:  Default [DF_ShowMIS_EntryTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_EntryTime]  DEFAULT ((0)) FOR [EntryTime]
GO
/****** Object:  Default [DF_ShowMIS_IntervalTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_IntervalTime]  DEFAULT ((0)) FOR [IntervalTime]
GO
/****** Object:  Default [DF_ShowMIS_ExitTime]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[ShowMIS] ADD  CONSTRAINT [DF_ShowMIS_ExitTime]  DEFAULT ((0)) FOR [ExitTime]
GO
/****** Object:  Default [DF__Type__TypeNo__52793849]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Type] ADD  DEFAULT ((0)) FOR [TypeNo]
GO
/****** Object:  Default [DF__Type__TypeName__536D5C82]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Type] ADD  DEFAULT ('') FOR [TypeName]
GO
/****** Object:  Default [DF__Type__Value__546180BB]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Type] ADD  DEFAULT ((0)) FOR [Value]
GO
/****** Object:  Default [DF__Type__Expression__5555A4F4]    Script Date: 08/27/2014 11:05:49 ******/
ALTER TABLE [dbo].[Type] ADD  DEFAULT ('') FOR [Expression]
GO
