#define RUSS 1
#include "new.ch"
#include "set.ch"
STATIC a_cur:={},s_delim:="'."
Static m_language:=1
STATIC m_poisk1:="",m_poisk2:="",m_poisk3:="",m_poisk4:=""
#define DOS_LETTERS  "������������������������������������������������������������������������"
#define WINDOWS_LETTERS "������������������������������������������������������������������������"

Function SaveCur()
  AADD(a_cur,{ROW(),COL(),SetCursor()})
RETURN .t.
Function RestCur()
  LOCAL n:=LEN(a_cur)
  SETPOS(a_cur[n][1],a_cur[n][2]);SetCursor(a_cur[n][3])
  ADEL(a_cur,n);ASIZE(a_cur,n-1)
RETURN .t.
  Function DbInsert()
    LOCAL m_recno:=RECNO(),n_order:=INDEXORD(),k,a_fields:={},i,;
    m_del:=.f.,l_delete:=SET(_SET_DELETED,.f.),m_gauge:=InitGauge("��⠢��� ��ப�",2)
    IF .NOT.USED()
      SET(_SET_DELETED,l_delete)
      RETURN .f.
    ENDIF
    DBSETORDER(0);ASIZE(a_fields,FCOUNT())
    i:=1;AEVAL(a_fields,{|x|a_fields[i]:=BLANK(fieldget(i),.t.),i++})
//    DBSKIP()
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
RETURN .t.

FUNCTION NumToStr(m_registr,n_len,n_dec,var1,var2)
  LOCAL c_delim:=IF(var1==NIL,SUBSTR(s_delim,1,1),var1),m_len:=IF(n_len<>NIL,n_len,16),;
  m_dec,x:=ABS(INT(m_registr))
  LOCAL y:=ABS(m_registr)-x
  LOCAL c_buf:="",m_str:=ALLTRIM(str(x,18))
  LOCAL n:=INT((LEN(m_str)+2)/3),i
  m_str:=PADL(m_str,3*n)
  FOR i:=1 TO n-1
    c_buf:=c_buf+SUBSTR(m_str,(i-1)*3+1,3)+c_delim
  NEXT
  c_buf:=LTRIM(c_buf+RIGHT(m_str,3))
  m_dec:=IF(n_dec==NIL,m_len-LEN(c_buf)-2,n_dec)
  IF m_dec<>0
  y:=ROUND(y,m_dec+2)
  IF ROUND(y,m_dec)<>0
    m_str:=ALLTRIM(STR(ROUND(y,m_dec),m_dec+2,m_dec));n:=LEN(m_str)
    FOR i:=n TO 1 STEP -1
      IF SUBSTR(m_Str,i,1)<>"0"
        EXIT
      ENDIF
    NEXT
    c_buf:=c_buf+IF(var2==NIL,SUBSTR(s_delim,2,1),var2)+SUBSTR(SUBSTR(m_str,1,i),3,i)
  ENDIF
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

Function SumToStr(m_registr1,n_len,var1,var2)
    LOCAL m_registr:=ROUND(m_registr1,4)
    LOCAL m_len:=IF(n_len<>NIL,n_len,16),x:=FLOOR(ABS(m_registr))
    LOCAL y:=ROUND(ROUND(ABS(m_registr)-x,4),2),c_buf:=""
//    LOCAL y:=ROUND(ABS(m_registr)-x,2),c_buf:=""
    LOCAL m_str:=ALLTRIM(STR(x,18))
    LOCAL n:=INT((LEN(m_str)+2)/3),i,c_delim:=IF(var1==NIL,LEFT(s_delim,1),var1)
    m_str:=PADL(m_str,3*n)
    FOR i:=1 TO n-1
      c_buf:=c_buf+SUBSTR(m_str,(i-1)*3+1,3)+c_delim
    NEXT
    c_buf:=LTRIM(c_buf+RIGHT(m_str,3))
    c_buf:=IF(m_registr<0,"-","")+c_buf+IF(var2==NIL,SUBSTR(s_delim,2,1),var2)+SUBSTR(STR(y,4,2),3,2)
    IF LEN(c_buf)<=m_len
      c_buf:=PADL(c_buf,m_len)
    ELSE
      c_buf:=REPLICATE("*",m_len)
    ENDIF
