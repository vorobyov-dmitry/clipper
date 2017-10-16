//#include "inkey.ch"
// Cursor movement keys
#define K_UP            5       // Uparrow, Ctrl-E
#define K_DOWN          24      // Dnarrow, Ctrl-X
#define K_LEFT          19      // Leftarrow, Ctrl-S
#define K_RIGHT         4       // Rightarrow, Ctrl-D
#define K_HOME          1       // Home, Ctrl-A
#define K_END           6       // End, Ctrl-F
#define K_PGUP          18      // PgUp, Ctrl-R
#define K_PGDN          3       // PgDn, Ctrl-C
#define K_CTRL_LEFT     26      // Ctrl-Leftarrow, Ctrl-Z
#define K_CTRL_RIGHT    2       // Ctrl-Rightarrow, Ctrl-B
#define K_CTRL_HOME     29      // Ctrl-Home, Ctrl-]
#define K_CTRL_END      23      // Ctrl-End, Ctrl-W
#define K_CTRL_PGUP     31      // Ctrl-PgUp, Ctrl-Hyphen
#define K_CTRL_PGDN     30      // Ctrl-PgDn, Ctrl-^
#define K_CTRL_RET      10      // Ctrl-Return

#define K_ESC           27      // Esc, Ctrl-[
#define K_RETURN        13      // Return, Ctrl-M
#define K_ENTER         13      // Enter, Ctrl-M


// Editing keys
#define K_INS           22      // Ins, Ctrl-V
#define K_DEL           7       // Del, Ctrl-G
#define K_BS            8       // Backspace, Ctrl-H
#define K_CTRL_BS       127     // Ctrl-Backspace
#define K_TAB           9       // Tab, Ctrl-I
#define K_SH_TAB        271     // Shift-Tab


// Control keys
#define K_CTRL_L        12      // Ctrl-L
#define K_CTRL_P        16      // Ctrl-P
#define K_CTRL_T        20      // Ctrl-T
#define K_CTRL_U        21      // Ctrl-U
#define K_CTRL_Y        25      // Ctrl-Y
#define K_CTRL_W        23      // Ctrl-W, Ctrl-End


// Alt keys
#define K_ALT_C         302     // Alt-C
#define K_ALT_F         289     // Alt-F
#define K_ALT_L         294     // Alt-L
#define K_ALT_N         305     // Alt-N
#define K_ALT_P         281     // Alt-P
#define K_ALT_R         275     // Alt-R
#define K_ALT_S         287     // Alt-S
#define K_ALT_V         303     // Alt-V
#define K_ALT_W         273     // Alt-W
#define K_ALT_1         376     // Alt-1
#define K_ALT_2         377     // Alt-2
#define K_ALT_3         378     // Alt-3
#define K_ALT_4         379     // Alt-4
#define K_ALT_5         380     // Alt-5
#define K_ALT_6         381     // Alt-6
#define K_ALT_7         382     // Alt-7
#define K_ALT_8         383     // Alt-8
#define K_ALT_9         384     // Alt-9
#define K_ALT_0         385     // Alt-0

// Function keys
#define K_F1            28      // F1, Ctrl-\
#define K_F2            -1      // F2
#define K_F3            -2      // F3
#define K_F4            -3      // F4
#define K_F5            -4      // F5
#define K_F6            -5      // F6
#define K_F7            -6      // F7
#define K_F8            -7      // F8
#define K_F9            -8      // F9
#define K_F10           -9      // F10
#define K_F11           -40     // F11
#define K_F12           -41     // F12

// Control-function keys
#define K_CTRL_F1       -20     // Ctrl-F1
#define K_CTRL_F2       -21     // Ctrl-F2
#define K_CTRL_F3       -22     // Ctrl-F4
#define K_CTRL_F4       -23     // Ctrl-F3
#define K_CTRL_F5       -24     // Ctrl-F5
#define K_CTRL_F6       -25     // Ctrl-F6
#define K_CTRL_F7       -26     // Ctrl-F7
#define K_CTRL_F8       -27     // Ctrl-F8
#define K_CTRL_F9       -28     // Ctrl-F9
#define K_CTRL_F10      -29     // Ctrl-F10
#define K_CTRL_F11      -44     // Ctrl-F11
#define K_CTRL_F12      -45     // Ctrl-F12

