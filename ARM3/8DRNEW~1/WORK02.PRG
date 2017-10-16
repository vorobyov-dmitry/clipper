 #include "new.ch"
#include "menu.ch"
#define K_ALT_T         276     // Alt-T
MEMVAR a_menu,m_workpath,m_sprpath
Function Work02
  LOCAL m_browse,i,j,n,m_screen,m_poisk
  LOCAL GetList:={},m_kod,m_key,l_delete:=.t.,m_poisk2,m_recno
  LOCAL m_sum1,m_sum2,m_sum3,m_sum4,m_sum5,m_sum6
  LOCAL m_sum7,m_sum8,m_sum9,m_sum10,m_sum11,m_sum12
  LOCAL m_sum1a,m_sum2a,m_sum3a,m_sum4a,m_sum5a,m_sum6a
  LOCAL m_sum7a,m_sum8a,m_sum9a,m_sum10a,m_sum11a,m_sum12a
  LOCAL m_sum1b,m_sum2b,m_sum3b,m_sum4b,m_sum5b,m_sum6b
  LOCAL m_sum7b,m_sum8b,m_sum9b,m_sum0,m_sum0a,m_sum0b
  LOCAL m_sum10b,m_sum11b,m_sum12b
  LOCAL k,s_files:={},m_block,m_buf
  DCL MENU
  IF .NOT.FILE("podohod.dbf")
    DispError("Не знайдено файла з данними")
    RETURN .f.
  ENDIF
//  Sopenfiles("SP10",@s_files)
  IF FILE(m_sprpath+"SP10.DBF")
    NET USE (m_sprpath+"SP10") INDEX (m_sprpath+"SP10") NEW
  ENDIF
  USE ("podohod") ALIAS fl1 NEW
  INDEX ON fl1->tabn  TO ("podohod1")
  INDEX ON fl1->fio     TO ("podohod2")
  INDEX ON fl1->tin     TO ("podohod3")
     m_browse:=TBrowseDB(3,1,MAXROW()-1,MAXCOL()-1)
      m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,GR+/BG'
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
      CASE m_key==K_ENTER
        SET ESCAPE ON
        m_block:=m_browse:GetColumn(m_browse:colPos)
        m_buf:=EVAL(m_block:block)
        STABILIZE BROWSE m_browse
        @ROW(),COL() GET m_buf  COLOR "gr+/n"
        READ
        EVAL(m_block:block,m_buf)
        fl1->sumall:=fl1->sum01+fl1->sum02+fl1->sum03+fl1->sum04+fl1->sum05+fl1->sum06+fl1->sum07+fl1->sum08+fl1->sum09+fl1->sum10+fl1->sum11+fl1->sum12
        fl1->podall:=fl1->pod01+fl1->pod02+fl1->pod03+fl1->pod04+fl1->pod05+fl1->pod06+fl1->pod07+fl1->pod08+fl1->pod09+fl1->pod10+fl1->pod11+fl1->pod12
        fl1->rasall:=fl1->ras01+fl1->ras02+fl1->ras03+fl1->ras04+fl1->ras05+fl1->ras06+fl1->ras07+fl1->ras08+fl1->ras09+fl1->ras10+fl1->ras11+fl1->ras12
        m_browse:RefreshCurrent()
      CASE m_key==K_INS.AND.ANSWERu("Вставити строку?")==YES
        Fl1->(DBINSERT())
        m_browse:RefreshAll()
      CASE m_key==K_ALT_S.AND.ANSWERu("Подрахувати ;контрольну суму?")==YES
            SavePar()
            DBGOTOP()
        @7,0,23 ,67 BOX B_SINGLE+" " COLOR "w/bg"
        @8,7 SayDisp  "------------------------------------------------------------" COLOR "n/bg"
        @9,12 SayDisp  "Нараховано  " COLOR "b/bg"
        @9,25 SayDisp  "Утримано  " COLOR "n/bg"
        @09,38 SayDisp "Перераховано" COLOR "b/bg"
        @09,51 SayDisp "Рiзниця     " COLOR "n/bg"

        @10,01 SayDisp "Январь " COLOR "n/bg"
        @11,01 SayDisp "Февраль     " COLOR "n/bg"
        @12,01 SayDisp "Март       " COLOR "n/bg"
        @13,01 SayDisp "Апрель      " COLOR "n/bg"
        @14,01 SayDisp "Май         " COLOR "n/bg"
        @15,01 SayDisp "Июнь        " COLOR "n/bg"
        @16,01 SayDisp "Июль        " COLOR "n/bg"
        @17,01 SayDisp "Август      " COLOR "n/bg"
        @18,01 SayDisp "Сентябрь    " COLOR "n/bg"
        @19,01 SayDisp "Октябрь     " COLOR "n/bg"
        @20,01 SayDisp "Ноябрь      " COLOR "n/bg"
        @21,01 SayDisp "Декабрь     " COLOR "n/bg"
        @22,01 SayDisp "За год      " COLOR "n/bg"

        m_sum1:=m_sum2:=m_sum3:=m_sum4:=m_sum5:=m_sum6:=0
        m_sum7:=m_sum8:=m_sum9:=m_sum10:=m_sum11:=m_sum12:=0

        m_sum1a:=m_sum2a:=m_sum3a:=m_sum4a:=m_sum5a:=m_sum6a:=0
        m_sum7a:=m_sum8a:=m_sum9a:=m_sum10a:=m_sum11a:=m_sum12a:=0

        m_sum1b:=m_sum2b:=m_sum3b:=m_sum4b:=m_sum5b:=m_sum6b:=0
        m_sum7b:=m_sum8b:=m_sum9b:=m_sum10b:=m_sum11b:=m_sum12b:=0

        m_sum0:=m_sum0a:=m_sum0b:=0


        DO WHILE .NOT.EOF()
