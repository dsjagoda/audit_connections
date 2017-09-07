# Audit Connections

## Description

The files located in this directory are for connection auditing in a DB. A on-demand daily-partitioned table holds 1 week of data.  There are 2 triggers which call various procedures in a package.  There is also a DBMS Scheduler job that drops old partitions.

File | Description
---- | -----------
00_audit_connections_install.sql | Installation script
01_audit_connections.sql |  Table creation script for AUDIT_CONNECTIONS
02_audit_connection.pks | Package specification for AUDIT_CONNECTION
03_audit_connection.pkb | Package body for AUDIT_CONNECTION
04_audit_connections_cleanup.sql | Scheduler job definition to drop partitions
05_audit_connection_denied.trg | Trigger that fires on any DB error but only logs connection-related errors to AUDIT_CONNECTIONS
06_audit_connection_granted.trg | Trigger that fires on successful logon and stores a record in AUDIT_CONNECTIONS

## Installation
1. Installation user must exist in the DB. All associated objects are owned by this user.
2. Run 00_audit_connections_install.sql
3. 00_audit_connections_install.log is spooled for logging purposes.
