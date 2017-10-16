#include "new.ch"
#include "menu.ch"
MEMVAR m_workpath,m_mainpath,m_sprpath,m_bufpath,m_temppath
#DEFINE COND1 (funnum->vdoc <> 51.OR.funnum->kopr=='05') .AND. funnum->kopr<>'00'
Function Ost01()
  LOCAL a_struct:={;
  {"DBT","C",6,0},;
  {"KOD","C",10,0},;
  {"KSASH","C",6,0}},m_scht:=SPACE(3),GetList:={},n
  @5,15,10,65 BOX B_DOUBLE+" " COLOR "GR+/BG"
  @6,22 SayDisp "Введiть рахунок" COLOR "w+/bg"
  SET ESCAPE ON
  @7,28 Get m_scht COLOR "N/BG,GR+/N"
  READ
  IF LASTKEY()==K_ESC
    RETURN .F.
  ENDIF
  DBCREATE(m_workpath+"Ost01",a_struct)
  USE (m_workpath+"Ost01") NEW
  INDEX ON ost01->dbt TO (m_workpath+"Ost01")
  // Ввод рахунка

  m_scht:=ALLTRIM(m_scht);n:=LEN(m_scht)
  Sp44->(DS(m_scht))
  DO WHILE .NOT.Sp44->(EOF()).AND.LEFT(sp44->ksash,n)==m_scht
    Ost01->(DBAP())
    Ost01->dbt:=Sp44->ksash
    Sp07->(DBSKIP())
  ENDDO
  Kaptka1->(DBGOTOP())
  DO WHILE .NOT.Kaptka1->(EOF())
    IF LEFT(Kaptka1->ksash,n)==m_scht
      IF .NOT.Sp44->(DS(Kaptka1->ksash))
        Sp44->(DBAP())
        Sp44->ksash:=Kaptka1->ksash
        Sp44->Naim7:=Kaptka1->Name
      ENDIF
      IF .NOT.Ost01->(DS(Kaptka1->ksash))
        Ost01->(DBAP())
        Ost01->dbt:=Kaptka1->ksash
      ENDIF
      Ost01->kod:=Kaptka1->kod
      Ost01->ksash:=Kaptka1->Ksash2
    ENDIF
    Kaptka1->(DBSKIP())
  ENDDO
  CLOSE ost01
RETURN .t.
Function Ost02
  LOCAL m_browse,m_col,m_key,i,j,n,l_print:={},l_delete:=.t.,GetList:={}
  DCL MENU
  USE (m_workpath+"Ost01") INDEX  (m_workpath+"Ost01") NEW
  SET ESCAPE ON
  @1,0,MAXROW(),MAXCOL() BOX B_DOUBLE+" " COLOR "w/b"
  m_browse:=TBrowseDB(2,1,MAXROW(),MAXCOL()-1)
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  m_browse:colsep        := '│'
  m_browse:SkipBlock     := { |n| SkipDb(n) }
  m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
  m_browse:goTopBlock    := { ||  DBGOTOP()  }
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(Ost01->dbt)
  m_col:heading:="Код;рахунку"
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:={||Sp44->(DS(Ost01->dbt)),Sp44->naim7}
  m_col:heading:="Назва;рахунку"
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:={||IF(EMPTY(ost01->kod),REPLICATE("?",10),ost01->kod)}
  m_col:heading:="Код;продукцiї"
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:={||Kaptka1->(DS(Ost01->kod)),Kaptka1->name}
  m_col:heading:="Назва;продукцiї"
  m_col:width:=25
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(Ost01->ksash)
  m_col:heading:="Код;реалiзацiї"
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:={||Sp44->(DS(Ost01->ksash)),Sp44->naim7}
  m_col:heading:="Назва;рахунку"
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_browse:freeze:=3
  DO WHILE .t.
    STABILIZE BROWSE m_browse
    m_key:=INKEY(0)
    DO CASE
      CASE m_key==K_ESC
        EXIT
      DEAL BROWSE m_browse KEY m_key
      CASE m_key==K_ENTER
       DO CASE
        CASE m_browse:ColPos==1
          STABILIZE BROWSE m_browse
          @ROW(),COL() Get ost01->dbt VALID Sp44->(Sp_vl("SP44")) COLOR "w/b,GR+/N"
          READ
        CASE m_browse:ColPos==3
          STABILIZE BROWSE m_browse
          @ROW(),COL() Get ost01->kod VALID Kaptka1->(Kaptka_vl()) COLOR "w/b,GR+/N"
          READ
        CASE m_browse:ColPos==5
          STABILIZE BROWSE m_browse
          @ROW(),COL() Get ost01->ksash VALID Sp44->(Sp_vl("SP44")) COLOR "w/b,GR+/N"
          READ
      ENDCASE
      m_browse:RefreshCurrent()
    ENDCASE
  ENDDO
  CLOSE Ost01

