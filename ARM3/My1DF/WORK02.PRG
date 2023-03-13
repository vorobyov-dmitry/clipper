#include "new.ch"
#include "menu.ch"
#define K_ALT_T         276     // Alt-T
MEMVAR a_menu,m_workpath,m_sprpath
Function Work02
  LOCAL m_browse,i,j,n,m_screen,m_poisk
  LOCAL GetList:={},m_num:=a_menu[1],m_rr,m_cc,m_kod,m_key,l_delete:=.t.
  LOCAL m_sum1,m_sum2,m_sum3,m_sum4,m_sum5,m_sum6,m_poisk2,m_recno
  LOCAL m_sum7,m_sum8,m_sum9,m_sum10,m_sum11,m_sum12,k,s_files:={},m_block,m_buf
  LOCAL a_sum:={},m_tin,m_path1
  DCL MENU
  IF .NOT.FILE(m_workpath+"kvart"+m_num+".dbf")
    DispError("Не знайдено файла з данними;за "+m_num+" квартал")
    RETURN .f.
  ENDIF
//  Sopenfiles("SP10",@s_files)
  IF FILE(m_sprpath+"SP10.DBF")
    NET USE (m_sprpath+"SP10") INDEX (m_sprpath+"SP10") NEW
  ELSE
    DispError("Не знайден доiдник працiвникiв")
  ENDIF
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_rr:=PADR(RESTVAR1("m_rr","DR"),2)
  m_cc:=PADR(RESTVAR1("m_cc","DR"),2)
  m_path1:=ALLTRIM(RESTVAR1("m_path1","DR"))
  CLOSE myvar
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE+ ' ' COLOR "W/B"
  @0,10 SayDisp "Форма 8 - ДР за " +m_num+" квартал" COLOR "n/w"
  @1,2 SayDisp "Пiдприємство"  COLOR "w/b"
  @2,2 SayDisp "Податкова"  COLOR "w/b"
  @3,2 SayDisp "Довiдка за "  COLOR "w/b"
  @4,2 SayDisp "Працювало у штатi "  COLOR "w/b"
  @5,2 SayDisp "Працювало за сум. "  COLOR "w/b"

  USE (m_workpath+"zag"+m_num) ALIAS zag NEW
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW
  INDEX ON fl1->tabn+STR(fl1->ozn_dox,2)     TO (m_workpath+"kvart"+m_num+"a")
  INDEX ON fl1->fam+STR(fl1->ozn_dox,2)     TO (m_workpath+"kvart"+m_num+"b")
  INDEX ON fl1->tin+STR(fl1->ozn_dox,2)     TO (m_workpath+"kvart"+m_num+"c")
  CLOSE
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW INDEX (m_workpath+"kvart"+m_num+"a"),(m_workpath+"kvart"+m_num+"b"),(m_workpath+"kvart"+m_num+"c")
      m_browse:=TBrowseDB(6,1,MAXROW()-1,MAXCOL()-1)
      m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
      m_browse:goTopBlock    := { ||  DBGOTOP()  }
    t1(@m_browse)
    m_browse:freeze        :=2
    ADD MENU UP_DOWN
    ADD MENU SEARCH
    ADD MENU LEFT_RIGHT
    ADD MENU NAME "Обробка" ITEMS {" Виправлення Enter","Видалення Delete","Вставка Insert","Розподiл"} KEY ;
    {K_ENTER,K_DEL,K_INS,K_ALT_T}
    ADD MENU NAME "Iнше" ITEMS {" Пiдсумок Alt+S","Друк F2","Копiя на дiскету F5","Копiя на дiск Alt+F5","Експорт до Арму Ctrl+F5"} KEY ;
    {K_ALT_S,K_F2,K_F5,K_ALT_F5,K_CTRL_F5}

    INIT MENU
    SayShp()
  DO WHILE .t.
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},EVAL(m_browse:GetColumn(1):colorBlock))
    m_key:=0
    keyboard ""
    DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
    ENDDO
    IF m_browse:stabilize()
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{6,6})
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},{2,2})
    ENDIF
    IF m_key==0
      m_key:=INKEY(0)
    ENDIF
    DEAL MENU
    DO CASE
      CASE m_key==K_F2.AND.ANSWERu("Друкувати звiт?")==YES
//         Print01(m_num)
      CASE m_key==K_ESC.AND.ANSWERu("Завершити программу?")==YES
          EXIT
      CASE m_key==K_DEL.AND.ANSWERu("Видалити строку?")==YES
        DBDELETE()
        DBSKIP()
        IF EOF()
          DBSKIP(-1)
          m_browse:RowPos:=MAX(1,m_browse:RowPos-1)
          m_browse:configure()
        ENDIF
        m_browse:RefreshAll()
      DEAL BROWSE m_browse KEY m_key
      CASE m_key==K_TAB
         GetZag()
         SayShp()
      CASE m_key==K_ENTER
        SET ESCAPE ON
        m_block:=m_browse:GetColumn(m_browse:colPos)
        m_buf:=EVAL(m_block:block)
        STABILIZE BROWSE m_browse
        @ROW(),COL() GET m_buf  COLOR "gr+/n"
        READ
        EVAL(m_block:block,m_buf)
        m_browse:RefreshCurrent()
      CASE m_key==K_INS.AND.ANSWERu("Вставити строку?")==YES
        DBINSERT()
        SavePar()
        SET ESCAPE OFF
        SET CURSOR ON
        @8,5,19 ,75 BOX B_SINGLE+" " COLOR "w/bg"
        @9,7 SayDisp "Iдентифiкацiйний номер>" COLOR "n/bg"
        @10,7 SayDisp "Таб. номер>" COLOR "n/bg"
        @11,7 SayDisp "Ф.I.Б .>" COLOR "n/bg"
        @12,7 SayDisp "Сума нарахов. доходу>" COLOR "n/bg"
        @13,7 SayDisp "Сума нарахов. податку>" COLOR "n/bg"
        @14,7 SayDisp "Сума виплаченого доходу>" COLOR "n/bg"
        @15,7 SayDisp "Сума податку>" COLOR "n/bg"
        @16,7 SayDisp "Ознака доходу>" COLOR "n/bg"
        @17,7 SayDisp "Ознака пiльги>" COLOR "n/bg"
        @9,35 Get fl1->tin  COLOR "w+/bg,gr+/n"
        @10,35 Get fl1->tabn COLOR "w+/bg,gr+/n"
        @11,35 Get fl1->Fio  COLOR "w+/bg,gr+/n"
        @12,35 Get fl1->s_nar COLOR "w+/bg,gr+/n"
        @13,35 Get fl1->s_taxn COLOR "w+/bg,gr+/n"
        @14,35 Get fl1->s_dox COLOR "w+/bg,gr+/n"
        @15,35 Get fl1->s_taxp COLOR "w+/bg,gr+/n"
        @16,35 Get fl1->ozn_dox COLOR "w+/bg,gr+/n"
        @17,35 Get fl1->ozn_pilg COLOR "w+/bg,gr+/n"
        READ
        SET CURSOR OFF
        SavePar(1)
        m_browse:RefreshAll()
