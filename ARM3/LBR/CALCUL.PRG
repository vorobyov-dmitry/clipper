#include "new.ch"
STATIC a_reg:={0,0,0,0,0,0,0,0,0,0}
STATIC n_reg:=1

Function Calcul()
  LOCAL m_blink:=SETBLINK(.f.),i,c_key:=""
  LOCAL m_state:="0",m_key,n_dec1,n_dec2,m_get
  LOCAL m_reg1:=0
  LOCAL m_reg2:=0,m_ret:=0,m_reg3:=0
  LOCAL  m_kopr:=" ",n_win:=0
  SavePar()
  n_win:=WOPEN(0,0,20,67)
  WSELECT(n_win)
  @0,0,MAXROW(),MAXCOL() BOX REPLICATE(CHR(219),8)+" " COLOR "w/G"
  @1,1 SayDisp "1 число" COLOR "w+/G"
  @3,1 SayDisp "2 число" COLOR "w+/G"
  @5,1 SayDisp  "Равно =" COLOR "w+/g"
  FOR i:=1 TO 14
    @i,34 SayDisp CHR(179) COLOR "bg+/g"
  NEXT
  @7,2 SayText  " 7 ~2  ~1 8 ~2  ~1 9 ~2  ~1 / ~2  ~1 % ~2  ~1   ~2" COLOR "w+/b,w/g"
  @9,2 SayText  " 4 ~2  ~1 5 ~2  ~1 6 ~2  ~1 * ~2  ~1   ~2  ~1   ~2" COLOR "w+/b,w/g"
  @11,2 SayText " 1 ~2  ~1 2 ~2  ~1 3 ~2  ~1 - ~2  ~1   ~2  ~1   ~2" COLOR "w+/b,w/g"
  @13,2 SayText " 0 ~2  ~1 . ~2  ~1 = ~2  ~1 + ~2  ~1   ~2  ~1   ~2" COLOR "w+/b,w/g"
  FOR i:=1 TO MAXCOL()-1
    @14,i SayDisp "─" COLOR "bg+/g"
  NEXT
  @14,34 SayDisp "┴"  COLOR "bg+/g"
  @15,1 SayText "~2Пробел~1 - обнуление, ~2<─~1 - удаление последней цифры, ~2+~1 - добавить," COLOR "b/g,w+/g"
  @16,1 SayText " ~2-~1 вычесть, ~2*~1 - умножить, ~2/~1 - разделить,~2<Alt>+<->~1 - изменить знак," COLOR "b/g,w+/g"
  @17,1 SayText "~2Enter~1 или ~2=~1 - вычислить значение, ~2%~1 - вычислить процент  " COLOR "b/g,w+/g"
  @18,1 SayText "~2 "+CHR(24)+" ~1или~2 "+CHR(25)+"~1 - перемещение по регистрам," COLOR "b/g,w+/g"
  @19,1 SayText " ~2"+CHR(26)+"~1 - занести в регистр, ~2"+CHR(27)+"~1 - забрать с регистра" COLOR "b/g,w+/g"
  @2,1 SayDisp REPLICATE("─",33)+CHR(180) COLOR "bg+/G"
  @4,1 SayDisp REPLICATE("═",33)+CHR(181) COLOR "bg+/G"
  @6,1 SayDisp REPLICATE("─",33)+CHR(180) COLOR "bg+/G"
  @0,27 SayDisp "Калькулятор" COLOR "b/w"
  @1,46 SayDisp "Регистры" COLOR "w+/G"
  FOR i:=1 TO LEN(a_reg)
    @2+i,36 SayDisp i PICTURE "99" COLOR "w+/g"
  NEXT
  i:=3;AEVAL(a_reg,{|x|SETPOS(i,43),DispOut(NumToStr(x,21),"w/b"),i++})
  @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
  @2+n_reg,39 SayDisp "═══"+CHR(16) COLOR "w+/G"
  m_get := GETACTIVE()
  IF VALTYPE(m_get) == "O"      // Есть активный  GET
    IF VALTYPE(m_get:VarGet()) == "N"
      m_reg1:=m_get:VarGet()
    ENDIF
  END

  DO WHILE .t.
  @1,9 SayDisp NumToStr(m_reg1,21) COLOR "w+/B"
  @3,9 SayDisp NumToStr(m_reg2,21) COLOR "w+/B"
  @5,9 SayDisp NumToStr(m_reg3,21) COLOR "w+/B"
  @2,7 SayDisp m_kopr COLOR "Gr+/B"
    DO CASE
      CASE m_state=="0" // Ввод первого операнда
          m_ret:=ReadSum(1,9,@m_reg1,"/*-+",c_key,@n_dec1)
          c_key:=""
          DO CASE
            CASE m_ret==K_ESC
              EXIT
            CASE AT(CHR(m_ret),"/*-+")<>0
              m_kopr:=SUBSTR("/*-+",AT(CHR(m_ret),"/*-+"),1)
              @2,7 SayDisp m_kopr COLOR "Gr+/B"
              m_state:="1"
          ENDCASE
      CASE m_state=="1" // Ввод 2-го операнда
          m_ret:=ReadSum(3,9,@m_reg2,"="+CHR(K_ENTER)+"%/*-+",c_key,@n_dec2)
          c_key:=""
          DO CASE
            CASE m_ret==K_ESC
              EXIT
            CASE AT(CHR(m_ret),"="+CHR(K_ENTER)+"%/*-+")<>0
              m_state:="2"
          ENDCASE
      CASE m_state=="2" // Вычисление
              DoOper(@m_reg1,@m_reg2,@m_reg3,@m_state,@m_kopr,m_ret,n_dec1,n_dec2)
              IF m_state<>"2"
                LOOP
              ENDIF
              @5,9 SayDisp NumToStr(m_reg3,21) COLOR "GR+/N"
              IF AT(CHR(m_ret),"/*-+")<>0
                m_reg1:=m_reg3
                m_reg3:=m_reg2:=0
                m_kopr:=SUBSTR("/*-+",AT(CHR(m_ret),"/*-+"),1)
                m_state:="1"
              ENDIF
              DO WHILE .t.
                m_key:=INKEY(0)
                DO CASE
                  CASE m_key==K_ESC
                    m_state:="9"
                    EXIT
                  CASE m_key==K_F10
                    m_state:="9"
                    IF VALTYPE(m_get) == "O"   // Вышли по F10
                      IF VALTYPE(m_get:VarGet()) == "N"
                        m_get:VarPut(m_reg3)
                        m_get:UpdateBuffer()
                      END
                    END
                    EXIT
                  case ( m_key == K_UP )
                    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w/b"
                    @2+n_reg,39 SayDisp "    " COLOR "w+/G"
                    n_reg:=IF(n_reg==1,LEN(a_reg),n_reg-1)
                    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
                    @2+n_reg,39 SayDisp "═══"+CHR(16) COLOR "w+/G"
                  case ( m_key == K_DOWN )
                    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w/b"
                    @2+n_reg,39 SayDisp "    " COLOR "w+/G"
                    n_reg:=IF(n_reg==LEN(a_reg),1,n_reg+1)
                    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
                    @2+n_reg,39 SayDisp "═══"+CHR(16) COLOR "w+/G"
                  CASE m_key==K_RIGHT
                    a_reg[n_reg]:=m_reg3
                    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
                  CASE m_key==K_ENTER.OR.CHR(m_key)=="="
                    m_reg1:=m_reg3;n_dec1:=LEN(STR(m_reg1))-AT(".",STR(m_reg1))
                    @1,9 SayDisp NumToStr(m_reg1,21) COLOR "w+/B"
                    EXIT
                  CASE AT(CHR(m_key),"/*-+")<>0
                    m_reg1:=m_reg3
                    m_reg3:=m_reg2:=0
                    m_kopr:=SUBSTR("/*-+",AT(CHR(m_key),"/*-+"),1)
                    m_state:="1";EXIT
                  CASE m_key=330
                    m_reg1:=-m_reg3
                    m_reg3:=m_reg2:=0
                    m_kopr:=" "
                    m_state:="0";EXIT
                  CASE AT(CHR(m_key)," 0123456789")<>0
                    m_reg1:=m_reg2:=m_reg3:=0
                    m_kopr:=" "
                    c_key:=CHR(m_key)
                    m_state:="0"
                    EXIT
                ENDCASE
             ENDDO
      CASE m_state=="9" // Завершить
        EXIT
     ENDCASE

  ENDDO
  WCLOSE()
  SavePar(1)
  SETBLINK(m_blink)
