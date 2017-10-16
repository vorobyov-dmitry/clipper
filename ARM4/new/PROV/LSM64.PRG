use d:\buhgal\ms\m64 index d:\buhgal\ms\m64
dbgotop()
set printer to  "d:\buhgal\ms\m64.lst"
set printer on
do while .not.eof()
  ?m64->npch,m64->ndoc,m64->dbt,m64->kopr+ " " + m64->itog,m64->name,m64->dbkvo,m64->dbstm
  skip
enddo
set printer off
set printer to
close all