/*
      CASE m_key==K_ALT_T.AND.ANSWERu("Распределять;суму подоходного?")==YES
            SavePar()
        SET ESCAPE ON
        SET CURSOR ON
m_sum1:=0
        @8,5,19 ,75 BOX B_SINGLE+" " COLOR "w/bg"
        @14,7 SayDisp "Cума подоходного>" COLOR "n/bg"
        @14,35 Get m_sum1 PICTURE "9999999.99" COLOR "w+/bg,gr+/n"
read
IF LASTKEY()<>K_ESC
        DBGOTOP()
       m_sum10a:=m_sum11a:=0
        DO WHILE .NOT.EOF()
        m_sum10a+=fl1->s_dox3
        m_sum11a+=fl1->s_tax3
        DBSKIP()
        ENDDO
m_koef = m_sum1/m_sum11a
        DBGOTOP()
        DO WHILE .NOT.EOF()
fl1->s_tax2:=m_koef*fl1->s_tax3
    fl1->s_dox2:=fl1->s_dox3 + fl1->s_tax2
        DBSKIP()
        ENDDO

ENDIF
        SavePar(1)
        m_browse:RefreshAll()

*/


      CASE m_key==K_ALT_S.AND.ANSWERu("Подрахувати ;контрольну суму?")==YES
            SavePar()
          IF INDEXORD()<>3
            SET ORDER TO 3
          ENDIF
            DBGOTOP()
            Zag->kvo1:=0
            Zag->kvo2:=0
        @7,5,19 ,75 BOX B_SINGLE+" " COLOR "w/bg"
        @8,7 SayDisp  "Кiлькiсть рядкiв----------------->" COLOR "n/bg"
        @9,7 SayDisp  "Кiлькiсть платникiв-------------->" COLOR "b/bg"
        @10,7 SayDisp "Кiлькiсть сумiсникiв------------->" COLOR "n/bg"
        m_sum1:=m_sum2:=m_sum3:=m_sum4:=m_sum5:=m_sum6:=0
        m_sum7:=m_sum8:=m_sum9:=m_sum10:=m_sum11:=m_sum12:=0
        m_tin:="#####"
        a_sum:={}
 // SET PRINTER TO (m_workpath+"02.txt")
 // SET CONSOLE OFF
 // SET PRINTER ON

        DO WHILE .NOT.EOF()
   //       ?"======================"
   //       ?"fl1->ozn_dox",fl1->ozn_dox
          i:=ASCAN(a_sum,{|x|x[1]==fl1->ozn_dox})
//          ?"i:=",i
          IF i==0
            AADD(a_sum,{fl1->ozn_dox,0,0,0,0})
            i:=LEN(a_sum)
          ENDIF

        a_sum[i,2]+=fl1->s_nar
        a_sum[i,3]+=fl1->s_dox
        a_sum[i,4]+=fl1->s_taxn
        a_sum[i,5]+=fl1->s_taxp
        m_sum1++
        IF (m_tin<>fl1->tin)
          m_tin:=fl1->tin
          IF fl1->kpn=="4".OR.fl1->kpn=="6"
            m_sum3++
          ENDIF
          m_sum2++
        ENDIF
        DBSKIP()
        ENDDO
        @8,42 SayDisp  SumToStr(m_sum1)   COLOR "w+/bg"
        @9,42 SayDisp  SumToStr(m_sum2)   COLOR "w+/bg"
        @10,42 SayDisp  SumToStr(m_sum3)   COLOR "w+/bg"
            Zag->kvo1:=m_sum2
            Zag->kvo2:=m_sum3
        ASORT(a_sum,{|x,y|x[1]<y[1]})
        @11,7 SayDisp "_____________________________________________________" COLOR "b/bg"
        @12,7 SayDisp "I КОД I   Нарах.  I   Випл.   I Приб нар I Приб утр I" COLOR "b/bg"
        @13,7 SayDisp "-----------------------------------------------------" COLOR "b/bg"
        m_sum1:=m_sum2:=m_sum3:=m_sum4:=m_sum5:=m_sum6:=0
        FOR i:=1 TO LEN(a_sum)
          @13+i,7 SAY "I"   COLOR "w+/bg"
          @13+i,7+2 SAY a_sum[i,1] PICTURE "99"   COLOR "GR+/bg"
          @13+i,7+6 SAY "I"   COLOR "w+/bg"
          @13+i,7+7 SAY SumToStr(a_sum[i,2],11)   COLOR "w+/bg"
          @13+i,7+18 SAY "I"   COLOR "w+/bg"
          @13+i,7+19  SAY SumToStr(a_sum[i,3],11)   COLOR "w+/bg"
          @13+i,7+30 SAY "I"   COLOR "w+/bg"
          @13+i,7+31  SAY SumToStr(a_sum[i,4],10)   COLOR "w+/bg"
          @13+i,7+41 SAY "I"   COLOR "w+/bg"
          @13+i,7+42  SAY SumToStr(a_sum[i,5],10)   COLOR "w+/bg"
          @13+i,7+52 SAY "I"   COLOR "w+/bg"
        m_sum1+=a_sum[i,2]
        m_sum2+=a_sum[i,3]
        m_sum3+=a_sum[i,4]
        m_sum4+=a_sum[i,5]
          NEXT
        i:=LEN(a_sum)+2
        @14+LEN(a_sum),7 SayDisp "=====================================================" COLOR "b/bg"
          @13+i,7 SAY "II"   COLOR "w+/bg"
          @13+i,7+1 SAY "РАЗОМ"   COLOR "GR+/bg"
          @13+i,7+6 SAY "I"   COLOR "w+/bg"
          @13+i,7+7 SAY SumToStr(m_sum1,11)   COLOR "w+/bg"
          @13+i,7+18 SAY "I"   COLOR "w+/bg"
          @13+i,7+19  SAY SumToStr(m_sum2,11)   COLOR "w+/bg"
          @13+i,7+30 SAY "I"   COLOR "w+/bg"
          @13+i,7+31  SAY SumToStr(m_sum3,10)   COLOR "w+/bg"
          @13+i,7+41 SAY "I"   COLOR "w+/bg"
          @13+i,7+42  SAY SumToStr(m_sum4,10)   COLOR "w+/bg"
          @13+i,7+52 SAY "I"   COLOR "w+/bg"
          i++
        @13+i,7 SayDisp "======================================================" COLOR "b/bg"
