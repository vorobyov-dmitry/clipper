#include "new.ch"
#include  "menu.ch"
MEMVAR m_dbspath,m_workpath,m_mnt,m_mash,m_temppath,a_menu
Function ReadMaket(NumMaket,m_kod,b_setname)
  Local i,a_const:={},a_dop:={}
//  LOCAL n:=28
  IF .NOT.maket->(DS(m_kod+NumMaket+"00"))
    DispError("Службова помилка !!! ;Не знайден макет вводу № "+NumMaket)
    IF .NOT.maket->(DS(m_kod+"01"))
      DispError("Фатальна помилка !!! ;Не знайден макет вводу № 01")
      BREAK
    ELSE
      IF ANSWERu("Виконувати ввод по макету 01?")<>YES
        RETURN a_const
      ENDIF
      NumMaket:="01"
    ENDIF
  ENDIF
    i:=1
    a_dop:={LEFT(maket->num,2),LEFT(maket->name,30),ALLTRIM(maket->value)}
    maket->(DBSKIP())
    DO WHILE m_kod==maket->kod.AND.maket->num==NumMaket
      AADD(a_const,{"","","","","",""})
      a_const[i,1]:=maket->name
      DO CASE
        CASE maket->type=="C"
          a_const[i,2]:=TRANSFORM(maket->value,ALLTRIM(maket->pict))
        CASE maket->type=="N"
          a_const[i,2]:=VAL(ALLTRIM(maket->value))
        CASE maket->type=="D"
          a_const[i,2]:=CTOD(ALLTRIM(maket->value))
        CASE maket->type=="M"
          a_const[i,2]:=ALLTRIM(maket->value)
      ENDCASE
      a_const[i,3]:=maket->ent;a_const[i,4]:=maket->view;a_const[i,5]:=ALLTRIM(maket->pict)
      a_const[i,6]:=""
      maket->(DBSKIP())
      i++
    ENDDO
    AADD(a_const,a_dop)
    a_const:=EVAL(b_SetName,a_const) // Установить расшифровки кодов
RETURN a_const

Function SkipDb2(n,m_block)
  LOCAL n_count:=0,m_recno
  IF n>=0
    DO WHILE n_count<n
      m_recno:=RECNO()
      DBSKIP()
      DO WHILE .NOT.EOF().AND.EVAL(m_block).AND.maket->punkt<>"00"
        DBSKIP()
      ENDDO
      IF EOF().OR..NOT.EVAL(m_block)
        DBGOTO(m_recno)
        EXIT
      ENDIF
      n_count++
    ENDDO
  ELSE
    DO WHILE n_count>n
      m_recno:=RECNO()
      DBSKIP(-1)
      DO WHILE .NOT.BOF().AND.EVAL(m_block).AND.maket->punkt<>"00"
        DBSKIP(-1)
      ENDDO
      IF BOF().OR..NOT.EVAL(m_block)
        DBGOTO(m_recno)
        EXIT
      ENDIF
      n_count--
    ENDDO
  ENDIF
  RETURN (n_count)
Function SelMaket(a_const,m_kod,b_setName,b_edit)
  Local m_key,i,j,k,GetList:={},m_screen
  LOCAL a_const1:={}
  DCL LIST
  DCL MENU
  a_const:={}
  SavePar();Select maket
  CrList1("MAKET",@m_browse,@l_print)
  m_browse:SkipBlock:={|n|maket->(SkipDb2(n,{||maket->kod==m_kod}))}
  m_browse:GoBottomBlock:={||maket->(dbseek(m_kod,.t.)),maket->(DBEVAL(,,{||maket->kod==m_kod})),maket->(DBSKIP(-1))}
  m_browse:GotopBlock:={||maket->(DBSEEK(m_kod+"0100",.f.))}
  ADD menu UP_DOWN
  ADD menu NAME "~Вибрати" ITEMS {"Вибрати Enter","Редактировати <Ctrl>+<Enter>","Вихiд з збереженням F12"} KEY {K_ENTER,K_CTRL_RET,K_F12}
  EVAL(m_browse:GoTopBlock)
  INIT MENU
  DISPLAYLIST
  DO WHILE .T.
    DISPLAY BROWSE m_browse
    m_key:=INKEY(0)
    deal menu
    DO CASE
    CASE m_key==K_CTRL_END.OR.m_key==K_F12
      EXIT
    CASE m_key==K_ESC
      ASIZE(a_const,0)
      EXIT
    DEAL BROWSE m_browse KEY m_key
    CASE m_key==K_ENTER
      a_const1:=ReadMaket(maket->num,m_kod,b_SetName)
      IF .NOT.EMPTY(a_const1)
        ASIZE(a_const,LEN(a_const1))
        ACOPY(a_const1,a_const)
      ENDIF
      EXIT
  CASE m_key==K_DEL
  CASE m_key==K_CTRL_RET
       SavePar()
       IF EMPTY(a_const)
        a_const:=ReadMaket(maket->num,m_kod,b_SetName)
      ENDIF
      a_const:=EVAL(b_edit,a_Const)
       SavePar(1)
       m_browse:refreshAll()
    ENDCASE
  ENDDO
  SavePar(1)
  IF EMPTY(a_const)
    RETURN .f.
  ENDIF
