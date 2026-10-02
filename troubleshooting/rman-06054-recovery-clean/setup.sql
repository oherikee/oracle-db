-- RMAN Recovery Lab
-- CDB: ORCL
-- PDB: ORCLPDB1
-- Datafile: 14
-- Tablespace: RECOVERY_LAB

SELECT tablespace_name, status, contents
FROM dba_tablespaces
WHERE tablespace_name = 'RECOVERY_LAB';

SELECT file#, name, status, enabled, checkpoint_change#
FROM v$datafile
WHERE file# = 14;

CONNECT recovery_lab/"RecoveryLab123"@//localhost:1521/orclpdb1

SELECT COUNT(*) AS total_rows, MIN(id) AS min_id, MAX(id) AS max_id
FROM recovery_data;
