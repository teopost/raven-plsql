raven-plsql
============

PL/SQL client for Sentry

Installation
===
1. Get the code: git clone git://github.com/teopost/raven-plsql
2. Connect su oracle database
3. Cut & Paste Procedure code and execute
4. Enable Oracle ACL for remote connection (see official documentation)

Example
===
```sql
exec RavenClient('app.getsentry.com/api/29639', 'cff7fad696c346e8966d0b0c82439df8', '79df31b6aa9642a3bef837f21f4132f1', 'This is a test', 'fatal')

```

Note: Use http://sentry.apexnet.it/api/12 for ApexNet internal Sentry server

Reference
===
http://www.oracleflash.com/36/Oracle-11g-Access-Control-List-for-External-Network-Services.html
http://sentry.readthedocs.org/en/latest/developer/client/index.html