//  SET CONSOLE ON
//  SET PRINTER OFF
//  SET PRINTER TO

        INKEY(0)
        SavePar(1)
        SayShp()
          IF INDEXORD()<>1
            SET ORDER TO 1
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          ENDIF
      CASE m_key==K_F5
        IF ANSWERu("Робити копiю на дискету?")==YES
          T2(m_num)
        ENDIF
      CASE m_key==K_ALT_F5
        IF ANSWERu("Робити копiю на диск?")==YES
          T2(m_num,1)
        ENDIF
      CASE m_key==K_CTRL_F5
        IF ANSWERu("Експортувати до Арм податкової?")==YES
           IF FILE(m_path1+"physpe~1.dbf")
            IF (file(m_path1+"1df.dbf"))
              FERASE(m_path1+"1df.dbf")
            ENDIF
           T2(m_num,2)
           FILECOPY(m_workpath+"fl2.dbf",m_path1+"1df"+m_num+".dbf")
            SavePar()
            USE  (m_path1+"physpe~1") ALIAS p10 NEW
            INDEX ON p10->num TO (m_workpath+"p10")
      SET DATE format "dd.mm.yyyy"
            fl1->(DBGOTOP())
            DO WHILE .NOT.fl1->(EOF())
              IF .NOT.p10->(DS(fl1->tin))
                IF (sp10->(DS(fl1->tabn)))
                  p10->(DBAP())
                  p10->code:=VAL(sp10->tabn)
                  p10->name:=dostowin(ALLTRIM(sp10->fam)+" "+ALLTRIM(sp10->imja)+" "+ALLTRIM(sp10->otch))
                  p10->num:=sp10->codn
                  p10->birthdate:=TRANSFORM(sp10->drog,"@D")
                ENDIF
              ENDIF
              fl1->(DBSKIP())
            ENDDO
           SavePar(1)
           SELE fl1
            //
        ELSE
          DispError("Не знайдено директорiї ;["+m_path1+"];  з данними;АРМ 1-ДФ")
        ENDIF
        ENDIF
       SCAN BROWSE   m_browse KEY m_key
       RANGE BROWSE  m_browse KEY m_key
       SEARCH BROWSE m_browse KEY m_key
       CONTINUE SEARCH BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_1
          IF INDEXORD()<>1
            SET ORDER TO 1
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          ENDIF
      CASE m_key==K_ALT_2
          IF INDEXORD()<>2
            SET ORDER TO 2
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          ENDIF
      CASE m_key==K_ALT_3
          IF INDEXORD()<>3
            SET ORDER TO 3
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          ENDIF
    ENDCASE
  ENDDO



//  Sclosefiles(@s_files)
  IF SELECT("SP10")<>0
    Close sp10
  ENDIF
  CLOSE base fl1,zag

RETURN .f.
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
Function t1(m_browse)
  LOCAL a_col:={;
  {COLBR(fl1->tin),"Iдентиф.;номер"},;
  {COLBR(fl1->tabn),"Таб.;ном."},;
  {COLBR(fl1->fam),"      Ф.I.Б.  "},;
  {COLBR(fl1->s_nar),"Сума  ;нарах.;доходу"},;
  {COLBR(fl1->s_dox),"Сума  ;випл.;доходу"},;
  {COLBR(fl1->sum_ved),"Сума  ;випл.;по вiдомoстi"},;
  {COLBR(fl1->s_taxn),"Сума  ;нарах.;под."},;
  {COLBR(fl1->s_taxp),"Сума  ;випл.;под."},;
  {COLBR(fl1->ozn_dox),"Озн.;дох."},;
  {COLBR(fl1->d_priyn),"Дата ;прийняття"},;
  {COLBR(fl1->d_zviln),"Дата ;звiльнення"},;
  {COLBR(fl1->ozn_pilg),"Озн.;пiльги"}},i,n,m_col
  n:=LEN(a_col)
  FOR i:=1 TO n
      m_Col           := TBColumnNew()
      m_col:block:=a_col[i][1]
      m_col:heading:=a_col[i][2]
      m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─"
      m_col:colsep:="│"
      m_browse:addColumn(m_col)
  NEXT
