#include "New.ch"
#include "menu.ch"
#define BUF_SIZE 4096
#define FIRST_ROW 1
#define LAST_ROW (MAXROW()-1)
#define FIRST_COL 0
#define LAST_COL  MAXCOL()
#define END_PAGE  "<<<<<   �I���� ����I���   >>>>>"
#define END_FILE  "<<<<< �I���� �����������  >>>>>"
#define ROW1 (FIRST_ROW+n_len_shapka+1)
#define ROWL (LAST_ROW-1)
#define COL1 (FIRST_COL+1)
#define COLL (LAST_COL-2)
#define COUNT1 (ROWL-ROW1+1)
#DEFINE N_PRINTER 1
#DEFINE N_PAPER 2
#DEFINE N_ZAG 3
#DEFINE N_SYMBOL 4
#DEFINE N_LINES 5
#DEFINE N_INIT_PRINTER  6
#define m_key n_file
#translate FGOTOP(<var>)     =>   FSEEK(<var>,0)
#translate FGOBOTTOM(<var>)  =>   FSEEK(<var>,0,2)
#translate LEFT(<str>,<n>)  =>   SUBSTR(<str>,1,<n>)
#translate EXTRACT(<str>,<n1>,<n2>) => SUBSTR(<str>,<n1>,<n2>-<n1>+1)
MEMVAR m_mash,m_syspath
Function ViewMsh(var)
  LOCAL m_str,;// ��ப� ���뢠���
        n,;    // ������⢮ ��⠭��� ����
        m_mtx:="",;
        m_file,;
        s_shapka2,;
        m_page,;
        n_file,;
        m_filesize,;
        a_str:={},;
        m_month:=0,m_month1:=1,;
        m_data,;
        m_time,;
        m_margin,;
        n_len_shapka,;
        n_page:=GetEndPage(),;
        l_shapka:=.t.,a_shapka:={},;
        n_row:=1,n_col:=1,;
        m_max_row,m_max_col:=0,;
        i,j,l,k,GetList:={},n1,n2,k1
LOCAL    path_mash := m_mash,k0
LOCAL m_screen,m_col1,m_inkey,l_delete:=.f.,m_poisk1:="",m_poisk2:={||(0)}
   DCL MENU
   ADD MENU NAME "��ப�" ITEMS ;
{"���� �� ���� ��ப�  "+CHR(25) ,;
"����� �� ���� ��ப�  "+CHR(24),;
"�� ����㯭� ���i���  Page Down" ,;
"�� ����।�� ���i��� Page Up" ,;
"�� ����� ���i���     Ctrl+Page Up" ,;
"�� ��⠭�� ���i���    Ctrl+Page Down" ,;
"��३� �� ���i���      F7"} KEY {K_DOWN,K_UP,K_PGDN,K_PGUP,K_CTRL_PGUP,K_CTRL_PGDN,K_F7}
   ADD MENU NAME "�⮢��i" ITEMS ;
{"��ࠢ� �� ���� ᨬ���               "+CHR(26),;
"��i�� �� ���� ᨬ���                "+CHR(27),;
"��ࠢ� �� �i���                     End" ,;
"��i��  �� �i���                     Home" ,;
"��ࠢ� �� 10 ᨬ���i�               Ctrl+"+CHR(26),;
"��i�� �� 10 ᨬ���i�                Ctrl+"+CHR(27)} KEY;
{K_RIGHT,K_LEFT,K_END,K_HOME,K_CTRL_RIGHT,K_CTRL_LEFT}
ADD MENU NAME "���" ITEMS ;
{"���              Ctrl+P  ",;
"��� �१ �㫥�  F2      ",;
"��� � 䠩�        Shift+F2",;
"����ன�� ����    F9    ",;
"����ன�� �ਭ�� Ctrl+U"} KEY {K_CTRL_P,K_F2,K_SH_F2,K_F9,K_CTRL_U}
 USE( m_syspath + "msh"  )   INDEX( m_syspath + "msh" )   NEW
    IF( ! DBSEEK(PADL(ALLTRIM(var),3)))
       DispError( "��設��ࠬ� N "+var+" �i����� � 䠩�i �����")
       CLOSE msh
      RETURN .f.
    END
