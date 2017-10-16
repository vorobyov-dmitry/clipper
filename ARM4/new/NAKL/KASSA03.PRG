#include "new.ch"
#define m_temppath "d:\buhgal\temp\"
#define m_sprpath "D:\Buhgal\SP\"
#define m_workpath "d:\buh\kassa\"
#define m_platpath "d:\buh\plat\"
#command DISPERROR(<var3>,<var4>,<var1>,<var2>) => n_error++  ;;
        DEVPOS(PROW()+1,0) ;;
        DEVOUT("Помилка ! КО ордер N "+STR(<var3>,5)+" за "+DTOC(<var4>)) ;;
        DEVPOS(PROW()+1,5) ;;
        DEVOUT(<var1>) ;;
        DEVPOS(PROW()+1,5) ;;
        DEVOUT(<var2>)

#command DISPWARNING(<var3>,<var4>,<var1>,<var2>) =>  n_warning++ ;;
        DEVPOS(PROW()+1,0) ;;
        DEVOUT("Попередження ! КО N "+STR(<var3>,5)+" за "+DTOC(<var4>)) ;;
        DEVPOS(PROW()+1,5) ;;
        DEVOUT(<var1>) ;;
        DEVPOS(PROW()+1,5) ;;
        DEVOUT(<var2>)

FUnction kassa02
  LOCAL a_struct:={},m_screen,m_ddoc1,m_ddoc2,m_file
  LOCAL i,j,k,n_warning:=0,n_error:=0,GetList:={}
  LOCAL a_nakl1:={},a_nakl2:={},m_ndoc,m_gauge,m_count

  AADD(a_struct,{"ndoc","N",5,0})
  AADD(a_struct,{"ddoc","D",8,0})
  AADD(a_struct,{"type","C",1,0})
  AADD(a_struct,{"ksash","C",6,0})
  AADD(a_struct,{"ndoc1","C",6,0})
  AADD(a_struct,{"sum","N",16,2})
  AADD(a_struct,{"nds","N",16,2})
  AADD(a_struct,{"glv","N",16,2})
  AADD(a_struct,{"kvo","N",16,2})
  AADD(a_struct,{"kvo2","N",16,2})
  SET DATE BRITISH
  SET DELETE ON
  SETBLINK(.f.)
  DBCREATE(m_temppath+"file1",a_struct)
  USE (m_temppath+"file1") NEW
//  INDEX on file1->ndoc1 TO (m_temppath+"file1")
  USE (m_workpath+"fks08") NEW
  m_SCREEN :=savescreen(1,19,08,64)
  DispBox(1,19,06,62,B_SINGLE+" ","w+/bg")
  Shadow(1,19,06,62)
  m_ddoc1:=fks08->ddoc
  FKS08->(DBGOBOTTOM())
  m_ddoc2:=fks08->ddoc
  @ 02,20 sayDisp 'Виконати звiрку з накладними  з ' COLOR "n/Bg"
  @ 04,20 sayDisp 'по (включно)'  COLOR "n/Bg"
  @ 03,39 get m_ddoc1 COLOR "gr+/N"
  @ 05,39 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  SET ESCAPE ON
  read
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      restscreen(1,19,08,64,m_screen)
      RETURN .F.
  ENDIF
  fks08->(DBGOTOP())
  m_gauge:=InitGauge("Вибiрка iз бази касових ордерiв")
  DO WHILE .not.fks08->(EOF())
    IF LEFT(fks08->ksash,2)=="46".AND.fks08->ndoc1<>0.AND.fks08->ddoc<=m_ddoc2.AND.fks08->ddoc>=m_ddoc1
      file1->(DBAP())
      file1->ndoc  := fks08->ndoc
      file1->ddoc  := fks08->ddoc
      file1->type  := IF(fks08->kpr<"100","0","1")
      file1->ndoc1 := PADL(ALLTRIM(STR(fks08->ndoc1)),6)
      file1->ksash   := fks08->ksash
      file1->sum   := fks08->sum
      file1->nds   := fks08->nds
      file1->glv   := fks08->glv
      file1->kvo   := fks08->kvo
      file1->kvo2  := fks08->kvo2
    ENDIF
    fks08->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fks08->(RECNO())/Fks08->(LASTREC()))
  ENDDO
  CLOSE Fks08
  DelGauge(m_gauge)
  NET USE (m_platpath+"nakl1") INDEX (m_platpath+"nakl1") NEW
  NET USE (m_platpath+"nakl2") INDEX (m_platpath+"nakl2") NEW READONLY
  NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1") NEW READONLY
  NET USE (m_sprpath+"sp07") INDEX (m_sprpath+"sp07") NEW READONLY
  m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
  SETPRC(0,0)
  SET PRINTER TO (m_file)
  SET DEVICE TO PRINTER
  file1->(DBGOTOP())
  m_gauge:=InitGauge("Звiрка касових ордерiв з накладними")
  m_count:=0
  DO WHILE .NOT.file1->(EOF())
    IF nakl1->(DS(file1->ndoc1))
      a_nakl1:={file1->ndoc1,0,0,NIL,file1->ddoc}
      m_ndoc:=file1->ndoc1;i:=file1->ndoc
      DO WHILE .NOT.file1->(EOF()).AND.file1->ndoc1==m_ndoc.AND.i==file1->ndoc
        a_nakl1[2]:=a_nakl1[2]+file1->sum
        a_nakl1[3]:=a_nakl1[3]+file1->nds
        m_count++
        file1->(DBSKIP())
      ENDDO

      a_nakl2:={nakl1->ndoc,0,0,NIL,nakl1->ddoc}
      nakl2->(DS(nakl1->vnum))
      m_ndoc:=nakl1->vnum
      DO WHILE .NOT.nakl2->(EOF()).AND.nakl2->vnum==m_ndoc
        kaptka1->(DS(nakl2->kod))
        a_nakl2[2]:=a_nakl2[2]+nakl2->stm+nakl2->nds
        a_nakl2[3]:=a_nakl2[3]+nakl2->nds
        nakl2->(DBSKIP())
      ENDDO
      IF file1->type=="1" // Возврат за неполученную продукцию
        IF .NOT.ISBIT(ASC(nakl1->state),1)
          DispError(i,a_nakl1[5],;
        "Накл. N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"не вiдмiчена як оплачена")
        ENDIF
        IF ISBIT(ASC(nakl1->state),2)
          DispError(i,a_nakl1[5],;
        "Накл. N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"- продукцiя вiдпущена")
        ENDIF
      ENDIF
      IF a_nakl1[5]<a_nakl2[5]
        DispWarning(i,a_nakl1[5],;
        "дата накладної N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"познiша дати КО")
      ENDIF
      IF ROUND(a_nakl1[2],2)<>ROUND(a_nakl2[2],2)
        DispError(i,a_nakl1[5],;
        "Сума накладної N "+LTRIM(a_nakl2[1])+"("+ALLTRIM(STR(a_nakl2[2],10,2))+")"+" за "+DTOC(a_nakl2[5])," не спiвпадає з сумою КО ["+ALLTRIM(STR(a_nakl1[2],10,2))+"]")
      ELSE
        IF ROUND(a_nakl1[3],2)<>ROUND(a_nakl2[3],2)
          DispError(i,a_nakl1[5],;
          "ПДВ  накладної N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"не спiвпадає з ПДВ КО")
        ELSE
 //          @PROW()+1,0 SAY "КО "+LTRIM(a_nakl1[1])+" за "+DTOC(a_nakl1[5])+" Накл. N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5])+" √"
        ENDIF
      ENDIF
    ELSE
      DispError(file1->ndoc,file1->ddoc,"вiдсутня накладна N "+LTRIM(file1->ndoc1),"")
      m_ndoc:=file1->ndoc1
      DO WHILE .NOT.file1->(EOF()).AND.file1->ndoc1==m_ndoc
        m_count++
        file1->(DBSKIP())
      ENDDO
    ENDIF
    m_gauge:=DispGauge(m_gauge,m_count/file1->(LASTREC()))
  ENDDO
DelGauge(m_gauge)
SET PRINTER TO
SET DEVICE TO SCREEN
CLOSE base nakl1,nakl2,sp07,file1
RETURN .t.
