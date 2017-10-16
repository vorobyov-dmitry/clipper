use d:\buhgal\ms\m70 index d:\buhgal\ms\m70
dbgotop()
set printer to  "d:\buhgal\ms\m70.lst"
set printer on
do while .not.eof()
  ?m70->dbt,m70->kopr,m70->crt,m70->name,m70->dbstm,m70->crstm
  skip
enddo
set printer off
set printer to

close all