RETURN .t.

// **********************************************
STATIC function ReadSum(row,col,var,m_str,c_key,n_dec1)
LOCAL i:=0,m_clr2:="w+/b*",m_clr1:="GR+/N",n_dec:=0
LOCAL m_key,c_buf:="",m_registr:=var,x
LOCAL l_dec:=.t.,m_len:=21,m_dec:=19,m_koef,l_znak:=IF(m_registr<0,.f.,.t.)
local m_cursor:=SETCURSOR(0)
LOCAL m_ret:=0

c_buf:=NumToStr(m_registr,m_len,m_dec)
IF (i:=AT(".",c_buf))<>0
  m_koef:=10**(i-LEN(c_buf)-1);n_dec:=LEN(c_buf)-i
  l_dec:=.t.
ELSE
  l_dec:=.f.
ENDIF
DO WHILE .t.
  @row,col SayDisp c_buf COLOR m_clr1
  IF c_key==""
    m_key:=INKEY(0)
  ELSE
    m_key:=ASC(c_key)
    c_key:=""
  ENDIF

  DO CASE
    CASE AT(CHR(m_key),m_str)<>0
      var:=IF(n_dec>0,ROUND(m_registr,n_dec+1),m_registr)
      n_dec1:=IF(n_dec>0,n_dec,0)
      m_ret:=ASC(SUBSTR(m_str,AT(CHR(m_key),m_str),1));EXIT
    case (m_key >=ASC("0").and. m_key <= ASC("9"))
      x:=m_key-ASC("0")
      IF .NOT.l_dec
        IF Len(LTRIM(c_buf))<m_len
          m_registr:=m_registr*10+IF(l_znak,x,-x)
          c_buf:=NumToStr(m_registr,m_len,0)
        ELSE
          BeepErr()
        ENDIF
      ELSE
        IF LEN(LTRIM(c_buf))<m_len.AND.(m_dec<>NIL.AND.n_dec<m_dec)
          m_registr:=m_registr+IF(l_znak,x*m_koef,-x*m_koef)
          m_koef:=m_koef*0.1
          n_dec++
          c_buf:=SUBSTR(c_buf,2)+CHR(m_key)
        ELSE
          BeepErr()
        ENDIF
      ENDIF
  case ( m_key == K_UP )
    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w/b"
    @2+n_reg,39 SayDisp "    " COLOR "w+/G"
    n_reg:=IF(n_reg==1,LEN(a_reg),n_reg-1)
    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
    @2+n_reg,39 SayDisp "═══"+CHR(16) COLOR "w+/G"
  case ( m_key == K_DOWN )
    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w/b"
    @2+n_reg,39 SayDisp "    " COLOR "w+/G"
    n_reg:=IF(n_reg==LEN(a_reg),1,n_reg+1)
    @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
    @2+n_reg,39 SayDisp "═══"+CHR(16) COLOR "w+/G"
  case ( m_key == K_LEFT )
      m_registr:=a_reg[n_reg]
      l_znak:=IF(m_registr<0,.f.,.t.)
      c_buf:=NumToStr(m_registr,m_len,m_dec)
      IF (i:=AT(".",c_buf))<>0
        m_koef:=10**(i-LEN(c_buf)-1);n_dec:=LEN(c_buf)-i
        l_dec:=.t.
      ELSE
        l_dec:=.f.
      ENDIF

  case ( m_key == K_RIGHT )
     a_reg[n_reg]:=m_registr
      @2+n_reg,43 SayDisp NumToStr(a_reg[n_reg],21) COLOR "w+/b*"
  case ( m_key == K_ENTER )
    var:=IF(n_dec>0,ROUND(m_registr,n_dec+1),m_registr)
    m_ret:=K_ENTER;EXIT
  case ( m_key == K_ESC )
    m_ret:=K_ESC;EXIT
  CASE m_key==ASC(".").AND.(m_dec==NIL.OR.m_dec>0).AND..NOT.l_dec.AND.SUBSTR(c_buf,1,1)==" "
      l_dec:=.t.;c_buf:=SUBSTR(c_buf,2)+".";m_koef:=0.1;n_dec:=0
  case (m_key == K_BS)
      IF .NOT.l_dec
        m_registr:=Int(m_registr*0.1)
        c_buf:=NumToStr(m_registr,m_len,0)
      ELSE
        IF RIGHT(c_buf,1)=="."
          c_buf:=" "+SUBSTR(c_buf,1,LEN(c_buf)-1)
          l_dec:=.f.
        ELSE
          m_koef:=m_koef*10;n_dec--
          c_buf:=" "+SUBSTR(c_buf,1,LEN(c_buf)-1)
          m_registr:=VAL(CHARREM(" '",c_buf))
        ENDIF
      ENDIF
    CASE m_key==ASC(" ")
      m_registr:=0;l_dec:=.f.;c_buf:=NumToStr(m_registr,m_len,0)
    CASE m_key==ASC("-").OR.m_key==330
      IF l_znak.AND.LEFT(c_buf,1)==" ".OR.;
        (.NOT.l_znak.AND.(LEFT(c_buf,1)==" ".OR.LEFT(c_buf,1)==" "))
        IF l_znak
          m_registr:=-m_registr
          l_znak:=.f.
          c_buf:=PADL("-"+LTRIM(c_buf),m_len)
        ELSE
          m_registr:=-m_registr;l_znak:=.t.
          c_buf:=PADL(SUBSTR(LTRIM(c_buf),2),m_len)
        ENDIF
      ELSE
        BeepErr()
      ENDIF
  OTHERWISE
        BeepErr()
  ENDCASE
