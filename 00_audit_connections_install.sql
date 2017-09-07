SET TIMING ON
SET ECHO ON
SPOOL 00_audit_connections_install.log
@01_audit_connections.sql
@02_audit_connection.pks
@03_audit_connection.pkb
@04_audit_connections_cleanup.sql
@05_audit_connection_denied.trg
@06_audit_connection_granted.trg
SPOOL OFF
