#include "new.ch"
#include "menu.ch"
#include "ACHOICE.ch"
#include "pass.ch"
MEMVAR a_menu,m_mainpath,m_level,m_tabn,m_oper,m_codn,m_krpou,m_kppidpr
MEMVAR m_sprpath,m_exepath,m_syspath,m_bufpath,m_mash
MEMVAR m_copypath,m_proc,m_menu_name
MEMVAR m_workpath,m_temppath,p_npr,m_dbspath,p_sovhoz,m_pension

Function Main(var1)
LOCAL m_time:=TIME(),getlist:={},m_parol,m_str:="",i
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
i:=0

SET ESCAPE ON
SET KEY K_F10 TO Calc
InitParPrn()
NET USE (m_workpath+"MENUIND") INDEX (m_workpath+"MENUIND") ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY
dialog()
SET COLOR TO "w/b"
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
      @0,0 SayDisp DMY(DATE())+" "+MyCDOW(DOW(DATE())) COLOR "n/w"
      @0,Col()+2 SayText '��� ��壠��� "~2�~3�~4�~5�~1" - ~6��ଠ I����I' COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
      @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
      @MAXROW(),Col()+2 SayText "����� �~2 001 ~1�� ~222/12/99" COLOR "N/w,R/w"
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
NET USE (m_workpath+"MENUind") INDEX (m_workpath+"MENUind") ALIAS menu NEW READONLY
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
         ScreenFile(m_temppath+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_temppath+"screen.scr")
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
   PUBLIC   m_dbspath   := ''              // ��⠫�� � ⥪�饩 ��
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // ��⠫�� � ���୮� ��
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // ��⠫�� ��� ��設��ࠬ�
   PUBLIC   m_syspath   := 'd:\buhgal\system\'  // ��⠫�� �  ��⥬��� ���ଠ樥�
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // ��⠫�� ��� �����
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // ��⠫�� � ���୮� ��
   PUBLIC   m_workpath  := 'd:\buhgal\pens\'
   PUBLIC   m_pension   := 'd:\buhgal\pens\'
   PUBLIC  m_codn
   PUBLIC   p_sovhoz
   PUBLIC   m_krpou
   PUBLIC  m_kppidpr
   IF .NOT.EMPTY(m_var1)
      IF .NOT.IsDigit(m_var1)
        m_mainpath  := m_var1+SUBSTR(m_mainpath  ,2)
        m_sprpath   := m_var1+SUBSTR(m_sprpath   ,2)
       m_exepath   := m_var1+SUBSTR(m_exepath   ,2)
       m_syspath   := m_var1+SUBSTR(m_syspath   ,2)
       m_bufpath   := m_var1+SUBSTR(m_bufpath   ,2)
       m_mash      := m_var1+SUBSTR(m_mash      ,2)
       m_copypath  := m_var1+SUBSTR(m_copypath  ,2)
       m_pension   := m_var1+SUBSTR(m_copypath  ,2)
       m_temppath  := m_var1+SUBSTR(m_pension,2)
       m_workpath  := m_var1+SUBSTR(m_workpath,2)
      ELSE
        IF FILE("INIT.DBF")
          USE init NEW Readonly
          IF VAL(m_var1)>=1.AND.VAL(m_var1)<=LASTREC()
              DBGOTO(VAL(m_var1))
              m_bufpath   := ALLTRIM(init->bf)
              m_mainpath  := ALLTRIM(init->mn)
              m_sprpath   := ALLTRIM(init->sp)
              m_exepath   := ALLTRIM(init->bh)
              m_mash      := ALLTRIM(init->ms)
              m_syspath   := ALLTRIM(init->js)
              m_copypath  := ALLTRIM(init->cp)
              m_pension   := ALLTRIM(init->pn)
              m_workpath  := ALLTRIM(init->pn)
              m_temppath  := ALLTRIM(init->temp)
          ENDIF
          CLOSE init
    	ENDIF
  ENDIF


  ELSE
   IF m_pension<>LEFT(s1,LEN(m_pension))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_mash      := s1+SUBSTR(m_mash      ,11)
       m_copypath  := s1+SUBSTR(m_copypath  ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
       m_pension   := s1+SUBSTR(m_pension,11)
       m_workpath  := s1+SUBSTR(m_workpath,11)
  ENDIF

 ENDIF

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- ��� ������ ( ���짮��⥫� )
   PUBLIC m_tabn     := ' '      // --- ⠡���� N ������ ( ���짮��⥫� )


//   NET USE (m_syspath+"sovhoz") NEW READONLY
//   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- ������������ �।�����
   PUBLIC p_npr := ""     // --- ������������ �।�����
   p_sovhoz:=.F.
//   USE

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
Function calcpens
  LOCAL k_boln,k_pen,s2,m_month,n,m_kpd,m_kpm
  LOCAL GetList:={},m_gauge,m_gauge1,i,j,m_year,m_sum
  LOCAL a_day:={31,28,31,30,31,30,31,31,30,31,30,31}
  LOCAL m_x
  SET DECIMALS TO 6
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  k_boln:=ALLTRIM(RESTVAR1("k_boln","PN"))
  k_pen:=ALLTRIM(RESTVAR1("k_pen","PN"))
  m_krpou:=ALLTRIM(RESTVAR1("m_krpou","PN"))
  m_kppidpr:=ALLTRIM(RESTVAR1("m_kppidpr","PN"))
  m_codn:=ALLTRIM(RESTVAR1("m_codn","PN"))

  CLOSE myvar
  USE ("ind-old") NEW ALIAS ind;zap
  INDEX ON ind->tin to (m_workpath+"ind")
//  USE ("pidpr") NEW
  USE ("drfo-old")  NEW ALIAS drfo
  INDEX ON drfo->tin TO  (m_workpath+"drfo")
  NET  use (m_sprpath+"sp10") index (m_sprpath+"sp10" ) NEW READONLY
  NET  use (m_sprpath+"sp08") index (m_sprpath+"sp08" ) NEW READONLY
  USE (m_mainpath+"fvnum.dbr") NEW
  m_year:=VAL(fvnum->year)
  CLOSE fvnum
  NET  use (m_mainpath+"flish") NEW READONLY
  m_gauge1:=initGauge("���iઠ � �ᮡ���� ��㭪i� ")
  DO WHILE .NOT.FLISH->(EOF())
       Sp08->(DS(flish->kopu))  // �� �ࠢ�筨�� ����� �����
       Sp10->(DS(flish->tabn))
        m_month:=IF(.NOT.EMPTY(flish->mnt).AND.m_year==mnt_year(flish->mnt),;
        mnt_month(flish->month),;
        VAL(flish->month))
        s2:=ALLTRIM(STR(m_month,2))
      IF Sp08->p02=="1"
        CheckInd(m_year)
        n:=ind->(FIELDNUM("SZP"+s2))
        ind->(FIELDPUT(n,FIELDGET(n)+flish->sum))
      ENDIF
      IF Sp08->p25=="1"
        CheckInd(m_year)
        n:=ind->(FIELDNUM("SZ"+s2))
        ind->(FIELDPUT(n,FIELDGET(n)+flish->sum))
        n:=ind->(FIELDNUM("KD"+s2))
        ind->(FIELDPUT(n,FIELDGET(n)+flish->otdn))
      ENDIF
      IF AT(flish->kopu,k_boln)<>0
        CheckInd(m_year)
        n:=ind->(FIELDNUM("SL"+s2))
        ind->(FIELDPUT(n,FIELDGET(n)+flish->sum))
      ENDIF
      IF AT(flish->kopu,k_pen)<>0
        CheckInd(m_year)
        n:=ind->(FIELDNUM("SPD"+s2))
        ind->(FIELDPUT(n,FIELDGET(n)+flish->sum))
      ENDIF
      flish->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,FLISH->(recno()/LASTREC()))
