LOCAL m_str,m_str1,m_str2,i
USE bank01
zap
USE mfo NEW
DO WHILE .NOT.mfo->(EOF())
  bank01->(DBAPPEND())
  bank01->mfo:=ALLTRIM(STR(mfo->mfo,8))
  m_str:=CHARREPL("פץצקרש",mfo->name,"עףIiפץ")
  i:=ATTOKEN(SUBSTR(m_str,1,32),' ')
IF i<>0
  m_str1:=SUBSTR(m_str,1,i-1)
  bank01->bank1:=m_str1
  bank01->bank2:=SUBSTR(m_str,LEN(m_str1)+1)
ELSE
  m_str1:=SUBSTR(m_str,1,32)
  bank01->bank1:=m_str1
  bank01->bank2:=SUBSTR(m_str,LEN(m_str1)+1)
ENDIF
  mfo->(DBSKIP())
ENDDO