ENDDO
@row,col SayDisp NumToStr(var,m_len) COLOR m_clr2
SETCURSOR(m_cursor)
RETURN m_ret
STATIC FUNCTION NumToStr(m_registr,n_len,n_dec,var1)
  LOCAL c_delim:=IF(var1==NIL,"'",var1),m_len:=IF(n_len<>NIL,n_len,16),;
  m_dec:=IF(n_dec<>NIL,n_dec,2),x:=ABS(INT(m_registr))
  LOCAL y:=ABS(m_registr)-x
  LOCAL c_buf:="",m_str:=ALLTRIM(str(x,18))
  LOCAL n:=INT((LEN(m_str)+2)/3),i
  m_str:=PADL(m_str,3*n)
  FOR i:=1 TO n-1
    c_buf:=c_buf+SUBSTR(m_str,(i-1)*3+1,3)+c_delim
  NEXT
  c_buf:=LTRIM(c_buf+RIGHT(m_str,3))
  m_dec:=IF(n_dec==NIL,m_len-LEN(c_buf)-2,n_dec)
  IF ROUND(y,m_dec+2)<>0
    m_str:=ALLTRIM(STR(y))
    m_str:=SUBSTR(m_str,AT(".",m_str)+1);n:=LEN(m_str)
    FOR i:=n TO 1 STEP -1
      IF SUBSTR(m_Str,i,1)<>"0"
        EXIT
      ENDIF
    NEXT
    c_buf:=c_buf+"."+LEFT(m_str,i)
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
STATIC function  DoOper(m_reg1,m_reg2,m_reg3,m_state,m_kopr,m_ret,n_dec1,n_dec2)
DO CASE
  CASE m_kopr=="+"
      IF CHR(m_ret)<>"%"
        m_reg3:=ROUND(m_reg1+m_reg2,MAX(n_dec1,n_dec2)+1)
      ELSE
        m_reg3:=ROUND(m_reg1+m_reg2*m_reg1/100,MAX(n_dec1,n_dec2+n_dec1)+1)
      ENDIF

  CASE m_kopr=="-"
      IF CHR(m_ret)<>"%"
        m_reg3:=ROUND(m_reg1-m_reg2,MAX(n_dec1,n_dec2)+1)
      ELSE
        m_reg3:=ROUND(m_reg1-m_reg2*m_reg1/100,MAX(n_dec1,n_dec2+n_dec1)+1)
      ENDIF
  CASE m_kopr=="*"
      IF CHR(m_ret)<>"%"
        m_reg3:=ROUND(m_reg1*m_reg2,n_dec1+n_dec2+2)
      ELSE
        m_reg3:=ROUND(m_reg1*m_reg2/100,n_dec1+n_dec2+4)
      ENDIF
  CASE m_kopr=="/"
    IF m_reg2=0
      DispError("На ноль делить нельзя")
      m_reg3:=0
      m_state:="1"
    ENDIF
      IF CHR(m_ret)<>"%"
        m_reg3:=ROUND(m_reg1/m_reg2,10)
      ELSE
        m_reg3:=ROUND(m_reg1/m_reg2*100,10)
      ENDIF

  ENDCASE
  IF AT(CHR(m_ret),"+-/*")<>0
    m_reg1:=m_reg3;m_reg2:=m_reg3:=0
    m_kopr:=SUBSTR("/*-+",AT(CHR(m_ret),"/*-+"),1)
    m_state:="1"
  ENDIF
