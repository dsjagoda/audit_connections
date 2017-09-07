CREATE OR REPLACE PACKAGE BODY AUDIT_CONNECTION AS

    ---------------------------------------------------------------------------
    -- INSERT_CONNECTION_INFO - Inserts all current session information as well
    --     as disposition info into AUDIT_CONNECTIONS.
    ---------------------------------------------------------------------------
    PROCEDURE INSERT_CONNECTION_INFO (p_connection_status in varchar2
                                     ,p_error_code        in varchar2 default null) AS

        v_session_data sys.gv_$session%rowtype;
    
    BEGIN
        -- Insert session data
        insert into audit_connections
        (
         unique_session_id
        ,sid
        ,serial_no
        ,inst_no
        ,username
        ,osuser
        ,machine
        ,ip_address
        ,service_name
        ,program
        ,module
        ,authentication_type
        ,logon_time
        ,connection_status
        )
        values
        (
         dbms_session.unique_session_id
        ,sys_context('USERENV','SID')
        ,to_number(substr(dbms_session.unique_session_id,5,4),'XXXXXXXXX' )
        ,sys_context('USERENV','INSTANCE')
        ,sys_context('USERENV','AUTHENTICATED_IDENTITY')
        ,sys_context('USERENV','OS_USER')
        ,sys_context('USERENV','HOST')
        ,nvl(sys_context ('USERENV', 'IP_ADDRESS'),'UNKNOWN')
        ,sys_context('USERENV','SERVICE_NAME')
        ,null
        ,sys_context('USERENV' ,'MODULE')
        ,sys_context ('USERENV', 'AUTHENTICATION_TYPE')
        ,systimestamp
        ,p_connection_status || decode(nvl(length(p_error_code),0),0,null,' ('||p_error_code||')')
        );        

    END INSERT_CONNECTION_INFO;
    
    ---------------------------------------------------------------------------
    -- CONNECTION_GRANTED - Called via AFTER LOGON system trigger
    --     AUDIT_CONNECTION_GRANTED.  This procedure tracks 
    --     when a user has a normal logon event. 
    ---------------------------------------------------------------------------
    PROCEDURE CONNECTION_GRANTED AS
    
    BEGIN
        insert_connection_info('CONNECTED');
    END CONNECTION_GRANTED;
    
    ---------------------------------------------------------------------------
    -- CONNECTION_DENIED - Called via AFTER SERVERERROR system trigger
    --     AUDIT_CONNECTION_DENIED.  This procedure will log
    --     a failed logon attempt and specify the error code for the failure.
    ---------------------------------------------------------------------------
    PROCEDURE CONNECTION_DENIED AS

    BEGIN
        if  ora_server_error(1) in (1004 -- ORA-01004 - default username feature not supported
                                   ,1005 -- ORA-01005 - null password given
                                   ,1017 -- ORA-01017 - invalid username/password; logon denied
                                   ,1035 -- ORA-01035 - Oracle only available to users with restricted session priv
                                   ,1045 -- ORA-01045 - create session privilege not granted
                                   ) then

            insert_connection_info('DENIED',ora_server_error(1));
            
            commit;
        end if;
    END CONNECTION_DENIED;

    ---------------------------------------------------------------------------
    -- GET_PART_HIGH_VALUE_AS_DATE - DBA_TAB_PARTITIONS stores date information
    --     in a LONG column.  This function converts the LONG to a DATE.
    ---------------------------------------------------------------------------
    FUNCTION  GET_PART_HIGH_VALUE_AS_DATE (p_owner          in varchar2
                                          ,p_table_name     in varchar2
                                          ,p_partition_name in varchar2) 
                                          return date as
    
        v_long long;
        
    BEGIN
        -- Get the high_value LONG
        select high_value 
        into   v_long
        from   dba_tab_partitions
        where  table_name = p_table_name
        and    partition_name = p_partition_name
        and    table_owner = p_owner;

        -- Parse the long and return a date
        return to_date(substr(v_long, 11, 19), 'YYYY-MM-DD HH24:MI:SS');
    END GET_PART_HIGH_VALUE_AS_DATE;
    
    ---------------------------------------------------------------------------
    -- DROP_PARTITIONS_BASED_ON_DATES - Attempts to drop all partitions for the
    --     given owner/table and date range specified.  This will not allow for
    --     the last partition to be dropped from the table.
    ---------------------------------------------------------------------------
    PROCEDURE DROP_PARTITIONS_BASED_ON_DATES (p_owner       in varchar2
                                             ,p_table_name  in varchar2
                                             ,p_lower_bound in date
                                             ,p_upper_bound in date) as
    
    -- Handle some exceptions gracefully
    last_partition_err exception;
    pragma exception_init(last_partition_err, -14758);
    invalid_partition_name exception;
    pragma exception_init(invalid_partition_name, -14006);
   
    v_partition_date date;

    cursor tab_partitions_cur is
        select table_owner
              ,table_name
              ,partition_name
              ,high_value
        from  dba_tab_partitions
        where table_owner = p_owner
        and   table_name = p_table_name;

    BEGIN
        -- Loop through all the partitions defined for the owner/table combination given.
        for tab_partitions_rec in tab_partitions_cur loop
            -- Partition range strings are stored as longs.  This function return a date instead.
            v_partition_date := AUDIT_CONNECTION.GET_PART_HIGH_VALUE_AS_DATE(tab_partitions_rec.table_owner
                                                                                 ,tab_partitions_rec.table_name
                                                                                 ,tab_partitions_rec.partition_name);
                                                                                 
            if v_partition_date between p_lower_bound and p_upper_bound then
                begin
                    -- Drop the partition
                    execute immediate 'alter table ' 
                                   || tab_partitions_rec.table_owner || '.' || tab_partitions_rec.table_name 
                                   || ' drop partition ' 
                                   || tab_partitions_rec.partition_name 
                                   || ' update global indexes';

                exception
                    when last_partition_err then -- Can't drop the last partition of a partitioned table.  Truncate.
                        execute immediate 'alter table ' 
                                       || tab_partitions_rec.table_owner || '.' || tab_partitions_rec.table_name
                                       || ' truncate partition '
                                       || tab_partitions_rec.partition_name
                                       || ' drop storage';
                    when invalid_partition_name then
                       null;
                end;
            end if;
        end loop;   
    END DROP_PARTITIONS_BASED_ON_DATES;
    
    ---------------------------------------------------------------------------
    -- PRUNE_AUDIT_CONNECTIONS - Called via job to keep one week's worth
    --     of partition data in AUDIT_CONNECTIONS.  This should never
    --     attempt to drop the base 'OUT_OF_BOUNDS' partition that is created
    --     when the table is first created.
    ---------------------------------------------------------------------------
    PROCEDURE PRUNE_AUDIT_CONNECTIONS AS
    
        v_drop_parts_from_date date := to_date('2001-01-01','YYYY-MM-DD'); -- "Since the beginning of time..."
        v_drop_parts_until_date date := trunc(sysdate) - 6;  -- One week ago 
    BEGIN
        DROP_PARTITIONS_BASED_ON_DATES('OPS$ORACLE'
                                      ,'AUDIT_CONNECTIONS'
                                      ,v_drop_parts_from_date
                                      ,v_drop_parts_until_date);                                      
    END PRUNE_AUDIT_CONNECTIONS;
END AUDIT_CONNECTION;
/