RETURN .t.
Function Ost03()
LOCAL m_scht:=SPACE(30),m_mol:="  ",m_mnt:=SPACE(4),;
a_sub:={},i,m_month,m_str1,m_month1,m_file1,m_file2,s_files:={}
LOCAL l,a_struct:={;
{"SUBSCH","C",6,0},;
{"MOL","C",2,0},;
{"KVO","N",14,2},;
{"GLV","N",14,2},;
{"SUM","N",14,2},;
{"SUM1","N",14,2},;
{"KOD","C",10,0},;
{"KVO1","N",14,2},;
{"GLV1","N",14,2},;
{"SUMD","N",14,2},;
{"MNT","C",4,0},;
{"SUMD1","N",14,2}},getlist:={},m_str,m_glvm,m_gauge
    SopenFiles("100",@s_files)
    OpenFl1()
  @5,15,10,65 BOX B_DOUBLE+" " COLOR "GR+/BG"
  @7,17 SayDisp "Рахунки " COLOR "w+/bg"
  @8,17 SayDisp "МВО" COLOR "w+/bg"
  @9,17 SayDisp "Дата " COLOR "w+/bg"
  SET ESCAPE ON
  @7,28 Get m_scht COLOR "N/BG,GR+/N"
  @8,28 Get m_mol COLOR "N/BG,GR+/N" VALID Sp02->(sp_vl("SP02","2",8,31,"_mol(sp02->mol)","GR+/BG"))
  @9,28 Get m_mnt COLOR "N/BG,GR+/N" VALID LEN(ALLTRIM(m_scht))>1
  GetList[3]:block:={|x|IF(x==NIL,RIGHT(m_mnt,2)+"."+LEFT(m_mnt,2),m_mnt:=RIGHT(x,2)+LEFT(x,2))}
  GetList[3]:picture:="99.99"
  GetList[3]:Postblock:={||IF(Left(m_mnt,2)>="00".AND.LEFT(m_mnt,2)<="99".AND.RIGHT(m_mnt,2)>="01".AND.RIGHT(m_mnt,2)<="12",.t.,.f.)}
  READ
m_str:=ALLTRIM(m_scht)
m_month:=VAL(RIGHT(m_mnt,2))-1
DO WHILE .NOT.EMPTY(m_str)
  i:=AT(",",m_str)
  IF i<>0
    AADD(a_sub,SUBSTR(m_str,1,i-1))
    m_str:=SUBSTR(m_str,i+1,LEN(m_str))
  ELSE
    AADD(a_sub,m_str)
    m_STR:=""
  ENDIF
ENDDO
m_gauge:=InitGauge("Перегляд основної бази даних",2)
m_str1:=DispMessage("Формування залишкiв по МВО;"+ALLTRIM(m_mol+" "+_mol(m_mol))+"на "+MyMonth(m_month+1))
NET USE  (m_mainpath+"funnum")  NEW
NET USE   (m_mainpath+"fdbcr")  NEW
NET USE   (m_mainpath+"fglv")   NEW
NET USE (m_workpath+"Spr03") NEW


