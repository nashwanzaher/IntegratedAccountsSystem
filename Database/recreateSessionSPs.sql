-- P11P2: Recreate session SPs with QUOTED_IDENTIFIER=ON
-- Requires: sqlcmd -I -S MRGFG-32\SQLEXPRESS -d accountSysDB -i recreateSessionSPs.sql
-- The -I flag enables QUOTED_IDENTIFIER at connection level for all SP operations.

USE accountSysDB;
GO

DROP PROCEDURE IF EXISTS dbo.createSession;
GO

CREATE PROCEDURE dbo.createSession
    @userCode      INT,
    @userID        NVARCHAR(15),
    @braCode       INT,
    @machineName   NVARCHAR(100) = NULL,
    @sessionToken  UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @token UNIQUEIDENTIFIER = NEWID();
    UPDATE tblSessions
    SET isActive = 0, logoutAt = GETDATE()
    WHERE userCode = @userCode AND braCode = @braCode AND isActive = 1;
    INSERT INTO tblSessions (sessionToken, userCode, userID, braCode, machineName, expiresAt)
    VALUES (@token, @userCode, @userID, @braCode, @machineName, DATEADD(HOUR, 1, GETDATE()));
    SET @sessionToken = @token;
END
GO