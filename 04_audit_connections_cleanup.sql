BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'AUDIT_CONNECTIONS_CLEANUP');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'AUDIT_CONNECTIONS_CLEANUP'
      ,start_date      => TO_TIMESTAMP_TZ('2017/07/15 00:00:00.000000 -04:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=DAILY; BYHOUR=21; BYMINUTE=0;BYSECOND=0'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'AUDIT_CONNECTION.PRUNE_AUDIT_CONNECTIONS'
      ,comments        => NULL
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'AUDIT_CONNECTIONS_CLEANUP'
     ,attribute => 'STORE_OUTPUT'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'AUDIT_CONNECTIONS_CLEANUP');
END;
/