NET USE (m_sprpath+"SP22") INDEX (m_sprpath+"SP22") NEW
DBCREATE(m_workpath+"Ost2",a_struct)
USE (m_workpath+"Ost2") NEW
INDEX ON Ost2->subsch+Ost2->mol TO (m_workpath+"ost2")
DO WHILE .NOT.fdbcr->(EOF())
  IF LEN(a_sub)==0.OR.ASCAN(a_sub,SUBSTR(fdbcr->dbt,1,2)) <> 0 .OR. ASCAN(a_sub,SUBSTR(fdbcr->crt,1,2))<>0
    IF .NOT.Pfilpoz("funnum","vnum","fdbcr")
      l:=fdbcr->vnum
      DO WHILE fdbcr->vnum == l.and..NOT.fdbcr->(EOF())
         i++
         SKIP ALIAS fdbcr
      ENDDO
      LOOP
    ENDIF
    m_month1:=IF(Day(funnum->ddoc)>26,Month(funnum->ddoc)+1,Month(funnum->ddoc))
    IF  m_month1>m_month.OR.(funnum->otp<>m_mol.AND.funnum->kplh<>m_mol)
      DO WHILE fdbcr->vnum == funnum->vnum.and..NOT.fdbcr->(EOF())
        fdbcr->(DBSKIP())
      ENDDO
      LOOP
    ENDIF
    m_glvm:=0
    IF funnum->vdoc>=200.and.funnum->vdoc<=399                            && Условие наличия голов
      IF Pfilpoz("fglv","vnum","funnum")
         m_glvm:=fglv->glv
      ENDIF
    ENDIF
    IF m_glvm<>0.OR.fdbcr->kvo<>0.OR.fdbcr->stm<>0
      IF m_glvm<>0.OR.fdbcr->kvo<>0.OR.fdbcr->stm<>0
        IF LEN(a_sub)==0.OR.ASCAN(a_sub,SUBSTR(fdbcr->dbt,1,2)) <> 0.AND.(EMPTY(m_mol).OR.funnum->kplh==m_mol)
          IF.NOT.Ost2->(DS(fdbcr->dbt+funnum->kplh))
            Ost2->(DBAP())
            ost2->subsch := fdbcr->dbt;ost2->mol:= funnum->kplh;ost2->mnt:=m_mnt
          ENDIF
          ost2->glv := ost2->glv + m_glvm
          IF funnum->vdoc == 1 .OR. funnum->vdoc == 2 .OR. funnum->vdoc == 3
               sp22->(DBSEEK(STRZERO(m_month1,2) + SUBSTR(fdbcr->dbt,5,2)))
               ost2->kvo  := ost2->kvo+ROUND(fdbcr->kvo * sp22->koef,2)
          ELSE
               IF COND1
                  ost2->kvo := ost2->kvo+fdbcr->kvo
                  ost2->sum := ost2->sum+fdbcr->stm
                ELSE
                  ost2->sum1 := ost2->sum1+fdbcr->stm
               ENDIF
          ENDIF
        ENDIF
        IF LEN(a_sub)==0.OR.ASCAN(a_sub,SUBSTR(fdbcr->crt,1,2)) <> 0.AND.(EMPTY(m_mol).OR.funnum->otp==m_mol)
          IF.NOT.Ost2->(DS(fdbcr->crt+funnum->otp))
            Ost2->(DBAP());ost2->subsch := fdbcr->CRT;ost2->mol:= funnum->otp;ost2->mnt:=m_mnt
          ENDIF
          IF funnum->vdoc == 1 .OR. funnum->vdoc == 2 .OR. funnum->vdoc == 3
            sp22->(DBSEEK(STRZERO(m_month1,2) + SUBSTR(fdbcr->crt,5,2)))
            ost2->kvo    := ost2->kvo-ROUND(fdbcr->kvo * sp22->koef,2)
          ELSE
            IF COND1
               ost2->kvo   := ost2->kvo-fdbcr->kvo
               ost2->sum := ost2->sum-fdbcr->stm
            ELSE
              ost2->sum1 := ost2->sum1-fdbcr->stm
            ENDIF
          ENDIF
          ost2->glv := ost2->glv - m_glvm
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  m_gauge:=DispGauge(m_gauge,fdbcr->(RECNO())/fdbcr->(LASTREC()))
  fdbcr->(DBSKIP())
