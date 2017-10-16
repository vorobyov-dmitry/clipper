#include "new.ch"
MEMVAR    m_exepath

STATIC msg_color:="N/BG,N/BG" // 1-й цвет цвет рамки , 2й цвет цвет сообщения
STATIC BeepErr:={300,4}
STATIC Beep:={100,2}
STATIC Gauge_clr:="w+/bg,gr+/bg,b+/b,w+" // 1-й цвет рамки , 2-й Название ,3-й ИНДИКАТОР, 4-й процент
STATIC net_wait1:=2 // Ожидание блокировки записи
STATIC net_wait2:=2 // Ожидание добавления записи
STATIC net_wait3:=5 // Ожидание открытия файла
STATIC net_wait4:=5 // Ожидание открытия файла
STATIC IsBeep:=.t.  // Флаг звуковой индикации

Function SetClrMsg(var)
  IF var<>NIL.AND.VALTYPE(var)=="C"
    msg_color:=var
    RETURN msg_color
  ENDIF
RETURN msg_color

Function SetBeepMsg(var1,var2)
  IF var1<>NIL.AND.var2==NIL.AND.VALTYPE(Var1)=="N".AND.VALTYPE(Var2)=="N"
    Beep[1]:=var1;Beep[2]:=var2
    RETURN .t.
  ENDIF
RETURN .f.

Function SetErrBeepMsg(var1,var2)
  IF var1<>NIL.AND.var2==NIL.AND.VALTYPE(Var1)=="N".AND.VALTYPE(Var2)=="N"
    BeepErr[1]:=var1;BeepErr[2]:=var2
    RETURN .t.
  ENDIF
RETURN .f.

Function Beep(var1,var2)
  LOCAL x:=IF(var1==NIL,beep[1],var1)
  LOCAL y:=IF(var2==NIL,beep[2],var2)
  IF IsBeep
    TONE(x,y)
  ENDIF
RETURN .t.

Function BeepErr(var1,var2,var3,var4)
  LOCAL x:=IF(var1==NIL,beepErr[1],var1)
  LOCAL y:=IF(var2==NIL,beepErr[2],var2)
  LOCAL x1:=IF(var3==NIL,beep[1],var3)
  LOCAL y1:=IF(var4==NIL,beep[2],var4)
  IF IsBeep
    TONE(x,y);TONE(x1,y1);TONE(x,y)
  ENDIF
RETURN .t.

Function SetBeep(var)
  IF VALTYPE(var)=="L"
    IsBeep:=var
  ENDIF
RETURN IsBeep


FUNCTION DispMessage(m_str,clr,bell)
   LOCAL m_countcol:=0,m_countrow:=0,m_maxcol:=0,i:=0,m_screen,;
   m_color:=IF(clr==NIL,msg_color,clr)
   m_str:=m_str+';'
//   SaveCur()
   FOR I:=1 TO LEN(m_str)
      m_countcol++
      If SUBSTR(m_str,i,1)==';'
         IF m_countcol>m_maxcol
         m_maxcol:=m_countcol
         ENDIF
         m_countcol:=0
         m_countrow++
      EndIF
   ENDFOR
   m_screen:=SAVESCREEN(INT((MAXROW()-m_countrow-2)/2),INT((MAXCOL()-m_maxcol-4)/2),;
            INT((MAXROW()-m_countrow-2)/2)+m_countrow+1+1,INT((MAXCOL()-m_maxcol-4)/2)+m_maxcol+4+2)
   DISPBOX(INT((MAXROW()-m_countrow-2)/2),INT((MAXCOL()-m_maxcol-4)/2),;
            INT((MAXROW()-m_countrow-2)/2)+m_countrow+1,INT((MAXCOL()-m_maxcol-4)/2)+m_maxcol+4,;
            B_DOUBLE+" ",TOKEN(m_color, ",",1))
   SHADOW(INT((MAXROW()-m_countrow-2)/2),INT((MAXCOL()-m_maxcol-4)/2),;
            INT((MAXROW()-m_countrow-2)/2)+m_countrow+1,INT((MAXCOL()-m_maxcol-4)/2)+m_maxcol+4)
   m_countcol:=1
   DO While LEN(m_str)<>0
      i:=AT(";",m_str)
      @ INT((MAXROW()-m_countrow-2)/2)+m_countcol,INT((MAXCOL()-m_maxcol-4)/2)+1 SayDisp PADC(LEFT(m_str,i-1),m_maxcol+3) COLOR TOKEN(m_color,",",2)
      m_str:=POSDEL(m_str,1,i)
      m_countcol++
   EndDO
   IF(bell<>NIL,IF(bell==.t.,BeepErr(),Beep()),NIL)