RETURN c_buf
Function SETCHARDELIM(Var)
  IF VALTYPE(var)=="C"
    s_delim:=var
  ENDIF
RETURN s_delim


Function GetMonth()
LOCAL m_cur:=SaveCur()
LOCAL a_choice:={},i,m_color:=SETCOLOR("w+/b,n/w" ),m_choice,j
Local m_value:="",m_key
FOR i:=1 TO 12
  AADD(a_choice,PADR(STR(i,2)+" "+MyCmonth(i),16))
NEXT
DispBox(6,30,19,50,B_DOUBLE+" ","w/b")
@6,32 SayDisp IF(m_language<>1,"�롮� �����","���i� �i����") Color "gr+/b"
i:=month(DATE())
i:=IF(i==1,12,i-1)
Shadow(6,30,19,50)
// m_choice:=ACHOICE(7,32,18,48,a_choice,,,i,0)
FOR j:=1 TO 12
  @6+j,32 SayDisp(a_choice[j]) COLOR "W+/B"
NEXT
DO WHILE .T.
  @6+i,32 SayDisp(a_choice[i]) COLOR "n/w"
  m_key:=INKEY(0)
  @6+i,32 SayDisp(a_choice[i]) COLOR "w+/b"
  DO CASE
    case m_key==K_DOWN
      i:=IF(i==12,1,i+1)
    CASE m_key==K_UP
      i:=IF(i==1,12,i-1)
    CASE LEN(m_value)<2.AND.m_key>=32.AND.m_key<=254
       m_value+=MyUpper(CHR(m_key))
       j:=i
       i:=VAL(m_value)
       IF i<=12.AND.i>=1
        @19,32+LEN(m_value) SayDisp MyUpper(CHR(m_key)) COLOR "GR+/b"
       ELSE
        m_value:=SUBSTR(m_value,1,LEN(m_value)-1)
        i:=j
        BeepErr()
      ENDIF
    CASE m_key==K_BS.AND.LEN(m_value)>0
        @19,32+LEN(m_value) SayDisp "�" COLOR "GR+/b"
        m_value:=SUBSTR(m_value,1,LEN(m_value)-1)
    CASE m_key==K_ENTER
      m_choice:=i
      EXIT
    CASE m_key==K_ESC
      m_choice:=0
      EXIT
  ENDCASE


ENDDO
RestCur()
SetColor(m_color)
RETURN m_choice

Function DealBrowse(m_browse,m_key)
DO CASE
CASE m_key == K_RIGHT     ; m_browse:right();m_browse:refreshCurrent()
CASE m_key == K_LEFT      ; m_browse:left() ;m_browse:refreshCurrent()
CASE m_key == K_CTRL_LEFT ; m_browse:panleft() ;m_browse:refreshCurrent()
CASE m_key == K_DOWN      ; m_browse:down();m_browse:refreshCurrent()
CASE m_key == K_UP        ; m_browse:up();m_browse:refreshCurrent()
CASE m_key == K_CTRL_PGUP ; m_browse:gotop();m_browse:refreshAll()
CASE m_key == K_CTRL_PGDN ; m_browse:gobottom();m_browse:refreshAll()
CASE m_key == K_PGUP      ; m_browse:pageUp();m_browse:refreshAll()
CASE m_key == K_PGDN      ; m_browse:pageDown();m_browse:refreshAll()
CASE m_key == K_HOME      ; m_browse:home();m_browse:refreshAll()
CASE m_key == K_END       ; m_browse:end();m_browse:refreshAll()
CASE m_key == K_CTRL_HOME ; m_browse:panhome();m_browse:refreshAll()
CASE m_key == K_F10       ; calcul()
CASE m_key == K_ALT_F10       ; calc()
CASE m_key == K_CTRL_END  ; m_browse:panend();m_browse:refreshAll()
OTHERWISE
RETURN .f.
ENDCASE
RETURN .t.

