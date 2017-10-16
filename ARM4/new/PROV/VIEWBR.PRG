#include "new.ch"
#include "menu.ch"
#DEFINE N_PRINTER 1
#DEFINE N_PAPER 2
#DEFINE N_ZAG 3
#DEFINE N_SYMBOL 4
#DEFINE N_LINES 5
#DEFINE N_INIT_PRINTER  6
STATIC m_page:=0,m_line:=0,n_line1:=0,m_endpage:=0,m_first:=0
MEMVAR m_mash,m_sprpath
STATIC a_total:={}
Function ViewMs(m_num_mash)
  LOCAL n_win,m_screen,l_filter:=.f.,n_win1,m_gauge
  LOCAL i,j,k,m_key,a_shapka:={},m_clr,n_pos,s_par,m_count,s1
  LOCAL m_name:="",a_filter:={},a_print:={}
  DCL MENU
  DCL list
// Прочитать параметры машинограммы

  IF .NOT.FILE(m_mash+"m"+m_num_mash+".DBF").OR..NOT.FILE(m_mash+"m"+m_num_mash+".NTX")
    DispError("Файл машинограми вiдсутнiй")
    RETURN .F.
  ENDIF

  s_par:=FILESTR(m_mash+"m"+m_num_mash+".DBF",20,FILESIZE(m_mash+"m"+m_num_mash+".DBF")-20)

  NET USE (m_sprpath+"SP10") INDEX  (m_sprpath+"SP10") NEW  READONLY
  NET USE (m_mash+"m"+m_num_mash) INDEX  (m_mash+"m"+m_num_mash) NEW ALIAS buf READONLY
  IF LASTREC()<1
    DispError("Машинограма пуста")
    CLOSE base sp10,buf
    RETURN .T.
  ENDIF

  a_total:={}
  CreateAtotal(m_num_mash,a_total)
  ASIZE(a_filter,LEN(a_total))
  AFILL(a_filter,.T.)
  CreateShapka(m_num_mash,a_shapka,a_print)
  IF .NOT.CrList7(m_num_mash,@m_browse,@l_print,@m_name,a_total,s_par,a_print)
    RETURN .F.
  ENDIF
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
//  n_win1:=InitScr("VIEWPROV")
  WSELECT(n_win)
  ADD menu up_down
  add menu Left_Right
  add menu search
  ADD MENU NAME "Д~рук" ITEMS {"Друк F2","Друк на прiнтер <Ctrl>+P",;
    "Перелiк стовбцiв <Ctrl>+L","Параметри друку F9","Параметри прiнтера <Ctrl>+U","Кiлькiсть рядкiв <Alt>+F9"} ;
    KEY {K_F2,K_CTRL_P,K_CTRL_L,K_F9,K_CTRL_U,K_ALT_F9}
  ADD MENU NAME "Iн~ше" ITEMS {"Формат сторiнки F11"} KEY {K_F11}
  ADD MENU NAME "~Фiльтр" ITEMS {"0 - вiдмiнити <Alt>+0","накласти <Alt>+1"};
  KEY {K_ALT_0,K_ALT_1}
//  a_shapka:=CreateShp(@m_browse,@l_print)
  INIT menu
  @m_browse:ntop-1,m_browse:nleft-1,m_browse:nBottom,m_browse:nRight+1 BOX B_DOUBLE+" " COLOR "w/b"
  m_name:=SetMsName(alltrim(m_name),s_par)
  i:=AT(";",m_name)
  CLEAREOL(m_browse:ntop-3,0,"w/b"," ")
  CLEAREOL(m_browse:ntop-2,0,"w/b"," ")
  IF i<>0
    @m_browse:ntop-3,0 SayText PADC(LEFT(m_name,i-1),MAXCOL()+1) COLOR "w/b,gr+/b"
    @m_browse:ntop-2,0 SayText PADC(SUBSTR(m_name,i+1),MAXCOL()+1) COLOR "w/b,gr+/b"
  ELSE
    @m_browse:ntop-2,0 SayText PADC(m_name,MAXCOL()+1) COLOR "w/b,gr+/b"
  ENDIF
  @m_browse:ntop-1,57 SayDisp "Сторiнка   " COLOR "W+/B"
  @m_browse:ntop-1,70 SayDisp "Рядок   " COLOR "W+/B"
  m_endpage:=GetEndPage()
  m_first:=LEN(a_shapka)+2
  m_page:=1;m_line:=m_first
  STABILIZE BROWSE m_browse
  DO WHILE .t.
     SELE BUF
    m_browse:refReshCurrent()
    m_key:=0
    keyboard ""
    DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
    ENDDO
    IF m_browse:stabilize()
      @m_browse:ntop-1,66 SayDisp m_page COLOR "GR+/B" PICTURE "999"
      @m_browse:ntop-1,76 SayDisp m_line COLOR "GR+/B" PICTURE "99"
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},{2,2})
    ENDIF
    IF m_key==0
      m_key:=INKEY(0)
    ENDIF
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
    Winsay
    DEAL MENU
    DO CASE

    CASE m_key==K_PGUP.AND.m_page>1
      EVAL(m_browse:SkipBlock,m_first-1-m_line-m_endpage+m_first)
      m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
    CASE m_key==K_PGDN
      j:=m_endpage-m_line+1
      i:=EVAL(m_browse:SkipBlock,j)
      IF i==j
        m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
      ELSE
        EVAL(m_browse:SkipBlock,-i)
      ENDIF
    CASE m_key==K_CTRL_L
      SetColPrint(a_print)
    DEAL BROWSE m_browse KEY m_key
    CASE m_key == K_ALT_0
      SET FILTER TO
      EVAL(m_browse:GoTopBlock)
      m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
      m_browse:RefreshAll()
    CASE m_key == K_ALT_1
      IF MsSetFilter(a_filter)
        buf->(DBSETFILTER({||(a_filter[VAL(buf->level)])},"a_filter[VAL(buf->level)])"))
        EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
        m_browse:configure();m_browse:RefreshAll()
      ENDIF
    CASE m_key == K_ALT_2
      ViewPrMs(s_par)
    CASE m_key == K_F9
        SetLpechat()
        IF GetEndPage()<>m_endpage
          m_endpage:=GetEndPage()
          EVAL(m_browse:GoTopBlock)
          m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
          m_browse:RefreshAll()
        ENDIF
      CASE m_key == K_F2
          m_recno:=buf->(RECNO())
          OpenPrn(m_mash+m_num_mash+".lst")
          PrintMs(a_shapka,a_print,m_name,m_num_mash,m_browse)
          ClosePrn()
          MyPrintFile(m_mash+m_num_mash+".lst")
          buf->(DBGOTO(m_recno))
      CASE m_key == K_CTRL_U
          LSetprint()
      SCAN  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
    CASE m_key==K_F11
        ScrView(m_browse)
        WSELECT(n_win)
        m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
        m_browse:RefreshAll()
