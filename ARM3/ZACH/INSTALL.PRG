#include "pass.ch"
#include "new.ch"
memvar m_dbspath   ,m_bufpath   ,m_mainpath  ,m_sprpath   ,m_exepath
memvar m_mash      ,m_syspath   ,m_copypath
memvar m_temppath  ,m_workpath

function install
  LOCAL m_file1,m_buf:=SPACE(250)
  local m_file2,M_STR1:="",i,j,getlist:={}
   PUBLIC   m_dbspath   := ''              // ��⠫�� � ⥪�饩 ��
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // ��⠫�� � ���୮� ��
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // ��⠫�� ��� ��設��ࠬ�
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // ��⠫�� �  ��⥬��� ���ଠ樥�
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // ��⠫�� ��� �����
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // ��⠫�� � ���୮� ��
   PUBLIC   m_workpath  :=""
    set date british
  m_file1:=FOPEN("install.exe",0)
  FSEEK(m_file1,-163,2)
  fread(m_file1,@m_buf,163)
  fclose(m_file1)
  m_buf:=CRYPT(m_buf,PASSWORD1)
  clear
  i:=INT(random()%100+1)
  @10,10 say i
  j:=0
  set cursor on
  @11,10 GET j PICTURE "999999"
  read
  if 1024-9*INT(i/3)==j
    FERASE(m_mainpath+CHR(92)+CHR(65)+CHR(84)+CHR(65)+CHR(66)+CHR(78)+CHR(46)+"D"+CHR(66)+"F")
    m_file2:=FCREATE(m_mainpath+CHR(92)+CHR(65)+CHR(84)+CHR(65)+CHR(66)+CHR(78)+CHR(46)+"D"+CHR(66)+"F")
    FWRITE(M_FILE2,@m_buf,163)
    fclose(m_file2)
    SETFDATI(m_mainpath+CHR(92)+CHR(65)+CHR(84)+CHR(65)+CHR(66)+CHR(78)+CHR(46)+"D"+CHR(66)+"F",ctod("12/11/91"),"09:08:28")
  endif
return .t.
