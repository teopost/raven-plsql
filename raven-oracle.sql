CREATE OR REPLACE procedure SYS.RavenClient(uri varchar2, public_key varchar2, public_secret varchar2, message varchar2, errlevel varchar2 := 'warning')
as
-- Valid values for level are: fatal, error, warning, info, debug

req utl_http.req;
res utl_http.resp;
url varchar2(4000) := uri || '/store/';  -- 'http://sentry.apexnet.it/api/12/store/';
name varchar2(500);
buffer varchar2(4000); 
dbversion varchar2(2000);

sentry_auth varchar2(2000);

payload varchar2(4000) := '
{
  "event_id": "$gui",
  "culprit": "$culprit",
  "timestamp": "2011-05-02T17:41:36",
  "message": "$message",
  "platform": "plsql",
  "server_name": "$servername",
  "level": "$level",
  "tags": {
    "oracle_version": "$dbversion",
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



begin
-- Extract Oracle Version
select banner into dbversion from v$version where banner like 'Oracle%';

payload:=replace(payload, '$gui', lower(SYS_GUID()));
payload:=replace(payload, '$culprit', 'RavenClient');
-- add timestamp
payload:=replace(payload, '$message', message);
payload:=replace(payload, '$servername', sys_context('USERENV','SERVER_HOST'));
payload:=replace(payload, '$level', errlevel);

payload:=replace(payload, '$dbversion', dbversion);
payload:=replace(payload, '$oraclesid', sys_context('USERENV','SID'));
payload:=replace(payload, '$current_schema', sys_context('USERENV','CURRENT_SCHEMA'));

payload:=replace(payload, chr(13), '');
payload:=replace(payload, chr(10), '');
payload:=ltrim(rtrim(payload));

-- Compose header
sentry_auth := 'Sentry sentry_version=5,sentry_timestamp=$sentry_time,sentry_key=$sentry_public,sentry_secret=$sentry_secret';
sentry_auth:=replace(sentry_auth, '$sentry_time', replace(to_char( SYS_EXTRACT_UTC(SYSTIMESTAMP),'YYYY-MM-DD HH24:MI:SS'),' ','T'));
sentry_auth:=replace(sentry_auth, '$sentry_public', public_key);
sentry_auth:=replace(sentry_auth, '$sentry_secret', public_secret);


-- Compose request
req := utl_http.begin_request(url, 'POST',' HTTP/1.1');
utl_http.set_header(req, 'User-agent', 'raven-oracle/1.0'); 
utl_http.set_header(req, 'payload-Type', 'application/json;charset=UTF-8'); 
utl_http.set_header(req, 'Accept', 'application/json'); 
--utl_http.set_header(req, 'X-Sentry-Auth', 'Sentry sentry_version=5,sentry_timestamp=1328055286.51,sentry_key=cff7fad696c346e8966d0b0c82439df8,sentry_secret=79df31b6aa9642a3bef837f21f4132f1');
utl_http.set_header(req, 'X-Sentry-Auth', sentry_auth); 
utl_http.set_header (req, 'Content-Length', lengthb(payload));
utl_http.write_raw(req, utl_raw.cast_to_raw(payload));

-- debug messages
-- dbms_output.put_line(sentry_auth);
-- dbms_output.put_line(payload);

res := utl_http.get_response(req);

begin
    loop
      utl_http.read_line(res, buffer);
      dbms_output.put_line(buffer);
    end loop;
    
    utl_http.end_response(res);

exception
    when utl_http.end_of_body then
    utl_http.end_response(res);
    end;
end;
/