ENDDO
DelGauge(m_gauge1)
  sele sp10
  set index to
  index on sp10->codn to (m_workpath+"sp10")
SELE IND
SET INDEX TO
m_gauge1:=InitGauge("�����㭮� �����쭨� ��")
ind->(DBGOTOP())

DO WHILE .NOT.ind->(EOF())
  m_kpd:=0
  m_kpm:=0

  FOR i:=1 TO 12
    s2:=ALLTRIM(STR(i,2))

    n:=ind->(FIELDNUM("SZP"+s2))
    ind->SZP+=ind->(FIELDGET(n))

    n:=ind->(FIELDNUM("SZ"+s2))
    ind->sz+=ind->(FIELDGET(n))

    n:=ind->(FIELDNUM("SPD"+s2))
    ind->sp+=ind->(FIELDGET(n))

    n:=ind->(FIELDNUM("SPD"+s2))
    ind->svz+=ind->(FIELDGET(n))

    n:=ind->(FIELDNUM("SL"+s2))
    ind->sl+=ind->(FIELDGET(n))

    sp10->(DBSEEK(drfo->tin))
    IF sp10->kpn<>"4".and.sp10->kpn<>"6".and.sp10->kpn<>"7"
      n:=ind->(FIELDNUM("KD"+s2))
      ind->(FIELDPUT(n,a_day[i]))
      m_kpd+=ind->(FIELDGET(n))
      m_kpm++
    endif
  NEXT
  ind->kd:=m_kpd
  ind->kpm:=m_kpm
  IF sp10->inv=='1'
    ind->svr:=ind->szp*0.04
  ELSE
    ind->svr:=ind->szp*0.3320
  ENDIF

  IF .not.drfo->(DBSEEK(ind->tin))
    drfo->(DBAP())
    drfo->tin:=ind->tin
    sp10->(DBSEEK(drfo->tin))
    drfo->tab:=sp10->tabn
    drfo->fulln_u:=dostowin(sp10->fam)
    drfo->name_u:=dostowin(sp10->imja)
    drfo->fath_u:=dostowin(sp10->otch)
    drfo->d_rog:=sp10->drog
    drfo->pol:=dostowin(IF(UPPER(sp10->pol)=="�","�","�"))
    drfo->d_tin:=DATE()
    drfo->krpou:=m_krpou
    drfo->kop:=m_codn
   ENDIF
  ind->(DBSKIP())
  // ���� ����窨 � 䠩�
  m_gauge1:=DispGauge(m_gauge1,ind->(RECNO()/LASTREC()))
