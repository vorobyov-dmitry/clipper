#include "new.ch"
#include "MENU.ch"
#include "pass.ch"
// #include  "error.ch"
#  DEFINE   MNU_CLR      "w+/b,n/w"            // 梥� ����

// #define   NAME_FILE_ERR  "errors.arm"

#DEFINE M_COLFIRST 1+LEN(A_MENU)*2  && �⮫��� ���孥�� ������ 㣫� ����
#DEFINE M_ROWFIRST 1+LEN(A_MENU)*1 && ��ப�  ���孥�� ������ 㣫� ����
#DEFINE M_COLLAST   M_COLFIRST+55 && �⮫��� ������� �ࠢ��� 㣫� ����
#DEFINE M_ROWLAST   M_ROWFIRST+12 && ��ப� ������� �ࠢ��� 㣫�

MEMVAR m_tabn,m_oper,m_level,m_syspath,m_workpath,a_menu,m_imja,m_sprpath,m_proc,m_copypath,p_npr
MEMVAR m_vdisk,m_bufpath,m_mainpath,m_mash,m_struct,m_exepath,m_shapka,m_temppath
MEMVAR m_virtdisk,m_menu_name,m_kassapath,m_menu,m_computer
Function Main(var1)
LOCAL m_time:=TIME(),m_pol,getlist:={},m_parol,m_str:=""

LOCAL s_files:={}

IF numfiles()<100
  DispError("�i��i��� ���ਯ��i� 䠩�i� ���� 100;���ࠢ� CONFIG.SYS")
  QUIT
ENDIF
KSETCAPS(.f.)
KSETNUM(.t.)
SETBLINK(.F.)
SETSHARE(4)
Beginit (var1)
vhod()
IF m_tabn=="****".AND.m_oper=="**"
      m_imja := '���i�i�����'
      m_pol  := '�� '
ELSE
      NET USE (m_sprpath+"SP10") INDEX (m_sprpath+"SP10") READONLY
      sp10->(DBSEEK(m_tabn))
      IF .NOT. sp10->(Found ())
         DispErr("�����쭨� ����� "+m_tabn+";�i����i� � �ࠢ�筨�� ���i����i�")
         m_imja = "����������"
         m_pol = '�� '
      ELSE
      m_imja = Alltrim ( SP10 -> IMJA ) + ' ' + Alltrim ( SP10 -> OTCH )
      IF  UPPER(SP10->POL)=='�'
            m_pol = '�� '
          ELSE
            m_pol = '�  '
      ENDIF
      ENDIF
      CLOSE sp10
ENDIF
wboard(0,0,maxrow(),maxcol())
wmode(.t.,.t.,.t.,.t.)
SET KEY K_F10 TO Calcul
SET KEY K_ALT_F10 TO Calc
InitParPrn()
NET USE (m_workpath+"FVNUM") NEW
// Check01()
NET USE (m_workpath+m_menu) INDEX (m_workpath+m_menu) ALIAS menu NEW READONLY
NET USE (m_vdisk+"DBROWSE") INDEX (m_vdisk+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_vdisk+"DBRTB") INDEX (m_vdisk+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_vdisk+"SPVIEW") INDEX (m_vdisk+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_vdisk+"Screen") INDEX (m_vdisk+"Screen")     NEW READONLY
NET USE (m_vdisk+"tbget") INDEX (m_vdisk+"tbget")       NEW READONLY
NET USE (m_workpath+"kaptka1") INDEX (m_workpath+"kaptka1"),(m_workpath+"kaptka1a"),(m_workpath+"kaptka1b") ALIAS kaptka1 NEW
SopenFiles("100",@s_files)
NET USE (m_workpath+"PRED01") NEW
NET USE (m_workpath+"FIRM01") INDEX (m_workpath+"FIRM01"),(m_workpath+"FIRM01A") NEW
NET USE (m_workpath+"BANK01") INDEX (m_workpath+"BANK01") NEW
NET USE (m_workpath+"nalog1") INDEX (m_workpath+"nalog1"),(m_workpath+"nalog1a") NEW ALIAS nalog1
NET USE (m_workpath+"nalog2") INDEX (m_workpath+"nalog2") NEW ALIAS nalog2
NET USE (m_workpath+"spr01") INDEX (m_workpath+"spr01")   NEW ALIAS spr01
NET USE (m_workpath+"nakl1") INDEX (m_workpath+"nakl1"),(m_workpath+"nakl1a")   NEW ALIAS nakl1
NET USE (m_workpath+"nakl2") INDEX (m_workpath+"nakl2")   NEW ALIAS nakl2
nakl1->(DBSETRELATION("nakl2",{||nakl1->vnum},"nakl1->vnum"))
NET USE (m_workpath+"nakl3") INDEX (m_workpath+"nakl3")     NEW ALIAS nakl3
// NET USE (m_syspath+"tbsay") INDEX (m_syspath+"tbsay")       NEW READONLY
//InitBrowse()
InitEdizm();InitDov();InitSal();InitForm()
   m_time:=VAL(LEFT(TIME(),2))
   DO CASE
    CASE m_time>=5.AND.m_time<=12
      m_str:="���ண� ࠭��, "
    CASE m_time>=13.AND.m_time<=16
      m_str:="���਩ ����, "
    CASE m_time>=16.AND.m_time<=23
      m_str:="���਩ ���i�, "
    OTHERWISE
      m_str:="�i�� ���, "
  ENDCASE
  WaitMessage(m_str+'������' + m_pol + m_imja + ',;'+'��� "��壠���" �i�� ��� !',"bg+/bg,W+/BG")
  DO dialog