ENDDO
DelGauge(m_gauge)
DO WHILE .NOT.Spr03->(EOF())
  IF Spr03->mnt==m_mnt.AND.(EMPTY(m_mol).OR.m_mol==Spr03->mol)
    Kaptka1->(DS(Spr03->kod))
    IF LEN(a_sub)==0.OR.ASCAN(a_sub,LEFT(Kaptka1->ksash,2)) <> 0
    IF .NOT.Ost2->(DS(Kaptka1->ksash+Spr03->mol))
      Ost2->(DBAP())
      Ost2->Subsch:=Kaptka1->ksash
      Ost2->mol:=Spr03->mol;ost2->mnt:=m_mnt
    ENDIF
    IF EMPTY(Ost2->kod)
      Ost2->kod:=Spr03->kod
    ELSE
      DispError("Подвiйне кодування;коду аналiтичного облiку;по кодам "+Ost2->kod+" i "+Spr03->kod)
    ENDIF

    Ost2->kvo1 :=Spr03->kvo
    Ost2->glv1 :=Spr03->glv
    Ost2->sumd :=Spr03->stm
    Ost2->sumd1:=Spr03->stm1
  ENDIF
  ENDIF
  Spr03->(DBSKIP())
ENDDO
DelMessage(m_str1)
  Ost2->(DBGOTOP())
DO WHILE .NOT.Ost2->(EOF())
  IF Ost2->kvo1==0.AND.Ost2->glv1==0.and.Ost2->sumd==0.and.;
    Ost2->sumd1==0.and.Ost2->kvo==0.and.Ost2->glv==0.and.Ost2->sum==0.and.Ost2->sum1==0
    Ost2->(DBDELETE())
  ENDIF
  IF EMPTY(ost2->mol)
    Ost2->(DBDELETE())
  ENDIF

  Ost2->(DBSKIP())
ENDDO

m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
USE (m_file1) NEW alias kaptka
index on kaptka->ksash TO (m_temppath+"kaptka")
ost2->(DBGOTOP())
do while .not.ost2->(EOF())
  IF kaptka->(DS(ost2->subsch))
    ost2->kod:=kaptka->kod
  ENDIF
  ost2->(DBSKIP())
ENDDO
    ScloseFile(s_files)
    CloseFl1()
CLOSE  BASE fdbcr,funnum,sp22,fglv,ost2,spr03,kaptka
RETURN .t.
FUNCTION pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)

LOCAL  m_fict_zap
LOCAL  m_fict_al
PRIVATE m_1
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
m_1 := ALLTRIM(m_nmfl_2) + '->' + ALLTRIM(m_nmpl_1)
LOCATE  REST  FOR  &(m_nmpl_1) == &(m_1)
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF
RETURN( .F. )
Function MyMonth(n)
  LOCAL a_month:={;
"сiчень",;
"лютий",;
"березень",;
"квiтень",;
"травень",;
"червень",;
"липень",;
"серпень",;
"вересень",;
"жовтень",;
"листопад",;
"грудень"}
IF n>=1.AND.n<=12
  RETURN a_month[n]
