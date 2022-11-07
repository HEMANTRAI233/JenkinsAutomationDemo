USE YourScreensBoxOffice
GO
IF NOT EXISTS (SELECT * FROM SchemaVersions)
BEGIN
    INSERT INTO SchemaVersions (DBVersion, QTVersion) VALUES (1, '1.0.0.0')
END
GO

/* INSERTING DEFAULT ITEMS in PriceCardItems table */
INSERT INTO PriceCardItems VALUES ('Ticket_Amount', 'Ticket Amount', 'VALUE', 'SURCHARGE')
GO
INSERT INTO PriceCardItemCollections VALUES ('Base_Ticket_Amount', 'Base Ticket Amount', 'VALUE', 'SURCHARGE', 'Ticket_Amount')
GO
INSERT INTO PriceCardItemCollections VALUES ('Maintenance_Charge', 'Maintenance Charge', 'VALUE', 'SURCHARGE', 'Ticket_Amount')
GO
INSERT INTO PriceCardItemCollections VALUES ('User_Service_Charge', 'User Service Charge', 'VALUE', 'SURCHARGE', 'Ticket_Amount')
GO
INSERT INTO PriceCardItemCollections VALUES ('CGST', 'CGST', 'PERCENTAGE', 'SURCHARGE', 'Ticket_Amount')
GO
INSERT INTO PriceCardItemCollections VALUES ('SGST', 'SGST', 'PERCENTAGE', 'SURCHARGE', 'Ticket_Amount')
GO
INSERT INTO PriceCardItemCollections VALUES ('User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%', 'VALUE', 'SURCHARGE', 'Ticket_Amount')
GO
INSERT INTO PriceCardItemCollections VALUES ('User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%', 'VALUE', 'SURCHARGE', 'Ticket_Amount')
GO

SET IDENTITY_INSERT PriceCard ON
GO

INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (1,'NonAC-Premium',0,68.51,1,getdate(),1,'Single Screen','None','Municipal Corporation',1,1,'41c5dba3-0a26-468a-92a8-3c143e451abe')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (2,'NonAC-Premium',0,68.51,1,getdate(),1,'Complex','None','Municipal Corporation',1,1,'cf51f0a1-1cf1-4d2c-8733-3e5bc5d6a835')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (3,'NonAC-Premium',0,57.1,1,getdate(),1,'Single Screen','None','Municipality',1,1,'f1e27c9f-8888-46a3-9d66-f592c2f62f3b')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (4,'NonAC-Premium',0,57.1,1,getdate(),1,'Complex','None','Municipality',1,1,'53b6a92b-eb84-482e-bef4-8fc8fcb03b31')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (5,'NonAC-Premium',0,45.68,1,getdate(),1,'Single Screen','None','Nagar Panchayats/Gram Panchayats',1,1,'01a8bf2a-2ab0-4749-a319-723863dab296')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (6,'NonAC-Premium',0,45.68,1,getdate(),1,'Complex','None','Nagar Panchayats/Gram Panchayats',1,1,'53bfb8fd-9bd9-4929-90fc-42059164eee1')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (7,'NonAC-Non-Premium',0,45.68,1,getdate(),1,'Single Screen','None','Municipal Corporation',1,2,'9b1a380f-f9d3-4a4c-af65-dea4b2daad7b')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (8,'NonAC-Non-Premium',0,45.68,1,getdate(),1,'Complex','None','Municipal Corporation',1,2,'d8048d70-f342-42ca-8372-91a6ebf68d65')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (9,'NonAC-Non-Premium',0,34.27,1,getdate(),1,'Single Screen','None','Municipality',1,2,'3c42dd41-65fe-4d4f-867c-bc0525f32aff')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (10,'NonAC-Non-Premium',0,34.27,1,getdate(),1,'Complex','None','Municipality',1,2,'e87bf4da-79f3-40ca-afb8-ac9fea71c8f2')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (11,'NonAC-Non-Premium',0,22.83,1,getdate(),1,'Single Screen','None','Nagar Panchayats/Gram Panchayats',1,2,'915aab32-80d9-419e-a376-539042108e18')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (12,'NonAC-Non-Premium',0,22.83,1,getdate(),1,'Complex','None','Nagar Panchayats/Gram Panchayats',1,2,'d38c176f-3fc4-46db-a174-174371bb8b59')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (13,'AC-Recliner',0,300.46,1,getdate(),1,'Single Screen','Air-Conditioned','Municipal Corporation',1,3,'d689091a-4224-4fd8-9c4e-b7d21ff1ade4')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (14,'AC-Recliner',0,300.46,1,getdate(),1,'Complex','Air-Conditioned','Municipal Corporation',1,3,'28f33756-1acc-4e2f-b253-e9f3cc527a93')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (15,'AC-Recliner',0,300.46,1,getdate(),1,'Single Screen','Air-Conditioned','Municipality',1,3,'97a7d1ad-23e2-4fdc-9b9a-3873758667c9')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (16,'AC-Recliner',0,300.46,1,getdate(),1,'Complex','Air-Conditioned','Municipality',1,3,'293b9bf4-0fcf-49af-9261-792dca0ede8a')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (17,'AC-Recliner',0,300.46,1,getdate(),1,'Single Screen','Air-Conditioned','Nagar Panchayats/Gram Panchayats',1,3,'6132ee49-468f-43f4-817e-a6c743858211')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (18,'AC-Recliner',0,300.46,1,getdate(),1,'Complex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',1,3,'710bdc7e-add6-48e9-b64c-5f21680d5f76')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (19,'AC-Premium',0,114.19,1,getdate(),1,'Single Screen','Air-Conditioned','Municipal Corporation',1,1,'0d432f89-48ee-402e-b47f-5eb84482a896')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (20,'AC-Premium',0,114.19,1,getdate(),1,'Complex','Air-Conditioned','Municipal Corporation',1,1,'da28212e-43bf-4f7e-8e9e-5a6136a17e9b')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (21,'AC-Premium',0,91.34,1,getdate(),1,'Single Screen','Air-Conditioned','Municipality',1,1,'9028d1f5-a8db-4a2b-b759-ea8316b0be54')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (22,'AC-Premium',0,91.34,1,getdate(),1,'Complex','Air-Conditioned','Municipality',1,1,'7241a2a5-d17b-415f-850e-8bbde465bbbf')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (23,'AC-Premium',0,79.93,1,getdate(),1,'Single Screen','Air-Conditioned','Nagar Panchayats/Gram Panchayats',1,1,'a40beb14-45e5-48a2-ae9c-41da01dc0864')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (24,'AC-Premium',0,79.93,1,getdate(),1,'Complex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',1,1,'fb162dc9-758c-4e9e-845f-0252c617ba50')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (25,'AC-Non-Premium',0,79.93,1,getdate(),1,'Single Screen','Air-Conditioned','Municipal Corporation',1,2,'942827f0-eedb-4d6e-ba95-6088e70e3390')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (26,'AC-Non-Premium',0,79.93,1,getdate(),1,'Complex','Air-Conditioned','Municipal Corporation',1,2,'058e49da-ea13-48fc-85db-f6f9715cc9d3')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (27,'AC-Non-Premium',0,68.51,1,getdate(),1,'Single Screen','Air-Conditioned','Municipality',1,2,'97ffe260-8d0d-47c1-8cde-712a839e3ae8')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (28,'AC-Non-Premium',0,68.51,1,getdate(),1,'Complex','Air-Conditioned','Municipality',1,2,'d1556534-81c2-4b56-b387-f9c9dfc0d0d9')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (29,'AC-Non-Premium',0,57.1,1,getdate(),1,'Single Screen','Air-Conditioned','Nagar Panchayats/Gram Panchayats',1,2,'990c19a1-8983-4199-8e27-fd91cf5536c0')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (30,'AC-Non-Premium',0,57.1,1,getdate(),1,'Complex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',1,2,'83e8925b-d5d5-4a0b-ae14-8a7c948844b5')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (31,'AC-Recliner-Special',0,300.46,1,getdate(),1,'Single Screen','Air-Conditioned','Municipal Corporation',2,3,'d328169d-afcf-4184-a163-dfaad87edd35')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (32,'AC-Recliner-Special',0,300.46,1,getdate(),1,'Complex','Air-Conditioned','Municipal Corporation',2,3,'2983f9fb-0d3c-4e3b-bb14-b1f6684642dd')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (33,'AC-Recliner-Special',0,300.46,1,getdate(),1,'Single Screen','Air-Conditioned','Municipality',2,3,'912acf22-c2c6-4bc4-aaf8-46eb5616b245')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (34,'AC-Recliner-Special',0,300.46,1,getdate(),1,'Complex','Air-Conditioned','Municipality',2,3,'81ba3f0b-ae6d-4f8a-be59-8f0e67758cc1')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (35,'AC-Recliner-Special',0,300.46,1,getdate(),1,'Single Screen','Air-Conditioned','Nagar Panchayats/Gram Panchayats',2,3,'21b72a38-1ba6-4bc7-86d6-eb46d44898e0')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (36,'AC-Recliner-Special',0,300.46,1,getdate(),1,'Complex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',2,3,'892d745e-247a-4503-9560-f896d3ffcd07')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (37,'AC-Premium-Special',0,150.24,1,getdate(),1,'Single Screen','Air-Conditioned','Municipal Corporation',2,1,'49ab5a92-99bf-4878-bf6d-0ddcea65f590')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (38,'AC-Premium-Special',0,150.24,1,getdate(),1,'Complex','Air-Conditioned','Municipal Corporation',2,1,'2922f047-fa7a-4ee4-b2e1-593a35c34afd')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (39,'AC-Premium-Special',0,114.19,1,getdate(),1,'Single Screen','Air-Conditioned','Municipality',2,1,'5d2bf5ec-643e-4521-88f2-8feb5124acf9')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (40,'AC-Premium-Special',0,114.19,1,getdate(),1,'Complex','Air-Conditioned','Municipality',2,1,'54ea91c7-85ea-4c69-bd3c-d3d797fcc916')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (41,'AC-Premium-Special',0,102.78,1,getdate(),1,'Single Screen','Air-Conditioned','Nagar Panchayats/Gram Panchayats',2,1,'153c25d7-7e2e-4b58-bb6b-f0a4ee35d0e2')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (42,'AC-Premium-Special',0,102.78,1,getdate(),1,'Complex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',2,1,'c0f8d097-8203-4f38-b8be-bfc5800dfd76')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (43,'AC-Non-Premium-Special',0,114.19,1,getdate(),1,'Single Screen','Air-Conditioned','Municipal Corporation',2,2,'bbcd1b5c-fd28-4eff-a6d6-08604f7cdd0d')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (44,'AC-Non-Premium-Special',0,114.19,1,getdate(),1,'Complex','Air-Conditioned','Municipal Corporation',2,2,'b9d9d3e5-019e-4b9a-a804-7d5a0ca9f920')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (45,'AC-Non-Premium-Special',0,91.34,1,getdate(),1,'Single Screen','Air-Conditioned','Municipality',2,2,'342c07c7-9b0a-48c3-9aa1-22fa86b4278a')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (46,'AC-Non-Premium-Special',0,91.34,1,getdate(),1,'Complex','Air-Conditioned','Municipality',2,2,'13371811-1a90-4a13-91d5-b7841f4ec4ea')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (47,'AC-Non-Premium-Special',0,79.93,1,getdate(),1,'Single Screen','Air-Conditioned','Nagar Panchayats/Gram Panchayats',2,2,'2e9b9d76-fe88-46d1-aaab-a61b7b14bd6e')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (48,'AC-Non-Premium-Special',0,79.93,1,getdate(),1,'Complex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',2,2,'79097526-dcf4-4448-9103-16d5266e2c03')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (49,'AC-Recliner',0,300.46,1,getdate(),1,'Multiplex','Air-Conditioned','Municipality',3,3,'f3c40401-a9f9-4ca8-b731-8d0b498cae39')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (50,'AC-Recliner',0,300.46,1,getdate(),1,'Multiplex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',3,3,'d209736d-aa3f-4199-9496-763badcf9e40')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (51,'AC-Recliner',0,300.46,1,getdate(),1,'Multiplex','Air-Conditioned','Municipal Corporation',3,3,'0d6d86ed-b43f-417a-938a-3992d9747d07')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (52,'AC-Regular',0,180.29,1,getdate(),1,'Multiplex','Air-Conditioned','Municipality',3,4,'990626d0-ddf3-412f-90ec-35f346f8cc90')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (53,'AC-Regular',0,150.24,1,getdate(),1,'Multiplex','Air-Conditioned','Nagar Panchayats/Gram Panchayats',3,4,'fd5d5d7a-f00e-41c3-b8f8-628bbd791487')
INSERT INTO [PriceCard] (Id, Name, TicketType, Amount, CreatedBy, CreatedOn, IsDeleted, TheatreType, CoolingType, TownType, ScreenType, ClassType,PriceCardGuid) VALUES (54,'AC-Regular',0,114.19,1,getdate(),1,'Multiplex','Air-Conditioned','Municipal Corporation',3,4,'e5114ebc-5f30-4a44-bb00-b76a4aae0b49')
GO