Function ScanBrowse(m_browse)
  LOCAL m_recno:=RECNO(),GetList:={}
  LOCAL m_screen  := SAVESCREEN(INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+4,77)
  LOCAL m_esc:=SET(_SET_ESCAPE,.t.)
  @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+3,75 BOX B_DOUBLE+" " COLOR "n/bg"
  @INT((MAXROW()-4)/2)+1,6 SayText '~1'+PADC( '����i�� ���祭�� ~2'+CHARREPL(";",;
  UPPER(ALLTRIM(m_browse:GetColumn(m_browse:colpos):heading))," ")+'~1 ��� ����� :', 68 ) COLOR  "n/bg,b/bg"
  m_poisk3:=BLANK(eval(m_browse:GetColumn(m_browse:colpos):block),.t.)
  @INT((MAXROW()-4)/2)+2,(40-INT(m_browse:ColWidth(m_browse:colpos)/2)) GET m_poisk3 COLOR  "GR+/N"
  READMY(getlist,,IF(VALTYPE(m_poisk3)=="N",1,NIL))
  RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )
  IF(LASTKEY()!=K_ESC)
    m_poisk1:=m_browse:GetColumn(m_browse:colpos):block;m_poisk2:={||m_poisk3<>EVAL(m_poisk1)}
    DBEVAL( { || NIL },,m_poisk2 )
    IF EOF()
      DBGOTO(m_recno)
      DispError(" ��ப� � ⠪�� ���祭�� �⮢��� �� �������� ")
    ELSE
      m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
    ENDIF
  ENDIF
  SET(_SET_ESCAPE,m_esc)
RETURN .t.

Function RangeBrowse(m_browse)
  LOCAL m_recno:=RECNO(),GetList:={}
  LOCAL m_screen:=SAVESCREEN(INT((MAXROW()-6)/2),5,INT((MAXROW()-6)/2)+7,77)
  LOCAL m_esc:=SET(_SET_ESCAPE,.t.)
  SET(_SET_ESCAPE,m_esc)
  @INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+6, 75  BOX B_DOUBLE+" " COLOR ("n/bg");;
  @INT((MAXROW()-6)/2)+1,6 SayDisp PADC( '����i�� ���祭�� ������ �࠭��i ����� :', 68 ) COLOR  ("n/bg")
  @INT((MAXROW()-6)/2)+3,6 SayDisp PADC( '����i�� ���祭�� ������ �࠭��i �����:', 68 ) COLOR  ("n/bg")
  m_poisk4:=m_poisk3:=BLANK((eval(m_browse:GetColumn(m_browse:colpos):block)),.t.)
  @INT((MAXROW()-6)/2)+2,(40-INT( m_browse:colwidth(m_browse:colpos)/2 ) ) GET m_poisk3  COLOR "GR+/N"
  @ INT((MAXROW()-6)/2)+4, ( 40 - INT( m_browse:colwidth(m_browse:colpos)/2 ) ) GET m_poisk4  COLOR "GR+/N"
  READMY(getlist,,IF(VALTYPE(m_poisk3)=="N",1,NIL))
  RESTSCREEN( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+7, 77, m_screen )
  IF(LASTKEY()!=K_ESC)
    m_poisk1:=m_browse:GetColumn(m_browse:colpos):block
    m_poisk2:={||.NOT.(EVAL(m_poisk1)>=m_poisk3.AND.EVAL(m_poisk1)<=m_poisk4)}
    DBEVAL( { || NIL },,m_poisk2 )
    IF EOF()
      DBGOTO(m_recno)
      DispError(" ��ப� � ⠪�� ���祭�� �⮢��� �� �������� ")
    ELSE
      m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
    ENDIF
  ENDIF
  SET(_SET_ESCAPE,m_esc)
RETURN .t.

