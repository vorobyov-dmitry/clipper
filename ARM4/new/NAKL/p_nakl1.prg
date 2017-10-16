#INCLUDE "NEW.CH"
MEMVAR M_1
Function p_kaptka(var)
LOCAL m_gauge,m_sch,m_path:=IF(var==NIL,"d:\buhgal\",var)
LOCAL N_ERROR:=0,n_cart:=0,i:=1,j:=0
  SET DELE ON
  SET DELE ON
  SET PRINTER TO "nakl.lst"
  SET PRINTER ON
  set console off
  use ("cod") NEW
  ZAP
  index on cod->dbt to ("cod")
  USE (m_path+"\sp\sp43") index  (m_path+"\sp\sp43") new READONLY
  USE (m_path+"\plat\nakl1") NEW
  m_gauge:=InitGauge("Проверка файла nakl1")
DO while .not.nakl1->(EOF())
IF nakl1->Kod1=="В "
@0,0 SAYDISP j picture "999'999" COLOR "GR+/B"
j++ 
m_sch:=LEFT(nakl1->ksash,6)
IF .not. Sp43->(DS(m_sch))
      ?nakl1->ndoc,nakl1->ddoc, "Не знайдено коду облiку ["+m_sch+"]"
      n_cart++
  IF .not. cod->(DS(m_sch))
      cod->(DBAPPEND())
      cod->dbt:=m_sch
      n_error++
  ENDIF
ENDIF
ENDIF

  nakl1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,i/nakl1->(LASTREC()))
i=i+1
ENDDO
DelGauge(m_gauge)
WaitMessage("При перевiрцi знайдено "+STR(n_error,6)+" помилок в "+STR(n_cart,6)+" карточках")






IF n_error==0.OR.ANSWERu("Виконувати перекодiровку ?")=YES
j:=1
i:=1
nakl1->(DBGOTOP())
m_gauge:=InitGauge("Конвертирование довiдника пiдприємств")
do while .not.nakl1->(eof())
IF nakl1->Kod1=="В "
@0,0 SAYDISP j picture "999'999" COLOR "GR+/B"
j++ 
m_sch:=LEFT(nakl1->ksash,6)
IF .not. Sp43->(DS(m_sch))
  nakl1->ksash:=m_sch+"?"
ELSE
  nakl1->ksash:=sp43->new_sch1
ENDIF
ENDIF
  nakl1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,i/nakl1->(LASTREC()))
i=i+1
ENDDO
DelGauge(m_gauge)
ENDIF
CLOSE nakl1
CLOSE cod
CLOSE sp43
  SET PRINTER TO
  SET PRINTER OFF
  set console off

RETURN .T.
