raven-plsql
============

PL/SQL client for Sentry

Installation
---
1. Get the code: git clone git://github.com/teopost/raven-plsql
2. Connect to Oracle Database
3. Enable Oracle ACL for remote connection
4. Cut & Paste stored procedure into oracle schema

Oracle ACL
---
Connect to Oracle sys user, replace ORACLE_SCHEMA with your Oracle schema name and execute script.

```sql
/* Create ACL for user ORACLE_SCHEMA */
BEGIN 
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
     acl => 'raven-plsql.xml', 
     description => 'Acl for sentry service', 
     principal => 'ORACLE_SCHEMA',
     is_grant => true, 
     privilege => 'connect'); 
  commit; 
END;
/

/* Add privilege of ACL to user ORACLE_SCHEMA */
BEGIN 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE
    (acl => 'raven-plsql.xml', principal => 'ORACLE_SCHEMA',is_grant => true, privilege => 'resolve'); 
  commit; 
END;
/

BEGIN 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL 
    (acl => 'raven-plsql.xml', host => 'sentry.apexnet.it'); 
  commit; 
END;
/
```

Example
===
```sql
exec RavenClient('app.getsentry.com/api/29639', 'cff7fad696c346e8966d0b0c82439df8', '79df31b6aa9642a3bef837f21f4132f1', 'This is a test', 'fatal')

```

Note: Use http://sentry.apexnet.it/api/12 for ApexNet internal Sentry server

Reference
---
http://www.oracleflash.com/36/Oracle-11g-Access-Control-List-for-External-Network-Services.html
http://sentry.readthedocs.org/en/latest/developer/client/index.html