/*
      CASE m_key == K_CTRL_P
          m_recno:=RECNO()
          OpenPrn()
          PrintMs(m_browse,a_shapka,m_name,l_print)
          DBGOTO(m_recno)
          ClosePrn()
      CASE m_key == K_F2
          m_recno:=RECNO()
          m_clr:=TEMPFILE(m_temppath,"prn");FERASE(m_clr)
          OpenPrn(m_clr)
          PrintMs(m_browse,a_shapka,m_name,l_print)
          DBGOTO(m_recno)
          ClosePrn()
          fileToLpt1(m_clr)
          PRINTSEND(CHR(K_CTRL_L))
      CASE m_key == K_CTRL_L
          SetLprint(m_browse,@l_print)
          a_shapka:=CreateShp(@m_browse,@l_print)
          IF m_first<>LEN(a_shapka)+3
            m_first:=LEN(a_shapka)+3
            EVAL(m_browse:GoTopBlock)
            m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
            m_browse:RefreshAll()
          ENDIF
      CASE m_key == K_ALT_F9
          CountLines()
     */
 ENDCASE
ENDDO
WCLOSE(n_win)
WCLOSE(n_win1)
WSELECT(0)
close BASE buf,sp10
RETURN .t.
/*
* СОЗДАНИЕ  BROWSE ОБЪЕКТА МАШИНОГРАММЫ
*/
STATIC Function CrList7(m_var,m_browse,l_print,m_name,a_total,s_par,a_print)
    LOCAL m_col,i,m_width,k
    LOCAL l_glv:=.t.,l_doc:=.t.,l_cod:=.t.