// SET KEY K_ESC TO Finish
Finish()
RETURN .t.
FUNCTION  Finish
         SET COLOR TO "w/b"
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
PROCEDURE dialog
  local obj_error,m_set,old_err
  local l_while:=.t.,i,j,k,a_prc:={},m_screen,m_key,s_files:={}
  Local a_hor_menu:={},a_num_menu:={},a_ver_menu:={},;
  menu_hor_width,s_letter:="",menu_col1,n_menu:=1,;
  menu_clr:="n/w,b/w,n/bg,w/b,n/w,w+/bg"
  private m_proc && �ᯮ������ ��� ���ய���⠭���� ����� ��楤���
  private m_menu_name:='������� ���� ' && �ᯮ������ ��� �ନ஢���� ������������ ����
  m_set:=CSetAll()
   menu->(DS("001"))
    menu->(DBEVAL ({||AADD(a_hor_menu,ALLTRIM(MENU->PUNKTNAME)),AADD(A_prc, ALLTRIM(MENU->PRC))},;
    ,{||"001"==MENU->NUMMENU}))
    ASIZE(a_ver_menu,LEN(a_hor_menu))
    FOR i:=1 TO LEN(a_prc)
      menu->(DS(a_prc[i]))
      a_ver_menu[i]:={}
      menu->(DBEVAL({||AADD(a_ver_menu[i],{ALLTRIM(menu->punktname),ALLTRIM(menu->prc),ALLTRIM(menu->par)})},;
     ,{||a_prc[i]==menu->nummenu}))
    NEXT

DO WHILE l_while
   old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
//      CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","�")
      DispWall()
      CLEAREOL(0,0,"n/g")
      CLEAREOL(MAXROW(),0,"n/g")
      @0,0 SayDisp My_Dtos(DATE())+" "+My_CDOW(DATE()) COLOR "n/g"
      @0,Col()+2 SayText '��� ��壠��� "~2�~3�~4�~5�~1" - ~6���i� ���ਠ�i�' COLOR "b/g,rb/g,gr+/g,r/g,g+/g,b+/g"
      @MAXROW(),0 SayDisp crypt(ITP,PASSWORD1) COLOR "b/g"
      @MAXROW(),Col()+1 SayText "��०��� ����i� N~22.0 ~1�i� ~220/10/97" COLOR "N/g,R/g"
    menu_hor_width:=INT(MAXCOL()/LEN(a_hor_menu));ASIZE(a_num_menu,LEN(a_hor_menu))
    AFILL(a_num_menu,1);n_menu:=1;CLEAREOL(1,0,USL_CLR)
    FOR i:=1 TO LEN(a_hor_menu);j:=AT("~",a_hor_menu[i]);IF j==0;a_hor_menu[i]:="~"+a_hor_menu[i]
    s_letter+=MyUPPER(SUBSTR(a_hor_menu[i],2,1));ELSE;s_letter+=MyUPPER(SUBSTR(a_hor_menu[i],j+1,1));END
    a_hor_menu[i]:=PADC(a_hor_menu[i],menu_hor_width);@1,(i-1)*menu_hor_width SayMenu a_hor_menu[i] COLOR (USL_CLR+","+SEL_CLR)
    j:=LEN(ALLTRIM(a_ver_menu[i][1][1]));ASCAN(a_ver_menu[i],{|x|IF(LEN(ALLTRIM(x[1]))>j,j:=LEN(ALLTRIM(x[1])),0)})
    FOR k:=1 TO LEN(a_ver_menu[i]);a_ver_menu[i][k][1]:=PADR(ALLTRIM(a_ver_menu[i][k][1]),j);NEXT;NEXT
   BEGIN SEQUENCE
//      MENU ('001')
      j:=1
      DO WHILE j==1
        @1,(n_menu-1)*menu_hor_width SayMenu a_hor_menu[n_menu] COLOR (SEL_H+","+SEL_H1)
        i:=LEN(a_ver_menu[n_menu][1][1])+3
        menu_col1:=MIN((n_menu-1)*menu_hor_width,MAXCOL()-i-4)
        m_screen:=SAVESCREEN (2,menu_col1 ,LEN(a_ver_menu[n_menu])+4,menu_col1+i+4)
        @2,menu_col1 ,LEN(a_ver_menu[n_menu])+3,menu_col1+i+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( "n/bg" )
        SHADOW( 2,menu_col1 ,LEN(a_ver_menu[n_menu])+3,menu_col1+i+2)
        FOR i:=1 TO LEN(a_ver_menu[n_menu])
          @2+i,menu_col1+1 SayDisp STR(i,1)+' '+a_ver_menu[n_menu][i][1] COLOR (IF(a_num_menu[n_menu]==i,"gr+/b","n/bg"))
        NEXT
        DO WHILE .t.
          i:=INKEY(0)
          DO CASE
            CASE i==K_ESC
              IF ANSWERu("������� �ணࠬ�?")==YES
                j:=0;m_key:=0;EXIT
              ENDIF
            CASE i==K_PGDN
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=LEN(a_ver_menu[n_menu])
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_PGUP
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_DOWN.AND.a_num_menu[n_menu]<LEN(a_ver_menu[n_menu])
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=a_num_menu[n_menu]+1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_UP.AND.a_num_menu[n_menu]>1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=a_num_menu[n_menu]-1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_RIGHT
              j:=1
              i:=IF(n_menu==LEN(a_hor_menu),1,n_menu+1)
              EXIT
            CASE i==K_LEFT
              j:=1
              i:=IF(n_menu==1,LEN(a_hor_menu),n_menu-1)
              EXIT
            CASE i>=ASC("1").AND.i<=ASC("0")+LEN(a_ver_menu[n_menu])
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=i-ASC("0")
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_ENTER
//                WaitMessage("��뢠�� ��楤��� "+a_ver_menu[n_menu][a_num_menu[n_menu]][2]+";� ��ࠬ��஬ "+a_ver_menu[n_menu][a_num_menu[n_menu]][3])
               @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
                MyChoice(10,10,a_ver_menu[n_menu][a_num_menu[n_menu]][2],a_ver_menu[n_menu][a_num_menu[n_menu]][3],a_ver_menu[n_menu][a_num_menu[n_menu]][1])
               @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
