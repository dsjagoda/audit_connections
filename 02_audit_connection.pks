CREATE OR REPLACE PACKAGE AUDIT_CONNECTION IS
    PROCEDURE CONNECTION_GRANTED;
    PROCEDURE CONNECTION_DENIED;
    FUNCTION  GET_PART_HIGH_VALUE_AS_DATE (p_owner          in varchar2
                                          ,p_table_name     in varchar2
                                          ,p_partition_name in varchar2) 
                                          return date;
    PROCEDURE DROP_PARTITIONS_BASED_ON_DATES (p_owner       in varchar2
                                             ,p_table_name  in varchar2
                                             ,p_lower_bound in date
                                             ,p_upper_bound in date);
    PROCEDURE PRUNE_AUDIT_CONNECTIONS;
END AUDIT_CONNECTION;
/
