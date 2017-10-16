#include "new.ch"
#include "menu.ch"
#DEFINE N_PAPER 2
MEMVAR m_mainpath,m_bufpath,m_sprpath,m_temppath,p_npr
Function FormPrem
  LOCAL i,j,n,m_month1,next_month,m_month,m_str1,m_gauge
  LOCAL m_path,m_screen,m_prc1,m_prc2,m_prc3,m_kopu1,l_first,m_kopu2

NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
m_month1:=RESTVAR1("m_month","ZR")
 CLOSE myvar
  next_month:=IF(m_month1==12,1,m_month1+1)
  i:=ALERT("Виберiть мiсяць розрахунку",{NTOCMONTH(m_month1),NTOCMONTH(next_month)},"n/bg,w/b")
  IF i==0
    RETURN .t.
  ENDIF
  m_month:=IF(i==1,m_month1,next_month)
USE memvar INDEX memvar ALIAS myvar NEW
  m_kopu1:=RESTVAR1("m_kopu1","NT")
  m_prc1:=RESTVAR1("m_prc1","NT")
  m_prc2:=RESTVAR1("m_prc2","NT")
  m_kopu2:=RESTVAR1("m_kopu2","NT")
  m_prc3:=RESTVAR1("m_prc3","NT")
  SAVEVAR1("m_month",m_month,"NT")
CLOSE myvar
m_path:=m_mainpath;m_str1:="Перегляд основної бази "
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW
NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW
USE ("prem") NEW
ZAP
INDEX ON field->tabn TO prem

FOR i:=1 TO 2
  m_gauge:=InitGauge(m_str1+" нарахувань",2)
  USE (m_path+"fz1") NEW
  USE (m_path+"fz2") NEW
  USE (m_path+"fz3") NEW
  DO WHILE .NOT.fz1->(EOF())
    IF mnt_month ( fz1->mnt ) == m_month.AND.fz1->vdoc<>38
       j:=mnt_month ( fz1->mnt )
       IF PfilPoz("Fz2","Vnum1","Fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
          IF PfilPoz("Fz3","Vnum2","Fz2")
            Sp10->(DBSEEK(fz2->tabn))
              IF .NOT.Prem->(DS(fz2->tabn))
                Prem->(DBAP())
                Prem->tabn:=fz2->tabn
              ENDIF
              l_first:=.t.
              DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                Sp08->(DS(fz3->kopu))
                IF Sp08->p10=="1".AND.month(fz1->ddoc)==m_month
                  Prem->sum1+=Fz3->sum
                  IF l_first
                    Prem->otdn1+=fz2->otdn
                    Prem->oths1+=fz2->oths
                  ENDIF
                ELSE
                  IF Sp08->p11=="1".AND.month(fz1->ddoc)==m_month
                    Prem->sum5+=Fz3->sum
                    IF l_first
                      Prem->otdn5+=fz2->otdn
                      Prem->oths5+=fz2->oths
                    ENDIF
                  ELSE
                    IF Sp08->p12=="1".AND.month(fz1->ddoc)==m_month
                      Prem->sum6+=Fz3->sum
                      IF l_first
                        Prem->otdn6+=fz2->otdn
                        Prem->oths6+=fz2->oths
                      ENDIF
                    ELSE
                      Prem->sum2+=Fz3->sum
                      IF l_first
                        Prem->otdn2+=fz2->otdn
                        Prem->oths2+=fz2->oths
                      ENDIF
                    ENDIF
                  ENDIF
                ENDIF
                l_first:=.f.
                fz3->(DBSKIP())
              ENDDO
            ENDIF
          fz2->(DBSKIP())
         ENDDO
        ENDIF
      ENDIF
     fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge, fz1->(RECNO())/fz1->(LASTREC()))
  ENDDO
  CLOSE FZ1
  CLOSE FZ2
  CLOSE FZ3
  DelGauge(m_gauge)
  m_path:=m_bufpath;m_str1:="Перегляд буферної бази даних"
NEXT
SELECT PREM
SET INDEX TO
DBGOTOP()
DO WHILE .NOT.EOF()
  Sp10->(DS(prem->tabn))
  IF Sp10->kpn<>"6"
    Prem->prem :=Prem->sum1*m_prc1/100
    Prem->prem5:=Prem->sum5*m_prc2/100
    Prem->sum3:=(Prem->sum6+Prem->prem+Prem->sum5+Prem->sum1+Prem->prem5)*m_prc3/100
    Prem->prc:=m_prc1
    Prem->prc5:=m_prc2
  ENDIF
  IF Prem->sum1==0.and.Prem->sum2==0.and.Prem->sum5==0.and.Prem->sum6==0
    Prem->(DBDELETE())
  ENDIF
  DBSKIP()
