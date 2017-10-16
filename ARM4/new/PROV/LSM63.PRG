use d:\buhgal\ms\m63 index d:\buhgal\ms\m63
dbgotop()
set printer to  "d:\buhgal\ms\m63.lst"
set printer on
do while .not.eof()
  ?m63->kplh,m63->npch,m63->ndoc,m63->dbt,m63->name,m63->inkvo,m63->instm,m63->dbkvo,m63->dbstm,m63->crkvo,m63->crstm
  skip
enddo
set printer off
set printer to

close all
