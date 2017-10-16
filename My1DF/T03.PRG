Function t03
Local n,i,a_disk:={},m_str,getlist:={}
  n:=NumDiskF()
 FOR i:=1 TO n
  m_str:=CHR(ASC("A")+i-1)+":"
  AADD(a_disk,m_str)
 NEXT
  n:=NumDiskL()
CLEAR
 FOR i:=1 TO n
  m_str:=CHR(ASC("C")+i-1)+":"
?m_str,DRIVETYPE(m_str),DISKTYPE(m_str)
 NEXT
Return .t.