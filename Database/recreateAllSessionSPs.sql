-- P11P2: Recreate ALL session SPs with QUOTED_IDENTIFIER=ON
-- Required because filtered indexes require QUOTED_IDENTIFIER=ON
-- Run with: sqlcmd -I -S MRGFG-32\SQLEXPRESS -d accountSysDB -i Database/recreateAllSessionSPs.sql

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

DROP PROCEDURE IF EXISTS dbo.validateSession;
GO
CREATE PROCEDURE dbo.validateSession
    @sessionToken  UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sessionID, sessionToken, userCode, userID, braCode, machineName,
           createdAt, lastActivityAt, expiresAt, isActive
    FROM tblSessions
    WHERE sessionToken = @sessionToken
      AND isActive = 1
      AND (expiresAt IS NULL OR expiresAt > GETDATE());
END
GO

DROP PROCEDURE IF EXISTS dbo.updateSessionActivity;
GO
CREATE PROCEDURE dbo.updateSessionActivity
    @sessionToken  UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblSessions
    SET lastActivityAt = GETDATE(),
        expiresAt = DATEADD(HOUR, 1, GETDATE())
    WHERE sessionToken = @sessionToken AND isActive = 1;
END
GO

DROP PROCEDURE IF EXISTS dbo.endSession;
GO
CREATE PROCEDURE dbo.endSession
    @sessionToken  UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblSessions
    SET isActive = 0, logoutAt = GETDATE()
    WHERE sessionToken = @sessionToken AND isActive = 1;
END
GO

DROP PROCEDURE IF EXISTS dbo.expireOldSessions;
GO
CREATE PROCEDURE dbo.expireOldSessions
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblSessions
    SET isActive = 0, logoutAt = GETDATE()
    WHERE isActive = 1 AND expiresAt IS NOT NULL AND expiresAt < GETDATE();
END
GO