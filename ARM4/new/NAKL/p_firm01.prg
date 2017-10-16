#INCLUDE "NEW.CH"
MEMVAR M_1
Function p_kaptka(var)
LOCAL m_gauge,m_sch,m_path:=IF(var==NIL,"d:\buhgal\",var)
LOCAL N_ERROR:=0,n_cart:=0,i:=1
  SET DELE ON
  SET DELE ON
  SET PRINTER TO "firm.lst"
  SET PRINTER ON
  set console off
  use ("cod") NEW
  ZAP
  index on cod->dbt to ("cod")
  USE (m_path+"\sp\sp43") index  (m_path+"\sp\sp43") new READONLY
  USE (m_path+"\plat\firm01") NEW
  m_gauge:=InitGauge("Проверка файла firm01")
DO while .not.firm01->(EOF())

m_sch:=LEFT(firm01->ksash,6)
IF .not. Sp43->(DS(m_sch))
      ?firm01->okpo,firm01->short, "Не знайдено коду облiку ["+m_sch+"]"
      n_cart++
  IF .not. cod->(DS(m_sch))
      cod->(DBAPPEND())
      cod->dbt:=m_sch
      n_error++
  ENDIF
ENDIF

  firm01->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,i/firm01->(LASTREC()))
i=i+1
ENDDO
DelGauge(m_gauge)
WaitMessage("При перевiрцi знайдено "+STR(n_error,6)+" помилок в "+STR(n_cart,6)+" карточках")






IF n_error==0.OR.ANSWERu("Виконувати перекодiровку ?")=YES
i:=1
firm01->(DBGOTOP())
m_gauge:=InitGauge("Конвертирование довiдника пiдприємств")
do while .not.firm01->(eof())
m_sch:=LEFT(firm01->ksash,6)
IF .not. Sp43->(DS(m_sch))
  firm01->ksash:="361"
ELSE
  firm01->ksash:=sp43->new_sch1
ENDIF
  firm01->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,i/firm01->(LASTREC()))
i=i+1
ENDDO
DelGauge(m_gauge)
ENDIF
CLOSE firm01
CLOSE cod
CLOSE sp43
  SET PRINTER TO
  SET PRINTER OFF
  set console off

RETURN .T.