Function SearchBrowse(m_browse)
  LOCAL m_recno:=RECNO(),GetList:={}
  LOCAL m_screen  := SAVESCREEN(INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+4,77)
  LOCAL m_esc:=SET(_SET_ESCAPE,.t.)
  m_poisk3:=BLANK(eval(m_browse:GetColumn(m_browse:colpos):block),.t.)
  IF VALTYPE(m_poisk3)<>"C"
    DispError("���� �� �ࠧ�� � ������ �⮢��i ����������")
    RETURN .t.
  ENDIF
  @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+3,75 BOX B_DOUBLE+" " COLOR "n/bg"
  @INT((MAXROW()-4)/2)+1,6 SayText '~1'+PADC( '����i�� ���祭�� ~2'+CHARREPL(";",ALLTRIM(m_browse:GetColumn(m_browse:colpos):heading),' ')+'~1 ��� ����� �� �ࠧ�� :', 68 ) COLOR "n/bg,w+/bg"
  @INT((MAXROW()-4)/2)+2,(40-INT(m_browse:ColWidth(m_browse:colpos)/2)) GET m_poisk3 COLOR "Gr+/N" PICTURE "@!"
  READ
  m_poisk3:="*"+ALLTRIM(m_poisk3)+"*"
  RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )
  IF(LASTKEY()!=K_ESC)
    m_poisk1:=m_browse:GetColumn(m_browse:colpos):block
    m_poisk3:=ALLTRIM(m_poisk3)
    m_poisk2:={||.NOT.EOF().AND..NOT.LIKE(m_poisk3,UPPER(EVAL(m_poisk1)))}
    DBEVAL( { || NIL },,m_poisk2 )
    IF EOF()
      DBGOTO(m_recno)
      DispError(" ��ப� � ⠪�� ���祭�� �⮢��� �� �������� ")
    ELSE
      m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
    ENDIF
  ENDIF
  SET(_SET_ESCAPE,m_esc)
RETURN .t.
Function SeekBrowse(m_browse)
  LOCAL m_recno:=RECNO(),m_clr:=m_browse:colorspec,GetList:={}
  LOCAL m_indexkey
  LOCAL m_screen  := SAVESCREEN(INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+4,77)
  LOCAL m_esc:=SET(_SET_ESCAPE,.t.)
  IF .NOT.EMPTY(INDEXKEY(0))
    m_indexkey:=&(INDEXKEY(0))
    m_indexkey:=BLANK(m_indexkey,.t.)
    @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+3,75 BOX B_DOUBLE+" " COLOR "n/bg"
    @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( '����i�� ���祭�� i������ ��� ����� :', 68 ) COLOR "n/bg" PICTURE "@!";;
    @INT((MAXROW()-4)/2)+2,(40-INT(LEN(m_indexkey)/2)) GET m_indexkey COLOR (TOKEN(m_clr,",",4)) ;;
    READ
    RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )
    IF(LASTKEY()!=K_ESC)
      m_indexkey:=ALLTRIM(m_indexkey)
      DBSEEK(m_indexkey,.t.)
      IF .NOT.FOUND()
        DispError(" ��ப� � ⠪�� ���祭�� �⮢��� �� �������� ")
        DBGOTO(m_recno)
      ELSE
        m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
      ENDIF
    ENDIF
  ELSE
    DispError("���� �� i������ ����������")
  ENDIF
  SET(_SET_ESCAPE,m_esc)
RETURN .t.
Function PrBrow(m_browse,m_key,m_temppath,l_print)
  LOCAL m_recno,l
  DO CASE
    CASE m_key == K_CTRL_P
      m_recno:=RECNO()
      OpenPrn()
      PrintBrowse(m_browse,l_print)
      DBGOTO(m_recno)
      ClosePrn()
  CASE m_key == K_SH_F2
      m_recno:=RECNO()
      OpenPrn(m_temppath+ALLTRIM(ALIAS())+".txt")
      PrintBrowse(m_browse,l_print)
      DBGOTO(m_recno)
      ClosePrn()
  CASE m_key == K_F2
      m_recno:=RECNO()
      OpenPrn(m_temppath+ALLTRIM(ALIAS())+".txt")
      l:=PrintBrowse(m_browse,l_print)
      DBGOTO(m_recno)
      ClosePrn()
      IF l
        MyPrintFile(m_temppath+ALLTRIM(ALIAS())+".txt")
      endif
  CASE m_key == K_CTRL_L
      SetLprint(m_browse,@l_print)
  CASE m_key == K_CTRL_U
      LSetprint()
  CASE m_key == K_F9
        SetLpechat()
  CASE m_key == K_ALT_F9
      CountLines()
  OTHERWISE
    RETURN .f.
