use master;
IF EXISTS(select * from sys.databases where NAME= 'YourScreensBoxOffice')
	drop database YourScreensBoxOffice;
CREATE DATABASE  YourScreensBoxOffice ON  PRIMARY 
( NAME = N'YourScreensBoxOffice', FILENAME = N'D:\Data\YourScreensBoxOffice.mdf')
 LOG ON 
( NAME = N'YourScreensBoxOffice_log', FILENAME = N'D:\Data\YourScreensBoxOffice_log.ldf')
 COLLATE SQL_Latin1_General_CP1_CI_AS;