# Debugging Audit Connections

**Do not run anything in this directory without reading, understanding, and following the instructions in this file first**

## Description 
The files located in this directory are to assist with generating timing statistics for the Audit Connection triggers that fire.

File | Description
---- | ----------- 
01_audit_connections_dbg.sql | Contains DDL to generate a table to hold timing information 
02_generate_connections.sh | Calls 02_generate_connections.sql 10000 times to generate timing data 
02_generate_connections.sql | Will need to be edited to provide connection information
03_analysis.sql | A SQL statement designed to pivot and aggregate the timing information and display it in a better format; Probably best run in a GUI

## Steps
1. Modify the two triggers, AUDIT_CONNECTION_DENIED & AUDIT_CONNECTION_GRANTED, in the desired DB and remove the comments from the debug lines.
2. Modify 02_generate_connections.sql to contain the desired connection information.
3. Run 02_generate_connections.sh.
4. Use 03_analysis.sql to view results.  Raw data is stored in AUDIT_CONNECTIONS_DBG.