SET IDENTITY_INSERT PriceCard OFF
GO

INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'Base_Ticket_Amount', 'Base Ticket Amount',57,'SURCHARGE','VALUE',57,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'User_Service_Charge', 'User Service Charge',1.17,'SURCHARGE','VALUE',1.17,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'CGST', 'CGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'SGST', 'SGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (1,'Ticket_Amount', 'Ticket Amount',68.51,'SURCHARGE','VALUE',68.51,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'Base_Ticket_Amount', 'Base Ticket Amount',57,'SURCHARGE','VALUE',57,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'User_Service_Charge', 'User Service Charge',1.17,'SURCHARGE','VALUE',1.17,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'CGST', 'CGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'SGST', 'SGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (2,'Ticket_Amount', 'Ticket Amount',68.51,'SURCHARGE','VALUE',68.51,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'Base_Ticket_Amount', 'Base Ticket Amount',47,'SURCHARGE','VALUE',47,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'User_Service_Charge', 'User Service Charge',0.98,'SURCHARGE','VALUE',0.98,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'CGST', 'CGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'SGST', 'SGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (3,'Ticket_Amount', 'Ticket Amount',57.1,'SURCHARGE','VALUE',57.1,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'Base_Ticket_Amount', 'Base Ticket Amount',47,'SURCHARGE','VALUE',47,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'User_Service_Charge', 'User Service Charge',0.98,'SURCHARGE','VALUE',0.98,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'CGST', 'CGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'SGST', 'SGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (4,'Ticket_Amount', 'Ticket Amount',57.1,'SURCHARGE','VALUE',57.1,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'Base_Ticket_Amount', 'Base Ticket Amount',37,'SURCHARGE','VALUE',37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'User_Service_Charge', 'User Service Charge',0.78,'SURCHARGE','VALUE',0.78,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'CGST', 'CGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'SGST', 'SGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (5,'Ticket_Amount', 'Ticket Amount',45.68,'SURCHARGE','VALUE',45.68,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'Base_Ticket_Amount', 'Base Ticket Amount',37,'SURCHARGE','VALUE',37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'User_Service_Charge', 'User Service Charge',0.78,'SURCHARGE','VALUE',0.78,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'CGST', 'CGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'SGST', 'SGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (6,'Ticket_Amount', 'Ticket Amount',45.68,'SURCHARGE','VALUE',45.68,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'Base_Ticket_Amount', 'Base Ticket Amount',37,'SURCHARGE','VALUE',37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'User_Service_Charge', 'User Service Charge',0.78,'SURCHARGE','VALUE',0.78,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'CGST', 'CGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'SGST', 'SGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (7,'Ticket_Amount', 'Ticket Amount',45.68,'SURCHARGE','VALUE',45.68,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'Base_Ticket_Amount', 'Base Ticket Amount',37,'SURCHARGE','VALUE',37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'User_Service_Charge', 'User Service Charge',0.78,'SURCHARGE','VALUE',0.78,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'CGST', 'CGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'SGST', 'SGST',2.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.05,'SURCHARGE','VALUE',0.05,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (8,'Ticket_Amount', 'Ticket Amount',45.68,'SURCHARGE','VALUE',45.68,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'Base_Ticket_Amount', 'Base Ticket Amount',27,'SURCHARGE','VALUE',27,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'User_Service_Charge', 'User Service Charge',0.59,'SURCHARGE','VALUE',0.59,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'CGST', 'CGST',1.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'SGST', 'SGST',1.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.04,'SURCHARGE','VALUE',0.04,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.04,'SURCHARGE','VALUE',0.04,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (9,'Ticket_Amount', 'Ticket Amount',34.27,'SURCHARGE','VALUE',34.27,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'Base_Ticket_Amount', 'Base Ticket Amount',27,'SURCHARGE','VALUE',27,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'User_Service_Charge', 'User Service Charge',0.59,'SURCHARGE','VALUE',0.59,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'CGST', 'CGST',1.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'SGST', 'SGST',1.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.04,'SURCHARGE','VALUE',0.04,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.04,'SURCHARGE','VALUE',0.04,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (10,'Ticket_Amount', 'Ticket Amount',34.27,'SURCHARGE','VALUE',34.27,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'Base_Ticket_Amount', 'Base Ticket Amount',17,'SURCHARGE','VALUE',17,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'User_Service_Charge', 'User Service Charge',0.39,'SURCHARGE','VALUE',0.39,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'CGST', 'CGST',1.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'SGST', 'SGST',1.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.02,'SURCHARGE','VALUE',0.02,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.02,'SURCHARGE','VALUE',0.02,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (11,'Ticket_Amount', 'Ticket Amount',22.83,'SURCHARGE','VALUE',22.83,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'Base_Ticket_Amount', 'Base Ticket Amount',17,'SURCHARGE','VALUE',17,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'Maintenance_Charge', 'Maintenance Charge',3,'SURCHARGE','VALUE',3,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'User_Service_Charge', 'User Service Charge',0.39,'SURCHARGE','VALUE',0.39,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'CGST', 'CGST',1.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'SGST', 'SGST',1.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.02,'SURCHARGE','VALUE',0.02,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.02,'SURCHARGE','VALUE',0.02,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (12,'Ticket_Amount', 'Ticket Amount',22.83,'SURCHARGE','VALUE',22.83,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (13,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (14,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (15,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (16,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (17,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (18,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (19,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (20,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'Base_Ticket_Amount', 'Base Ticket Amount',75,'SURCHARGE','VALUE',75,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'User_Service_Charge', 'User Service Charge',1.56,'SURCHARGE','VALUE',1.56,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'CGST', 'CGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'SGST', 'SGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (21,'Ticket_Amount', 'Ticket Amount',91.34,'SURCHARGE','VALUE',91.34,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'Base_Ticket_Amount', 'Base Ticket Amount',75,'SURCHARGE','VALUE',75,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'User_Service_Charge', 'User Service Charge',1.56,'SURCHARGE','VALUE',1.56,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'CGST', 'CGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'SGST', 'SGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (22,'Ticket_Amount', 'Ticket Amount',91.34,'SURCHARGE','VALUE',91.34,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'Base_Ticket_Amount', 'Base Ticket Amount',65,'SURCHARGE','VALUE',65,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'User_Service_Charge', 'User Service Charge',1.37,'SURCHARGE','VALUE',1.37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'CGST', 'CGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'SGST', 'SGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (23,'Ticket_Amount', 'Ticket Amount',79.93,'SURCHARGE','VALUE',79.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'Base_Ticket_Amount', 'Base Ticket Amount',65,'SURCHARGE','VALUE',65,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'User_Service_Charge', 'User Service Charge',1.37,'SURCHARGE','VALUE',1.37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'CGST', 'CGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'SGST', 'SGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (24,'Ticket_Amount', 'Ticket Amount',79.93,'SURCHARGE','VALUE',79.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'Base_Ticket_Amount', 'Base Ticket Amount',65,'SURCHARGE','VALUE',65,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'User_Service_Charge', 'User Service Charge',1.37,'SURCHARGE','VALUE',1.37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'CGST', 'CGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'SGST', 'SGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (25,'Ticket_Amount', 'Ticket Amount',79.93,'SURCHARGE','VALUE',79.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'Base_Ticket_Amount', 'Base Ticket Amount',65,'SURCHARGE','VALUE',65,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'User_Service_Charge', 'User Service Charge',1.37,'SURCHARGE','VALUE',1.37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'CGST', 'CGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'SGST', 'SGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (26,'Ticket_Amount', 'Ticket Amount',79.93,'SURCHARGE','VALUE',79.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'Base_Ticket_Amount', 'Base Ticket Amount',55,'SURCHARGE','VALUE',55,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'User_Service_Charge', 'User Service Charge',1.17,'SURCHARGE','VALUE',1.17,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'CGST', 'CGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'SGST', 'SGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (27,'Ticket_Amount', 'Ticket Amount',68.51,'SURCHARGE','VALUE',68.51,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'Base_Ticket_Amount', 'Base Ticket Amount',55,'SURCHARGE','VALUE',55,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'User_Service_Charge', 'User Service Charge',1.17,'SURCHARGE','VALUE',1.17,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'CGST', 'CGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'SGST', 'SGST',3.6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.07,'SURCHARGE','VALUE',0.07,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (28,'Ticket_Amount', 'Ticket Amount',68.51,'SURCHARGE','VALUE',68.51,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'Base_Ticket_Amount', 'Base Ticket Amount',45,'SURCHARGE','VALUE',45,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'User_Service_Charge', 'User Service Charge',0.98,'SURCHARGE','VALUE',0.98,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'CGST', 'CGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'SGST', 'SGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (29,'Ticket_Amount', 'Ticket Amount',57.1,'SURCHARGE','VALUE',57.1,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'Base_Ticket_Amount', 'Base Ticket Amount',45,'SURCHARGE','VALUE',45,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'User_Service_Charge', 'User Service Charge',0.98,'SURCHARGE','VALUE',0.98,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'CGST', 'CGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'SGST', 'SGST',3,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.06,'SURCHARGE','VALUE',0.06,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (30,'Ticket_Amount', 'Ticket Amount',57.1,'SURCHARGE','VALUE',57.1,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (31,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (32,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (33,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (34,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (35,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (36,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'Base_Ticket_Amount', 'Base Ticket Amount',120,'SURCHARGE','VALUE',120,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'User_Service_Charge', 'User Service Charge',2.44,'SURCHARGE','VALUE',2.44,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'CGST', 'CGST',11.25,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'SGST', 'SGST',11.25,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.15,'SURCHARGE','VALUE',0.15,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.15,'SURCHARGE','VALUE',0.15,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (37,'Ticket_Amount', 'Ticket Amount',150.24,'SURCHARGE','VALUE',150.24,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'Base_Ticket_Amount', 'Base Ticket Amount',120,'SURCHARGE','VALUE',120,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'User_Service_Charge', 'User Service Charge',2.44,'SURCHARGE','VALUE',2.44,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'CGST', 'CGST',11.25,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'SGST', 'SGST',11.25,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.15,'SURCHARGE','VALUE',0.15,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.15,'SURCHARGE','VALUE',0.15,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (38,'Ticket_Amount', 'Ticket Amount',150.24,'SURCHARGE','VALUE',150.24,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (39,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (40,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'Base_Ticket_Amount', 'Base Ticket Amount',85,'SURCHARGE','VALUE',85,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'User_Service_Charge', 'User Service Charge',1.76,'SURCHARGE','VALUE',1.76,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'CGST', 'CGST',5.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'SGST', 'SGST',5.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.11,'SURCHARGE','VALUE',0.11,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.11,'SURCHARGE','VALUE',0.11,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (41,'Ticket_Amount', 'Ticket Amount',102.78,'SURCHARGE','VALUE',102.78,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'Base_Ticket_Amount', 'Base Ticket Amount',85,'SURCHARGE','VALUE',85,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'User_Service_Charge', 'User Service Charge',1.76,'SURCHARGE','VALUE',1.76,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'CGST', 'CGST',5.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'SGST', 'SGST',5.4,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.11,'SURCHARGE','VALUE',0.11,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.11,'SURCHARGE','VALUE',0.11,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (42,'Ticket_Amount', 'Ticket Amount',102.78,'SURCHARGE','VALUE',102.78,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (43,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (44,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'Base_Ticket_Amount', 'Base Ticket Amount',75,'SURCHARGE','VALUE',75,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'User_Service_Charge', 'User Service Charge',1.56,'SURCHARGE','VALUE',1.56,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'CGST', 'CGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'SGST', 'SGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (45,'Ticket_Amount', 'Ticket Amount',91.34,'SURCHARGE','VALUE',91.34,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'Base_Ticket_Amount', 'Base Ticket Amount',75,'SURCHARGE','VALUE',75,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'User_Service_Charge', 'User Service Charge',1.56,'SURCHARGE','VALUE',1.56,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'CGST', 'CGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'SGST', 'SGST',4.8,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.09,'SURCHARGE','VALUE',0.09,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (46,'Ticket_Amount', 'Ticket Amount',91.34,'SURCHARGE','VALUE',91.34,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'Base_Ticket_Amount', 'Base Ticket Amount',65,'SURCHARGE','VALUE',65,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'User_Service_Charge', 'User Service Charge',1.37,'SURCHARGE','VALUE',1.37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'CGST', 'CGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'SGST', 'SGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (47,'Ticket_Amount', 'Ticket Amount',79.93,'SURCHARGE','VALUE',79.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'Base_Ticket_Amount', 'Base Ticket Amount',65,'SURCHARGE','VALUE',65,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'User_Service_Charge', 'User Service Charge',1.37,'SURCHARGE','VALUE',1.37,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'CGST', 'CGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'SGST', 'SGST',4.2,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.08,'SURCHARGE','VALUE',0.08,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (48,'Ticket_Amount', 'Ticket Amount',79.93,'SURCHARGE','VALUE',79.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (49,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (50,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'Base_Ticket_Amount', 'Base Ticket Amount',245,'SURCHARGE','VALUE',245,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'User_Service_Charge', 'User Service Charge',4.88,'SURCHARGE','VALUE',4.88,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'CGST', 'CGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'SGST', 'SGST',22.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.29,'SURCHARGE','VALUE',0.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (51,'Ticket_Amount', 'Ticket Amount',300.46,'SURCHARGE','VALUE',300.46,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'Base_Ticket_Amount', 'Base Ticket Amount',145,'SURCHARGE','VALUE',145,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'User_Service_Charge', 'User Service Charge',2.93,'SURCHARGE','VALUE',2.93,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'CGST', 'CGST',13.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'SGST', 'SGST',13.5,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.18,'SURCHARGE','VALUE',0.18,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.18,'SURCHARGE','VALUE',0.18,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (52,'Ticket_Amount', 'Ticket Amount',180.29,'SURCHARGE','VALUE',180.29,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'Base_Ticket_Amount', 'Base Ticket Amount',120,'SURCHARGE','VALUE',120,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'User_Service_Charge', 'User Service Charge',2.44,'SURCHARGE','VALUE',2.44,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'CGST', 'CGST',11.25,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'SGST', 'SGST',11.25,'SURCHARGE','PERCENTAGE',9,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.15,'SURCHARGE','VALUE',0.15,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.15,'SURCHARGE','VALUE',0.15,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (53,'Ticket_Amount', 'Ticket Amount',150.24,'SURCHARGE','VALUE',150.24,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'Base_Ticket_Amount', 'Base Ticket Amount',95,'SURCHARGE','VALUE',95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'Maintenance_Charge', 'Maintenance Charge',5,'SURCHARGE','VALUE',5,1)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'User_Service_Charge', 'User Service Charge',1.95,'SURCHARGE','VALUE',1.95,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'CGST', 'CGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'SGST', 'SGST',6,'SURCHARGE','PERCENTAGE',6,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'User_Service_Charge_CGST_6_Per', 'User Service Charge CGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'User_Service_Charge_SGST_6_Per', 'User Service Charge SGST 6%',0.12,'SURCHARGE','VALUE',0.12,0)
INSERT INTO PriceCardDetails(PriceCardId, Code, Name, Price, Type, CalculationType, ValueByCalculationType, ApplyGST) VALUES (54,'Ticket_Amount', 'Ticket Amount',114.19,'SURCHARGE','VALUE',114.19,0)
GO


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
	IsTaxLossReport,
	IsUserwisePaymentTypeSummaryReport
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
)
GO

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
	IsTaxLossReport,
	IsUserwisePaymentTypeSummaryReport
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
)
GO
/* Master entries for the table 'Type' */
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',0,'MyType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',1,'TableType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',2,'ComplexType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',3,'TransactionLogType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',4,'BoxOfficeLicenseType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',5,'ClientType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',6,'UserRoleType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',7,'StartPageType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',8,'PrintType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',9,'PrintOrientationType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',10,'ScreenType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',11,'FilmFormatType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',12,'ProjectorTechnologyType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',13,'SoundTechnologyType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',14,'MovieType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',15,'MovieLanguageType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',16,'MovieCensorRatingType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',17,'MovieGenreType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',18,'SeatType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',19,'QuotaType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',20,'PaymentType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',21,'StatusType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',22,'TransactionType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',23,'OrderType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',24,'ChangeQuotaType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',25,'PriceType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',26,'SalesTaxType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',27,'UnitOfMeasureType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',28,'ItemClass')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',29,'TicketType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',30,'HealthSafetyAlertType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',31,'ScreenType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (0,'MyType',32,'ClassType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',0,'Complex')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',1,'Type')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',2,'BoxOfficeUser')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',3,'Screen')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',4,'ClassLayout')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',5,'SeatLayout')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',6,'Show')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',7,'ShowMIS')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',8,'Class')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',9,'ClassMIS')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',10,'Seat')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',11,'SeatMIS')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',12,'Item')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',13,'Canteen')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',14,'CanteenMIS')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',15,'Log')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',16,'LogMIS')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',17,'DCR')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',18,'Report')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (1,'TableType',19,'ParkingType')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',0,'Regular')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',1,'Theater')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',2,'Complex')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',3,'Multiplex')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',4,'Megaplex')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',5,'Plaza')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',6,'Mall')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',7,'Hall')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',8,'Mini')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',9,'DriveIn')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',10,'DineIn')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',11,'OpenAir')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',12,'Home')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (2,'ComplexType',13,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (3,'TransactionLogType',0,'None')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (3,'TransactionLogType',1,'Light')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (3,'TransactionLogType',2,'Medium')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (3,'TransactionLogType',3,'Heavy')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (3,'TransactionLogType',4,'Bulk')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (4,'BoxOfficeLicenseType',0,'Evaluation')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (4,'BoxOfficeLicenseType',1,'Basic')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (4,'BoxOfficeLicenseType',2,'Professional')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (4,'BoxOfficeLicenseType',3,'Enterprise')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (4,'BoxOfficeLicenseType',4,'Ultimate')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (5,'ClientType',0,'Any_Direct')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (5,'ClientType',1,'Central_Direct')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (5,'ClientType',2,'Online_Direct')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (5,'ClientType',3,'Agent_Direct')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (5,'ClientType',4,'Mobile_Direct')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',0,'Super_Admin')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',1,'Administrator')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',2,'Complex_Owner')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',3,'Complex_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',4,'Complex_Supervisor')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',5,'Booking_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',6,'Booking_Supervisor')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',7,'Booking_Clerk')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',8,'Booking_Assistant')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleTypeDel',9,'Kiosk_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleTypeDel',10,'Kiosk_Assistant')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',11,'QR_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',12,'QR_Sentry')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',13,'Food_And_Beverage_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',14,'Food_And_Beverage_Clerk')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',15,'Online_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',16,'Report_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',17,'User_Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',18,'DCR_Auditor')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',19,'Custom')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',20,'Field_Support')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (6,'UserRoleType',21,'Operations')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',0,'Welcome_Page')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',1,'Shows_By_Week')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',2,'Shows_By_Day')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',3,'Food_And_Beverage_Counter')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',4,'Kiosk_Interface')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',5,'QR_Sentry')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',6,'Booking_Status_Display')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (7,'StartPageType',7,'Reports')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',0,'None')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',1,'RegularTicket3x3Type1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',2,'RegularTicket3x3Type2')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',3,'BarcodeTicket3x3')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',4,'RegularTicket4x3Type1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',5,'RegularTicket4x3Type2')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',6,'BarcodeTicket4x3')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',7,'SensorRegularTicket3x3')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',8,'TwoPerforationSensorRegularTicket3X3Type1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',9,'TwoPerforationSensorRegularTicket3X3Type2')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',10,'TwoPerforationSensorRegularTicket3X3Type3')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',11,'TwoPerforationSensorRegularTicket4X4Type1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',12,'TwoPerforationSensorRegularTicket4X4Type2')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',13,'TwoPerforationSensorRegularTicket4X4Type3')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',14,'RegularTicket6x3Type1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',15,'RegularTicket6x3Type2')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',16,'RegularTicket6x3Type3')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (8,'PrintType',17,'RegularTicket6x3Type4')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (9,'PrintOrientationType',0,'Portrait')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (9,'PrintOrientationType',1,'Landscape')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',0,'Regular')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',1,'3D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',2,'4D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',3,'IMax')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',4,'IMax3D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',5,'IMax4D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (10,'ScreenType',6,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',0,'Regular')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',1,'70_mm')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',2,'65_mm')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',3,'35_mm')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',4,'Super_35_mm')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',5,'16_mm')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',6,'Digital')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',7,'Wide_Screen')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',8,'Academy')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',9,'Vista_Vision')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (11,'FilmFormatType',10,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (12,'ProjectorTechnologyType',0,'Regular')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (12,'ProjectorTechnologyType',1,'1_Reel')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (12,'ProjectorTechnologyType',2,'2_Reel')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (12,'ProjectorTechnologyType',3,'Change_Over')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (12,'ProjectorTechnologyType',4,'Digital')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (12,'ProjectorTechnologyType',5,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',0,'4 Track Stereo')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',1,'6 Track 70mm')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',2,'Auro 11.1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',3,'Cinesound')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',4,'Datasat Digital Sound')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',5,'Digital 5.1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',6,'Digital 7.1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',7,'Dolby')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',8,'Dolby Atmos')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',9,'Dolby Digital')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',10,'Dolby Digital 2.0 Stereo')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',11,'Dolby Digital 5.1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',12,'Dolby Digital EX')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',13,'Dolby SR')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',14,'Dolby Surround 7.1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',15,'Dolby TrueHD')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',16,'DTS')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',17,'DTS 5.1 Surround')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',18,'DTS HD')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',19,'DTS HD 5.1')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',20,'DTS HD Master Audio')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',21,'DTS Stereo')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',22,'Mono')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',23,'Silent')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',24,'Sonics-DDP')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',25,'Sony Dynamic Digital Sound')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',26,'Stereo')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',27,'Ultra Stereo')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (13,'SoundTechnologyType',28,'Western Electric')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',0,'Visual_2D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',1,'3D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',2,'IMax')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',3,'IMax_3D')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',4,'HFR')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',5,'Subtitle')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',6,'4K')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (14,'MovieType',7,'4DX')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',0,'English')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',1,'Hindi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',2,'Tamil')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',3,'Telugu')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',4,'Marathi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',5,'Kannada')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',6,'Malayalam')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',7,'Gujarati')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',8,'Bhojpuri')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',9,'Oriya')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',10,'Punjabi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',11,'Bengali')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',12,'Assamese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',13,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',14,'Banjara')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',15,'Chhattisgarhi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',16,'Haryanvi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',17,'Nagpuri')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',18,'Nepali')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',19,'Pushtu')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',20,'Rajasthani')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',21,'Sindhi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',22,'Sourashtra')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',23,'Arabic')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',24,'Badaga')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',25,'Bhutani')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',26,'Brijbasi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',27,'Burmese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',28,'Cantonese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',29,'Catalan')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',30,'Chinese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',31,'Deccani (Dakhini)')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',32,'Desiya')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',33,'French')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',34,'Garhwali')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',35,'German')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',36,'Gondhi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',37,'Gujjar')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',38,'Himachali')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',39,'Hindustani')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',40,'Hinglish')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',41,'Italian')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',42,'Japanese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',43,'Kashmiri')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',44,'Kazakh')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',45,'Konkani')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',46,'Korean')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',47,'Ladakhi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',48,'Magadhi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',49,'Maithili')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',50,'Malay')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',51,'Mandarin')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',52,'Manipuri')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',53,'Marwadi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',54,'Music')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',55,'Parsi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',56,'Pashtu')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',57,'Persian')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',58,'Polish')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',59,'Portuguese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',60,'Russian')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',61,'Sanskrit')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',62,'Silent')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',63,'Sinhala')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',64,'Slovak')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',65,'Slovenian')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',66,'Somali')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',67,'Spanish')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',68,'Swedish')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',69,'Thai')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',70,'Turkish')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',71,'Urdu')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',72,'Uttarakhandi')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',73,'Uttaranchalee')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (15,'MovieLanguageType',74,'Vietnamese')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (16,'MovieCensorRatingType',0,'U')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (16,'MovieCensorRatingType',1,'U/A')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (16,'MovieCensorRatingType',2,'A')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (16,'MovieCensorRatingType',3,'S')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',0,'None')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',1,'Action')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',2,'Adventure')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',3,'Drama')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',4,'Comedy')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',5,'Crime')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',6,'Historical')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',7,'Horror')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',8,'Musical')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',9,'Fiction')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',10,'War')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',11,'Western')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',12,'Adult')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',13,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',14,'Action_&_Romance')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',15,'Animation')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',16,'Children')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',17,'Family')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',18,'Love')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',19,'Love_&_Action')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',20,'Love_&_Romance')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',21,'Mythology')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (17,'MovieGenreType',22,'Thrillers')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (18,'SeatType',0,'Regular')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (18,'SeatType',1,'Gangway')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (18,'SeatType',2,'Couple')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (19,'QuotaType',0,'Counter')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (19,'QuotaType',1,'Manager')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (19,'QuotaType',2,'TeleBooking')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (19,'QuotaType',3,'Online')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (20,'PaymentType',0,'Cash')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (20,'PaymentType',1,'Online')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (20,'PaymentType',2,'CreditCard')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (20,'PaymentType',3,'DebitCard')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',0,'Open')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',1,'Blocked')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',2,'Sold')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',3,'Occupied')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',4,'RealTimeBlock')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',5,'HandoffBlock')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (21,'StatusType',6,'UnpaidBook')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (22,'TransactionType',0,'Event')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (22,'TransactionType',1,'Warning')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (22,'TransactionType',2,'Error')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (22,'TransactionType',4,'Critical')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (23,'OrderType',0,'Sale')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (23,'OrderType',1,'Cancel due to Damage')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (23,'OrderType',2,'Cancel Order')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (23,'OrderType',3,'PackageTicket')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (24,'ChangeQuotaType',0,'Increase_Quota')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (24,'ChangeQuotaType',1,'Decrease_Quota')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (25,'PriceType',0,'Fixed')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (25,'PriceType',1,'Variable')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (26,'SalesTaxType',0,'SalesTax')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (26,'SalesTaxType',1,'TaxExempt')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',0,'Bag')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',1,'Bottle')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',2,'Box')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',3,'Cup')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',4,'Each')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',5,'Kilogram')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',6,'Litre')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',7,'Ounce')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',8,'Pack')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',9,'Pound')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',10,'Serving')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (27,'UnitOfMeasureType',11,'Slice')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',0,'Sweet Or Candy')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',1,'Drinks')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',2,'Food')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',3,'Gift')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',4,'Card Sale')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',5,'Hot Drinks')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',6,'Ice Cream')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',7,'Pop Corn')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',8,'Merchandise')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',9,'Theatre Products')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',10,'Item Packages')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (28,'ItemClass',11,'Other')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (29,'TicketType',0,'Regular')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (29,'TicketType',1,'Defence')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (29,'TicketType',2,'Complimentary')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (30,'HealthSafetyAlertType',0,'Temperature Checks')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (30,'HealthSafetyAlertType',1,'Masks Mandatory')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (30,'HealthSafetyAlertType',2,'Contactless Ticketing')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (30,'HealthSafetyAlertType',3,'Reduced Capacity')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (30,'HealthSafetyAlertType',4,'Regular Sanitisation')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (31,'ScreenType',1,'Non-Special')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (31,'ScreenType',2,'Special')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (31,'ScreenType',3,'Screen-Multiplex')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (32,'ClassType',1,'Premium')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (32,'ClassType',2,'Non-Premium')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (32,'ClassType',3,'Recliner')
INSERT INTO Type(TypeNo,TypeName,Value,Expression) VALUES (32,'ClassType',4,'Regular')
GO

