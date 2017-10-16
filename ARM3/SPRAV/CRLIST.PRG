Function CrList(m_browse,m_var,l_print)
   LOCAL m_col,m_select:=SELECT(),m_str,i:=0
  sptabl->(dbseek(m_var))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==m_var
     m_Col           := TBColumnNew()
     DO CASE
     CASE sptabl->type=='02'
        m_col:block:=&("{||"+trn(ALLTRIM(sptabl->value))+"}")
     CASE sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")
     OTHERWISE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
     ENDCASE
     m_col:heading:=ALLTRIM(sptabl->heading)
     AADD(l_print,{||.T.})
     l_print[LEN(l_print)]:=sptabl->print
     m_Col:colorblock:=  {|| {1,2}}
        IF sptabl->type=='01'
          m_Col:headsep    := "ÂÄ"
          m_col:colsep:="³"
          m_col:footsep:="ÏÍ"
        ELSE
          m_Col:headsep    := "Ä"
          m_col:colsep:=" "
          m_col:footsep:="ÍÍ"
        ENDIF
     IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
     ENDIF
     m_browse:addColumn( m_col )
     sptabl->(dbskip(1))
  ENDDO
SELECT(m_select)
RETURN (.T.)