RETURN {INT((MAXROW()-m_countrow-2)/2),INT((MAXCOL()-m_maxcol-4)/2),;
            INT((MAXROW()-m_countrow-2)/2)+m_countrow+1+1,INT((MAXCOL()-m_maxcol-4)/2)+m_maxcol+4+2,m_screen}


FUNCTION DelMessage(m_object)
   RESTSCREEN(m_object[1],m_object[2],m_object[3],m_object[4],m_object[5])
RETURN .T.

FUNCTION WaitMessage(m_str,clr,bell)
LOCAL s,i
SaveCur()
s:=DispMessage(m_str,clr,bell)
i:=INKEY(0)
DelMessage(s)
RestCur()
RETURN i


Function DispMenu(x,y,m_str,m_clr)
  LOCAL i,n:=LEN(m_str),;
  clr1:=IF(m_clr==NIL,"n/w",TOKEN(m_clr,",",1)),;
  clr2:=IF(m_clr==NIL,"r/w",TOKEN(m_clr,",",2))
  SETPOS(x,y)
  FOR i:=1 TO n
    IF SUBSTR(m_str,i,1)=="~"
      DISPOUT(UPPER(SUBSTR(m_str,i+1,1)),clr2)
      i++
    ELSE
      DISPOUT(SUBSTR(m_str,i,1),clr1)
    ENDIF
  NEXT
RETURN .t.

Function MyUpper(m_str)
    LOCAL x:=UPPER(SUBSTR(m_str,1,1))
    IF x>="A".AND.x<="Z"
      RETURN (SUBSTR("ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ",ASC(x)-ASC("A")+1,1))
    ENDIF
    DO CASE
      CASE x=="<".OR.x==","
        RETURN "Б"
      CASE x=="[".OR.x=="{"
        RETURN "Х"
      CASE x=="]".OR.x=="}"
        RETURN "Ъ"
      CASE x==":".OR.x==":"
        RETURN "Ж"
      CASE x==">".OR.x=="."
        RETURN "Ю"
      CASE x=="'".OR.x=='"'
        RETURN "Э"
    ENDCASE
RETURN (x)

Function DispText(m_str,var)
    LOCAL i:=0,n:=LEN(m_str),m_color:=IF(var==NIL,SETCOLOR(),var)
    LOCAL m_char,m_clr:=TOKEN(m_color,",",1)
    DO WHILE (++i<=n)
      m_char:=SUBSTR(m_str,i,1)
      IF m_char=="~"
        m_clr:=TOKEN(m_color,",",VAL(SUBSTR(m_str,++i,1)))
      ELSE
        DispOut(m_char,m_clr)
      ENDIF
    ENDDO
RETURN .t.

FUNCTION    Shadow(  top,  left,  bottom,  right,  attribute  )

LOCAL   s_top, s_left, s_bottom, s_right
LOCAL   s_trans := "8/0"

// Проверка границ окна: числа или нет
 IF(  VALTYPE(top) != "N" .OR. VALTYPE(left) != "N" .OR. ;
      VALTYPE(bottom) != "N" .OR. VALTYPE(right) != "N"  )
    RETURN   NIL
 END

 // Иначе устанавливаем  пользовательский
  IF(  VALTYPE(attribute) == "C"  )
       s_trans := attribute
  END

// Вычисляем границы нижнего участка тени
 s_top := bottom + 1
 s_bottom := s_top
 s_left := left + 2
 s_right := MIN(right + 2,MAXCOL())

    IF(s_bottom <= MAXROW())
       COLORWIN(s_top,s_left,s_Bottom,s_right,s_trans)
    END

// Вычисляем границы бокового участка тени
 s_top := top + 1
 s_right := right + 2
 s_left := s_right - 1
 s_bottom := MIN(bottom,MAXROW())
// Читаем часть экрана, изменяем атрибуты у символов м щаписываем обратно
   IF(  s_left <= MAXCOL()  )
       COLORWIN(s_top,s_left,s_Bottom,s_right,s_trans)
   END
RETURN   .t.

