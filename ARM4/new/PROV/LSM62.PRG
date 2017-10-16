use d:\buhgal\ms\m62 index d:\buhgal\ms\m62
set filter to m62->level>"1"
dbgotop()
set printer to  "d:\buhgal\ms\m62.lst"
set printer on
do while .not.eof()
  ?m62->npch,m62->ndoc,m62->dbt,m62->kplh,m62->name,m62->inkvo,m62->instm,m62->dbkvo,m62->dbstm,m62->crkvo,m62->crstm
  skip
enddo
set printer off
set printer to

close all
