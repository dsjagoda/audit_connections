SET LINESIZE 160
select dbg1.trigger_fired
      ,(select count(*)
        from   audit_connections_dbg dbg2
        where EXTRACT (SECOND FROM fire_end - fire_start) * 1000 < 1
        and  dbg1.trigger_fired = dbg2.trigger_fired) "<1MS"
      ,(select count(*)
        from   audit_connections_dbg dbg2
        where EXTRACT (SECOND FROM fire_end - fire_start) * 1000 between 1 and 5
        and  dbg1.trigger_fired = dbg2.trigger_fired) "1MS-5MS"        
      ,(select count(*)
        from   audit_connections_dbg dbg2
        where EXTRACT (SECOND FROM fire_end - fire_start) * 1000 between 5 and 10
        and  dbg1.trigger_fired = dbg2.trigger_fired) "5MS-10MS"
      ,(select count(*)
        from   audit_connections_dbg dbg2
        where EXTRACT (SECOND FROM fire_end - fire_start) * 1000 between 10 and 15
        and  dbg1.trigger_fired = dbg2.trigger_fired) "10MS-15MS"
      ,(select count(*)
        from   audit_connections_dbg dbg2
        where EXTRACT (SECOND FROM fire_end - fire_start) * 1000 between 15 and 20
        and  dbg1.trigger_fired = dbg2.trigger_fired) "15MS-20MS"
      ,(select count(*)
        from   audit_connections_dbg dbg2
        where EXTRACT (SECOND FROM fire_end - fire_start) * 1000 > 20
        and  dbg1.trigger_fired = dbg2.trigger_fired) ">20MS"
      ,round(MIN (EXTRACT (SECOND FROM fire_end - fire_start)) * 1000,4) min_fire_ms
      ,round(AVG (EXTRACT (SECOND FROM fire_end - fire_start)) * 1000,4) average_fire_ms
      ,round(MAX (EXTRACT (SECOND FROM fire_end - fire_start)) * 1000,4) max_fire_ms
      ,count(*) total_times_fired                                
from   audit_connections_dbg dbg1
group by trigger_fired;
