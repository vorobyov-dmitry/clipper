#include "buh.ch"
#include  "error.ch"
MEMVAR m_bufpath ,m_mainpath,m_sprpath,m_exepath,m_mash
MEMVAR m_platpath,m_syspath,m_temppath,m_workpath

Function Main(var1)
LOCAL m_time:=TIME(),m_env,getlist:={},m_path,m_x,m_name,;
      m_var:=IF(var1==NIL," ",alltrim(var1)),s1:=LOWER(EXENAME())


   // ----------------------------------------------------
   // --- ����H��K� ����������, ����� ��� ���� ������� ---
   // ----------------------------------------------------
SetCancel ( .f. )
SetCursor ( SC_NONE )
SetBlink(.f.)
Set ( _SET_ESCAPE     , .f. )
Set ( _SET_SCOREBOARD , .f. )
Set ( _SET_BELL       , .f. )
Set ( _SET_DECIMALS   ,  5  )
Set ( _SET_DELETED    , .t. )
Set ( _SET_CONFIRM    , .t. )
SET (_SET_EXIT        , .t. )
SET CENTURY       OFF
SET DATE          BRITISH
set epoch to 1960
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // ��⠫�� � ���୮� ��
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // ��⠫�� ��� ��設��ࠬ�
   PUBLIC   m_syspath   := 'd:\buhgal\system\'  // ��⠫�� �  ��⥬��� ���ଠ樥�
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // ��⠫�� � ���୮� ��
   PUBLIC   m_workpath  := "d:\buhgal\kassa\"
   PUBLIC   m_platpath :=  "d:\buhgal\plat\"
   clear
   ?"["+m_var+"]"
   IF m_var<>" "
      IF .NOT.IsDigit(m_var)
        IF RIGHT(m_var,1)<>"\"
           m_mainpath  := m_var+SUBSTR(m_mainpath  ,2)
           m_sprpath   := m_var+SUBSTR(m_sprpath   ,2)
           m_exepath   := m_var+SUBSTR(m_exepath   ,2)
           m_syspath   := m_var+SUBSTR(m_syspath   ,2)
           m_bufpath   := m_var+SUBSTR(m_bufpath   ,2)
           m_mash      := m_var+SUBSTR(m_mash      ,2)
           m_temppath  := m_var+SUBSTR(m_temppath  ,2)
           m_workpath  := m_var+SUBSTR(m_workpath  ,2)
           m_platpath  := m_var+SUBSTR(m_platpath  ,2)
        ELSE
          m_bufpath   := m_var+'bf\'
          m_mainpath  := m_var+'mn\'
          m_sprpath   := m_var+'sp\'
          m_exepath   := m_var+'bh\'
          m_mash      := m_var+'ms\'
          m_syspath   := m_var+'system\'
          m_temppath  := m_var+'temp\'
          m_workpath  := m_var+"kassa\"
          m_platpath :=  m_var+"plat\"
        ENDIF
      ELSE
        IF FILE("INIT.DBF")
          USE init NEW Readonly
          IF VAL(m_var)>=1.AND.VAL(m_var)<=LASTREC()
            DBGOTO(VAL(m_var))
              m_bufpath   := ALLTRIM(init->bf)
              m_mainpath  := ALLTRIM(init->mn)
              m_sprpath   := ALLTRIM(init->sp)
              m_exepath   := ALLTRIM(init->bh)
              m_mash      := ALLTRIM(init->ms)
              m_syspath   := ALLTRIM(init->js)
              m_temppath  := ALLTRIM(init->tp)
              m_workpath  := ALLTRIM(init->kassa)
              m_platpath  := ALLTRIM(init->nk)
          ENDIF
          CLOSE init
    ENDIF
  ENDIF
 ELSEIF m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_mash      := s1+SUBSTR(m_mash      ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
       m_workpath  := s1+SUBSTR(m_workpath  ,11)
       m_platpath  := s1+SUBSTR(m_platpath  ,11)
 ENDIF


   PUBLIC    p_help_code  := 0                     // ��ࠬ��� ��� ��࠭���� HELP
   PUBLIC    F_MENU     :=  "menu50" // 䠩� ����
   PUBLIC    p_npr:=""
   m_name:="��� "
   PUBLIC a_menu:={}
   CLEARWIN(0,0,MAXROW(),MAXCOL(),'N/W','�')
   SET KEY K_F10 TO Calc
//   SETKEY(K_INS,{||READINSERT(.NOT.READINSERT()),SETCURSOR(IF(READINSERT(),SC_INSERT,SC_NORMAL))})
keyboard ''
NET USE (m_syspath+"spview") INDEX (m_syspath+"spview") ALIAS view NEW READONLY
USE (m_workpath+f_menu) INDEX (m_workpath+f_menu) ALIAS menu NEW
KEYBOARD ""
InitParPrn()
dialog(m_name)
Finish()
// SHOWTIME()
RETURN .t.
*--------------------------------------------------------------------

FUNCTION  Finish
         SET COLOR TO DOS_CLR
//         SHOWTIME()
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
  local obj_error,m_set
  local l_while:=.t.
  private m_proc && �ᯮ������ ��� ���ய���⠭���� ����� ��楤���
  private m_menu_name:=var1 && �ᯮ������ ��� �ନ஢���� ������������ ����
//  initarmerror()
  KEYBOARD ""
  DO WHILE l_while
   old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
   BEGIN SEQUENCE
      SET COLOR TO (CLR_CLR)
      CLEAREOL(0,0,"n/w")
//      SHOWTIME(0,MAXCOL()-4,.t.,"n/w")
      @0,0 SayDisp DMY(DATE())+" "+CDOW(DATE()) COLOR "n/w"
      MENU ('001')
      l_while:=.f.
   RECOVER USING obj_error
      QUIT
   END SEQUENCE
  ENDDO
//  showtime()
RETURN

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+2)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 ��室"},; && ���祭� �㭪⮢ ����
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
      IF M_KEY==1.OR. m_key==AC_ABORT
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
         ScreenFile(m_temppath+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_temppath+"screen.scr")
         ENDIF
        ELSE
          WaitMessage("�ணࠬ�� �� ������祭�","w/r",.t.)
        ENDIF
        SET PRINTER TO
        SET COLOR TO ( MNU_CLR )
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.
STATIC FUNCTION    ArmError(err)