ENDDO
CLOSE Base Sp10,Sp08,Prem
RETURN .t.
Function SetVar()
  LOCAL GetList:={}
  LOCAL m_kopu1,m_prc,m_prc1,m_kopu2,m_prc2,m_kopu3,m_prc3

  @08,20,15,60 BOX B_SINGLE + " " COLOR "w/bg"
  @08,22 SayDisp "Довiдкова iнформацiя" COLOR "n/w"
  NET USE (m_sprpath+"Sp08") INDEX (m_sprpath+"Sp08") NEW
  USE memvar INDEX memvar ALIAS myvar NEW
  m_kopu1:=RESTVAR1("m_kopu1","NT")
  m_prc1:=RESTVAR1("m_prc1","NT")
  m_kopu2:=RESTVAR1("m_kopu2","NT")
  m_kopu3:=RESTVAR1("m_kopu3","NT")
  m_prc2:=RESTVAR1("m_prc2","NT")
  m_prc3:=RESTVAR1("m_prc3","NT")
  SET ESCAPE ON
  SET CURSOR ON
  @09,22 SayDisp "Код премiї 1>" COLOR "n/bg"
  @9,47 Get m_kopu1 COLOR "b/bg,gr+/n" VALID Sp08->(Sp_vl("SP08"))
  @10,22 SayDisp "Вiдсоток 1>" COLOR "n/bg"
  @10,47 Get m_prc1 COLOR "b/bg,gr+/n" PICTURE "999"
  @11,22 SayDisp "Код премiї 2>" COLOR "n/bg"
  @11,47 Get m_kopu2 COLOR "b/bg,gr+/n" VALID Sp08->(Sp_vl("SP08"))
  @12,22 SayDisp "Вiдсоток 2>" COLOR "n/bg"
  @12,47 Get m_prc2 COLOR "b/bg,gr+/n" PICTURE "999"
  @13,22 SayDisp "Код ковб. >" COLOR "n/bg"
  @13,47 Get m_kopu3 COLOR "b/bg,gr+/n" VALID Sp08->(Sp_vl("SP08"))
  @14,22 SayDisp "Вiдс. ковб>" COLOR "n/bg"
  @14,47 Get m_prc3 COLOR "b/bg,gr+/n" PICTURE "999"
  READ
  IF LASTKEY()<>K_ESC
    SAVEVAR1("m_kopu1",m_kopu1,"NT")
    SAVEVAR1("m_prc3",m_prc3,"NT")
    SAVEVAR1("m_kopu2",m_kopu2,"NT")
    SAVEVAR1("m_kopu3",m_kopu3,"NT")
    SAVEVAR1("m_prc2",m_prc2,"NT")
    SAVEVAR1("m_prc1",m_prc1,"NT")
  ENDIF
  CLOSE base myvar,sp08
RETURN .t.

Function EditPrem
  LOCAL i,j,m_poisk1:={||.t.},m_poisk2:={||.t.},m_prc1,;
  m_poisk3:={||.t.},m_poisk4:={||.t.},n,m_key,m_browse,m_path,m_str1,m_gauge
  LOCAL GetList:={},k,m_screen,m_recno,l_delete:=.t.,m_prc2,m_prc3,m_kopu3
  LOCAL s_kopu0,m_kopu1,m_kopu2,a_kopu:={},m_month,n_pos1:=13,n_pos2:=14
  LOCAL a_col:={;
  {{||fl1->tabn},"Таб.;ном."},; //1
  {{||LEFT(_fio(fl1->tabn),15)},"      Ф.I.Б.  "},; //2
  {{||fl1->prc},"%; 1"},; //3
  {{||STR(fl1->otdn1,4,1)},"Вiдр;днiв"},; //4
  {{||Str(fl1->oths1,3)},"Вiдр;год."},; //5
  {{||Str(fl1->sum1,8,2)},"Сума осн.;оплати 1"},; //6
  {{||Str(fl1->prem,8,2)},"Сума ;доплати 1"},; //7
  {{||fl1->prc5},"%; 2"},; //8
  {{||STR(fl1->otdn5,4,1)},"Вiдр.;днiв 2"},; //9
  {{||STR(fl1->oths5,3)},"Вiдр.;год. 2"},; //10
  {{||Str(fl1->sum5,8,2)},"Сума осн.;оплати 2"},; //11
  {{||Str(fl1->prem5,8,2)},"Сума ;доплати 2"},; //12
  {{||Str(fl1->prem+fl1->sum1+fl1->sum5,8,2)},"Разом"},; //13
  {{||STR(fl1->otdn6,4,1)},"Вiдр.;днiв 3 "},; //14
  {{||STR(fl1->oths6,3)},"Вiдр.;год. 3"},; //15
  {{||Str(fl1->sum6,8,2)},"Сума ;для ковб."},; //16
  {{||Str(fl1->sum3,8,2)},"Сума ;ковб.;виробiв"},; //17
  {{||STR(fl1->otdn2,6,1)},"Вiдр.;днiв  ;за мiсяць"},; //18
  {{||STR(fl1->oths2,5)},"Вiдр.;год.  ;за мiсяць"},; //19
  {{||Str(fl1->sum2,8,2)},"Сума доп.;оплати; за мiсяць"}},; //20
  m_col,l_print:={}
  DCL MENU