//                menu->(DS())
            CASE i==K_F10;calcul()
            CASE i==K_ALT_F10;calc()
            CASE (j:=AT(MyUpper(CHR(i)),s_letter))<>0
              i:=j;j:=1;EXIT
          ENDCASE
        ENDDO
        RESTSCREEN (2,menu_col1 ,LEN(a_ver_menu[n_menu])+4,menu_col1+LEN(a_ver_menu[n_menu][1][1])+3+4,m_screen)
        @1,(n_menu-1)*menu_hor_width SayMenu a_hor_menu[n_menu] COLOR (USL_CLR+","+SEL_CLR)
        IF j==1
          n_menu:=i
        ENDIF
      ENDDO
      l_while:=.f.
   RECOVER USING obj_error
      DBCOMMITALL()
      CLOSE ALL
      WAclose()
      CSetAll(m_set)
      SET PRINTER TO
      SET DEVICE TO SCREEN
      asize(a_menu,0)
   END SEQUENCE
   ERRORBLOCK(old_err)
IF l_while
NET USE (m_workpath+"FVNUM") NEW
NET USE (m_workpath+m_menu) INDEX (m_workpath+m_menu) ALIAS menu NEW READONLY
NET USE (m_vdisk+"DBROWSE") INDEX (m_vdisk+"DBROWSE")  ALIAS SPTABL  NEW READONLY
NET USE (m_vdisk+"DBRTB") INDEX (m_vdisk+"DBRTB")      ALIAS SPTABL1 NEW READONLY
NET USE (m_vdisk+"SPVIEW") INDEX (m_vdisk+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_vdisk+"Screen") INDEX (m_vdisk+"Screen")     NEW READONLY
NET USE (m_vdisk+"tbget") INDEX (m_vdisk+"tbget")       NEW READONLY
NET USE (m_workpath+"kaptka1") INDEX (m_workpath+"kaptka1"),(m_workpath+"kaptka1a"),(m_workpath+"kaptka1a") ALIAS kaptka1 NEW
SopenFiles("100",@s_files)
NET USE (m_workpath+"PRED01") NEW
NET USE (m_workpath+"FIRM01") INDEX (m_workpath+"FIRM01"),(m_workpath+"FIRM01A") NEW
NET USE (m_workpath+"BANK01") INDEX (m_workpath+"BANK01") NEW
NET USE (m_workpath+"nalog1") INDEX (m_workpath+"nalog1")     NEW ALIAS nalog1
NET USE (m_workpath+"nalog2") INDEX (m_workpath+"nalog2")     NEW ALIAS nalog2
NET USE (m_workpath+"spr01") INDEX (m_workpath+"spr01") NEW ALIAS spr01
NET USE (m_workpath+"nakl1") INDEX (m_workpath+"nakl1") NEW ALIAS nakl1
NET USE (m_workpath+"nakl2") INDEX (m_workpath+"nakl2")     NEW ALIAS nakl2
nakl1->(DBSETRELATION("nakl2",{||nakl1->vnum},"nakl1->vnum"))
NET USE (m_workpath+"nakl3") INDEX (m_workpath+"nakl3")     NEW ALIAS nakl2
      m_menu_name:=' ������� ���� '
ENDIF
  ENDDO
RETURN

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+1)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 ���i�"},; && ���祭� �㭪⮢ ����
          a_prc:={},;            && ���祭� ��뢠���� ��楤��
          a_par:={}              && ��ࠬ���� ��楤��
    local m_key:=0,i:=ASC("0")
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("w+/b,gr+/n,,,w+/b")
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',55 -5) COLOR ("r+/b")
    MENU->(DBseek(m_choice))
    SET COLOR TO ( MNU_CLR )
    menu->(DBEVAL ({||i++,AADD(A_CHOICE, CHR(i)+" "+MENU->PUNKTNAME),AADD(A_prc, ALLTRIM(MENU->PRC));
             ,AADD(A_par, ALLTRIM(MENU->PAR))},,{||m_choice ==MENU->NUMMENU}))
    DO WHILE .T.
        m_key :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,, m_key,)
      IF M_KEY==1.OR. m_key==0
         RESTSCREEN(M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+1,m_screen)
         MENU->(DBGOTO(m_recno))
         RETURN .T.
      ENDIF
      AADD(a_menu,a_par[m_key-1])
      m_menu_name:=a_choice[m_key]
      IF Isdigit(A_PRC[m_key-1])
         menu(ALLTRIM(A_PRC[m_key-1]))
      ELSE
         m_proc:=A_PRC[m_key-1]
         IF .NOT.EMPTY(m_proc)
         ScreenFile(m_temppath+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_temppath+"screen.scr")
         ENDIF
        ELSE
          WaitMessage("�ணࠬ� �� �i����祭�","w/r,gr+/r",.t.)
        ENDIF
         SET COLOR TO ( MNU_CLR )
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.


