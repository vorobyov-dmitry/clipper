Function corr86
use DBRTB Index DBRTB
append from  D86
reindex
use  DBROWSE  Index  DBROWSE
append from DB_86
reindex
use   MENU99  Index  MENU99
append from M99_86
reindex
use    MSH  Index  MSH
append from MSH_86
reindex
USE PARMSH  Index   PARMSH
append from  PAR_86
reindex
USE STRUCT   Index   STRUCT
append from  STR_86.DBF
reindex
USE screen   Index   screen
append from  Sc_86.DBF
reindex
Return .t.
