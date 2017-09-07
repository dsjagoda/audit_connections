CREATE OR REPLACE TRIGGER AUDIT_CONNECTION_DENIED AFTER SERVERERROR ON DATABASE
DECLARE
    --dbg_call_start timestamp := systimestamp;
BEGIN
    if sys_context('USERENV','DATABASE_ROLE') = 'PRIMARY' then
        audit_connection.connection_denied;
        --insert into audit_connections_dbg values ('AUDIT_CONNECTION_DENIED', dbg_call_start,systimestamp);
    end if;
END;
/
