#INCLUDE "NEW.CH"
function zan3(var)
  LOCAl m_gauge,M_KOD1,n
  if var==NIL
    return .f.
  endif
  if .not.file(var+"nakl1.dbf")
    disperror("�i����i� 䠩� "+var+"nakl1.dbf")
    return .f.
  endif
  set dele on
  USE (VAR+"SPR01") index (VAR+"SPR01") new
  use (var+"nakl1.dbf") new
  n:=lastrec()
  m_gauge :=initgauge("��ॣ�� 䠩�� NAKL1")
  DO WHILE .NOT.EOF()
        m_kod1:=nakl1->kod1
        Spr01->(DS(nakl1->kopr))
        IF EMPTY(m_kod1).OR.m_kod1=="0"
          IF Spr01->potr=="2".or.Spr01->potr=="6".or.Spr01->potr=="7"
            m_kod1:="� "
          ENDIF
          IF Spr01->potr=="3"
            m_kod1:="� "
          ENDIF
        ELSE
          DO CASE
            CASE m_kod1=="1 "
              m_kod1:="� "
            CASE m_kod1=="2 "
              m_kod1:="� "
            CASE m_kod1=="3 "
              m_kod1:="� "
            CASE m_kod1=="4 "
              m_kod1:="� "
            CASE m_kod1=="5 "
              m_kod1:="� "
            CASE m_kod1=="6 "
              m_kod1:="� "
            endcase
        ENDIF
        nakl1->kod1:=m_kod1
    DBSKIP()
    M_gauge:=DISPGAUGE(M_GAUGE,RECNO()/N)
  ENDDO
RETURN .F.