// m_margin:=FIELDGET(5);m_month:=FIELDGET(7);l_shapka:=FIELDGET(4)
m_margin:=msh->p005;m_month:=msh->p007;l_shapka:=msh->p004
CLOSE msh
var:=RIGHT("00"+ALLTRIM(var),2)
IF l_shapka
  IF Screen->(DS("SH0"+var))
    m_str:=screen->vd
    n:=MLCOUNT(m_str,254)
    FOR i:=1 TO n
      AADD(a_shapka,SPACE(m_margin)+RTRIM(MEMOLINE(m_str,254,i)))
    NEXT
  ELSE
    DispError("�i����� 蠯�� ��設��ࠬ� N"+var)
    l_shapka:=.f.
  ENDIF
ENDIF
n_len_shapka:=LEN(a_shapka)
m_max_col:=IF(l_shapka,LEN(a_shapka[n_len_shapka]),0)
m_filesize:=FILESIZE(path_mash+var+".txt")
IF m_filesize=-1
  Disperror("��設��ࠬ� N "+var+" �i�����")
  RETURN .f.
ELSE
  IF m_filesize==0
    Disperror("��設��ࠬ� N "+var+" ��� ��쮢�� ஧�i�")
  RETURN .f.
  ENDIF
ENDIF
m_file:=FOPEN(path_mash+var+".txt")
IF m_file==-1
  Disperror("�訡�� ������ 䠩�� "+path_mash+var+".txt")
  RETURN .f.
ENDIF
FormPage(n_page,m_file,@m_mtx,n_len_shapka,m_filesize,@m_month,@m_month1,var)
SET COLOR TO 'W/B'
@FIRST_ROW,FIRST_COL,LAST_ROW,LAST_COL BOX B_DOUBLE+" "
@LAST_ROW+1,0 SayDisp PADC("F8 - ����",LAST_COL+1) COLOR "n/w"
@FIRST_ROW,FIRST_COL+10 SayDisp "��設��ࠬ� N "+var+" �� "+UPPER(NTOCMONTH(VAL(m_month1)))+" - "+UPPER(NTOCMONTH(VAL(m_month)))+" �i����"
@FIRST_ROW,LAST_COL-30 SayDisp "C��i���   "
@FIRST_ROW,LAST_COL-10 SayDisp "��쮣� "+STR(LEN(m_mtx)/4-1,4)
n_col:=1
n_row:=1
n:=1
m_str:=""
//m_max_col-=COLL-COL1-10
s_shapka2:=DTOC(DATE());
+PADC("��設��ࠬ� N "+var+" �� "+UPPER(NTOCMONTH(VAL(m_month1)))+" - ";
+UPPER(NTOCMONTH(VAL(m_month)))+" �i����",m_max_col-19)+"C��. N"
MyGetPage(a_str,@m_mtx,m_file,1,m_margin,m_max_col)
IF m_max_col<=0
  FOR i:=1 TO LEN(a_str)
    IF m_max_col<LEN(a_str[i])
      m_max_col:=LEN(a_str[i])
    ENDIF
  NEXT
ENDIF

