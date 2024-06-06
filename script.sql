USE [master]
GO
/****** Object:  Database [BillingSystem]    Script Date: 06-06-2024 10:40:26 ******/
CREATE DATABASE [BillingSystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BillingSystem', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BillingSystem.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BillingSystem_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BillingSystem_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [BillingSystem] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BillingSystem].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BillingSystem] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BillingSystem] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BillingSystem] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BillingSystem] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BillingSystem] SET ARITHABORT OFF 
GO
ALTER DATABASE [BillingSystem] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BillingSystem] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BillingSystem] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BillingSystem] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BillingSystem] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BillingSystem] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BillingSystem] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BillingSystem] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BillingSystem] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BillingSystem] SET  ENABLE_BROKER 
GO
ALTER DATABASE [BillingSystem] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BillingSystem] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BillingSystem] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BillingSystem] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BillingSystem] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BillingSystem] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BillingSystem] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BillingSystem] SET RECOVERY FULL 
GO
ALTER DATABASE [BillingSystem] SET  MULTI_USER 
GO
ALTER DATABASE [BillingSystem] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BillingSystem] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BillingSystem] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BillingSystem] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BillingSystem] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BillingSystem] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'BillingSystem', N'ON'
GO
ALTER DATABASE [BillingSystem] SET QUERY_STORE = OFF
GO
USE [BillingSystem]
GO
/****** Object:  Table [dbo].[Invoice]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Invoice](
	[InvoiceID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [nvarchar](100) NULL,
	[PartyID] [int] NULL,
	[InvoiceDate] [date] NULL,
	[GrandTotal] [decimal](18, 2) NULL,
	[Discount] [decimal](18, 2) NULL,
	[GSTAmount] [decimal](18, 2) NULL,
	[NetAmount] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceItem]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItem](
	[InvoiceItemID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NULL,
	[SRNo] [int] NULL,
	[ItemCode] [nvarchar](50) NULL,
	[ItemName] [nvarchar](100) NULL,
	[Qty] [int] NULL,
	[Rate] [decimal](18, 2) NULL,
	[GST] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[InvoiceItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Party]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Party](
	[PartyID] [int] IDENTITY(1,1) NOT NULL,
	[PartyName] [nvarchar](100) NULL,
	[ContactNo] [nvarchar](20) NULL,
	[GSTNo] [nvarchar](20) NULL,
	[CreateDate] [datetime] NULL,
	[ActiveStatus] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PartyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Party] ADD  CONSTRAINT [DF_Party_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Party] ADD  CONSTRAINT [DF_Party_ActiveStatus]  DEFAULT ((1)) FOR [ActiveStatus]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD FOREIGN KEY([PartyID])
REFERENCES [dbo].[Party] ([PartyID])
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[Invoice] ([InvoiceID])
GO
/****** Object:  StoredProcedure [dbo].[GetLastInvoiceNo]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetLastInvoiceNo]
AS
BEGIN
     SELECT TOP 1 InvoiceNo
    FROM Invoice
    ORDER BY CAST(SUBSTRING(InvoiceNo, 4, LEN(InvoiceNo)) AS INT) DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPartyDetails]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPartyDetails]
    @PartyID INT
AS
BEGIN
    SELECT GSTNo, ContactNo
    FROM Party
    WHERE PartyID = @PartyID;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPartyNames]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[GetPartyNames]
AS
BEGIN
    SELECT PartyID,PartyName FROM Party;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertInvoiceData]    Script Date: 06-06-2024 10:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertInvoiceData]
    @InvoiceNo NVARCHAR(100),
    @PartyName NVARCHAR(100),
    @ContactNo NVARCHAR(20),
    @InvoiceDate DATE,
    @GSTNo NVARCHAR(20),
    @GrandTotal DECIMAL(18, 2),
    @Discount DECIMAL(18, 2),
    @GSTAmount DECIMAL(18, 2),
    @NetAmount DECIMAL(18, 2),
    @SRNo INT,
    @ItemCode NVARCHAR(50),
    @ItemName NVARCHAR(100),
    @Qty INT,
    @Rate DECIMAL(18, 2),
    @GST DECIMAL(18, 2),
    @Total DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PartyID INT;
    SELECT @PartyID = PartyID FROM Party WHERE PartyName = @PartyName AND ContactNo = @ContactNo;

    IF @PartyID IS NULL
    BEGIN
        INSERT INTO Party (PartyName, ContactNo, GSTNo, CreateDate, ActiveStatus)
        VALUES (@PartyName, @ContactNo, @GSTNo, GETDATE(), 1);

        SET @PartyID = SCOPE_IDENTITY();
    END

    INSERT INTO Invoice (InvoiceNo, PartyID, InvoiceDate, GrandTotal, Discount, GSTAmount, NetAmount)
    VALUES (@InvoiceNo, @PartyID, @InvoiceDate, @GrandTotal, @Discount, @GSTAmount, @NetAmount);

    DECLARE @InvoiceID INT;
    SET @InvoiceID = SCOPE_IDENTITY();

    INSERT INTO InvoiceItem (InvoiceID, SRNo, ItemCode, ItemName, Qty, Rate, GST, Total)
    VALUES (@InvoiceID, @SRNo, @ItemCode, @ItemName, @Qty, @Rate, @GST, @Total);
END
GO
USE [master]
GO
ALTER DATABASE [BillingSystem] SET  READ_WRITE 
GO