FUNCTION BegInit (m_var)

   LOCAL SwapingSpace := 3,s1:=LOWER(EXENAME()),i // ������⢮ ᢮������� ����࠭�⢠
                                     // �� ��᪥ � ������, ����室���� ���
                                     // ࠡ��� ��� "��壠���"

   // ----------------------------------------------------
   // --- ����H��K� ����������, ����� ��� ���� ������� ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor ( 0 )
   setblink(.f.)
   VGAPALETTE(6,32,32,32)

   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   PUBLIC   m_workpath   := 'd:\buh\plat\'   // ��⠫�� � ⥪�饩 ��
   PUBLIC   m_kassapath   := 'd:\buh\kassa\' // ��⠫�� � ���ᮩ
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // ��⠫�� � ���୮� ��
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_shapka    := 'd:\buhgal\nf\'  // ��⠫�� ��� 蠯�� ��設��ࠬ�
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // ��⠫�� ��� ��設��ࠬ�
   PUBLIC   m_struct    := 'd:\buhgal\st\'  // ��⠫�� � ����묨 ������ࠬ�
                                           // 䠩���
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // ��⠫�� �  ��⥬��� ���ଠ樥�
   PUBLIC   m_vdisk     := 'd:\buhgal\vd\'  // �����஭�� ��� !!!!!!!!!!!!!!!
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // ��⠫�� ��� �����
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // ��⠫�� � ���୮� ��
   PUBLIC   m_menu
   PUBLIC   m_computer

   IF .NOT.EMPTY(m_var)
      USE init NEW READONLY
      IF VAL(m_var)>0.AND.VAL(m_var)<=LASTREC()
        DBGOTO(VAL(m_var))
        m_workpath  :=ALLTRIM(init->nk)
        m_bufpath   :=ALLTRIM(init->bf)
        m_mainpath  :=ALLTRIM(init->mn)
        m_sprpath   :=ALLTRIM(init->sp)
        m_exepath   :=ALLTRIM(init->bh)
        m_shapka    :=ALLTRIM(init->nf)
        m_mash      :=ALLTRIM(init->ms)
        m_struct    :=ALLTRIM(init->st)
        m_syspath   :=ALLTRIM(init->js)
        m_vdisk     :=ALLTRIM(init->vd)
        m_copypath  :=ALLTRIM(init->cp)
        m_temppath  :=ALLTRIM(init->tp)
        m_kassapath :=ALLTRIM(init->kassa)
        m_menu      :=ALLTRIM(init->menu)
      ENDIF
      CLOSE init
   ENDIF
// m_syspath :="i:\"

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- ��� ������ ( ���짮��⥫� )
   PUBLIC m_tabn     := ' '      // --- ⠡���� N ������ ( ���짮��⥫� )

   PUBLIC m_imja  := ' '         // --- ���-����⢮ ���짮��⥫�

   NET USE (m_workpath+"pred01") NEW READONLY
   PUBLIC p_npr := AllTrim ( pred01->short )     // --- ������������ �।�����
   USE

   PUBLIC a_menu:={}

   // �஢�ઠ ������ ᢮������� ����࠭�⢠ �� ��᪥

   IF ( i := DiskSpace () ) <= ( SwapingSpace * 1048576 )
      DispErr('��� ��ଠ�쭮� ࠡ�� ��� �����i��� '+Str ( SwapingSpace, 2 ) + ' ����� ᢮������� �i��� �� ����.'+;
      '���������� �i��� '+ Str ( i / 1048576 , 5 , 2 ) + ' �����. ����� ��⥬� ����������.')
      QUIT
   ENDIF
RETURN .t.
Function vhod()
LOCAL m_str:=space(10),x:=CHR(4)+CHR(248)+CHR(8)+"T"+CHR(6)+"D"+CHR(3)+"��+"
LOCAL a_user:={},i,i1,m_time,m_date:=DATE(),GetList:={},m_file
SET CURSOR OFF
set confirm on
SET CURSOR ON
CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","�")
CLEAREOL(0,0,"n/w")
@0,0 SayDisp DMY(DATE())+" "+CDOW(DATE()) COLOR "n/w"
@0,col()+2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
CLEAREOL(MAXROW()-1,0,"w/b","�")
NET USE (m_vdisk+"fdor") READONLY  NEW
DO WHILE .NOT. fdor->(EOF())
IF CHECKSUM(SUBSTR(fdor->name,5,11))<>BIN2L(SUBSTR(fdor->name,1,4))
      DISPERROR("���i୨� ����� ����� "+STR(fdor->(RECNO()),3)+";���� ����i��� 㤠���")
      fdor->(DBSKIP())
ENDIF
AADD(a_user,{;
CRYPT(SUBSTR(fdor->name,5,4),x),PADR(CRYPT(SUBSTR(fdor->name,10,6),x),6),val(CRYPT(SUBSTR(fdor->name,9,1),x))})
fdor->(DBSKIP())
ENDDO
CLOSE fdor
SET COLOR TO "w/b,w+/b"
i:=0
SET ESCAPE ON
DO WHILE .t.
  i++
  m_str:=SPACE(6)
