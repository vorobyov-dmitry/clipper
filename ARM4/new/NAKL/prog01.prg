#include "new.ch"
function prog01
local m_str:="",m_npch,m_mol
LOCAl M_GAUGE:=InitGauge("перекодировка")
set dele on
use h:\buhgal\mn\fp1 NEW
use h:\buhgal\mn\fp2 index h:\buhgal\mn\fp2 NEW
do while .not.fp1->(eof())
/*
if fp1->oper=="N1" // в счет зарплаты
endif
*/
if fp1->oper=="N2"
fp2->(DS(fp1->vnum))
m_npch := "7"+right(fp1->mnt,2)
m_mol:="  "
do while .not.fp2->(EOF()).AND.fp2->vnum==fp1->vnum
IF .not.EMPTY(fp2->kplh).AND..not.EMPTY(fp2->OTP)
	m_mol:=fp2->OTP
	exit
endif
IF .not.EMPTY(fp2->OTP)
	m_mol:=fp2->otp
	exit
endif
IF .not.EMPTY(fp2->kplh)
	m_mol:=fp2->kplh
	exit
endif
fp2->(DBSKIP())
m_gauge:=DispGauge(m_gauge,Fp1->(RECNO()/LASTREC()))
enddo
DelGAuge(m_gauge)
fp1->npch:=m_npch+m_mol
endif
fp1->(DBSKIP())
enddo
return 0
