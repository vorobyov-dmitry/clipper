 #include "new.ch"
#include "menu.ch"
#define K_ALT_T         276     // Alt-T
MEMVAR a_menu,m_workpath,m_sprpath
Function Work02
  LOCAL m_browse,i,j,n,m_screen,m_poisk
  LOCAL GetList:={},m_num:=a_menu[1],m_rr,m_cc,m_kod,m_key,l_delete:=.t.
  LOCAL m_sum1,m_sum2,m_sum3,m_sum4,m_sum5,m_sum6,m_poisk2,m_recno
  LOCAL m_sum7,m_sum8,m_sum9,m_sum10,m_sum11,m_sum12,k,s_files:={},m_block,m_buf
  DCL MENU
  IF .NOT.FILE(m_workpath+"kvart"+m_num+".dbf")
    DispError("Не знайдено файла з данними;за "+m_num+" квартал")
    RETURN .f.
  ENDIF
//  Sopenfiles("SP10",@s_files)
  IF FILE(m_sprpath+"SP10.DBF")
    NET USE (m_sprpath+"SP10") INDEX (m_sprpath+"SP10") NEW
  ENDIF
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_rr:=PADR(RESTVAR1("m_rr","DR"),2)
  m_cc:=PADR(RESTVAR1("m_cc","DR"),2)
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
  INDEX ON fl1->fio+STR(fl1->ozn_dox,2)     TO (m_workpath+"kvart"+m_num+"b")
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
    m_browse:freeze        := 4
    ADD MENU UP_DOWN
    ADD MENU SEARCH
    ADD MENU LEFT_RIGHT
    ADD MENU NAME "Обробка" ITEMS {" Виправлення Enter","Видалення Delete","Вставка Insert","Розподiл"} KEY ;
    {K_ENTER,K_DEL,K_INS,K_ALT_T}
    ADD MENU NAME "Iнше" ITEMS {" Пiдсумок Alt+S","Друк F2","Копiя на дiскету F5"} KEY ;
    {K_ALT_S,K_F2,K_F5}

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
         Print01(m_num)
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
        @12,35 Get fl1->s_dox COLOR "w+/bg,gr+/n"
        @13,35 Get fl1->s_tax COLOR "w+/bg,gr+/n"
        @14,35 Get fl1->s_dox2 COLOR "w+/bg,gr+/n"
        @15,35 Get fl1->s_tax2 COLOR "w+/bg,gr+/n"
        @16,35 Get fl1->ozn_dox COLOR "w+/bg,gr+/n"
        @17,35 Get fl1->ozn_pilg COLOR "w+/bg,gr+/n"
        READ
        SET CURSOR OFF
        SavePar(1)
        m_browse:RefreshAll()
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



      CASE m_key==K_ALT_S.AND.ANSWERu("Подрахувати ;контрольну суму?")==YES
            SavePar()
            DBGOTOP()
            Zag->kvo1:=0
            Zag->kvo2:=0
        @7,5,19 ,75 BOX B_SINGLE+" " COLOR "w/bg"
        @8,7 SayDisp  "Кiлькiсть рядкiв----------------->" COLOR "n/bg"
        @9,7 SayDisp  "Дохiд за основним мiсцем работи-->" COLOR "b/bg"
        @10,7 SayDisp "Дохiд за неосновним мiсцем работи>" COLOR "n/bg"
        @11,7 SayDisp "Матерiальна допомога------------->" COLOR "b/bg"
        @12,7 SayDisp "Дивiденти------------------------>" COLOR "n/bg"
        @13,7 SayDisp "Дохiд отр. через ком. торгiвлю--->" COLOR "b/bg"
        @14,7 SayDisp "Дохiд за договором оренди майна-->" COLOR "n/bg"
        @15,7 SayDisp "Суми на вiдшкодування шкоди------>" COLOR "b/bg"
        @16,7 SayDisp "Iнше----------------------------->" COLOR "b/bg"
        @17,7 SayDisp "Разом---------------------------->" COLOR "n/bg"
        @18,7 SayDisp "Сума податку--------------------->" COLOR "b/bg"
        m_sum1:=m_sum2:=m_sum3:=m_sum4:=m_sum5:=m_sum6:=0
        m_sum7:=m_sum8:=m_sum9:=m_sum10:=m_sum11:=m_sum12:=0
        m_sum1a:=m_sum2a:=m_sum3a:=m_sum4a:=m_sum5a:=m_sum6a:=0
        m_sum7a:=m_sum8a:=m_sum9a:=m_sum10a:=m_sum11a:=m_sum12a:=0

        DO WHILE .NOT.EOF()
          IF fl1->ozn_dox=2
            zag->kvo2++
          ELSE
            zag->kvo1++
          ENDIF
          m_sum1++
          DO CASE
            CASE fl1->ozn_dox=1
              m_sum2+=fl1->s_dox
              m_sum2a+=fl1->s_dox2
            CASE fl1->ozn_dox=2
              m_sum3+=fl1->s_dox
              m_sum3a+=fl1->s_dox2
            CASE fl1->ozn_dox=3
              m_sum4+=fl1->s_dox
              m_sum4a+=fl1->s_dox2
            CASE fl1->ozn_dox=4
              m_sum5+=fl1->s_dox
              m_sum5a+=fl1->s_dox2
            CASE fl1->ozn_dox=5
              m_sum6+=fl1->s_dox
              m_sum6a+=fl1->s_dox2
            CASE fl1->ozn_dox=6
              m_sum7+=fl1->s_dox
              m_sum7a+=fl1->s_dox2
            CASE fl1->ozn_dox=8
              m_sum8+=fl1->s_dox
              m_sum8a+=fl1->s_dox2
            OTHERWISE
              m_sum9+=fl1->s_dox
              m_sum9a+=fl1->s_dox2
          ENDCASE
         m_sum10+=fl1->s_dox
         m_sum11+=fl1->s_tax
         m_sum10a+=fl1->s_dox2
         m_sum11a+=fl1->s_tax2
        @8,42 SayDisp  SumToStr(m_sum1)+  SumToStr(m_sum1a)   COLOR "w+/bg"
        @9,42 SayDisp  SumToStr(m_sum2)+  SumToStr(m_sum2a)   COLOR "gr+/bg"
        @10,42 SayDisp SumToStr(m_sum3)+  SumToStr(m_sum3a)   COLOR "w+/bg"
        @11,42 SayDisp SumToStr(m_sum4)+  SumToStr(m_sum4a)   COLOR "gr+/bg"
        @12,42 SayDisp SumToStr(m_sum5)+  SumToStr(m_sum5a)   COLOR "w+/bg"
        @13,42 SayDisp SumToStr(m_sum6)+  SumToStr(m_sum6a)   COLOR "gr+/bg"
        @14,42 SayDisp SumToStr(m_sum7)+  SumToStr(m_sum7a)   COLOR "w+/bg"
        @15,42 SayDisp SumToStr(m_sum8)+  SumToStr(m_sum8a)   COLOR "gr+/bg"
        @16,42 SayDisp SumToStr(m_sum9)+  SumToStr(m_sum9a)   COLOR "w+/bg"
        @17,42 SayDisp SumToStr(m_sum10)+ SumToStr(m_sum10a)  COLOR "gr+/bg"
        @18,42 SayDisp SumToStr(m_sum11)+ SumToStr(m_sum11a)  COLOR "w+/bg"
        DBSKIP()
        ENDDO
        INKEY(0)
        SavePar(1)
        SayShp()
      CASE m_key==K_F5
        IF ANSWERu("Робити копiю на дискету?")==YES
          T2(m_num)
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
  {COLBR(fl1->st)," "},;
  {COLBR(fl1->tabn),"Таб.;ном."},;
  {COLBR(fl1->fio),"      Ф.I.Б.  "},;
  {COLBR(fl1->s_dox),"Сума  ;нарах.;доходу"},;
  {COLBR(fl1->s_tax),"Сума  ;нарах.;под."},;
  {COLBR(fl1->s_dox2),"Сума  ;випл.;доходу"},;
  {COLBR(fl1->s_tax2),"Сума  ;випл.;под."},;
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
STATIC FUnction T2(m_num)
LOCAL a_struct:={;
{"NP","N",5,0},;
{"PERIOD","N",1,0},;
{"RIK","N",4,0},;
{"KOD","C",10,0},;
{"TYP","N",1,0},;
{"TIN","C",10,0},;
{"S_NAR","N",12,2},;
{"S_DOX","N",12,2},;
{"S_TAXN","N",12,2},;
{"S_TAXP","N",12,2},;
{"OZN_DOX","N",3,0},;
{"D_PRIYN","D",8,0},;
{"D_ZVILN","D",8,0},;
{"OZN_PILG","N",2,0},;
{"OZNAKA","N",1,0}}
LOCAL m_sum1:=0,m_sum2:=0,m_sum3:=0,i:=0,m_kod,m_cc,m_rr,m_file,m_rik
LOCAL m_sum1a:=0,m_sum2a:=0
SAVEPAR()
USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
m_rr:=PADR(RESTVAR1("m_rr","DR"),2)
m_cc:=PADR(RESTVAR1("m_cc","DR"),2)
m_kod:=PADR(RESTVAR1("m_kod","DR"),10)
CLOSE myvar

DBCREATE(m_workpath+"Fl2",a_struct)
USE (m_workpath+"fl2") NEW
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
  fl2->s_nar:=fl1->s_dox
  fl2->s_dox:=fl1->s_dox2
  fl2->s_taxn:=fl1->s_tax
  fl2->s_taxp:=fl1->s_tax2
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
CopyFl(m_file)
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