ENDCASE
RETURN .t.
Function MyCMonth(n)
  LOCAL a_month:={;
"�i祭�","��⨩","��१���","��i⥭�","�ࠢ���","��ࢥ��",;
"������","��௥��","���ᥭ�","���⥭�","���⮯��","��㤥��"}
IF VALTYPE(n)=="N"
  IF m_language==1
    IF n>=1.AND.n<=12
      RETURN a_month[n]
    ENDIF
  ELSE
      RETURN NToCMonth(n)
  ENDIF
ENDIF
RETURN ""
Function MyCdow(i)
IF VALTYPE(i)=="N"
  IF m_language==1
  DO CASE
    CASE i==1
      RETURN "���i��"
    CASE i==2
      RETURN "�����i���"
    CASE i==3
      RETURN "�i��ப"
    CASE i==4
      RETURN "��।�"
    CASE i==5
      RETURN "��⢥�"
    CASE i==6
      RETURN "�'�⭨��"
    CASE i==7
      RETURN "�㡮�"
  ENDCASE
  ELSE
    RETURN NTOCDOW(i)
  ENDIF
ENDIF
RETURN ""
function MyDmy(m_ddoc)
  LOCAL a_month:={;
        " �i�� ",;
        " ��⮣� ",;
        " ��१�� ",;
        " ��i�� ",;
        " �ࠢ�� ",;
        " �ࢭ� ",;
        " ����� ",;
        " �௭� ",;
        " ����� ",;
        " ����� ",;
        " ���⮯��� ",;
        " ��㤭� "}
  LOCAL a_month1:={;
        " ﭢ���",;
        " 䥢ࠫ�",;
        " ���� ",;
        " ��५� ",;
        " ��� ",;
        " ��� ",;
        " ��� ",;
        " ������ ",;
        " ᥭ���� ",;
        " ������ ",;
        " ����� ",;
        " ������� "}
 IF .NOT.EMPTY(m_ddoc)
    RETURN (STRZERO(DAY(m_ddoc),2)+;
    IF(m_language==1,a_month[MONTH(m_ddoc)],a_month1[MONTH(m_ddoc)]);
      +STR(YEAR(m_ddoc),4))+IF(m_language==1,' �.',' �.')
 ENDIF
RETURN ""
FUNCTION SETLANG(mode)
  IF VALTYPE(mode)=="N"
    m_language:=mode
  ENDIF
RETURN m_language
FUNCTION    NumToChar(var)
  IF m_language==1
    RETURN Num2(var)
  ENDIF
RETURN Num1(var)
STATIC FUNCTION    Num2( input_num )

LOCAL  units := { "", "���� ", "��i " ,"�� " ,"��� ", "�'��� ", "�i��� ",;
      "�i� ", "�i�i� ", "���'��� ", "������ ", "���������� ", "���������� ",;
      "�ਭ������ ", "��ୠ����� ", "�'�⭠����� ", "�i�⭠����� ", "�i�������� ",;
      "�i�i�������� ", "���'�⭠����� "  }
LOCAL  units2 := { "", "���� ", "��i " ,"�� " ,"��� ", "�'��� " , "�i��� ",;
      "�i� ", "�i�i� ", "���'��� ", "������ ", "���������� ", "���������� ",;
      "�ਭ������ ", "��ୠ����� ", "�'�⭠����� ", "�i�⭠����� ", "�i�������� ",;
      "�i�i�������� ", "���'�⭠����� "  }
