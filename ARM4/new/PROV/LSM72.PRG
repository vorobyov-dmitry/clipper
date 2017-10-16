use d:\buhgal\ms\m72 index d:\buhgal\ms\m72
dbgotop()
set printer to  "d:\buhgal\ms\m72.lst"
set printer on
do while .not.eof()
  ?m72->npch,m72->ndoc,m72->dbt,m72->crt,m72->name,m72->indbstm,m72->incrstm,m72->dbstm,m72->crstm,m72->outdbstm,m72->outcrstm
  skip
enddo
set printer off
set printer to
close all