@MAXROW()-1,25 SayDisp " ����i�� ��� ��஫�>" COLOR "gr+/b"
m_str:=GetSecret(m_str)
IF m_str==DIMA
  m_tabn:=REPLICATE(CHR(42),4);m_oper:=REPLICATE(CHR(42),2);m_level:=0
  EXIT
ENDIF

IF LASTKEY()==K_ESC
  IF ANSWERu("���� i� ��⥬�?")==YES
    QUIT
  ENDIF
ENDIF
IF (i1:=ASCAN(a_user,{|x|x[2]==m_str}))==0
  DispError("��஫� ���i७")
ELSE
  m_oper:=STR(i1+32,2)
  m_tabn :=a_user[i1][1]
  IF POSALPHA(m_tabn)<>0
    DispError("������� � ⠡��쭮�� �����i")
    QUIT
  ENDIF
  m_level:=a_user[i1][3]
  IF POSALPHA(m_level)<>0
    DispError("������� � �ਮ�i��i")
    QUIT
  ENDIF
  EXIT
ENDIF
IF i>=3
  DispError("��i �஡� ���௠��,;�� ����祭�� !!!!")
  quit
ENDIF
ENDDO
SET ESCAPE OFF
  @02,14,06,66 BOX B_DOUBLE+" " color "W/B"
  shadow(02,14,06,66)
  @03,26 SayDisp "�쮣���i "+my_Dtos(m_date)+" "+My_Cdow(m_date) COLOR "w+/b"
  @05,30 SayDisp "���>" COLOR "W+/B"
  @04,30 SayDisp "���> " COLOR "W+/B"
  m_time:=TIME()
  @04,37 GET m_time COLOR "GR+/B,GR+/N" PICTURE "99:99:99"
  @05,37 GET m_date COLOR "GR+/B,GR+/N"
  READ
  SETTIME(m_time)
  SETDATE(m_date)
  m_str:=MEMOREAD(m_exepath+"computer.txt")
  m_computer:=VAL(TOKEN(m_str))
RETURN .t.
Function IndNakl()
  LOCAL m_vnum:=0
IF ANSWER("I�����஢�� ����?")==YES
  DispMessage("I������i� ��� ")
  SAVEPAR()
  USE (m_workpath+"spr03") NEW
  INDEX ON spr03->mnt+spr03->kod+spr03->mol+Spr03->ozn TO (m_workpath+"spr03")
  INDEX ON spr03->mnt+spr03->mol+spr03->kod+Spr03->ozn TO (m_workpath+"spr03a")
  CLOSE spr03
  SELECT nakl1
  SET INDEX TO
  DBGOTOP()
  DO WHILE .NOT.EOF()
    IF EMPTY(nakl1->ndoc).AND.EMPTY(nakl1->vdoc)
      IF Nakl1->(NetRlock())
        nakl1->(DBDELETE())
        nakl1->(dbUnlock())
      ENDIF
    ENDIF
    DBSKIP()
  ENDDO
  INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"nakl1")
  INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"nakl1a")
  SET INDEX TO
  SET INDEX TO (m_workpath+"nakl1"),(m_workpath+"nakl1a")
  SELECT nakl2
  SET INDEX TO
  INDEX ON field->vnum TO (m_workpath+"nakl2")
  SELECT nakl3
  SET INDEX TO
  INDEX ON field->vnum TO (m_workpath+"nakl3")
  SELECT kaptka1
  SET INDEX TO
  INDEX ON field->kod TO (m_workpath+"kaptka1")
  INDEX ON UPPER(field->name) TO (m_workpath+"kaptka1a")
  INDEX ON JustRight(field->kod) TO (m_workpath+"kaptka1b")
  SET INDEX TO
  SET INDEX TO (m_workpath+"kaptka1"),(m_workpath+"kaptka1a")
  SELECT spr01
  SET INDEX TO
  INDEX ON field->kopr TO (m_workpath+"spr01")
  SELECT firm01
  SET INDEX TO
  INDEX ON UPPER(field->short) TO (m_workpath+"firm01")
  INDEX ON field->okpo TO (m_workpath+"firm01a")
  SET INDEX TO
  SET INDEX TO (m_workpath+"firm01"),(m_workpath+"firm01a")
  SELECT nalog1
  SET INDEX TO
  DBGOTOP()
  m_vnum:=0
  DO WHILE .NOT.EOF()
    IF EMPTY(nalog1->ndoc).AND.EMPTY(nalog1->vdoc)
      IF Nalog1->(NetRlock())
        nalog1->(DBDELETE())
        nalog1->(dbUnlock())
      ENDIF
    ENDIF
    DBSKIP()
  ENDDO
  DBSKIP(-1)
  INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"nalog1")
  INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"nalog1a")
//  INDEX ON field->ndoc TO (m_workpath+"nalog1")
//  INDEX ON field->vnum TO (m_workpath+"nalog1a")
  SET INDEX TO
  SET INDEX TO (m_workpath+"nalog1"),(m_workpath+"nalog1a")
  SELECT nalog2
  SET INDEX TO
  INDEX ON field->vnum TO (m_workpath+"nalog2")
  SELECT 0
  NET USE (m_workpath+"scht1")
  INDEX ON  DTOS(field->ddoc)+field->ndoc  TO (m_workpath+"scht1")
  INDEX ON  field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"scht1a")
  CLOSE Scht1
  NET USE (m_workpath+"scht2")
  INDEX ON field->vnum TO (m_workpath+"scht2")
  CLOSE Scht2
  SAVEPAR(1)
