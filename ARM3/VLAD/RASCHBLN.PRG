#include "menu.ch"
#include "new.ch"
#define KVO_DAY 5
MEMVAR a_menu,m_mainpath,m_level,m_tabn,m_oper
MEMVAR m_sprpath,m_exepath,m_struct,m_syspath,m_bufpath
MEMVAR m_proc,m_menu_name
MEMVAR m_workpath,m_temppath,p_npr,m_dbspath,p_sovhoz,m_computer
FUNCTION RaschBln
Local m_path:="d:\buhgal\mn\",m_gauge,m_mnt,M_SUM1
  beginit()
  NET USE (m_mainpath+"Fl01") INDEX (m_mainpath+"Fl01") NEW READONLY
  USE (m_path+"boln1") INDEX (m_path+"boln1") NEW
  USE (m_path+"boln2") INDEX (m_path+"boln2") NEW
m_gauge:=InitGauge("����ᥭ�� �i���ﭨ�",2)
do while .not.boln1->(EOF())
// m_mnt:=boln1->mnt2

boln1->mnt4:=mnt_dec(boln1->mnt2)
Fl01->(DS(mnt_syear(boln1->mnt4)+boln1->tabn+"911"))
boln1->otdn04:=fl01->(FIELDGET(FIELDNUM("OTDN"+mnt_smonth(boln1->mnt4))))
boln1->sum4:=fl01->(FIELDGET(FIELDNUM("SUM0"+mnt_smonth(boln1->mnt4))))

boln1->mnt5:=mnt_dec(boln1->mnt4)
Fl01->(DS(mnt_syear(boln1->mnt5)+boln1->tabn+"911"))
boln1->otdn05:=fl01->(FIELDGET(FIELDNUM("OTDN"+mnt_smonth(boln1->mnt5))))
boln1->sum5:=fl01->(FIELDGET(FIELDNUM("SUM0"+mnt_smonth(boln1->mnt5))))

boln1->mnt6:=mnt_dec(boln1->mnt5)
Fl01->(DS(mnt_syear(boln1->mnt6)+boln1->tabn+"911"))
boln1->otdn06:=fl01->(FIELDGET(FIELDNUM("OTDN"+mnt_smonth(boln1->mnt6))))
boln1->sum6:=fl01->(FIELDGET(FIELDNUM("SUM0"+mnt_smonth(boln1->mnt6))))

boln1->mnt7:=mnt_dec(boln1->mnt6)
Fl01->(DS(mnt_syear(boln1->mnt7)+boln1->tabn+"911"))
boln1->otdn07:=fl01->(FIELDGET(FIELDNUM("OTDN"+mnt_smonth(boln1->mnt7))))
boln1->sum7:=fl01->(FIELDGET(FIELDNUM("SUM0"+mnt_smonth(boln1->mnt7))))

  boln2->(DS(boln1->vnumc))
  DO WHILE boln2->vnumc==Boln1->vnumc.AND..NOT.boln2->(EOF())

IF (boln1->otdn01+boln1->otdn02+boln1->otdn04+boln1->otdn05+boln1->otdn06+boln1->otdn07)<>0
  m_sum1:= (boln1->sum1+boln1->sum2+boln1->sum4+boln1->sum5+boln1->sum6+boln1->sum7)/;
(boln1->otdn01+boln1->otdn02+boln1->otdn04+boln1->otdn05+boln1->otdn06+boln1->otdn07)
ELSE
m_sum1:=0
ENDIF
    boln2->sum4:=m_sum1
    boln2->sum5:=boln2->prc/100*boln2->otdn01*boln2->sum4
    boln2->(DBSKIP())
  ENDDO




   Boln1->(DBSKIP(1))
  m_gauge:=DispGauge(m_gauge,Boln1->(RECNO()/LASTREC()))
enddo
DelGauge(m_gauge)


Close base fl01,boln1,boln2

RETURN .T.
FUNCTION BegInit (m_var)

   LOCAL SwapingSpace := 3,s1:=LOWER(EXENAME()),i // ������⢮ ᢮������� ����࠭�⢠
                                     // �� ��᪥ � ������, ����室���� ���
                                     // ࠡ��� ��� "��壠���"

   // ----------------------------------------------------
   // --- ����H��K� ����������, ����� ��� ���� ������� ---
   // ----------------------------------------------------
   SetCancel ( .f. )
//   Fontreset()
   VGAPALETTE()
   SetCursor ( 0 )
   setblink(.f.)
   VGAPALETTE(6,30,30,30)
   VGAPALETTE(7,50,50,50)

   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
   SET DATE format "DD.MM.YYYY"
   PUBLIC   m_workpath  := "d:\buhgal\korrect\"       // ��⠫�� � ⥪�饩 ��
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'      // ��⠫�� � ���୮� ��
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'      // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'      // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'      // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_syspath   := 'd:\buhgal\SYSTEM\'  // ��⠫�� �  ��⥬��� ���ଠ樥�
   PUBLIC   m_temppath  := 'd:\buhgal\temp\'    // ��⠫�� � ���୮� ��
   PUBLIC   m_computer  :=1

   IF .NOT.EMPTY(m_var)
      USE init NEW READONLY
      IF VAL(m_var)>0.AND.VAL(m_var)<=LASTREC()
        DBGOTO(VAL(m_var))
        m_workpath  :=ALLTRIM(init->nk)
        m_bufpath   :=ALLTRIM(init->bf)
        m_mainpath  :=ALLTRIM(init->mn)
        m_sprpath   :=ALLTRIM(init->sp)
        m_exepath   :=ALLTRIM(init->bh)
        m_syspath   :=ALLTRIM(init->js)
        m_temppath  :=ALLTRIM(init->tp)
      ENDIF
      CLOSE init
ELSE
  IF   m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_workpath  := s1+SUBSTR(m_workpath  ,11)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
   ENDIF
   ENDIF

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- ��� ������ ( ���짮��⥫� )
   PUBLIC m_tabn     := ' '      // --- ⠡���� N ������ ( ���짮��⥫� )



   PUBLIC a_menu:={}

   // �஢�ઠ ������ ᢮������� ����࠭�⢠ �� ��᪥

   IF ( i := DiskSpace () ) <= ( SwapingSpace * 1048576 )
      DispErr('��� ��ଠ�쭮� ࠡ�� ��� �����i��� '+Str ( SwapingSpace, 2 ) + ' ����� ᢮������� �i��� �� ����.'+;
      '���������� �i��� '+ Str ( i / 1048576 , 5 , 2 ) + ' �����. ����� ��⥬� ����������.')
      QUIT
   ENDIF
RETURN .t.
