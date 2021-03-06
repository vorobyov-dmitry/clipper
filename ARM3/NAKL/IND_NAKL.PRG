#include "new.ch"
MEMVAR m_tabn,m_oper,m_level,m_syspath,m_workpath,a_menu,m_imja,m_sprpath,m_proc,m_copypath,p_npr
MEMVAR m_vdisk,m_bufpath,m_mainpath,m_mash,m_struct,m_exepath,m_shapka,m_temppath
MEMVAR m_virtdisk,m_menu_name,m_kassapath
Function IndNakl(var1)
  LOCAL m_vnum:=0
Beginit (var1)
IF ANSWER("I�����஢�� ����?")==YES
  DispMessage("I������i� ��� ")
  USE (m_workpath+"spr03") NEW
  INDEX ON STR(spr03->year,4)+spr03->kod+spr03->mol TO (m_workpath+"spr03")
  INDEX ON STR(spr03->year,4)+spr03->mol+spr03->kod TO (m_workpath+"spr03a")
  CLOSE spr03
  NET USE (m_workpath+"nakl1")
  INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"nakl1")
  INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"nakl1a")
  CLOSE nakl1
  NET USE (m_workpath+"nakl2") NEW ALIAS nakl2
  INDEX ON field->vnum TO (m_workpath+"nakl2")
  CLOSE nakl2
  NET USE (m_workpath+"nakl3") NEW ALIAS nakl3
  INDEX ON field->vnum TO (m_workpath+"nakl3")
  CLOSE nakl3
  NET USE (m_workpath+"kaptka1") ALIAS kaptka1 NEW
  INDEX ON field->kod TO (m_workpath+"kaptka1")
  INDEX ON UPPER(field->name) TO (m_workpath+"kaptka1a")
  SET INDEX TO (m_workpath+"kaptka1"),(m_workpath+"kaptka1a")
  NET USE (m_workpath+"spr01") NEW ALIAS spr01
  INDEX ON field->kopr TO (m_workpath+"spr01")
  CLOSE spr01
  NET USE (m_workpath+"FIRM01") NEW
  INDEX ON UPPER(field->short) TO (m_workpath+"firm01")
  INDEX ON field->okpo TO (m_workpath+"firm01a")
  CLOSE firm01
  NET USE (m_workpath+"BANK01") INDEX (m_workpath+"BANK01") NEW
  NET USE (m_workpath+"nalog1") INDEX (m_workpath+"nalog1"),(m_workpath+"nalog1a") NEW ALIAS nalog1
  INDEX ON DTOS(field->ddoc)+field->ndoc TO (m_workpath+"nalog1")
  INDEX ON field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"nalog1a")
  CLOSE nalog1
  NET USE (m_workpath+"nalog2") NEW ALIAS nalog2
  INDEX ON field->vnum TO (m_workpath+"nalog2")
  CLOSE nalog2
  NET USE (m_workpath+"scht1")
  INDEX ON  DTOS(field->ddoc)+field->ndoc  TO (m_workpath+"scht1")
  INDEX ON  field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8) TO (m_workpath+"scht1a")
  CLOSE Scht1
  NET USE (m_workpath+"scht2")
  INDEX ON field->vnum TO (m_workpath+"scht2")
  CLOSE Scht2
ENDIF
RETURN .t.
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