ENDIF
RETURN .t.
Function Work02
  LOCAL a_dir:={"kaptka1.dbf","nakl1.dbf","nakl2.dbf","spr01.dbf","firm01.dbf","bank01.dbf"}
  LOCAL i:=0
  IF ANSWER("���i஢�� ���� �����?")==YES
  AEVAL(a_dir,{|x|i++,a_dir[i]:=m_workpath+a_dir[i]})
  IF CopyFl(a_dir,"���� ���������")
    WaitMessage("���i஢���� �����襭� ��i譮")
  ENDIF
  ENDIF
RETURN .t.
STATIC Function MyChoice(x,y,m_choice,m_par,m_name)
local m_screen,i:=0,j:=0,n_menu:=1
local m_recno:= MENU->(RECNO())
local a_choice:={"���i�"},; && ���祭� �㭪⮢ ����
a_prc:={},;            && ���祭� ��뢠���� ��楤��
a_par:={}              && ��ࠬ���� ��楤��
local m_key:=0
  IF Isdigit(m_choice) // ��ନ஢��� ����
    MENU->(DBseek(m_choice))
    menu->(DBEVAL ({||i++,AADD(a_choice, ALLTRIM(menu->punktname)),AADD(a_prc, ALLTRIM(menu->prc));
   ,IF(LEN(a_choice[i+1])>j,j:=LEN(a_choice[i+1]),NIL),AADD(a_par, ALLTRIM(menu->par))},,{||m_choice ==menu->nummenu}))
    i:=1;AEVAL(a_choice,{|x|a_choice[i]:=PADR(a_choice[i],j),i++})
    m_screen:=SAVESCREEN (x,y ,x+LEN(a_choice)+2,y+j+6)
    @x,y,x+LEN(a_choice)+1,y+j+4 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("n/bg")
    @x,y+2 SayDisp ' '+ALLTRIM(m_name)+' ' COLOR "w+/Bg"
    SHADOW(x,y,x+LEN(a_choice)+1,y+j+4 )
    FOR i:=1 TO LEN(a_choice)
      @x+i,y+2 SayDisp STR(i-1,1)+' '+a_choice[i] COLOR (IF(n_menu==i,"gr+/b","n/bg"))
    NEXT
      DO WHILE .t.
        m_key:=INKEY(0)
        DO CASE
          CASE m_key==K_ESC.OR.m_key==ASC("0")
            EXIT
          CASE m_key==K_PGDN
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_PGUP
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_DOWN.AND.n_menu<LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=n_menu+1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_UP.AND.n_menu>1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=n_menu-1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE CHR(m_key)>="0".AND.m_key<=ASC("0")+LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=m_key-ASC("0")+1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_ENTER
              IF n_menu==1
                EXIT
              ENDIF
//              WaitMessage("��뢠�� ��楤��� "+a_prc[n_menu-1]+";� ��ࠬ��஬ "+a_par[n_menu-1])
              MyChoice(x+2,y+4,a_prc[n_menu-1],a_par[n_menu-1],a_choice[n_menu])
          CASE m_key==K_F10;calcul()
          CASE m_key==K_ALT_F10;calc()
        ENDCASE
      ENDDO
      RESTSCREEN(x,y ,x+LEN(a_choice)+2,y+j+6,m_screen)
  ELSE
      m_proc:=m_choice
      IF .NOT.EMPTY(m_proc)
        ScreenFile(m_temppath+"screen.scr")
        AADD(a_menu,m_par)
        IF XTOC(&m_proc(m_par))<>"NORESTORE"
          FileScreen(m_temppath+"screen.scr")
        ENDIF
        ASIZE(a_menu,len(a_menu)-1)
      ELSE
        DispError("�ணࠬ� �� �i����祭�")
      ENDIF
  ENDIF
 RETURN .T.
Function ClearPrn()
  LOCAL i,n:=SPOOLCOUNT(),m_str:="� ��i �� ��� ���室����� 䠩��"
  LOCAL a_choice:={}
  IF n==0
    WaitMessage("��࣠ �㫥� ���� ����")
    RETURN .t.
  ENDIF
  FOR i:=1 TO n
    m_str+=";"+STR(i,2)+" "+SPOOLENTRY(i)
  NEXT
  i:=ALERT(m_str,{"����� ���","������ � �ࣨ 䠩�","���i�"},"n/bg,w/b")
  DO CASE
      CASE i==1
        SPOOLFLUSH()
      CASE i==2
        FOR i:=1 TO n
           AADD(a_choice,STR(i,2)+" "+SPOOLENTRY(i))
        NEXT
        i:=MyMenu("�����i�� 䠩�",a_choice)
        IF i>0
          SPOOLDEL(SUBSTR(a_choice[i],4))
        ENDIF
    ENDCASE
SPOOLACTIVE()
RETURN .t.

