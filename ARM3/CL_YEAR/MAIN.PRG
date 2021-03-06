#include "new.ch"
#include "ACHOICE.ch"
#include "pass.ch"
MEMVAR a_menu,m_mainpath,m_level,m_tabn,m_oper
MEMVAR m_sprpath,m_exepath,m_shapka,m_struct,m_syspath,m_bufpath,m_mash
MEMVAR m_vdisk,m_virtvdisk,m_copypath,m_proc,m_menu_name
MEMVAR m_workpath,m_temppath,p_npr,m_dbspath,m_uchpath

Function Main(var1)
LOCAL m_time:=TIME(),getlist:={},m_parol,m_str:=""
LOCAL m_var1:=IF(EMPTY(var1),"",var1),m_imja,m_pol
CLEAR
IF numfiles()<100
  DispError("������⢮ ���ਯ�஢ 䠩��� ����� 100;������� CONFIG.SYS")
  QUIT
ENDIF
KSETCAPS(.f.)
KSETNUM(.t.)
Beginit (m_var1)
wboard(0,0,MAXROW(),MAXCOL())
SET KEY K_F10 TO Calc
InitParPrn()
NET USE (m_workpath+"MENU") INDEX (m_workpath+"MENU") ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY

DO dialog
SET KEY K_ESC TO Finish
Finish()
RETURN .t.
FUNCTION  Finish
         SET COLOR TO &dos_clr
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
#DEFINE M_COLZERO  1  &&   �⮫��� ��ࢮ�� ����
#DEFINE M_ROWZERO  1  &&   ��ப� ��ࢮ�� ����
#DEFINE M_COLSTEP  2  &&   ������� ���� �� ��ਧ��⠫�
#DEFINE M_ROWSTEP  1  &&   ������� ���� �� ���⨪���
#DEFINE M_WIDTH    55 &&   ��ਭ� ����
#DEFINE M_HIGH     12 &&   ���� ����
#DEFINE M_COLFIRST M_COLZERO+LEN(A_MENU)*M_COLSTEP && �⮫��� ���孥�� ������ 㣫� ����
#DEFINE M_ROWFIRST M_ROWZERO+LEN(A_MENU)*M_ROWSTEP && ��ப�  ���孥�� ������ 㣫� ����
#DEFINE M_COLLAST   M_COLFIRST+M_WIDTH && �⮫��� ������� �ࠢ��� 㣫� ����
#DEFINE M_ROWLAST   M_ROWFIRST+M_HIGH && ��ப� ������� �ࠢ��� 㣫�
PROCEDURE dialog
  local obj_error,m_set,old_err,m_str,j
  local l_while:=.t.
  private m_proc && �ᯮ������ ��� ���ய���⠭���� ����� ��楤���
  private m_menu_name:='������� ���� ' && �ᯮ������ ��� �ନ஢���� ������������ ����
   m_set:=CSetAll()

DO WHILE l_while
   old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
   BEGIN SEQUENCE
      CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","�")
      CLEAREOL(0,0,"n/w")
      CLEAREOL(MAXROW(),0,"n/w")
      @0,0 SayDisp DMY(DATE())+" "+CDOW(DATE()) COLOR "n/w"
      @0,Col()+2 SayText '��� ��壠��� "~2�~3�~4�~5�~1" - ~6��७�� ���⪮�' COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
      @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
      @MAXROW(),Col()+2 SayText "����� �~2 002 ~1�� ~210/01/00" COLOR "N/w,R/w"
   m_str:="^�{o�jutg�dj�aam�]i[�AJG�JT��[^QΏQV����������"
FOR j:=1 TO LEN(m_str)
  m_str:=STUFF(m_str,j,1,CHR(ASC(SUBSTR(m_str,j,1))+j+48))
NEXT
   @21,8,23,63 BOX "�ͻ���Ⱥ " COLOR "w+/bg"
   @22,10 Say LEFT(m_str,LEN(m_str)-8)+CHR(49)+CHR(52)+CHR(45)+CHR(52)+CHR(51)+CHR(45)+CHR(56)+CHR(53) COLOR "GR+/bg"
      MENU ('001')
      l_while:=.f.
   RECOVER USING obj_error
      DBCOMMITALL()
      CLOSE ALL
      CSetAll(m_set)
      SET PRINTER TO
      SET DEVICE TO SCREEN
      asize(a_menu,0)
   END SEQUENCE
   ERRORBLOCK(old_err)

NET USE (m_syspath +"DBROWSE")  INDEX  (m_syspath+"DBROWSE")   ALIAS SPTABL  NEW READONLY
NET USE (m_workpath+"MENU")     INDEX (m_workpath+"MENU") ALIAS menu NEW READONLY
NET USE (m_syspath +"DBRTB")    INDEX (m_syspath+"DBRTB")      ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath +"SPVIEW")   INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath +"SCREEN")   INDEX (m_syspath+"SCREEN")     NEW READONLY

      m_menu_name:=' ������� ���� '
  ENDDO