// Alt-function keys
#define K_ALT_F1        -30     // Alt-F1
#define K_ALT_F2        -31     // Alt-F2
#define K_ALT_F3        -32     // Alt-F3
#define K_ALT_F4        -33     // Alt-F4
#define K_ALT_F5        -34     // Alt-F5
#define K_ALT_F6        -35     // Alt-F6
#define K_ALT_F7        -36     // Alt-F7
#define K_ALT_F8        -37     // Alt-F8
#define K_ALT_F9        -38     // Alt-F9
#define K_ALT_F10       -39     // Alt-F10
#define K_ALT_F11       -46     // Alt-F11
#define K_ALT_F12       -47     // Alt-F12

// Shift-function keys
#define K_SH_F1         -10     // Shift-F1
#define K_SH_F2         -11     // Shift-F2
#define K_SH_F3         -12     // Shift-F3
#define K_SH_F4         -13     // Shift-F4
#define K_SH_F5         -14     // Shift-F5
#define K_SH_F6         -15     // Shift-F6
#define K_SH_F7         -16     // Shift-F7
#define K_SH_F8         -17     // Shift-F8
#define K_SH_F9         -18     // Shift-F9
#define K_SH_F10        -19     // Shift-F10
#define K_SH_F11        -42     // Shift-F11
#define K_SH_F12        -43     // Shift-F12

//#include "box.ch"
#define B_SINGLE                "███▐███▌ "
#define B_DOUBLE		( CHR(201) + CHR(205) + CHR(187) + CHR(186) + ;
						CHR(188) + CHR(205) + CHR(200) + CHR(186) )
#define	B_DOUBLE_SINGLE	( CHR(213) + CHR(205) + CHR(184) + CHR(179) + ;
						CHR(190) + CHR(205) + CHR(212) + CHR(179) )
#define SKIP0      DBGOTO( RECNO() )      /* продергивание                    */
#define ALTKEY     "1C0&6$7)@ #5?%423>A"+CHR(34)+".*!='(+/B8D<"

#command   WARNING <msg>;
=>;
           BELL;;
           WaitMessage(<msg>)
#TRANSLATE EXTRACT(<par>,<n1>,<n2>) => SUBSTR(<par>,<n1>,<n2>-<n1>+1)
#TRANSLATE SUBSCH(<par>) => SUBSTR(<par>,1,3)
#TRANSLATE SCHT(<par>) => SUBSTR(<par>,1,2)
#TRANSLATE ANKOD(<par>) => SUBSTR(<par>,4,3)
#IFNDEF RUSS
#TRANSLATE NTOCMONTH(<par>) => MyCMonth(<par>)
#TRANSLATE NTOCDOW(<par>) => MyCDow(<par>)
#TRANSLATE DMY(<par>) => MyDmy(<par>)
#ENDIF
#translate @ <nRow>, <nCol> SayDisp <exp> [PICTURE <cSayPicture>] [COLOR <cColor>] ;
=>;
           SETPOS( <nRow>, <nCol> );;
           DISPOUT( TRANSFORM( <exp>, <cSayPicture> ),<cColor>)

#translate @ <nRow>, <nCol> SayText <exp> [COLOR <cColor>] ;
=>;
           SETPOS( <nRow>, <nCol> );;
           DISPTEXT( <exp>,<cColor>)
#translate @ <nRow>, <nCol> SayPrint <exp> [PICTURE <cSayPicture>] ;
=>;
           SETPOSPRINT( <nRow>, <nCol> );;
           PRINTSTR( TRANSFORM( <exp>, <cSayPicture> ))

#DEFINE COLBR(var)      {|x|IF(x==NIL,var,var:=x)}
#translate  ANSWERu(<m_var>) => ALERT(<m_var>,{"Да","Нi"},"N/BG,w/b")
#translate  ANSWER(<m_var>) => ALERT(<m_var>,{"Да","Нет"},"N/BG,w/b")
#DEFINE  YES 1

#translate STABILIZE BROWSE <var> => do while .not.<var>:stabilize();end
#command CLOSE base <var1>[,<varN>] = >;
         <var1>->(dbclosearea()) ;
         [;<varN>->(dbclosearea())  ]
