-- Enable advanced options
USE master;
GO
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

-- Enable EKM provider
sp_configure 'EKM provider enabled', 1;
GO
RECONFIGURE;
GO

-- Create cryptographic provider
CREATE CRYPTOGRAPHIC PROVIDER SQLTDE
FROM FILE = 'C:\Program Files\SQL Server Connector for Microsoft Azure Key Vault\Microsoft.AzureKeyVaultService.EKM.dll'

-- Create credentials
USE master;
CREATE CREDENTIAL SQLTDECRED
    WITH IDENTITY = 'SQLTDEKeys',
    SECRET = '----------vv9309r8290rsdvlksdfklwfkljdklfjglk||kwfkljfjwf==sdfkndf=='
FOR CRYPTOGRAPHIC PROVIDER SQLTDE

ALTER LOGIN [sa]
    ADD CREDENTIAL SQLTDECRED

-- Create asymmetric key
CREATE ASYMMETRIC KEY SQLTDEAsymKey
FROM PROVIDER SQLTDE
WITH PROVIDER_KEY_NAME ='SQLTDEKey',
CREATION_DISPOSITION = OPEN_EXISTING;

CREATE LOGIN TDELogin
FROM ASYMMETRIC KEY SQLTDEAsymKey

ALTER LOGIN [sa] DROP CREDENTIAL SQLTEDCRED
GO

ALTER LOGIN [TDELogin] 
    ADD CREDENTIAL SQLTDECRED
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER ASYMMETRIC KEY SQLTDEAsymKey
GO

ALTER DATABASE [WideWorldImporters]
    SET ENCRYPTION ON;

SELECT 
    name as 'WideWorldImporters', 
    CASE encryption_state
        WHEN 0 THEN 'No database encryption key present, no encryption'
        WHEN 1 THEN 'Unencrypted'
        WHEN 2 THEN 'Encryption in progress'
        WHEN 3 THEN 'Encrypted'
        WHEN 4 THEN 'Key change in progress'
        WHEN 5 THEN 'Decryption in progress'
        WHEN 5 THEN 'Protection change in progress'
    END AS status
FROM 
    sys.dm_database_encryption_keys e 
JOIN 
    sys.sysdatabases d
ON 
    e.database_id = d.dbid