RETURN

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+1)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 ���i�"},; && ���祭� �㭪⮢ ����
          a_prc:={},;            && ���祭� ��뢠���� ��楤��
          a_par:={}              && ��ࠬ���� ��楤��
    local m_key:=0,i:=ASC("0")
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ('w/b,gr+/n,,,n/w')
    SET COLOR TO  ( 'r+/b')
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',M_WIDTH -5)
    MENU->(DBseek(m_choice))
    SET COLOR TO ( 'w+/b,n/w')
    menu->(DBEVAL ({||i++,AADD(A_CHOICE, CHR(i)+" "+MENU->PUNKTNAME),AADD(A_prc, ALLTRIM(MENU->PRC));
             ,AADD(A_par, ALLTRIM(MENU->PAR))},,{||m_choice ==MENU->NUMMENU}))
    DO WHILE .T.
        m_key :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,, m_key,)
      IF M_KEY==1.OR. m_key==AC_ABORT
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
         ScreenFile(m_vdisk+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_vdisk+"screen.scr")
         ENDIF
        ELSE
          DispError("�ணࠬ� �� �i����祭�")
        ENDIF
         SET COLOR TO ( 'w+/b,n/w')
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.


FUNCTION BegInit (m_var1)

   LOCAL SwapingSpace := 3,s1:=LOWER(EXENAME()) // ������⢮ ᢮������� ����࠭�⢠
                                     // �� ��᪥ � ������, ����室���� ���
                                     // ࠡ��� ��� "��壠���"

   // ----------------------------------------------------
   // --- ����H��K� ����������, ����� ��� ���� ������� ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor (0)
   SETBLINK(.f.)

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
   PUBLIC   m_dbspath   := ''              // ��⠫�� � ⥪�饩 ��
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
   PUBLIC   m_virtvdisk := 'd:\buhgal\vd\'  // �ᥢ�������஭�� ���
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // ��⠫�� ��� �����
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // ��⠫�� � ���୮� ��
   PUBLIC   m_workpath  :=""
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
//    INKEY(0)
//    ?"------&&&&&&&&&-------"
//    INKEY(0)
   IF .NOT.EMPTY(m_var1)
//    ?"NOR EMPTY -------------"
//      INKEY(0)
      IF .NOT.IsDigit(m_var1)
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
       m_uchpath   := m_var1+SUBSTR(m_uchpath  ,2)
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
     	      m_uchpath   := ALLTRIM(init->uch)
          ENDIF
         CLOSE init
      ENDIF
    ENDIF
// ENDIF
ELSE
//  ?"*&&&&&*",s1,"*******",m_exepath,m_mainpath
   IF m_exepath<>LEFT(s1,LEN(m_exepath))
