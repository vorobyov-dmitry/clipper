#include "new.ch"
STATIC m_left:=0
STATIC s3:="³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ ³ "
Function DispTree()
  LOCAL m_workpath:="d:\buhgal\plat3\",m_margin:=0,s2
    NET USE (m_workpath+"kaptka1") INDEX (m_workpath+"kaptka1"),(m_workpath+"kaptka1a"),(m_workpath+"kaptka1b"),(m_workpath+"kaptka1c") ALIAS kp NEW
    set dele on
    DBSETORDER(3)
    DBGOTOP()
    SET PRINTER TO "DispTree.lst"
    set printer on
      Disp1(1,"")
    set printer oFF
    SET PRINTER TO
    s2:=JustRight("fggg ")
    close kp
RETURN .t.
Function Disp1(m_len,s_kod)
  LOCAL m_str1,m_recno,s1,l_first:=.t.,x1,x2
  DO WHILE .NOT.EOF().AND.LEN(ALLTRIM(kp->kod))==m_len.AND.LEFT(kp->kod,LEN(s_kod))==s_kod
    IF LEFt(kp->kod,1)<>"8"
      ?LEFT(s3,m_left*2)+IF(l_first,"Â ","Ã ")+kp->kod+kp->name
    ELSE
      x1:=kp->kod+kp->name
    ENDIF
    l_first:=.f.
    DBSETORDER(1)
    m_str1:=ALLTRIM(kp->kod)
    m_recno:=RECNO()
    DBSKIP()
    IF LEFT(kp->kod,LEN(m_str1))==m_str1
      DBSETORDER(3)
      IF LEFt(kp->kod,1)=="8"
        ?LEFT(s3,m_left*2)+IF(l_first,"Â ","Ã ")+x1
      ENDIF
      m_left++
      Disp1(LEN(ALLTRIM(kp->kod)),m_str1)
      m_left--
    ENDIF
      DBGOTO(m_recno)
      DBSETORDER(3)
      DBSKIP()
  ENDDO
RETURN .t.