INIT MENU
DO WHILE .t.
//  @FIRST_ROW+n_len_shapka+1,FIRST_COL+1 CLEAR TO LAST_ROW-1,LAST_COL-1
  m_max_row:=MAX(LEN(a_str)-ROWL+ROW1,1)
  DISPBEGIN()
  @FIRST_ROW,LAST_COL-20 SayDisp STR(n,4) COLOR "w+/b"
  @FIRST_ROW+1,FIRST_COL+1 CLEAR TO ROWL,COLL+1
  // ���i� 蠯��
  i:=1;AEVAL(a_shapka,{|x|SetPos(FIRST_ROW+i,FIRST_COL+1),DispOut(SUBSTR(x,n_col,LAST_COL-FIRST_COL-1),"w+/b"),i++})
  // ���i� ��設���.
  i:=1;AEVAL(a_str,{|x|SetPos(ROW1+i-1,COL1),DispText(SUBSTR(x,n_col,COLL-COL1+2),IF(i+n_row-1<>LEN(a_str),"w/b,b/w","w/r")),i++},n_row,COUNT1)
  DISPEND()
  m_key:=INKEY(0)
  Deal Menu
  DO CASE
    CASE m_key==K_F6
      m_screen  := SAVESCREEN(10,5,14,77)
      @10,5,14,77 BOX B_DOUBLE+" " COLOR "n/bg"
      @11,8 SayDisp PADC( '����i�� ���祭�� ��ப� �����',66 ) COLOR  "b/bg"
      @12,8 GET m_poisk1 COLOR  "GR+/N,GR+/n"
      m_poisk1:=PADR(m_poisk1,60)
      SET ESCAPE ON
      READ
      m_poisk1:=ALLTRIM(m_poisk1)
      m_poisk2:={|y,z|k0:=AT(y,z)}
      RESTSCREEN(10,5,14,77,m_screen )
      IF LASTKEY()!=K_ESC
        j:=ASCAN(a_str,{|x|k0:=EVAL(m_poisk2,m_poisk1,x),IF(k0==0,.f.,.t.)},n_row,len(a_str)-1)
        IF j==0
          IF ANSWERu("��ப� "+m_poisk1+" �� ��������;�த���㢠� ���� �� ����㯭�� ���i����?")==YES
           FOR k1:=n+1 TO LEN(m_mtx)/4-1
             m_screen:=DispMessage("���� ���i��� N"+STR(k1,3))
             MyGetPage(a_str,@m_mtx,m_file,k1,m_margin,m_max_col)
             j:=ASCAN(a_str,{|x|k0:=EVAL(m_poisk2,m_poisk1,x),IF(k0==0,.f.,.t.)},n_row,len(a_str)-1)
             DelMessage(m_screen)
             IF j<>0
              n:=k1
              EXIT
             ENDIF
           NEXT
           IF j==0
             MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
             DispError("��ப� "+m_poisk1+" �� ��������")
           ENDIF
          ENDIF
        ENDIF
        IF j<>0
          n_row:=j
          a_str[j]:=SUBSTR(a_str[j],1,k0-1)+"~2"+SUBSTR(a_str[j],k0,LEN(m_poisk1))+"~1"+SUBSTR(a_str[j],k0+LEN(m_poisk1))
          IF k0>COLL-COL1-LEN(m_poisk1)-5
            n_col:=MIN(m_max_col-(COLL-COL1)+10,MAX(k0-20,1))
          ENDIF
        ENDIF
      ENDIF
    CASE m_key==K_ALT_F6
      m_screen  := SAVESCREEN(10,5,14,77)
      @10,5,14,77 BOX B_DOUBLE+" " COLOR "n/bg"
      @11,8 SayDisp PADC( '����i�� ���祭�� ��ப� ����� �� �ࠧ��',66 ) COLOR  "w+/bg"
      @12,8 GET m_poisk1 COLOR  "GR+/N,GR+/n"
      m_poisk1:=PADR(m_poisk1,60)
      SET ESCAPE ON
      READ
      m_poisk1:=UPPER(ALLTRIM(m_poisk1))
      m_poisk2:={|y,z|k0:=AT(y,UPPER(z))}
      RESTSCREEN(10,5,14,77,m_screen )
      IF LASTKEY()!=K_ESC
        j:=ASCAN(a_str,{|x|k0:=EVAL(m_poisk2,m_poisk1,x),IF(k0==0,.f.,.t.)},n_row,len(a_str)-1)
        IF j==0
          IF ANSWERu("��ப� "+m_poisk1+" �� ��������;�த���㢠� ���� �� ����㯭�� ���i����?")==YES
           FOR k1:=n+1 TO LEN(m_mtx)/4-1
             m_screen:=DispMessage("���� ���i��� N"+STR(k1,3))
             MyGetPage(a_str,@m_mtx,m_file,k1,m_margin,m_max_col)
             j:=ASCAN(a_str,{|x|k0:=EVAL(m_poisk2,m_poisk1,x),IF(k0==0,.f.,.t.)},n_row,len(a_str)-1)
             DelMessage(m_screen)
             IF j<>0
              n:=k1
              EXIT
             ENDIF
           NEXT
           IF j==0
             MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
             DispError("��ப� "+m_poisk1+" �� ��������")
           ENDIF
          ENDIF
        ENDIF
        IF j<>0
          n_row:=j
          a_str[j]:=SUBSTR(a_str[j],1,k0-1)+"~2"+SUBSTR(a_str[j],k0,LEN(m_poisk1))+"~1"+SUBSTR(a_str[j],k0+LEN(m_poisk1))
          IF k0>COLL-COL1-LEN(m_poisk1)-5
            n_col:=MIN(m_max_col-(COLL-COL1)+10,MAX(k0-20,1))
          ENDIF
        ENDIF
      ENDIF
    CASE m_key==K_CTRL_F6
        j:=ASCAN(a_str,{|x|k0:=EVAL(m_poisk2,m_poisk1,x),IF(k0==0,.f.,.t.)},n_row+1,len(a_str)-1)
        IF j==0
           FOR k1:=n+1 TO LEN(m_mtx)/4-1
             m_screen:=DispMessage("���� ���i��� N"+STR(k1,3))
             MyGetPage(a_str,@m_mtx,m_file,k1,m_margin,m_max_col)
             j:=ASCAN(a_str,{|x|k0:=EVAL(m_poisk2,m_poisk1,x),IF(k0==0,.f.,.t.)},n_row,len(a_str)-1)
             DelMessage(m_screen)
             IF j<>0
              n:=k1
              EXIT
             ENDIF
           NEXT
           IF j==0
             MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
             DispError("��ப� "+m_poisk1+" �� ��������")
           ENDIF
        ENDIF
        IF j<>0
          n_row:=j
          a_str[j]:=SUBSTR(a_str[j],1,k0-1)+"~2"+SUBSTR(a_str[j],k0,LEN(m_poisk1))+"~1"+SUBSTR(a_str[j],k0+LEN(m_poisk1))
          IF k0>COLL-COL1-LEN(m_poisk1)-5
            n_col:=MIN(m_max_col-(COLL-COL1)+10,MAX(k0-20,1))
          ENDIF
        ENDIF
    CASE m_key==K_UP
      n_row:=MAX(1,--n_row)
    CASE m_key==K_DOWN
      n_row:=MIN(LEN(a_str)-1,++n_row)
  CASE m_key==K_PGUP
      n:=MAX(1,--n)
      MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
      n_row:=1
    CASE m_key==K_PGDN
      n_row:=1
      n:=MIN(LEN(m_mtx)/4-1,++n)
      MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
    CASE m_key==K_CTRL_PGUP
      n:=1
      MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
      n_row:=1
    CASE m_key==K_F10
      Calcul()
    CASE m_key==K_ALT_F10
      Calc()
    CASE m_key==K_CTRL_PGDN
      n_row:=1
      n:=LEN(m_mtx)/4-1
      MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
    CASE m_key==K_RIGHT
      n_col:=MIN(m_max_col-(COLL-COL1)+10,++n_col)
    CASE m_key==K_LEFT
      n_col:=MAX(1,--n_col)
    CASE m_key==K_CTRL_RIGHT
      n_col:=MIN(m_max_col-(COLL-COL1)+10,n_col+10)
    CASE m_key==K_CTRL_LEFT
      n_col:=MAX(1,n_col-10)
    CASE m_key==K_HOME
      n_col:=1
    CASE m_key==K_END
      n_col:=m_max_col-(COLL-COL1)+10
    CASE m_key==K_F7
      m_screen:=SAVESCREEN(INT(MAXROW()/2)-1,INT((MAXCOL()-30)/2),INT(MAXROW()/2)-1+2,INT((MAXCOL()-30)/2)+30)
      @INT(MAXROW()/2)-1,INT((MAXCOL()-30)/2),INT(MAXROW()/2)-1+2,INT((MAXCOL()-30)/2)+30  BOX B_DOUBLE+" " COLOR "W+/BG"
      @INT(MAXROW()/2)-1+1,INT((MAXCOL()-30)/2)+2 SAYDISP "����i�� ����� ���i���>" COLOR "GR+/bg"
      @ROW(),COL() GET n PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n>0.AND.n<=(LEN(m_mtx)/4-1)
      READ
      RESTSCREEN(m_screen,INT(MAXROW()/2)-1,INT((MAXCOL()-30)/2),INT(MAXROW()/2)-1+3,INT((MAXCOL()-30)/2)+30)
      n_row:=1
      MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
    CASE m_key==K_CTRL_P.OR.(m_key==K_F2.AND..NOT.(SPOOLACTIV().AND.SPOOLCOUNT()<=3))
      IF GetNumPage(@n1,@n2,(LEN(m_mtx)/4-1))
      PrintMs(m_mtx,m_file,a_str,a_shapka,s_shapka2,n1,n2,m_max_col)
      ENDIF
    CASE m_key==K_SH_F2
      IF GetNumPage(@n1,@n2,(LEN(m_mtx)/4-1))
        PrintFl(m_mtx,m_file,a_str,a_shapka,s_shapka2,n1,n2,m_max_col,path_mash+ var +".prn")
      ENDIF
    CASE m_key==K_F2
      IF GetNumPage(@n1,@n2,(LEN(m_mtx)/4-1))
        IF PrintFl(m_mtx,m_file,a_str,a_shapka,s_shapka2,n1,n2,m_max_col,path_mash+  var +".prn")
           SPOOLADD(path_mash+ var +".prn")
        ENDIF
      ENDIF
    CASE m_key == K_CTRL_U
            LSetprint()
    CASE m_key == K_F9
            SetLpechat()
            IF (n_page<>GetEndPage())
              n_page:=GetEndPage()
              FormPage(n_page,m_file,@m_mtx,n_len_shapka,m_filesize)
              n:=1
              MyGetPage(a_str,@m_mtx,m_file,n,m_margin,m_max_col)
              n_row:=1
              n_col:=1
            ENDIF
  CASE m_key==K_ESC
    EXIT
  ENDCASE