RETURN .t.
STATIC Function Print01(m_num)
LOCAL i:=1,m_sum1:=0,m_sum2:=0,m_sum3:=0,m_page:=1,m_people:=0
LOCAL m_sum1a:=0,m_sum2a:=0,m_sum3a:=0

LOCAL s_kvart,l_f1,m_tin:="?????????"
SavePar()
DO CASE
  CASE m_num=="1"
    s_kvart:="I"
  CASE m_num=="2"
    s_kvart:="II"
  CASE m_num=="3"
    s_kvart:="III"
  CASE m_num=="4"
    s_kvart:="IV"
ENDCASE
DBGOTOP()
SET PRINTER TO (m_workpath+"dovidka.txt")
SET DEVICE TO PRINTER
SETPRC(0,0)
@PROW()+1,0 Say CHR(27)+"M"
@PROW()+1,0 Say "Вiдмiтка про одержання:"
@PROW()+1,0 Say " (вхiдний N,дата, штамп ДПI)                   Затверджено наказом ДПА України"
@PROW()+1,0 Say "┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐                вiд  30 грудня 1997 р. N 473"
@PROW()+1,0 Say TrCod(zag->kod,10)+"                (в редакцiї наказу ДПА України"
@PROW()+1,0 Say "└──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘                вiд 06.01)99р. N 10)"
@PROW()+1,0 Say "(iдентифiкацiйний номер за ЄДРПОУ"
@PROW()+1,0 Say "або реєстрацiйний (облiковий) номер            Зареєстровано в Мiн'юстi України"
@PROW()+1,0 Say "платника податкiв )                            15.03.99 р. за N 163/3456"
@PROW()+1,0 Say CHR(27)+"M"
@PROW()+1,0 Say "                            Форма N 8 ДР"
@PROW()+1,0 Say "                               ДОВIДКА"
@PROW()+1,0 Say "     про суми виплачених доходiв i утриманих з них податкив фiзичних осiб"
@PROW()+1,0 Say PADC(ALLTRIM(Zag->name),75)
@PROW()+1,0 Say "       (назва юридичної особи чи прiзвище, по батькоi фiзичної особи - суб'єкта пiдприємницької дiяльностi"
@PROW()+1,0 Say CHR(18)
@PROW()+1,0 Say ""
@PROW()+1,0 Say "┌──┬──┬──┬──┬──┬──┬──┬──┐"
@PROW()+1,0 Say TrCod(zag->kod1,8)+ "           "+ALLTRIM(zag->name1)
@PROW()+1,0 Say "└──┴──┴──┴──┴──┴──┴──┴──┘"
@PROW()+1,0 Say "(iдентифiкацiйний код державного податкового органу) (назва державного податкового органу, де зареєстрована юридична чи фiзична особа)"
@PROW()+1,0 Say chr(18)
@PROW()+1,0 Say "                           ЗА "+zag->period
@PROW()+1,0 Say "                                                            ┌────┐"
@PROW()+1,0 Say "Працювало у штатi         "+STR(zag->kvo1,5)+"                             │    │"
@PROW()+1,0 Say "Працювало за сумiсництвом "+STR(zag->kvo2,5)+"            Порцiя  N        ├────┤"
@PROW()+1,0 Say "                                                            │    │"
@PROW()+1,0 Say "                                                            └────┘"+CHR(27)+CHR(15)
@PROW()+1,0 Say "                                                                             Аркуш   1"

SayShp08()
l_f1:=.t.
DO WHILE .NOT.EOF()
  IF l_f1
@PROW()+1,0 Say ;
"├────┼─┬─┬─┬─┬─┬─┬─┬─┬─┬─┼───────────┼───────────┼────────────┼────────────┼────┼───────────┼──────────┼───────┤"
l_f1:=.f.
ELSE
@PROW()+1,0 Say ;
"├────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼───────────┼───────────┼────────────┼────────────┼────┼───────────┼──────────┼───────┤"

ENDIF

  @PROW()+1,0 Say "│"
  @PROW(),1 Say i PICTURE "9999"
  @PROW(),5 Say trkod1(fl1->tin,10)
  @PROW(),26 Say fl1->s_dox PICTURE "99999999.99"
  @PROW(),37 Say "│"
  @PROW(),38 Say fl1->s_dox2 PICTURE "99999999.99"
  @PROW(),49 Say "│"
  @PROW(),50 Say fl1->s_tax PICTURE "99999999.99"
  @PROW(),62 Say "│"
  @PROW(),63 Say fl1->s_tax2 PICTURE "99999999.99"
  @PROW(),75 Say "│"
  @PROW(),77 Say fl1->ozn_dox
  @PROW(),80 Say "│"
  IF .NOT.EMPTY(fl1->d_priyn)
    @PROW(),81 Say fl1->d_priyn
  ENDIF
  @PROW(),92 Say "│"
  IF .NOT.EMPTY(fl1->d_zviln)
    @PROW(),93 Say fl1->d_zviln
  ENDIF
  @PROW(),103 Say "│"
  @PROW(),105 Say fl1->ozn_pilg
  @PROW(),111 Say "│"

  m_sum1+=fl1->s_dox
  m_sum2+=fl1->s_tax
  m_sum1a+=fl1->s_dox2
  m_sum2a+=fl1->s_tax2
  i++
  IF m_tin<>fl1->tin
    m_people++
    m_tin:=fl1->tin
  ENDIF
  dbSKIP()
  IF PROW()>60.AND..NOT.EOF()
    @PROW()+1,0 Say ;
    "└────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴───────────┴───────────┴────────────┴────────────┴────┴───────────┴──────────┴───────┘"
    m_page++
    @0,0 Say ;
    "                                                                             Аркуш "+STR(m_page,3)
    SayShp08()
    l_f1:=.t.
  ENDIF