ENDIF
RETURN ""
Function Ost04
  LOCAL m_browse,m_col,m_key,i,j,n,l_print:={},l_delete:=.t.,GetList:={}
  LOCAL m_recno,m_get,s_files:={}
  DCL MENU
    SopenFiles("100",@s_files)
    OpenFl1()
  USE (m_workpath+"Ost2") INDEX  (m_workpath+"Ost2") NEW
  SET ESCAPE ON
  @1,0,MAXROW(),MAXCOL() BOX B_DOUBLE+" " COLOR "w/b"
  m_browse:=TBrowseDB(2,1,MAXROW(),MAXCOL()-1)
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  m_browse:colsep        := '│'
  m_browse:SkipBlock     := { |n| SkipDb(n) }
  m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
  m_browse:goTopBlock    := { ||  DBGOTOP()  }
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(Ost2->mol)
  m_col:heading:="Код;МВО"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||Ost2->subsch}
  m_col:heading:="Назва;рахунку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||Sp44->(DS(Ost2->Subsch)),Sp44->naim7}
  m_col:heading:="Назва;рахунку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||IF(EMPTY(ost2->kod),REPLICATE(IF(ost2->kvo<>0,"?"," "),10),ost2->kod)}
  m_col:heading:="Код;продукцiї"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||Kaptka1->(DS(Ost2->kod)),Kaptka1->name}
  m_col:heading:="Назва;продукцiї"
  m_col:width:=25
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||ost2->kvo}
  m_col:heading:="Кiлькiсть;по бух облiку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(ost2->kvo1)
  m_col:heading:="Кiлькiсть;по залишкам"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||ost2->glv}
  m_col:heading:="Кiлькiсть 2;по бух облiку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(ost2->glv1)
  m_col:heading:="Кiлькiсть 2;по залишкам"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||ost2->sum}
  m_col:heading:="   Сума ;по бух облiку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(ost2->sumd)
  m_col:heading:="Сума ;по залишкам"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||ost2->sum1}
  m_col:heading:="Сума накл.;витрат;по бух облiку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(ost2->sumd1)
  m_col:heading:="Сума накл.;витрат;по залишкам"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  m_Col           := TBColumnNew()
  m_col:block:={||SumToStr(ost2->sum1+ost2->sum,14)}
  m_col:heading:="Загальна сума;по бух облiку"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:block:={||SumToStr(ost2->sumd+ost2->sumd1,14)}
  m_col:heading:="Загальна сума ;витрат;по залишкам"
  AADD(l_print,.T.)
  m_Col:headsep    := "╤═"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_browse:addColumn(m_col)

  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||color1()}
  NEXT

  m_browse:freeze:=3
  DO WHILE .t.
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color1())
    STABILIZE BROWSE m_browse
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2())
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},MyFunc1(EVAL(m_browse:GetColumn(1):colorBlock)))

    m_key:=INKEY(0)
    DO CASE
      CASE m_key==K_ESC
        EXIT
      DEAL BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_S
          SaySum()
    CASE m_key==K_ALT_W
      IF ANSWERu("Занести залишки до довiдника?")==YES
        ZanOst()
      ENDIF
    CASE m_key==K_F5
      ost2->kvo1:=ost2->kvo
      ost2->glv1:=ost2->glv
      ost2->sumd:=ost2->sum
      ost2->sumd1:=ost2->sum1
      m_browse:RefreshCurrent()
    CASE m_key==K_ALT_F5
      m_recno:=Ost2->(RECNO())
      ost2->(DBSETORDER(0))
      ost2->(DBGOTOP())
      DO WHILE .NOT.ost2->(EOF())
        ost2->kvo1:=ost2->kvo
        ost2->glv1:=ost2->glv
        ost2->sumd:=ost2->sum
        ost2->sumd1:=ost2->sum1
        ost2->(DBSKIP())
      ENDDO
      ost2->(DBGOTO(m_recno))
      ost2->(DBSETORDER(1))
      m_browse:RefreshAll()
    CASE m_Key == K_DEL
      IF ANSWERu("Видалити строку?")==YES
        ost2->(DBDELETE())
        ost2->(DBSKIP(-1))
        ost2->(DBSKIP(1))
        m_browse:RefreshAll()
      ENDIF
      CASE m_key==K_ENTER
       DO CASE
        CASE m_browse:ColPos==2
          STABILIZE BROWSE m_browse
          @ROW(),COL() Get ost2->subsch VALID Sp44->(Sp_vl("SP44")) COLOR "w/b,GR+/N"
          READ
        CASE m_browse:ColPos==4
          STABILIZE BROWSE m_browse
          @ROW(),COL() Get ost2->kod VALID Kaptka1->(Kaptka_vl()) COLOR "w/b,GR+/N"
          READ
        CASE m_browse:ColPos==7.OR.m_browse:ColPos==9.OR.m_browse:ColPos==11.OR.m_browse:ColPos==13
          STABILIZE BROWSE m_browse
//          @ROW(),COL() Get ost01->ksash COLOR "w/b,GR+/N"
          m_get:=GetNew()
          m_get:Row:=ROW()
          m_get:Col:=COL()
          m_get:Block:=m_browse:GetColumn(m_browse:ColPos):block
          m_get:ColorSpec:="w/b,GR+/N"
          READMY({m_get})
      ENDCASE
      m_browse:RefreshCurrent()
    ENDCASE
  ENDDO
  CLOSE Ost2
    ScloseFile(s_files)
    CloseFl1()


