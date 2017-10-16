use d:\buhgal\ms\m65 index d:\buhgal\ms\m65
dbgotop()
set printer to  "d:\buhgal\ms\m65.lst"
set printer on
do while .not.eof()
  ?m65->npch,m65->ndoc,m65->dbt,m65->kopr+ " " + m65->itog,m65->name,m65->dbkvo,m65->dbstm
  skip
enddo
set printer off
set printer to
close all
