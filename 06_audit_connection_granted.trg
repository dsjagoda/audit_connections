CREATE OR REPLACE TRIGGER AUDIT_CONNECTION_GRANTED AFTER LOGON ON DATABASE
DECLARE
    --dbg_call_start timestamp := systimestamp;
BEGIN
    if sys_context('USERENV','DATABASE_ROLE') = 'PRIMARY' then
        audit_connection.connection_granted;
        --insert into audit_connections_dbg values ('AUDIT_CONNECTION_GRANTED', dbg_call_start,systimestamp);
    end if;
END;
/
