#include "new.ch"
#include "menu.ch"
STATIC a_browse:={},a_print:={},a_name:={"KAPTKA1"}
STATIC EdIzm:={},Dov:={},m_nds
STATIC Sal:={},Form:={}
STATIC k_nds1,k_nds2,k_nds3,k_ndsDbt
STATIC k_ndsKopr
STATIC s_nds1,s_nds2
MEMVAR m_workpath,m_level
Function InitBrowse
  LOCAL m_browse,m_col,i,l_print:={}
  LOCAL m_select:=SELECT()
  FOR i:=1 TO LEN(a_name)
    sptabl1->(DBGOTOP())
    sptabl1->(dbseek(a_name[i]))
    IF sptabl1->(FOUND())
      m_browse:=TBrowseDB(;
      IF(sptabl1->bt==0,3,sptabl1->bt),IF(sptabl1->lt==0,1,sptabl1->lt),;
      IF(sptabl1->tp==0,MAXROW()-1,sptabl1->tp),IF(sptabl1->nr==0,MAXCOL()-1,sptabl1->nr))
      m_browse:colorspec:=IF(EMPTY(sptabl1->clr),'W/B,B/W,GR+/b,GR+/N,N/BG,w+/b',sptabl1->clr)
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
      m_browse:goTopBlock    := { ||  DBGOTOP()  }
      m_browse:cargo        := ALLTRIM(sptabl1->cargo)
      SELECT (sptabl1->fl)
  ELSE
    DispErr("Служебная ошибка ;нет описания DBROWSE "+a_name[i])
    LOOP
  ENDIF
  sptabl->(DBGOTOP())
  sptabl->(dbseek(a_name[i]))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==a_name[i]
      m_Col           := TBColumnNew()
      IF sptabl->type=='02'
        m_col:block:=&("{||"+trn(ALLTRIM(sptabl->value))+"}")
      ELSE
        IF sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")
        ELSE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
        ENDIF
      ENDIF
      m_col:heading:=ALLTRIM(sptabl->heading)
      AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
      m_Col:colorblock:=  {|| {1,2}}
        IF sptabl->type=='01'
          m_Col:headsep    := "┬─"
          m_col:colsep:="│"
          m_col:footsep:="╧═"
        ELSE
        m_Col:headsep    := "─"
          m_col:colsep:=" "
          m_col:footsep:="══"
        ENDIF
      IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
      ENDIF
     Sptabl->(DBSKIP())
     m_browse:addColumn(m_col)
    ENDDO
    m_browse:freeze        := IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
    AADD(a_browse,m_browse)
    AADD(a_print,{});a_print[LEN(a_print)]:=ACLONE(l_print)
   NEXT
  SELECT(m_select)
  InitEdIzm()
  RETURN .t.
Function InitMacro(var)
  LOCAL m_str,a_var:={}
  LOCAL n,i,s1,k,s2,n1:=0
  SavePar()
  USE (m_workpath+"macro") INDEX (m_workpath+"macro") NEW
  macro->(DS(var))
  m_str:=macro->text
  n:=MLCOUNT(m_str)
  FOR i:=1 TO n
    s1:=MEMOLINE(m_str,,i)
    IF n1<LEN(RTRIM(s1))
      n1:=LEN(RTRIM(s1))
    ENDIF
    IF (k:=AT("~",s1))==0
      s2:=myUpper(LEFT(s1,1))
    ELSE
      s2:=myUpper(SUBSTR(s1,k+1,1))
    ENDIF
    AADD(a_var,{MyAltCode(s2),RTRIM(s1)})
  NEXT
  FOR i:=1 TO LEN(a_var)
    a_var[i][2]:=PADR(a_var[i][2],n1+1)
  NEXT
  CLOSE macro
  SavePar(1)
RETURN a_var
FUNCTION InitEdIzm()
  Edizm:=InitMacro("EDIZM")
  AADD(Edizm,{ASC("?"),{||VlEd(Edizm,"Одиниця вимiру")}})
