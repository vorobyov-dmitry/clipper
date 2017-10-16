use d:\buhgal\ms\m69 index d:\buhgal\ms\m69
dbgotop()
set printer to  "d:\buhgal\ms\m69.lst"
set printer on
do while .not.eof()
  ?m69->npch,m69->ndoc,m69->brgd,m69->dbt,m69->crt,m69->name,m69->koef,m69->kvo,m69->kvo2,m69->stm
  skip
enddo
set printer off
set printer to

close all
