use d:\buhgal\ms\m66 index d:\buhgal\ms\m66
dbgotop()
set printer to  "d:\buhgal\ms\m66.lst"
set printer on
do while .not.eof()
  ?m66->npch,m66->ndoc,m66->dbt,m66->kopr,m66->brgd,m66->name,m66->dbkvo,m66->dbstm,m66->crkvo,m66->crstm
  skip
enddo
set printer off
set printer to

close all
