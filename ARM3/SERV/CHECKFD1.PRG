#include "new.ch"
FUNCTION checkfd1(var1)
SET DELE ON
SET PRINTER TO ("checkfd1.txt")
SET PRINTER ON
SET CONSOLE OFF
checkf()
checkf("d:\temp\08\01")
checkf("d:\temp\08\02")
checkf("d:\temp\08\03")
SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON

RETURN .t.


FUNCTION checkf(var1)
LOCAL m_path:=IF(var1==NIL,"d:\buhgal\",alltrim(var1))
LOCAL m_vnum,m_recno,m_count
USE (m_path+"\mn\fd1.dbf")
?" Начало файла "+m_path
?" (((( ",fd1->vnuma,fd1->(recno())
m_vnum:=fd1->vnuma+1

m_count=1
fd1->(DBSKIP())
DO WHILE .NOT.fd1->(EOF())
  IF m_vnum==fd1->vnuma
    m_vnum++
    m_count++
    m_recno:=fd1->(recno())
  ELSE
??(m_vnum-1),m_recno,m_count," ))))"
?" (((( ",fd1->vnuma,fd1->(recno())
m_vnum:=fd1->vnuma+1
m_count:=1
ENDIF
  fd1->(DBSKIP())
ENDDO
??(m_vnum-1),m_recno,m_count," ))))"
Close fd1


USE (m_path+"\mn\fd2.dbf")
?" Начало файла fd2"
?" (((( ",fd2->vnuma,fd2->(recno())
m_vnum:=fd2->vnuma+1

m_count=1
SkipFd2()
//fd1->(DBSKIP())
DO WHILE .NOT.fd2->(EOF())
  IF m_vnum==fd2->vnuma
    m_vnum++
    m_count++
    m_recno:=fd2->(recno())
  ELSE
??(m_vnum-1),m_recno,m_count," ))))"
?" (((( ",fd2->vnuma,fd2->(recno())
m_vnum:=fd2->vnuma+1
m_count:=1
ENDIF
SkipFd2()
//  fd1->(DBSKIP())
ENDDO
??(m_vnum-1),m_recno,m_count," ))))"
?"==============================="
Close fd2
RETURN .t.
FUNCTION SkipFd2()
Local m_v1:=fd2->vnuma
DO WHILE .NOT.fd2->(EOF()).AND.m_v1==fd2->vnuma
  fd2->(DBSKIP())
ENDDO

  Return .t.