Function InitGauge(m_str,m_mode,ltop,lleft,lbottom,lRight)
  LOCAL s:="",m_screen
  LOCAL n_top,n_bottom,n_right,n_left,n_win:=WSELECT()
  WSELECT(0)
  DO CASE
    CASE m_mode==NIL.OR.m_mode==1
      n_top:=INT(MAXROW()/2-2);n_bottom:=n_top+2;n_left:=10;n_right:=MAXCOL()-10
    CASE m_mode==3
      n_top:=ltop;n_bottom:=lleft;n_left:=lbottom;n_right:=lright
    CASE m_mode==2
      n_top:=MAXROW()-5;n_bottom:=n_top+2;n_left:=10;n_right:=MAXCOL()-10
  ENDCASE
  m_screen:=SAVESCREEN(n_top,n_left,n_bottom+1,n_right+2)
  @n_top,n_left,n_bottom,n_right BOX B_DOUBLE+" " COLOR TOKEN(gauge_clr,",",1)
  m_str:=SUBSTR(ALLTRIM(m_str),1,n_right-n_left-2)
  @n_top,n_left+INT((n_right-n_left-LEN(m_str))/2) SayDisp m_str COLOR TOKEN(gauge_clr,",",2)
  Shadow(n_top,n_left,n_bottom,n_right)
  @n_top+1,n_left+2 SayDisp SPACE(n_right-n_left-3) COLOR(TOKEN(gauge_clr,",",3))
  s:=L2BIN(300)+CHR(n_top)+CHR(n_left)+CHR(n_bottom)+CHR(n_right)+m_screen
  WSELECT(n_win)
RETURN s

Function DispGauge(s,x)
  LOCAL n_top:=ASC(SUBSTR(s,5,1)),n_bottom:=ASC(SUBSTR(s,7,1)),;
  n_right:=ASC(SUBSTR(s,8,1)),n_left:=ASC(SUBSTR(s,6,1)),x1:=ROUND(x*100,0)
  LOCAL m_state:=BIN2L(SUBSTR(s,1,4)),m_str,m_color,n_win:=WSELECT()
  LOCAL s1:=STR(x1,3)+"%",i  //,k
  WSELECT(0)
  IF x1<>m_state
    m_str:=REPLICATE(CHR(219),MIN(INT((n_right-n_left-1)*x),IF(s1=="100%",n_right-n_left-1,n_right-n_left-4)))
    m_str:=PADR(m_str,n_right-n_left-3)
    DispBegin()
    @n_top+1,n_left+2 SayDisp m_str COLOR(TOKEN(gauge_clr,",",3))
    FOR i:=1 TO 4
  //    k:=SCREENSTR(n_top+1,n_left+INT((n_right-n_left-4)/2)+i,1)
      m_color:=TOKEN(gauge_clr,",",4)+"/"+CHARREPL("+",TOKEN(TOKEN(gauge_clr,",",3),"/",IF(LEFT(SCREENSTR(n_top+1,n_left+INT((n_right-n_left-4)/2)+i,1),1)==" ",2,1)),"*")
      @n_top+1,n_left+INT((n_right-n_left-4)/2)+i SayDisp SUBSTR(s1,i,1) COLOR m_color
    NEXT
    DispEnd()
    s:=L2BIN(x1)+SUBSTR(s,5)
  ENDIF
  WSELECT(n_win)
RETURN s

Function DelGauge(s)
  LOCAL n_top:=ASC(SUBSTR(s,5,1)),n_bottom:=ASC(SUBSTR(s,7,1)),;
  n_right:=ASC(SUBSTR(s,8,1)),n_left:=ASC(SUBSTR(s,6,1)),n_win:=WSELECT()
  WSELECT(0)
  RESTSCREEN(n_top,n_left,n_bottom+1,n_right+2,SUBSTR(s,9))
  WSELECT(n_win)
RETURN .t.

Function NetUse(new,var1,name, als,ronl,x)
LOCAL i:=IF(x==NIL,net_wait3,x),j
DO WHILE .t.
   DO WHILE  i > 0
    dbUseArea(new,,name, als,IF(NETWORK(),.t.,.f.), ronl)
    IF NEtWork()
      IF !NETERR()                // If successful, let's get out of here
         RETURN .t.
      ENDIF
    ELSE
      RETURN .t.
    ENDIF
    INKEY(.5)         // Wait 1/2 second
    i-= .5
   ENDDO
    DispError("Помилка при вiдкриттi файла;"+name)
    IF ANSWERu("Продовжувати вiдкриття файла;"+name)==YES
      i:=IF(x==NIL,net_wait3,x)
      LOOP
    ENDIF
   BREAK
ENDDO

RETURN ( .f. )


Function NetDbAP(x)
  LOCAL i:=IF(x==NIL,net_wait2,x)