LOCAL  tens := { "", "", "�������� ", "�ਤ���� ", "�ப ", "�'�⤥��� ",;
      "�i�⤥��� ", "�i������ ", "�i�i������ ", "���'ﭮ�� " }
LOCAL  hundreds := { "","�� ","��i��i ","���� ","����� ","�'���� ",;
       "�i���� ","�i��� ","�i�i��� ", "���'���� " }
LOCAL   outstr:=IF(input_num < 0,"�i��� ","") ,amtstr := TRANSFORM(ABS(input_num),"999999999999")
IF(VALTYPE(input_num) != "N")
   RETURN("")
END
IF(input_num < -99999999999 .OR. input_num > 999999999999)
   RETURN("")
END
IF(input_num ==0)
   RETURN("��� ")
END
IF VAL(SUBSTR(amtstr,1,3))>0
  outstr+=hundreds[VAL(SUBSTR(amtstr,1,1))+1];
  +tens[VAL(SUBSTR(amtstr,2,1))+1]+;
  units[IF(SUBSTR(amtstr,2,1)<"2",VAL(SUBSTR(amtstr,2,2)),VAL(SUBSTR(amtstr,3,1)))+1]+;
  "�i��'��"+IF(VAL(SUBSTR(amtstr,3,1))==1.AND.VAL(SUBSTR(amtstr,2,2))<>11," ",IF(VAL(SUBSTR(amtstr,2,2))<5.AND.VAL(SUBSTR(amtstr,2,2))>0,"� ","i� "))
ENDIF
IF VAL(SUBSTR(amtstr,4,3))>0
  outstr+=hundreds[VAL(SUBSTR(amtstr,4,1))+1];
  +tens[VAL(SUBSTR(amtstr,5,1))+1]+;
  units[IF(SUBSTR(amtstr,5,1)<"2",VAL(SUBSTR(amtstr,5,2)),VAL(SUBSTR(amtstr,6,1)))+1]+;
  "�i��o�"+IF(VAL(SUBSTR(amtstr,6,1))==1.AND.VAL(SUBSTR(amtstr,5,2))<>11," ",IF(VAL(SUBSTR(amtstr,5,2))<5.AND.VAL(SUBSTR(amtstr,6,1))>0,"� ","i� "))

ENDIF

IF VAL(SUBSTR(amtstr,7,3))>0
  outstr+=hundreds[VAL(SUBSTR(amtstr,7,1))+1];
  +tens[VAL(SUBSTR(amtstr,8,1))+1]+;
  units2[IF(SUBSTR(amtstr,8,1)<"2",VAL(SUBSTR(amtstr,8,2)),VAL(SUBSTR(amtstr,9,1)))+1]+;
  "����"+IF(VAL(SUBSTR(amtstr,9,1))==1.AND.VAL(SUBSTR(amtstr,8,2))<>11,"� ",IF(VAL(SUBSTR(amtstr,8,2))<5.AND.VAL(SUBSTR(amtstr,9,1))>0,"i "," "))
ENDIF
IF VAL(SUBSTR(amtstr,10,3))>0
  outstr+=hundreds[VAL(SUBSTR(amtstr,10,1))+1];
  +tens[VAL(SUBSTR(amtstr,11,1))+1]+;
  units[IF(SUBSTR(amtstr,11,1)<"2",VAL(SUBSTR(amtstr,11,2)),VAL(SUBSTR(amtstr,12,1)))+1]
ENDIF
RETURN( ALLTRIM(outstr))
STATIC FUNCTION    Num1( input_num )

LOCAL  amtstr,lenamt,negstr,tstr,hstr,kstr
LOCAL  hkstr,mstr,hmstr,bilstr,output_str,ch
LOCAL  units := { "", "����", "���" ,"��" ,"����", "����", "����",;
      "ᥬ�", "��ᥬ�", "������", "������", "����������", "���������",;
      "�ਭ�����", "���ୠ����", "��⭠����", "��⭠����", "ᥬ������",;
      "��ᥬ������", "����⭠����"  }