/*
  {{||STR(fl1->otdn1,4,1)},"Вiдр;днiв"},; //4
  {{||Str(fl1->oths1,3)},"Вiдр;год."},; //5
  {{||STR(fl1->otdn2,4,1)},"Вiдр.;днiв 2;за мiсяць"},; //8
  {{||STR(fl1->oths2,3)},"Вiдр.;год. 2;за мiсяць"},; //9
*/

  NET USE (m_sprpath+"Sp10") INDEX (m_sprpath+"Sp10") NEW READONLY
  NET USE (m_sprpath+"Sp08") INDEX (m_sprpath+"Sp08") NEW READONLY
  USE memvar INDEX memvar ALIAS myvar NEW
  m_kopu1:=RESTVAR1("m_kopu1","NT")
  m_month:=RESTVAR1("m_month","NT")
  m_prc1:=RESTVAR1("m_prc1","NT")
  m_prc3:=RESTVAR1("m_prc3","NT")
  m_kopu3:=RESTVAR1("m_kopu3","NT")
  m_kopu2:=RESTVAR1("m_kopu2","NT")
  m_prc2:=RESTVAR1("m_prc2","NT")
  CLOSE myvar
  USE ("prem") INDEX ("prem")  ALIAS fl1 NEW
  m_browse:=TBrowseDB(2,1,MAXROW()-1,MAXCOL()-1)
  m_browse:colorspec:='W/B,B/W,w+/b,W/R,R/W,W+/R,w/b*,b+/w,gr+/b*,w/RB,RB+/w,w+/RB'
  m_browse:colsep        := '│'
  m_browse:SkipBlock     := { |n| SkipDb(n) }
  m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
  m_browse:goTopBlock    := { ||  DBGOTOP()  }
  n:=LEN(a_col)
  FOR i:=1 TO n
      m_Col           := TBColumnNew()
      m_col:block:=a_col[i][1]
      m_col:heading:=a_col[i][2]
      m_Col:colorblock:=  {||Color1(m_prc1,m_prc2)}
      m_Col:headsep    := "┬─"
      m_col:colsep:="│"
      m_browse:addColumn(m_col)
      AADD(l_print,.t.)
  NEXT
  m_browse:freeze:=2
  @1,0,MAXROW(),MAXCOL() BOX B_SINGLE+ ' ' COLOR "BG/B"
  @1,0 SayText PADC("Розрахунок премiї за ~2"+NTOCMONTH(m_month)+" ~1мiсяць",maxcol()-6) COLOR "n/BG,b/BG"
  @MAXROW(),0 SayText PADC("Виклик меню - ~2<~3F8~2>",MAXCOL()-7) COLOR "n/BG,b/BG,r/BG"
    ADD MENU UP_DOWN
    ADD MENU SEARCH
    ADD MENU LEFT_RIGHT
    ADD MENU NAME "Обробка" ITEMS {" Виправлення Enter",;
    "Пiдрахунок суми <Alt>+S","Занесення в базу <Alt>+W",;
    "Видалення розрахованих сум <Ctrl>+<Bs>"} KEY ;
    {K_ENTER,K_ALT_S,K_ALT_W,K_CTRL_BS}

    INIT MENU

  DO WHILE .t.
    m_browse:RefreshCurrent()
    m_key:=0
    keyboard ""
    DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
    ENDDO
    IF m_browse:stabilize()
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},Color2(m_prc1,m_prc2))
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},Color3(m_prc1,m_prc2))
    ENDIF
    IF m_key==0
      m_key:=INKEY(0)
    ENDIF
    DEAL MENU
    DO CASE
      CASE m_key==K_ESC.AND.ANSWERu("Завершити программу?")==YES
          EXIT
      DEAL BROWSE m_browse KEY m_key
      CASE m_key==K_CTRL_BS.AND.ANSWERu("Видалити суми по премiї?")==YES
        DelPrem(m_month)
      CASE m_key==K_ENTER
        STABILIZE BROWSE m_browse
        SET ESCAPE ON
        DO CASE
          CASE  m_browse:ColPos==3
            @ROW(),COL() Get fl1->prc PICTURE "999.9" COLOR "w/b,GR+/N"
            READ
            CalcPrem(m_prc3)
          CASE m_browse:ColPos==8
            @ROW(),COL() Get fl1->prc5 PICTURE "999.9" COLOR "w/b,GR+/N"
            READ
            CalcPrem5(m_prc3)
          CASE m_browse:ColPos==17
            @ROW(),COL() Get fl1->SUM3 PICTURE "99999.99" COLOR "w/b,GR+/N"
            READ
        ENDCASE
        m_browse:RefreshCurrent()
      CASE m_key==K_ALT_S.AND.ANSWERu("Подрахувати ;контрольну суму?")==YES
        SumZap()
      CASE m_key==K_ALT_W.AND.ANSWERu("Заносити ;розраховану премiю?")==YES
       PutPrem(m_kopu1,m_month,m_kopu2)
      CASE m_key==K_ALT_V.AND.ANSWERu("Заносити ;утримання за ковбасу?")==YES
       PutUder(m_kopu3,m_month)
      CASE m_key==K_ALT_1.AND.ANSWERu("Друкувати ;утримання за ковбасу?")==YES
       ListUder(m_month)
       SCAN BROWSE   m_browse KEY m_key
       SEEK BROWSE   m_browse KEY m_key
       RANGE BROWSE  m_browse KEY m_key
       SEARCH BROWSE m_browse KEY m_key
       CONTINUE SEARCH BROWSE m_browse KEY m_key
       PRINT BROWSE m_browse KEY m_key
    ENDCASE
  ENDDO
  CLOSE BASE fl1,sp10,sp08