DO WHILE .t.
   WHILE  i > 0
      DBAPPEND()
      IF !NETERR();RETURN .t.;ENDIF
      INKEY(.5)         // Wait 1/2 second
      i-= .5
   END
    DispError("Помилка при додаваннi запису; в файл"+ALIAS())
    IF ANSWERu("Продовжувати додавати ?")==YES
      i:=IF(x==NIL,net_wait2,x)
      LOOP
    ELSE
      EXIT
    ENDIF
ENDDO
RETURN ( .f. )

Function NetDbInsert()
    LOCAL m_recno:=RECNO(),n_order:=INDEXORD(),k,a_fields:={},i,;
    m_del:=.f.,l_delete:=SET(_SET_DELETED,.f.),m_gauge:=InitGauge("Вставка строки",2)
    IF .NOT.USED()
      SET(_SET_DELETED,l_delete)
      RETURN .f.
    ENDIF
IF NetFlock()
    DBSKIP()
    DBSETORDER(0);ASIZE(a_fields,FCOUNT())
    i:=1;AEVAL(a_fields,{|x|a_fields[i]:=BLANK(fieldget(i),.t.),i++})
    DO WHILE .NOT.EOF()
      i:=1;AEVAL(a_fields,{|x|a_fields[i]:=fieldget(i),FIELDPUT(i,x),i++})
      k:=DELETE()
      IF DELETE().AND..NOT.m_del
        RECALL
      ELSE
        IF .NOT.DELETE().AND.m_del
          DBDELETE()
        ENDIF
      ENDIF
      m_del:=k
      DBSKIP(1)
      DispGauge(m_gauge,(RECNO()-m_recno)/(LASTREC()-m_recno+1))
    ENDDO
    DBAPPEND()
    i:=1;AEVAL(a_fields,{|x|FIELDPUT(i,x),i++})
    IF m_del
      DBDELETE()
    ENDIF
    DBGOTO(m_recno)
    DBSETORDER(n_order)
    SET(_SET_DELETED,l_delete)
    DelGauge(m_gauge)
ELSE
  SET(_SET_DELETED,l_delete)
  RETURN .f.
ENDIF
RETURN .t.

FUNCTION NetRLock( var )
  LOCAL  nWait:=IF(var==NIL,net_wait1,var)
DO WHILE .t.
  DBGOTO(RECNO())
  DO WHILE nWait>0
    IF RLOCK();RETURN .t. ;ENDIF
    INKEY( .5 );nWait -= .5
  ENDDO
    DispError("Помилка  при блокуваннi запису #"+STR(RECNO())+"; файла "+ALIAS())
    IF ANSWERu("Продовжувати блокування запису ?")==YES
      nWait:=IF(var==NIL,net_wait1,var)
      LOOP
    ELSE
      EXIT
    ENDIF
ENDDO

RETURN  .f.

FUNCTION NetFLock( var )
  LOCAL  nWait:=IF(var==NIL,net_wait4,var)
DO WHILE .t.
  DBGOTO(RECNO())
  DO WHILE nWait>0
    IF FLOCK();RETURN .t. ;ENDIF
    INKEY( .5 );nWait -= .5
  ENDDO
    DispError("Помилка  при блокуваннi ; файла "+ALIAS())
    IF ANSWERu("Продовжувати блокування файлу ?")==YES
      nWait:=IF(var==NIL,net_wait4,var)
      LOOP
    ELSE
      EXIT
    ENDIF
ENDDO
RETURN  .f.
Function NetInit(var1,var2,var3,var4)
  IF VALTYPE(var1)=="N"
    net_wait1:=var1
  ENDIF
  IF VALTYPE(var2)=="N"
    net_wait2:=var2
  ENDIF
  IF VALTYPE(var3)=="N"
    net_wait3:=var3
  ENDIF
  IF VALTYPE(var4)=="N"
    net_wait4:=var4
  ENDIF
RETURN .t.

Function MyAltCode(m_var)
IF m_var<"А".OR.m_var>"Я"
  RETURN (0)
ENDIF
RETURN ASC(SUBSTR(ALTKEY,ASC(m_var)-ASC("А")+1,1))+240
// ***************************************************

Function MyCodeAlt(m_var)
  LOCAL j,k
  IF (j:=AT(CHR(m_var-240),ALTKEY))==0.OR.m_var<272.OR.m_var>368
    RETURN "Q"
  ENDIF
  k:=CHR(ASC("А")+j-1)
  RETURN k
