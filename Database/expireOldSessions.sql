-- expireOldSessions.sql
-- Runs expireOldSessions stored procedure
-- Scheduled via Windows Task Scheduler (sqlcmd)
-- Replace instance name and database as needed
:setvar Instance "MRGFG-32\SQLEXPRESS"
:setvar Database "accountSysDB"

USE $(Database);
GO

EXEC dbo.expireOldSessions;
GO