RETURN .t.
STATIC Function CrList1(m_var,m_browse,l_print)
    LOCAL m_col
    SELECT(m_var)
    sptabl1->(DBGOTOP())
    sptabl1->(dbseek(m_var))
    IF sptabl1->(FOUND())
      m_browse:=TBrowseDB(;
      IF(sptabl1->bt==0,3,sptabl1->bt),IF(sptabl1->lt==0,1,sptabl1->lt),;
      IF(sptabl1->tp==0,MAXROW()-1,sptabl1->tp),IF(sptabl1->nr==0,MAXCOL()-1,sptabl1->nr))
      m_browse:colorspec:=IF(EMPTY(sptabl1->clr),'W/B,B/W,GR+/b,GR+/N,N/BG,w+/b',sptabl1->clr)
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
      m_browse:goTopBlock    := { ||  DBGOTOP()  }
      m_browse:cargo        := ALLTRIM(sptabl1->cargo)
      SELECT (sptabl1->fl)
  ELSE
    DispErr("Службова помилка ;нема опису в DBROWSE "+m_var)
    RETURN .t.
  ENDIF
  sptabl->(DBGOTOP())
  sptabl->(dbseek(m_var))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==m_var
      m_Col           := TBColumnNew()
      IF sptabl->type=='02'
        m_col:block:=&("{||"+trn(ALLTRIM(sptabl->value))+"}")
      ELSE
        IF sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")
        ELSE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
        ENDIF
      ENDIF
      m_col:heading:=ALLTRIM(sptabl->heading)
      AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
      m_Col:colorblock:=  {|| {1,2}}
        IF sptabl->type=='01'
          m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
        ELSE
          m_Col:headsep    := "─";m_col:colsep:=" ";m_col:footsep:="══"
        ENDIF
      IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
      ENDIF
     Sptabl->(DBSKIP())
     m_browse:addColumn(m_col)
    ENDDO
    m_browse:freeze        := IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
  RETURN .t.
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
Function GetlApnd
RETURN .t.
Function CountNds
RETURN .t.
Function Spr01
RETURN .t.
Function Recurs(var)
  LOCAL i,m_func:=IF(var==NIL,UPPER(PROCNAME(1)),UPPER(var))
  LOCAL s1:="1"
 i := 2
 DO  WHILE i<20.AND..NOT.EMPTY(s1)
  IF (s1:=UPPER(PROCNAME(i)))==m_func
    DispError("Программа вже "+m_func+" активна")
    RETURN .t.
  ENDIF
  i++
 ENDDO
RETURN .f.
Function ReadList(a_get,n_pole,a_func,m_var)
LOCAL i:=n_pole,m_mode:=IF(m_var==NIL,0,m_var)
n_pole:=1;AEVAL(a_get,{|x|x:Display(),n_pole++})
n_pole:=i
DO WHILE .t.
  READMy({a_get[n_pole]},a_func)
  DO CASE
    CASE LASTKEY() == K_ESC
      RETURN 0
    CASE LASTKEY() == K_F12.OR.LASTKEY() == K_CTRL_END
      RETURN 1
    CASE LASTKEY() == K_PGUP
      n_pole:=1
    CASE LASTKEY() == K_PGDN
      n_pole:=LEN(a_get)
    CASE LASTKEY() == K_UP.OR.LASTKEY() == K_LEFT
      IF n_pole == 1
        IF m_mode==0
          BeepErr()
          KEYBOARD ""
        ELSE
          RETURN 3
        ENDIF
      ELSE
        n_pole--;LOOP
      ENDIF
    OTHERWISE
      IF n_pole < LEN(a_get)
        n_pole++
      ELSE
        RETURN 2
      ENDIF
  ENDCASE
ENDDO
RETURN 0
Function ViewOtch(var)
  LOCAL m_color,n_win1
  IF .NOT.FILE(m_Mash+var+'.txt')
    DispError("Данний звiт вiдсутнiй")
    RETURN .f.
  ENDIF
  m_color:=SETCOLOR("w/b")
n_win1:=WOPEN(4,0,20,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC(" Перегляд звiта",80) COLOR "n/w"
MEMOEDIT(MEMOREAD(m_mash+var+'.txt'),0,0,MAXROW(),MAXCOL(),.f.,"f002",254)
WCLOSE(n_win1)
WSELECT(0)
SETCOLOR(m_color)
RETURN .t.
Function f002(var1,var2,var3)
  LOCAL m_file:=m_mash+a_menu[LEN(a_menu)]+".txt"
  IF var1==1.OR.var1==2
    IF LASTKEY()==K_F2
      IF ALERT("Друкувати звiт ?",{"Да","Нi"},"n/bg,w/b")==1
        IF SPOOLACTIV().AND.SPOOLCOUNT()<6
            IF Is_Ready_Prn()
              SPOOLADD(m_file)
            ENDIF
        ELSE
          PRINTFILE(m_file,.t.)
        ENDIF
      ENDIF
    ENDIF
  ENDIF
RETURN 0
