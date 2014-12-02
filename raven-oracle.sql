CREATE OR REPLACE procedure SYS.CallSentry
as
req utl_http.req;
res utl_http.resp;
url varchar2(4000) := 'http://sentry.apexnet.it/api/12/store/';
name varchar2(4000);
buffer varchar2(4000); 
content varchar2(4000) := '
{
  "event_id": "fc6d8c0c43fc4630ad850ee518f1b9d0",
  "culprit": "my.module.function_name",
  "timestamp": "2011-05-02T17:41:36",
  "message": "SyntaxError: Wattttt!",
  "tags": {
    "ios_version": "4.0"
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

content:=replace(content, chr(13), '');
content:=replace(content, chr(10), '');
content:=ltrim(rtrim(content));
dbms_output.put_line(content);
-- http://cff7fad696c346e8966d0b0c82439df8:79df31b6aa9642a3bef837f21f4132f1@sentry.apexnet.it/12/store/

req := utl_http.begin_request(url, 'POST',' HTTP/1.1');
utl_http.set_header(req, 'User-agent', 'raven-oracle'); 
utl_http.set_header(req, 'Content-Type', 'application/json;charset=UTF-8'); 
utl_http.set_header(req, 'Accept', 'application/json'); 
utl_http.set_header(req, 'X-Sentry-Auth', 'Sentry sentry_version=5,sentry_timestamp=1328055286.51,sentry_key=cff7fad696c346e8966d0b0c82439df8,sentry_secret=79df31b6aa9642a3bef837f21f4132f1'); 

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