RETURN NIL
FUNCTION InitDov()
  Dov:=InitMacro("DOV")
  AADD(Dov,{ASC("?"),{||VlED(dov,"Призначення")}})
RETURN NIL
FUNCTION InitSal()
  Sal:=InitMacro("SAL")
  AADD(Sal,{ASC("?"),{||VlED(sal,"Умова продажу")}})
RETURN NIL
FUNCTION InitForm()
  Form:=InitMacro("FORM")
  AADD(Form,{ASC("?"),{||VlED(form,"")}})
RETURN NIL
Function InitNds
  NET USE (m_workpath+"NDS") READONLY NEW
  m_nds:=nds->nds/100  //;m_nds:=m_nds/(1+m_nds)
  k_nds1:=nds->ksash
  k_nds2:=nds->ksash2
  k_nds3:=nds->ksash3
  k_ndsDbt:=nds->ksash4
  k_ndsKopr:=nds->kopr
  s_nds1:=ALLTRIM(nds->Scht)
  s_nds2:=ALLTRIM(nds->Scht2)
  CLOSE Nds
RETURN .t.
/*
Function GetNdsK1()
  RETURN k_nds1
Function GetNdsK2()
  RETURN k_nds2
Function GetNdsK3()
  RETURN k_nds3
Function GetNdsS1()
  RETURN s_nds1
Function GetNdsS2()
  RETURN s_nds2
  */
Function GetNds()
IF CountNds()
    RETURN m_nds
ENDIF
RETURN 0

Function GetNdsKsash(m_ksash)
  LOCAL m_subsch:=LEFT(m_ksash,3)
  IF AT(m_subsch,s_nds1)<>0
    RETURN k_nds1
  ENDIF
  IF AT(m_subsch,s_nds2)<>0
    RETURN k_nds2
  ENDIF
RETURN k_nds3
Function GetNdsDbt()
  RETURN k_ndsDbt

Function GetNdsKopr()
RETURN k_ndsKopr

Function ReadNds()
RETURN m_nds

// **************************************************************

