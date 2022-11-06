USE [YourScreensBoxOffice]
GO
/****** Object:  User [YourScreensBoxOfficeDBOUser]    Script Date: 05/04/2022 10:00:00 ******/
IF NOT EXISTS (SELECT * FROM sys.syslogins WHERE Name = N'YourScreensBoxOfficeLogin')
	CREATE LOGIN YourScreensBoxOfficeLogin WITH PASSWORD=N'YourScreensBoxOff1ce', DEFAULT_DATABASE=YourScreensBoxOffice, CHECK_EXPIRATION=OFF, CHECK_POLICY=ON;
IF NOT EXISTS (SELECT * FROM sys.sysusers WHERE Name = N'YourScreensBoxOfficeDBOUser')
	CREATE USER YourScreensBoxOfficeDBOUser FOR LOGIN YourScreensBoxOfficeLogin;
EXEC sp_addrolemember N'db_owner', N'YourScreensBoxOfficeDBOUser';