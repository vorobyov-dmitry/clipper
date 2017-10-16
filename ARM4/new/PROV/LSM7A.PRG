use m75 index m75
dbgotop()
set printer to  "75.lst"
set printer on
do while .not.eof()
  ?m75->dbt,m75->name,m75->indbstm,m75->incrstm,m75->dbstm,m75->crstm,m75->outdbstm,m75->outcrstm
  skip
enddo
set printer off
set printer to
close all