//      ?"*------***",m_exepath, LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_shapka    := s1+SUBSTR(m_shapka    ,11)
       m_struct    := s1+SUBSTR(m_struct    ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_mash      := s1+SUBSTR(m_mash      ,11)
       m_copypath  := s1+SUBSTR(m_copypath  ,11)
       m_vdisk     := s1+SUBSTR(m_vdisk     ,11)
       m_virtvdisk := s1+SUBSTR(m_virtvdisk ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
       m_uchpath   := s1+SUBSTR(m_uchpath   ,11)
 ENDIF

 ENDIF
// ?"*******",s1,"*+++++******",m_exepath,m_mainpath
// INKEY(0)
   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- ��� ������ ( ���짮��⥫� )
   PUBLIC m_tabn     := ' '      // --- ⠡���� N ������ ( ���짮��⥫� )


   NET USE (m_syspath+"sovhoz") NEW READONLY
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- ������������ �।�����
   USE

   PUBLIC a_menu:={}
RETURN .T.
#UNDEF HIGHER
#UNDEF M_ROWFIRST
#UNDEF M_COLFIRST

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
Function Copybase()
  LOCAL i,GetList:={},m_year:=YEAR(DATE())-1
  LOCAL a_dir:={},a_dir1:={},m_size:=0,m_path,nCopy,m_gauge,m_root
  SET ESCAPE ON
  @8,11,12,70 BOX B_DOUBLE+" " COLOR "gr+/bg"
@8,13 SayDisp m_mainpath  COLOR "gr+/bg"
  @10,13 SayDisp "����i�� ���祭�� ப�>" COLOR "w+/bg"
  @10,47 Get m_year PICTURE "9999" COLOR "N/BG,GR+/N"
  READ
  IF LASTKEY()==K_ESC;RETURN .F.;ENDIF
  IF ANSWERu("����� ���i� ���� ����� ��  "+STR(m_year,4)+" �i� ?")==YES
    // ������ ��������I�
    // �i���㭮� �i��
/*    m_size:=FILESIZE(m_mainpath+"*.dbf")
    m_size+=FILESIZE(m_bufpath+"*.dbf")
    m_size+=FILESIZE(m_sprpath+"*.dbf")
    m_size+=FILESIZE(m_sprpath+"*.ntx")
    a_dir1:=DIRECTORY(m_mainpath+"*.dbf")
    AEVAL(a_dir1,{|x|m_size+=x[2],AADD(a_dir,{m_mainpath+x[1]})})
    a_dir1:=DIRECTORY(m_bufpath+"*.dbf")
    AEVAL(a_dir1,{|x|m_size+=x[2],AADD(a_dir,{m_bufpath+x[1])})
    a_dir1:=DIRECTORY(m_sprpath+"*.dbf")
    AEVAL(a_dir1,{|x|m_size+=x[2],AADD(a_dir,{m_sprpath+x[1])})
    a_dir1:=DIRECTORY(m_sprpath+"*.NTX")
    AEVAL(a_dir1,{|x|m_size+=x[2],AADD(a_dir,{m_sprpath+x[1])}) */
    m_path:="H:\bars\"+STR(m_year,4)
    DO WHILE .T.
      m_path:=PADR(m_path,50)
      @11,13 SayDisp "����i�� ��४��i�>"  COLOR "w+/bg"
      @11,47 Get m_path PICTURE "@s20"   COLOR "N/BG,GR+"
      READ
      IF LASTKEY()==K_ESC;RETURN .F.;ENDIF
      m_path:=ALLTRIM(m_path)+"\"
      // ��ॢiઠ �����i ��४��i�
      //
//      IF DISKTYPE(LEFT(m_path,2))<>248
//        DispError("���i��� �� 楩 ��� ���������")
//        LOOP
//      ENDIF
      IF DISKFREE(LEFT(m_path,1))<m_size+1500000
        DispError("����i��� "+ALLTRIM(NumToSTR(m_size,18))+" �i�쭮�� �i���")
        LOOP
      ENDIF
      IF MAKEDIR(m_path)
        EXIT
      ENDIF
    ENDDO
  m_root:=LEFT(m_mainpath,LEN(m_mainpath)-4)
  ? "XCOPY "+m_root +"\*.* "+m_path+"*.*  /s/e >t1.lst"
__RUN("XCOPY "+m_root +"\*.* "+m_path+"*.*  /s/e >t1.lst")
   USE (m_exepath+"INIT") NEW
    LOCA FOR init->year==STR(m_year,4)
    IF .NOT.init->(FOUND())
      init->(DBAPPEND())
    ENDIF
    init->bf  := m_path+'bf\'
    init->mn  := m_path+'mn\'
    init->sp  := m_path+'sp\'
    init->bh  := m_path+'bh\'
    init->ms  := m_path+'ms\'
    init->js  := m_path+'system\'
    init->cp  := m_path+'cp\'
    init->tp  := m_path+'temp\'
    init->uch :=m_path+'1_2\'
    init->year:=STR(m_year,4)
    i:=RECNO()
    CLOSE init
  ENDIF

return .t.
Function MakeDir(m_path)
  local a_dir,i,s1
  Local n:=NumAt("\",m_path)
  FOR i:=2 TO n
    s1:=LEFT(m_path,ATNUM("\",m_path,i)-1)
    a_dir:=FILESEEK(s1,16)
    IF EMPTY(a_dir)
      BeepErr()
      IF ANSWERu("��४��i� �i����� "+s1+";�⢮�� ��?")==YES
        IF DIRMAKE(s1)<>0
          Disperror("������� �� �⢮७�i ��४��i�; "+s1 )
          RETURN .f.
        ENDIF
      ENDIF
    ENDIF
  NEXT
  a_dir:=FILESEEK(m_path+"MN",16)
  IF EMPTY(a_dir)
      IF DIRMAKE(m_path+"MN")<>0
        Disperror("������� �� �⢮७�i ��४��i�; "+m_path+"MN" )
        RETURN .f.
      ENDIF
  ENDIF
  a_dir:=FILESEEK(m_path+"BF",16)
  IF EMPTY(a_dir)
      IF DIRMAKE(m_path+"BF")<>0
        Disperror("������� �� �⢮७�i ��४��i�; "+m_path+"BF" )
        RETURN .f.
      ENDIF
  ENDIF
  a_dir:=FILESEEK(m_path+"SP",16)
  IF EMPTY(a_dir)
      IF DIRMAKE(m_path+"SP")<>0
        Disperror("������� �� �⢮७�i ��४��i�; "+m_path+"SP" )
        RETURN .f.
      ENDIF
  ENDIF
  a_dir:=FILESEEK(m_path+"MS",16)
  IF EMPTY(a_dir)
      IF DIRMAKE(m_path+"MS")<>0
        DispError("������� �� �⢮७�i ��४��i�; "+m_path+"MS" )
        RETURN .f.
      ENDIF
  ENDIF
RETURN .T.
Function close1
   LOCAL getlist:={},i,m_path
   LOCAL m_ask :=1,m_gauge,m_message,m_year:=YEAR(DATE())-1
   LOCAL a_file:={;
m_mainpath+"FD1",;
m_mainpath+"FD2",;
m_mainpath+"FLISH",;
m_mainpath+"FNPCH",;
m_mainpath+"FZ1",;
m_mainpath+"FZ1AE",;
m_mainpath+"FZ1AP",;
m_mainpath+"FZ1AT",;
m_mainpath+"FZ1T",;
m_mainpath+"FZ1TP",;
m_mainpath+"FZ2",;
m_mainpath+"FZ2A",;
m_mainpath+"FZ2T",;
m_mainpath+"FZ2TP",;
m_mainpath+"FZ3",;
m_mainpath+"FZN",;
m_bufpath+"FD1",;
m_bufpath+"FD2",;
m_bufpath+"FZ1",;
m_bufpath+"FZ1AE",;
m_bufpath+"FZ1AP",;
m_bufpath+"FZ1AT",;
m_bufpath+"FZ1T",;
m_bufpath+"FZ1TP",;
m_bufpath+"FZ2",;
m_bufpath+"FZ2A",;
m_bufpath+"FZ2T",;
m_bufpath+"FZ2TP",;
m_bufpath+"FZ3"}
   SET ESCAPE ON
  @8,8,14,72 BOX B_DOUBLE+" " COLOR "GR+/bg"
  @8,20 SayDisp "��७�� ����� �� 1-� ��⨭i"  COLOR "w+/bg"
  @10,10 SAYdisp "����i��, �� � �������� ��������  - 1"  COLOR "w+/bg"
  @11,10 SAYdisp "��� ��㣮�� - 2, ��� 3-�� - 3 > "  COLOR "w+/bg"
  @11,42  GET m_ask PICTURE "9" VALID m_ask<=3 COLOR "b/bg,gr+/n"
  @13,10 SayDisp "����i�� �i�>"   COLOR "w+/bg"
  @13,23 Get  m_year PICTURE "9999" COLOR "N/BG,GR+/N"
  READ
  IF LASTKEY()==K_ESC
   return .t.
  ENDIF
  m_message:=DispMessage("���⪠ ���� �����")
  m_gauge:=InitGauge("���⪠ 䠩�i�",2)
  FOR i:=1 TO LEN(a_file)
    USE (a_file[i]) NEW
    ZAP
    USE
    m_gauge:=DispGauge(m_gauge,i/(LEN(a_file)+1))
  NEXT
m_gauge:=DispGauge(m_gauge,1)
DelGauge(m_gauge)
DelMessage(m_message)
If m_ask==1
    USE (m_exepath+"INIT") NEW
    LOCA FOR init->year==STR(m_year,4)
    IF init->(FOUND())
      m_path:=ALLTRIM(init->mn)
      CLOSE init
      m_message:=DispMessage("��७�� �����i� �� �i楢�� ��㭪��")
      cl_flish(m_path)
    ELSE
      CLOSE init
      DispError("�� �������� ���� �� "+STR(m_year,4)+" �i�")
    ENDIF
endif
  USE (m_mainpath+"fvnum.dbr")
  DO CASE
    CASE m_ask==1
     fvnum->vnum1:=1
     fvnum->vnum2:=1
     fvnum->vnuma:=1
    CASE m_ask==2
     fvnum->vnum1:=500000
     fvnum->vnum2:=500000
     fvnum->vnuma:=500000
    CASE m_ask==3
     fvnum->vnum1:=750000
     fvnum->vnum2:=750000
     fvnum->vnuma:=750000
  ENDCASE
return .t.
Function cl_flish(m_path)
   LOCAL m_gauge:=InitGauge("��ॣ�� �ᮡ���� ��㭪i�",2)
   LOCAL m_097,m_110
  USE (m_syspath+"memvar") INDEX (m_syspath+"memvar") ALIAS myvar NEW
  m_097   :=RESTVAR1("m_097"  ,"ZR")
  m_110   :=RESTVAR1("m_110"  ,"ZR")
  close myvar
   USE (m_mainpath+"flish") ALIAS flish1 NEW
   USE (m_path+"flish") ALIAS flish READONLY NEW
   flish->(dbgotop())
   DO WHILE .NOT.flish->(EOF())
    IF  (flish->month=='13'.OR.(flish->month=='12'.AND.flish->kopu=='800'))
      IF flish->month=='13'.and.(flish->kopu==m_097.OR.flish->kopu==m_110)
         flish1->(dbappend())
         flish1->month:= "01"
         flish1->sum  := flish->sum
         flish1->kopu := flish->kopu
         flish1->tabn := flish->tabn
      ELSE
         flish1->(dbappend())
         flish1->month:= '00'
         flish1->sum  := flish->sum
         flish1->kopu := flish->kopu
         flish1->tabn := flish->tabn
      ENDIF
      ENDIF
      m_gauge:=DispGauge(m_gauge,(flish->(LASTREC())-flish->(RECNO())+1)/flish->(LASTREC()))
      flish->(DBSKIP(1))
   ENDDO
   CLOSE flish
   CLOSE flish1
   DelGauge(m_gauge)
RETURN .t.
#DEFINE COND1 (funnum->vdoc <> 51.OR.funnum->kopr=='05') .AND. funnum->kopr<>'00'
Function close2
   LOCAL m_ask :=1,cMusic,GetList:={},m_message,m_gauge,;
   m_vnum:=1,i,m_year:=YEAR(DATE())-1,m_path
   LOCAL a_file:={;
m_mainpath+"FP1",;
m_mainpath+"FP2"}
   SET ESCAPE ON
  @8,8,14,72 BOX B_DOUBLE+" " COLOR "GR+/bg"
  @8,20 SayDisp "��७�� ����� �� 2-� ��⨭i"  COLOR "w+/bg"
  @10,10 SAYdisp "����i��, �� � �������� ��������  - 1"  COLOR "w+/bg"
  @11,10 SAYdisp "��� ��㣮�� - 2, ��� 3-�� - 3 > "  COLOR "w+/bg"
  @11,42  GET m_ask PICTURE "9" VALID m_ask<=3 COLOR "b/bg,gr+/n"
  @13,10 SayDisp "����i�� �i�>"   COLOR "w+/bg"
  @13,23 Get  m_year PICTURE "9999" COLOR "N/BG,GR+/N"
  READ
  IF LASTKEY()==K_ESC
   return .t.
  ENDIF
clear
m_message:=DispMessage("���⪠ ���� �����")
m_gauge:=InitGauge("���⪠ 䠩�i�",2)
  FOR i:=1 TO LEN(a_file)
    USE (a_file[i]) NEW
    ZAP
    USE
    m_gauge:=DispGauge(m_gauge,i/(LEN(a_file)))
  NEXT
IF m_ask==1
    USE (m_exepath+"INIT") NEW
    LOCA FOR init->year==STR(m_year,4)
    IF init->(FOUND())
      m_path:=ALLTRIM(init->mn)
      CLOSE init
      cl_schet(m_path,@m_vnum,m_year)
    ELSE
      CLOSE init
      DispError("�� �������� ���� �� "+STR(m_year,4)+" �i�")
    ENDIF
endif
  USE (m_mainpath+"fvnum.dbr") NEW
  DO CASE
    CASE m_ask==1
      fvnum->vnum:=++m_vnum
    CASE m_ask==2
     fvnum->vnum:=500000
    CASE m_ask==3
     fvnum->vnum:=750000
  ENDCASE
  CLOSE fvnum
  return .t.
Function SetScht
  LOCAL m_scht1,GetList:={},m_scht2,m_scht3,m_scht4,;
  n_win
  n_win:=WOPEN(05,08,14,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "���i����� i��ଠ�i�" COLOR "n/w"
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_scht1:=PADR(RESTVAR1("m_scht1","SC"),50)
  m_scht2:=PADR(RESTVAR1("m_scht2","SC"),50)
  m_scht3:=PADR(RESTVAR1("m_scht3","SC"),50)
  m_scht4:=PADR(RESTVAR1("m_scht4","SC"),50)
  SET ESCAPE ON
  SET CURSOR ON
  SETKEY(K_F4,{||FormScht(@m_scht1,@m_scht2),GetList[1]:updateBuffer(),;
GetList[2]:updateBuffer(),GetList[1]:display(),GetList[2]:display()})
  @02,2 SayDisp "����i���i ��㭪�>" COLOR "n/bg"
  @03,2 SayDisp "����i���i ��㭪�>" COLOR "n/bg"
  @04,2 SayDisp "��஡���i   ��㭪�>" COLOR "n/bg"
  @05,2 SayDisp "��஡���i   ��㭪�>" COLOR "n/bg"
  @02,29 GET m_scht1 PICTURE "@s34" COLOR "w/b,GR+/N"
  @03,29 GET m_scht2 PICTURE "@s34" COLOR "w/b,GR+/N"
  @04,29 GET m_scht3 PICTURE "@s34" COLOR "w/b,GR+/N"
  @05,29 GET m_scht4 PICTURE "@s34" COLOR "w/b,GR+/N"
  READ
  IF LASTKEY()<>K_ESC
    SAVEVAR1("m_scht1",m_scht1,"SC")
    SAVEVAR1("m_scht2",m_scht2,"SC")
    SAVEVAR1("m_scht3",m_scht3,"SC")
    SAVEVAR1("m_scht4",m_scht4,"SC")
  ENDIF
  CLOSE myvar
  WCLOSE(n_win)
  WSELECT(0)

return .t.
Function cl_schet(m_path,m_vnum,m_year)
  LOCAL m_scht1,m_scht3,m_ndoc,m_type
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht1:={},a_scht2:={}
  LOCAL m_num_mash:="62",a_files:={},l_exit:=.f.
LOCAL   m_kopr2,s_kormday,;
a_struct:={;
{"DBT","C",7,0},;
{"COD1","C",10,0},;
{"KPLH","C",2,0},;
{"CRT","C",7,0},;
{"COD2","C",10,0},;
{"KOPR","C",2,0},;
{"GLV","N",6,0},;
{"KVO2","N",14,2},;
{"KVO","N",14,2},;
{"STM","N",16,2}}
// �᫮��� �� ������ �� �㬬������ ������⢮
// ��室 - �� �� ᨭ���᪨� � �������᪨� ��� (�/�� � �.�.) � �� ��ମ���
// ��室 - � �� ᠬ�� �� �᪫�砥���� ᯨᠭ�� ��� � ����⥫��

LOCAL   b_cond1db:={||IF((fp1->maket<> "51") .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL   b_cond1cr:={||IF((fp1->maket <> "51".OR.fp2->kopr==m_kopr2) .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL k_ost:=PADR("04",7),k_kopr:="OC",n,m_schtgsm,m_cod1
LOCAL s01:=RIGHT(STR(m_year,4),2)+"01",s02:=RIGHT(STR(m_year,4),2)+"12"
LOCAL s03:=RIGHT(STR(m_year+1,4),2)+"01"

  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_scht1:=ALLTRIM(RESTVAR1("m_scht1","SC"))+ALLTRIM(RESTVAR1("m_scht2","SC"))
  m_scht3:=ALLTRIM(RESTVAR1("m_scht3","SC")) + ALLTRIM(RESTVAR1("m_scht4","SC"))
  CLOSE myvar
  n:=NUMTOKEN(m_scht1)
FOR i:=1 TO n;AADD(a_scht1,TOKEN(m_scht1,i));NEXT
  n:=NUMTOKEN(m_scht3)
FOR i:=1 TO n;AADD(a_scht2,TOKEN(m_scht3,i));NEXT

//  WaitMessage("�����㭮� 62-� ��設��ࠬ�")
// 1-� 蠣 ����� ����� ��ਮ�
// ����室��� ��।����� , �� �� ������ �㬬�஢����� � ������⢮
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // ������ ���
  RESTMEM s_kormday // ��ମ��� � �.�.
  RESTMEM m_schtgsm  // ��� ��� - ����� �㬨������ � ������
  CLOSE myvar
  s_kormday:=ALLTRIM(s_kormday)
  m_kopr2:=ALLTRIM(m_kopr2)
  NET USE (m_sprpath+"sp44") INDEX  (m_sprpath+"sp44") NEW READONLY
// ������� ���������
//  CrStr("99")
  IF FILE(m_temppath+"buf.dbf")
    FERASE(m_temppath+"buf.dbf")
  ENDIF
USE (m_path+"FP1") INDEX (m_path+"FP1") NEW
USE (m_path+"FP2")  NEW

  DBCREATE(m_temppath+"buf.dbf",a_struct)
  USE (m_temppath+"buf.dbf") NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kplh+buf->crt+buf->cod2+buf->kopr TO (m_temppath+"buf")
  // ������� ����������
  m_gauge:=InitGauge("����i� �� ����� �i�")
  @2,10 SAY s01+"-"+s02 COLOR "w/B"
  DO WHILE .NOT. Fp2->(EOF())

    IF .NOT.Fp1Check(@n_error,s01,s02);LOOP;ENDIF

// �஢�ઠ �����
    IF IsScht(Fp2->dbt,a_scht1) // Fp2 ���室��
        m_cod1:=GetAnCod(Fp2->dbt,fp2->cod1)
        IF .not.buf->(DS(fp2->dbt+m_cod1+fp2->kplh+k_ost+SPACE(10)+k_kopr))
          buf->(DBAP())
          buf->dbt:=fp2->dbt
          buf->cod1:=m_cod1
          buf->kplh:=fp2->kplh
          buf->crt:=k_ost
          buf->kopr:=k_kopr
        ENDIF
        // �������� ������
        IF EVAL(b_cond1db)
          buf->kvo+=fp2->kvo;buf->kvo2+=fp2->kvo2
        ENDIF
        buf->stm+=fp2->stm;buf->glv+=fp2->glv
   ELSE
     IF IsScht(Fp2->dbt,a_scht2) // Fp2 ���室��
       m_cod1:=GetAnCod(Fp2->dbt,fp2->cod1)
       IF .not.buf->(DS(fp2->dbt+m_cod1+"  "+k_ost+SPACE(10)+fp2->kopr))
             buf->(DBAP())
             buf->dbt:=fp2->dbt
             buf->cod1:=m_cod1
             buf->kplh:="  "
             buf->crt:=k_ost
             buf->kopr:=fp2->kopr
       ENDIF
           buf->kvo+=fp2->kvo
           buf->kvo2+=fp2->kvo2
           buf->stm+=fp2->stm
           buf->glv+=fp2->glv
    ELSE
      IF LEFT(fp2->dbt,2)<>"04"
        m_cod1:=GetAnCod(Fp2->dbt,fp2->cod1)
        IF .not.buf->(DS(fp2->dbt+m_cod1+"  "+k_ost+SPACE(10)+k_kopr))
          buf->(DBAP())
          buf->dbt:=fp2->dbt
          buf->cod1:=m_cod1
          buf->kplh:="  "
          buf->crt:=k_ost
          buf->kopr:=k_kopr
        ENDIF
        buf->kvo+=fp2->kvo
        buf->kvo2+=fp2->kvo2
        buf->stm+=fp2->stm
        buf->glv+=fp2->glv
    ENDIF
  ENDIF
ENDIF

     IF IsScht(Fp2->crt,a_scht1)
       m_cod1:=GetAnCod(Fp2->crt,fp2->cod2)
       IF .not.buf->(DS(fp2->crt+m_cod1+fp2->otp+k_ost+SPACE(10)+k_kopr))
        buf->(DBAP())
        buf->dbt:=fp2->crt
        buf->cod1:=m_cod1
        buf->kplh:=fp2->otp
        buf->crt:=k_ost
        buf->kopr:=k_kopr
       ENDIF
      // �������� ������
        IF EVAL(b_cond1cr)
          buf->kvo-=fp2->kvo
          buf->kvo2-=fp2->kvo2
        ENDIF
        buf->stm-=fp2->stm
        buf->glv-=fp2->glv
      ELSE
         IF IsScht(Fp2->crt,a_scht2)
           m_cod1:=GetAnCod(Fp2->crt,fp2->cod2)
          IF .not.buf->(DS(k_ost+SPACE(10)+"  "+fp2->crt+m_cod1+fp2->kopr))
            buf->(DBAP())
            buf->crt:=fp2->crt
            buf->cod2:=m_cod1
            buf->kplh:="  "
            buf->dbt:=k_ost
            buf->kopr:=fp2->kopr
          ENDIF
          // �������� ������
          buf->kvo+=fp2->kvo
          buf->kvo2+=fp2->kvo2
          buf->stm+=fp2->stm
          buf->glv+=fp2->glv
        ELSE

       IF LEFT(fp2->crt,2)<>"04"
        m_cod1:=GetAnCod(Fp2->crt,fp2->cod2)
        IF .not.buf->(DS(fp2->crt+m_cod1+"  "+k_ost+SPACE(10)+k_kopr))
          buf->(DBAP())
          buf->dbt:=fp2->crt
          buf->cod1:=m_cod1
          buf->kplh:="  "
          buf->crt:=k_ost
          buf->kopr:=k_kopr
        ENDIF
        buf->kvo-=fp2->kvo
        buf->kvo2-=fp2->kvo2
        buf->stm-=fp2->stm
        buf->glv-=fp2->glv
       ENDIF
       ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("��ࢠ� ஧��㭮� ��設��ࠬ� ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.l_exit
    // ����塞 �㫥�� ��ப� � �����뢠�� ��室�饥 ᠫ줮
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
      IF buf->kvo2==0.AND.buf->kvo==0.AND. buf->stm==0.AND.buf->glv==0
         buf->(DBDELETE())
      ENDIF
      buf->(DBSKIP())
    ENDDO

CLOSE  base fp1,fp2
  NET USE (m_sprpath+"sp11") INDEX  (m_sprpath+"sp11") NEW READONLY
USE (m_mainpath+"FP1")  NEW
USE (m_mainpath+"FP2")  NEW
USE (m_mainpath+"fvnum.dbr") NEW
m_vnum := fvnum->vnum
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
      m_ndoc=SPACE(3)+LEFT(buf->dbt,2)
      FP1->(DBAPPEND())
      fp1->vnum:=str(m_vnum++,7)
      fp1->ndoc:=m_ndoc
      fp1->npch:= "    0"
      fp1->maket:= "10"
      fp1->ddoc:= DATE()
      fp1->mnt:=s03
      fp1->dvv := date()
      fp1->oper:= '00'

      DO WHILE .NOT.buf->(EOF()).AND.m_ndoc==SPACE(3)+LEFT(buf->dbt,2)

        m_type:="�"
        // ��।����� �室�饥 ᠫ줮 ᢥ��⮥ ��� ���
        FOR i:=LEN(buf->dbt)-1 TO 2 STEP -1
          IF Sp11->(DS(PADR(LEFT(buf->dbt,i),7)))
            m_type:=Sp11->type2
            EXIT
          ENDIF
        NEXT

      Fp2->(DBAPPEND())
      DO CASE
        CASE m_type="�"
          fp2->vnum:=fp1->vnum
          fp2->kopr:= buf->kopr
          fp2->kplh := buf->kplh
          fp2->dbt:= buf->dbt
          fp2->cod1:= buf->cod1
          fp2->crt:= buf->crt
          fp2->cod2:= buf->cod2
          fp2->kvo:= buf->kvo
          fp2->kvo2:= buf->kvo2
          fp2->glv :=buf->glv
          fp2->stm:= buf->stm
        CASE m_type="�"
          fp2->vnum:=fp1->vnum
          fp2->kopr:= buf->kopr
          fp2->otp:= buf->kplh
          fp2->crt:= buf->dbt
          fp2->cod2:= buf->cod1
          fp2->dbt:= buf->crt
          fp2->cod2:= buf->cod2
          fp2->kvo:=  - buf->kvo
          fp2->kvo2:= - buf->kvo2
          fp2->glv := - buf->glv
          fp2->stm:=  - buf->stm

      CASE m_type="�"
        IF buf->stm>0
          fp2->vnum:=fp1->vnum
          fp2->kopr:= buf->kopr
          fp2->kplh := buf->kplh
          fp2->dbt:= buf->dbt
          fp2->cod1:= buf->cod1
          fp2->crt:= buf->crt
          fp2->cod2:= buf->cod2
          fp2->kvo:= buf->kvo
          fp2->kvo2:= buf->kvo2
          fp2->glv :=buf->glv
          fp2->stm:= buf->stm
        ELSE
          fp2->vnum:=fp1->vnum
          fp2->kopr:= buf->kopr
          fp2->otp:= buf->kplh
          fp2->crt:= buf->dbt
          fp2->cod2:= buf->cod1
          fp2->dbt:= buf->crt
          fp2->cod2:= buf->cod2
          fp2->kvo:=  - buf->kvo
          fp2->kvo2:= - buf->kvo2
          fp2->glv := - buf->glv
          fp2->stm:=  - buf->stm
        ENDIF
      OTHERWISE

      fp2->vnum:=fp1->vnum
      fp2->kopr:= buf->kopr
      fp2->kplh := buf->kplh
      fp2->dbt:= buf->dbt
      fp2->cod1:= buf->cod1
      fp2->crt:= buf->crt
      fp2->cod2:= buf->cod2
      fp2->kvo:= buf->kvo
      fp2->kvo2:= buf->kvo2
      fp2->glv :=buf->glv
      fp2->stm:= buf->stm
    ENDCASE


      buf->(DBSKIP())
      ENDDO
    ENDDO
fvnum->vnum:=m_vnum
CLOSE fvnum




   ENDIF




CLOSE  base fp1,fp2,buf,sp44,sp11
Return .t.
STATIC Function Fp1Check(n_error,s01,s02)
LOCAL m_vnum
      IF Fp1->vnum<>Fp2->vnum
        IF .NOT.Fp1->(DS(Fp2->vnum))
          IF n_error==0
            DispError("�������� �஢���� ��� ���������")
          ENDIF
          n_error++
          // �᫨ �訡�� �ய�᪠�� �� ����� fp2 � ⠪�� ����७��� ����஬
          m_vnum:=Fp2->vnum
          DO WHILE .NOT.fp2->(EOF()).and.Fp2->vnum==m_vnum
            fp2->(DBSKIP())
          ENDDO
          RETURN .F.
        ENDIF
        IF .NOT.(fp1->mnt>=s01.AND.Fp1->mnt<=s02)
          m_vnum:=Fp2->vnum
          DO WHILE .NOT.fp2->(EOF()).and.Fp2->vnum==m_vnum
            fp2->(DBSKIP())
          ENDDO
          RETURN .F.
        ENDIF

      ENDIF
RETURN .T.
STATIC FUNCTION GetAnCod(m_dbt,m_cod)
Sp44->(DS(m_dbt))
IF EMPTY(Sp44->type1)
  RETURN BLANK(m_cod,.t.)
ENDIF
RETURN m_cod
Function RestVar(m_name)
myvar->(DBSEEK(PADR(LOWER(ALLTRIM(m_name)),12)))
DO CASE
  CASE myvar->kod=="C"
    RETURN (ALLTRIM(myvar->value))
  CASE myvar->kod=="N"
    RETURN (VAL(myvar->value))
  CASE myvar->kod=="L"
    RETURN (IF(AT(UPPER(ALLTRIM(myvar->value)),"1TY�")<>0,.t.,.f.))
  CASE myvar->kod=="D"
    RETURN (CTOD(ALLTRIM(myvar->value)))
ENDCASE
DispError("������� �� �⠭�i "+m_name)
RETURN ""
Static Function IsScht(m_dbt,a_scht)
LOCAL i:=ASCAN(a_scht,{|x|(x==LEFT(m_dbt,LEN(x)))})
IF i==0
  RETURN .f.
ENDIF
RETURN .t.
Function  FormScht(m_scht1,m_scht2)
LOCAL m_str:=""
USE (m_mainpath+"Fp2") NEW READONLY
DO WHILE .NOT.Fp2->(EOF())
IF .NOT.EMPTY(fp2->kplh).AND.AT(LEFT(fp2->dbt,2),m_str)==0
m_str+=LEFT(fp2->dbt,2)+","
ENDIF
IF .NOT.EMPTY(fp2->otp).AND.AT(LEFT(fp2->crt,2),m_str)==0
m_str+=LEFT(fp2->crt,2)+","
ENDIF
fp2->(DBSKIP())
ENDDO
Close Fp2
IF LEN(m_str)>45
m_scht1:=LEFT(m_str,45)
m_scht2:=SUBSTR(m_str,46)
ELSE
m_scht1:=m_str
ENDIF
RETURN .t.


