#include "new.ch"
FUNCTION checkfp1(var1)
SET DELE ON
SET PRINTER TO ("checkfp1.txt")
SET PRINTER ON
SET CONSOLE OFF
checkf()
SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON

RETURN .t.


FUNCTION checkf(var1)
LOCAL m_path:=IF(var1==NIL,"d:\buhgal\",alltrim(var1))
LOCAL m_vnum,m_recno,m_count
USE (m_path+"\mn\fp1.dbf")
?" Начало файла "+m_path
?" ((((  First_vnum,first_recno,last_vnum,last_recno, count"
?" (((( ",fp1->vnum,fp1->(recno())
m_vnum:=VAL(fp1->vnum)
m_count=1
DO WHILE .NOT.fp1->(EOF())
  IF m_vnum==VAL(fp1->vnum)
    m_vnum++
    m_count++
    m_recno:=fp1->(recno())
 ELSE
	??(m_vnum-1),m_recno,m_count," ))))"
	?" (((( ",fp1->vnum,fp1->(recno())
	m_vnum:=VAL(fp1->vnum)+1
	m_count:=1
 ENDIF
 fp1->(DBSKIP())
ENDDO
??(m_vnum-1),m_recno,m_count," ))))"
Close fp1


USE (m_path+"\mn\fp2.dbf")
?" Начало файла fp2"
?" (((( ",fp2->vnum,fp2->(recno())
m_vnum:=VAL(fp2->vnum)+1

m_count=1
Skipfp2()
//fp1->(DBSKIP())
DO WHILE .NOT.fp2->(EOF())
  IF m_vnum==VAL(fp2->vnum)
    m_vnum++
    m_count++
    m_recno:=Skipfp2()
  ELSE
	??(m_vnum-1),m_recno,m_count," ))))"
	?" (((( ",fp2->vnum,fp2->(recno())
	m_vnum:=VAL(fp2->vnum)+1
	m_count:=1
        m_recno:=Skipfp2()
//Skipfp2()
   ENDIF

//  fp1->(DBSKIP())
ENDDO
??(m_vnum-1),m_recno,m_count," ))))"
?"==============================="
Close fp2
RETURN .t.
FUNCTION Skipfp2()
Local m_v1:=VAL(fp2->vnum)
LOCAL m_x:= fp2->(recno())
DO WHILE .NOT.fp2->(EOF()).AND.m_v1==VAL(fp2->vnum)
	m_x:= fp2->(recno())
  fp2->(DBSKIP())
ENDDO

  Return m_x