#UNDEF   HIGHER
#UNDEF   M_ROWFIRST
#UNDEF   M_COLFIRST
#DEFINE   HIGHER 10
#DEFINE   M_ROWFIRST INT((MAXROW()-m_high)/2)+i
#DEFINE   M_COLFIRST INT((MAXCOL()-m_width)/2)+i
Function MyMenu(m_name,a_choice,m_count,l_clear)
  LOCAL m_WIDTH:=0,m_high,m_screen,m_key,i:=IF(m_count==NIL,0,m_count),;
  l_restore:=IF(l_clear==NIL,.t.,l_clear)
  AADD(a_choice,NIL)
  AINS(a_choice,1)
  a_choice[1]:="���i�"
  AEVAL(a_choice,{|p|IF(LEN(p)>m_width,m_width:=LEN(p),NIL)})
  IF(LEN(m_name)>m_width,m_width:=LEN(m_name),NIL)
  IF(LEN(a_choice)>HIGHER,m_high:=HIGHER,m_high:=LEN(a_choice))
  m_screen:=SAVESCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2)
  @M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1 ;
  BOX B_DOUBLE_SINGLE+SPACE(1) COLOR ("w+/b,gr+/n,,,w+/b")
  @M_ROWFIRST-1,M_COLFIRST SayDisp m_name COLOR ("r+/b")
  SHADOW(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1)
  SETCOLOR("w+/b,n/w")
  m_key:=ACHOICE(M_ROWFIRST,M_COLFIRST,M_ROWFIRST+m_high,M_COLFIRST+m_width,a_choice)
  ADEL(a_choice,1)
  ASIZE(a_choice,LEN(a_choice)-1)
  IF(l_restore,RESTSCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2,m_screen),NIL)
RETURN( IF(m_key==1.OR.m_key==0,0,m_key-1))
#UNDEF   HIGHER
#UNDEF   M_ROWFIRST
#UNDEF   M_COLFIRST
Function DispWall(var)
LOCAL i:=0,j:=0,m_char:=" "
LOCAL m_clr:=IF(var==NIL,"w/b",var)
DispBegin()
FOR i:=1 TO MAXROW()
  FOR j:=0 TO MAXCOL()
    DO CASE
      CASE i==1
        IF j%6==2
          m_char:="�"
        ELSE
          m_char:="�"
        ENDIF
      CASE i==MAXROW()
        IF j%6==2
          m_char:="�"
        ELSE
          m_char:="�"
        ENDIF
      CASE i%2==0
        DO CASE
          CASE j%6==2
            m_char:="�"
          CASE j%6==5
            m_char:="�"
          OTHERWISE
            m_char:="�"
        ENDCASE
      OTHERWISE
        DO CASE
          CASE j%6==2
            m_char:="�"
          CASE j%6==5
            m_char:="�"
          OTHERWISE
            m_char:="�"
        ENDCASE

    ENDCASE
    @i,j SayDisp m_char COLOR (m_clr)
  NEXT
NEXT
DispEnd()
RETURN .t.
FUNCTION DispMs(var)
local m_screen,i:=0,j:=0,n_menu:=1,m_str,n_win
LOCAL x:=4,y:=1,a_dir:=DIRECTORY(m_mash+"????????.dbf")
local m_browse,m_col,m_key,a_choice:={},n,m_row:=1,m_skip
FOR i:=LEN(a_dir) TO 1 STEP -1
  IF TYPE(LEFT(a_dir[i][1],8))<>"N"
    ADEL(a_dir,i)
    ASIZE(a_dir,LEN(a_dir)-1)
  ENDIF
NEXT

n:=LEN(a_dir)
FOR i:=n TO 1 STEP -1
  m_str:=FILESTR(m_mash+a_dir[i][1],184,a_dir[i][2]-184)
  IF RIGHT(m_str,2)=="��"
    AADD(a_choice,{LEFT(m_str,160),SUBSTR(m_str,161,10),SUBSTR(m_str,171,12)})
  ELSE
   ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
  ENDIF
NEXT
IF LEN(a_dir)==0
  DispError("��設��ࠬ �� ��������")
  RETURN .f.
ENDIF
n:=LEN(a_dir)
m_screen:=SAVESCREEN (x,y ,x+20,y+76)
@x,y,x+18,y+74 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("n/bg")
@x,y+2 SayDisp '��५i� ��設��ࠬ' COLOR "w+/Bg"
SHADOW(x,y,x+18,y+74 )
m_browse:=TBrowseNew(x+1,y+1,x+17,y+73)
m_browse:colorspec:='N/BG,B/W,w+/b*'
m_browse:colsep        := '�'
m_browse:skipBlock:={|m_count|;
m_skip:=IF(m_count>=0,;
IF(m_row+m_count>n,n-m_row,m_count),;
IF(m_row+m_count>=1,m_count,-m_row+1)),m_row+=m_skip,m_skip}
m_browse:goBottomBlock := { ||m_row:=n}
m_browse:goTopBlock    := { ||m_row:=1}
m_col:=TBColumnNew()
m_col:block:={||REM01(a_choice[m_row][1])}
m_col:heading:="����� ��設��ࠬ�"
m_Col:colorblock:=  {||{1,2}}
m_Col:headsep    := "��";m_col:colsep:="�"
m_col:width:=70
m_browse:addColumn(m_col)
/*
m_col:=TBColumnNew()
m_col:block:={||a_dir[m_row][3]}
m_col:heading:="��� ;���᫥���"
m_Col:colorblock:=  {||{1,2}}
m_Col:headsep    := "��";m_col:colsep:="�"
m_browse:addColumn(m_col)
m_col:=TBColumnNew()
m_col:block:={||a_dir[m_row][4]}
m_col:heading:=" ��� ;���᫥���"
m_Col:colorblock:=  {||{1,2}}
m_Col:headsep    := "��";m_col:colsep:="�"
m_browse:addColumn(m_col) */
DO WHILE .t.
  IF LEN(a_choice)==0
    EXIT
  ENDIF