RETURN .t.
FUNCTION SkipDb(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // Если конец файла
       IF  EOF()
          DBSKIP( -1 )
          EXIT
       END
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
END
RETURN ( ncount )
STATIC FUNCTION  _fio(m_var)
  IF m_var<>NIL
    sp10->(DBSEEK(m_var,.f.))
  ENDIF
RETURN (PADR(LEFT(ALLTRIM(sp10->fam)+' '+;
             IF(!EMPTY(sp10->imja),Chr(Asc(sp10->imja))+'.'+ ;
                                  Chr(Asc(sp10->otch))+'.',''),25),25,' '))
STATIC Function EditZap(m_kopu1,m_kopu2,a_kopu)
LOCAL GetList:={},i
        SavePar()
        @5,2,21,75 BOX B_SINGLE + " " COLOR "w/bg"
        @5,3 SayDisp "Таб. номер" COLOR "n/w"
        @5,14 SayDisp fl1->tabn COLOR "b/w"
        @5,19 SayDisp _fio(fl1->tabn) COLOR "gr+/w"
        @5+1,40 SayDisp "За мiсяць          " COLOR "n/bg"
        @5+3,32 SayDisp SumToStr(fl1->summ,14) COLOR  "w+/bg"
        @5+3,46 SayDisp SumToStr(fl1->summr,14) COLOR  "w+/bg"
        @5+3,60 SayDisp SumToStr(fl1->sumy,14) COLOR  "w+/bg"
        @5+2,35 SayDisp "Нараховано      Введено   З початку року" COLOR "n/bg"
        @5+3,4 SayDisp "Зар. платня" COLOR "n/bg"
        sp08->(DS(m_kopu1))
        @5+4,4 SayTEXT "~2"+m_kopu1+"~3 "+Sp08->name8 COLOR "n/bg,b/bg,gr+/bg"
//        @5+4,32 SayDisp SumToStr(fl1->sum1m,14) COLOR  "w+/bg"
        @5+4,32 Get fl1->sum1m PICTURE "999'999'999.99" COLOR  "w+/BG,GR+/N"
        @5+4,46 SayDisp SumToStr(fl1->sum1mr,14) COLOR  "w+/bg"
        @5+4,60 SayDisp SumToStr(fl1->sum1y,14) COLOR  "w+/bg"
        sp08->(DS(m_kopu2))
        @5+5,4 SayTEXT "~2"+m_kopu2+"~3 "+Sp08->name8 COLOR "n/bg,b/bg,gr+/bg"
//        @5+5,32 SayDisp SumToStr(fl1->sum2m,14) COLOR  "w+/bg"
        @5+5,32 Get fl1->sum2m PICTURE "999'999'999.99" COLOR  "w+/BG,GR+/N"
        @5+5,46 SayDisp SumToStr(fl1->sum2mr,14) COLOR  "w+/bg"
        @5+5,60 SayDisp SumToStr(fl1->sum2y,14) COLOR  "w+/bg"
        @5+6,4 SayDisp "Утримано по кодах " COLOR "n/bg"
        FOR i:=1 TO LEN(a_kopu)
          @5+6+i,4 SayDisp a_kopu[i] COLOR "b/bg"
          @5+6+i,46 SayDisp SumToStr(Fl1->(FIELDGET(FIELDNUM("S"+STRZERO(i,2)+"M"))),14) COLOR "w+/bg"
          @5+6+i,60 SayDisp SumToStr(Fl1->(FIELDGET(FIELDNUM("S"+STRZERO(i,2)+"Y"))),14) COLOR "w+/bg"
        NEXT
        SET ESCAPE ON
        SET CURSOR ON
//        INKEY(0)
        READ
        SET CURSOR OFF

        SavePar(1)

RETURN .t.
STATIC Function SumZap(m_kopu1,m_kopu2,a_kopu)
LOCAL i,s_otdn1:=0,s_oths1:=0,s_sum1:=0
LOCAL s_otdn2:=0,s_oths2:=0,s_sum2:=0
LOCAL s_otdn5:=0,s_oths5:=0,s_sum5:=0
LOCAL s_otdn6:=0,s_oths6:=0,s_sum3:=0
LOCAL s_prem:=0,s_prem5:=0,s_sum6:=0
LOCAL m_kvo:=0,m_key
SavePar()
fl1->(DBGOTOP())
        @5,2,21,75 BOX B_SINGLE + " " COLOR "w/bg"
        @5,3   SayDisp "Кiлькiсть " COLOR "n/w"
        @5+3,3 SayDisp "Сума оплати 1  >" COLOR "n/bg"
        @5+4,3 SayDisp "Сума премiї 1  >" COLOR "n/bg"
        @5+5,3 SayDisp "Сума оплати 2  >" COLOR "n/bg"
        @5+6,3 SayDisp "Сума премiї 2  >" COLOR "n/bg"
        @5+7,3 SayDisp "Разом          >" COLOR "n/bg"
        @5+8,3 SayDisp "Сума оплати    >" COLOR "n/bg"
        @5+9,3 SayDisp "Сума за ковбасу>" COLOR "n/bg"
        @5+10,3 SayDisp"Iншi нарахув.>  " COLOR "n/bg"
       DO WHILE .NOT.fl1->(EOF())
            m_kvo++
        @5,19 SayDisp m_kvo PICTURE "999999" COLOR "b/w"
          s_otdn1+=fl1->otdn1;s_oths1+=fl1->oths1;s_sum1 +=fl1->sum1;s_prem +=fl1->prem
          s_otdn5+=fl1->otdn5;s_oths5+=fl1->oths5;s_sum5 +=fl1->sum5;s_prem5 +=fl1->prem5
          s_otdn2+=fl1->otdn2;s_oths2+=fl1->oths2;s_sum2 +=fl1->sum2
          s_otdn6+=fl1->otdn6;s_oths6+=fl1->oths6;s_sum3 +=fl1->sum3;s_sum6 +=fl1->sum6
//        @5+1,19 SayDisp   NumToStr(s_otdn1,16,1) COLOR "w+/bg"
//        @5+2,19 SayDisp   NumToStr(s_oths1,16,0) COLOR "w+/bg"
        @5+3,19 SayDisp   SumToStr(s_sum1,16)  COLOR "w+/bg"
        @5+4,19 SayDisp   SumToStr(s_prem,16)  COLOR "w+/bg"
        @5+5,19 SayDisp   SumToStr(s_sum5,16)  COLOR "w+/bg"
        @5+6,19 SayDisp   SumToStr(s_prem5,16)  COLOR "w+/bg"
        @5+7,19 SayDisp   SumToStr(s_sum1+s_prem+s_prem5+s_sum5,16)  COLOR "w+/bg"
        @5+8,19 SayDisp   SumToStr(s_sum6,16)  COLOR "w+/bg"
        @5+9,19 SayDisp   SumToStr(s_sum3,16)  COLOR "w+/bg"
        @5+10,19 SayDisp   SumToStr(s_sum2,16)  COLOR "w+/bg"
         fl1->(DBSKIP())
        ENDDO
        DO WHILE .t.
         m_key:=INKEY(0)
         DO CASE
          CASE m_key==K_F10;calcul()
          CASE m_key==K_ALT_F10;calc()
          CASE m_key==K_F2.AND.ANSWERu("Друкувати пiдсумки?")==YES
            SET DEVICE TO PRINTER
        @prow()+1,3 Say "Кiлькiсть " COLOR "n/w"
        @prow(),19  Say m_kvo PICTURE "999999" COLOR "b/w"
        @prow()+1,3 Say "Сума оплати 1  >" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_sum1,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Сума премiї 1  >" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_prem,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Сума оплати 2  >" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_sum5,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Сума премiї 2  >" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_prem5,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Разом          >" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_sum1+s_prem+s_prem5+s_sum5,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Сума оплати    >" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_sum3,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Сума за ковбасу>" COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_sum6,16)  COLOR "w+/bg"
        @prow()+1,3 Say "Iншi нарахув.>  " COLOR "n/bg"
        @prow(),19  Say  SumToStr(s_sum2,16)  COLOR "w+/bg"
        SET DEVICE TO SCREEN
          OTHERWISE
            EXIT
        ENDCASE
      ENDDO
        SavePar(1)