m_sum1+=fl1->sum01
m_sum2+=fl1->sum02
m_sum3+=fl1->sum03
m_sum4+=fl1->sum04
m_sum5+=fl1->sum05
m_sum6+=fl1->sum06
m_sum7+=fl1->sum07
m_sum8+=fl1->sum08
m_sum9+=fl1->sum09
m_sum10+=fl1->sum10
m_sum11+=fl1->sum11
m_sum12+=fl1->sum12

m_sum0=m_sum1+m_sum2+m_sum3+m_sum4+m_sum5+m_sum6+m_sum7+m_sum8+m_sum9+m_sum10+m_sum11+m_sum12

m_sum1a+=fl1->pod01
m_sum2a+=fl1->pod02
m_sum3a+=fl1->pod03
m_sum4a+=fl1->pod04
m_sum5a+=fl1->pod05
m_sum6a+=fl1->pod06
m_sum7a+=fl1->pod07
m_sum8a+=fl1->pod08
m_sum9a+=fl1->pod09
m_sum10a+=fl1->pod10
m_sum11a+=fl1->pod11
m_sum12a+=fl1->pod12

m_sum0a=m_sum1a+m_sum2a+m_sum3a+m_sum4a+m_sum5a+m_sum6a+m_sum7a+m_sum8a+m_sum9a+m_sum10a+m_sum11a+m_sum12a


