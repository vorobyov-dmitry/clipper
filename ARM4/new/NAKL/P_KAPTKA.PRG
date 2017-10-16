#INCLUDE "NEW.CH"
MEMVAR M_1
Function p_kaptka(var)
LOCAL m_gauge,m_sch,m_path:=IF(var==NIL,"d:\buhgal\",var)
LOCAL N_ERROR:=0,n_cart:=0,i:=1
  SET DELE ON
  SET DELE ON
  SET PRINTER TO "kaptka.lst"
  SET PRINTER ON
  set console off
  use ("cod") NEW
  ZAP
  index on cod->dbt to ("cod")
  USE (m_path+"\sp\sp43") index  (m_path+"\sp\sp43") new READONLY
  USE (m_path+"\plat\kaptka1") NEW
  INDEX ON kaptka1->kod TO (m_path+"\temp\k1")
  m_gauge:=InitGauge("Проверка файла kaptka1")
DO while .not.kaptka1->(EOF())

m_sch:=LEFT(kaptka1->ksash,6)
IF .not. Sp43->(DS(m_sch))
      ?kaptka1->kod, "Не знайдено коду облiку ["+m_sch+"]"
      n_cart++
  IF .not. cod->(DS(m_sch))
      cod->(DBAPPEND())
      cod->dbt:=m_sch
      n_error++
  ENDIF
ENDIF

m_sch:=LEFT(kaptka1->ksash2,6)
IF .not. Sp43->(DS(m_sch))
      ?kaptka1->kod, "Не знайдено коду облiку ["+m_sch+"]"
      n_cart++
  IF .not. cod->(DS(m_sch))
      cod->(DBAPPEND())
      cod->dbt:=m_sch
      n_error++
  ENDIF
ENDIF

  kaptka1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,i/kaptka1->(LASTREC()))
i=i+1
ENDDO
DelGauge(m_gauge)
WaitMessage("При перевiрцi знайдено "+STR(n_error,6)+" помилок в "+STR(n_cart,6)+" карточках")






IF n_error==0.OR.ANSWERu("Виконувати перекодiровку ?")=YES
i:=1
kaptka1->(DBGOTOP())
m_gauge:=InitGauge("Конвертирование довiдника матерiалiв")
do while .not.kaptka1->(eof())
m_sch:=LEFT(kaptka1->ksash,6)
IF .not. Sp43->(DS(m_sch))
  kaptka1->ksash:="20"
ELSE
  kaptka1->ksash:=sp43->new_sch1
ENDIF

m_sch:=LEFT(kaptka1->ksash2,6)
IF .not. Sp43->(DS(m_sch))
     kaptka1->ksash2:="7911"
ELSE
    kaptka1->ksash2:=sp43->new_sch2
ENDIF
  kaptka1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,i/kaptka1->(LASTREC()))
i=i+1
ENDDO
DelGauge(m_gauge)
ENDIF
CLOSE kaptka1
CLOSE cod
CLOSE sp43
  SET PRINTER TO
  SET PRINTER OFF
  set console off

RETURN .T.