RETURN .t.
STATIC Function PutPrem(m_kopu1,m_month,m_kopu2)
LOCAL m_message,i,j,m_str1,a_struct:={},n,m_path,m_gauge,l_change
LOCAL m_recno1,m_recno,m_sum1,m_sum2,m_sum,m_vnum
SAVEPAR()
m_message:=DispMessage;
("Занесення розрахованої суми;премiї;Увага !; Попереднiй розрахунок буде видалено!!! ")
  m_path:=m_mainpath;m_str1:="Занесення розрахованих сум в основну базу "
  Fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
      fl1->SUM4:=0
      fl1->SUMMAX:=0
      fl1->REC:=0
      fl1->bd:=" "
      fl1->SUM7:=0
      fl1->SUMMAX2:=0
      fl1->REC2:=0
      fl1->bd2:=" "
    fl1->(DBSKIP())
  ENDDO
  FOR j:=1 TO 2
    m_gauge:=InitGauge(m_str1+" нарахувань",2)
    l_change:=.f.
    USE (m_path+"fz1") NEW
    USE (m_path+"fz2") NEW
    USE (m_path+"fz3") NEW
    a_struct:=Fz3->(DBSTRUCT())
    n:=LEN(a_struct)
    DBCREATE(m_path+"fz3d",a_struct)
    USE (m_path+"fz3d") NEW
    DO WHILE .NOT.fz1->(EOF())
      IF mnt_month ( fz1->mnt ) == m_month.AND.month(fz1->ddoc) == m_month .AND.fz1->vdoc<>38
          IF PfilPoz("Fz2","Vnum1","Fz1")
            DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            m_recno:=Fz3->(RECNO())
            IF PfilPoz("Fz3","Vnum2","Fz2")
              m_recno1:=Fz3->(RECNO())
              Fz3->(DBGOTO(m_recno))
              DO WHILE fz3->(RECNO())<m_recno1
                fz3d->(DBAP())
                FOR i:=1 TO n
                  fz3d->(FIELDPUT(i,fz3->(FIELDGET(i))))
                NEXT
                fz3->(DBSKIP())
              ENDDO
              fl1->(DS(fz2->tabn))
              DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                l_change:=.t.
                IF fz3->st=="P"
                  fz3->(DBDELETE())
                ELSE
                  fz3d->(DBAP())
                  FOR i:=1 TO n
                    fz3d->(FIELDPUT(i,fz3->(FIELDGET(i))))
                  NEXT
                  Sp08->(DS(fz3->kopu))
                  IF Sp08->p10=="1"
                    m_sum1:=ROUND(fl1->prem*fz3->sum/fl1->sum1,2)
                    IF m_sum1<>0
                      fz3d->(DBAP())
                      fz3d->vnum2:=fz3->vnum2
                      fz3d->kopu:=m_kopu1
                      fz3d->sum:=m_sum1
                      fz3d->st:="P"
                      fl1->Sum4+=fz3d->sum
                      IF fz3d->sum>fl1->SumMax
                        fl1->SumMax:=fz3d->sum
                        fl1->Rec:=Fz3d->(RECNO())
                        fl1->bd:=STR(j,1)
                      ENDIF
                    ENDIF
                  ENDIF
                  IF Sp08->p11=="1"
                    m_sum1:=ROUND(fl1->prem5*fz3->sum/fl1->sum5,2)
                    IF m_sum1<>0
                      fz3d->(DBAP())
                      fz3d->vnum2:=fz3->vnum2
                      fz3d->kopu:=m_kopu2
                      fz3d->sum:=m_sum1
                      fz3d->st:="P"
                      fl1->Sum7+=fz3d->sum
                      IF fz3d->sum>fl1->SumMax2
                        fl1->SumMax2:=fz3d->sum
                        fl1->Rec2:=Fz3d->(RECNO())
                        fl1->bd2:=STR(j,1)
                      ENDIF
                    ENDIF
                  ENDIF
               ENDIF
                fz3->(DBSKIP())
              ENDDO
            ENDIF
            fz2->(DBSKIP())
            ENDDO
          ENDIF
        ENDIF
        m_gauge:=DispGauge(m_gauge, fz1->(RECNO())/fz1->(LASTREC()))
        fz1->(DBSKIP())
    ENDDO
    CLOSE FZ1
    CLOSE FZ2
    IF l_change
      DO WHILE .NOT.fz3->(EOF())
        fz3d->(DBAP())
        FOR i:=1 TO n
          fz3d->(FIELDPUT(i,fz3->(FIELDGET(i))))
        NEXT
        fz3->(DBSKIP())
      ENDDO
    ENDIF
    CLOSE FZ3
    CLOSE FZ3D
    IF FILE(m_path+"FZ3.DD1")
      FERASE(m_path+"FZ3.DD1")
    ENDIF
    IF l_change
      IF FRENAME(m_path+"Fz3.dbf",m_path+"FZ3.DD1")==-1
        DispError("Помилка при перемiщеннi файлу FZ3")
      ELSE
        IF FRENAME(m_path+"Fz3D.dbf",m_path+"FZ3.DBF")==-1
          DispError("Помилка при перемiщеннi файлу Fz3D")
        ENDIF
      ENDIF
    ELSE
      FERASE(m_path+"FZ3d.DBF")
    ENDIF
    DelGauge(m_gauge)
    m_str1:="Занесення розрахованих сум в буферну базу "
    m_path:=m_bufpath
  NEXT