LOCAL  tens := { "", "", "�������", "�ਤ���", "�ப", "���줥���",;
      "���줥���", "ᥬ줥���", "��ᥬ줥���", "���ﭮ��" }
LOCAL  hundreds := { "","��","�����","����","������","������",;
       "������","ᥬ���","��ᥬ���", "��������" }

IF(VALTYPE(input_num) != "N")
   RETURN("")
END
IF(input_num < -9999999999.999999 .OR. input_num > 9999999999.999999)
   RETURN("")
END

tstr := hstr := kstr := hkstr := mstr := hmstr := bilstr := negstr := ""

input_num := INT(input_num)
amtstr := LTRIM(STR(input_num))

IF(input_num < 0)
   negstr := "����� "
   amtstr := SUBSTR(amtstr,2)
END

lenamt := LEN(amtstr)

IF(VAL(SUBSTR(amtstr,-2,2)) < 20)
   IF(input_num == 0)
      tstr = "����"
   ELSE
      tstr = units[VAL(SUBSTR(amtstr,-2,2)) + 1]
   END
ELSE
   tstr = tens[VAL(SUBSTR(amtstr,-2,1)) + 1] + " " + ;
        + units[VAL(SUBSTR(amtstr,-1,1)) + 1]
END

IF(lenamt == 3)
   hstr = hundreds[VAL(SUBSTR(amtstr,-3,1)) + 1] + " "
END

IF(lenamt == 4)
  ch := VAL(SUBSTR(amtstr,-4,1))
     IF(ch == 1)
        kstr := "���� ����� "
     ELSEIF(ch == 2)
          kstr := "��� ����� "
         ELSEIF( ch == 3 .OR. ch == 4 )
            kstr := units[ ch+1 ] + " ����� "
         ELSE
            kstr := units[ ch+1 ] + " ����� "
     END
     kstr += ( hundreds[VAL(SUBSTR(amtstr,-3,1)) + 1] + " " )
END

IF(lenamt > 4)
   ch := VAL(SUBSTR(amtstr,-3,1))
   hstr := " " + hundreds[ ch+1 ] + " "
   IF( VAL(SUBSTR(amtstr,-6,3)) == 0)
      kstr = ""
   ELSEIF( VAL(SUBSTR(amtstr,-5,2)) < 20 )
      ch := VAL(SUBSTR(amtstr,-5,2))
        IF(ch == 1)
           kstr += " ���� �����"
        ELSEIF(ch == 2)
               kstr += " ��� �����"
            ELSEIF(ch == 3 .OR. ch == 4)
                   kstr += (units[ ch+1 ] + " �����")
                ELSE
                   kstr += (units[ ch+1 ] + " �����")
        END
   ELSE
      kstr = tens[VAL(SUBSTR(amtstr,-5,1)) + 1] + " "
      ch := VAL(SUBSTR(amtstr,-4,1))
      IF(ch == 1)
         kstr += "���� �����"
      ELSEIF(ch == 2)
            kstr += "��� �����"
          ELSEIF(ch == 3 .OR. ch == 4)
                kstr += ( units[ ch+1 ] + " �����" )
              ELSE
                kstr += ( units[ ch+1 ] + " �����" )
     END
   END
END

IF(lenamt >= 6)
   ch := VAL(SUBSTR(amtstr,-6,1))
   hkstr := IF( ch == 0, "", hundreds[ch + 1] + " " )
END

IF(lenamt == 7)
   ch := VAL(SUBSTR(amtstr,-7,1))
   mstr := units[ch+ 1]
    IF(ch == 1)
      mstr += " ������� "
    ELSEIF(ch == 2 .OR. ch == 3 .OR. ch == 4)
          mstr += " �������� "
        ELSE
          mstr += " ��������� "
    END

