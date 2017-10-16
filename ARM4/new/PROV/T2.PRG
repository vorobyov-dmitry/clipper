Function DispWall(var)
LOCAL i:=0,j:=0,m_char:=" ",k
LOCAL m_clr:=IF(var==NIL,"w/b",var)
DispBegin()
FOR k:=1 TO 7
DO CASE
  CASE k==1
    m_clr:="w/b"
  CASE k==2
    m_clr:="b/bg"
  CASE k==3
    m_clr:="w/gr"
  CASE k==4
    m_clr:="n/w"
  CASE k==5
    m_clr:="w/rb"
  CASE k==6
    m_clr:="w/g"
  CASE k==7
    m_clr:="w/rb*"
ENDCASE
FOR i:=1 TO MAXROW()
  FOR j:=0 TO MAXCOL()
    DO CASE
      CASE i==1
        IF j%6==2
          m_char:="Â"
        ELSE
          m_char:="Ä"
        ENDIF
      CASE i==MAXROW()
        IF j%6==2
          m_char:="Á"
        ELSE
          m_char:="Ä"
        ENDIF
      CASE i%2==0
        DO CASE
          CASE j%6==2
            m_char:="Á"
          CASE j%6==5
            m_char:="Â"
          OTHERWISE
            m_char:="Ä"
        ENDCASE
      OTHERWISE
        DO CASE
          CASE j%6==2
            m_char:="Â"
          CASE j%6==5
            m_char:="Á"
          OTHERWISE
            m_char:="Ä"
        ENDCASE

    ENDCASE
    @i,j Say m_char COLOR (m_clr)
  NEXT
NEXT
DispEnd()
INKEY(0)
next
RETURN .t.
