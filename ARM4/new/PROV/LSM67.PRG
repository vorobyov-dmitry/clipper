use d:\buhgal\ms\m67 index d:\buhgal\ms\m67
dbgotop()
set printer to  "d:\buhgal\ms\m67.lst"
set printer on
do while .not.eof()
  ?m67->brgd,m67->npch,m67->ndoc,m67->dbt,m67->kopr,m67->name,m67->dbkvo,m67->dbstm,m67->crkvo,m67->crstm
  skip
enddo
set printer off
set printer to

close all