//  RETURN CHR(ASC("А")+j-1)
IF m_var<"А".OR.m_var>"Я"
  RETURN CHR(0)
ENDIF
RETURN ASC(SUBSTR(ALTKEY,ASC(m_var)-ASC("А")+1,1))+240


Function InitScroll(top,left,bottom,clr)
RETURN CHR(top)+CHR(left)+CHR(bottom-top+1)+CHR(COLORTON(IF(clr==NIL,"W/B",clr)))+SAVESCREEN(top,left,bottom,left)

Function DispScroll(m_scroll,x)
  LOCAL i:=0,n:=ASC(SUBSTR(m_scroll,3,1)),;
  top:=ASC(SUBSTR(m_scroll,1,1)),;
  left:=ASC(SUBSTR(m_scroll,2,1))
  LOCAL bottom:=n+top-1,clr:=NTOCOLOR(ASC(SUBSTR(m_scroll,4,1)))
  IF x<0.OR.x>1;REtURn .f.;ENDIF
  FOR i:=2 TO n-1
    @top+i-1,left SayDisp CHR(177) COLOR clr
  NEXT
  DO CASE
    CASE x==0
      @top,left SayDisp CHR(219) COLOR clr
      @bottom,left SayDisp CHR(25) COLOR clr
    CASE x==1
      @top,left SayDisp CHR(24) COLOR clr
      @bottom,left SayDisp CHR(219) COLOR clr
    OTHERWISE
      @top,left SayDisp CHR(24) COLOR clr
      @bottom,left SayDisp CHR(25) COLOR clr
      @top+1+ROUND((n-2)*x,0),left SayDisp CHR(219) COLOR clr
  ENDCASE
RETURN .t.

Function DelScroll(m_scroll)
  LOCAL n:=ASC(SUBSTR(m_scroll,3,1)),;
  top:=ASC(SUBSTR(m_scroll,1,1)),;
  left:=ASC(SUBSTR(m_scroll,2,1))
  LOCAL bottom:=n+top-1,m_screen:=SUBSTR(m_scroll,5)
RESTSCREEN(ASC(SUBSTR(m_scroll,1,1)),ASC(SUBSTR(m_scroll,2,1)),ASC(SUBSTR(m_scroll,3,1))+ASC(SUBSTR(m_scroll,1,1))-1,ASC(SUBSTR(m_scroll,2,1)),SUBSTR(m_scroll,5))
RETURN .t.

Function SAvePar(var)
  LOCAL i:=0
  STATIC a_par:={}
  IF var==NIL
    AADD(a_par,;
    {SELECT(),WSELECT(),ROW(),COL(),READEXIT(),SETCURSOR(),SET(_SET_ESCAPE),RECNO(),SaveScreen(0,0,MaxRow(),Maxcol())})
  ELSE
    i:=LEN(a_par)
    SELECT(a_par[i][1])
    WSELECT(a_par[i][2])
    SETPOS(a_par[i][3],a_par[i][4])
    READEXIT(a_par[i][5])
    SETCURSOR(a_par[i][6])
    SET(_SET_ESCAPE,a_par[i][7])
    DBGOTO(a_par[i][8])
    RestScreen(0,0,MAXROW(),MAXcOl(),a_par[i][9])
    ADEL(a_par,i);ASIZE(a_par,i-1)
  ENDIF
RETURN .t.
Function RestVar1(m_name,tip)
myvar->(DBSEEK(PADR(tip+ALLTRIM(m_name),16)))
DO CASE
  CASE myvar->kod=="C"
    RETURN (ALLTRIM(myvar->value))
  CASE myvar->kod=="N"
    RETURN (VAL(myvar->value))
  CASE myvar->kod=="L"
    RETURN (IF(AT(UPPER(ALLTRIM(myvar->value)),"1TYД")<>0,.t.,.f.))
  CASE myvar->kod=="D"
    RETURN (CTOD(ALLTRIM(myvar->value)))
ENDCASE
DispError("Помилка при читаннi "+m_name+" "+tip)

RETURN (0)
Function SaveVar1(m_name,m_value,tip)
myvar->(DBSEEK(PADR(tip+ALLTRIM(m_name),16)))
IF .NOT.myvar->(FOUND())
  IF myvar->(netDBAP())
    myvar->prg:=tip
    myvar->name:=m_name
  ELSE
    RETURN .f.
  ENDIF
