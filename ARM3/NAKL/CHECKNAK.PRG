#include "new.ch"
Function Check01(var)
LOCAL m_message,n_win1,m_vnum1
LOCAL m_vnum:=0,m_ndoc:=0,i:=0,m1:=0,m2:=0,j
LOCAL m_workpath:=IF(var==NIL,"D:\buh\plat\",var)
LOCAL m_tempath:="D:\BUHGAL\TEMP\"
LOCAL m_gauge,m_str:="",l_index:=.f.,m_ndoc1
USE (m_workpath+"FVNUM") NEW
SET DELE ON
SETBLINK(.f.)
fvnum->(DBGOTO(1))
i:=1
IF fvnum->reg<>0
    l_index:=.t.
    FOR j:=1 TO 8
      IF Isbit(fvnum->reg,j);m_str+=" N"+STR(j,2);ENDIF
    NEXT
    DispError("Було аварiйне завершення програми;роботи з накладними;рабоче мiсце "+m_str)
    m_gauge:=InitGauge("Iндексацiя накладних",2)
    USE (m_workpath+"nakl1") NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"nakl1")
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"nakl1a")
    m_gauge:=DispGauge(m_gauge,i++/8)
    USE (m_workpath+"nakl2") NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->vnum TO (m_workpath+"nakl2")
    m_gauge:=DispGauge(m_gauge,5/7)
    CLOSE nakl2
    m_gauge:=DispGauge(m_gauge,i++/8)
    USE (m_workpath+"nakl3")  NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->vnum TO (m_workpath+"nakl3")
    m_gauge:=DispGauge(m_gauge,i++/8)
    CLOSE nakl3
    fvnum->reg:=0
    DelGauge(m_gauge)
ENDIF
m_vnum:=0;m_ndoc:=0
fvnum->(DBGOTO(2))
i:=2
IF fvnum->reg<>0
    l_index:=.t.
    m_str:=""
    FOR j:=1 TO 8
      IF Isbit(fvnum->reg,j);m_str+=" N"+STR(j,2);ENDIF
    NEXT
    DispError("Було аварiйне завершення програми;роботи з податковими накладними;рабоче мiсце "+m_str)
    m_gauge:=InitGauge("Iндексацiя податкових накладних",2)
    USE (m_workpath+"nalog1") NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"nalog1")
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"nalog1a")
    m_gauge:=DispGauge(m_gauge,i++/8)
    CLOSE nalog1
    USE (m_workpath+"nalog2") NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->vnum TO (m_workpath+"nalog2")
    m_gauge:=DispGauge(m_gauge,i++/8)
    CLOSE nalog2
    m_gauge:=DispGauge(m_gauge,i++/8)
    fvnum->reg:=0
    DelGauge(m_gauge)
ENDIF

m_vnum:=0;m_ndoc:=0
fvnum->(DBGOTO(7))
i:=2
IF fvnum->reg<>0
    l_index:=.t.
    m_str:=""
    FOR j:=1 TO 8
      IF Isbit(fvnum->reg,j);m_str+=" N"+STR(j,2);ENDIF
    NEXT
    DispError("Було аварiйне завершення програми;роботи з розрахунками;рабоче мiсце "+m_str)
    m_gauge:=InitGauge("Iндексацiя розрахункiв",2)
    USE (m_workpath+"Nalog3") NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    m_message:=DispMessage("Вiдновлюю службову iнформацiю")
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"Nalog3")
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"Nalog3a")
    m_gauge:=DispGauge(m_gauge,i++/8)
    CLOSE Nalog3
    USE (m_workpath+"Nalog4") NEW
    m_gauge:=DispGauge(m_gauge,i++/8)
    INDEX ON field->vnum TO (m_workpath+"Nalog4")
    m_gauge:=DispGauge(m_gauge,i++/8)
    CLOSE Nalog4
    m_gauge:=DispGauge(m_gauge,i++/8)
    fvnum->reg:=0
    DelGauge(m_gauge)
