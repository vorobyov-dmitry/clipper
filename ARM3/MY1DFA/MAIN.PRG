#include "new.ch"
 #include "pass.ch"
//#include "setcurs.ch"
Memvar a_menu,m_workpath,m_syspath
FUNCTION BegInit (var1,var2)
LOCAL m_time:=TIME(),m_env,getlist:={},m_path,m_x,m_name,;
      m_var:=IF(var1==NIL,"",alltrim(var1)),s1:=LOWER(EXENAME()),;
      m_var1:=IF(var2==NIL,"",alltrim(var2))

   SetCancel ( .f. )
   SetCursor (0)
   SetBlink(.f.)

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET EPOCH TO 1960
   READEXIT(.t.)

   SET CENTURY       OFF

   SET DATE format "DD.MM.YYYY"

   CLEAR SCREEN
   PUBLIC   p_help_code  := 0                     // ��ࠬ��� ��� ��࠭���� HELP
   PUBLIC   txt_clr      := 'bg+/b,n/bg'          // �᭮���� 梥� ᨬ�����
   PUBLIC   msg_clr      := 'gr+/r'               // 梥� ᮮ�饭�� �� �訡���
   PUBLIC   msg_mig_clr  := 'gr+*/r'              // 梥� ᮮ�饭��
                                                  // �� �訡��� � ���栭���
   PUBLIC   msg1_clr     := 'w+*/bg'              // 梥� ᮮ�饭�� � ���栭���
   PUBLIC   box_clr      := 'w/b'                 // 梥� ࠬ�� � �.�.
   PUBLIC   hlp_clr      := 'n/w,gr+/w'           // 梥� �ࠢ�� ( help'� )
   PUBLIC   psw_clr      := 'w+/bg,n/n'           // 梥� ��஫�
   PUBLIC   hello_clr    := 'gr+/b'               // 梥� ���筮�� �ਢ���⢨�
   PUBLIC   head_clr     := 'r+/b'                // 梥� ��砫쭮� ���⠢��
   PUBLIC   dos_clr      := SetColor ()           // 梥� MS-DOS
   PUBLIC   str_clr      := 'w+/n'                // 梥�
   PUBLIC   mnu_clr      := 'w+/b,n/w'            // 梥� ����
           PUBLIC   ten_clr      := 'w/n'                 // 梥� ⥭�
   PUBLIC   phn_clr      := 'n/w'                 // 梥� 䮭�
   PUBLIC   vvod_clr     := 'w+/b,gr+/n,,,w+/b'   // 梥� ��࠭� �����-�뢮��
   PUBLIC   vvod_mig_clr := 'w+*/b,gr+/n,,,w+/b'  // 梥� ��࠭� �����-�뢮��
                                                  // � ���栭���
   PUBLIC   hello1_clr   := 'w+/bg,w+/n'          // 梥� �� ����� ����
   PUBLIC   poisk_clr    := 'gr+/bg'              // 梥� 蠯�� ���� �����
                                                  // �� ���᪥ � ���室�
   PUBLIC   hl_clr       := 'n/w,gr+/n'           // 梥� �뤥������� �㭪�

   PUBLIC   m_dbspath   := ''              // ��⠫�� � ⥪�饩 ��
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // ��⠫�� � ���୮� ��
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_shapka    := 'd:\buhgal\nf\'  // ��⠫�� ��� 蠯�� ��設��ࠬ�
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // ��⠫�� ��� ��設��ࠬ�
   PUBLIC   m_struct    := 'd:\buhgal\st\'  // ��⠫�� � ����묨 ������ࠬ�
                                           // 䠩���
   PUBLIC   m_syspath   := 'd:\buhgal\system\'  // ��⠫�� �  ��⥬��� ���ଠ樥�
   PUBLIC   m_vdisk     := 'd:\buhgal\vd\'  // �����஭�� ��� !!!!!!!!!!!!!!!
   PUBLIC   m_virtvdisk := 'd:\buhgal\vd\'  // �ᥢ�������஭�� ���
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // ��⠫�� ��� �����

   IF .NOT.EMPTY(m_var1)
      IF .NOT.IsDigit(m_var1)
        IF RIGHT(m_var1,1)<>"\"
           m_mainpath  := m_var1+SUBSTR(m_mainpath  ,2)
           m_sprpath   := m_var1+SUBSTR(m_sprpath   ,2)
           m_exepath   := m_var1+SUBSTR(m_exepath   ,2)
           m_shapka    := m_var1+SUBSTR(m_shapka    ,2)
           m_struct    := m_var1+SUBSTR(m_struct    ,2)
           m_syspath   := m_var1+SUBSTR(m_syspath   ,2)
           m_bufpath   := m_var1+SUBSTR(m_bufpath   ,2)
           m_mash      := m_var1+SUBSTR(m_mash      ,2)
           m_vdisk     := m_var1+SUBSTR(m_vdisk     ,2)
           m_virtvdisk := m_var1+SUBSTR(m_virtvdisk ,2)
           m_copypath  := m_var1+SUBSTR(m_copypath  ,2)
           m_temppath  := m_var1+SUBSTR(m_temppath  ,2)
           m_uchpath   := m_var1+SUBSTR(m_uchpath  ,2)
        ELSE
          m_bufpath   := m_var1+'bf\'
          m_mainpath  := m_var1+'mn\'
          m_sprpath   := m_var1+'sp\'
          m_exepath   := m_var1+'bh\'
          m_shapka    := m_var1+'nf\'
          m_mash      := m_var1+'ms\'
          m_struct    := m_var1+'st\'
          m_syspath   := m_var1+'system\'
          m_vdisk     := m_var1+'vd\'
          m_virtvdisk := m_var1+'vd\'
          m_copypath  := m_var1+'cp\'
          m_temppath  := m_var1+'temp\'
          m_uchpath   :=m_var1+'1_2\'
        ENDIF
      ELSE
        IF FILE("INIT.DBF")
          USE init NEW Readonly
          IF VAL(m_var1)>=1.AND.VAL(m_var1)<=LASTREC()
            DBGOTO(VAL(m_var1))
              m_bufpath   := ALLTRIM(init->bf)
              m_mainpath  := ALLTRIM(init->mn)
              m_sprpath   := ALLTRIM(init->sp)
              m_exepath   := ALLTRIM(init->bh)
              m_shapka    := ALLTRIM(init->nf)
              m_mash      := ALLTRIM(init->ms)
              m_struct    := ALLTRIM(init->st)
              m_syspath   := ALLTRIM(init->js)
              m_vdisk     := ALLTRIM(init->vd)
              m_virtvdisk := ALLTRIM(init->vd)
              m_copypath  := ALLTRIM(init->cp)
              m_temppath  := ALLTRIM(init->tp)
              m_uchpath   := ALLTRIM(init->uch)
          ENDIF
          CLOSE init
    ENDIF