// Округленiе
  fl1->(DBGOTOP())
  USE (m_mainpath+"fz3") NEW
  DO WHILE .NOT.fl1->(EOF())
    IF (fl1->prem-fl1->Sum4)<>0.AND.fl1->Rec<>0.AND.fl1->bd=="1"
      fz3->(DBGOTO(fl1->Rec))
      Fz3->sum+=(fl1->prem-fl1->Sum4)
      IF ABS(fl1->prem-fl1->Sum4)>0.3
        DispError("Дуже великий розбiг; сум по таб. номеру "+fl1->tabn+";Cума"+ALLTRIM(STR(fl1->prem-fl1->Sum4,10,2)))
      ENDIF
    ENDIF
    IF (fl1->prem5-fl1->Sum7)<>0.AND.fl1->Rec2<>0.AND.fl1->bd2=="1"
      fz3->(DBGOTO(fl1->Rec2))
      Fz3->sum+=(fl1->prem5-fl1->Sum7)
      IF ABS(fl1->prem5-fl1->Sum7)>0.3
        DispError("Дуже великий розбiг; сум по таб. номеру "+fl1->tabn+";Cума"+ALLTRIM(STR(fl1->prem5-fl1->Sum7,10,2)))
      ENDIF
    ENDIF
    fl1->(DBSKIP())
  ENDDO
  CLOSE fz3
  USE (m_bufpath+"fz3") NEW
  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    IF (fl1->prem-fl1->Sum4)<>0.AND.fl1->Rec<>0.AND.fl1->bd=="2"
      fz3->(DBGOTO(fl1->Rec))
      Fz3->sum+=(fl1->prem-fl1->Sum4)
      IF ABS(fl1->prem-fl1->Sum4)>0.3
        DispError("Дуже великий розбiг; сум по таб. номеру "+fl1->tabn+";Cума"+ALLTRIM(STR(fl1->prem-fl1->Sum4,10,2)))
      ENDIF
    ENDIF
    IF (fl1->prem5-fl1->Sum7)<>0.AND.fl1->Rec2<>0.AND.fl1->bd2=="2"
      fz3->(DBGOTO(fl1->Rec2))
      Fz3->sum+=(fl1->prem5-fl1->Sum7)
      IF ABS(fl1->prem5-fl1->Sum7)>0.3
        DispError("Дуже великий розбiг; сум по таб. номеру "+fl1->tabn+";Cума"+ALLTRIM(STR(fl1->prem5-fl1->Sum7,10,2)))
      ENDIF
    ENDIF
    fl1->(DBSKIP())
  ENDDO
  CLOSE fz3
SAVEPAR(1)
RETURN .t.
STATIC Function CalcPrem(m_prc3)
  fl1->prem:=fl1->sum1*fl1->prc/100
  fl1->sum3:=(fl1->sum1+fl1->sum5+fl1->prem+fl1->prem5+fl1->sum6)*m_prc3/100
RETURN .t.
STATIC Function CalcPrem5(m_prc3)
  fl1->prem5:=fl1->sum5*fl1->prc5/100
  fl1->sum3:=(fl1->sum1+fl1->sum5+fl1->prem+fl1->prem5+fl1->sum6)*m_prc3/100