ENDIF
IF myvar->(NetRlock())
  DO CASE
  CASE VALTYPE(m_value)=="C"
    myvar->kod:="C"
    myvar->value:=m_value
  CASE VALTYPE(m_value)=="D"
    myvar->kod:="D"
    myvar->value:=DTOC(m_value)
  CASE VALTYPE(m_value)=="N"
    myvar->kod:="N"
    myvar->value:=ALLTRIM(STR(m_value))
  CASE VALTYPE(m_value)=="L"
    myvar->kod:="L"
    myvar->value:=IF(m_value,"1","0")
  ENDCASE
  MyVar->(dbUnlock())
  RETURN .t.
ENDIF
RETURN .f.
#define   NAME_FILE_ERR  "errors.arm"
#INCLUDE "error.ch"
FUNCTION ArmError(err)
LOCAL     i,  err_msg := {},  s,j
STATIC    s_han_err := 0
WACLOSE()
  IF( err:genCode == EG_ZERODIV )
    //  Деление на ноль
    RETURN(0)
  END

 IF ( err:genCode == EG_OPEN .AND. err:osCode == 32 .AND. err:canDefault )
   // Ошибка сетевой работы
   NetErr(.t.)
   RETURN(.F.)
 END

 IF ( err:genCode == EG_APPENDLOCK .AND. err:canDefault )
    // Ошибка сетевой работы
    NETERR(.T.)
    RETURN(.F.)
 END

 err_msg:="Помилка "

 IF( ! EMPTY( err:subsystem()) )
    // Описание подсистемы, где произошла ошибка
    err_msg += " " + err:subsystem() + "/" + LTRIM(STR( err:subCode() ))
 END

 IF( ! EMPTY( err:description()) )
    // Строкове описание ошибки
    err_msg += ";" + err:description()
 END

 IF( ! EMPTY( err:operation()) )
   // Строковое описание операции, вызвавшей ошибку
   err_msg += ": " + err:operation()
 END

 IF( ! EMPTY( err:filename()) )
   // Имя файла, связанного с ошибкой
   err_msg += ": " + err:filename()
 END

 IF( err:genCode == EG_OPEN .OR. err:genCode == EG_CREATE )
   // Ошибка ДОСа
   err_msg+= ";  (Помилка MS-DOS " + LTRIM(STR( err:osCode )) + ")"
 END

 i := 2
 s := ""
   // Трассировка вызова ошибки
   WHILE( ! EMPTY( PROCNAME(i)) )
      s += "; Викликано iз " + TRIM( PROCNAME(i)) + ;
                      "(" + ALLTRIM( STR( PROCLINE(i))) + ") "
        IF(LEN(s) > 50)
          err_msg+=s
          s := ""
        END
      i++
   END
   IF( ! EMPTY(s))
     err_msg+=s
   END
   j:=DispError(err_msg)
   //  Записываем в файл сообщение об ошибке
   IF(s_han_err == 0)
      //  Вошли в первый раз ?
      IF( FILE(m_exepath +  NAME_FILE_ERR))
         s_han_err := FOPEN(m_exepath +  NAME_FILE_ERR, 2)
      ELSE
         s_han_err := FCREATE(m_exepath + NAME_FILE_ERR, 0)
      END
      //  Были ошибки открытия/создания ?
      IF( FERROR() != 0)
        //  Попытка открытия неудачна
        s_han_err := 0
      END
   END

   //  Файл открыли нормально
   IF(s_han_err != 0)
      //  В конец файла
      FSEEK(s_han_err, 0, 2)
      //  Пишем дату и время ошибки
      FWRITE(s_han_err, DTOC( DATE()) + " " + TIME() + END_LINE)
       //  Пишем сообщение об ошибке
      FWRITE(s_han_err, err_msg)
      FWRITE(s_han_err, END_LINE)
      FCLOSE(s_han_err)
      DBCOMMITALL()
      s_han_err := 0
   END
   IF j==K_ALT_C.OR.(j==K_ESC.AND.ANSWERu("Зняти програму?")==YES)
     QUIT
    ENDIF
   // Выдаем обьект ошибки на-гора
   BREAK(err)
RETURN .f.
Function IsSingle(FieldBlock)
  Local m_vnum:=EVAL(FieldBlock)
  DBSKIP()
  IF EVAL(FieldBlock) == m_vnum.AND..NOT.EOF()
    DBSKIP(-1)
    RETURN .f.
  ENDIF
  DBSKIP(-2)
  IF .NOT.BOF()
    IF EVAL(FieldBlock) == m_vnum
      DBSKIP()
      RETURN .f.
    ELSE
      DBSKIP()
    ENDIF
  ENDIF
RETURN .T.