endif
  ELSEIF m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
 m_dbspath   := ''              // ��⠫�� � ⥪�饩 ��
 m_bufpath   :=s1+SUBSTR(m_bufpath    ,  11)  // ��⠫�� � ���୮� ��
 m_mainpath  :=s1+SUBSTR(m_mainpath   ,  11)  // ��⠫�� � �᭮���� ��
 m_sprpath   :=s1+SUBSTR(m_sprpath    ,  11)  // ��⠫�� � �ࠢ�筨����
 m_exepath   :=s1+SUBSTR(m_exepath    ,  11)  // ��⠫�� ��� .EXE ����� �����
 m_shapka    :=s1+SUBSTR(m_shapka     ,  11)  // ��⠫�� ��� 蠯�� ��設��ࠬ�
 m_mash      :=s1+SUBSTR(m_mash       ,  11)  // ��⠫�� ��� ��設��ࠬ�
 m_struct    :=s1+SUBSTR(m_struct     ,  11)  // ��⠫�� � ����묨 ������ࠬ�
 m_syspath   :=s1+SUBSTR(m_syspath    ,  11)  // ��⠫�� �  ��⥬��� ���ଠ樥�
 m_vdisk     :=s1+SUBSTR(m_vdisk      ,  11)  // �����஭�� ��� !!!!!!!!!!!!!!!
 m_virtvdisk :=s1+SUBSTR(m_virtvdisk  ,  11)  // �ᥢ�������஭�� ���
 m_copypath  :=s1+SUBSTR(m_copypath   ,  11)  // ��⠫�� ��� �����

 ENDIF




   PUBLIC   l_sov

   USE (m_syspath+"sovhoz") NEW
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- ������������ �।�����
   l_sov:= sovhoz->sov
   USE

   USE (m_syspath+"printer") NEW
   PUBLIC m_printer := printer->printer         // --- ⨯ �ਭ��:
   PUBLIC m_endpage :=IF(ASCAN(printer->(DBSTRUCT()),{|P|UPPER(p[1])=='ENDPAGE'})<>0,PRINTER->ENDPAGE,64) // --- ࠧ��� ��࠭���
   USE                                          //     0 - CPF
                                                //     1 - Geniprint
                                                //     2 - Hyundai

   PUBLIC a_menu:={}
