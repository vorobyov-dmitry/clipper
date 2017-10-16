use d:\buhgal\ms\m68 index d:\buhgal\ms\m68
dbgotop()
set printer to  "d:\buhgal\ms\m68.lst"
set printer on
do while .not.eof()
  ?m68->npch,m68->ndoc,m68->dbt,m68->crt,m68->brgd,m68->name,m68->koef,m68->kvo,m68->kvo2,m68->stm
  skip
enddo
set printer off
set printer to

close all
