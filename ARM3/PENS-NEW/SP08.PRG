FUNCTION sp08(t1)
  LOCAL s1:=t1+"\sp08.dbf"
  clear
//  ?s1
//  ?
  IF FILE ("sp08a.dbf")
    FERASE("sp08a.dbf")
  ENDIF
  FILECOPY(s1,"sp08a.dbf")
  FERASE(s1)
  USE ("sp08")
  ZAP
  SET DELE On
  APPEND FROM ("SP08A")
  repla SP08->P25 WITH SP08->P02 all
  Close sp08
  FILECOPY("sp08.dbf",s1)
  USE (t1+"\sp08")
  INDEX ON sp08->KOPU TO (t1+"\sp08")
  Close sp08
RETURN .t.