ENDDO
@PROW()+1,0 Say ;
"├────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼───────────┼───────────┼────────────┼────────────┼────┼───────────┼──────────┼───────┤"
  @PROW()+1,0 Say "│"
  @PROW(),1 Say " X  "
  @PROW(),5 Say "│ │ │ │ │X│ │ │ │ │ │"


  @PROW(),26 Say m_sum1 PICTURE "99999999.99"
  @PROW(),37 Say "│"
  @PROW(),38 Say m_sum1a PICTURE "99999999.99"
  @PROW(),49 Say "│"
  @PROW(),50 Say m_sum2 PICTURE "99999999.99"
  @PROW(),62 Say "│"
  @PROW(),63 Say m_sum2a PICTURE "99999999.99"
  @PROW(),75 Say "│"
  @PROW(),77 Say " X"
  @PROW(),80 Say "│"
  @PROW(),82 Say "   X"
  @PROW(),92 Say "│"
  @PROW(),94 Say "   X"
  @PROW(),103 Say "│"
  @PROW(),105 Say " X"
  @PROW(),111 Say "│"



@PROW()+1,0 Say ;
    "└────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴───────────┴───────────┴────────────┴────────────┴────┴───────────┴──────────┴───────┘"

@PROW()+2,0 Say CHR(18)+"Кiлькiсть рядкiв "+STR(i-1,4)+"        Кiлькiсть фiзичних осiб  "+STR(m_people,4)+"       Кiлькiсть аркушiв "+STR(m_page,3)
@PROW()+1,0 Say ;
CHR(27)+"P"+CHR(27)+CHR(15)+"                            ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐"
@PROW()+1,0 Say ;
"Керiвник пiдприємства       "+    TrCod(zag->id1,10)+"                  "+LEFT(zag->fam1,15)+"   "+zag->tel1
@PROW()+1,0 Say ;
"                            └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘    -------------  ------------------   ----------  ┌─────────────┐"
@PROW()+1,0 Say ;
"                                                          (пiдпис)            (прiзвище)            (тел.)     │ Дата подання│"
@PROW()+1,0 Say ;
"                            ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐                                                    └─────────────┘"
@PROW()+1,0 Say ;
"М. П.   Головний бухгалтер  "+TrCod(zag->id2,10)+"                   "+LEFT(zag->fam2,15)+"   "+zag->tel2
@PROW()+1,0 Say ;
"                            └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘    -------------  ----------------   ----------  ┌─────────────┐"
@PROW()+1,0 Say ;
"                                                          (пiдпис)            (прiзвище)            (тел.)   │ Наведена    │"
@PROW()+1,0 Say ;
"                                                                                                             │ iнформацiя є│"
@PROW()+1,0 Say ;
"                                                                                                             │  вiрною     │"
@PROW()+1,0 Say ;
"                                                                                                             └─────────────┘"
@PROW()+1,0 Say ;
CHR(27)+CHR(18)
@PROW()+1,0 Say ""

SET DEVICE TO SCREEN
SET PRINTER TO
IF SPOOLACTIV()
  SPOOLADD(m_workpath+"DOVIDKA.TXT")
ELSE
  WaitMessage("Друкування у фоновому режимi неможливо")
  PrintFile(m_workpath+"DOVIDKA.TXT",.t.)
ENDIF
SavePar(1)
RETURN .t.

// export to medok

STATIC FUnction T2(m_num,m_x)
LOCAL a_struct:={;
{"NP","N",5,0},;
{"PERIOD","N",2,0},;
{"RIK","N",4,0},;
{"KOD","C",10,0},;
{"TYP","N",1,0},;
{"TIN","C",10,0},;
{"S_NAR","N",12,2},;
{"S_DOX","N",12,2},;
{"S_TAXN","N",12,2},;
{"S_TAXP","N",12,2},;
{"OZN_DOX","N",2,0},;
{"D_PRIYN","D",8,0},;
{"D_ZVILN","D",8,0},;
{"OZN_PILG","N",2,0},;
{"OZNAKA","N",1,0}}
LOCAL m_sum1:=0,m_sum2:=0,m_sum3:=0,i:=0,m_kod,m_cc,m_rr,m_file,m_rik
LOCAL m_sum1a:=0,m_sum2a:=0
LOCAL m_y:=IF(EMPTY(m_x),0,m_x)
SAVEPAR()
USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
m_rr:=PADR(RESTVAR1("m_rr","DR"),2)
m_cc:=PADR(RESTVAR1("m_cc","DR"),2)
m_kod:=PADR(RESTVAR1("m_kod","DR"),10)
CLOSE myvar

DBCREATE(m_workpath+"Fl2",a_struct)
USE (m_workpath+"fl2") NEW
SELE fl1
SET ORDER TO 2
fl1->(DBGOTOP())
m_rik:=fl1->rik
DO WHILE .NOT.fl1->(EOF())
  fl2->(DBAP())
  i++
  fl2->np:=i
  fl2->period:=VAL(m_num)
  fl2->rik:=fl1->rik
  fl2->kod:=zag->kod
  fl2->typ:=0
  fl2->tin:=fl1->tin
  fl2->s_nar:=fl1->s_nar
  fl2->s_dox:=fl1->s_dox
  fl2->s_taxn:=fl1->s_taxn
  fl2->s_taxp:=fl1->s_taxp
  fl2->ozn_dox:=fl1->ozn_dox
  Fl2->d_priyn :=  fl1->d_priyn
  Fl2->d_zviln :=  fl1->d_zviln
  Fl2->ozn_pilg:=  fl1->ozn_pilg
  fl2->oznaka:=0
  m_sum1+=fl2->s_nar
  m_sum2+=fl2->s_taxn
  m_sum1a+=fl2->s_dox
  m_sum2a+=fl2->s_taxp
  fl1->(DBSKIP())
ENDDO
fl2->(DBAP())
fl2->np:=99991
fl2->tin:=zag->id1
fl2->s_dox:=VAL(CHARREM("-",zag->tel1))
fl2->period:=VAL(m_num)
fl2->rik:=m_rik
fl2->kod:=zag->kod
fl2->typ:=0
fl2->(DBAP())
fl2->np:=99992
fl2->tin:=zag->id2
fl2->s_dox:=VAL(CHARREM("-",zag->tel2))
fl2->period:=VAL(m_num)
fl2->rik:=m_rik
fl2->kod:=zag->kod
fl2->typ:=0

