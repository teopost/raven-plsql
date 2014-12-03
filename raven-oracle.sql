CREATE OR REPLACE procedure SYS.RavenClient(uri varchar2, public_key varchar2, public_secret varchar2, message varchar2, errlevel varchar2 := 'warning')
as
req utl_http.req;
res utl_http.resp;
url varchar2(4000) := uri || '/store/';  -- 'http://sentry.apexnet.it/api/12/store/';
name varchar2(500);
utctime varchar2(4000);
buffer varchar2(4000); 
sentry_auth varchar2(2000) := 'Sentry sentry_version=5,sentry_timestamp=$sentry_time,sentry_key=$sentry_public,sentry_secret=$sentry_secret';

content varchar2(4000) := '
{
  "event_id": "$gui",
  "culprit": "ravenclient",
  "timestamp": "2011-05-02T17:41:36",
  "message": "$message",
  "platform": "plsql",
  "server_name": "$servername",
  "level": "$level",
  "tags": {
    "oracle_version": "$dbversion",
    "sid": "$oraclesid"
  },
  "exception": [
    {
      "type": "SyntaxError",
      "value": "Wattttt!",
      "module": "__builtins__"
    }
  ]
}';


begin
content:=replace(content, '$gui', lower(SYS_GUID()));
content:=replace(content, '$message', message);

-- Valid values for level: fatal, error, warning, info, debug
content:=replace(content, '$level', errlevel);
content:=replace(content, '$servername', sys_context('USERENV','SERVER_HOST'));
content:=replace(content, '$oraclesid', sys_context('USERENV','SID'));
content:=replace(content, '$dbversion', sys_context('USERENV','SERVER_HOST'));
sentry_auth:=replace(sentry_auth, '$sentry_time', replace(to_char( SYS_EXTRACT_UTC(SYSTIMESTAMP),'YYYY-MM-DD HH24:MI:SS'),' ','T'));
sentry_auth:=replace(sentry_auth, '$sentry_public', public_key);
sentry_auth:=replace(sentry_auth, '$sentry_secret', public_secret);
dbms_output.put_line(sentry_auth);
content:=replace(content, chr(13), '');
content:=replace(content, chr(10), '');
content:=ltrim(rtrim(content));
dbms_output.put_line(content);
-- http://cff7fad696c346e8966d0b0c82439df8:79df31b6aa9642a3bef837f21f4132f1@sentry.apexnet.it/12/store/


req := utl_http.begin_request(url, 'POST',' HTTP/1.1');
utl_http.set_header(req, 'User-agent', 'raven-oracle'); 
utl_http.set_header(req, 'Content-Type', 'application/json;charset=UTF-8'); 
utl_http.set_header(req, 'Accept', 'application/json'); 
--utl_http.set_header(req, 'X-Sentry-Auth', 'Sentry sentry_version=5,sentry_timestamp=1328055286.51,sentry_key=cff7fad696c346e8966d0b0c82439df8,sentry_secret=79df31b6aa9642a3bef837f21f4132f1');
utl_http.set_header(req, 'X-Sentry-Auth', sentry_auth); 

--utl_http.set_header(req, 'Content-Length', length(content));
UTL_HTTP.SET_HEADER (r      =>   req,
                     name   =>   'Content-Length',
                     value  =>    LENGTHB(content));
                     
UTL_HTTP.WRITE_RAW (r    => req,  data => UTL_RAW.CAST_TO_RAW(content));

--utl_http.write_text(req, content);

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
