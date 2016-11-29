/*
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO
*/

Declare @Object as Int;
DECLARE @hr		INT;
Declare @payload_len as Int;
Declare @ResponseText as Varchar(8000);
DECLARE @sentry_auth AS VARCHAR(8000);
DECLARE @msg	VARCHAR(8000);
declare @auth_tk varchar(2000) = 'c267eabbed18475b8f03e051d1a87c4a';
Declare @payload as varchar(8000) = '
{
  "event_id": "$gui",
  "culprit": "$culprit",
  "timestamp": "2011-05-02T17:41:36",
  "message": "$message",
  "platform": "plsql",
  "server_name": "$servername",
  "level": "$level",
  "tags": {
    "db_version": "$dbversion",
    "sid": "$oraclesid",
    "current_schema": "$current_schema"
  },
  "exception": [
    {
      "type": "Error type",
      "value": "Error value",
      "module": "Module"
    }
  ]
}';



SET @payload = replace(@payload, '$gui', LOWER(NEWID()))
SET @payload = replace(@payload, '$culprit', 'RavenClient')

-- add timestamp
SET @payload = replace(@payload, '$message', 'Messaggio di errore');
SET @payload = replace(@payload, '$servername', @@SERVERNAME);
SET @payload = replace(@payload, '$level', '1');

SET @payload = replace(@payload, '$dbversion', '2');
SET @payload = replace(@payload, '$oraclesid', 'dbversion');
SET @payload = replace(@payload, '$current_schema', 'schema');

SET @payload = REPLACE(@payload, CHAR(13), '');
SET @payload = replace(@payload, char(10), '');
SET @payload = replace(@payload, '\', '\\');
SET @payload = ltrim(rtrim(@payload));

SET @sentry_auth = 'Sentry sentry_version=5,sentry_timestamp=$sentry_time,sentry_key=$sentry_public,sentry_secret=$sentry_secret'
SET @sentry_auth = replace(@sentry_auth, '$sentry_time', '2016-01-01 23:00:00')
SET @sentry_auth = replace(@sentry_auth, '$sentry_public', '7c40aa0e88774cdf80c81328b91e307f')
SET @sentry_auth = replace(@sentry_auth, '$sentry_secret', 'f4914b0a125b4c908f4c4e2ddb5fad6f')

select @sentry_auth

Exec @hr = sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
IF @hr <> 0 BEGIN SET @Msg = 'sp_OACreate WinHttp.WinHttpRequest.5.1 failed. Cannot connect to Blockchain.info' GOTO Error END

--EXEC  sp_OAMethod @Object, 'open', NULL, 'post','https://7c40aa0e88774cdf80c81328b91e307f:f4914b0a125b4c908f4c4e2ddb5fad6f@sentry.io/29639', 'false'
--EXEC  sp_OAMethod @Object, 'open', NULL, 'post','https://7c40aa0e88774cdf80c81328b91e307f:f4914b0a125b4c908f4c4e2ddb5fad6f@sentry.io/api/29639/store', 'false'

EXEC  sp_OAMethod @Object, 'open', NULL, 'post','https://sentry.io/api/29639/store', 'false'

--EXEC  sp_OAMethod @Object, 'open', NULL, 'post','http://requestb.in/12pic6t1', 'false'
--http://sentry.apexnet.it/api/12/store/
SELECT @payload_len = len(@payload)

--c267eabbed18475b8f03e051d1a87c4a

  
Exec @hr = sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
IF @hr <> 0 BEGIN SET @msg = 'sp_OAMethod 1.' GOTO Error END

Exec @hr = sp_OAMethod @Object, 'setRequestHeader', null, 'User-agent', 'raven-mssql/1.0'
IF @hr <> 0 BEGIN SET @msg = 'sp_OAMethod 2' GOTO Error END

Exec @hr = sp_OAMethod @Object, 'setRequestHeader', null, 'payload-Type', 'application/json;charset=UTF-8'
IF @hr <> 0 BEGIN SET @msg = 'sp_OAMethod 3' GOTO Error END

Exec @hr = sp_OAMethod @Object, 'setRequestHeader', null, 'Accept', 'application/json'
IF @hr <> 0 BEGIN SET @msg = 'sp_OAMethod 4' GOTO Error END

--Exec @hr = sp_OAMethod @Object, 'setRequestHeader', null, 'X-Sentry-Auth',  @sentry_auth
Exec @hr = sp_OAMethod @Object, 'setRequestHeader', null, 'Authorization', 'Bearer c267eabbed18475b8f03e051d1a87c4a'
IF @hr <> 0 BEGIN SET @msg = 'sp_OAMethod 5' GOTO Error END


--Exec @hr =  sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Length', @payload_len
--IF @hr <> 0 BEGIN SET @msg = 'sp_OAMethod 6' GOTO Error END


Exec sp_OAMethod @Object, 'send', null, @payload

Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
Select @ResponseText

Exec sp_OADestroy @Object

Error:
