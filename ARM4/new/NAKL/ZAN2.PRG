// #include "new.ch"
Function zan2
  Local i,getlist:={}
  clear
  SET DELE ON
  Use Prov1 NEW
  USE NAKL1 INDEX NAKL1A new
  SET FILTER TO NAKL1->VDOC>='1'
  USE NAKL2 INDEX NAKL2 new
  SET PRINTER TO "ZAN2.TXT"
  SET PRINTER ON

  DO WHILE .not.Prov1->(EOF())
    IF Nakl1->(DBSEEK(prov1->ndoc))
      IF nakl2->(DBSEEK(Nakl1->vnum))
        do while .not.nakl2->(eof()).and.nakl2->vnum==nakl1->vnum
          if nakl2->kod==prov1->cod2.and.nakl2->kvo==prov1->kvo
            exit
          endif
          nakl2->(Dbskip())
        enddo
        IF nakl2->kod==prov1->cod2.and.nakl2->kvo==prov1->kvo
          nakl2->stm1:=prov1->stm
          nakl2->prise1:=IF( nakl2->kvo==0,0,prov1->stm/nakl2->kvo)
          ?"    OK ",nakl1->ndoc,nakl2->kod,nakl2->kvo,nakl2->prise1,nakl2->stm1
        else
          ?"error nakl2 ctpoka not found",prov1->(RECNO()),prov1->ndoc
        endif
      else
        ?"error nakl2 not found",prov1->(RECNO()),prov1->ndoc
      endif


    ELSE
      ?"error ndoc not found",prov1->(RECNO()),prov1->ndoc
    ENDIF
    prov1->(DBSKIP())
  ENDDO
close all
set printer off
set printer to
RETURN .T.



