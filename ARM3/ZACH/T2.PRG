#include "pass.ch"
Function t1
  local m_buf:=SPACE(256),m_file1,m_file2
  m_file1:=FOPEN("e:\buhgal\mn\atabn.dbf",0)
  FREAD(m_file1,@m_buf,163)
  m_file2:=Fcreate("A1.LST",1)
  M_BUF:=CRYPT(m_buf,PASSWORD1)
  FWRITE(m_file2,m_buf,163)
RETURN .T.