fl2->(DBAP())
fl2->np:=99999
fl2->period:=VAL(m_num)
fl2->rik:=m_rik
fl2->kod:=zag->kod
fl2->typ:=0
fl2->s_nar   :=m_sum1
fl2->s_dox   :=m_sum1a
fl2->s_taxn   :=m_sum2
fl2->s_taxp   :=m_sum2a
CLOSE FL2
m_file:="DA"+m_rr+m_cc+"01."+m_num
IF m_y==0
CopyFl(m_file)
ELSE
  IF m_y==1
    copydsk(m_file)
  ELSE
  IF m_y==2
//    FILECOPY(m_workpath+"fl2.dbf",c_disk+m1)
  ENDIF
  ENDIF
ENDIF
sele fl1
SET ORDER TO 1

SAVEPAR(1)
RETURN .t.
STATIC Function SayShp()
  @1,20 SayDisp Zag->kod COLOR "w+/b"
  @1,35 SayDisp Zag->name COLOR "w+/b"
  @2,20 SayDisp Zag->kod1 COLOR "w+/b"
  @2,35 SayDisp Zag->name1 COLOR "w+/b"
  @3,20 SayDisp Zag->period COLOR "w+/b"
  @4,20 SayDisp Zag->kvo1 COLOR "w+/b"
  @5,20 SayDisp Zag->kvo2 COLOR "w+/b"
RETURN .t.
STATIC Function GetZag()
  LOCAL GetList:={}
  @1,20 Get Zag->kod    COLOR "b/w,gr+/n"
  @1,35 Get Zag->name   COLOR "b/w,gr+/n"
  @2,20 Get Zag->kod1   COLOR "b/w,gr+/n"
  @2,35 Get Zag->name1  COLOR "b/w,gr+/n"
  @3,20 Get Zag->period COLOR "b/w,gr+/n"
  @4,20 Get Zag->kvo1   COLOR "b/w,gr+/n"
  @5,20 Get Zag->kvo2   COLOR "b/w,gr+/n"
  READ
RETURN .t.
STATIC Function TrCod(kod,n1)
  LOCAL m_str:="│",i,n:=IF(n1==NIL,LEN(kod),n1)
  FOR i:=1 TO n
    m_str+=" "+SUBSTR(kod,i,1)+"│"
  NEXT
  RETURN m_str
STATIC Function SayShp08()
@PROW()+1,0 Say "┌────┬───────────────────┬───────────┬───────────┬─────────────────────────┬────┬──────────────────────┬───────┐"
@PROW()+1,0 Say "│ N  │  Iдентифiкацiйний │Сума нара- │Сума випла-│Сума утриманого прибутко-│Оз- │        Дата          │Ознака │"
@PROW()+1,0 Say "│з/п │     номер         │хованого   │ ченого до-│   вого податку          │нака├───────────┬──────────┤пiльги │"
@PROW()+1,0 Say "│    │                   │ доходу    │  ходу     ├────────────┬────────────┤до- │прийняття  │звiльнення│щодо   │"
@PROW()+1,0 Say "│    │                   │(грн.,коп.)│(грн.,коп.)│нарахованого│перерахован.│ходу│на роботу  │ з роботи │приб.  │"
@PROW()+1,0 Say "│    │                   │           │           │(грн.,коп.) │(грн.,коп.) │    │           │          │податку│"
@PROW()+1,0 Say "├────┼───────────────────┼───────────┼───────────┼────────────┼────────────┼────┼───────────┼──────────┼───────┤"
@PROW()+1,0 Say "│  1 │      2            │      3а   │      3    │       4а   │       4    │ 5  │    6      │     7    │   8   │"
RETURN .t.
STATIC Function Trkod1(kod,n1)
  LOCAL m_str:="│",i,n:=IF(n1==NIL,LEN(kod),n1)
  FOR i:=1 TO n
    m_str+=SUBSTR(kod,i,1)+"│"
  NEXT
  RETURN m_str

Function GetDirectoryname()
  LOCAL a_disk:={"A:","C:","D:","E:"},m_key,i,n,m_browse1,m_browse2,m_str,m_col,L_delete:=.t.
  LOCAL m_disk:=DiskNAME(),c_file:="",m_state:=2,j
  LOCAL c_dir:=DIRNAME(m_disk),m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())
  LOCAL a_dir,a_file,n_file,n_disk,n_dir
  LOCAL a_str:={"-------"}
  SAVEPAR()
  IF c_dir=="\"
    c_dir:=""
  ENDIF
  a_dir:=DIRECTORY(m_disk+":"+c_dir+"\*.*","D")
  a_file:=DIRECTORY(m_disk+":"+c_dir+"\*.*")
  n_file:=1;n_dir:=1;n_disk:=0
  n:=LEN(a_dir)
  FOR i:=n TO 1 STEP -1
    IF a_dir[i,5]<>"D".OR.ALLTRIM(a_dir[i,1])=="."
      ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
    ENDIF
  NEXT
  a_dir:=MySort1(a_dir,1)
  a_file:=MySort2(a_file)