RETURN .t.
STATIC Function Color1(m_prc,m_prc2)
IF fl1->prc==m_prc.AND.fl1->prc5==m_prc2
  RETURN ({1,2})
ENDIF
IF fl1->prc<m_prc.AND.fl1->prc5<m_prc2
  RETURN ({4,5})
ENDIF
IF fl1->prc>m_prc.AND.fl1->prc5>m_prc2
 RETURN ({7,8})
ENDIF
RETURN ({10,11})
STATIC Function Color2(m_prc,m_prc2)
IF fl1->prc==m_prc.AND.fl1->prc5==m_prc2
  RETURN ({3,3})
ENDIF
IF fl1->prc<m_prc.AND.fl1->prc5<m_prc2
  RETURN ({6,6})
ENDIF
IF fl1->prc>m_prc.AND.fl1->prc5>m_prc2
 RETURN ({9,9})
ENDIF
RETURN ({12,12})
STATIC Function Color3(m_prc,m_prc2)
IF fl1->prc==m_prc.AND.fl1->prc5==m_prc2
  RETURN ({2,2})
ENDIF
IF fl1->prc<m_prc.AND.fl1->prc5<m_prc2
  RETURN ({5,5})
ENDIF
IF fl1->prc>m_prc.AND.fl1->prc5>m_prc2
 RETURN ({8,8})
ENDIF
RETURN ({11,11})
Function DelPrem(m_month)
  LOCAL m_path,m_str1,m_gauge,i
  m_path:=m_mainpath;m_str1:="Видалення розрахованих сум з основної бази "
  FOR i:=1 TO 2
    m_gauge:=InitGauge(m_str1+" нарахувань",2)
    USE (m_path+"fz1") NEW
    USE (m_path+"fz2") NEW
    USE (m_path+"fz3") NEW
    DO WHILE .NOT.fz1->(EOF())
      IF month(fz1->ddoc) == m_month .AND.fz1->vdoc<>38
          IF PfilPoz("Fz2","Vnum1","Fz1")
            DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF PfilPoz("Fz3","Vnum2","Fz2")
              DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                IF fz3->st=="P"
                   fz3->(DBDELETE())
                ENDIF
                fz3->(DBSKIP())
              ENDDO
            ENDIF
            fz2->(DBSKIP())
            ENDDO
          ENDIF
        ENDIF
        fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge, fz1->(RECNO())/fz1->(LASTREC()))
    ENDDO
    CLOSE FZ1
    CLOSE FZ2
    CLOSE FZ3
    DelGauge(m_gauge)
    m_str1:="Видалення розрахованих сум з буферної бази "
    m_path:=m_bufpath
  NEXT
RETURN .t.
STATIC Function PutUder(m_kopu3,m_month)
LOCAL m_message,i,j,m_str1,a_struct:={},n,m_path,m_gauge,l_change
LOCAL m_recno1,m_recno,m_sum1,m_sum2,m_sum,m_vnum
SAVEPAR()
m_message:=DispMessage;
("Занесення утримань за ковбасу;Увага !; Попереднi данi буде видалено!!! ")
  m_path:=m_bufpath;m_str1:="Занесення сум утримань в базу даних"
  USE (m_bufpath+"fvnum.dbr") NEW
  USE (m_bufpath+"fd1") NEW
  USE (m_bufpath+"fd2") NEW
  fd1->(DBAPPEND())
  fd1->npch:=700
  fd1->ndoc:=m_month
  fd1->kopu:=m_kopu3
  fd1->vdoc:=2
  fd1->ddoc:=CTOD("01/"+STRZERO(m_month,2)+"/99")
  fd1->mnt:=mnt_dtod(fd1->ddoc)
  fd1->vnuma:=fvnum->vnuma
  fvnum->vnuma := fvnum->vnuma +1
  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    IF fl1->sum3<>0
      fd2->(DBAP())
      fd2->vnuma:=fd1->vnuma
      fd2->tabn:=fl1->tabn
      fd2->sum:=fl1->sum3
    ENDIF
   fl1->(DBSKIP())
  ENDDO
  CLOSE base fd1,fd2,fvnum
SAVEPAR(1)
return .t.


Function ListUder(m_month)
  LOCAL m_gauge1,m_sum1,m_sum2,m_endpage,m_num:=1,i,m_page
  LOCAL l_finish:=.f.
  SAVEPAR()
m_gauge1:=InitGauge("Вивiд вiд. на ковбасу",2)
select fl1
SET FILTER TO fl1->sum3<>0
fl1->(DBGOTOP())
i:=1
SET PRINTER TO ("uder.txt")
SET DEVICE TO PRINTER
SETPRC(0,0)
m_page:=1
m_endpage:=GetEndPage()
m_sum1:=m_sum2:=0
DO WHILE .NOT.fl1->(EOF()).AND..NOT.l_finish
  IF PROW()==0
    @0,0  SAY DATE()
    @0,40 SAY  'Вiдомiсть утримань  за ковбасу за ' + NTOCMONTH(m_month)
    @0,100  SAY  'Лист   N   ' + STRZERO( m_page, 3 )
    m_page++
    @1,0  SAY  '┌───┬─────┬─────────────────┬────────┬────────┬─────────┬────────┬─────────┬────────┬─────────┬────────┬─────────┐'
    @2,0  SAY  '│ N │Таб. │                 │Загальна│Одержано│Розпис   │Одержано│Розпис   │Одержано│Розпис   │Одержано│Розпис   │'
    @3,0  SAY  '│п/п│ ний │   Ф.I.Б.        │ Сума   │        │   в     │        │   в     │        │   в     │        │   в     │'
    @4,0  SAY  '│   │номер│                 │ (грв.) │        │одержаннi│        │одержаннi│        │одержаннi│        │одержаннi│'
    @5,0  SAY  '└───┴─────┴─────────────────┴────────┴────────┴─────────┴────────┴─────────┴────────┴─────────┴────────┴─────────┘'
    m_sum1:=0