ENDDO
SELE ind
DelGauge(m_gauge1)
CLOSE base sp10,flish,ind,sp08
RETURN .T.

Function SetValue()
  LOCAL GetList:={},k_pen,k_boln,n_win
  n_win:=WOPEN(01,08,22,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "���i����� i��ଠ�i�" COLOR "n/w"
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  k_boln:=PADR(RESTVAR1("k_boln","PN"),50)
  k_pen:=PADR(RESTVAR1("k_pen","PN"),50)
  m_krpou:=ALLTRIM(RESTVAR1("m_krpou","PN"))
  m_kppidpr:=ALLTRIM(RESTVAR1("m_kppidpr","PN"))
  m_codn:=ALLTRIM(RESTVAR1("m_codn","PN"))
  SET ESCAPE ON
  SET CURSOR ON
  @02,2 SayDisp "��� �i���ﭨ�>" COLOR "n/bg"
  @03,2 SayDisp "��� ����i������>" COLOR "n/bg"
  @04,2 SayDisp "��� �i�����⢠>" COLOR "n/bg"
  @05,2 SayDisp "��� ������>" COLOR "n/bg"
  @06,2 SayDisp "��� ����. 䮭��>" COLOR "n/bg"
  @02,19 GET k_boln PICTURE "@S30" COLOR "w/b,GR+/N"
  @03,19 GET k_pen  PICTURE "@S30"  COLOR "w/b,GR+/N"
  @04,19 GET m_krpou PICTURE "9999999999"  COLOR "w/b,GR+/N"
  @05,19 GET m_kppidpr  PICTURE "99999"   COLOR "w/b,GR+/N"
  @06,19 GET m_codn PICTURE "9999999999"  COLOR "w/b,GR+/N"
  // @08,19 say VALTYPE(m_krpou)  +VALTYPE(m_kppidpr)+ VALTYPE(m_codn)
  READ
  IF LASTKEY()<>K_ESC
    SAVEVAR1("k_boln",k_boln,"PN")
    SAVEVAR1("k_pen",k_pen,"PN")
    SAVEVAR1("m_krpou",m_krpou,"PN")
    SAVEVAR1("m_codn",m_codn,"PN")
    SAVEVAR1("m_kppidpr",m_kppidpr,"PN")
  ENDIF
  CLOSE myvar
  WCLOSE(n_win)
  WSELECT(0)
RETURN .t.

Function CheckInd(m_year)
  LOCAL m_codn1
  IF EMPTY(ALLTRIM(Sp10->codn))
    m_codn1:=Sp10->tabn
  ELSE
   m_codn1:=Sp10->codn
  ENDIF
IF .NOT.ind->(DS(m_codn1))
  ind->(DBAP())
  ind->ktf:="1"
  ind->tin:=m_codn1
  ind->splat_r:=m_year
  ind->zvit_r:=m_year
  ind->zvit_p:="0"
  ind->krpou:=m_krpou
  ind->dfd:=date()
  ind->kpfu:=m_kppidpr
  ind->kop:=m_codn
  DO CASE
    CASE sp10->inv=="1" // ��������
      ind->ktsz:= "2"
    CASE sp10->kpn=="4".OR.sp10->kpn=="6".OR.sp10->kpn=="7"
      ind->ktsz:= "3"
    OTHERWISE
      ind->ktsz:= "1"
  ENDCASE
    ind->otk:=IF(sp10->kpn=="4".OR.sp10->kpn=="6".OR.sp10->kpn=="7","0","1")
  IF YEAR(sp10->dzch)==m_year
      ind->dpr:=sp10->dzch
  ELSE
      ind->dpr:=STOD(STR(m_year,4)+"0101")
  ENDIF
    IF YEAR(sp10->duvl)==m_year
      ind->dzr:=sp10->duvl
    ELSE
      ind->dzr:=STOD(STR(m_year,4)+"1231")
    ENDIF
ENDIF
RETURN .t.



FUNCTION t6_app()
tabl6->(DBAP())
tabl6->ROWNUM:=tabl6->(RECNO())
tabl6->NUMIDENT:=sp10->codn
tabl6->LN:=dostowin(sp10->fam)
tabl6->NM:=dostowin(sp10->imja)
tabl6->FTN:=dostowin(sp10->otch)
tabl6->ZO:=1
tabl6->ZIC:=1
tabl6->OTK:=1
tabl6->EXP:=0
RETURN .t.




Function Getmnt(m_mnt)
  LOCAL m_month1:="01",m_year1:="2010",GetList:={}
SET ESCAPE ON
@03,7,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "�����i�� �i���� ஧��㭪�" COLOR "n/w"
m_year1:=STR(YEAR(DATE()),4)
m_month1:=STRZERO(MONTH(DATE())-1,2)
@6,10 get m_month1 PICTURE "99" COLOR "gr+/B*,gr+/n" VALID (m_month1<"13".and.m_month1>"00")
@6,15 get m_year1 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2011".and.m_year1>="2000")
READ
m_mnt:=RIGHT(m_year1,2)+m_month1
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
RETURN .t.