ENDDO
FCLOSE(m_file)
//SET PRINTER TO
//SET PRINTER OFF
RETURN .t.

Function MyGetPage(a_str,m_mtx,m_file,n_page,m_margin,m_max_col)
  LOCAL m_first:=BIN2L(SUBSTR(m_mtx,4*(n_page-1)+1,4)),;
        m_last:=BIN2L(SUBSTR(m_mtx,4*(n_page)+1,4))-1
  LOCAL m_str:=SPACE(m_last-m_first+1),n_line:=1,n_pos:=0,n,i
  FSEEK(m_file,m_first)
  n:=FREAD(m_file,@m_str,LEN(m_str))
  IF n<>LEN(m_str)
    DispError("�� ����i��� ��⠭� ���i���  ��設��ࠬ�")
    m_str:=LEFT(m_str,n)
  ENDIF
  IF SUBSTR(m_str,n-1,2)<>END_LINE
    m_str+=END_LINE
  ENDIF
  IF SUBSTR(m_str,n-2,3)="$"+END_LINE
    m_str:=SUBSTR(m_str,1,n-3)
  ENDIF
  ASIZE(a_str,0)
  n_line:=1
  n_pos:=0
  DO WHILE (i:=ATNUM(END_LINE,m_str,1,n_pos))<>0
      AADD(a_str,"")
      a_str[n_line++]:=EXTRACT(m_str,n_pos+1,i-3)
      n_pos:=i+1
  ENDDO
  IF n_page==ROUND(LEN(m_mtx)/4-1,0)
    IF RIGHT(a_str[n_line-1],2)=="ZZ"
      ADEL(a_str,n_line);ASIZE(a_str,LEN(a_str)-1)
    ENDIF
  ENDIF
  AADD(a_str,IF(n_page<>LEN(m_mtx)/4-1,SPACE(m_margin)+PADR(END_PAGE,m_max_col),SPACE(m_margin)+PADR(END_FILE,m_max_col)))
  RETURN .t.
  Function PrintMs(m_mtx,m_file,a_str,a_shapka,s_shapka2,n_first,n_last,m_max_col)
    LOCAL n1:=IF(n_first==NIL,1,n_first),;
          n2:=IF(n_last==NIL,LEN(m_mtx)/4-1,n_last),;
          m_str,m_first,m_last,;
          s_shapka1:="",;
          i,n
    IF OpenPrn().AND.SetWidthPrn(m_max_col)
      AEVAL(a_shapka,{|x|s_shapka1+=IF(GetParPrn(N_SYMBOL)==2,CHARREPL("ڳ������ٴ�",x+END_LINE,"-||-|----||"),x+END_LINE)},3)
      FOR i:=n1 TO n2
        DispMessage("���i� ���i��� "+STR(i,4)+";�� �ਭ��","w+/bg,n/bg")
        m_first:=BIN2L(SUBSTR(m_mtx,4*(i-1)+1,4))
        m_last:=BIN2L(SUBSTR(m_mtx,4*i+1,4))-1
        m_str:=SPACE(m_last-m_first+1)
        FSEEK(m_file,m_first)
        n:=FREAD(m_file,@m_str,LEN(m_str))
        IF n<>LEN(m_str)
    DispError("�� ����i��� ��⠭� ���i���  ��設��ࠬ�")
          m_str:=LEFT(m_str,n)
        ENDIF
        IF SUBSTR(m_str,n-1,2)<>END_LINE
          m_str+=END_LINE
        ENDIF
        IF SUBSTR(m_str,n-2,3)="$"+END_LINE
          m_str:=SUBSTR(m_str,1,n-3)
        ENDIF
        IF GetparPrn(N_PAPER)==2 //�����
           WaitMessage("���ࠢ� ���� N "+STR(i,3)+";� ���᭨�� ��� �� ����i��")
        ENDIF
        IF LASTKEY()==K_ESC
          IF ANSWERu("�४��� ���?")==YES
            ClosePrn()
            RETURN .f.
          ENDIF
        ENDIF

        SendToPrint(s_shapka2+STR(i,3)+END_LINE+;
        IF(GetparPrn(N_ZAG)==1.OR.(GetparPrn(N_ZAG)==2.AND.i==1),s_shapka1,"");
        +m_str+;
        IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)))
      NEXT
      ClosePrn()
    ENDIF
    RETURN .t.