KSETCAPS(.f.)
KSETNUM(.t.)
CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","�")
CLEAREOL(0,0,"n/w")
CLEAREOL(MAXROW(),0,"n/w")
@0,0 SayDisp DMY(DATE())+" "+NTOCDOW(DOW(DATE())) COLOR "n/w"
@0,Col()+2 SayText '��� ��壠��� "~2�~3�~4�~5�~1" - ~6���㢠��� �ନ N 1 - ��'  COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
 @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
@MAXROW(),Col()+2 SayText "����i� �~2 1.00 ~1�i� ~212/04/04" COLOR "N/w,R/w"
//   CLEARWIN(0,0,MAXROW(),MAXCOL(),'N/W','�')
   SET KEY K_F10 TO Calcul
   SET KEY K_ALT_F10 TO Calc
   PUBLIC    M_WORKPATH := m_var
keyboard ''
USE (m_workpath+"menu") INDEX (m_workpath+"menu") ALIAS menu NEW
KEYBOARD ""
// m_syspath+="\"
// InitParPrn()
// m_syspath:=SUBSTR(m_syspath,1,LEN(m_syspath)-1)
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY
dialog("���㢠��� �ନ N 1 - ��")
Finish()
close all
RETURN .t.
FUNCTION  Finish
         SET COLOR TO DOS_CLR
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
#DEFINE M_COLZERO  1  &&   �⮫��� ��ࢮ�� ����
#DEFINE M_ROWZERO  1  &&   ��ப� ��ࢮ�� ����
#DEFINE M_COLSTEP  2  &&   ������� ���� �� ��ਧ��⠫�
#DEFINE M_ROWSTEP  1  &&   ������� ���� �� ���⨪���
#DEFINE M_WIDTH    65 &&   ��ਭ� ����
#DEFINE M_HIGH     12 &&   ���� ����
#DEFINE M_COLFIRST M_COLZERO+LEN(A_MENU)*M_COLSTEP && �⮫��� ���孥�� ������ 㣫� ����
#DEFINE M_ROWFIRST M_ROWZERO+LEN(A_MENU)*M_ROWSTEP && ��ப�  ���孥�� ������ 㣫� ����
#DEFINE M_COLLAST   M_COLFIRST+M_WIDTH && �⮫��� ������� �ࠢ��� 㣫� ����
#DEFINE M_ROWLAST   M_ROWFIRST+M_HIGH && ��ப� ������� �ࠢ��� 㣫�
FUNCTION dialog(var1)
  local obj_error,m_set,old_err
  local l_while:=.t.
  private m_proc && �ᯮ������ ��� ���ய���⠭���� ����� ��楤���
  private m_menu_name:=var1 && �ᯮ������ ��� �ନ஢���� ������������ ����
  old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
//  initarmerror()
  KEYBOARD ""
  DO WHILE l_while
   BEGIN SEQUENCE
      MENU ('001')
      l_while:=.f.
   RECOVER USING obj_error
      QUIT
   END SEQUENCE
  ENDDO
RETURN .t.

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+2)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 ���i�"},; && ���祭� �㭪⮢ ����
          a_prc:={},;            && ���祭� ��뢠���� ��楤��
          a_par:={}              && ��ࠬ���� ��楤��
    local m_key:=0
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
    SHADOW(M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST)
    SET COLOR TO  ( HEAD_CLR )
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',M_WIDTH -5)
    MENU->(DBseek(m_choice))
    SET COLOR TO ( MNU_CLR )
    menu->(DBEVAL ({||AADD(A_CHOICE, CHR(LEN(a_choice)+IF(LEN(a_choice)>9,55,48))+;
                    " "+MENU->PUNKTNAME),AADD(A_prc, ALLTRIM(MENU->PRC));
             ,AADD(A_par, ALLTRIM(MENU->PAR))},,{||m_choice ==MENU->NUMMENU}))
    DO WHILE .T.
        m_key :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,, m_key,)
      IF M_KEY==1.OR. m_key==0
         RESTSCREEN(M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+2,m_screen)
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
         ScreenFile(m_workpath+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_workpath+"screen.scr")
         ENDIF
        ELSE
          Disperror("�ணࠬ� �� �i����祭�")
        ENDIF
        SET PRINTER TO
        SET COLOR TO ( MNU_CLR )
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.