RETURN .t.
STATIC Function Color2()
LOCAL x:={6,6}
IF ost2->kvo<>ost2->kvo1.OR.(ost2->sum+ost2->Sum1)<>(ost2->sumd1+ost2->sumd).OR.(ost2->glv<>ost2->glv1)
    x:={17,17}
ENDIF
RETURN x
STATIC function Color1()
LOCAL x:={1,2}
IF ost2->kvo<>ost2->kvo1.OR.(ost2->sum+ost2->Sum1)<>(ost2->sumd1+ost2->sumd).OR.(ost2->glv<>ost2->glv1)
    x:={7,8}
ENDIF

RETURN x
STATIC Function MyFunc1(x)
LOCAL y:={0,0}
y[1]:=x[2];y[2]:=x[2]
return y
STATIC Function SaySum()
LOCAL a_sum:={},i
ASIZE(a_sum,10)
FOR i:=1 TO 10
  a_sum[i]:=0
NEXT
        SAVEPAR()
        ost2->(DBGOTOP())
        @5,5,18,70 BOX B_DOUBLE + " " COLOR "GR+/BG"
  @7,08  SayDisp "Кiлькiсть по бух облiку" COLOR "n/Bg"
  @8,08  SayDisp "Кiлькiсть по залишкам"   COLOR "b/Bg"
  @9,08  SayDisp "Кiлькiсть 2 по бух облiку"  COLOR "n/Bg"
  @10,08 SayDisp "Кiлькiсть 2 по залишкам"    COLOR "b/Bg"
  @11,08 SayDisp "Сума  по бух облiку"           COLOR "n/Bg"
  @12,08 SayDisp "Сума по залишкам"                  COLOR "b/Bg"
  @13,08 SayDisp "Сума накл. витрат по бух облiку"    COLOR "n/Bg"
  @14,08 SayDisp "Сума накл. витрат по залишкам"      COLOR "b/Bg"
  @15,08 SayDisp "Загальна сума по бух облiку"        COLOR "n/Bg"
  @16,08 SayDisp "Загальна сума витрат по залишкам"  COLOR "b/Bg"
        DO WHILE .NOT.ost2->(EOF())
          a_sum[1] +=ost2->kvo
          a_sum[2] +=ost2->kvo1
          a_sum[3] +=ost2->glv
          a_sum[4] +=ost2->glv1
          a_sum[5] +=ost2->sum
          a_sum[6] +=ost2->sumd
          a_sum[7] +=ost2->sum1
          a_sum[8] +=ost2->sumd1
          a_sum[9] +=(ost2->sum1+ost2->sum)
          a_sum[10]+=(ost2->sumd+ost2->sumd1)
          FOR i:=1 TO 10
            @6+i,40 SayDisp SumToStr(a_sum[i],14) COLOR (IF(INT(i/2)<>i/2,"n/bg",'b/bg'))
          NEXT
          ost2->(DBSKIP())
        ENDDO
        INKEY(0)
        SAVEPAR(1)
RETURN .t.
Static Function ZanOst()
LOCAL m_mol:="",m_mnt,m_gauge,m_sch:=""
Savepar()
m_gauge:=InitGauge("Занесення залишкiв",2)
Ost2->(DBGOTOP())
USE (m_workpath+"spr03") NEW
DO WHILE .NOT.Ost2->(EOF())
  IF .NOT.EMPTY(Ost2->kod).AND.(Ost2->kvo1<>0.OR.Ost2->glv1<>0.OR.Ost2->Sumd<>0.OR.Ost2->Sumd1<>0)
    Spr03->(DBAP())
    Spr03->kod:=Ost2->kod
    Spr03->mnt:=Ost2->mnt
    Spr03->mol:=Ost2->mol
    Spr03->kvo:=Ost2->kvo1
    Spr03->glv:=Ost2->glv1
    Spr03->stm:=Ost2->Sumd
  ENDIF
  Ost2->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,0.5+Ost2->(RECNO())/(2*Ost2->(LASTREC())))
ENDDO
CLOSE Spr03
Ost2->(DBSETORDER(1))
DelGauge(m_gauge)
Savepar(1)
RETURN .t.