FUNCTION SkipDb(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // Если конец файла
       IF  EOF()
          DBSKIP( -1 )
          EXIT
       END
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
END
RETURN ( ncount )
FUNCTION SkipDb1(n,m_block,lApnd)
    LOCAL  ncount  := 0
    STATIC m_recno :=0
IF n > 0
   DO WHILE ncount < n.AND..NOT.EOF()
        m_recno:=RECNO()
        DBSKIP()
       // Если конец файла
       IF  EOF().OR..NOT.EVAL(m_block)
        IF .NOT.lApnd
          DBSKIP( -1 )
          EXIT
        ELSE
          ncount++
          DBGOBOTTOM()
          DBSKIP()
          EXIT
        ENDIF
       END
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       IF EOF()
        DBGOTO(m_recno)
      ELSE
       DBSKIP( -1 )
      ENDIF
       IF BOF();EXIT;END
       IF .NOT.EVAL(m_block);DBSKIP(1);EXIT;END
       ncount--
   ENDDO
END
RETURN ( ncount )
Function GetBrowse(m_var)
  LOCAL i:=ASCAN(a_name,UPPER(m_var))
  IF i<>0
    RETURN a_browse[i]
  ENDIF
  DispErr("Служебная ошибка ;нет обьекта DBROWSE "+a_name[i])
RETURN .f.
Function GetLprint(m_var)
  LOCAL i:=ASCAN(a_name,UPPER(m_var))
  IF i<>0
    RETURN a_print[i]
  ENDIF
  DispErr("Служебная ошибка ;нет обьекта DBROWSE "+a_name[i])
RETURN .f.
Function GetEdIzm()
  RETURN EdIzm
Function GetDov()
  RETURN Dov
Function GetSal()
  RETURN Sal
Function GetForm()
  RETURN Form
Function VlEd(a_var,m_name)
  LOCAL m_win:=WSELECT(),oCurGet:=GETACTIVE ()
  LOCAL n_win2,m_key,m_clr:="w/b,w/b,b/w,n/w,R/W"
  LOCAL i,n:=LEN(a_var)-1,j,m_str1:="",m_str2:="",n1:=0
  AEVAL(a_var,{|x|n1:=IF(LEN(x[2])>n1,LEN(x[2]),n1)},1,n)
  n1:=MAX(n1,LEN(m_name))
  n_win2:=WOPEN(0,0,n+1,n1+4)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE COLOR ("w/b")
  m_str1:="~3"+m_name;m_str2:="~4<Enter> - выбор"
  @0,INT((n1-LEN(m_str1)+NUMAT("~",m_str1)*2)/2) SayText m_str1 COLOR (m_clr)
  @MAXROW(),INT((n1-LEN(m_str2)+NUMAT("~",m_str2)*2)/2) SayText m_str2 COLOR (m_clr)
  FOR i:=1 TO n
    @i,1 SayMenu a_var[i][2] COLOR ("w/b,Gr+/b")
  NEXT
  i:=1
  DO WHILE .t.
    @i,1 SayMenu a_var[i][2] COLOR ("b/bg,w+/bg")
    m_key:=INKEY(0)
    @i,1 SayMenu a_var[i][2] COLOR ("w/b,Gr+/b")
    DO CASE
      CASE m_key==K_ESC
        WCLOSE()
        WSELECT(m_win)
        EXIT
      CASE m_key==K_ENTER
        WCLOSE()
        WSELECT(m_win)
        n:=LEN(a_var[i][2])
        FOR j:=1 TO n
           IF Substr(a_var[i][2],j,1)=="$"
             oCurGet:exitState:=5
             EXIT
            ENDIF
           IF Substr(a_var[i][2],j,1)<>"~"
             oCurGet:Overstrike(SUBSTR(a_var[i][2],j,1))
           ENDIF
        NEXT
        oCurGet:Display()
        EXIT
    CASE m_key==K_UP.AND.i>1
      i--
  CASE m_key==K_DOWN.AND.i<n
       i++
  CASE m_key==K_INS
/*    IF ANSWERu("Добавити макрос?")==YES
      USE (m_workpath+"macro") INDEX (m_workpath+"macro") NEW
      macro->(DS(var))
      macro->text:=m_str
    ENDIF */
  OTHERWISE
    j:=ASCAN(a_var,{|x|IF(AT("~"+MyUpper(CHR(m_key)),UPPER(x[2]))<>0,.t.,.f.)},1,n)
    IF j<>0
      i:=j
    ENDIF
  ENDCASE
ENDDO
RETURN .t.
Function IniTGet(m_var,a_say)
LOCAL a_get:={},i:=0
tbget->(DBGOTOP())
tbget->(DBSEEK(m_var))
do while m_var=LEFT(tbget->p01,LEN(m_var)).and..not.tbget->(eof())
  i++;AADD(a_get,GetNew())
  a_get[i]:row:=tbget->row
  a_get[i]:col:=tbget->col
  a_get[i]:picture:="@K"
  IF .NOT.EMPTY(alltrim(tbget->pict))
    a_get[i]:picture:="@K"+rtrim(tbget->pict)
  ENDIF
  a_get[i]:cargo:=FIELDNUM(alltrim(tbget->name))
  IF .NOT.EMPTY(tbget->clr)
    a_get[i]:colorSpec:=ALLTRIM(tbget->clr)
  ELSE
    a_get[i]:colorSpec:="g+/b,gr+/n"
  ENDIF
  IF .NOT.EMPTY(tbget->valid)
    a_get[i]:PostBlock=GetValid(ALLTRIM(UPPER(tbget->valid)))
  ENDIF
  IF .NOT.EMPTY(tbget->WHEN)
    a_get[i]:PreBlock=GetValid(ALLTRIM(UPPER(tbget->when)))
  ENDIF
  AADD(a_say,NIL)
  IF .NOT.EMPTY(tbget->block)
    DO CASE
      CASE UPPER(ALLTRIM(tbget->block)) == "IZM"
        a_say[Len(a_say)]:=GetEdIzm()
      CASE UPPER(ALLTRIM(tbget->block)) == "DOV"
        a_say[Len(a_say)]:=GetDov()
      CASE UPPER(ALLTRIM(tbget->block)) == "SAL"
        a_say[Len(a_say)]:=GetSal()
      CASE UPPER(ALLTRIM(tbget->block)) == "FORM"
        a_say[Len(a_say)]:=GetForm()
      OTHERWISE
        a_say[Len(a_say)]:={tbget->row1,tbget->Col1,Alltrim(tbget->pict1),IF(empty(tbget->clr1),"Gr+/b",Alltrim(tbget->clr1)),SayTr(ALLTRIM(UPPER(tbget->block)))}
   ENDCASE
  ENDIF
  tbget->(dbskip())
enddo
RETURN (a_get)
Function CrGet(m_var,a_say)
LOCAL a_get:={},i:=0
tbget->(DBGOTOP())
tbget->(DBSEEK(m_var))
do while m_var=LEFT(tbget->p01,LEN(m_var)).and..not.tbget->(eof())
  i++;AADD(a_get,GetNew())
  a_get[i]:row:=tbget->row
  a_get[i]:col:=tbget->col
   a_get[i]:picture:="@K"
  IF .NOT.EMPTY(alltrim(tbget->pict))
    a_get[i]:picture:="@K"+rtrim(tbget->pict)
  ENDIF
  a_get[i]:cargo:=FIELDNUM(alltrim(tbget->name))
  IF .NOT.EMPTY(tbget->clr)
    a_get[i]:colorSpec:=ALLTRIM(tbget->clr)
  ELSE
    a_get[i]:colorSpec:="g+/b,gr+/n"
  ENDIF
  IF .NOT.EMPTY(tbget->valid)
    a_get[i]:PostBlock=GetValid(ALLTRIM(UPPER(tbget->valid)))
  ENDIF
  IF .NOT.EMPTY(tbget->WHEN)
    a_get[i]:PreBlock=GetValid(ALLTRIM(UPPER(tbget->when)))
  ENDIF
  IF a_say<>NIL
    AADD(a_say,NIL)
    IF .NOT.EMPTY(tbget->block)
      IF UPPER(ALLTRIM(tbget->block)) == "IZM"
        a_say[Len(a_say)]:=GetEdIzm()
      ELSE
        a_say[Len(a_say)]:={tbget->row1,tbget->Col1,Alltrim(tbget->pict1),IF(empty(tbget->clr1),"Gr+/b",Alltrim(tbget->clr1)),SayTr(ALLTRIM(UPPER(tbget->block)))}
      ENDIF
    ENDIF
  ENDIF
  tbget->(dbskip())
enddo
RETURN (a_get)
STATIC Function GetValid(m_var)
LOCAL m_block
DO CASE
  CASE m_var=="F"
    m_block:={||.f.}
  CASE m_var=="LV"
    m_block:={||IF(m_level<=3,.t.,.f.)}
  CASE m_var=="NDS"
    m_block:={||field->nds:=GetNds()*field->prise*field->kvo,field->stm:=field->prise*field->kvo,.t.}
   // m_block:={||TaxStm()}
  CASE m_var=="LV&IZM2"
    m_block:={||IF(m_level<=3,.t.,.f.)}
  CASE m_var=="LAPND"
    m_block:={||GetlApnd()}
  CASE m_var=="IZM2"
    m_block:={||IF(empty(field->izm2),.f.,.t.)}
  CASE m_var=="IZM2A"
    m_block:={||Kaptka1->(DBSEEK(Nakl2->Kod)),IF(empty(Kaptka1->izm2),.f.,.t.)}
  CASE m_var=="T"
    m_block:={||.t.}
  CASE m_var=="SP07"
    m_block:={||sp44->(sp_vl("SP44"))}
  CASE m_var=="SP08"
    m_block:={||sp08->(sp_vl("SP08","2"))}
  CASE m_var=="SP05"
    m_block:={||sp05->(sp_vl("SP05","2"))}
  CASE m_var=="SPR01"
    m_block:={||spr01->(Spr01())}
  CASE m_var=="SP02"
    m_block:={||sp02->(sp_vl("SP02A"))}
  CASE m_var=="SP01"
    m_block:={||sp01->(sp_vl("SP01"))}
  CASE m_var=="SP10"
    m_block:={||sp10->(sp_vl("SP10A"))}
  CASE m_var=="SP17"
    m_block:={||sp17->(sp_vl("SP17"))}
  CASE m_var=="UN"
    m_block:={|p,x|x:=EVAL(p:block),IF(EMPTY(x),.f.,SpUn(x))}
  CASE m_var=="SDV&UN"
    m_block:={|p,x|x:=JUSTRIGHT(EVAL(p:block)),EVAL(p:block,x),p:display(),IF(EMPTY(x),.f.,SpUn(x))}
  CASE m_var=="SDV"
    m_block:={|p,x|x:=JUSTRIGHT(EVAL(p:block)),EVAL(p:block,x),p:display(),.t.}
  CASE m_var=="SP44"
    m_block:={||sp44->(sp_vl("SP44"))}
//  CASE m_var=="IZM"
//    m_block:={|p,x|x:=EVAL(p:block),IF(EMPTY(x),.f.,SpUn(x))}
ENDCASE
RETURN m_block
STATIC Function SayTR(m_var)
LOCAL i:={||""}
DO CASE
  CASE m_var=="SP08"
    i:={|x,n|Sp08->(DS(x[n])),Sp08->name8}
  CASE m_var=="SP07"
    i:={|x,n|Sp44->(DS(x[n])),Sp44->naim7}
  CASE m_var=="SP44"
    i:={|x,n|sp44->(DS(x[n])),Sp44->naim7}
  CASE m_var=="SP05"
    i:={|x,n|Sp05->(DS(x[n])),Sp05->naim5a}
  CASE m_var=="SPR01"
    i:={|x,n|Spr01->(DS(x[n])),Spr01->name}
  CASE m_var=="SP01"
    i:={|x,n|Sp01->(DS(x[n])),Sp01->naim1}
  CASE m_var=="SP02"
    i:={|x,n|Sp02->(DS(x[n])),Sp10->(DS(Sp02->tabn)),_fio()}
  CASE m_var=="SP10"
    i:={|x,n|Sp10->(DS(x[n])),_fio()}
  CASE m_var=="GLV"
    i:={|x,n|x[8]-x[15]-x[18]-x[21]}
  CASE m_var=="KVO"
    i:={|x,n|x[9]-x[16]-x[19]-x[22]}
  CASE m_var=="STM"
    i:={|x,n|x[10]-x[17]-x[20]-x[23]}
ENDCASE
RETURN i
Function EditIzm()
  LOCAL m_str,n,i,s1,s2,k,n1:=0
  SavePar()
  USE (m_workpath+"macro") INDEX (m_workpath+"macro") NEW
  macro->(DS("EDIZM"))
  m_str:=macro->text
  SETCOLOR("w/b")
  SET CURSOR ON
  @4,19,21,61 BOX B_SINGLE COLOR "w/b"
  m_str:=MEMOEDIT(m_str,5,20,20,60,.t.)
  SET CURSOR OFF
  IF LASTKEY()<>K_ESC
    macro->text:=m_str
    n:=MLCOUNT(m_str)
    Edizm:={}
    FOR i:=1 TO n
      s1:=MEMOLINE(m_str,,i)
      IF n1<LEN(RTRIM(s1))
        n1:=LEN(RTRIM(s1))
      ENDIF
      IF (k:=AT("~",s1))==0
        s2:=myUpper(LEFT(s1,1))
      ELSE
        s2:=myUpper(SUBSTR(s1,k+1,1))
      ENDIF
      AADD(Edizm,{MyAltCode(s2),RTRIM(s1)})
    NEXT
    FOR i:=1 TO LEN(Edizm)
      Edizm[i][2]:=PADR(Edizm[i][2],n1+1)
    NEXT
    AADD(Edizm,{ASC("?"),{||VlEd(Edizm,"Одиниця вимiру")}})
  ENDIF
  CLOSE macro
  SavePar(1)
  RETURN .t.
Function EditDov()
  LOCAL m_str,n,i,s1,s2,k,n1:=0
  SavePar()
  USE (m_workpath+"macro") INDEX (m_workpath+"macro") NEW
  macro->(DS("DOV"))
  m_str:=macro->text
  SETCOLOR("w/b")
  SET CURSOR ON
  @4,19,21,61 BOX B_SINGLE COLOR "w/b"
  m_str:=MEMOEDIT(m_str,5,20,20,60,.t.)
  SET CURSOR OFF
  IF LASTKEY()<>K_ESC
    macro->text:=m_str
    n:=MLCOUNT(m_str)
    Dov:={}
    FOR i:=1 TO n
      s1:=MEMOLINE(m_str,,i)
      IF n1<LEN(RTRIM(s1))
        n1:=LEN(RTRIM(s1))
      ENDIF
      IF (k:=AT("~",s1))==0
        s2:=myUpper(LEFT(s1,1))
      ELSE
        s2:=myUpper(SUBSTR(s1,k+1,1))
      ENDIF
      AADD(Dov,{MyAltCode(s2),RTRIM(s1)})
    NEXT
    FOR i:=1 TO LEN(Dov)
      Dov[i][2]:=PADR(Dov[i][2],n1+1)
    NEXT
    AADD(Dov,{ASC("?"),{||VlEd(Dov,"Призначення")}})
  ENDIF
  CLOSE macro
  SavePar(1)
RETURN .t.
Function EditForm()
  LOCAL m_str,n,i,s1,s2,k,n1:=0
  SavePar()
  USE (m_workpath+"macro") INDEX (m_workpath+"macro") NEW
  macro->(DS("FORM"))
  m_str:=macro->text
  SETCOLOR("w/b")
  SET CURSOR ON
  @4,14,21,66 BOX B_SINGLE COLOR "w/b"
  m_str:=MEMOEDIT(m_str,5,15,20,65,.t.)
  SET CURSOR OFF
  IF LASTKEY()<>K_ESC
    macro->text:=m_str
    n:=MLCOUNT(m_str)
    Form:={}
    FOR i:=1 TO n
      s1:=MEMOLINE(m_str,,i)
      IF n1<LEN(RTRIM(s1))
        n1:=LEN(RTRIM(s1))
      ENDIF
      IF (k:=AT("~",s1))==0
        s2:=myUpper(LEFT(s1,1))
      ELSE
        s2:=myUpper(SUBSTR(s1,k+1,1))
      ENDIF
      AADD(Form,{MyAltCode(s2),RTRIM(s1)})
    NEXT
    FOR i:=1 TO LEN(Form)
      Form[i][2]:=PADR(Form[i][2],n1+1)
    NEXT
    AADD(Form,{ASC("?"),{||VlEd(Form,"Умова продажу")}})
  ENDIF
  CLOSE macro
  SavePar(1)
RETURN .t.
Function EditSal()
  LOCAL m_str,n,i,s1,s2,k,n1:=0
  SavePar()
  USE (m_workpath+"macro") INDEX (m_workpath+"macro") NEW
  macro->(DS("SAL"))
  m_str:=macro->text
  SETCOLOR("w/b")
  SET CURSOR ON
  @4,19,21,61 BOX B_SINGLE COLOR "w/b"
  m_str:=MEMOEDIT(m_str,5,20,20,60,.t.)
  SET CURSOR OFF
  IF LASTKEY()<>K_ESC
    macro->text:=m_str
    n:=MLCOUNT(m_str)
    Sal:={}
    FOR i:=1 TO n
      s1:=MEMOLINE(m_str,,i)
      IF n1<LEN(RTRIM(s1))
        n1:=LEN(RTRIM(s1))
      ENDIF
      IF (k:=AT("~",s1))==0
        s2:=myUpper(LEFT(s1,1))
      ELSE
        s2:=myUpper(SUBSTR(s1,k+1,1))
      ENDIF
      AADD(Sal,{MyAltCode(s2),PADR(s1,10)})
    NEXT
    FOR i:=1 TO LEN(Sal)
      Sal[i][2]:=PADR(Sal[i][2],n1+1)
    NEXT
    AADD(Sal,{ASC("?"),{||VlEd(sal,"Умова продажу")}})
  ENDIF
  CLOSE macro
  SavePar(1)
RETURN .t.

Function CrList1(m_var,m_browse,l_print,m_var1)
    LOCAL m_col
    IF m_var1==NIL
      SELECT(m_var)
    ELSE
      SELECT(m_var1)
    ENDIF
    sptabl1->(DBGOTOP())
    sptabl1->(dbseek(m_var))
    IF sptabl1->(FOUND())
      m_browse:=TBrowseDB(;
      IF(sptabl1->bt==0,3,sptabl1->bt),IF(sptabl1->lt==0,1,sptabl1->lt),;
      IF(sptabl1->tp==0,MAXROW()-1,sptabl1->tp),IF(sptabl1->nr==0,MAXCOL()-1,sptabl1->nr))
      m_browse:colorspec:=IF(EMPTY(sptabl1->clr),'W/B,B/W,GR+/b,GR+/N,N/BG,w+/b',sptabl1->clr)
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
      m_browse:goTopBlock    := { ||  DBGOTOP()  }
      m_browse:cargo        := ALLTRIM(sptabl1->cargo)
      SELECT (sptabl1->fl)
  ELSE
    DispErr("Служебная ошибка ;нет описания DBROWSE "+m_var)
    RETURN .t.
  ENDIF
  sptabl->(DBGOTOP())
  sptabl->(dbseek(m_var))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==m_var
      m_Col           := TBColumnNew()
      IF sptabl->type=='02'
        m_col:block:=&("{||"+trn(ALLTRIM(sptabl->value))+"}")
      ELSE
        IF sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")
        ELSE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
        ENDIF
      ENDIF
      m_col:heading:=ALLTRIM(sptabl->heading)
      AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
      m_Col:colorblock:=  {|| {1,2}}
        IF sptabl->type=='01'
          m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
        ELSE
          m_Col:headsep    := "─";m_col:colsep:=" ";m_col:footsep:="══"
        ENDIF
      IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
      ENDIF
     Sptabl->(DBSKIP())
     m_browse:addColumn(m_col)
    ENDDO
    m_browse:freeze        := IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
  RETURN .t.
  Function CrBrCol(m_var,m_browse,m_var1)
    LOCAL m_col
    IF m_var1==NIL
      SELECT(m_var)
    ELSE
      SELECT(m_var1)
    ENDIF
  sptabl->(DBGOTOP())
  sptabl->(dbseek(m_var))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==m_var
      m_Col           := TBColumnNew()
      IF sptabl->type=='02'
        m_col:block:=&("{||"+trn(ALLTRIM(sptabl->value))+"}")
      ELSE
        IF sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")
        ELSE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
        ENDIF
      ENDIF
      m_col:heading:=ALLTRIM(sptabl->heading)
//      AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
      m_Col:colorblock:=  {|| {1,2}}
        IF sptabl->type=='01'.OR.sptabl->type=='04'
          m_Col:headsep    := "┬─";m_col:colsep:="│"
        ELSE
          m_Col:headsep    := "─";m_col:colsep:=" "
        ENDIF
      IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
      ENDIF
     Sptabl->(DBSKIP())
     m_browse:addColumn(m_col)
    ENDDO
    m_browse:freeze        := IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
RETURN .t.
Function MyGoTop(m_var)
    DBSEEK(m_var,.t.)
    DO WHILE m_var==field->vnum
      DBSKIP(-1)
      IF BOF()
        EXIT
      ENDIF
    ENDDO
    IF .NOT.BOF()
      DBSKIP(1)
    ENDIF
RETURN .t.

Function KodPotr(xrow,xcol,xcolor,xlen)
  LOCAL a_mass:={},n_win,n_winold:=WSELECT()
  LOCAL oCurGet:=GETACTIVE ( ),b_block:={|x|Potr(x)}
  LOCAL m_var:=oCurGet:VarGet(),i,m_answer
IF (m_var>="0".AND.m_var<="9")
   IF xrow<>NIL.AND.xcol<>NIL
     @xrow,xcol SayDisp Potr(m_var) COLOR IF(Xcolor==NIL,"GR+/B",xcolor)
   ENDIF
   RETURN .t.
ENDIF
SavePar()
n_win:=WOPEN(4,20,22,60)
@0,0,MAXROW(),MAXCOL() BOX B_SINGLE+" " COLOR "w/b"
WSELECT(n_win)
FOR i:=0 TO 9
  AADD(a_mass,STR(i,1)+" "+Potr(STR(i,1)))
NEXT
@1,1 SayDisp PADC("Перелiк споживачiв",MAXCOL()-2) COLOR "GR+/B"
m_answer:=EditMass(a_mass,xrow,xcol,xcolor,xlen,b_block)
WCLOSE()
WSELECT(n_winold)
SavePar(1)
RETURN m_answer
Function Potr(var)
    LOCAL a_mass:={{"0","Працiвник       "},;
                   {"1","Пiдприємства    "},;
                   {"2","Виробництво     "},;
                   {"3","Мат. вiд. особа "},;
                   {"4","Iнше            "},;
                   {"5","Список працiвн. "},;
                   {"6","Автопарк        "},;
                   {"7","Тракторн. парк  "},;
                   {"8","Фiзична особа   "},;
                   {"9","Перел. фiз. осiб"}}
   LOCAL i
   LOCAL y:=IF(var==NIL,spr01->potr,var)
    IF (i:=ASCAN(a_mass,{|x|(x[1]==y)}))<>0
      RETURN a_mass[i][2]
    ENDIF
    RETURN BLANK(a_mass[1][2],.t.)
Function My_Cdow(m_ddoc)
  LOCAL i:=DOW(m_ddoc)
  DO CASE
    CASE i==1
      RETURN "Недiля"
    CASE i==2
      RETURN "Понедiлок"
    CASE i==3
      RETURN "Вiвторок"
    CASE i==4
      RETURN "Середа"
    CASE i==5
      RETURN "Четверг"
    CASE i==6
      RETURN "П'ятниця"
    CASE i==7
      RETURN "Субота"
ENDCASE
RETURN ""
function my_dtos(m_ddoc,x,y)
  LOCAL a_month:={;
        " сiчня ",;
        " лютого ",;
        " березня ",;
        " квiтня ",;
        " травня ",;
        " червня ",;
        " липня ",;
        " серпня ",;
        " вересня ",;
        " жовтня ",;
        " листопада ",;
        " грудня "}
 IF .NOT.EMPTY(m_ddoc)
    IF x<>NIL.AND.y<>NIL
    @x,y Say STRZERO(DAY(m_ddoc),2)+a_month[MONTH(m_ddoc)]+STR(YEAR(m_ddoc),4)+' р.'
    ENDIF
    RETURN (STRZERO(DAY(m_ddoc),2)+a_month[MONTH(m_ddoc)]+STR(YEAR(m_ddoc),4))+' р.'
 ENDIF
RETURN ""