// АНАЛИЗАТОР СОХРАНЕННОЙ МАШИНОГРАММЫ И ИСКЛЮЧЕНИЕ НЕНУЖНЫХ СТОЛБЦОВ
    IF TOKEN(s_par,";",5)=="2"  //АНАЛИТИЧЕСКИЙ КОД  НЕ УЧИТЫВАТЬ
      l_cod:=.F.
    ENDIF
    IF TOKEN(s_par,";",6)=="Z"  //первичные документы не включать
      l_doc:=.F.
    ENDIF
    IF TOKEN(s_par,";",3)<>"1"  //Голов нет
      l_glv:=.F.
    ENDIF

      m_browse:=TBrowseDB(4,1,MAXROW()-1,MAXCOL()-1)
      // задание допустимых цветов
      m_browse:colorspec:="W+/B,B/W,"
      FOR i:=1 TO LEN(a_total)
        m_browse:colorspec+=ALLTRIM(a_total[i,4])+IF(i<>LEN(a_total),",","")
      NEXT
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| buf->(SkipDb(n)) }
      m_browse:goBottomBlock := { ||buf->(MyGOBOT(m_browse)) }
      m_browse:goTopBlock    := { ||m_page:=1,m_line:=m_first,buf->(DBGOTOP())  }


      IF .NOT.sptabl->(DS("M"+m_var))
        DispError("Не знайдена службова iнформацiя машинограми ["+m_var+"]")
        RETURN .F.
      ENDIF
      DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)=="M"+m_var
          m_Col           := TBColumnNew()
        k:=ASCAN(a_print,{|x|ALLTRIM(UPPER(sptabl->value))==x[1]})
        IF k<>0
          a_print[k,2]:=ALLTRIM(CHARREPL(";",sptabl->heading," "))
        ENDIF
         IF AT("GLV",sptabl->value)<>0.and..NOT.l_glv //не включать головы
            Sptabl->(DBSKIP());LOOP
        ENDIF
        IF AT("COD",sptabl->value)<>0.and..NOT.l_cod // не включать аналитический код
            Sptabl->(DBSKIP());LOOP
        ENDIF
        IF AT("NPCH",sptabl->value)<>0.and..NOT.l_doc // не включать параметры первичного документа
            Sptabl->(DBSKIP());LOOP
        ENDIF
        IF AT("NDOC",sptabl->value)<>0.and..NOT.l_doc // не включать параметры первичного документа
            Sptabl->(DBSKIP());LOOP
        ENDIF
        IF AT("DDOC",sptabl->value)<>0.and..NOT.l_doc // не включать параметры первичного документа
            Sptabl->(DBSKIP());LOOP
        ENDIF
        IF AT("MNT",sptabl->value)<>0.and..NOT.l_doc // не включать параметры первичного документа
            Sptabl->(DBSKIP());LOOP
        ENDIF
        IF AT("NDOG",sptabl->value)<>0.and..NOT.l_doc // не включать параметры первичного документа
            Sptabl->(DBSKIP());LOOP
        ENDIF
        m_width:=0
        k:=ASCAN(a_print,{|x|ALLTRIM(UPPER(sptabl->value))==x[1]})
        IF k<>0
          m_width:=a_print[k,6]-1
          a_print[k,3]:=sptabl->print
        ENDIF
            DO CASE
              CASE sptabl->type=='03' // Сумма
                m_col:block:=&("{||StoStr2(buf->"+ALLTRIM(sptabl->value)+;
                             IF(m_width==0,",12)}",","+ALLTRIM(STR(m_width,3))+")}"))
              CASE sptabl->type=='04' // Для количественных показателей
//                m_col:block:=&("{||StoStr2(buf->"+ALLTRIM(sptabl->value)+;
//                             IF(m_width==0,",12)}",","+ALLTRIM(STR(m_width,3))+")}"))
                m_col:block:=&("{||StoStr3(buf->"+ALLTRIM(sptabl->value)+;
                             IF(m_width==0,",12,",","+ALLTRIM(STR(m_width,3))+",")+ALLTRIM(STR(sptabl->width,3))+")}")
              CASE sptabl->type=='02' //Блок отображаеться 1:1
                m_col:block:=&("{||buf->"+ALLTRIM(sptabl->value)+"}")
              CASE sptabl->type=='01' //Блок отображаеться 1:1
                m_col:block:=&("{||buf->"+ALLTRIM(sptabl->value)+"}")
              OTHERWISE
                m_col:block:=&("{||buf->"+ALLTRIM(sptabl->value)+"}")
            ENDCASE
    /*          IF .NOT.EMPTY(sptabl->width)
              m_col:width:=sptabl->width
            ENDIF */
            m_col:heading:=ALLTRIM(sptabl->heading)
            AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
            m_Col:colorblock:=  {||{VAL(buf->level)+2,VAL(buf->level)+2}}
            m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
            m_col:Cargo:=ALLTRIM(sptabl->value)  //Запоминаем содержимое столбца
            IF k<>0
              a_print[k,4]:=m_col:block
            ENDIF

            m_browse:addColumn(m_col)
          Sptabl->(DBSKIP())
      ENDDO
      sptabl1->(DS("M"+m_var))
      m_browse:freeze:= IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
      m_name=ALLTRIM(sptabl1->cargo)
RETURN .t.
/*
* проход по строкам машинограммы
*/
STATIC FUNCTION SkipDb(n)
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
  m_line+=ncount
  DO WHILE  m_line>m_endpage
    m_line:=m_line-m_endpage-1+m_first
    m_page++
  ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
  m_line+=ncount
  DO WHILE  m_line<m_first
    m_line:=m_line+m_endpage-m_first+1
    m_page--
  ENDDO
END
RETURN ( ncount )
STATIC Function MyGOBOT(m_browse)
DO WHILE .t.
  IF EVAL(m_browse:SkipBlock,1)<>1
    EXIT
  ENDIF
ENDDO
RETURN .t.
/* Функция форматирования суммы с заменой нулевого значения пробелом
*/
Function StoSTR2(x,m_len)
LOCAL m_str:="",s:=STR(ABS(x),18,2),i
if x==0
  IF VAL(buf->level)<=0.OR.VAL(buf->level)>LEN(a_total)
    return SPACE(m_len)
  ENDIF
IF a_total[VAL(buf->level),2]=="0" // Тип итога
  return SPACE(m_len)
else
  RETURN PADL("0.00",m_len)
endif
endif
m_str:=ALLTRIM(substr(s,1,3))
FOR i:=1 TO 4
   IF .NOT.EMPTY(SUBSTR(s,3*i+1,3))
       IF .NOT.EMPTY(m_str)
           m_str+="'"+SUBSTR(s,3*i+1,3)
      ELSE
        m_str+=ALLTRIM(SUBSTR(s,3*i+1,3))
      ENDIF
    ENDIF