Function PrintFl(m_mtx,m_file,a_str,a_shapka,s_shapka2,n_first,n_last,m_max_col,m_name)
    LOCAL n1:=IF(n_first==NIL,1,n_first),;
          n2:=IF(n_last==NIL,LEN(m_mtx)/4-1,n_last),;
          m_str,m_first,m_last,;
          s_shapka1:="",;
          i,n
    IF OpenPrn(m_name).AND.SetWidthPrn(m_max_col)
      AEVAL(a_shapka,{|x|s_shapka1+=IF(GetParPrn(N_SYMBOL)==2,CHARREPL("ڳ������ٴ�",x+END_LINE,"-||-|----||"),x+END_LINE)},3)
      FOR i:=n1 TO n2
        DispMessage("���i� ���i��� "+STR(i,4)+";�� ���")
        m_first:=BIN2L(SUBSTR(m_mtx,4*(i-1)+1,4))
        m_last:=BIN2L(SUBSTR(m_mtx,4*i+1,4))-1
        m_str:=SPACE(m_last-m_first+1)
        FSEEK(m_file,m_first)
        n:=FREAD(m_file,@m_str,LEN(m_str))
        IF n<>LEN(m_str)
          DispError("�� ����i��� ��⠭� ���i���  ��設��ࠬ�")
          m_str:=LEFT(m_str,n)
        ENDIF
        IF SUBSTR(m_str,n-1,2)<>END_LINE
          m_str+=END_LINE
        ENDIF
        IF SUBSTR(m_str,n-2,3)="$"+END_LINE
          m_str:=SUBSTR(m_str,1,n-3)
        ENDIF
        IF LASTKEY()==K_ESC
          IF ANSWERu("�४��� ���?")==YES
            ClosePrn()
            RETURN .f.
          ENDIF
        ENDIF
        DevOUT(s_shapka2+STR(i,3)+END_LINE+;
        IF(GetparPrn(N_ZAG)==1.OR.(GetparPrn(N_ZAG)==2.AND.i==1),s_shapka1,"");
        +m_str+;
        IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)))
      NEXT
      ClosePrn()
    ENDIF
    RETURN .t.