m_sum1b+=fl1->ras01
m_sum2b+=fl1->ras02
m_sum3b+=fl1->ras03
m_sum4b+=fl1->ras04
m_sum5b+=fl1->ras05
m_sum6b+=fl1->ras06
m_sum7b+=fl1->ras07
m_sum8b+=fl1->ras08
m_sum9b+=fl1->ras09
m_sum10b+=fl1->ras10
m_sum11b+=fl1->ras11
m_sum12b+=fl1->ras12
m_sum0b=m_sum1b+m_sum2b+m_sum3b+m_sum4b+m_sum5b+m_sum6b+m_sum7b+m_sum8b+m_sum9b+m_sum10b+m_sum11b+m_sum12b


        @10,12 SayDisp SumToStr(m_sum1,12) +" "+ SumToStr(m_sum1a,12)  +" "+ SumToStr(m_sum1b,12)  +" "+SumToStr(m_sum1a-m_sum1b,12)   COLOR "w+/bg"
        @11,12 SayDisp SumToStr(m_sum2,12) +" "+ SumToStr(m_sum2a,12)  +" "+ SumToStr(m_sum2b,12)  +" "+SumToStr(m_sum2a-m_sum2b,12)   COLOR "gr+/bg"
        @12,12 SayDisp SumToStr(m_sum3,12) +" "+ SumToStr(m_sum3a,12)  +" "+ SumToStr(m_sum3b,12)  +" "+SumToStr(m_sum3a-m_sum3b,12)   COLOR "w+/bg"
        @13,12 SayDisp SumToStr(m_sum4,12) +" "+ SumToStr(m_sum4a,12)  +" "+ SumToStr(m_sum4b,12)  +" "+SumToStr(m_sum4a-m_sum4b,12)   COLOR "gr+/bg"
        @14,12 SayDisp SumToStr(m_sum5,12) +" "+ SumToStr(m_sum5a,12)  +" "+ SumToStr(m_sum5b,12)  +" "+SumToStr(m_sum5a-m_sum5b,12)   COLOR "w+/bg"
        @15,12 SayDisp SumToStr(m_sum6,12) +" "+ SumToStr(m_sum6a,12)  +" "+ SumToStr(m_sum6b,12)  +" "+SumToStr(m_sum6a-m_sum6b,12)   COLOR "gr+/bg"
        @16,12 SayDisp SumToStr(m_sum7,12) +" "+ SumToStr(m_sum7a,12)  +" "+ SumToStr(m_sum7b,12)  +" "+SumToStr(m_sum7a-m_sum7b,12)   COLOR "w+/bg"
        @17,12 SayDisp SumToStr(m_sum8,12) +" "+ SumToStr(m_sum8a,12)  +" "+ SumToStr(m_sum8b,12)  +" "+SumToStr(m_sum8a-m_sum8b,12)   COLOR "gr+/bg"
        @18,12 SayDisp SumToStr(m_sum9,12) +" "+ SumToStr(m_sum9a,12)  +" "+ SumToStr(m_sum9b,12)  +" "+SumToStr(m_sum9a-m_sum9b,12)   COLOR "w+/bg"
        @19,12 SayDisp SumToStr(m_sum10,12)+" "+ SumToStr(m_sum10a,12) +" "+ SumToStr(m_sum10b,12) +" "+SumToStr(m_sum10a-m_sum10b,12)  COLOR "gr+/bg"
        @20,12 SayDisp SumToStr(m_sum11,12)+" "+ SumToStr(m_sum11a,12) +" "+ SumToStr(m_sum11b,12) +" "+SumToStr(m_sum11a-m_sum11b,12)  COLOR "w+/bg"
        @21,12 SayDisp SumToStr(m_sum12,12)+" "+ SumToStr(m_sum12a,12) +" "+ SumToStr(m_sum12b,12) +" "+SumToStr(m_sum12a-m_sum12b,12)  COLOR "gr+/bg"
        @22,10 SayDisp SumToStr(m_sum0,14) +" "+ SumToStr(m_sum0a,12)  +" "+ SumToStr(m_sum0b,12)  +" "+SumToStr(m_sum0a-m_sum0b,12)   COLOR "w+/bg"


        DBSKIP()
        ENDDO
        INKEY(0)
        SavePar(1)
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
  CLOSE base fl1

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
/*
  LOCAL a_col:={;
  {COLBR(fl1->tin),"Iдентиф.;номер"},;
  {COLBR(fl1->tabn),"Таб.;ном."},;
  {COLBR(fl1->fio),"      Ф.I.Б.  "},;
  {COLBR(fl1->sumpod)," пiльга "},;
  {COLBR(fl1->kpn),"под"},;
  {COLBR(fl1->kmn),"дт"},;
  {COLBR(fl1->sum01),"Сума1  ;нарах.;доходу"},;
  {COLBR(fl1->pod01),"Сума1  ;нарах.;под."},;
  {COLBR(fl1->ras01),"Сума1  ;обч.;под."},;
  {COLBR(fl1->sum02),"Сума2  ;нарах.;доходу"},;
  {COLBR(fl1->pod02),"Сума2  ;нарах.;под."},;
  {COLBR(fl1->ras02),"Сума2  ;обч.;под."},;
  {COLBR(fl1->sum03),"Сума3  ;нарах.;доходу"},;
  {COLBR(fl1->pod03),"Сума3  ;нарах.;под."},;
  {COLBR(fl1->ras03),"Сума3  ;обч.;под."},;
  {COLBR(fl1->sum04),"Сума4  ;нарах.;доходу"},;
  {COLBR(fl1->pod04),"Сума4  ;нарах.;под."},;
  {COLBR(fl1->ras04),"Сума4  ;обч.;под."},;
  {COLBR(fl1->sum05),"Сума5  ;нарах.;доходу"},;
  {COLBR(fl1->pod05),"Сума5  ;нарах.;под."},;
  {COLBR(fl1->ras05),"Сума5  ;обч.;под."},;
  {COLBR(fl1->sum06),"Сума6  ;нарах.;доходу"},;
  {COLBR(fl1->pod06),"Сума6  ;нарах.;под."},;
  {COLBR(fl1->ras06),"Сума6  ;обч.;под."},;
  {COLBR(fl1->sum07),"Сума7  ;нарах.;доходу"},;
  {COLBR(fl1->pod07),"Сума7  ;нарах.;под."},;
  {COLBR(fl1->ras07),"Сума7  ;обч.;под."},;
  {COLBR(fl1->sum08),"Сума8  ;нарах.;доходу"},;
  {COLBR(fl1->pod08),"Сума8  ;нарах.;под."},;
  {COLBR(fl1->ras08),"Сума8  ;обч.;под."},;
  {COLBR(fl1->sum09),"Сума9  ;нарах.;доходу"},;
  {COLBR(fl1->pod09),"Сума9  ;нарах.;под."},;
  {COLBR(fl1->ras09),"Сума9  ;обч.;под."},;
  {COLBR(fl1->sum10),"Сума10  ;нарах.;доходу"},;
  {COLBR(fl1->pod10),"Сума10  ;нарах.;под."},;
  {COLBR(fl1->ras10),"Сума10  ;обч.;под."},;
  {COLBR(fl1->sum11),"Сума11  ;нарах.;доходу"},;
  {COLBR(fl1->pod11),"Сума11  ;нарах.;под."},;
  {COLBR(fl1->ras11),"Сума11  ;обч.;под."},;
  {COLBR(fl1->sum12),"Сума12  ;нарах.;доходу"},;
  {COLBR(fl1->pod12),"Сума12  ;нарах.;под."},;
  {COLBR(fl1->ras12),"Сума12  ;обч.;под."},;
  {COLBR(fl1->sumall),"Сума рiк  ;нарах.;доходу"},;
  {COLBR(fl1->podall),"Сума рiк  ;нарах.;под."},;
  {COLBR(fl1->rasall),"Сума рiк   ;обч.;под."}}
*/
  LOCAL a_col:={;
  {COLBR(fl1->tin),"Iдентиф.;номер"},;
  {COLBR(fl1->tabn),"Таб.;ном."},;
  {COLBR(fl1->fio),"      Ф.I.Б.  "},;
  {COLBR(fl1->sumpod)," пiльга "},;
  {COLBR(fl1->kpn),"под"},;
  {COLBR(fl1->kmn),"дт"},;
  {COLBR(fl1->sum01),"Сума1  ;нарах.;доходу"},;
  {COLBR(fl1->pod01),"Сума1  ;нарах.;под."},;
  {COLBR(fl1->ras01),"Сума1  ;обч.;под."},;
  {COLBR(fl1->b01),"Сума1  ;больн"},;
  {COLBR(fl1->sum02),"Сума2  ;нарах.;доходу"},;
  {COLBR(fl1->pod02),"Сума2  ;нарах.;под."},;
  {COLBR(fl1->ras02),"Сума2  ;обч.;под."},;
  {COLBR(fl1->b02),"Сума2  ;больн"},;
  {COLBR(fl1->sum03),"Сума3  ;нарах.;доходу"},;
  {COLBR(fl1->pod03),"Сума3  ;нарах.;под."},;
  {COLBR(fl1->ras03),"Сума3  ;обч.;под."},;
  {COLBR(fl1->b03),"Сума3  ;больн"},;
  {COLBR(fl1->sum04),"Сума4  ;нарах.;доходу"},;
  {COLBR(fl1->pod04),"Сума4  ;нарах.;под."},;
  {COLBR(fl1->ras04),"Сума4  ;обч.;под."},;
  {COLBR(fl1->b04),"Сума4  ;больн"},;
  {COLBR(fl1->sum05),"Сума5  ;нарах.;доходу"},;
  {COLBR(fl1->pod05),"Сума5  ;нарах.;под."},;
  {COLBR(fl1->ras05),"Сума5  ;обч.;под."},;
  {COLBR(fl1->b05),"Сума5  ;больн"},;
  {COLBR(fl1->sum06),"Сума6  ;нарах.;доходу"},;
  {COLBR(fl1->pod06),"Сума6  ;нарах.;под."},;
  {COLBR(fl1->ras06),"Сума6  ;обч.;под."},;
  {COLBR(fl1->b06),"Сума6  ;больн"}}
  Local i,n,m_col
  AADD(a_col,{COLBR(fl1->sum07),"Сума7  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->pod07),"Сума7  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->ras07),"Сума7  ;обч.;под."})
  AADD(a_col,{COLBR(fl1->b07),"Сума7  ;больн"})
  AADD(a_col,{COLBR(fl1->sum08),"Сума8  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->pod08),"Сума8  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->ras08),"Сума8  ;обч.;под."})
  AADD(a_col,{COLBR(fl1->b08),"Сума8  ;больн"})
  AADD(a_col,{COLBR(fl1->sum09),"Сума9  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->pod09),"Сума9  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->ras09),"Сума9  ;обч.;под."})
  AADD(a_col,{COLBR(fl1->b09),"Сума9  ;больн"})
  AADD(a_col,{COLBR(fl1->sum10),"Сума10  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->pod10),"Сума10  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->ras10),"Сума10  ;обч.;под."})
  AADD(a_col,{COLBR(fl1->b10),"Сума10 ;больн"})
  AADD(a_col,{COLBR(fl1->sum11),"Сума11  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->pod11),"Сума11  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->ras11),"Сума11  ;обч.;под."})
  AADD(a_col,{COLBR(fl1->b11),"Сума11 ;больн"})
  AADD(a_col,{COLBR(fl1->sum12),"Сума12  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->pod12),"Сума12  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->ras12),"Сума12  ;обч.;под."})
  AADD(a_col,{COLBR(fl1->b12),"Сума12  ;больн"})
  AADD(a_col,{COLBR(fl1->sumall),"Сума рiк  ;нарах.;доходу"})
  AADD(a_col,{COLBR(fl1->podall),"Сума рiк  ;нарах.;под."})
  AADD(a_col,{COLBR(fl1->rasall),"Сума рiк   ;обч.;под."})
  AADD(a_col,{{||fl1->podall-fl1->rasall},"Разница"})
  n:=LEN(a_col)

  FOR i:=1 TO n
      m_Col           := TBColumnNew()
      m_col:block:=a_col[i][1]
      m_col:heading:=a_col[i][2]
      m_Col:colorblock:=  {|| IF(fl1->podall==fl1->rasall,{1,2},{5,7})}
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
{"OZN_DOX","N",2,0},;
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