NEXT
// m_str+=IF(substr(s,17,2)=='00',"","."+substr(s,17,2))
m_str+=","+substr(s,17,2)
IF x<0
  m_str:="-"+m_str
ENDIF
IF m_len<>NIL.AND.m_len>0
  IF LEN(m_str)>m_len
    IF LEN(ALLTRIM(STR(x,18,2)))>m_len
	     m_str:=REPLICATE("*",m_len)
    ELSE
	     m_str:=PADL(ALLTRIM(STR(x,18,2)),m_len)
     ENDIF
  ELSE
   m_str:=PADL(m_str,m_len)
  ENDIF

ENDIF
RETURN m_str
/* Ввод данных по фильтру
*
*/
STATIC FUNCTION MsSetFilter(a_f)
LOCAL i,n_win,GetList:={}

  n_win:=InitScr("PARFILT")
    @7,31 Get a_f[1] COLOR "n/w,Gr+/n"
    IF LEN(a_total)>=2
      @8,31 Get a_f[2] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=3
      @9,31 Get a_f[3] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=4
      @10,31 Get a_f[4] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=5
      @11,31 Get a_f[5] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=6
      @12,31 Get a_f[6] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=7
      @13,31 Get a_f[7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=8
      @14,31 Get a_f[8] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=9
      @15,31 Get a_f[9] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=10
      @16,31 Get a_f[10] COLOR "n/w,Gr+/n"
    ENDIF

    @7,9  SAY a_total[1,1] COLOR "Gr+/b"
    @7,38 Say a_total[1,4] COLOR a_total[1,4]
    @7,52 Get a_total[1,5] COLOR "n/w,Gr+/n"
    @7,61 Get a_total[1,6] COLOR "n/w,Gr+/n"
    @7,69 Get a_total[1,7] COLOR "n/w,Gr+/n"



    IF LEN(a_total)>=2
      @8,9  SAY a_total[2,1] COLOR "Gr+/b"
      @8,38 Say a_total[2,4] COLOR (a_total[2,4])
      @8,52 Get a_total[2,5] COLOR "n/w,Gr+/n"
      @8,61 Get a_total[2,6] COLOR "n/w,Gr+/n"
      @8,69 Get a_total[2,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=3
      @9,9  SAY a_total[3,1] COLOR "Gr+/b"
      @9,38 Say a_total[3,4] COLOR (a_total[3,4])
      @9,52 Get a_total[3,5] COLOR "n/w,Gr+/n"
      @9,61 Get a_total[3,6] COLOR "n/w,Gr+/n"
      @9,69 Get a_total[3,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=4
      @10,9  SAY a_total[4,1] COLOR "Gr+/b"
      @10,38 Say a_total[4,4] COLOR (a_total[4,4])
      @10,52 Get a_total[4,5] COLOR "n/w,Gr+/n"
      @10,61 Get a_total[4,6] COLOR "n/w,Gr+/n"
      @10,69 Get a_total[4,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=5
      @11,9  SAY a_total[5,1] COLOR "Gr+/b"
      @11,38 Say a_total[5,4] COLOR (a_total[5,4])
      @11,52 Get a_total[5,5] COLOR "n/w,Gr+/n"
      @11,61 Get a_total[5,6] COLOR "n/w,Gr+/n"
      @11,69 Get a_total[5,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=6
      @12,9  SAY a_total[6,1] COLOR "Gr+/b"
      @12,38 SAY a_total[6,4] COLOR (a_total[6,4])
      @12,52 Get a_total[6,5] COLOR "n/w,Gr+/n"
      @12,61 Get a_total[6,6] COLOR "n/w,Gr+/n"
      @12,69 Get a_total[6,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=7
      @13,9  SAY a_total[7,1] COLOR "Gr+/b"
      @13,38 Say a_total[7,4] COLOR (a_total[7,4])
      @13,52 Get a_total[7,5] COLOR "n/w,Gr+/n"
      @13,61 Get a_total[7,6] COLOR "n/w,Gr+/n"
      @13,69 Get a_total[7,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=8
      @14,9  SAY a_total[8,1] COLOR "Gr+/b"
      @14,38 SAY a_total[8,4] COLOR (a_total[8,4])
      @14,52 Get a_total[8,5] COLOR "n/w,Gr+/n"
      @14,61 Get a_total[8,6] COLOR "n/w,Gr+/n"
      @14,69 Get a_total[8,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=9
      @15,9  SAY a_total[9,1] COLOR "Gr+/b"
      @15,38 SAY a_total[9,4] COLOR (a_total[9,4])
      @15,52 Get a_total[9,5] COLOR "n/w,Gr+/n"
      @15,61 Get a_total[9,6] COLOR "n/w,Gr+/n"
      @15,69 Get a_total[9,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_total)>=10
      @16,9  SAY a_total[10,1] COLOR "Gr+/b"
      @16,38 SAY a_total[10,4] COLOR (a_total[10,4])
      @16,52 Get a_total[10,5] COLOR "n/w,Gr+/n"
      @16,61 Get a_total[10,6] COLOR "n/w,Gr+/n"
      @16,69 Get a_total[10,7] COLOR "n/w,Gr+/n"
    ENDIF
    SET CURSOR ON
    SET ESCAPE ON
    READ
    Wclose(n_win)
    IF LASTKEY()==K_ESC
      RETURN .f.
    ENDIF
return .t.
/* ПРОСМОТР ПАРАМЕТРОВ МАШИНОГРАММЫ
*
*/
STATIC FUNCTION ViewPrMs(s_par)
LOCAL n_win
    n_win:=InitScr("PARROZ")
    @ 2,18 Say mnt_data(TOKEN(s_par,";",1)) COLOR "w+/b*" //mnt1
    @ 2,26 Say mnt_dtoc(TOKEN(s_par,";",1)) COLOR "gr+/b"
    @ 3,18 Say mnt_data(TOKEN(s_par,";",2)) COLOR "w+/b*" // mnt2
    @ 3,26 Say mnt_dtoc(TOKEN(s_par,";",2)) COLOR "gr+/b"
    @ 4,18 Say TOKEN(s_par,";",3)           COLOR "w+/b*"  //наличие голов
    @ 5,18 Say TOKEN(s_par,";",4)           COLOR "w+/b*"  // оператор
    @ 5,22 Say LEFT(_fiofull(GetOper(TOKEN(s_par,";",4))),35)  COLOR "gr+/b"

    @ 6,18 Say TOKEN(s_par,";",5)           COLOR "w+/b*"  // код расчета
    @ 7,18 Say TOKEN(s_par,";",6)           COLOR "w+/b*"  //1-я строка
    INKEY(0)
    Wclose(n_win)
return .t.
/*
* Установка параметров шапки
*/
STATIC FUNCTION   CreateShapka(m_num_mash,a_shapka,a_print)
LOCAL s_val,m_str,n,i,s1,j
  IF .NOT.Screen->(DS("M"+m_num_mash+"SH"))
    DispError("Вiдсутня шапка машинограми N"+m_num_mash)
    RETURN .F.
  ENDIF
    m_str:=screen->vd
    n:=MLCOUNT(m_str,254)
    FOR i:=1 TO n-1
      AADD(a_shapka,RTRIM(MEMOLINE(m_str,254,i)))
    NEXT
    s_val:=RTRIM(MEMOLINE(m_str,254,i))
    n:=NUMTOKEN(s_val)
    // массив печати
    // 1-й содержимое столбца
    // 2 - название столбца
    // 3 - условие печати
    // 4 - кодовый блок содержимого
    // 5 - координата
    // 6 - ширина
    FOR i:=1 TO n
      s1:=UPPER(alltrim(TOKEN(s_val,,i)))
      AADD(a_print,{s1,NIL,NIL,NIL,0,0})
    NEXT
    a_print[1,5]:=1
    FOR i:=1 TO n-1
    // определение координатs столбца
      j:= ATNUM("┴",a_shapka[LEN(a_shapka)],i)
      a_print[i+1,5]:=j
      a_print[i,6]:=a_print[i+1,5]-a_print[i,5] // 1 на промежуток между столбцами
    NEXT
    a_print[n,6]:=LEN(a_shapka[LEN(a_shapka)])-a_print[i,5]
RETURN .T.
/* ФУНКЦИЯ устанавливает какие столбцы печатать
*
*/

STATIC FUNCTION SetColPrint(a_print)
  LOCAL m_screen:=SAVESCREEN(4,4,MAXROW()-3,MAXCOL()-2),;
        a_browse:=TbrowseNew(5,5,MAXROW()-5,MAXCOL()-5),;
        m_color:=SETCOLOR("n/bg"),m_first:=1,;
        m_col,i,m_row:=1,m_skip:=0

      m_col:=TBcolumnNew()
      m_col:block={||a_print[m_row,2]}
      m_col:heading:="  Назва стовбця      "
      m_col:colsep:="│"
      m_col:headsep    := "─"
      m_col:footsep    := "─"
      m_col:width      :=25
      a_browse:AddColumn(m_col)
      m_col:=TBcolumnNew()
      m_col:block:={||IF(a_print[m_row,3]==NIL,"***",IF(a_print[m_row,3]," Да  "," Нi "))}
      m_col:heading:="Друкувати стовбець"
      m_col:colsep:="│"
      m_col:headsep    := "─"
      m_col:footsep    := "─"
      m_col:colorblock:={||IF(a_print[m_row,3]==NIL,{5,6},IF(a_print[m_row,3],{1,2},{3,4}))}
      a_browse:AddColumn(m_col)
      a_browse:Autolite:=.f.
      a_browse:colorspec:="n/bg,n/w,n/r,r/w,w/n,gr/n"
      a_browse:skipBlock:={|m_count|;
        m_skip:=IF(m_count>=0,;
                IF(m_row+m_count>LEN(a_print),LEN(a_print)-m_row,m_count),;
                IF(m_row+m_count>=m_first,m_count,-m_row+m_first)),m_row+=m_skip,m_skip}
     @4,4,MAXROW()-4,MAXCOL()-4  BOX B_DOUBLE_SINGLE + SPACE(1)
     SHADOW(4,4,MAXROW()-4,MAXCOL()-4 )
     DO WHILE .T.
      DO WHILE .NOT.a_browse:stabilize()
      ENDDO
      a_browse:hilite()
      i:=inkey(0)
      a_browse:deHilite()
      DO CASE
        CASE i==K_DOWN
          a_browse:down()
        CASE i==K_UP
          a_browse:up()
        CASE i==K_ENTER.OR.CHR(i)==" "
         IF a_print[m_row,3]<>NIL
          a_print[m_row,3]:=.NOT.a_print[m_row,3]
          a_browse:refreshCurrent()
        ENDIF
        CASE i==K_ESC
          EXIT
        CASE i==K_CTRL_RET
          FOR i:=1 TO LEN(a_print)
         IF a_print[i,3]<>NIL
            a_print[i,3]:=.t.
          ENDIF
          NEXT
          a_browse:refreshAll()
      ENDCASE
    ENDDO
    SETCOLOR(m_color)
    RESTSCREEN(4,4,MAXROW()-3,MAXCOL()-2,m_screen)
RETURN .t.
STATIC FUNCTION PrintMs(a_shapka,a_print,m_name,m_num_mash,m_browse)
LOCAL m_recno,n_page:=m_page,n_line:=m_line,n_page1:=-1,n1:=1,n2:=1
LOCAL i,j,n,p_col:={},a_col:={},l,l_end:=.f.,b_finish:={||.f.},m_gauge
LOCAL a_shp:={},a_width:={},l_first:=.t.,a_esc_ON:={},a_esc_OFF:={}
LOCAL m_count,s1,m_str1:=My_Dtos(DATE())+" "


// Вибрати тип друку
m_recno:=buf->(RECNO())
i:=ALERT("Друкувати",{"З 1-ї сторiнки","Вибiрково ","Вiдмовитися"},"n/bg+,w/b" )
DO CASE
  CASE i==1
    j:=1
    buf->(EVAL(m_browse:goTopBlock))
    l:=buf->(LASTREC())
    m_gauge := InitGauge("Друк таблицi ",2)
  CASE i==2
    n1:=1;n2:=m_page
    IF GetNumPage(@n1,@n2,INT(0.6+buf->(LASTREC())/(m_endpage-m_first)))
      buf->(EVAL(m_browse:goTopBlock))
      // Позиционирование на необходимую запись
      DO WHILE m_page<>n1
        IF buf->(EVAL(m_browse:skipblock,1))<1
          buf->(DBGOTO(m_recno));m_line:=n_line;m_page:=n_page
          DispError("Сторiнка N "+STR(n1,3)+";не знайдена")
          RETURN .f.
        ENDIF
      ENDDO
      b_finish:={||IF(m_page<=n2,.f.,.t.)}
      j:=1
      l:=(n2-n1+1)*(m_endpage-m_first+1)
      m_gauge := InitGauge("Друк таблицi вибiрково з сторiнки"+STR(n1,3)+" по сторiнку"+STR(n2,3),2)
    ELSE
      RETURN .f.
    ENDIF
  CASE i==0.OR.i==3
      RETURN .f.
ENDCASE
// Формирование шапки и массива координат
ASIZE(a_shp,LEN(a_shapka))
FOR i:=1 TO LEN(a_shapka)
  a_shp[i]:=LEFT(a_shapka[i],1)
NEXT
FOR i:=1 TO LEN(a_print)
  IF a_print[i,3]<>NIL.AND.a_print[i,3]
        AADD(p_col,LEN(a_shp[1])) //координата вывода
      // Копируем столбец
      FOR j:=1 TO LEN(a_shapka)
        a_shp[j]+=SUBSTR(a_shapka[j],a_print[i,5]+1,a_print[i,6])
      NEXT
      AADD(a_width,a_print[i,6]-1)
      AADD(a_col,a_print[i,4])
  ENDIF
NEXT
IF GetParPrn(4)==2
  FOR i:=1 TO LEN(a_shp)
    a_shp[i]:=CHARREPL("┌│├└┼┴┬─┘┤┐",a_shp[i],"-||-|----||")
  NEXT
ENDIF


n:=LEN(a_col)
IF .NOT.SetWidthPrn(LEN(a_shp[1]))
  RETURN .f.
ENDIF
m_str1+=PADC(ALLTRIM(m_name),LEN(a_shp[1])-16-LEN(m_str1))+"Сторiнка N"
//Инициализация ESC последовательностей
InitMsEsc(a_esc_ON,a_esc_OFF)

l_first:=.t.;j:=1
DO WHILE .T.
      IF n_page1<>m_page
        IF .NOT.l_first
            StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
            SETPRC(0,0)
        ENDIF
        l_first:=.f.
        IF GetparPrn(N_ZAG)==1.OR.(GetParPrn(N_ZAG)==2.AND.m_page==1)
          IF PrnOnLine()
              @0,0 SAY m_str1+STR(m_page,3)
              FOR i:=1 TO LEN(a_shp)
                IF PrnOnLine()
                    @PROW()+1,0  SAY a_shp[i]
                ELSE
                    RETURN .F.
                ENDIF
              NEXT
          ENDIF
        ENDIF
       n_page1:=m_page
      ENDIF
      @PROW()+1,0 SAY ""
              // Установить шрифт
              SetMsEsc(a_esc_ON)
      FOR i:=1 TO n
         IF PrnOnLine()
            @PROW(),p_col[i] SAY LEFT(TRANSFORM(buf->(EVAL(a_col[i])),""),a_width[i])
         ELSE
            l_end:=.T.
            EXIT
         ENDIF
      NEXT
            // Снять шрифт
              SetMsEsc(a_esc_OFF)
   IF l_end
      EXIT
   ENDIF
   m_gauge:=DispGauge(m_gauge,j++/l)
   IF EVAL(m_browse:skipblock,1)<1.OR.EVAL(b_finish)
      EXIT
   ENDIF
ENDDO
DelGauge(m_gauge)
@PROW()+1,0 SAY ""
SETPRC(PROW(),0)
buf->(DBGOTO(m_recno));m_line:=n_line;m_page:=n_page
RETURN .T.
STATIC Function GetNumPage(n1,n2,m_max)
  LOCAL m_screen,GetList:={}
  SET ESCAPE ON
m_screen:=SAVESCREEN(INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50)
  @INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50  BOX B_DOUBLE+" " COLOR "N/BG"
  @INT(MAXROW()/2)-2+1,INT((MAXCOL()-50)/2)+2 SAYDISP     "Номер першої    сторiнки>" COLOR "N/bg"
  @INT(MAXROW()/2)-2+2,INT((MAXCOL()-50)/2)+2 SAYDISP "Номер останньої сторiнки>" COLOR "N/bg"
  n1:=1
  n2:=m_max
  @INT(MAXROW()/2)-2+1,INT((MAXCOL()-50)/2)+2+35 GET n1 PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n1>0.AND.n1<=m_max
  @INT(MAXROW()/2)-2+2,INT((MAXCOL()-50)/2)+2+35 GET n2 PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n2>=n1.AND.n2<=m_max
      READ
      SET ESCAPE OFF
RESTSCREEN(INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50,m_screen)
      IF LASTKEY()==K_ESC
        RETURN .f.
      ENDIF
RETURN .t.
STATIC Function SetMsName(m_name,s_par)
LOCAL m_mnt1:=TOKEN(s_par,";",1),m_mnt2:=TOKEN(s_par,";",2)
IF m_mnt1==m_mnt2
  RETURN ALLTRIM(m_name)+" за "+ mnt_dtoc(m_mnt1)
ENDIF
IF mnt_year(m_mnt1)==mnt_year(m_mnt2)
  IF mnt_month(m_mnt1)==1.AND.mnt_month(m_mnt2)==3
    RETURN ALLTRIM(m_name)+" за  I квартал "+ mnt_syear(m_mnt1)
  ENDIF
  IF mnt_month(m_mnt1)==4.AND.mnt_month(m_mnt2)==6
    RETURN ALLTRIM(m_name)+" за  II квартал "+ mnt_syear(m_mnt1)
  ENDIF
  IF mnt_month(m_mnt1)==7.AND.mnt_month(m_mnt2)==9
    RETURN ALLTRIM(m_name)+" за  III квартал "+ mnt_syear(m_mnt1)
  ENDIF
  IF mnt_month(m_mnt1)==10.AND.mnt_month(m_mnt2)==12
    RETURN ALLTRIM(m_name)+" за  IV квартал "+ mnt_syear(m_mnt1)
  ENDIF
  IF mnt_month(m_mnt1)==1.AND.mnt_month(m_mnt2)==6
    RETURN ALLTRIM(m_name)+" за  I пiврiччя "+ mnt_syear(m_mnt1)
  ENDIF
  IF mnt_month(m_mnt1)==7.AND.mnt_month(m_mnt2)==12
    RETURN ALLTRIM(m_name)+" за  II пiврiччя "+ mnt_syear(m_mnt1)
  ENDIF
ENDIF
RETURN ALLTRIM(m_name)+" з "+ mnt_dtoc(m_mnt1)+ " по " + mnt_dtoc(m_mnt2)
FUNCTION StoStr3(m_registr,n_len,n_dec)
  LOCAL c_delim:="'",m_len:=IF(n_len<>NIL,n_len,16),;
  m_dec,x:=ABS(INT(m_registr))
  LOCAL y:=ABS(m_registr)-x
  LOCAL c_buf:="",m_str:=ALLTRIM(str(x,18))
  LOCAL n:=INT((LEN(m_str)+2)/3),i
if m_registr==0
  IF VAL(buf->level)<=0.OR.VAL(buf->level)>LEN(a_total)
    return SPACE(m_len)
  ENDIF
  IF a_total[VAL(buf->level),2]=="0" // Тип итога
    return SPACE(m_len)
  else
   IF n_dec==0
    RETURN PADL("0",m_len)
  ELSE
    RETURN PADL("0,"+REPLICATE("0",n_dec),m_len)
  ENDIF
  endif
endif
  m_str:=PADL(m_str,3*n)
  FOR i:=1 TO n-1
    c_buf:=c_buf+SUBSTR(m_str,(i-1)*3+1,3)+c_delim
  NEXT
  c_buf:=LTRIM(c_buf+RIGHT(m_str,3))
  m_dec:=IF(n_dec==NIL,m_len-LEN(c_buf)-2,n_dec)
  IF m_dec<>0
    y:=ROUND(y,m_dec+2)
//    IF ROUND(y,m_dec)<>0
    m_str:=ALLTRIM(STR(ROUND(y,m_dec),m_dec+2,m_dec));n:=LEN(m_str)
//      FOR i:=n TO 1 STEP -1
//        IF SUBSTR(m_Str,i,1)<>"0"
//          EXIT
//        ENDIF
//      NEXT
    c_buf:=c_buf+","+SUBSTR(m_str,3)    //SUBSTR(SUBSTR(m_str,1,i),3,i)
//  ENDIF
  ENDIF
  IF m_registr<0
    c_buf:="-"+c_buf
  ENDIF
  IF LEN(c_buf)<=m_len
    c_buf:=PADL(c_buf,m_len)
  ELSE
    c_buf:=REPLICATE("*",m_len)
  ENDIF
RETURN c_buf
STATIC Function  InitMsEsc(a_esc1,a_esc2)
LOCAL i
ASIZE(a_esc1,LEN(a_total))
ASIZE(a_esc2,LEN(a_total))
AFILL(a_esc1,"")
AFILL(a_esc2,"")
FOR i:=1 TO LEN(a_total)

  // жирный шрифт
  IF a_total[i,5]=="1"
    a_esc1[i]+=CHR(K_ESC)+"E"
    a_esc2[i]+=CHR(K_ESC)+"F"
  ENDIF

  // наклонный
  IF a_total[i,6]=="1"
    a_esc1[i]+=CHR(K_ESC)+"4"
    a_esc2[i]+=CHR(K_ESC)+"5"
  ENDIF
  //подчеркнутый
  IF a_total[i,7]=="1"
    a_esc1[i]+=CHR(K_ESC)+"-1"
    a_esc2[i]+=CHR(K_ESC)+"-0"
  ENDIF

NEXT
RETURN .T.
STATIC Function SetMsEsc(esc)
LOCAL n_row:=PROW(),n_col:=PCOL()
@PROW(),PCOL() SAY esc[VAL(buf->level)]
SETPRC(n_row,n_col)
RETURN .T.
STATIC FUNCTION ScrView(m_browse)
LOCAL n_win:=WOPEN(0,0,MAXROW(),MAXCOL()),i,n_pos
  @0,0,maxrow(),maxcol() BOX B_DOUBLE+" " COLOR "w/b"
      n_pos:=1
      @1,57 SayDisp "Сторiнка   " COLOR "W+/B"
      @1,70 SayDisp "Рядок   " COLOR "W+/B"
      FOR i:=1 TO m_browse:ColCount
          @i,1 SayDisp LEFT(m_browse:GetColumn(i):heading,20) COLOR "w/b"
      NEXT
      DO WHILE .t.
        @1,66 SayDisp m_page COLOR "GR+/B" PICTURE "999"
        @1,76 SayDisp m_line COLOR "GR+/B" PICTURE "99"
        FOR i:=1 TO m_browse:ColCount
          @i,22 SayDisp EVAL(m_browse:GetColumn(i):block) COLOR "w+/b*"
        NEXT
      @n_pos,22 SayDisp EVAL(m_browse:GetColumn(n_pos):block) COLOR "n/w"
      @n_pos,1 SayDisp LEFT(m_browse:GetColumn(n_pos):heading,20) COLOR "w+/b"
      i:=INKEY(0)
      @n_pos,22 SayDisp EVAL(m_browse:GetColumn(n_pos):block) COLOR "w+/b*"
      @n_pos,1 SayDisp LEFT(m_browse:GetColumn(n_pos):heading,20) COLOR "w/b"
      DO CASE
        CASE i==K_ESC
          EXIT
      CASE i==K_RIGHT
        n_pos:=IF(n_pos==m_browse:ColCount,m_browse:ColCount,n_pos+1)
      CASE i==K_LEFT
        n_pos:=IF(n_pos==1,1,n_pos-1)
      CASE i==K_DOWN
        EVAL(m_browse:SkipBlock,1)
      CASE i==K_UP
        EVAL(m_browse:SkipBlock,-1)
      CASE i==K_PGUP
        EVAL(m_browse:SkipBlock,-20)
      CASE i==K_PGDN
        EVAL(m_browse:SkipBlock,20)
      CASE i==K_CTRL_PGUP
        EVAL(m_browse:GoTopBlock)
      CASE i==K_CTRL_PGDN
        EVAL(m_browse:GoBottomBlock)
      ENDCASE
      ENDDO
      WCLOSE(n_win)
RETURN .T.