LOCAL     i,  err_msg := {},  s
LOCAL     y := ROW(), x := COL(), curs := SETCURSOR(0)
STATIC    s_han_err := 0
MEMVAR    m_workpath
WACLOSE()
  IF( err:genCode == EG_ZERODIV )
    //  ������� �� ����
    RETURN(0)
  END
/*
 IF( err:genCode == EG_OPEN .AND. err:osCode == 32 .AND. err:canDefault )
   // �訡�� �⥢�� ࠡ���
   RETURN(.F.)
 END

 IF( err:genCode == EG_APPENDLOCK .AND. err:canDefault )
    // �訡�� �⥢�� ࠡ���
    NETERR(.T.)
    RETURN(.F.)
 END
*/
 err_msg:="������"

 IF( ! EMPTY( err:subsystem()) )
    // ���ᠭ�� �����⥬�, ��� �ந��諠 �訡��
    err_msg += " " + err:subsystem() + "/" + LTRIM(STR( err:subCode() ))
 END

 IF( ! EMPTY( err:description()) )
    // ��ப��� ���ᠭ�� �訡��
    err_msg += ";" + err:description()
 END

 IF( ! EMPTY( err:operation()) )
   // ��ப���� ���ᠭ�� ����樨, �맢��襩 �訡��
   err_msg += ": " + err:operation()
 END

 IF( ! EMPTY( err:filename()) )
   // ��� 䠩��, �易����� � �訡���
   err_msg += ": " + err:filename()
 END

 IF( err:genCode == EG_OPEN .OR. err:genCode == EG_CREATE )
   // �訡�� ����
   err_msg+= ";  (�訡�� MS-DOS " + LTRIM(STR( err:osCode )) + ")"
 END

 i := 2
 s := ""
   // ����஢�� �맮�� �訡��
   WHILE( ! EMPTY( PROCNAME(i)) )
      s += "; �맢��� �� " + TRIM( PROCNAME(i)) + ;
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
   DispMessage(err_msg,"GR+/r,w+/r",.t.)
     // ����⠭�������� ��஥ ��������� �����
     SETPOS(y, x)
     SETCURSOR(curs)


   //  �����뢠�� � 䠩� ᮮ�饭�� �� �訡��
   IF(s_han_err == 0)
      //  ��諨 � ���� ࠧ ?
      IF( FILE(m_workpath +  "errors.arm"))
         s_han_err := FOPEN(m_workpath +  "errors.arm", 2)
      ELSE
         s_han_err := FCREATE(m_workpath + "errors.arm", 0)
      END
      //  �뫨 �訡�� ������/ᮧ����� ?
      IF( FERROR() != 0)
        //  ����⪠ ������ ��㤠筠
        s_han_err := 0
      END
   END

   //  ���� ���뫨 ��ଠ�쭮
   IF(s_han_err != 0)
      //  � ����� 䠩��
      FSEEK(s_han_err, 0, 2)
      //  ��襬 ���� � �६� �訡��
      FWRITE(s_han_err, DTOC( DATE()) + " " + TIME() + END_LINE)
       //  ��襬 ᮮ�饭�� �� �訡��
      FWRITE(s_han_err, err_msg)
      FWRITE(s_han_err, END_LINE)
      FCLOSE(s_han_err)
      DBCOMMITALL()
      s_han_err := 0
   END
   IF LASTKEY()==K_ALT_C
     QUIT
    ENDIF
   // �뤠�� ��쥪� �訡�� ��-���
   BREAK(err)
RETURN .f.
Function EditSp()
 NET use (m_syspath+"DBROWSE")  index (m_syspath+"DBROWSE") new readonly   alias sptabl
 NET use (m_syspath+"DBRTB")  index (m_syspath+"DBRTB") new readonly   alias sptabl1
 SpBrow("FKS07")
 Close base sptabl,sptabl1
RETURN .t.