/*
  n:=NumDiskF()
 FOR i:=1 TO n
  m_str:=CHR(ASC("A")+i-1)+":"
  AADD(a_disk,m_str)
 NEXT
  n:=NumDiskL()
 FOR i:=1 TO n
  m_str:=CHR(ASC("C")+i-1)+":"
  IF DRIVETYPE(m_str)==3.OR.(DRIVETYPE(m_str)==0.AND.(DISKTYPE(m_str)==248.OR.DISKTYPE(m_str)==254))
    AADD(a_disk,m_str)
  ENDIF
 NEXT
  FOR i:=1 TO LEN(a_disk)
    IF LEFT(a_disk[i],1)==m_disk
//      @1,7 SayDisp a_disk[i] COLOR "w+/b"
      n_disk:=i
    ENDIF
  NEXT
IF n_disk==0
   n_disk:=LEN(a_disk)
ENDIF
*/
n_disk:=3
 m_browse1:=TbrowseNew(4,16,MAXROW()-2,58)
 m_col:=TBColumnNew()
 m_col:block:={||MyBlock1(a_file,n_file)}
 m_col:ColorBlock:={||{1,2}}
 m_browse1:ColorSpec:="bg+/b,n/w"
 m_browse1:GoBottomBlock:={||n_file:=LEN(a_file)}
 m_browse1:GotopBlock:={||n_file:=1}
 m_browse1:SkipBlock:={|x|SkipBr(x,@n_file,LEN(a_file))}
 m_browse1:AddColumn(m_col)
 m_browse1:AutoLite:=.f.
 m_browse2:=TbrowseNew(4,1,MAXROW()-2,15)
 m_col:=TBColumnNew()
 m_col:block:={||IF(LEN(a_dir)>0,PADR(a_dir[n_dir,1],12),"Дир-рий нет ")}
 m_col:ColorBlock:={||{1,2}}
 m_browse2:ColorSpec:="w/b,n/w"
 m_browse2:GoBottomBlock:={||n_dir:=LEN(a_dir)}
 m_browse2:GotopBlock:={||n_dir:=1}
 m_browse2:SkipBlock:={|x|SkipBr(x,@n_dir,LEN(a_dir))}
 m_browse2:AddColumn(m_col)

 @0,0,MAXROW(),60 Box  B_SINGLE+" " COLOR "w/b"
 @0,0 SayDisp PADC("Вибiр файлу",60) COLOR "B/W"
 @MAXROW(),1 SayText PADC("~1<"+CHR(26)+","+CHR(27)+">~2-переход,~1<Alt+F1>~2-выбор диска,~1<ENTER>~2-Выбор файла",70) COLOR "R/W,n/w"
 @1,2 SayDisp "Дiск:" COLOR "gr+/b"
 @1,8 SayDisp PADR(a_disk[n_disk],50) COLOR "w+/B"
 @3,4 SayDisp "Дiректорiя " COLOR "gr+/b"
 @3,26 SayDisp "Файли " COLOR "gr+/b"
  m_browse2:Autolite:=.f.
  m_browse2:Dehilite()
  m_browse2:refreshCurrent()
  STABILIZE BROWSE m_browse2