/* Master entries for Report Data */
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','DailyCollectionReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','AdvanceSalesSummaryReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','PerformanceReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','ScreeningSchedule')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','BoxOfficeSalesSummaryReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','BoxOfficeReceiptsSummary')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','BoxOfficeSummary')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','DistributorReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','CancelledShowDetails')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','DailyCollectionSummaryReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','Show','ProductSales')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','General','CashierReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','General','TransactionReport')
INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','General','UserwisePaymentTypeSummaryReport')
/*INSERT INTO Report (PhaseName, TableName, ReportName) VALUES ('Current','General','UnclaimedStock')*/
GO

/* Default Taxes */
IF NOT EXISTS(SELECT ServiceTax FROM Taxes)
	INSERT INTO Taxes(ServiceTax, SwachhBharatCess, LastModifiedBy, LastModifiedOn) SELECT '0.00', '0.00', (SELECT UserID FROM BoxOfficeUser WHERE Username = 'YSAdmin' ), GETDATE()
GO

/* Default 10X8 matrix setup order */
IF NOT EXISTS(SELECT TOP 1 ID FROM SetupOrder)
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @RowNo INT
			DECLARE @ColNo INT
			SET @RowNo = 0
			WHILE (@RowNo < 10)
			BEGIN
				SET @ColNo = 0
				WHILE (@ColNo < 8)
				BEGIN
					INSERT INTO SetupOrder (
						Row,
						[Column]
					) VALUES (
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
END
GO