STABILIZE BROWSE m_browse
m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{3,3})
m_key:=Inkey(0)
m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
DO CASE
  CASE m_key==K_DEL.AND.ANSWERu("������� ��設��ࠬ�?")==YES
    FERASE(m_mash+a_dir[m_row][1]);FERASE(m_mash+ALLTRIM(a_choice[m_row][3]))
    ADEL(a_dir,m_row);ASIZE(a_dir,LEN(a_dir)-1)
    ADEL(a_choice,m_row);ASIZE(a_choice,LEN(a_choice)-1)
    IF m_row>LEN(a_dir)
      m_row:=LEN(a_dir);m_browse:rowPos:=m_browse:rowPos-1;m_browse:configure()
    ENDIF
    n:=n-1
    IF n==0
      EXIT
    ENDIF
    m_browse:RefreshAll()
  CASE m_key==K_SH_F5.AND.ANSWERu("�i������ ��設��ࠬ� ?")==YES
    RestFl()
  CASE m_key==K_F5.AND.ANSWERu("���i� ��設��ࠬ� ?")==YES
    CopyFl({m_mash+a_dir[m_row][1],m_mash+ALLTRIM(a_choice[m_row][3])},REM01(a_choice[m_row][1]))
  CASE m_key==K_ESC
    EXIT
  CASE m_key==K_UP
    m_browse:up();m_browse:refreshCurrent()
  CASE m_key==K_DOWN
    m_browse:down();m_browse:refreshCurrent()
  CASE m_key==K_ENTER
    USE (m_mash+a_dir[m_row][1]) INDEX (m_mash+a_choice[m_row][3]) ALIAS buf NEW READONLY
    ViewMs(ALLTRIM(a_choice[m_row][2]),a_choice[m_row][1])
    CLOSE buf
  CASE m_key==K_F11.OR.CHR(m_key)=="?".OR.CHR(m_key)=="/"
    n_win:=InitScr("DISPMS")
    i:=AT(";",a_choice[m_row][1])
    IF i<>0
      @2,1 SayText PADC(LEFT(a_choice[m_row][1],i-1),MAXCOL()) COLOR "w+/b,gr+/b"
      @3,1 SayText PADC(SUBSTR(a_choice[m_row][1],i+1),MAXCOL()) COLOR "w+/b,gr+/b"
    ELSE
     @2,1 SayText PADC(a_choice[m_row][1],MAXCOL()+1) COLOR "w/b,gr+/b"
    ENDIF
    @4,18 SayDisp a_dir[m_row][3]  COLOR "w+/b"
    @5,18 SayDisp a_dir[m_row][4]  COLOR "w+/b"
    @6,18 SayDisp a_dir[m_row][2]  COLOR "w+/b"
    @7,18 SayDisp FILESIZE(m_mash+a_choice[m_row][3]) COLOR "w+/b"
    @8,18 SayDisp a_dir[m_row][1] COLOR "w+/b"
    @09,18 SayDisp a_choice[m_row][3]COLOR "w+/b"
    INKEY(0)
    WCLOSE(n_win)
ENDCASE
ENDDO
RESTSCREEN(x,y ,x+20,y+76,m_screen)
RETURN .t.
Function Disp08(var)
local m_screen,i:=0,j:=0,n_menu:=1
local m_recno:= MENU->(RECNO())
local a_choice:={"���i�","��ॣ�� i ���","���㢠�"}
local m_key:=0,x:=18,y:=30
    j:= 40
    i:=1;AEVAL(a_choice,{|x|a_choice[i]:=PADR(a_choice[i],j),i++})
    m_screen:=SAVESCREEN (x,y ,x+LEN(a_choice)+2,x+j+6)
    @x,y,x+LEN(a_choice)+1,y+j+4 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("n/bg")
    @x,y+2 SayDisp ' '+"I������i���i���� ����"+' ' COLOR "w+/Bg"
    SHADOW(x,y,x+LEN(a_choice)+1,y+j+4 )
    FOR i:=1 TO LEN(a_choice)
      @x+i,y+2 SayDisp STR(i-1,1)+' '+a_choice[i] COLOR (IF(n_menu==i,"gr+/b","n/bg"))
    NEXT
      DO WHILE .t.
        m_key:=INKEY(0)
        DO CASE
          CASE m_key==K_ESC.OR.m_key==ASC("0")
            EXIT
          CASE m_key==K_PGDN
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_PGUP
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_DOWN.AND.n_menu<LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=n_menu+1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_UP.AND.n_menu>1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=n_menu-1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE CHR(m_key)>="0".AND.m_key<=ASC("0")+LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=m_key-ASC("0")+1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_ENTER
              DO CASE
                CASE n_menu==1
                  EXIT
                CASE n_menu==2
                  ViewOtch("08")
                CASE n_menu==3
                  Ms08()
              ENDCASE
          CASE m_key==K_F10;calcul()
          CASE m_key==K_ALT_F10;calc()
        ENDCASE
      ENDDO
      RESTSCREEN(x,y ,x+LEN(a_choice)+2,x+j+6,m_screen)
Return .t.
Function DispReg()
  LOCAL i,j:=1,n_win
  SavePar()
  n_win:=InitScr("STAT")
  fvnum->(DBGOTOP())
  DO WHILE .NOT.fvnum->(EOF())
    @2+j*2,2 SayDisp fvnum->name COLOR "w+/gr"
  FOR i:=1 TO 10
    IF IsBit(fvnum->reg,i)
      @2+j*2,25+i*5 SayDisp "�" COLOR "b/gr"
    ENDIF
  NEXT
   fvnum->(DBSKIP())
   j++
  ENDDO
  INKEY(0)
  Wclose(n_win)
  SavePar(1)
RETURN .t.