STATIC Function GetNumPage(n1,n2,m_max)
      LOCAL m_screen,GetList:={}
      SET ESCAPE ON
      m_screen:=SAVESCREEN(INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+30)
      @INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50  BOX B_DOUBLE+" " COLOR "W+/BG"
      @INT(MAXROW()/2)-2+1,INT((MAXCOL()-50)/2)+2 SAYDISP "����i�� ����� ���⪮��� ���i���>" COLOR "GR+/bg"
      @INT(MAXROW()/2)-2+2,INT((MAXCOL()-50)/2)+2 SAYDISP "����i�� ����� �i�楢��  ���i���>" COLOR "GR+/bg"
      n1:=1
      n2:=m_max
      @INT(MAXROW()/2)-2+1,INT((MAXCOL()-50)/2)+2+35 GET n1 PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n1>0.AND.n1<=m_max
      @INT(MAXROW()/2)-2+2,INT((MAXCOL()-50)/2)+2+35 GET n2 PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n2>=n1.AND.n2<=m_max
      READ
      SET ESCAPE OFF
      RESTSCREEN(m_screen,INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+30)
      IF LASTKEY()==K_ESC
        RETURN .f.
      ENDIF
RETURN .t.
STATIC Function FormPage(n_page,m_file,m_mtx,n_len_shapka,m_filesize,m_month,m_month1,var)
LOCAL m_ostatok,n_file,n,l,m_str,m_proc,j,n_line,m_str2,n_pos,i,k0:=m_filesize
  FGOTOP(m_file)
  m_mtx:=""
  m_ostatok:=""
  n_line:=n_len_shapka
  n_file:=0
  m_proc := InitGauge("���i� 䠩�� �� ���i���",2)
  DO WHILE .T.
    m_str:=SPACE(BUF_SIZE)
    n:=FREAD(m_file,@m_str,BUF_SIZE)
    m_proc:=DispGauge(m_proc,(n_file+n)/m_filesize)
    l:=LEN(m_ostatok)
    IF n<>BUF_SIZE
      IF SUBSTR(m_str,n,1)="$"
        n--
      ENDIF
      IF SUBSTR(m_str,n-1,2)<>END_LINE
        IF SUBSTR(m_str,n-1,2)=="ZZ"
          IF m_month<>NIL
            m_month:=SUBSTR(m_str,n-23,2)
            m_month1:=SUBSTR(m_str,n-21,2)
          ENDIF
          m_str:=m_ostatok+LEFT(m_str,n-24)
          k0-=24
        ELSE
          IF m_month<>NIL
            NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh") NEW
           msh->(DS(STR(VAL(var),3)))
            m_month:=msh->p007
            m_month1:="01"
            CLOSE msh
          ENDIF
          m_str:=m_ostatok+LEFT(m_str,n)+END_LINE
        ENDIF
      ELSE
        m_str:=m_ostatok+LEFT(m_str,n)
        IF m_month<>NIL
            NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh") NEW
           msh->(DS(STR(VAL(var),3)))
            m_month:=msh->p007
            m_month1:="01"
            CLOSE msh
        ENDIF
      ENDIF
    ELSE
      j:=ATNUM(END_LINE,m_str)
      IF j==0
        DispError("������� !!!!! ������� ��ப� �i��� ������� ����")
        FCLOSE(m_file)
        BREAK
      ENDIF
      m_str2:=SUBSTR(m_str,j+2)
      m_str:=m_ostatok+LEFT(m_str,j+1)
      m_ostatok:=m_str2
    ENDIF
    n_pos:=0
    DO WHILE (i:=ATNUM(END_LINE,m_str,1,n_pos))<>0
      n_line++
      IF n_line==n_page.OR.SUBSTR(m_str,n_pos+1,1)=="$"
        m_mtx+=L2BIN(n_file+i-l+1)
        n_line:=n_len_shapka
      ENDIF
      n_pos:=i+1
    ENDDO
    n_file+=n
    IF n<>BUF_SIZE
      EXIT
    ENDIF
  ENDDO
  // �������� �����祭�
  DelGauge(m_proc)
  m_mtx:=L2BIN(0)+m_mtx+L2BIN(k0)
  @FIRST_ROW,LAST_COL-10 SayDisp "��쮣� "+STR(LEN(m_mtx)/4-1,4) COLOR "w/b"
RETURN .t.