RETURN .t.
STATIC function ReadSum1(row,col,var,m_str,c_key,n_dec1)
LOCAL i:=0,m_clr2:="w+/b*",m_clr1:="GR+/N",n_dec:=0
LOCAL m_key,c_buf:="",m_registr:=var,x
LOCAL l_dec:=.t.,m_len:=21,m_dec:=19,m_koef,l_znak:=IF(m_registr<0,.f.,.t.)
local m_cursor:=SETCURSOR(0)
LOCAL m_ret:=0

c_buf:=NumToStr(m_registr,m_len,m_dec)
IF (i:=AT(".",c_buf))<>0
  m_koef:=10**(i-LEN(c_buf)-1);n_dec:=LEN(c_buf)-i
  l_dec:=.t.
ELSE
  l_dec:=.f.
ENDIF
DO WHILE .t.
  @row,col SayDisp c_buf COLOR m_clr1
  IF c_key==""
    m_key:=INKEY(0)
  ELSE
    m_key:=ASC(c_key)
    c_key:=""
  ENDIF

  DO CASE
    CASE AT(CHR(m_key),m_str)<>0
      var:=IF(n_dec>0,ROUND(m_registr,n_dec+1),m_registr)
      n_dec1:=IF(n_dec>0,n_dec,0)
      m_ret:=ASC(SUBSTR(m_str,AT(CHR(m_key),m_str),1));EXIT
    case (m_key >=ASC("0").and. m_key <= ASC("9"))
      x:=m_key-ASC("0")
      IF .NOT.l_dec
        IF Len(LTRIM(c_buf))<m_len
          m_registr:=m_registr*10+IF(l_znak,x,-x)
          c_buf:=NumToStr(m_registr,m_len,0)
        ELSE
          BeepErr()
        ENDIF
      ELSE
        IF LEN(LTRIM(c_buf))<m_len.AND.(m_dec<>NIL.AND.n_dec<m_dec)
          m_registr:=m_registr+IF(l_znak,x*m_koef,-x*m_koef)
          m_koef:=m_koef*0.1
          n_dec++
          c_buf:=SUBSTR(c_buf,2)+CHR(m_key)
        ELSE
          BeepErr()
        ENDIF
      ENDIF
  case ( m_key == K_ENTER )
    var:=IF(n_dec>0,ROUND(m_registr,n_dec+1),m_registr)
    m_ret:=K_ENTER;EXIT
  case ( m_key == K_ESC )
    m_ret:=K_ESC;EXIT
  CASE m_key==ASC(".").AND.(m_dec==NIL.OR.m_dec>0).AND..NOT.l_dec.AND.SUBSTR(c_buf,1,1)==" "
      l_dec:=.t.;c_buf:=SUBSTR(c_buf,2)+".";m_koef:=0.1;n_dec:=0
  case (m_key == K_BS)
      IF .NOT.l_dec
        m_registr:=Int(m_registr*0.1)
        c_buf:=NumToStr(m_registr,m_len,0)
      ELSE
        IF RIGHT(c_buf,1)=="."
          c_buf:=" "+SUBSTR(c_buf,1,LEN(c_buf)-1)
          l_dec:=.f.
        ELSE
          m_koef:=m_koef*10;n_dec--
          c_buf:=" "+SUBSTR(c_buf,1,LEN(c_buf)-1)
          m_registr:=VAL(CHARREM(" '",c_buf))
        ENDIF
      ENDIF
    CASE m_key==ASC(" ")
      m_registr:=0;l_dec:=.f.;c_buf:=NumToStr(m_registr,m_len,0)
    CASE m_key==ASC("-").OR.m_key==330
      IF l_znak.AND.LEFT(c_buf,1)==" ".OR.;
        (.NOT.l_znak.AND.(LEFT(c_buf,1)==" ".OR.LEFT(c_buf,1)==" "))
        IF l_znak
          m_registr:=-m_registr
          l_znak:=.f.
          c_buf:=PADL("-"+LTRIM(c_buf),m_len)
        ELSE
          m_registr:=-m_registr;l_znak:=.t.
          c_buf:=PADL(SUBSTR(LTRIM(c_buf),2),m_len)
        ENDIF
      ELSE
        BeepErr()
      ENDIF
  OTHERWISE
        BeepErr()
  ENDCASE