// DispDisk(a_disk,m_disk)
 @MAXROW()-1,2 SayDisp "Вибранний файл" COLOR "gr+/b"
 @2,2 SayDisp "Пот. дiректорiя " COLOR "gr+/b"
 @2,18 SayDisp UPPER(LEFT(a_disk[n_disk],1)+":"+IF(EMPTY(c_dir),"\",c_dir)) COLOR "w+/b"
 m_str:=""
 DO WHILE .t.
  DO CASE
    CASE m_state==1
      j:=n_disk
      DO WHILE .t.
      FOR i:=1 TO LEN(a_disk)
        IF i==n_disk
          @1,5+3*i SayDisp a_disk[i] COLOR "n/w"
        ELSE
          @1,5+3*i SayDisp a_disk[i] COLOR "w/b"
        ENDIF
      NEXT
      m_key:=INKEY(0)
      DO CASE
        CASE m_key==K_ESC
          n_disk:=j
          EXIT
        CASE m_key==K_ENTER
          EXIT
        CASE m_key==K_RIGHT
          n_disk:=IF(n_disk==LEN(a_disk),1,n_disk+1)
        CASE m_key==K_LEFT
          n_disk:=IF(n_disk==1,n_disk:=LEN(a_disk),n_disk-1)
      ENDCASE
      ENDDO
      @1,8 SayDisp PADR(a_disk[n_disk],50) COLOR "w+/B"
      IF m_key==K_ENTER
        IF DRIVETYPE(a_disk[n_disk])==2
          IF .NOT.WaitDisk(a_disk[n_disk])
            lOOP
          ENDIF
        ENDIF
          c_dir:=DIRNAME(LEFT(a_disk[n_disk],1))
          IF c_dir=="\"
            c_dir:=""
          ENDIF
         @2,18 SayDisp PADR(UPPER(LEFT(a_disk[n_disk],1)+":"+IF(EMPTY(c_dir),"\",c_dir)),42) COLOR "w+/b"
          a_dir:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*","D")
          a_file:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*")
          n_file:=1;n_dir:=1
          n:=LEN(a_dir)
          FOR i:=n TO 1 STEP -1
            IF a_dir[i,5]<>"D".OR.ALLTRIM(a_dir[i,1])=="."
              ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
            ENDIF
          NEXT
          a_dir:=MySort1(a_dir,1)
          a_file:=MySort2(a_file)
          m_browse1:RowPos:=1;m_browse1:configure()
          m_browse1:Autolite:=.f.;m_browse1:Dehilite()
          Stabilize Browse m_browse1
          m_browse2:RowPos:=1;m_browse2:configure()
          Stabilize Browse m_browse2
          IF .NOT.EMPTY(a_file)
            m_state:=2
          ELSE
            m_state:=2
          ENDIF
      ENDIF


    CASE m_state==2
      Display Browse m_browse2
      m_browse2:hilite()
      m_key:=INKEY(0)
      DO CASE
/*
      CASE m_key==K_TAB.OR.m_key==K_RIGHT.AND..NOT.EMPTY(a_file)
       m_state:=3
       m_browse2:Autolite:=.f.
       m_browse2:Dehilite()
       m_browse2:refreshCurrent()
       STABILIZE BROWSE m_browse2
*/
      DEAL BROWSE m_browse2 KEY m_key
/*
      CASE m_key==K_ALT_F1
       m_state:=1
       m_browse2:Autolite:=.f.
       m_browse2:Dehilite()
       m_browse2:refreshCurrent()
       STABILIZE BROWSE m_browse2
*/
      CASE m_key==K_ALT_F1
       m_state:=1
       m_browse2:Autolite:=.f.
       m_browse2:Dehilite()
       m_browse2:refreshCurrent()
       STABILIZE BROWSE m_browse2
      CASE m_key==K_CTRL_RET
        c_file:=UPPER(LEFT(a_disk[n_disk],1)+":"+c_dir)+"\"
        @MAXROW()-1,18 SayDisp c_file COLOR "GR+/N"
        IF inkey(0)==K_ENTER
          SAVEPAR(1)
          RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
          RETURN c_file
        ENDIF
        @MAXROW()-1,18 SayDisp BLANK(c_file,.t.) COLOR "w+/b"
        c_file:=""
      CASE m_key==K_ENTER
        IF a_dir[n_dir,1]==".."
          i:=RAT("\",c_dir)
          c_dir:=SUBSTR(c_dir,1,i-1)
        ELSE
          c_dir:=c_dir+"\"+UPPER(ALLTRIM(a_dir[n_dir,1]))
          // PutStr(@a_str,UPPER(ALLTRIM(a_dir[n_dir,1]))
          AADD(a_str,UPPER(ALLTRIM(a_dir[n_dir,1])))
        ENDIF
       @2,18 SayDisp PADR(UPPER(LEFT(a_disk[n_disk],1)+":"+IF(EMPTY(c_dir),"\",c_dir)),42) COLOR "w+/b"
        a_dir:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*","D")
        a_file:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*")
        n_file:=1;n_dir:=1
        n:=LEN(a_dir)
        FOR i:=n TO 1 STEP -1
          IF a_dir[i,5]<>"D".OR.ALLTRIM(a_dir[i,1])=="."
            ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
          ENDIF
        NEXT
        a_dir:=MySort1(a_dir,1)
        a_file:=MySort2(a_file)
        m_browse1:RowPos:=1;m_browse1:configure()
        m_browse1:Autolite:=.f.;m_browse1:Dehilite()
        Stabilize Browse m_browse1
        m_browse2:RowPos:=1
        IF (j:=ASCAN(a_dir,{|x|UPPER(x[1])==a_str[LEN(a_str)]}))<>0
            IF LEN(a_str)>2
              ADEL(a_str,LEN(a_str))
              ASIZE(a_str,LEN(a_str)-1)
            ENDIF

          n_dir:=j
          m_browse2:RowPos:=IF(j<=m_browse2:RowCount,j,m_browse2:RowCount)
        ENDIF
        m_browse2:configure()
      ENDCASE
    CASE m_state==3
      Display Browse m_browse1
      m_browse1:hilite()
      m_key:=INKEY(0)
      DO CASE
      CASE m_key==K_TAB.OR.m_key==K_LEFT
       m_state:=2
       m_browse1:Autolite:=.f.
       m_browse1:Dehilite()
       m_browse1:refreshCurrent()
       STABILIZE BROWSE m_browse1
      DEAL BROWSE m_browse1 KEY m_key
      CASE m_key==K_ALT_F1
       m_state:=1
       m_browse1:Autolite:=.f.
       m_browse1:Dehilite()
       m_browse1:refreshCurrent()
       STABILIZE BROWSE m_browse1
      CASE m_key==K_ENTER
        c_file:=UPPER(LEFT(a_disk[n_disk],1)+":"+c_dir)+"\"+LOWER(ALLTRIM(a_file[n_file][1]))
        @MAXROW()-1,18 SayDisp c_file COLOR "GR+/N"
        IF inkey(0)==K_ENTER
          SAVEPAR(1)
          RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
          RETURN c_file
        ENDIF
        @MAXROW()-1,18 SayDisp BLANK(c_file,.t.) COLOR "w+/b"
        c_file:=""
      ENDCASE
  ENDCASE
ENDDO
SAVEPAR(1)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
RETURN ""
STATIC FUnction T3(m_num)
GetDirectoryname()
RETURN ""

STATIC function MySort1(a_dir,j)
ASORT(a_dir,,,{|x,y|x[j]<y[j]})
RETURN a_dir

STATIC function MySort2(a_dir)
ASORT(a_dir,,,{|x,y|comp1(x[1],y[1])})
RETURN a_dir

STATIC fUnction comp1(x,y)
LOCAL m_str1,m_str2,i
IF (i:=AT(".",x))<>0
  m_str1:=PADR(SUBSTR(x,i+1),3)+PADR(SUBSTR(x,1,i-1),8)
ELSE
  m_str1:="   "+PADR(x,8)
ENDIF
IF (i:=AT(".",y))<>0
  m_str2:=PADR(SUBSTR(y,i+1),3)+PADR(SUBSTR(y,1,i-1),8)
ELSE
  m_str2:="   "+PADR(y,8)
ENDIF
IF m_str1<m_str2
  RETURN .t.
ENDIF
RETURN .f.

Static Function MyBlock1(a_file,n)
LOCAL m_str,i
IF EMPTY(a_file)
  RETURN PADC("Файлов нет",27)
ENDIF

m_str:=LOWER(a_file[n][1])
IF (i:=AT(".",m_str))<>0
  m_str:=PADR(SUBSTR(m_str,1,i-1),8)+"."+PADR(SUBSTR(m_str,i+1),3)
ELSE
  m_str:=PADR(m_str,12)
ENDIF
m_str+=" "+DTOC(a_file[n][3])+" "+STR(a_file[n][2],10)
RETURN m_str

Static Function SkipBr(x,i,n)
LOCAL j
IF x>0
  IF i+x<=n
    j:=x
  ELSE
    j:=n-i
  ENDIF
ELSE
  IF i+x>=1
    j:=x
  ELSE
    j:=1-i
  ENDIF
ENDIF
i+=j
RETURN j
EXTERNAL calcul