ENDIF
IF l_index.OR.DOW(DATE())==1
    m_gauge:=InitGauge("Вiдновлення довiдкових баз даних")
    i:=1
    m_gauge:=DispGauge(m_gauge,i++/7)
    m_gauge:=DispGauge(m_gauge,i++/7)
    USE (m_workpath+"kaptka1") NEW
    INDEX ON field->kod TO (m_workpath+"kaptka1")
    m_gauge:=DispGauge(m_gauge,i++/7)
    INDEX ON UPPER(field->name) TO (m_workpath+"kaptka1a")
    m_gauge:=DispGauge(m_gauge,i++/7)
    INDEX ON JustRight(field->kod) TO (m_workpath+"kaptka1b")
    CLOSE kaptka1

    USE (m_workpath+"spr01") NEW
    INDEX ON field->kopr TO (m_workpath+"spr01")
    m_gauge:=DispGauge(m_gauge,i++/7)
    CLOSE spr01

    USE (m_workpath+"firm01") NEW
    INDEX ON UPPER(field->short) TO (m_workpath+"firm01")
    m_gauge:=DispGauge(m_gauge,i++/7)
    INDEX ON field->kodnds TO (m_workpath+"firm01b")
    INDEX ON field->okpo TO (m_workpath+"firm01a")
    m_gauge:=DispGauge(m_gauge,i++/7)
    CLOSE firm01
ENDIF
DBCOMMITALL()
m_message:=DispMessage("Перевiрка структури; файлiв накладних")
SETPRC(0,0)
SET PRINTER TO (m_workpath+"06.txt")
SET PRINTER ON
n_win1:=WOPEN(0,0,6,80,.t.)
Wselect(n_win1)
SETCOLOR("w/r")
WBOX(12)
SETCOLOR("GR+/r")
// @-1,0 SayDisp PADC("",80) COLOR "n/w"
SETPOS(0,0)
Wselect(0)
fvnum->(DBGOTO(1))
    USE (m_workpath+"nakl1") NEW
    INDEX ON field->vnum TO (m_tempath+"nakl1")
    USE (m_workpath+"nakl2") INDEX (m_workpath+"nakl2")  NEW
    m_vnum:=0;m_ndoc:=BLANK(Nakl1->ndoc,.t.)
    m_gauge:=InitGauge("Перегляд файлу NAKL1",2)
    m_ndoc1:=0;m_vnum1:=0
    DO WHILE .NOT.nakl1->(EOF())
      IF STR(VAL(nakl1->vnum),6)<>nakl1->vnum
        Disp1("Помилка перетворення внутрiшнього номеру накладної N"+nakl1->ndoc,n_win1)
      ENDIF
      IF .NOT.nakl2->(DS(nakl1->vnum))
        Disp1("Вiдсутнi строки накладної N"+nakl1->ndoc,n_win1)
      ENDIF
      IF m_vnum==VAL(nakl1->vnum)
        Disp1("Строки накладної N"+nakl1->ndoc+" i накладної N"+m_ndoc+" переплутанi !!!!",n_win1)
      ENDIF
      m_vnum:=VAL(Nakl1->vnum);m_ndoc:=Nakl1->ndoc
      m_gauge:=DispGauge(m_gauge,Nakl1->(RECNO())/Nakl1->(LASTREC()))
      IF Year(nakl1->ddoc)==fvnum->year.and.nakl1->vdoc=="1"
        IF m_ndoc1<VAL(nakl1->ndoc).AND.nakl1->vdoc=="1"
          m_ndoc1:=VAL(nakl1->ndoc)
        ENDIF
      ENDIF
      IF m_vnum1<VAL(nakl1->vnum)
        m_vnum1:=VAL(nakl1->vnum)
      ENDIF
      m_gauge:=DispGauge(m_gauge,Nakl1->(RECNO()/Lastrec()))
      nakl1->(DBSKIP())
    ENDDO
IF fvnum->ndoc<>m_ndoc1+1
  DispError("Системний номер накладних ("+STR(fvnum->ndoc,6);
  +")"+";не збiгається з максимальним номером "+STR(m_ndoc1,6))
  IF ANSWERu("Нумеровати накладнi починаючi з "+STR(m_ndoc1+1,6))==YES
    fvnum->ndoc:=m_ndoc1+1
  ENDIF
ENDIF

    fvnum->vnum:=m_vnum1+1
    CLOSE base nakl1,nakl2
    DelGauge(m_gauge)
    DelMessage(m_message)
    FERASE(m_tempath+"nakl1")

