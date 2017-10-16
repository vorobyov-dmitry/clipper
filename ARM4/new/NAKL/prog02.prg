#include "new.ch"
function prog01
local m_str:="",m_npch,m_mol
LOCAl M_GAUGE:=InitGauge("перекодировка")
set dele on
use h:\buhgal\mn\fp1 ALIAS main NEW
index on main->npch+main->ndoc to d:\buhgal\temp\fp1 
SET FILTER TO main->oper="N1"
use d:\buhgal\bf\fp1 NEW
use d:\buhgal\bf\fp2 index d:\buhgal\bf\fp2 NEW
do while .not.fp1->(eof())
if fp1->oper=="N1" // в счет зарплаты
IF main->(DBSEEK(fp1->npch+fp1->ndoc))
do while fp2->(DS(fp1->vnum))
FP2->(dbdelete())
ENDDO
fp1->(DBDELETE())
ENDIF
endif
m_gauge:=DispGauge(m_gauge,Fp1->(RECNO()/LASTREC()))
fp1->(DBSKIP())
enddo
close all
return 0