ENDDO
@row,col SayDisp NumToStr(var,m_len) COLOR m_clr2
SETCURSOR(m_cursor)
RETURN m_ret
Function Calc()
  LOCAL m_blink:=SETBLINK(.f.),i,c_key:=""
  LOCAL m_state:="0",m_key,n_dec1,n_dec2,m_get
  LOCAL m_reg1:=0
  LOCAL m_reg2:=0,m_ret:=0,m_reg3:=0
  LOCAL  m_kopr:=" ",n_win:=0
  SavePar()
  n_win:=WOPEN(0,0,4,23)
  WSELECT(n_win)
//  CLEARWIN(0,0,MAXROW(),MAXCOL(),"w/b")
  @ 0,0,MAXROW(),MAXCOL() BOX B_SINGLE+" " COLOR "w/b"
//  CLEAREOL(0,0,"w/b",CHR(219))
  @0,1 SayDisp "Калькулятор" COLOR "b/w"
  m_get := GETACTIVE()
  IF VALTYPE(m_get) == "O"      // Есть активный  GET
    IF VALTYPE(m_get:VarGet()) == "N"
      m_reg1:=m_get:VarGet()
    ENDIF
  END

  DO WHILE .t.
  @1,1 SayDisp NumToStr(m_reg1,21) COLOR "w+/B"
  @2,1 SayDisp NumToStr(m_reg2,21) COLOR "w+/B"
  @3,1 SayDisp NumToStr(m_reg3,21) COLOR "w+/B"
  @0,14 SayDisp m_kopr COLOR "N/W"
    DO CASE
      CASE m_state=="0" // Ввод первого операнда
          m_ret:=ReadSum1(1,1,@m_reg1,"/*-+",c_key,@n_dec1)
          c_key:=""
          DO CASE
            CASE m_ret==K_ESC
              EXIT
            CASE AT(CHR(m_ret),"/*-+")<>0
              m_kopr:=SUBSTR("/*-+",AT(CHR(m_ret),"/*-+"),1)
              @0,14 SayDisp m_kopr COLOR "N/W"
              m_state:="1"
          ENDCASE
      CASE m_state=="1" // Ввод 2-го операнда
          m_ret:=ReadSum1(2,1,@m_reg2,"="+CHR(K_ENTER)+"%/*-+",c_key,@n_dec2)
          c_key:=""
          DO CASE
            CASE m_ret==K_ESC
              EXIT
            CASE AT(CHR(m_ret),"="+CHR(K_ENTER)+"%/*-+")<>0
              m_state:="2"
          ENDCASE
      CASE m_state=="2" // Вычисление
              DoOper(@m_reg1,@m_reg2,@m_reg3,@m_state,@m_kopr,m_ret,n_dec1,n_dec2)
              IF m_state<>"2"
                LOOP
              ENDIF
              @3,1 SayDisp NumToStr(m_reg3,21) COLOR "GR+/N"
              IF AT(CHR(m_ret),"/*-+")<>0
                m_reg1:=m_reg3
                m_reg3:=m_reg2:=0
                m_kopr:=SUBSTR("/*-+",AT(CHR(m_ret),"/*-+"),1)
                m_state:="1"
              ENDIF
              DO WHILE .t.
                m_key:=INKEY(0)
                DO CASE
                  CASE m_key==K_ESC
                    m_state:="9"
                    EXIT
                  CASE m_key==K_F10
                    m_state:="9"
                    IF VALTYPE(m_get) == "O"   // Вышли по F10
                      IF VALTYPE(m_get:VarGet()) == "N"
                        m_get:VarPut(m_reg3)
                        m_get:UpdateBuffer()
                      END
                    END
                    EXIT
                  CASE m_key==K_ENTER.OR.CHR(m_key)=="="
                    m_reg1:=m_reg3;n_dec1:=LEN(STR(m_reg1))-AT(".",STR(m_reg1))
                    @1,1 SayDisp NumToStr(m_reg1,21) COLOR "w+/B"
                    EXIT
                  CASE AT(CHR(m_key),"/*-+")<>0
                    m_reg1:=m_reg3
                    m_reg3:=m_reg2:=0
                    m_kopr:=SUBSTR("/*-+",AT(CHR(m_key),"/*-+"),1)
                    m_state:="1";EXIT
                  CASE m_key=330
                    m_reg1:=-m_reg3
                    m_reg3:=m_reg2:=0
                    m_kopr:=" "
                    m_state:="0";EXIT
                  CASE AT(CHR(m_key)," 0123456789")<>0
                    m_reg1:=m_reg2:=m_reg3:=0
                    m_kopr:=" "
                    c_key:=CHR(m_key)
                    m_state:="0"
                    EXIT
                ENDCASE
             ENDDO
      CASE m_state=="9" // Завершить
        EXIT
     ENDCASE

  ENDDO
  WCLOSE()
  SavePar(1)
  SETBLINK(m_blink)
RETURN .t.