#command USESPR <var1>[,<varN>] = >;
         DBUSEAREA(.t.,"DBFNTX",(m_sprpath+"\"+<"var1">),,,);;
         DBSETINDEX(m_sprpath+"\"+<"var1">);
         [;DBUSEAREA(.t.,"DBFNTX",(m_sprpath+"\"+<"varN">),,,);;
         DBSETINDEX(m_sprpath+"\"+<"varN">)]
#command RESTMEM <var1>[,<varN>] = >;
             <var1>:=RestVar(<"var1">);
             [;<varN>:=RestVar(<"varN">)]
#command SAVEMEM <var1>[,<varN>] = >;
             <var1>:=SaveVar(<"var1">,<var1>);
             [;<varN>:=SaveVar(<"varN">,<varN>)]
#translate FGOTOP(<var>)     =>   FSEEK(<var>,0)
#translate FGOBOTTOM(<var>)  =>   FSEEK(<var>,0,2)
#translate DispError(<var>) =>   WaitMessage(<var>,"GR+/R,w+/R",.t.)
#translate EXTRACT(<str>,<n1>,<n2>) => SUBSTR(<str>,<n1>,<n2>-<n1>+1)
#define END_LINE CHR(13)+CHR(10)
#command UI <(db)>                                                     ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ex: EXCLUSIVE>]                                          ;
             [<sh: SHARED>]                                             ;
             [<ro: READONLY>]                                           ;
                                                                        ;
      => dbUseArea(                                                     ;
                    <.new.>, <rdd>, <(db)>, <(a)>,                      ;
                    if(<.sh.> .or. <.ex.>, !<.ex.>, NIL), <.ro.>        ;
                  )                                                     ;
                                                                        ;
        ; dbSetIndex( <(db)> )                                      ;

#define ScreenFile(var)    (STRFILE(SAVESCREEN(0,0,MAXROW(),MAXCOL()),var))
#define FileScreen(var)  (RESTSCREEN(0,0,MAXROW(),MAXCOL(),FILESTR(var)))
#define DBAP()     DBAPPEND()
#define DS(var)    DBSEEK(var)
#command DEAL BROWSE <m_browse> KEY <m_key> =>;
CASE DealBrowse(<m_browse>,<m_key>);;
CASE <m_key> == K_ESC.AND.ANSWERu("Завершити програму?")==YES;EXIT;;
CASE <m_key> == K_F12;EXIT;;
CASE <m_key> == K_ALT_L;l_delete:=IF(ANSWERu("Пiдтведжувати видалення ")==YES,.t.,.f.)

#command PRINT BROWSE <m_browse> KEY <m_key> =>;
CASE PrBrow(<m_browse>,<m_key>,m_temppath,@l_print)

#command SCAN BROWSE <m_browse> KEY <m_key> =>;
CASE <m_key> == K_F6;ScanBrowse(@<m_browse>)

#command RANGE BROWSE <m_browse> KEY <m_key> =>;
CASE <m_key> == K_F7;RangeBrowse(@<m_browse>)

#command SEARCH BROWSE <m_browse> KEY <m_key> =>;
CASE <m_key> == K_ALT_F6;SearchBrowse(@<m_browse>)

#command SEEK BROWSE <m_browse> KEY <m_key> =>;
CASE <m_key> == K_SH_F6;SeekBrowse(@<m_browse>)

#command CONTINUE SEARCH BROWSE <m_browse> KEY <m_key> =>;
CASE <m_key> == K_CTRL_F6;ContBrowse(@<m_browse>)

#command DISPLAY BROWSE <m_browse> => ;
    <m_browse>:refReshCurrent();;
    <m_browse>:ColorRect({<m_browse>:RowPos,1,<m_browse>:RowPos,<m_browse>:colCount},{1,1});;
    STABILIZE BROWSE <m_browse>;;
    <m_browse>:ColorRect({<m_browse>:RowPos,1,<m_browse>:RowPos,<m_browse>:colCount},{6,1});;
    <m_browse>:ColorRect({<m_browse>:RowPos,<m_browse>:ColPos,<m_browse>:RowPos,<m_browse>:ColPos},{2,2})


#command NET USE <(db)> [ALIAS <a>] [<new: NEW>] [<ro: READONLY>] [INDEX <(index1)> [, <(indexn)>]]  ;
      => NetUse(<.new.>,, <(db)>, <(a)>, <.ro.>)                 ;
      [; dbSetIndex( <(index1)> )]                               ;
      [; dbSetIndex( <(indexn)> )]

#define Wait_Mig() DispMessage("Чекайте ...","w+/bg,w+*/bg")

#command DCL MENU => ;
Local a_hor_menu:={},a_num_menu:={},a_ver_menu:={},menu_hor_width,s_letter:="",menu_col1,n_menu,menu_clr:="n/w,b/w,n/bg,w/b,n/w,w+/bg"

#command INIT MENU => ;
menu_hor_width:=INT(MAXCOL()/LEN(a_hor_menu));ASIZE(a_num_menu,LEN(a_hor_menu));;
AFILL(a_num_menu,1);n_menu:=1;CLEAREOL(0,0,USL_CLR);;
FOR i:=1 TO LEN(a_hor_menu);j:=AT("~",a_hor_menu\[i]);IF j==0;a_hor_menu\[i]:="~"+a_hor_menu\[i];;
s_letter+=MyUPPER(SUBSTR(a_hor_menu\[i],2,1));ELSE;s_letter+=MyUPPER(SUBSTR(a_hor_menu\[i],j+1,1));END;;
a_hor_menu\[i]:=PADC(a_hor_menu\[i],menu_hor_width);@0,(i-1)*menu_hor_width SayMenu a_hor_menu\[i] COLOR (USL_CLR+","+SEL_CLR);;
j:=LEN(ALLTRIM(a_ver_menu\[i]\[1]\[1]));ASCAN(a_ver_menu\[i]\[1],{|x|IF(LEN(ALLTRIM(x))>j,j:=LEN(ALLTRIM(x)),0)});;
FOR k:=1 TO LEN(a_ver_menu\[i]\[1]);a_ver_menu\[i]\[1]\[k]:=PADR(ALLTRIM(a_ver_menu\[i]\[1]\[k]),j);NEXT;NEXT

#command DEAL MENU => #include "menu_act.prg"

#command DCL LIST =>;
   LOCAL m_browse,s_files:={},l_print:={},l_delete:=.f.;;
   LOCAL m_recno,m_poisk1,m_poisk3,m_poisk4,m_poisk2:={||.f.},m_indexkey,m_time

#command INIT LIST <m_var> TO <m_browse> =>;
sptabl1->(DS(<m_var>));;
<m_browse>:=TBrowseDB(3,1,MAXROW()-1,MAXCOL()-1);<m_browse>:colorspec:='w/b,b/w,w+/b,gr+/n,n/bg';;
<m_browse>:colsep:='│';<m_browse>:SkipBlock:={|n|SkipOrder(n)};<m_browse>:goBottomBlock:={||DBGOBOTTOM()};;
<m_browse>:goTopBlock:={||DBGOTOP()};<m_browse>:cargo:=ALLTRIM(sptabl1->cargo);;
FILL LIST FIELDS BY <m_var>;<m_browse>:freeze:=sptabl1->frz

#command FILL LIST FIELDS by <m_var> => CrList(@m_browse,<m_var>,@l_print)

#command FINISH LIST =>end;end

#command DISPLAYLIST =>;
@m_browse:ntop-1,m_browse:nleft-1,m_browse:nBottom,m_browse:nRight+1 BOX B_DOUBLE+" " COLOR (TOKEN(m_browse:colorspec,",",1));;
@m_browse:ntop-2,0 SayDisp PADC(ALLTRIM(m_browse:cargo),MAXCOL()+1) COLOR (TOKEN(m_browse:colorspec,",",3));;
STABILIZE BROWSE m_browse

#command STABILIZE LIST => STABILIZE BROWSE m_browse
#command ADD MENU NAME <m_name> ITEMS <a_items> KEY <a_key> =>;
AADD(a_hor_menu,<m_name>);AADD(a_ver_menu,{<a_items>,<a_key>})
#command  ADD MENU UP_DOWN =>;
AADD(a_hor_menu,"~Строки");;
AADD(a_ver_menu,{{"Униз на одну строку      "+CHR(25) ,"Угору на одну строку     "+CHR(24),"Униз на один екран        Page Down" ,"Угору на один  екран      Page Up" ,;
"На першу строку          Ctrl+Page Up" ,"На Останню строку       Ctrl+Page Down"},;
{K_DOWN,K_UP,K_PGDN,K_PGUP,K_CTRL_PGUP,K_CTRL_PGDN}})
#command  ADD MENU SEARCH =>;
AADD(a_hor_menu,"Пошу~к");;
AADD(a_ver_menu,{{"Пошук запису по стовбцю   F6" ,;
"Пошук по зразцю           Alt+F6",;
"Пошук по iндексу          Shift+F6",;
"Продовження пошуку запису Ctrl+F6",;
"Пошук по дiапазону        F7"},{K_F6,K_ALT_F6,K_SH_F6,K_CTRL_F6,K_F7}})
#command  ADD MENU LEFT_RIGHT =>;
AADD(a_hor_menu,"Сто~вбцi");;
AADD(a_ver_menu,{{"Вправо на один стовбець             "+CHR(26),"Влiво на один стовбець              "+CHR(27) ,"Вправо на последний видимый столбец End" ,;
"Влiво  на перший видимий стовбець   Home" ,"На перший стовбець                  Ctrl+End" ,"На останнiй  стовбець               Ctrl+Home" ,"Прокрутка вправо                    Ctrl+"+CHR(26)+"   " ,;
"Прокрутка влiво                     Ctrl+"+CHR(27) } ,;
{K_RIGHT,K_LEFT,K_END,K_HOME,K_CTRL_END,K_CTRL_HOME,K_CTRL_RIGHT,K_CTRL_LEFT}})
#command  ADD MENU EDIT =>;
AADD(a_hor_menu,"~Змiна");;
AADD(a_ver_menu,{{"Додати     Ins" ,"Виправити  Enter" ,"Удалити    Delete " },;
{K_INS,K_ENTER,K_DEL}})
#command  ADD MENU PRINT =>;
AADD(a_hor_menu,"~Друк");;
AADD(a_ver_menu,{{"Друк                    Ctrl+P","Друк в фоновому режимi  F2   ","Вивод у файл TXT        Shift+F2","Друкованi стовбцi       Ctrl+L","Настройка друку         F9    ","Настройка принтера      Ctrl+U","Пiдрахунок кiльк. строк Alt+F9 "},;
{K_CTRL_P,K_F2,K_SH_F2,K_CTRL_L,K_F9,K_CTRL_U,K_ALT_F9}})
#command  ADD MENU  DOP=>;
AADD(a_hor_menu,"~Настройка");;
AADD(a_ver_menu,{{"Пiдтвердження вилучення запису  Alt+L "},{K_ALT_L}})
#command create menu standart => ;
ADD MENU UP_DOWN ;;
ADD MENU SEARCH  ;;
ADD MENU LEFT_RIGHT ;;
ADD MENU EDIT ;;
ADD MENU PRINT ;;
ADD MENU DOP

#command WinSay => ;
IF WCOL()\<0.OR.WLASTCOL()>MAXCOL(.T.);WMOVE(WROW(),0);END;;
IF WROW()\<0.OR.WLASTROW()>MAXROW(.t.);WMOVE(0,WCOL());END

#command INIT GET <m_var> TO <a_get> KEY <m_key> DATA <a_data> SAY <a_say> =>;
<a_get>:=InitGet(<m_var>,@<a_say>);;
j:=0;AEVAL(<a_get>,{|x|<a_get>\[++j]:block:={|x|IF(x==NIL,<a_data>\[<m_key>],<a_data>\[<m_key>]:=x)}});;
ASIZE(<a_data>,LEN(<a_get>))

#command  DISPLAY GET <a_get> KEY <n_pole> SAY <a_say> DATA <a_data> => ;
FOR <n_pole>:=1 TO len(<a_get>);;
<a_get>\[<n_pole>]:display();;
IF <a_say>\[<n_pole>] # NIL.AND. VALTYPE(<a_say>\[<n_pole>]\[1])<>"A";;
SETPOS(<a_say>\[<n_pole>]\[1],<a_say>\[<n_pole>]\[2]);;
DISPOUT(TRANSFORM(EVAL(<a_say>\[<n_pole>]\[5],<a_data>,<n_pole>),<a_say>\[<n_pole>]\[3]),<a_say>\[<n_pole>]\[4]);;
END;NEXT


#command DEAL GET <a_get> KEY <n_pole> TO <m_key> COLOR <var1>,<var2> SAY <a_say> DATA <a_data> =>;
SETPOS(<a_get>\[<n_pole>]:row,<a_get>\[<n_pole>]:col);DISPOUT(TRANSFORM(EVAL(<a_get>\[<n_pole>]:block),<a_get>\[<n_pole>]:picture),<var1>);;
<m_key>:=INKEY(0);;
SETPOS(<a_get>\[<n_pole>]:row,<a_get>\[<n_pole>]:col);DISPOUT(TRANSFORM(EVAL(<a_get>\[<n_pole>]:block),<a_get>\[<n_pole>]:picture),<var2>)
#command WORK GET <a_get> KEY <m_key> BY <n_pole> SAY <a_say> DATA <a_data> =>;
CASE <m_key> == K_UP;IF <n_pole> ==1;ELSE;<n_pole>:=<n_pole>-1;END;;
CASE <m_key> == K_DOWN;IF <n_pole> ==LEN(<a_get>);ELSE;<n_pole>:=<n_pole>+1;END;;
CASE <m_key> == K_ESC;BeepErr();IF ALERT("Всi змiни будуть анулiрованi;Выходити ?",{"Так","Нi "})==1;EXIT;END;;
CASE <m_key> == K_F12.OR. <m_key> == K_CTRL_END ;;
IF NetRLOCK();<n_pole>:=1;AEVAL(<a_get>,{|x|FIELDPUT(x:cargo,EVAL(x:block)),<n_pole>++});UNLOCK;EXIT;;
ELSE;DispError("Неможливо заблокувати запис");END;;
CASE <m_key> == K_ENTER ;WinSay;ReadMy({<a_get>\[<n_pole>]},IF(<a_say>\[<n_pole>] # NIL.AND.VALTYPE(<a_say>\[<n_pole>]\[1])=="A",<a_say>\[<n_pole>],NIL));;
IF <a_say>\[<n_pole>] # NIL .AND. VALTYPE(<a_say>\[<n_pole>]\[1])<>"A";;
SETPOS(<a_say>\[<n_pole>]\[1],<a_say>\[<n_pole>]\[2]);;
DISPOUT(TRANSFORM(EVAL(<a_say>\[<n_pole>]\[5],<a_data>,<n_pole>),<a_say>\[<n_pole>]\[3]),<a_say>\[<n_pole>]\[4]);;
END

#command INIT DATA <a_data> FROM <a_get> KEY <n_pole> =>;
<n_pole>:=1;AEVAL(<a_data>,{|x|<a_data>\[<n_pole>]:=FIELDGET(<a_get>\[<n_pole>]:cargo),<n_pole>:=<n_pole>+1});<n_pole>:=1

#command INIT DATA <a_data> FROM <a_get> KEY <n_pole> BLANK =>;
<n_pole>:=1;AEVAL(<a_data>,{|x|<a_data>\[<n_pole>]:=BLANK(FIELDGET(<a_get>\[<n_pole>]:cargo),.t.),<n_pole>:=<n_pole>+1});<n_pole>:=1

#command TAKE GET <a_get> KEY <n_pole> SAY <a_say> DATA <a_data> =>;
<n_pole>:=1;WHILE .t.;ReadMy({<a_get>\[<n_pole>]},IF(<a_say>\[<n_pole>] # NIL.AND.VALTYPE(<a_say>\[<n_pole>]\[1])=="A",<a_say>\[<n_pole>],NIL));;
IF <a_say>\[<n_pole>] # NIL.AND. VALTYPE(<a_say>\[<n_pole>]\[1])<>"A";;
SETPOS(<a_say>\[<n_pole>]\[1],<a_say>\[<n_pole>]\[2]);;
DISPOUT(TRANSFORM(EVAL(<a_say>\[<n_pole>]\[5],<a_data>,<n_pole>),<a_say>\[<n_pole>]\[3]),<a_say>\[<n_pole>]\[4]);;
END;;
DO CASE;CASE LASTKEY() == K_ESC.AND.ALERT("Завершити програму?",{"Так","Нi"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT;;
CASE LASTKEY() == K_UP.AND.<n_pole> # 1;<n_pole>--;LOOP;;
CASE LASTKEY() == K_F12.OR.LASTKEY() == K_CTRL_END.OR.<n_pole> == LEN(<a_get>);;
IF NetDbAp();<n_pole>:=1;AEVAL(<a_get>,{|x|FIELDPUT(x:cargo,EVAL(x:block)),<n_pole>++});EXIT;;
ELSE;DispError("Неможливо добавитi запис");END;;
CASE <n_pole> == 1.AND.EMPTY(<a_data>\[1]);l_stop:=.f.;EXIT;;
OTHERWISE ;<n_pole>++;END;END

//