//    m_num:=1
  ENDIF
@PROW()+1,0 SAY "I"
@PROW(),37 SAY "I"
@PROW(),46 SAY "I"
@PROW(),56 SAY "I"
@PROW(),65 SAY "I"
@PROW(),75 SAY "I"
@PROW(),84 SAY "I"
@PROW(),94 SAY "I"
@PROW(),103 SAY "I"
// @PROW(),113 SAY "I"
@PROW()+1,0 SAY "I"
@PROW(),1 SAY m_num PICTURE "999"
m_num++
@PROW(),5 SAY fl1->tabn
Sp10->(DS(fl1->tabn))
@PROW(), 11 SAY  LEFT(ALLTRIM(sp10->fam)+' '+LEFT(sp10->imja,1)+'.'+left(sp10->otch,1)+".",16)
@PROW(),29 SAY  SumToStr(fl1->sum3,7,,",")
@PROW(),37 SAY "I"
@PROW(),38 SAY "........"
@PROW(),46 SAY "I"
@PROW(),47 SAY "........"
@PROW(),56 SAY "I"
@PROW(),57 SAY "........"
@PROW(),65 SAY "I"
@PROW(),66 SAY "........"
@PROW(),75 SAY "I"
@PROW(),76 SAY "......."
@PROW(),84 SAY "I"
@PROW(),85 SAY "......."
@PROW(),94 SAY "I"
@PROW(),95 SAY "......."
@PROW(),103 SAY "I"
@PROW(),104 SAY "......."
m_sum1+=fl1->sum3
m_sum2+=fl1->sum3
IF INKEY()==K_ESC
  IF ANSWERu("Прервати вивiд?")==YES
    l_finish:=.t.
    EXIT
  ENDIF
ENDIF
fl1->(DBSKIP())
  IF PROW()>=m_endpage-4.OR.fl1->(EOF())
      @PROW()+2,0 SAY "РАЗОМ ПО СТОРIНЦI"
      @PROW(),24 SAY SumToStr(m_sum1,12,,",")
      @PROW()+1,0 SAY NumToChar(INT(m_sum1))+'  грв.  ' + STRZERO( (m_sum1 - INT(m_sum1))*100,2) + ' коп.'
      m_sum1:=0
      IF fl1->(EOF())
        @PROW()+2,0 SAY "РАЗОМ ПО ВIДОМОСТI"
        @PROW(),54 SAY SumToStr(m_sum2,12,,",")
        @PROW()+1,0 SAY NumToChar(INT(m_sum2))+'  грв.  ' + STRZERO( (m_sum2 - INT(m_sum2))*100,2) + ' коп.'
        @prow()+1,0   SAY  'Контролер______________________          Керiвник      ___________________'
        @PROW()+1,0   SAY  '                                         Гол. бухгалтер___________________'
        StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
        SETPRC(0,0)
        @0, 0          SAY      REPLICATE('_',75)
        @1, 0      SAY      DATE()
        @1, 75    SAY      'Лист 0'
        @ 3, 61   SAY      ' Форма Т-53'
        @ 5,10       SAY      'Пiдприємство '+  p_npr
        @ 7,10       SAY      'В магазин      '
        @ 9, 10      SAY      'з_____по_______________19    року '
        @ 11, 10      SAY      'В сумi'
        @ 11, 10 +9   SAY  NumToStr( INT(m_sum2) ) + '  грв.  ' + STRZERO( (m_sum2 - INT(m_sum2))*100,2) + ' коп.'
        @ 15, 10      SAY      'Керiвник           ________________ '
        @ 17, 10      SAY      'Головний бухгалтер ________________'
        @  25, 10 + 25 SAY      'BIДOMICTЬ N 1'
        @  27, 10+26   SAY  "За "+NTOCMONTH(m_month)+" мiсяць "
        @  32, 10      SAY      'По даннiй вiдомостi'
        @  34, 10      SAY      'Видано продукцiї ____________________________________'
        @  36, 10      SAY      '                 ________________________(_____грв. ____коп)'
        @  38, 10      SAY      'И невидано       ________________________________________'
        @  40, 10      SAY      '                 ________________________(_____грв._____коп)'
        @  42, 10      SAY      'Видачу  виконав    ________________'
        @  44, 10      SAY      'Перевiрiв бухгалтер ________________ '
        @  46, 10      SAY      'Накладна     ______вiд_____________________19   року'
        @  50, 10      SAY      'Kiлькiсть листiв'
        @  50,10+19    SAY       m_page-1
        m_sum2:=0;m_num:=1;m_page:=1
       ENDIF
      StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
      SETPRC(0,0)
    ENDIF
m_gauge1:=DispGauge(m_gauge1,i++/fl1->(LASTREC()))
ENDDO
SET PRINTER TO
SET DEVICE TO SCREEN
DelGauge(m_gauge1)
SPOOLADD("uder.txt")
SAVEPAR(1)
RETURN .t.
