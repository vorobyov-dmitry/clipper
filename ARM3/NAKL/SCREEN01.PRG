#include "new.ch"
#include "Pass.ch"
#include "menu.ch"
// #INCLUDE "SETCURS.CH"
#DEFINE M_REC     A_FORM[I,1]
#DEFINE M_NUM     A_FORM[I,2]
#DEFINE M_POLE    A_FORM[I,3]
#DEFINE M_ROW     A_FORM[I,4]
#DEFINE M_COL     A_FORM[I,5]
#DEFINE M_PICT    A_FORM[I,6]
#DEFINE M_VAR     A_FORM[I,7]
#DEFINE M_SCR     A_FORM[I,8]
#DEFINE M_CLR     A_FORM[I,9]
// #DEFINE SAVEVIDEO A_FORM[I,8]:=SAVESCREEN(A_FORM[I,4],A_FORM[I,5],A_FORM[I,4],A_FORM[I,5]+LEN(A_FORM[I,7]))
// #DEFINE RESTVIDEO RESTSCREEN(A_FORM[I,4],A_FORM[I,5],A_FORM[I,4],A_FORM[I,5]+LEN(A_FORM[I,7]),A_FORM[I,8])
// #command DISPLAYVIDEO => ;
MEMVAR m_workpath

STATIC m_clr:="w/b,w/b,b/w,n/w,R/W",m_bord:=B_SINGLE+" "
Function SCR(var,var2)
  LOCAL m_var:=IF(EMPTY(var),"d:\buhgal\js\",var)
  LOCAL i,j,k,n,m_br,m_col,m_screen,m_key,l_delete:=.f.
  LOCAL m_get:=GetNew(),GetList:={},m_screen1,a_data:={}
  LOCAL m_scr,m_name,m_str1,m_str2,m_clr,m_high,m_width,m_text
  LOCAL m_row,m_col1,m_file
  DCL menu
  LOCAL a_col:={;
        {COLBR(screen->p01),"Код формы"},;
        {COLBR(screen->str1),"Заголовок"},;
        {COLBR(screen->str2),"Статусная строка"},;
        {COLBR(screen->clr),"Цвет"},;
        {COLBR(screen->row),"Строка"},;
        {COLBR(screen->col),"Столбец"},;
        {COLBR(screen->high),"Высота"},;
        {COLBR(screen->width),"Ширина"},;
        {{||IF(.NOT.EMPTY(SUBSTR(screen->vd,1,10)),SUBSTR(screen->vd,1,10),SPACE(10))},"Текст формы"},;
        {COLBR(screen->bord),"Cимволы границы"},;
        {COLBR(screen->fl),"Используемый файл"}}
   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
SetCancel ( .f. )
SetCursor (0)
Set ( _SET_ESCAPE     , .t. )
Set ( _SET_SCOREBOARD , .f. )
Set ( _SET_BELL       , .f. )
Set ( _SET_DECIMALS   ,  5  )
Set ( _SET_DELETED    , .t. )
Set ( _SET_CONFIRM    , .f. )
SET (_SET_EXIT        , .t. )
SETBLINK(.f.)
SET CENTURY       OFF
SET DATE          BRITISH
IF .NOT.file(m_var+"screen.dbf")
  DispMessage("Не найден файл;"+m_var+"screen.dbf")
  RETURN .f.
ENDIF
IF .NOT.file(m_var+"screen.ntx")
  DispMessage("Не найден файл;"+m_var+"screen.ntx")
  RETURN .f.
ENDIF
   SET KEY K_F10 TO Calc
   SETKEY(K_INS,{||READINSERT(.NOT.READINSERT()),;
                    SETCURSOR(IF(READINSERT(),1,3))})
   keyboard ''
   USE (m_var+"screen") INDEX (m_var+"screen") NEW
   USE (m_var+"tbget")  INDEX (m_var+"tbget")  NEW
//   USE (m_var+"screen") INDEX (m_var+"screen") NEW
PUBLIC M_WORKPATH:=IF(EMPTY(var2),"d:\buh\plat\",var2)
   m_br:=TBROWSEDB(3,0,MAXROW()-1,MAXCOL())
  @2,0 SayDisp REPLICATE("═",MAXCOL()+1) COLOR "w/b"
  @1,0 SayDisp PADC("Перечень видеоформ",MAXCOL()+1) COLOR "w+/b"
  m_br:ColorSpec:="w/b,b/w,bg+/n,n/bg+,W+/B,gr+/b"
  m_br:SkipBlock:={|m_count|MySkip(m_count)}
  m_br:goBottomBlock:={||screen->(DBGOBOTTOM())}
  m_br:goTopBlock:={||screen->(DBGOTOP())}
  n:=LEN(a_col)
  FOR i:=1 TO n
      m_col:=TBCOLUMNNEW()
      m_col:block:=a_col[i,1]
      m_col:heading:=ALLTRIM(a_col[i,2])
      m_col:headsep:="┬─"
      m_col:footsep:="╧═"
      m_col:colsep:="│"
      IF i>2
        m_col:ColorBlock:={|X|{5,2}}
      ELSE
        m_col:ColorBlock:={|X|{1,2}}
      ENDIF
      m_br:AddColumn(m_col)
    NEXT
    m_br:ColPos:=1
    m_br:RowPos:=1
    m_br:freeze:=1
ADD MENU UP_DOWN
ADD MENU LEFT_RIGHT
ADD MENU NAME " Из~менение" ;
ITEMS   {"Исправить данное         Enter   ",;
        "Удалить форму            Delete  ",;
        "Редактирование формы   Ctrl+Enter",;
        "Скопировать форму        F5      ",;
        "Создать новую            Insert  "} ;
KEY {K_ENTER,K_DEL,K_CTRL_RET,K_F5,K_INS}
ADD MENU NAME " Импорт/~Экспорт" ITEMS {"Импорт текста       F3 " ,"Экспорт текста      F4 " } ;
KEY {K_F3,K_F4}
INIT MENU
  @MAXROW(),0 SayMenu (padc("~F~8-Меню",MAXCOL()+3))
  DO WHILE .t.
    STABILIZE BROWSE m_br
    m_key:=INKEY(0)
    DEAL MENU
      DO CASE
         CASE  m_key==K_F3
          IF ANSWER("Импортировать текст;в форму ?")==YES
            m_file:=GetFname()
            MEMOWRIT("scr.old",Screen->vd)
            IF .NOT.EMPTY(m_file)
              Screen->vd:=MEMOREAD(m_file)
            ENDIF
          ENDIF
         CASE  m_key==K_CTRL_F3
          IF ANSWER("Импортировать текст;в форму ?")==YES
            m_file:=GetFname()
            MEMOWRIT("scr.old",Screen->vd)
            IF .NOT.EMPTY(m_file)
              m_str1:=MEMOREAD(m_file)
              m_str2:=crypt(@m_str1,CHARMIRR(PASSWORD1))
              Screen->vd:=m_str2
            ENDIF
          ENDIF
         CASE  m_key==K_F4
          IF ANSWER("Экспортировать текст ?")==YES
            m_file:=PADR(screen->fl,60)
            SAVEPAR()
            @8,8,11,33 BOX B_SINGLE + " " COLOR "w/bg"
            SHADOW(8,8,11,33)
            @9,10 SayDisp "Введите имя файла" COLOR "n/bg"
            @10,10 Get m_file PICTURE "@s20" COLOR "GR+/n"
            READ
            SAVEPAR(1)
            IF FILE(m_file)
              IF ANSWER("Файл "+ALLTRIM(m_file)+" существует;Перезаписать ?")<>YES
                LOOP
              ENDIF
            ENDIF
            MEMOWRIT(m_file,Screen->vd)
          ENDIF
         CASE  m_key==K_CTRL_F4
          IF ANSWER("Экспортировать текст ?")==YES
            m_file:=PADR(screen->fl,60)
            SAVEPAR()
            @8,8,11,33 BOX B_SINGLE + " " COLOR "w/bg"
            SHADOW(8,8,11,33)
            @9,10 SayDisp "Введите имя файла" COLOR "n/bg"
            @10,10 Get m_file PICTURE "@s20" COLOR "GR+/n"
            READ
            SAVEPAR(1)
            IF FILE(m_file)
              IF ANSWER("Файл "+ALLTRIM(m_file)+" существует;Перезаписать ?")<>YES
                LOOP
              ENDIF
            ENDIF
            MEMOWRIT(m_file,crypt(Screen->vd,CHARMIRR(PASSWORD1)))
          ENDIF

        CASE  m_key==K_F5
        a_data:={screen->p01,screen->str1,screen->str2,;
screen->clr,screen->row,screen->col,screen->high,screen->width,;
screen->vd,screen->bord,screen->fl}

        screen->(DBAPPEND())
        screen->p01   :=a_data[1]
        screen->str1  :=a_data[2]
        screen->str2  :=a_data[3]
        screen->clr   :=a_data[4]
        screen->row   :=a_data[5]
        screen->col   :=a_data[6]
        screen->high  :=a_data[7]
        screen->width :=a_data[8]
        screen->vd    :=a_data[9]
        screen->bord  :=a_data[10]
        screen->fl  :=a_data[11]
        m_br:RefreshAll()
         CASE  m_key==K_CTRL_RET
              IF m_br:ColPos<>9
                EditForm()
              ELSE
                SET CURSOR ON
                SET ESCAPE ON
                m_screen:=SAVESCREEN(screen->row+1,screen->col+1,SCREEN->row+screen->high-2,screen->col+screen->width-2)
                set color TO "GR+/N,N/BG"
                set color TO (IF(EMPTY(screen->clr),"GR+/N,N/BG",screen->clr))
                screen->vd:=crypt(MEMOEDIT(crypt(Screen->vd,CHARMIRR(PASSWORD1)),screen->row+1,screen->col+1,SCREEN->row+screen->high-2,screen->col+screen->width-2,.t.,,250),CHARMIRR(PASSWORD1))
                RESTSCREEN(screen->row+1,screen->col+1,SCREEN->row+screen->high-2,screen->col+screen->width-2,m_screen)
                SET CURSOR OFF
  //              SET ESCAPE OFF
                ENDIF
         CASE  m_key==K_ENTER
              SET CURSOR ON
              SET ESCAPE ON
              IF m_br:ColPos<>9
              m_get:row:=ROW()
              m_get:col:=COL()
              m_get:colorSpec:="n/w,GR+/N"
              m_get:block:={|x|IF(x==NIL,EVAL(a_col[m_br:ColPos,1]),EVAL(a_col[m_br:ColPos,1],x))}
              READMODAL({m_get})
              SET CURSOR OFF
//              SET ESCAPE OFF
            ELSE
              SET CURSOR ON
              SET ESCAPE ON
              m_screen:=SAVESCREEN(screen->row+1,screen->col+1,SCREEN->row+screen->high-2,screen->col+screen->width-2)
              set color TO "GR+/N,N/BG"
              set color TO (IF(EMPTY(screen->clr),"GR+/N,N/BG",screen->clr))
              screen->vd:=MEMOEDIT(screen->vd,screen->row+1,screen->col+1,SCREEN->row+screen->high-2,screen->col+screen->width-2,.t.,"DIMA01",250)
              RESTSCREEN(screen->row+1,screen->col+1,SCREEN->row+screen->high-2,screen->col+screen->width-2,m_screen)
              SET CURSOR OFF
//              SET ESCAPE OFF
              ENDIF
              m_br:refreshCurrent()
              STABILIZE BROWSE m_br
        CASE m_key == K_INS  // Ввод формы
          m_screen1:=SAVESCREEN(6,2,16,79)
          CLEARWIN(6,2,16,74,"w/bg+")
          m_scr:=BLANK(screen->p01,.t.)
          m_str1:=BLANK(screen->str1,.t.)
          m_str2:=BLANK(screen->str2,.t.)
          m_clr:=BLANK(screen->clr,.t.)
          m_row:=0
          m_col1:=0
          m_high:=BLANK(screen->high,.t.)
          m_width:=BLANK(screen->width,.t.)
          m_text:=""
          @6,2   SAY "Код формы   >" COLOR "bg+/n"
          @7,2   SAY "Имя формы   >" COLOR "bg+/n"
          @8,2   SAY "Заголовок   >" COLOR "bg+/n"
          @9,2   SAY "Стат. строка>" COLOR "bg+/n"
          @10,2   SAY "Цвет        >" COLOR "bg+/n"
          @11,2  SAY "Срока        "  COLOR "bg+/n"
          @12,2  SAY "Столбец     >"  COLOR "bg+/n"
          @13,2  SAY "Высота формы>"  COLOR "bg+/n"
          @14,2  SAY "Ширина формы>"  COLOR "bg+/n"
        SET CURSOR ON
        SET ESCAPE ON
          @6,15  GET m_scr  COLOR "n/w,GR+/N"
          @8,15  GET m_str1 COLOR "n/w,GR+/N"
          @9,15  GET m_str2 COLOR "n/w,GR+/N"
          @10,15 GET m_clr  COLOR "n/w,GR+/N"
          @11,15 GET m_row  COLOR "n/w,GR+/N"  PICTURE "999" VALID m_row>=0.AND.m_row<MAXROW()-2
          @12,15 GET m_col1  COLOR "n/w,GR+/N" PICTURE "999" VALID m_col1>=0.AND.m_col1<MAXCOL()-2
          @13,15 GET m_high COLOR "n/w,GR+/N"  PICTURE "999" VALID m_high>2.AND.m_high<MAXROW()-2
          @14,15 GET m_width COLOR "n/w,GR+/N" PICTURE "999" VALID m_width>2.AND.m_width<MAXCOL()-2
          READ
          IF LASTKEY()<>K_ESC
              m_screen:=SAVESCREEN(0,0,m_high-2,m_width-2)
//              set color TO "GR+/N,N/BG"
              set color TO (IF(EMPTY(m_clr),"GR+/N,N/BG",m_clr))
              m_text:=MEMOEDIT(m_text,0,0,m_high-2,m_width-2,.t.)
              RESTSCREEN(0,0,m_high-2,m_width-2,m_screen)
              IF LASTKEY()<>K_ESC
                screen->(DBAPPEND())
                screen->p01  :=  m_scr
                screen->str1 :=  m_str1
                screen->str2 :=  m_str2
                screen->clr  :=  m_clr
                screen->high :=  m_high
                screen->row :=  m_row
                screen->col :=  m_col1
                screen->width:=  m_width
                screen->vd :=  m_text

              ENDIF
              m_br:refreshAll()
          ENDIF
          RESTSCREEN(6,2,16,79,m_screen1)
          SET CURSOR OFF
//          SET ESCAPE OFF
         DEAL BROWSE m_br KEY m_key
          CASE m_key == K_F10            ; Calc()
         CASE m_Key == K_DEL                                    /* удаление записи */
               IF  ANSWER("Вы действительно хотите уничтожить запись ?")==YES
                     screen->(DBDELETE())
                     screen->(DBSKIP(-1))
                     screen->(DBSKIP(1))
                     m_br:RefreshAll()
                ENDIF
      ENDCASE
  ENDDO
  CLOSE base screen,tbget
  RETURN .t.
STATIC FUNCTION myskip( n )
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
       screen->( DBSKIP() )
       // Если конец файла
       IF ( screen->( EOF() ) )
        screen->( DBSKIP( -1 ) )
        EXIT
       ENDIF
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       screen->( DBSKIP( -1 ) )
       IF ( screen->( BOF() ) )
          EXIT
       END
       ncount--
   ENDDO
END
RETURN ( ncount )
// Выбор поля данных
STATIC function GetVarf(a_file)
LOCAL n_win:=WOPEN(0,0,20,40)
LOCAL m_br,oldwin:=WSELECT(),n_ret:=0
LOCAL n:=LEN(a_file),i:=1,m_col,j,m_key:=0
  WSELECT(n_win)
  IF LEN(a_file)>0
  m_br:=TBROWSENEW(0,0,MAXROW(),MAXCOL())
  m_br:ColorSpec:="n/w,w/b,bg/n,n/bg,W+/BG,gr+/b"
  m_br:SkipBlock:={|m_count|j:=IF(m_count>0,IF(i+m_count<=n,m_count,n-i),IF(i+m_count>1,m_count,-i+1)),i+=j,j}
  m_br:goBottomBlock:={||i:=n}
  m_br:goTopBlock:={||i:=1}
  m_col:=TBCOLUMNNEW()
  m_col:block:={||PADR(a_file[i,1],18)}
  m_col:heading:="Поле базы данных"
  m_col:headsep:="┬─"
  m_col:footsep:="╧═"
  m_col:colsep:="│"
  m_col:ColorBlock:={3,5}
  m_br:AddColumn(m_col)
  m_br:ColPos:=1
  m_br:RowPos:=1
  DO WHILE .t.
    STABILIZE BROWSE m_br
    m_key:=INKEY(0)
    DO CASE
        CASE  m_key==K_ENTER
          n_ret:=i
          EXIT
        CASE m_key == K_DOWN ;  m_br:down();m_br:refreshCurrent()
        CASE m_key == K_CTRL_PGUP      ; m_br:gotop();m_br:refreshAll()
        CASE m_key == K_CTRL_PGDN      ; m_br:gobottom();m_br:refreshAll()
        CASE m_key == K_PGUP      ; m_br:pageUp();m_br:refreshAll()
        CASE m_key == K_PGDN      ; m_br:pageDown();m_br:refreshAll()
        CASE m_key == K_UP;m_br:up();m_br:refreshCurrent()
        CASE m_key == K_ESC
               EXIT
      ENDCASE
  ENDDO
ELSE
  DispError("Нет файлов")
endif
  WCLOSE()
  WSELECT(oldwin)
  RETURN (n_ret)


STATIC function EditForm()
LOCAL n_win1:=WOPEN(screen->row,screen->col,screen->row+screen->high-1,screen->col+screen->width-1)
LOCAL GetList:={},m_screen
LOCAL n,i,j,k,m_str1,m_str2,m_key1,m_key2,m_buf
LOCAL a_form:={},m_text,l_pic:=.t.,a_file:={}
WSELECT(n_win1)
USE (m_workpath+screen->fl) NEW  ALIAS work01
tbget->(DS(Screen->p01))
FOR i:=1 TO work01->(Fcount())
  AADD(a_file,LOWER(ALLTRIM(screen->fl))+"->"+ALLTRIM(LOWER(work01->(FIELDNAME(i)))))
NEXT
i:=1
do while Screen->p01=tbget->p01.and..not.eof()
    m_buf:=work01->(fieldget(fieldnum(alltrim(tbget->name))))
    IF m_buf==NIL
      Disperror("Ошибка при трансляции выражения"+tbget->name)
      CLOSE work01
      RETURN .t.
    ENDIF
    aadd(a_form,{tbget->(recno()),tbget->p02,tbget->name,tbget->row,;
    tbget->col,rtrim(tbget->pict),transform(m_buf,alltrim(tbget->pict)),"",;
    IF(EMPTY(tbget->clr),"w+/b,b/w,GR+/N",ALLTRIM(tbget->clr))})
    tbget->(dbskip())
enddo
m_text:=screen->vd
m_str1:="~3"+SUBSTR(RTRIM(screen->str1),1,screen->width+10)
m_str2:="~4"+SUBSTR(RTRIM(screen->str2),1,screen->width+10)
DO WHILE .t.
  IF l_pic
    @0,0,MAXROW(),MAXCOL() BOX IF(EMPTY(screen->bord),m_bord,IF(LEN(RTRIM(screen->bord))==8,RTRIM(screen->bord)+" ",RTRIM(screen->bord))) ;
    COLOR (IF(EMPTY(screen->clr),TOKEN(m_clr,",",1),TOKEN(screen->clr,",",1)))
    @0,INT((screen->width-LEN(m_str1)+NUMAT("~",m_str1)*2)/2) SayText m_str1 COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
    @MAXROW(),INT((screen->width-LEN(m_str2)+NUMAT("~",m_str2)*2)/2) SayText m_str2 COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
    n:=MLCOUNT(m_text)
    FOR i:=1 TO n
      @i,1 SayText "~2"+RTRIM(MEMOLINE(m_text,screen->width+10,i)) COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
      IF i==screen->high-1
        EXIT
      ENDIF
    NEXT
    i:=1
    aeval(a_form,{||setpos(a_form[i,4],a_form[i,5]),;
    a_form[i,8]:=savescreen(a_form[i,4],a_form[i,5],a_form[i,4],a_form[i,5]+len(a_form[i,7])),;
    dispout(a_form[i,7],TOKEN(a_form[i,9],",",1)),i++})
    l_pic:=.f.
  ENDIF
  i:=INKEY(0)
  DO CASE
      CASE i==K_ALT_F4
//         EditVal(a_val,a_file,n_row)

      CASE i==K_F4
        I:=1
        DO WHILE .T.
          @M_ROW,M_COL SAY M_VAR COLOR "GR+/R"
          @0,0 SAY M_POLE PICTURE 'XXXXXXXXXXXXXXXXXXX' COLOR 'N/W'
          M_KEY1:=INKEY(0)
          @M_ROW,M_COL SAY M_VAR COLOR "N/W"
          DO CASE
            CASE M_KEY1==K_UP
              IF (I==1)
                I:=LEN(A_FORM)
              ELSE
                I--
              ENDIF
            CASE M_KEY1==K_DOWN
              IF I==LEN(A_FORM)
                I:=1
              ELSE
                I++
              ENDIF
          CASE M_KEY1==K_ESC.AND.ANSWER("Аннулировать изменения и выйти?")==YES
            EXIT
            CASE M_KEY1==K_F12.OR.m_key1==K_CTRL_END
              FOR I:=1 TO LEN(A_FORM)
                TBGET->(DBGOTO(M_REC))
                TBGET->P02  :=  M_NUM
                TBGET->NAME :=  M_POLE
                TBGET->ROW  :=  M_ROW
                TBGET->COL  :=  M_COL
                TBGET->PICT :=  M_PICT
              NEXT
              EXIT
            CASE M_KEY1==K_ENTER
              DO WHILE .T.
                @M_ROW,M_COL SAY M_VAR COLOR 'N/BG'
                M_KEY2:=INKEY(0)
                RESTSCREEN(A_FORM[I,4],A_FORM[I,5],A_FORM[I,4],A_FORM[I,5]+LEN(A_FORM[I,7]),A_FORM[I,8])
//                RESTVIDEO
                DO CASE
                  CASE M_KEY2==K_UP
                    IF M_ROW>1
                      M_ROW--
                    ENDIF
                  CASE M_KEY2==K_DOWN
                    IF M_ROW<MAXROW()-1
                      M_ROW++
                    ENDIF
                  CASE M_KEY2==K_LEFT
                    IF M_COL>0
                      M_COL--
                    ENDIF
                  CASE M_KEY2==K_RIGHT
                    IF M_COL+LEN(M_VAR)-1<MAXCOL()
                      M_COL++
                    ENDIF
                  CASE M_KEY2==K_ESC.OR.M_KEY2==K_ENTER
                    EXIT
                ENDCASE
                A_FORM[I,8]:=SAVESCREEN(A_FORM[I,4],A_FORM[I,5],A_FORM[I,4],A_FORM[I,5]+LEN(A_FORM[I,7]))
              ENDDO
          ENDCASE
        ENDDO
    CASE i==K_CTRL_END.OR.i==K_F12
        screen->str1:=substr(m_str1,3)
        screen->str2:=substr(m_str2,3)
        screen->vd:=m_text
        EXIT
  CASE i==K_ESC.and.ANSWER("УНИЧТОЖИТЬ ИЗМЕНЕНИЯ?")==YES
        EXIT
  CASE i==K_CTRL_RET
      l_pic:=.t.
    CASE i==K_BS
      m_str2:=PADR(SUBSTR(m_str2,3),screen->width+10)
      m_screen:=SAVESCREEN(MAXROW(),0,MAXROW(),MAXCOL())
      SET CURSOR ON
      @MAXROW(),1 Get m_str2 COLOR("GR+/n") PICTURE ("@s"+LTRIM(STR(screen->width-1,3)))
      READ
      SET CURSOR OFF
      m_str2:="~4"+RTRIM(m_str2)
      RESTSCREEN(MAXROW(),0,MAXROW(),MAXCOL(),m_screen)
      @MAXROW(),INT((screen->width-LEN(m_str2)+NUMAT("~",m_str2)*2)/2) SayText m_str2 COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
    CASE i==K_TAB
      m_str1:=PADR(SUBSTR(m_str1,3),screen->width+10)
      m_screen:=SAVESCREEN(0,0,0,MAXCOL())
      SET CURSOR ON
      @0,1 Get m_str1 COLOR("GR+/n") PICTURE ("@s"+LTRIM(STR(screen->width-1,3)))
      READ
      SET CURSOR OFF
      m_str1:="~3"+RTRIM(m_str1)
      RESTSCREEN(0,0,0,MAXCOL(),m_screen)
      @0,INT((screen->width-LEN(m_str1)+NUMAT("~",m_str1)*2)/2) SayText m_str1 COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
    CASE CHR(i)==" "
        SET CURSOR ON
        m_text:=MEMOEDIT(m_text,1,1,MAXROW()-1,MAXCOL()-1,.t.,,90)
        SET CURSOR OFF
        l_pic:=.t.
    ENDCASE
ENDDO
WCLOSE (n_win1)
CLOSE work01
RETURN .t.
Function DIma01(MODE,LINE,COL)
  if MODE==1.OR.MODE==2
    DO CASE
      CASE lastkey()==K_CTRL_END.OR.lastkey()==K_F12
        RETURN K_CTRL_W
/*
      CASE CHR(lastkey())=="Q"
        RETURN  ASC("┌")
      CASE CHR(lastkey())=="A"
        RETURN  ASC("├")
      CASE CHR(lastkey())=="Z"
        RETURN  ASC("└")
      CASE CHR(lastkey())=="W"
        RETURN  ASC("┬")
      CASE CHR(lastkey())=="S"
        RETURN  ASC("┼")
      CASE CHR(lastkey())=="X"
        RETURN  ASC("┴")
      CASE CHR(lastkey())=="E"
        RETURN  ASC("┐")
      CASE CHR(lastkey())=="D"
        RETURN  ASC("┤")
      CASE CHR(lastkey())=="C"
        RETURN  ASC("┘")
      CASE CHR(lastkey())=="-"
        RETURN  ASC("─")
      CASE CHR(lastkey())=="F"
        RETURN  ASC("│") */
     ENDCASE
  ENDIF
RETURN 0