USE (m_workpath+"nalog1") NEW
    INDEX ON field->vnum TO (m_tempath+"nalog1")
    fvnum->(DBGOTO(2))
    USE (m_workpath+"nalog2") INDEX (m_workpath+"nalog2")  NEW
    m_vnum:=VAL(nalog1->vnum)-1;m_ndoc:=BLANK(nalog1->ndoc,.t.)
    m_gauge:=InitGauge("Перегляд файлу nalog1",2)
    m_ndoc1:=0;m_vnum1:=0
    DO WHILE .NOT.nalog1->(EOF())
      IF STR(VAL(nalog1->vnum),6)<>nalog1->vnum
        Disp1("Помилка перетворення внутрiшнього номеру податкової накладної N"+nalog1->ndoc,n_win1)
      ENDIF
      IF .NOT.nalog2->(DS(nalog1->vnum))
        Disp1("Вiдсутнi строки податкової накладної N"+nalog1->ndoc,n_win1)
      ENDIF
      IF m_vnum==VAL(nalog1->vnum)
        Disp1("Строки податкової накладної N"+nalog1->ndoc+" i податкової накладної N"+m_ndoc+" переплутанi !!!!",n_win1)
      ENDIF
      m_vnum:=VAL(nalog1->vnum);m_ndoc:=nalog1->ndoc
      m_gauge:=DispGauge(m_gauge,nalog1->(RECNO())/nalog1->(LASTREC()))
      IF Year(nalog1->ddoc)==fvnum->year.and.nalog1->vdoc=="1"
        IF m_ndoc1<VAL(nalog1->ndoc).and.nalog1->vdoc=="1"
          m_ndoc1:=VAL(nalog1->ndoc)
        ENDIF
      ENDIF
      IF m_vnum1<VAL(nalog1->vnum)
        m_vnum1:=VAL(nalog1->vnum)
      ENDIF
      nalog1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,Nalog1->(RECNO()/Lastrec()))
    ENDDO
IF fvnum->ndoc<>m_ndoc1+1
  DispError("Системний номер накладних ("+STR(fvnum->ndoc,6);
  +")"+";не збiгається з максимальним номером "+STR(m_ndoc1,6))
  IF ANSWERu("Нумеровати накладнi починаючi з "+STR(m_ndoc1+1,6))==YES
    fvnum->ndoc:=m_ndoc1+1
  ENDIF
ENDIF
    fvnum->vnum:=m_vnum1+1
    CLOSE base nalog1,nalog2
    DelGauge(m_gauge)
    DelMessage(m_message)
    FERASE(m_tempath+"nalog1")

USE (m_workpath+"nalog3") NEW
    INDEX ON field->vnum TO (m_tempath+"nalog3")
    fvnum->(DBGOTO(7))
    USE (m_workpath+"nalog4") INDEX (m_workpath+"nalog4")  NEW
    m_vnum:=VAL(nalog3->vnum)-1;m_ndoc:=BLANK(nalog3->ndoc,.t.)
    m_gauge:=InitGauge("Перегляд файлу nalog3",2)
    m_ndoc1:=0;m_vnum1:=0
    DO WHILE .NOT.nalog3->(EOF())
      IF STR(VAL(nalog3->vnum),6)<>nalog3->vnum
        Disp1("Помилка перетворення внутрiшнього номеру розрахунку N"+nalog3->ndoc,n_win1)
      ENDIF
      IF .NOT.nalog4->(DS(nalog3->vnum))
        Disp1("Вiдсутнi строки  розрахунку N"+nalog3->ndoc,n_win1)
      ENDIF
      IF m_vnum==VAL(nalog3->vnum)
        Disp1("Строки  розрахунку N"+nalog3->ndoc+" i розрахунку N"+m_ndoc+" переплутанi !!!!",n_win1)
      ENDIF
      m_vnum:=VAL(nalog3->vnum);m_ndoc:=nalog3->ndoc
      m_gauge:=DispGauge(m_gauge,nalog3->(RECNO())/nalog3->(LASTREC()))
      IF Year(nalog3->ddoc)==fvnum->year
        IF m_ndoc1<VAL(nalog3->ndoc)
          m_ndoc1:=VAL(nalog3->ndoc)
        ENDIF
      ENDIF
      IF m_vnum1<VAL(nalog3->vnum)
        m_vnum1:=VAL(nalog3->vnum)
      ENDIF
      nalog3->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,nalog3->(RECNO()/Lastrec()))
    ENDDO
    fvnum->ndoc:=m_ndoc1+1
    fvnum->vnum:=m_vnum1+1
    CLOSE base nalog3,nalog4,fvnum
    DelGauge(m_gauge)
    FERASE(m_tempath+"nalog3")
Wclose(n_win1)
INKEY(5)
WSELECT(0)
SET PRINTER OFF
SET PRINTER TO
RETURN .t.
STATIC Function Disp1(m_str,n_win1)
Wselect(n_win1)
BeepErr()
?m_str
Wselect(0)
RETURN .t.