Function View01()
  @4,1,23,79  BOX B_DOUBLE_SINGLE+SPACE(1) COLOR (VVOD_CLR)
        MEMOEDIT(MEMOREAD(m_workpath+"01.txt"),5,2,22,78)
RETURN .T.
Function Zapdf1()
  LOCAL m_path1

        IF ANSWERu("���� 䠩� � ������ 1��;� �� �� - ��i�?")==YES
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_path1:=ALLTRIM(RESTVAR1("m_path1","DR"))
  CLOSE myvar
         IF FILE(m_path1+"1dfdata.dbf")
          USE (m_path1+"1dfdata.dbf") NEW  ALIAS fl8
          ZAP
          CLOSE Fl8
          ELSE
          DispError("�� �������� 䠩��  ;["+m_path1+"1dfdata.dbf];  � �������;��� 1-��")
          ENDIF
        ENDIF


RETURN .T.


Function SetVar()
  LOCAL m_rr,m_cc,m_kod,GetList:={},m_kod1,;
  m_id1,m_fam1,m_tel1,;
  m_pilg1,m_pilg2,m_pilg3,m_kopu1,m_kopu2,;
  m_id2,m_fam2,m_tel2,m_name,m_name1,m_year,;
  n_win,m_path1,s_sumpod,s_sumn
  n_win:=WOPEN(01,08,22,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "���i����� i��ଠ�i�" COLOR "n/w"
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_name:=PADR(RESTVAR1("m_name","DR"),50)
  m_name1:=PADR(RESTVAR1("m_name1","DR"),50)
  m_rr:=PADR(RESTVAR1("m_rr","DR"),2)
  m_cc:=PADR(RESTVAR1("m_cc","DR"),2)
  m_kod:=PADR(RESTVAR1("m_kod","DR"),10)
  m_kod1:=PADR(RESTVAR1("m_kod1","DR"),10)
  m_id1:=PADR(RESTVAR1("m_id1","DR"),10)
  m_fam1:=PADR(RESTVAR1("m_fam1","DR"),30)
  m_tel1:=PADR(RESTVAR1("m_tel1","DR"),10)
  m_id2:=PADR(RESTVAR1("m_id2","DR"),10)
  m_fam2:=PADR(RESTVAR1("m_fam2","DR"),30)
  m_tel2:=PADR(RESTVAR1("m_tel2","DR"),10)
  m_year:=PADR(RESTVAR1("m_year","DR"),4)
//  m_kopu1:=PADR(RESTVAR1("m_kopu1","DR"),60)
//  m_kopu2:=PADR(RESTVAR1("m_kopu2","DR"),60)
  m_pilg1:=RESTVAR1("m_pilg1","DR")
  m_pilg2:=RESTVAR1("m_pilg2","DR")
  m_pilg3:=RESTVAR1("m_pilg3","DR")
//  m_kopu3:=PADR(RESTVAR1("m_kopu3","DR"),60)
//  m_kopu4:=PADR(RESTVAR1("m_kopu4","DR"),60)
//  m_kopu5:=PADR(RESTVAR1("m_kopu5","DR"),60)
  m_path1:=PADR(RESTVAR1("m_path1","DR"),60)
    s_sumpod:=PADR(RESTVAR1("s_sumpod","DR"),4)
    s_sumn:=PADR(RESTVAR1("s_sumn","DR"),4)
  SET ESCAPE ON
  SET CURSOR ON
  @02,2 SayDisp "����� �ਤi筮� �ᮡ�>" COLOR "n/bg"
  @03,2 SayDisp "��� 򄐏�� �ਤi筮� �ᮡ�>" COLOR "n/bg"
  @04,2 SayDisp "��� ������i" COLOR "n/bg"
  @05,2 SayDisp "��� ���" COLOR "n/bg"
  @06,2 SayDisp "����� ���" COLOR "n/bg"
  @07,2 SayDisp "��� 򄐏�� ���" COLOR "n/bg"
  @08,2 SayDisp "���i���� �i�����⢠ " COLOR "n/bg"
  @09,2 SayDisp "���                       �.I.�.              ⥫�䮭 " COLOR "n/bg"
  @11,2 SayDisp "�������� ��壠���    " COLOR "n/bg"
  @12,2 SayDisp "���                       �.I.�.              ⥫�䮭 " COLOR "n/bg"
  @14,2 SayDisp "�i� " COLOR "n/bg"
//  @15,2 SayDisp "���� ����㢠�� �� ���. ��� " COLOR "n/bg"
//  @16,2 SayDisp "���� ����㢠�� �� ����. ��� " COLOR "n/bg"
  @17,2 SayDisp "�i�죠 100% (61.5) " COLOR "n/bg"
  @18,2 SayDisp "�i�죠 150%        " COLOR "n/bg"
  @19,2 SayDisp "�i�죠 200%        " COLOR "n/bg"
  @20,2 SayDisp "��४��� 1 �� " COLOR "n/bg"

  @02,29 GET m_name PICTURE "@s34" COLOR "w/b,GR+/N"
  @03,29 GET m_kod COLOR "w/b,GR+/N"
  @04,29 GET m_rr COLOR "w/b,GR+/N"
  @05,29 GET m_cc COLOR "w/b,GR+/N"
  @06,29 GET m_name1 PICTURE "@s34" COLOR "w/b,GR+/N"
  @07,29 GET m_kod1 COLOR "w/b,GR+/N"
  @10,2 GET m_id1 COLOR "w/b,GR+/N"
  @10,15 GET m_fam1 COLOR "w/b,GR+/N"
  @10,47 GET m_tel1 COLOR "w/b,GR+/N"
  @13,2 GET m_id2 COLOR "w/b,GR+/N"
  @13,15 GET m_fam2 COLOR "w/b,GR+/N"
  @13,47 GET m_tel2 COLOR "w/b,GR+/N"
  @14,15 GET m_year COLOR "w/b,GR+/N"
  @14,15 GET m_year COLOR "w/b,GR+/N"
//  @16,36 GET m_kopu2 PICTURE "@s20" COLOR "w/b,GR+/N"
  @17,36 GET m_pilg1 PICTURE "999.99" COLOR "w/b,GR+/N"
  @18,36 GET m_pilg2 PICTURE "999.99" COLOR "w/b,GR+/N"
  @19,36 GET m_pilg3 PICTURE "999.99" COLOR "w/b,GR+/N"
  @20,36 GET m_path1 PICTURE "@s20" COLOR "w/b,GR+/N"
  @20,36 GET s_sumpod PICTURE "999999.99" COLOR "w/b,GR+/N"
  @20,36 GET s_sumn PICTURE "9999999.99" COLOR "w/b,GR+/N"

  READ
  IF LASTKEY()<>K_ESC
    SAVEVAR1("m_name",m_name,"DR")
    SAVEVAR1("m_name1",m_name1,"DR")
    SAVEVAR1("m_rr",m_rr,"DR")
    SAVEVAR1("m_cc",m_cc,"DR")
    SAVEVAR1("m_kod",m_kod,"DR")
    SAVEVAR1("m_kod1",m_kod1,"DR")
    SAVEVAR1("m_id1", m_id1,"DR")
    SAVEVAR1("m_fam1",m_fam1,"DR")
    SAVEVAR1("m_tel1",m_tel1,"DR")
    SAVEVAR1("m_id2", m_id2,"DR")
    SAVEVAR1("m_fam2",m_fam2,"DR")
    SAVEVAR1("m_tel2",m_tel2,"DR")
    SAVEVAR1("m_year",m_year,"DR")
//    SAVEVAR1("m_kopu1",m_kopu1,"DR")
//    SAVEVAR1("m_kopu2",m_kopu2,"DR")
    SAVEVAR1("m_pilg1",m_pilg1,"DR")
    SAVEVAR1("m_pilg2",m_pilg2,"DR")
    SAVEVAR1("m_pilg3",m_pilg3,"DR")
    SAVEVAR1("m_path1",m_path1,"DR")
    SAVEVAR1("s_sumn",s_sumn,"DR")
    SAVEVAR1("s_sumpod",s_sumpod,"DR")
  ENDIF
  CLOSE myvar
  WCLOSE(n_win)
  WSELECT(0)
RETURN .t.
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