ELSEIF( lenamt > 7)
   IF( VAL(SUBSTR(amtstr,-9,3)) == 0 )
     mstr := ""
   ELSEIF( VAL(SUBSTR(amtstr,-8,2)) < 20 )
         ch := VAL(SUBSTR(amtstr,-8,2))
         mstr = units[ ch+1 ]
          IF(ch == 1)
            mstr += " ������� "
          ELSEIF(ch == 2 .OR. ch == 3 .OR. ch == 4)
                mstr += " �������� "
              ELSE
                mstr += " ��������� "
          END
       ELSE
         ch := VAL(SUBSTR(amtstr,-7,1))
         mstr = tens[VAL(SUBSTR(amtstr,-8,1)) + 1] + IF( ch == 0,""," ") +;
                units[ ch+1 ]
          IF(ch == 1)
            mstr += " ������� "
          ELSEIF(ch == 2 .OR. ch == 3 .OR. ch == 4)
                mstr += " �������� "
              ELSE
                mstr += " ��������� "
       END
   END
END

IF(lenamt >= 9)
   ch := VAL(SUBSTR(amtstr,-9,1))
   hmstr := IF( ch == 0, "", hundreds[ ch+1 ] + " " )
END

IF(lenamt == 10)
   ch := VAL(SUBSTR(amtstr,-10,1))
   bilstr = units[ ch+1 ]
     IF(ch == 1)
       bilstr += " �������"
     ELSEIF(ch == 2 .OR. ch == 3 .OR. ch == 4)
           bilstr += " ������ठ"
         ELSE
           bilstr += " ������म�"
     END
     bilstr += " "
END

output_str := negstr + bilstr + hmstr + mstr + hkstr + kstr + hstr + tstr

RETURN( LTRIM(TRIM( STRTRAN(STRTRAN(output_str, "   ", " "), "  ", " ") )))
Function InitScr(m_var)
LOCAL i:=-1,m_clr:="w/b,w/b,b/w,n/w,R/W",m_str1,m_str2,m_text,n,j
LOCAL m_max_row,m_max_col
IF screen->(DS(m_var))
  IF screen->type=="MAX"
    m_max_row:=MAXROW()
    m_max_col:=MAXCOL()
  ELSE
    m_max_row:=screen->row+screen->high-1
    m_max_col:=screen->col+screen->width-1
 ENDIF
  i:=WOPEN(screen->row,screen->col,m_max_row,m_max_col)
    @0,0,MAXROW(),MAXCOL() BOX IF(EMPTY(screen->bord),B_SINGLE,IF(LEN(RTRIM(screen->bord))==8,RTRIM(screen->bord)+" ",RTRIM(screen->bord))) ;
    COLOR (IF(EMPTY(screen->clr),TOKEN(m_clr,",",1),TOKEN(screen->clr,",",1)))
    m_str1:="~3"+RTRIM(screen->str1);m_str2:="~4"+RTRIM(screen->str2)
    @0,INT((screen->width-LEN(m_str1)+NUMAT("~",m_str1)*2)/2) SayText m_str1 COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
    @MAXROW(),INT((screen->width-LEN(m_str2)+NUMAT("~",m_str2)*2)/2) SayText m_str2 COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
    m_text:=screen->vd
    n:=MLCOUNT(m_text)
    FOR j:=1 TO n
      @j,1 SayText "~2"+RTRIM(MEMOLINE(m_text,screen->width+10,j)) COLOR (IF(EMPTY(screen->clr),m_clr,screen->clr))
      IF j==screen->high-1
        EXIT
      ENDIF
    NEXT
ENDIF
RETURN i
Function ContBrowse(m_browse)
  LOCAL m_recno :=  RECNO()
  DBSKIP(1)
  DBEVAL( { || NIL },,m_poisk2 )
  IF EOF()
    DBGOTO(m_recno)
    DispError(" ��ப� � ⠪�� ���祭�� �� �������� ")
  ELSE
    m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
  ENDIF
RETURN .T.
Function dosToWin(strSource)
Local strResult
RETURN CHARREPL(DOS_LETTERS,strSource,WINDOWS_LETTERS,.t.)

Function winToDos(strSource)
Local strResult
RETURN CHARREPL(WINDOWS_LETTERS,strSource,DOS_LETTERS,.t.)

