#include "new.ch"
#include "menu.ch"
#define ITOG1 REPLICATE(CHR(255),5)+" "
#define ITOG0 REPLICATE(CHR(255),6)
#DEFINE N_PRINTER 1
#DEFINE N_PAPER 2
#DEFINE N_ZAG 3
#DEFINE N_SYMBOL 4
#DEFINE N_LINES 5
#DEFINE N_INIT_PRINTER  6
MEMVAR m_mash,m_temppath,m_vdisk,m_level,m_workpath,m_sprpath,p_npr,m_tabn,m_oper
STATIC m_page:=0,m_line:=0,n_line1:=0,m_endpage:=0,m_first:=0
Function Ms06()
  LOCAL m_file1,m_file2,m_gauge,a_struct:={}
  LOCAL m_mol:="  ",m_ddoc1:=CTOD(""),m_ddoc2:=CTOD("")
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  LOCAL n_file1,n_file2,n_kapt,n_file3
  DCL MENU
  DCL LIST
  SopenFiles("100",@s_files)
IF .not.Get001(@m_mol,@m_ddoc1,@m_ddoc2)
  ScloseFile(s_files)
  RETURN .f.
ENDIF
IF NETDISK(LEFT(m_workpath,1))
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  s2+=m_file1+","
  FILECOPY(m_workpath+"nakl1.dbf",m_file1)
  USE (m_file1) NEW READONLY ALIAS file1
  n_file1:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"nakl2.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  s2+=m_file1+","+m_file2+","
  FILECOPY(m_workpath+"nakl2.ntx",m_file2)
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
  n_file2:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"spr03.dbf",m_file1)
  s2+=m_file1+","
  USE (m_file1) NEW READONLY  ALIAS File3
  n_file3:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
  s2+=m_file1+","+m_file2+","
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
  n_kapt:=SELECT()
ELSE
  NET USE (m_workpath+"nakl1") NEW ALIAS nakl1 READONLY
  NET USE (m_workpath+"nakl2") INDEX (m_workpath+"nakl2")   NEW ALIAS nakl2 READONLY
  NET USE (m_workpath+"kaptka1") INDEX (m_workpath+"kaptka1") ALIAS kaptka1 NEW READONLY
  n_file1:=SELECT("NAKL1")
  n_file2:=SELECT("NAKL2")
  n_kapt:=SELECT("KAPTKA1")
  USE (m_workpath+"spr03.dbf") NEW  ALIAS File3
  n_file3:=SELECT()
ENDIF
  USE  (m_vdisk+"Struct") INDEX (m_vdisk+"Struct") NEW READONLY
  struct->(DS("NAKL06"))
  DO WHILE .NOT.struct->(EOF()).AND."NAKL06"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
m_file1:=TEMPFILE(m_mash,"dbf");FERASE(m_file1)
DBCREATE(m_file1,a_struct)
USE (m_file1) NEW ALIAS buf
m_file2:=TEMPFILE(m_mash,"ntx");FERASE(m_file2)
INDEX ON field->kod+field->ndoc TO (m_file2)
CLOSE struct
s2+=m_file1+","+m_file2
m_gauge:=InitGauge("Вибiрка сальдо",2)
buf->(DBAP())
buf->ndoc:=ITOG1;buf->kod:=ITOG1;buf->name:="РАЗОМ";buf->clr:="3"
buf->(DBAP())
buf->ndoc:=ITOG0;buf->kod:=ITOG0;buf->name:="КIЛЬКIСТЬ ДОКУМ.";buf->clr:="4"
DO WHILE .NOT.(n_file3)->(EOF())
  IF m_mol==(n_file3)->mol.AND.mnt_dtod(m_ddoc1)==(n_file3)->mnt
    buf->(DS((n_file3)->kod+ITOG1))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
//      buf->ndoc:=REPLICATE(CHR(255),6)
     buf->ndoc:=ITOG1
        buf->clr:="2"
      buf->kod:=(n_file3)->kod
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->prise:=(n_kapt)->prise
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->inkvo1+=(n_file3)->kvo
    buf->outkvo1+=(n_file3)->kvo
    IF (n_file3)->glv<>0
      l_kvo2:=.t.
      buf->inkvo2+=(n_file3)->glv
      buf->outkvo2+=(n_file3)->glv
    ENDIF
    buf->insum+=(n_file3)->stm
    buf->outsum+=(n_file3)->stm
    buf->(DBGOTO(1));buf->insum+=(n_file3)->stm;buf->outsum+=(n_file3)->stm
  ENDIF
  (n_file3)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file3)->(RECNO())/(n_file3)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
NET USE (m_workpath+"NAKL5") new
m_gauge:=InitGauge("Вибiрка даних по переводу ",2)
DO WHILE .NOT.nakl5->(EOF())
  IF nakl5->ddoc>=m_ddoc1.AND.nakl5->ddoc<=m_ddoc2.AND.nakl5->mol==m_mol
    buf->(DBAPPEND())
    buf->ndoc:=nakl5->ndoc
    buf->kod:=nakl5->cod1
    (n_kapt)->(DS(nakl5->cod2))
    buf->name:="Перевiд в групу("+ALLTRIM(nakl5->cod2)+") "+(n_kapt)->name
    buf->prise:=IF(nakl5->stm==0,0,nakl5->stm/nakl5->kvo)
    buf->crkvo1:=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->crkvo2:=nakl5->glv
    ENDIF
    buf->crsum:=nakl5->stm
    buf->(DS(nakl5->cod1+ITOG1))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->ndoc:=ITOG1
      buf->kod:=nakl5->cod1
      buf->clr:="2"
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->prise:=(n_kapt)->prise
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->crkvo1+=nakl5->kvo
    buf->outkvo1-=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->crkvo2+=nakl5->glv
      buf->outkvo2-=nakl5->glv
    ENDIF
    buf->crsum+=nakl5->stm
    buf->outsum-=nakl5->stm
    buf->(DBGOTO(1));buf->crsum+=nakl5->stm;buf->outsum-=nakl5->stm
    buf->(DBGOTO(2));buf->inkvo1+=1
    buf->(DBAPPEND())
    buf->ndoc:=nakl5->ndoc
    buf->kod:=nakl5->cod2
    (n_kapt)->(DS(nakl5->cod1))
    buf->name:="Перевiд iз групи("+ALLTRIM(nakl5->cod1)+") "+(n_kapt)->name
    buf->prise:=IF(nakl5->stm==0,0,nakl5->stm/nakl5->kvo)
    buf->dbkvo1:=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->dbkvo2:=nakl5->glv
    ENDIF
    buf->dbsum:=nakl5->stm
    buf->(DS(nakl5->cod2+ITOG1))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->ndoc:=ITOG1
      buf->kod:=nakl5->cod2
      buf->clr:="2"
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->prise:=(n_kapt)->prise
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->dbkvo1+=nakl5->kvo
    buf->outkvo1+=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->dbkvo2+=nakl5->glv
      buf->outkvo2+=nakl5->glv
    ENDIF
    buf->dbsum+=nakl5->stm
    buf->outsum+=nakl5->stm
    buf->(DBGOTO(1));buf->dbsum+=nakl5->stm;buf->outsum+=nakl5->stm
  ENDIF
  nakl5->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,NAKL5->(RECNO()/LASTREC()))
ENDDO
CLOSE nakl5
DelGauge(m_gauge)

m_gauge:=InitGauge("Вибiрка iнформацiї з накладних",2)
(n_file1)->(DBGOTOP())
DO WHILE .NOT.(n_file1)->(EOF())
    IF (n_file1)->ddoc3>=m_ddoc1.AND.(n_file1)->ddoc3<=m_ddoc2;
      .AND..not.IsBit(ASC((n_file1)->state),3).AND.IsBit(ASC((n_file1)->state),2)
      IF ((n_file1)->otp==m_mol).OR.((n_file1)->vdoc<>"0".AND.(n_file1)->mol==m_mol)
        (n_file2)->(DS((n_file1)->vnum))
        DO WHILE .NOT.(n_file2)->(EOF()).AND.(n_file2)->vnum==(n_file1)->vnum
            buf->(DBAPPEND())
            buf->ndoc:=(n_file1)->ndoc
            buf->kod:=(n_file2)->kod
            buf->name:=(n_file1)->fio1
            IF ((n_file1)->vdoc>="1".AND.(n_file1)->otp==m_mol)
              buf->prise:=(n_file2)->prise1
              buf->crkvo1:=(n_file2)->kvo
              IF (n_file2)->glv<>0
                l_kvo2:=.t.
                buf->crkvo2:=(n_file2)->glv
              ENDIF
              buf->crsum:=(n_file2)->stm1
            ELSE
              buf->prise:=(n_file2)->prise
              buf->dbkvo1:=(n_file2)->kvo
              IF (n_file2)->glv<>0
                l_kvo2:=.t.
                buf->dbkvo2:=(n_file2)->glv
              ENDIF
              buf->dbsum:=(n_file2)->stm
            ENDIF
            buf->(DS((n_file2)->kod+ITOG1))
            IF .NOT.BUF->(FOUND())
              buf->(DBAP())
              buf->ndoc:=ITOG1
              buf->kod:=(n_file2)->kod
              buf->clr:="2"
              (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
              buf->prise:=(n_kapt)->prise
              buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
            ENDIF
            IF ((n_file1)->vdoc>="1".AND.(n_file1)->otp==m_mol)
                buf->crkvo1+=(n_file2)->kvo
                buf->outkvo1-=(n_file2)->kvo
                IF (n_file2)->glv<>0
                  l_kvo2:=.t.
                  buf->crkvo2+=(n_file2)->glv
                  buf->outkvo2-=(n_file2)->glv
                ENDIF
                buf->crsum+=(n_file2)->stm1
                buf->outsum-=(n_file2)->stm1
                buf->(DBGOTO(1));buf->crsum+=(n_file2)->stm1;buf->outsum-=(n_file2)->stm1
            ELSE
                buf->dbkvo1+=(n_file2)->kvo
                buf->outkvo1+=(n_file2)->kvo
                IF (n_file2)->glv<>0
                  l_kvo2:=.t.
                  buf->dbkvo2+=(n_file2)->glv
                  buf->outkvo2+=(n_file2)->glv
                ENDIF
                buf->dbsum+=(n_file2)->stm
                buf->outsum+=(n_file2)->stm
                buf->(DBGOTO(1));buf->dbsum+=(n_file2)->stm;buf->outsum+=(n_file2)->stm
            ENDIF
      (n_file2)->(DBSKIP())
    ENDDO
    buf->(DBGOTO(2))
    IF ((n_file1)->vdoc>="1".AND.(n_file1)->otp==m_mol)
      buf->crkvo1+=1
    ELSE
      buf->dbkvo1+=1
    ENDIF
  ENDIF
  ENDIF
  (n_file1)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file1)->(RECNO())/(n_file1)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
file3->(DBCLOSEAREA())
(n_file1)->(DBCLOSEAREA())
(n_file2)->(DBCLOSEAREA())
(n_kapt)->(DBCLOSEAREA())
select buf
buf->(DBGOTOP())
i:=0;l_doc:=.f.
DO WHILE .NOT.buf->(EOF())
  IF buf->ndoc==ITOG1
    buf->outsum1:=buf->outkvo1*buf->prise
    i+=buf->outsum1
    IF l_doc==.f.
      IF buf->inkvo1==0.AND.buf->inkvo2==0.AND.buf->insum==0.AND.buf->(RECNO())<>1
        buf->(DBDELETE())
      ENDIF
    ENDIF
    l_doc:=.f.
  ELSE
    l_doc:=.t.
  ENDIF
  buf->(DBSKIP())
ENDDO

buf->(DBGOTO(1))
buf->outsum1:=i
buf->(DBGOTOP())
s1:="Звiт по комiрниковi ~2"+ALLTRIM(_mol(m_mol))+" ("+m_mol+")";
+";~1за перiод з ~2"+My_Dtos(m_ddoc1)+" ~1по ~2"+My_Dtos(m_ddoc2)
s3:=IF(l_kvo2,"NAKL6","NAKL6A")
ViewMs(s3,s1)
CLOSE BASE buf
n:=NumToken(s2,",")
FOR i:=1 TO n-2
  FERASE(TOKEN(s2,",",i))
NEXT
IF ALERT("Зберiгати машинограму?",{"Нi","Так"},"n/bg,gr+/b")==2
  STRFILE(PADR(s1,160)+PADR(s3,10)+PADR(TOKEN(TOKEN(s2,",",n),"\:"),12)+"ьь",TOKEN(s2,",",n-1),.t.)
ELSE
  FERASE(TOKEN(s2,",",n-1));FERASE(TOKEN(s2,",",n))
ENDIF
ScloseFile(s_files)
RETURN .t.
STATIC FUNCTION color2(var)
DO CASE
  CASE buf->clr==" ".OR.buf->clr=="1"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {1,2}
      CASE var=="2"
        RETURN {2,1}
      CASE var=="3"
        RETURN {7,7}
    ENDCASE
  CASE buf->clr=="2"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {3,4}
      CASE var=="2"
        RETURN {4,3}
      CASE var=="3"
        RETURN {8,8}
    ENDCASE
  CASE buf->clr=="9"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {5,6}
      CASE var=="2"
        RETURN {6,5}
      CASE var=="3"
        RETURN {9,9}
    ENDCASE
  CASE buf->clr=="3"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {10,11}
      CASE var=="2"
        RETURN {11,10}
      CASE var=="3"
        RETURN {12,12}
    ENDCASE
  CASE buf->clr=="4"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {13,14}
      CASE var=="2"
        RETURN {14,13}
      CASE var=="3"
        RETURN {15,15}
    ENDCASE
  CASE buf->clr=="5"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {16,17}
      CASE var=="2"
        RETURN {17,16}
      CASE var=="3"
        RETURN {18,18}
    ENDCASE
  CASE buf->clr=="6"
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {19,20}
      CASE var=="2"
        RETURN {20,19}
      CASE var=="3"
        RETURN {21,21}
    ENDCASE
ENDCASE

RETURN {1,2}
STATIC Function CrList6(m_var,m_browse,l_print)
    LOCAL m_col,i:=0
      m_browse:=TBrowseDB(4,1,MAXROW()-1,MAXCOL()-1)
      m_browse:colorspec:='W/B,B/W,w+/b,W+/W,GR+/B,GR+/w,w/b*,w+/b*,GR+/b*,bg+/b,bg+/w,bg+/b*,g+/b,g+/w,g+/b*,Rb+/b,rb/w,rb+/b*,r+/b,r/w,r+/B*'
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||MyGOBOT(m_browse) }
      m_browse:goTopBlock    := { ||m_page:=1,m_line:=m_first,DBGOTOP()  }
  sptabl->(DBGOTOP())
  sptabl->(dbseek(m_var))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==m_var
      m_Col           := TBColumnNew()
      i++
      DO CASE
        CASE sptabl->type=='03'
        m_col:block:=&("{||IF(buf->clr==' ',StoStr2(buf->"+ALLTRIM(sptabl->value)+",12),StoStr1(buf->"+ALLTRIM(sptabl->value)+",12))}")
      CASE sptabl->type=='04'
        m_col:block:=&("{||IF(buf->clr==' ',SPACE(12),StoStr1("+ALLTRIM(sptabl->value)+",12))}")
        CASE sptabl->type=='02'
        m_col:block:=&("{||"+ALLTRIM(sptabl->value)+"}")
        CASE sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")

        OTHERWISE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
      ENDCASE
/*      IF i==7
        m_col:block:={||IF(buf->clr==" ",SPACE(12),STostr1(buf->inkvo1,12))}
      ENDIF
      IF i==9
        m_col:block:={||IF(buf->clr==" ",SPACE(12),STostr1(buf->insum,12))}
      ENDIF */

      m_col:heading:=ALLTRIM(sptabl->heading)
      AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
      m_Col:colorblock:=  {||color2("1")}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
      ENDIF
      IF .NOT.EMPTY(sptabl->cargo)
        m_col:Cargo:=ALLTRIM(sptabl->cargo)
      ENDIF
     Sptabl->(DBSKIP())
     m_browse:addColumn(m_col)
    ENDDO
    sptabl1->(DS(m_var))
    m_browse:freeze:= IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
  RETURN .t.
STATIC FUNCTION SkipDb(n)
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
  m_line+=ncount
  DO WHILE  m_line>m_endpage
    m_line:=m_line-m_endpage-1+m_first
    m_page++
  ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
  m_line+=ncount
  DO WHILE  m_line<m_first
    m_line:=m_line+m_endpage-m_first+1
    m_page--
  ENDDO
END
RETURN ( ncount )
STATIC Function MyGOBOT(m_browse)

DO WHILE .t.
  IF EVAL(m_browse:SkipBlock,1)<>1
    EXIT
  ENDIF
ENDDO
RETURN .t.
Function StoSTR2(x,m_len)
LOCAL m_str:="",s:=STR(ABS(x),18,2),i
if x==0
  return SPACE(m_len)
endif
m_str:=ALLTRIM(substr(s,1,3))
FOR i:=1 TO 4
   IF .NOT.EMPTY(SUBSTR(s,3*i+1,3))
       IF .NOT.EMPTY(m_str)
           m_str+="'"+SUBSTR(s,3*i+1,3)
      ELSE
        m_str+=ALLTRIM(SUBSTR(s,3*i+1,3))
      ENDIF
    ENDIF
NEXT
m_str+=IF(substr(s,17,2)=='00',"","."+substr(s,17,2))
IF x<0
  m_str:="-"+m_str
ENDIF
IF m_len<>NIL.AND.m_len>0
   m_str:=IF(LEN(m_str)>m_len,REPLICATE("*",m_len),PADL(m_str,m_len))
ENDIF
RETURN m_str
Function ViewMs(var,var2)
  LOCAL n_win,m_screen,l_filter:=.f.,n_win1
  LOCAL i,j,k,m_key,a_shapka:={},m_clr,n_pos
  LOCAL m_name:=IF(var2==NIL,"",ALLTRIM(var2))
  DCL MENU
  DCL list
CrList6(var,@m_browse,@l_print)
// m_browse:cargo:=var2
n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
n_win1:=InitScr(var)
WSELECT(n_win)
ADD menu up_down
add menu Left_Right
add menu search
ADD MENU NAME "Д~рук" ITEMS {"Друк через спулер F2","Друк на прiнтер <Ctrl>+P",;
"Перелiк стовбцiв <Ctrl>+L","Параметри друку F9","Параметри прiнтера <Ctrl>+U","Кiлькiсть рядкiв <Alt>+F9"} ;
KEY {K_F2,K_CTRL_P,K_CTRL_L,K_F9,K_CTRL_U,K_ALT_F9}
ADD MENU NAME "Iн~ше" ITEMS {"Формат сторiнки F11","Перелiк накладних <Ctrl>+F4"};
KEY {K_F11,K_CTRL_F4}
ADD MENU NAME "~Фiльтр" ITEMS {"0 - рiвень <Alt>+0","1 - рiвень <Alt>+1","2 - рiвень <Alt>+2",;
"3 - рiвень <Alt>+3","4 - рiвень <Alt>+4","5 - рiвень <Alt>+5","6 - рiвень <Alt>+6",};
KEY {K_ALT_0,K_ALT_1,K_ALT_2,K_ALT_3,K_ALT_4,K_ALT_5,K_ALT_6}
// add menu print
a_shapka:=CreateShp(@m_browse,@l_print)
INIT menu
// DISPLAYLIST
@m_browse:ntop-1,m_browse:nleft-1,m_browse:nBottom,m_browse:nRight+1 BOX B_DOUBLE+" " COLOR "w/b"
i:=AT(";",m_name)
CLEAREOL(m_browse:ntop-3,0,"w/b"," ")
CLEAREOL(m_browse:ntop-2,0,"w/b"," ")
IF i<>0
  @m_browse:ntop-3,0 SayText PADC(LEFT(m_name,i-1),MAXCOL()+1) COLOR "w/b,gr+/b"
  @m_browse:ntop-2,0 SayText PADC(SUBSTR(m_name,i+1),MAXCOL()+1) COLOR "w/b,gr+/b"
ELSE
  @m_browse:ntop-2,0 SayText PADC(m_name,MAXCOL()+1) COLOR "w/b,gr+/b"
ENDIF
@m_browse:ntop-1,57 SayDisp "Сторiнка   " COLOR "W+/B"
@m_browse:ntop-1,70 SayDisp "Рядок   " COLOR "W+/B"
m_endpage:=GetEndPage();m_first:=LEN(a_shapka)+3
m_page:=1;m_line:=m_first
STABILIZE BROWSE m_browse
DO WHILE .t.
  m_browse:refReshCurrent()
  m_key:=0
  keyboard ""
  DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
  ENDDO
  IF m_browse:stabilize()
    @m_browse:ntop-1,66 SayDisp m_page COLOR "GR+/B" PICTURE "999"
    @m_browse:ntop-1,76 SayDisp m_line COLOR "GR+/B" PICTURE "99"
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2("3"))
    m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},color2("2"))
  ENDIF
  IF m_key==0
    m_key:=INKEY(0)
  ENDIF
  m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2("1"))
  Winsay
  DEAL MENU
  DO CASE
    CASE m_key==K_PGUP.AND.m_page>1
      EVAL(m_browse:SkipBlock,m_first-1-m_line-m_endpage+m_first)
      m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
    CASE m_key==K_PGDN
      j:=m_endpage-m_line+1
      i:=EVAL(m_browse:SkipBlock,j)
      IF i==j
        m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
      ELSE
        EVAL(m_browse:SkipBlock,-i)
      ENDIF
    DEAL BROWSE m_browse KEY m_key
    CASE m_key == K_ALT_0
        SET FILTER TO
      EVAL(m_browse:GoTopBlock)
      m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
      m_browse:RefreshAll()
    CASE m_key == K_ALT_1
      SET FILTER TO buf->clr>="1"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_2
      SET FILTER TO buf->clr>="2"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_3
      SET FILTER TO buf->clr>="3"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_4
      SET FILTER TO buf->clr>="4"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_5
      SET FILTER TO buf->clr>="5"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_6
      SET FILTER TO buf->clr>="6"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_7
      SET FILTER TO buf->clr>="7"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_ALT_8
      SET FILTER TO buf->clr>="8"
      EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:ColPos:=1
      m_browse:configure();m_browse:RefreshAll()
    CASE m_key == K_F9
        SetLpechat()
        IF GetEndPage()<>m_endpage
          m_endpage:=GetEndPage()
          EVAL(m_browse:GoTopBlock)
          m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
          m_browse:RefreshAll()
        ENDIF

//    PRINT BROWSE m_browse KEY m_key
      CASE m_key == K_CTRL_P
          m_recno:=RECNO()
          OpenPrn()
          PrintMs(m_browse,a_shapka,m_name,l_print)
          DBGOTO(m_recno)
          ClosePrn()
      CASE m_key == K_F2
          m_recno:=RECNO()
          m_clr:=TEMPFILE(m_temppath,"prn");FERASE(m_clr)
          OpenPrn(m_clr)
          PrintMs(m_browse,a_shapka,m_name,l_print)
          DBGOTO(m_recno)
          ClosePrn()
          fileToLpt1(m_clr)
          PRINTSEND(CHR(K_CTRL_L))
      CASE m_key == K_CTRL_L
          SetLprint(m_browse,@l_print)
          a_shapka:=CreateShp(@m_browse,@l_print)
          IF m_first<>LEN(a_shapka)+3
            m_first:=LEN(a_shapka)+3
            EVAL(m_browse:GoTopBlock)
            m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
            m_browse:RefreshAll()
          ENDIF
      CASE m_key == K_CTRL_U
          LSetprint()
      CASE m_key == K_ALT_F9
          CountLines()
    CASE m_key==K_F11
      WSELECT(n_win1)
      n_pos:=1
      @1,57 SayDisp "Сторiнка   " COLOR "W+/B"
      @1,70 SayDisp "Рядок   " COLOR "W+/B"
      DO WHILE .t.
        @1,66 SayDisp m_page COLOR "GR+/B" PICTURE "999"
        @1,76 SayDisp m_line COLOR "GR+/B" PICTURE "99"
        FOR i:=1 TO m_browse:ColCount
          j:=Color2("3")
          m_clr:=TOKEN(m_browse:ColorSpec,",",j[1])
          @VAL(TOKEN(m_browse:GetColumn(i):cargo,",",1)),VAL(TOKEN(m_browse:GetColumn(i):cargo,",",2));
            SayDisp EVAL(m_browse:GetColumn(i):block) COLOR m_clr
        NEXT
      j:=Color2("2")
      m_clr:=TOKEN(m_browse:ColorSpec,",",j[1])
      @VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",1)),VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",2));
      SayDisp EVAL(m_browse:GetColumn(n_pos):block) COLOR m_clr
      i:=INKEY(0)
      j:=Color2("3")
      m_clr:=TOKEN(m_browse:ColorSpec,",",j[1])
      @VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",1)),VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",2));
      SayDisp EVAL(m_browse:GetColumn(n_pos):block) COLOR m_clr
      DO CASE
        CASE i==K_ESC
          EXIT
      CASE i==K_RIGHT
        n_pos:=IF(n_pos==m_browse:ColCount,m_browse:ColCount,n_pos+1)
      CASE i==K_LEFT
        n_pos:=IF(n_pos==1,1,n_pos-1)
      CASE i==K_DOWN
        EVAL(m_browse:SkipBlock,1)
      CASE i==K_UP
        EVAL(m_browse:SkipBlock,-1)
      CASE i==K_PGUP
        EVAL(m_browse:SkipBlock,-20)
      CASE i==K_PGDN
        EVAL(m_browse:SkipBlock,20)
      CASE i==K_CTRL_PGUP
        EVAL(m_browse:GoTopBlock)
      CASE i==K_CTRL_PGDN
        EVAL(m_browse:GoBottomBlock)

      ENDCASE
      ENDDO
      j:=0
      WSELECT(n_win)
    SCAN  BROWSE m_browse KEY m_key
    SEARCH  BROWSE m_browse KEY m_key
    RANGE  BROWSE m_browse KEY m_key
    CONT SEARCH  BROWSE m_browse KEY m_key
    CASE m_key == K_CTRL_F4
      i:=ALERT("Перелiк накладних",{"По приходу","По витратi"},"n/bg,gr=/b")
      IF i==1;nakla("0");ENDIF
      IF i==2;nakl("1");ENDIF
 ENDCASE
ENDDO
WCLOSE(n_win)
WCLOSE(n_win1)
WSELECT(0)

RETURN .t.
STATIC FUNCTION CreateShp(m_browse,l_print)
LOCAL a_shp:={"┌","│","└"},;
      i,j,m_max,m_shapka,i_str:=2,m_length:=1,l
FOR i:=1 TO m_browse:colCount
  If l_print==NIL.OR.(l_print<>NIL.AND.l_print[i]==.T.)
    m_shapka:=m_browse:getColumn(i):heading+";"
    m_max:=0
    i_str:=2
    DO While   .NOT.EMPTY(m_shapka)
      j:=AT(";",m_shapka)
      IF(j>m_max+1,m_max:=j-1,NIL)
      If i_str>LEN(a_shp)-1
        AADD(a_shp,NIL)
        AINS(a_shp,i_str)
        a_shp[i_str]:=SPACE(m_length)
        FOR l:=1 TO LEN(a_shp[i_str-1])
          IF SUBSTR(a_shp[i_str-1],l,1)=="│".OR.SUBSTR(a_shp[i_str-1],l,1)=="┌"
            a_shp[i_str]:=STUFF(a_shp[i_str],l,1,"│")
          ENDIF
        ENDFOR
      EndIF
      a_shp[i_str]:=a_shp[i_str]+LEFT(m_shapka,j-1)
      i_str++
      m_shapka:=RIGHT(m_shapka,LEN(m_shapka)-j)
    EndDO
    m_max:=MAX(m_max,m_browse:colwidth(i))
    a_shp[1]+=REPLICATE("─",m_max)
    a_shp[LEN(a_shp)]+=REPLICATE("─",m_max)
    FOR l:=2 TO LEN(a_shp)-1
      a_shp[l]:=PADR(a_shp[l],m_length+m_max)+"│"
    NEXT
    m_length+=m_max+1
    a_shp[1]+="┬"
    a_shp[LEN(a_shp)]+="┴"
  EndIF
NEXT
a_shp[1]:=STUFF(a_shp[1],LEN(a_shp[1]),1,"┐")
a_shp[LEN(a_shp)]:=STUFF(a_shp[LEN(a_shp)],LEN(a_shp[LEN(a_shp)]),1,"┘")
RETURN a_shp


Static Function PrintMs(m_browse,a_shp,m_name,l_print)
LOCAL i,j,n,p_col:={},a_col:={},l,l_end:=.f.,b_finish:={||.f.}
LOCAL m_recno,n_page:=m_page,n_line:=m_line,n_page1:=-1,n1:=1,n2:=1
LOCAL m_str2:="",m_proc,l_first,a_width:={}
LOCAL m_str1:=My_Dtos(DATE())+" "
m_recno:=RECNO()
i:=ALERT("Друкувати",{"З 1-ї сторiнки","Вибiрково ","Вiдмовитися"},"n/bg+,w/b" )
DO CASE
  CASE i==1
    j:=1
    l:=LASTREC()
m_proc := InitGauge("Друк таблицi ",2)
  CASE i==2
    n1:=1;n2:=m_page
    IF GetNumPage(@n1,@n2,INT(0.6+buf->(LASTREC())/(m_endpage-m_first)))
      EVAL(m_browse:goTopBlock)
      // Позиционирование на необходимую запись
      DO WHILE m_page<>n1
        IF EVAL(m_browse:skipblock,1)<1
          DBGOTO(m_recno);m_line:=n_line;m_page:=n_page
          DispError("Сторiнка N "+STR(n1,3)+";не знайдена")
          RETURN .f.
        ENDIF
      ENDDO
      b_finish:={||IF(m_page<=n2,.f.,.t.)}
      j:=1
      l:=(n2-n1+1)*(m_endpage-m_first+1)
      m_proc := InitGauge("Друк таблицi вибiрково з сторiнки"+STR(n1,3)+" по сторiнку"+STR(n2,3),2)
    ELSE
      RETURN .f.
    ENDIF
  CASE i==0.OR.i==3
      RETURN .f.
ENDCASE
m_name:=REM01(ALLTRIM(m_name))
i:=AT(";",m_name)
IF i<>0
  IF LEN(m_name)+LEN(m_str1)+16>LEN(a_shp[1])
    m_str1+=PADC(ALLTRIM(LEFT(m_name,i-1)),LEN(a_shp[1])-16-LEN(m_str1))+"Сторiнка N"
    m_str2:=ALLTRIM(SUBSTR(m_name,i+1))
  ELSE
    m_str1+=PADC(ALLTRIM(LEFT(m_name,i-1))+" "+ALLTRIM(SUBSTR(m_name,i+1)),LEN(a_shp[1])-16-LEN(m_str1))+"Сторiнка N"
  ENDIF
ELSE
  m_str1+=PADC(ALLTRIM(m_name),LEN(a_shp[1])-16-LEN(m_str1))+"Сторiнка N"
ENDIF
p_col:={1}
j:=2
DO WHILE .t.
  i:=ATNUM("┴",a_shp[LEN(a_shp)],1,j)
  IF i==0
    EXIT
  ENDIF
  AADD(p_col,i)
  j:=i
ENDDO
IF GetParPrn(4)==2
  FOR i:=1 TO LEN(a_shp)
    a_shp[i]:=CHARREPL("┌│├└┼┴┬─┘┤┐",a_shp[i],"-||-|----||")
  NEXT
ENDIF
FOR i:=1 TO m_browse:ColCount
  IF l_print[i]
    AADD(a_col,m_browse:GetColumn(i):block)
    AADD(a_width,m_browse:GetColumn(i):width)
  ENDIF
NEXT
n:=LEN(a_col)
IF .NOT.SetWidthPrn(LEN(a_shp[1]))
  RETURN .f.
ENDIF
l_first:=.t.;j:=1
DO WHILE .T.
//   IF SkipLn(@a_shp,m_str1,m_str2)
      IF n_page1<>m_page
        IF .NOT.l_first
            StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
            SETPRC(0,0)
        ENDIF
        l_first:=.f.
        IF GetparPrn(N_PAPER)==2.AND.EMPTY(SET(_SET_PRINTFILE)) //ЛИСТЫ
          WaitMessage("Заправте лист N "+STR(m_page,3)+";и натиснить любу клавiшу")
        ENDIF
        IF GetparPrn(N_ZAG)==1.OR.(GetParPrn(N_ZAG)==2.AND.m_page==1)
          IF PrnOnLine()
              @0,0 SAY m_str1+STR(m_page,3)
//              @0,PCOL()+2 SAY LEFT(PADC(m_str1,LEN(a_shp[1])-18-PCOL()),LEN(a_shp[1])-18-PCOL())
//              @0,LEN(a_shp[1])-14 SAY "Сторiнка N" +STR(m_page,3)
              IF .NOT.EMPTY(m_str2)
                @1,0 SAY m_str2
              ENDIF
              FOR i:=1 TO LEN(a_shp)
                IF PrnOnLine()
                    @PROW()+1,0  SAY a_shp[i]
                ELSE
                    RETURN .F.
                ENDIF
              NEXT
          ENDIF
        ENDIF
       n_page1:=m_page
      ENDIF

      FOR i:=1 TO n
         IF PrnOnLine()
            @IF(i==1,PROW()+1,PROW()),p_col[i];
            SAY IF(a_width[i]==NIL,EVAL(a_col[i]),LEFT(EVAL(a_col[i]),a_width[i]))
         ELSE
            l_end:=.T.
            EXIT
         ENDIF
      NEXT
   IF l_end
      EXIT
   ENDIF
   m_proc:=DispGauge(m_proc,j++/l)
   IF EVAL(m_browse:skipblock,1)<1.OR.EVAL(b_finish)
      EXIT
   ENDIF
ENDDO
DelGauge(m_proc)
@PROW()+1,0 SAY ""
SETPRC(PROW(),0)
DBGOTO(m_recno);m_line:=n_line;m_page:=n_page
RETURN .t.
Function REM01(m_str)
LOCAL m_str1:="",i:=1,n:=LEN(m_str)
FOR i:=1 TO n
  IF SUBSTR(m_str,i,1)=="~"
    i:=i+1
    LOOP
  ENDIF
  m_str1+=SUBSTR(m_str,i,1)
NEXT
RETURN m_str1
STATIC Function GetNumPage(n1,n2,m_max)
  LOCAL m_screen,GetList:={}
  SET ESCAPE ON
m_screen:=SAVESCREEN(INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50)
  @INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50  BOX B_DOUBLE+" " COLOR "N/BG"
  @INT(MAXROW()/2)-2+1,INT((MAXCOL()-50)/2)+2 SAYDISP     "Номер першої    сторiнки>" COLOR "N/bg"
  @INT(MAXROW()/2)-2+2,INT((MAXCOL()-50)/2)+2 SAYDISP "Номер останньої сторiнки>" COLOR "N/bg"
  n1:=1
  n2:=m_max
  @INT(MAXROW()/2)-2+1,INT((MAXCOL()-50)/2)+2+35 GET n1 PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n1>0.AND.n1<=m_max
  @INT(MAXROW()/2)-2+2,INT((MAXCOL()-50)/2)+2+35 GET n2 PICTURE "9999" COLOR "GR+/bg,gr+/N" VALID n2>=n1.AND.n2<=m_max
      READ
      SET ESCAPE OFF
RESTSCREEN(INT(MAXROW()/2)-2,INT((MAXCOL()-50)/2),INT(MAXROW()/2)-2+3,INT((MAXCOL()-50)/2)+50,m_screen)
      IF LASTKEY()==K_ESC
        RETURN .f.
      ENDIF
RETURN .t.
Function Ms08()
  LOCAL m_file1,m_file2,m_gauge,a_struct:={}
  LOCAL m_mol:="  ",m_ddoc1:=CTOD(""),m_page:=2
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  LOCAL a_shp:=GetShp08(),m_scr1,m_ddoc2:=CTOD(""),l
  DCL MENU
  DCL LIST
// Ввод мат. отв. лица
SET ESCAPE ON
m_scr1:=SAVESCREEN(03,5,08,55)
@03,5,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "Виберiть комiрника i дату iнвентарiзацiї" COLOR "n/w"
@05,10 Get m_mol VALID Sp02->(sp_vl("SP02",,5,15,"_mol(sp02->mol)","GR+/BG")) COLOR  "w+/bg,gr+/n"
m_ddoc1:=BOM(DATE()-10)
@06,10 Get m_ddoc1  COLOR "w+/bg,gr+/N"
READ
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
InitNds()
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
s2+=m_file1+","
FILECOPY(m_workpath+"nakl1.dbf",m_file1)
USE (m_file1) NEW READONLY ALIAS file1
SET FILTER TO file1->vdoc=="1".OR.file1->vdoc=="0"
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"nakl2.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
s2+=m_file1+","+m_file2+","
FILECOPY(m_workpath+"nakl2.ntx",m_file2)
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"spr03.dbf",m_file1)
s2+=m_file1+","
USE (m_file1) NEW READONLY  ALIAS File3
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
s2+=m_file1+","+m_file2+","
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
  USE  (m_vdisk+"Struct") INDEX (m_vdisk+"Struct") NEW READONLY
  struct->(DS("NAKL08"))
  DO WHILE .NOT.struct->(EOF()).AND."NAKL08"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
m_file1:=TEMPFILE(m_mash,"dbf");FERASE(m_file1)
DBCREATE(m_file1,a_struct)
USE (m_file1) NEW ALIAS buf
m_file2:=TEMPFILE(m_mash,"ntx");FERASE(m_file2)
INDEX ON field->kod TO (m_file2)
CLOSE struct
s2+=m_file1+","+m_file2
m_gauge:=InitGauge("Вибiрка сальдо",2)
DO WHILE .NOT.File3->(EOF())
  IF m_mol==file3->mol.AND.mnt_dtod(m_ddoc1)==file3->mnt
    buf->(DS(file3->kod))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->kod:=file3->kod
      kaptka->(DS(buf->kod));buf->name:=kaptka->name
      buf->prise:=kaptka->prise
      buf->izm:=kaptka->izm;buf->izm2:=kaptka->izm2
    ENDIF
    buf->kvo1+=file3->kvo
    IF file3->glv<>0
      l_kvo2:=.t.
      buf->kvo2+=file3->glv
    ENDIF
  ENDIF
  File3->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,File3->(RECNO())/File3->(LASTREC()))
ENDDO
DelGauge(m_gauge)
m_gauge:=InitGauge("Вибiрка iнформацiї з накладних",2)
DO WHILE .NOT.file1->(EOF())
    IF nakl1->ddoc3>=m_ddoc1.AND.nakl1->ddoc3<=m_ddoc2.AND..not.IsBit(ASC(nakl1->state),3)
      IF ((nakl1->vdoc=="0".AND.nakl1->otp==m_mol).OR.(nakl1->vdoc<>"0".AND.(nakl1->otp==m_mol.or.nakl1->mol==m_mol)))
    file2->(DS(file1->vnum))
    DO WHILE .NOT.file2->(EOF()).AND.file2->vnum==file1->vnum
        IF (file1->vdoc>="1".AND.file1->otp==m_mol)
          buf->(DS(file2->kod))
          IF .NOT.buf->(FOUND())
            buf->(DBAPPEND())
            buf->kod:=file2->kod
            kaptka->(DS(buf->kod));buf->name:=kaptka->name
            buf->prise:=kaptka->prise
            buf->izm:=kaptka->izm
          ENDIF
          buf->kvo1-=file2->kvo
          buf->sum -=file2->stm1
          IF file2->glv<>0
            l_kvo2:=.t.
            buf->kvo2-=file2->glv
          ENDIF
        ELSE
          IF file1->vdoc=="0"
            buf->sum +=file2->stm
          ELSE
            buf->sum +=file2->stm1
          ENDIF
          buf->kvo1+=file2->kvo
          IF file2->glv<>0
            l_kvo2:=.t.
            buf->kvo2+=file2->glv
          ENDIF
        ENDIF
      file2->(DBSKIP())
    ENDDO
  ENDIF
  ENDIF
  File1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,file1->(RECNO())/file1->(LASTREC()))
ENDDO
DelGauge(m_gauge)
 CLOSE BASE file1,File2,File3,Kaptka
// CLOSE BASE file1,File2,File3
select buf
buf->(DBGOTOP())
i:=0;j:=1
DO WHILE .NOT.buf->(EOF())
      IF buf->kvo1==0.AND.buf->kvo2==0.AND.buf->sum==0
        buf->(DBDELETE())
        j++
      ENDIF
  buf->sum:=buf->kvo1*buf->prise*(1+ReadNds())
  buf->(DBSKIP())
ENDDO
buf->(DBGOTOP())
m_gauge:=InitGauge("Вивiд iнвентарного опису",2)
SET PRINTER TO (m_workpath+"08.txt")
SET DEVICE TO PRINTER
SETPRC(0,0)
i:=0
// вивiд шапки
@PROW()+2,0 SAY ;
PADR(pred01->short,40)+"         Форма N iнв-3"
@PROW()+2,0 SAY ;
" ИНВЕНТАРIЗАЦIОНИЙ ОПИС ТОВАРНО-МАТЕРIАЛЬНИХ ЦIННОСТЕЙ"
@PROW()+2,0 SAY ;
"            ┌──────────┬────────────┬─────────────────────┐"
@PROW()+1,0 SAY ;
"            │ Номер    │ Дата       │ Матерiально-        │"
@PROW()+1,0 SAY ;
"            │документа │cкладання   │ вiдповiдальна особа │"
@PROW()+1,0 SAY ;
"            ├──────────┼────────────┼─────────────────────┤"
@PROW()+1,0 SAY ;
"            │          │            │"+LEFT(PADR(ALLTRIM(_mol(m_mol)),21),21)+"│"
@PROW()+1,0 SAY ;
"            └──────────┴────────────┴─────────────────────┘"
@PROW()+3,0 SAY ;
CHR(27)+"3-                        Р О З П И С К А"
@PROW()+1,0 SAY ;
"     До  початку  проведення  iнвентарiзацiї всi витратнi i при-"
@PROW()+1,0 SAY ;
"ходнi документи на товарно-матерiальнi цiнностi здани до бухгал-"
@PROW()+1,0 SAY ;
"терiї  i усi  товарно-матерiальнi  цiнностi,  що надiйшли на мою"
@PROW()+1,0 SAY ;
"(нашу) вiдповiдальнiсть,  оприходуванi, а тi, що вибули, списанi"
@PROW()+1,0 SAY ;
"на витрату."
@PROW()+2,0 SAY ;
"     Матерiально-вiдповiдальна  особа :"
Sp02->(DS(m_mol))
@PROW()+1,0 SAY ;
"_________________   ______________ "+CHR(27)+"M"+CHR(27)+"-1"+ALLTRIM(_fiofull(sp02->tabn))+CHR(27)+"-0"+CHR(27)+"P"
@PROW()+1,0 SAY ;
"   посада             пiдпис         iм'я, по батьковi,фамiлiя"
@PROW()+6,0 SAY ;
'На основi приказу (розпорядження) вiд "____"___________________199  г.'
@PROW()+1,0 SAY ;
"N______ виконана перевiрка фактичних залишкiв цiнностей"
@PROW()+1,0 SAY ;
'по стану на "____"________________199  г.'
@PROW()+1,0 SAY ;
'     Iнвентаризацiя: почата    "____"________________199  г.'
@PROW()+1,0 SAY ;
'                     завершена "____"________________199  г.'
@PROW()+2,0 SAY ;
'     При iнвентарiзацiї встановлено наступне:'+chr(27)+"2"
@PROW()+5,0 SAY CHR(27)+CHR(15)
@PROW()+1,0 SAY ""
SETPRC(GetEndPage()+1,0)
IF GetParPrn(4)==2
  FOR i:=1 TO LEN(a_shp)
    a_shp[i]:=CHARREPL("┌│├└┼┴┬─┘┤┐",a_shp[i],"-||-|----||")
  NEXT
ENDIF
k:=l:=0
DO WHILE .NOT.buf->(EOF())
  IF PROW()>GetEndPage()
    StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
    SETPRC(0,0)
    IF GetparPrn(N_PAPER)==2.AND.EMPTY(SET(_SET_PRINTFILE)) //ЛИСТЫ
      WaitMessage("Заправте лист N "+STR(m_page,3)+";и натиснить любу клавiшу")
    ENDIF
    IF PrnOnLine()
      @0,116 SAY "Сторiнка "+STR(m_page,3)
      FOR i:=1 TO LEN(a_shp)
        IF PrnOnLine()
            @PROW()+1,0  SAY a_shp[i]
        ELSE
            EXIT
        ENDIF
      NEXT
    ENDIF
   ENDIF
  m_gauge:=DispGauge(m_gauge,j++/buf->(LASTREC()))
  k++
  @PROW()+1,0 SAY k PICTURE "9999"
  @PROW(),5   SAY buf->kod
  @PROW(),16 SAY LEFT(Buf->name,34)
  @PROW(),52 SAY Buf->izm PICTURE "XXXXXX"
  @PROW(),59 SAY Buf->prise PICTURE "999999999.999"
  @PROW(),97 SAY Buf->kvo1 PICTURE "99999999999.99"
  @PROW(),112 SAY Buf->sum PICTURE "999999999999.99"
  l+=Buf->sum
  buf->(DBSKIP())
ENDDO
DelGauge(m_gauge)
@PROW()+1,0 SAY ;
"──────────────────────────────────────────────────────────────┬─────────────────────────────────────┬──────────────────────────────"
@PROW()+1,0 SAY ;
"                                                              │       РАЗОМ  :                      │"
@PROW(),112 SAY l PICTURE "999999999999.99"
@PROW()+1,0 SAY ;
"                                                              └─────────────────────────────────────┴──────────────────────────────"
StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
@PROW()+1,0 SAY ;
CHR(18)+CHR(27)+"3-                                                        Сторiнка " + STR(m_page+1,3)
@PROW()+1,0 SAY ;
"Разом по опису: кiлькiсть порядкових номерiв  ______________________________"
@PROW()+1,0 SAY ;
"                                                           прописом"
@PROW()+1,0 SAY ;
"              загальна кiлькiсть одиниць фактично  _________________________"
@PROW()+1,0 SAY ;
"                                                           прописом"
@PROW()+1,0 SAY ;
"____________________________________________________________________________"
@PROW()+1,0 SAY ;
"                на суму, грв., фактично  ___________________________________"
@PROW()+1,0 SAY ;
"                                                           прописом"
@PROW()+1,0 SAY ;
"____________________________________________________________________________"
@PROW()+1,0 SAY ;
"____________________________________________________________________________"
@PROW()+1,0 SAY ;
"____________________________________________________________________________"
@PROW()+2,0 SAY ;
"Голова  комiсiї"
@PROW()+1,0 SAY ;
"_________________       ___________________      _________________________"
@PROW()+1,0 SAY ;
"    посада                  пiдпис               iм'я, по батьковi,фамiлiя"
@PROW()+1,0 SAY ;
"Члени комiсiї:"
@PROW()+1,0 SAY ;
"_________________   ___________________   _________________________"
@PROW()+1,0 SAY ;
"    посада                  пiдпис        iм'я, по батьковi,фамiлiя"
@PROW()+1,0 SAY ;
"_________________   ___________________   _________________________"
@PROW()+1,0 SAY ;
"    посада                  пiдпис        iм'я, по батьковi,фамiлiя"
@PROW()+1,0 SAY ;
"_________________   ___________________   _________________________"
@PROW()+1,0 SAY ;
"    посада                  пiдпис        iм'я, по батьковi,фамiлiя"
@PROW()+2,0 SAY ;
"     Все  цiнностi ,  перелiкованi в данному iнвентарiзацiонному"
@PROW()+1,0 SAY ;
"опису  N_________  ,  комiсiєю перевiренi в моїй (нашiй) присут-"
@PROW()+1,0 SAY ;
"ностi i внесенi до опису, в зв'язку з чим претензiй к iнвентарi-"
@PROW()+1,0 SAY ;
"зацiоннiй  комiсiї не маю (не маємо).  Цiнностi,  перелiкованi в"
@PROW()+1,0 SAY ;
"опису, знаходяться на моїй (нашому) вiдповiдальному збереженнi."
@PROW()+2,0 SAY ;
"     Матерiально-вiдповiдальна  особа :"
@PROW()+2,0 SAY ;
'  "____"________________199  г.'
@PROW()+2,0 SAY ;
" Указаннi в данному опису данi i пiдрахунки перевiрил"
@PROW()+1,0 SAY ;
"                      _________________       ___________________"
@PROW()+1,0 SAY ;
"                            посада                   пiдпис"
@PROW()+1,0 SAY ;
'  "____"________________199  г.'

SET PRINTER TO
SET DEVICE TO SCREEN
CLOSE BASE buf
n:=NumToken(s2,",")
FOR i:=1 TO n
  FERASE(TOKEN(s2,",",i))
NEXT
RESTSCREEN(03,5,08,55,m_scr1)
RETURN .t.
STATIC FUNCTION GetShp08()
LOCAL a_shp:={},m_str,i,n
  Screen->(DS("SHP008"))
n:=MLCOUNT(screen->vd,254)
FOR i:=1 To n
  AADD(a_shp,RTRIM(MEMOLINE(screen->vd,254,i)))
NEXT
RETURN a_shp
Function Ms22()
  LOCAL m_file1,m_file2,m_gauge,a_struct:={},l_mode,m_level1,m_level2
  LOCAL m_mol:="  ",m_ddoc1:=BOY(),m_ddoc2:=EOM(DATE()-15)
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3,m_poisk
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  DCL MENU
  DCL LIST
SET ESCAPE ON
@03,5,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "Виберiть перiод розрахунку" COLOR "n/w"
@05,10 Get m_ddoc1  COLOR "w+/bg,gr+/N"
@05,20 Get m_ddoc2  COLOR "w+/bg,gr+/N" VALID m_ddoc2>=m_ddoc1
READ
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
NET USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") NEW ALIAS myvar
m_level1:=RestVar1("m_level1","NK")
CLOSE myvar
m_level2:=MONTH(m_ddoc2)*m_level1
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
s2+=m_file1+","
FILECOPY(m_workpath+"nakl1.dbf",m_file1)
USE (m_file1) NEW READONLY ALIAS file1
SET FILTER TO file1->vdoc=="1".OR.file1->vdoc=="0"
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"nakl2.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
s2+=m_file1+","+m_file2+","
FILECOPY(m_workpath+"nakl2.ntx",m_file2)
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"nakl3.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
s2+=m_file1+","+m_file2+","
FILECOPY(m_workpath+"nakl3.ntx",m_file2)
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File3
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
s2+=m_file1+","+m_file2+","
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
USE  (m_vdisk+"Struct") INDEX (m_vdisk+"Struct") NEW READONLY
struct->(DS("NAKL22"))
  DO WHILE .NOT.struct->(EOF()).AND."NAKL22"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
m_file1:=TEMPFILE(m_mash,"dbf");FERASE(m_file1)
DBCREATE(m_file1,a_struct)
USE (m_file1) NEW ALIAS buf
m_file2:=TEMPFILE(m_mash,"ntx");FERASE(m_file2)
// INDEX ON field->tabn+field->kod+field->ndoc TO (m_file2)
INDEX ON field->indkod TO (m_file2)
CLOSE struct
s2+=m_file1+","+m_file2
m_gauge:=InitGauge("Вибiрка iнформацiї з накладних",2)
//buf->(DBAP())
// buf->indkod:=REPLICATE(CHR(255),4+10+6)
DO WHILE .NOT.file1->(EOF())
  IF file1->ddoc<=m_ddoc2.AND.file1->ddoc>=m_ddoc1;
    .AND.(NumPotr(file1->kopr)=="0".OR.NumPotr(file1->kopr)=="5").AND.file1->kod1=="З ";
    .AND..NOT.Isbit(Asc(file1->state),3)
    file2->(DS(file1->vnum))
    l_mode:=IF(file1->ddoc>=BOM(m_ddoc2),.t.,.f.)
    IF NumPotr(file1->kopr)<>"5"
      DO WHILE .NOT.file2->(EOF()).AND.file2->vnum==file1->vnum
        IF file1->ddoc>=BOM(m_ddoc2)
          buf->(DBAPPEND())
          buf->indkod:=file1->tabn+File2->kod+file1->ndoc
//          buf->tabn:=file1->tabn
          buf->ndoc:=file1->ndoc
          buf->name:=""
          buf->kod :=file2->kod
          buf->kvo1:=file2->kvo
          IF file2->nds==0
            buf->sum01m:=file2->stm
          ELSE
            buf->sum03m:=file2->stm+file2->nds
          ENDIF
        ENDIF
        // по коду продукцiї
          SeekBf22a(file1->tabn,File2->kod,REPLICATE(CHR(255),6))
          SumStm22(l_mode);Sumkvo22(l_mode)
        // по таб. номеру
          SeekBf22b(file1->tabn,REPLICATE(CHR(255),10),REPLICATE(CHR(255),6))
          SumStm22(l_mode)
        // по коду продукцiї по пiдприємству
          SeekBf22c(REPLICATE(CHR(255),4),File2->kod,REPLICATE(CHR(255),6))
          SumStm22(l_mode);Sumkvo22(l_mode)
        // по пiдприємству
          SeekBf22d(REPLICATE(CHR(255),4),REPLICATE(CHR(255),10),REPLICATE(CHR(255),6))
          SumStm22(l_mode)
          file2->(DBSKIP())
      ENDDO
    ELSE
        File3->(DS(File1->vnum))
        DO WHILE .NOT.File3->(EOF()).AND.File1->vnum==File3->vnum
          IF file1->ddoc>=BOM(m_ddoc2)
            buf->(DBAPPEND())
            buf->indkod:=file3->tabn+File2->kod+file1->ndoc
  //          buf->tabn:=file3->tabn
            buf->ndoc:=file1->ndoc
            buf->name:=""
            buf->kod :=file2->kod
            buf->kvo1:=file3->kvo
            IF file3->nds==0
              buf->sum01m:=file3->stm
            ELSE
              buf->sum03m:=file3->stm+file3->nds
            ENDIF
          ENDIF
        // по коду продукцiї
          SeekBf22a(file3->tabn,File2->kod,REPLICATE(CHR(255),6))
          SumSt22a(l_mode);Sumkv22a(l_mode)
        // по таб. номеру
          SeekBf22b(file3->tabn,REPLICATE(CHR(255),10),REPLICATE(CHR(255),6))
          SumSt22a(l_mode)
        // по коду продукцiї по пiдприємству
          SeekBf22c(REPLICATE(CHR(255),4),File2->kod,REPLICATE(CHR(255),6))
          SumSt22a(l_mode);Sumkv22a(l_mode)
        // по пiдприємству
          SeekBf22d(REPLICATE(CHR(255),4),REPLICATE(CHR(255),10),REPLICATE(CHR(255),6))
          SumSt22a(l_mode)
          file3->(DBSKIP())
        ENDDO
    ENDIF
  ENDIF
  File1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,file1->(RECNO())/file1->(LASTREC()))
ENDDO
DelGauge(m_gauge)
CLOSE BASE file1,File2,File3,Kaptka

select buf
i:=0;j:=0
buf->(DBGOTOP())
DO WHILE .NOT.buf->(EOF())
 IF buf->clr=="3"
    IF buf->sum01m>m_level1
      buf->sum02m:=buf->sum01m-m_level1
      i+=buf->sum02m
    ENDIF
    IF buf->sum01y>m_level2
      buf->sum02y:=buf->sum01y-m_level2
      j+=buf->sum02y
      buf->clr:="4"
    ENDIF
  ENDIF
  buf->(DBSKIP())
ENDDO
buf->(DS(REPLICATE(CHR(255),4)+REPLICATE(CHR(255),10)+REPLICATE(CHR(255),6)))
buf->sum02m:=i
buf->sum02y:=j
buf->(DBGOTOP())
s1:="Звiт по одерж. прод. в рахунок зар.платнi ";
+";~1за перiод з ~2"+My_Dtos(m_ddoc1)+" ~1по ~2"+My_Dtos(m_ddoc2)
s3:="NAKL22"
ViewMs(s3,s1)
CLOSE BASE buf
n:=NumToken(s2,",")
/*
FOR i:=1 TO n-2
  FERASE(TOKEN(s2,",",i))
NEXT
*/
IF ALERT("Зберiгати машинограму?",{"Нi","Так"},"n/bg,gr+/b")==2
  STRFILE(PADR(s1,160)+PADR(s3,10)+PADR(TOKEN(TOKEN(s2,",",n),"\:"),12)+"ьь",TOKEN(s2,",",n-1),.t.)
ELSE
  FERASE(TOKEN(s2,",",n-1));FERASE(TOKEN(s2,",",n))
ENDIF
RETURN .t.
STATIC FUNCTION SeekBf22a(x1,x2,x3)
IF .NOT.buf->(DS(x1+x2+x3))
  buf->(DBAP())
  buf->clr:="2"
  buf->indkod:=x1+x2+x3
  buf->tabn:="  По"
  buf->kod:=x2
  kaptka->(DS(x2))
  buf->name:=kaptka->name
ENDIF
RETURN .t.
STATIC FUNCTION SeekBf22b(x1,x2,x3)
IF .NOT.buf->(DS(x1+x2+x3))
  buf->(DBAP())
  buf->clr:="3"
  buf->indkod:=x1+x2+x3
  buf->tabn:=x1
  buf->name:=_fio(x1)
ENDIF
RETURN .t.
STATIC FUNCTION SeekBf22c(x1,x2,x3)
IF .NOT.buf->(DS(x1+x2+x3))
  buf->(DBAP())
  buf->clr:="5"
  buf->indkod:=x1+x2+x3
  buf->tabn:=" По "
  buf->kod:=x2
  kaptka->(DS(x2))
  buf->name:=kaptka->name
ENDIF
RETURN .t.
STATIC FUNCTION SeekBf22d(x1,x2,x3)
IF .NOT.buf->(DS(x1+x2+x3))
  buf->(DBAP())
  buf->clr:="9"
  buf->indkod:=x1+x2+x3
  buf->tabn:="По  "
  buf->name:="пiдприємству"
ENDIF
RETURN .t.
STATIC Function Sumstm22(mode)
IF mode
  IF file2->nds==0
    buf->sum01m+=file2->stm
  ELSE
    buf->sum03m+=file2->stm+file2->nds
  ENDIF
  buf->sum04m+=file2->stm+file2->nds
ENDIF
  IF file2->nds==0
    buf->sum01y+=file2->stm
  ELSE
    buf->sum03y+=file2->stm+file2->nds
  ENDIF
  buf->sum04y+=file2->stm+file2->nds
RETURN .t.
STATIC Function Sumkvo22(mode)
IF mode
  buf->kvo1+=file2->kvo
ENDIF
  buf->kvo2+=file2->kvo
RETURN .t.
STATIC Function Sumst22a(mode)
IF mode
  IF file3->nds==0
    buf->sum01m+=file3->stm
  ELSE
    buf->sum03m+=file3->stm+file3->nds
  ENDIF
  buf->sum04m+=file3->stm+file3->nds
ENDIF
  IF file3->nds==0
    buf->sum01y+=file3->stm
  ELSE
    buf->sum03y+=file3->stm+file3->nds
  ENDIF
  buf->sum04y+=file3->stm+file3->nds
RETURN .t.
STATIC Function Sumkv22a(mode)
IF mode
  buf->kvo1+=file3->kvo
ENDIF
  buf->kvo2+=file3->kvo
RETURN .t.

Function Ms23
LOCAL m_gauge,m_ddoc1,m_ddoc2,a_struct:={},GetList:={},i,n
LOCAL m_file1,m_file2,m_indcod,s1:="",s2:="",s3:=""
SET ESCAPE ON
@03,5,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "Виберiть перiод розрахунку" COLOR "n/w"
m_ddoc1:=BOM(DATE()-10)
@06,10 Get m_ddoc1  COLOR "w+/bg,gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
@06,20 Get m_ddoc2  COLOR "w+/bg,gr+/N" VALID m_ddoc2>=m_ddoc1
READ
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF

m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
s2+=m_file1+","
FILECOPY(m_workpath+"nalog1.dbf",m_file1)
USE (m_file1) NEW READONLY ALIAS file1
SET FILTER TO file1->vdoc=="1".OR.file1->vdoc=="0"
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"nalog2.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
s2+=m_file1+","+m_file2+","
FILECOPY(m_workpath+"nalog2.ntx",m_file2)
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
s2+=m_file1+","+m_file2+","
USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
  USE  (m_vdisk+"Struct") INDEX (m_vdisk+"Struct") NEW READONLY
  struct->(DS("NAKL23"))
  DO WHILE .NOT.struct->(EOF()).AND."NAKL23"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
m_file1:=TEMPFILE(m_mash,"dbf");FERASE(m_file1)
DBCREATE(m_file1,a_struct)
USE (m_file1) NEW ALIAS buf
m_file2:=TEMPFILE(m_mash,"ntx");FERASE(m_file2)
INDEX ON field->indcod TO (m_file2)
CLOSE struct
s2+=m_file1+","+m_file2
m_gauge:=InitGauge("Вибiрка iнформацiї з податкових накладних",2)
DO WHILE .NOT.file1->(EOF())
  IF file1->ddoc<=m_ddoc2.AND.file1->ddoc>=m_ddoc1
    file2->(DS(file1->vnum))
    DO WHILE .NOT.file2->(EOF()).AND.file2->vnum==file1->vnum
        Kaptka->(DS(File2->kod))
        buf->(DBAPPEND())
        buf->ndoc:=file1->ndoc
        buf->kod:=file2->kod
        buf->stm:=file2->Sum1+file2->Sum2+file2->Sum3+file2->sum4+file2->nds
        buf->kvo:=File2->kvo
        buf->nds:=file2->nds
        m_indcod:=kaptka->ksash2+File2->kod+file1->ndoc
        buf->indcod:=m_indcod

        m_indcod:=kaptka->ksash2+File2->kod+REPLICATE(CHR(255),6)
        IF .NOT.buf->(DS(m_indcod))
          buf->(DBAP())
          buf->indcod:=m_indcod
          buf->ndoc:="По коду"
          buf->name:=Kaptka->name
          buf->kod:=file2->kod
          buf->clr:="2"
        ENDIF
        buf->kvo+=File2->kvo
        buf->stm+=file2->Sum1+file2->Sum2+file2->Sum3+file2->sum4+file2->nds
        buf->nds+=file2->nds

        m_indcod:=kaptka->ksash2+REPLICATE(CHR(255),16)
        Sp07->(DS(kaptka->ksash2))
        IF .NOT.buf->(DS(m_indcod))
          buf->(DBAP())
          buf->indcod:=m_indcod
          buf->ndoc:="По рах."
          buf->kod:=kaptka->ksash2
          buf->name:=Sp07->naim7
          buf->clr:="3"
        ENDIF
        buf->kvo+=File2->kvo
        buf->stm+=file2->Sum1+file2->Sum2+file2->Sum3+file2->sum4+file2->nds
        buf->nds+=file2->nds

        m_indcod:=LEFT(kaptka->ksash2,3)+REPLICATE(CHR(255),19)
        Sp07->(DS(LEFT(kaptka->ksash2,3)+"000"))
        IF .NOT.buf->(DS(m_indcod))
          buf->(DBAP())
          buf->indcod:=m_indcod
          buf->ndoc:="По субрах."
          buf->kod:=LEFT(kaptka->ksash2,3)
          buf->name:=Sp07->naim7
          buf->clr:="4"
        ENDIF
        buf->stm+=file2->Sum1+file2->Sum2+file2->Sum3+file2->sum4+file2->nds
        buf->nds+=file2->nds

        m_indcod:=CHR(255)+LEFT(File1->form,21)
        IF .NOT.buf->(DS(m_indcod))
          buf->(DBAP())
          buf->indcod:=m_indcod
          buf->ndoc:="  По "
          buf->name:=File1->form
          buf->clr:="5"
        ENDIF
        buf->stm+=file2->Sum1+file2->Sum2+file2->Sum3+file2->sum4+file2->nds
        buf->nds+=file2->nds

        m_indcod:=REPLICATE(CHR(255),22)
        IF .NOT.buf->(DS(m_indcod))
          buf->(DBAP())
          buf->indcod:=m_indcod
          buf->ndoc:="РАЗОМ"
          buf->clr:="6"
        ENDIF
        buf->stm+=file2->Sum1+file2->Sum2+file2->Sum3+file2->sum4+file2->nds
        buf->nds+=file2->nds

      file2->(DBSKIP())
    ENDDO
  ENDIF
  File1->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,file1->(RECNO())/file1->(LASTREC()))
ENDDO
DelGauge(m_gauge)
CLOSE BASE file1,File2,Kaptka
s1:="Звiт по податкових накладних за перiод з ~2"+My_Dtos(m_ddoc1)+" ~1по ~2"+My_Dtos(m_ddoc2)
s3:="NAKL23"
ViewMs(s3,s1)
CLOSE BASE buf
n:=NumToken(s2,",")
FOR i:=1 TO n-2
  FERASE(TOKEN(s2,",",i))
NEXT
IF ALERT("Зберiгати машинограму?",{"Нi","Так"},"n/bg,gr+/b")==2
  STRFILE(PADR(s1,160)+PADR(s3,10)+PADR(TOKEN(TOKEN(s2,",",n),"\:"),12)+"ьь",TOKEN(s2,",",n-1),.t.)
ELSE
  FERASE(TOKEN(s2,",",n-1));FERASE(TOKEN(s2,",",n))
ENDIF
RETURN .t.

Function Get001(m_mol,m_ddoc1,m_ddoc2)
  LOCAL GetList:={}
// Ввод мат. отв. лица
SET ESCAPE ON
@03,5,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "Виберiть комiрника i перiод розрахунку" COLOR "n/w"
@05,10 Get m_mol VALID Sp02->(sp_vl("SP02",,5,15,"_mol(sp02->mol)","GR+/BG")) COLOR  "w+/bg,gr+/n"
m_ddoc1:=BOM(DATE()-10)
@06,10 Get m_ddoc1  COLOR "w+/bg,gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
@06,20 Get m_ddoc2  COLOR "w+/bg,gr+/N" VALID m_ddoc2>=m_ddoc1
READ
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
RETURN .t.
Function Get002(m_ddoc1,m_ddoc2)
  LOCAL GetList:={}
// Ввод мат. отв. лица
SET ESCAPE ON
@03,5,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "        Виберiть перiод розрахунку" COLOR "n/w"
m_ddoc1:=BOM(DATE()-10)
@05,10 Get m_ddoc1  COLOR "w+/bg,gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
@05,20 Get m_ddoc2  COLOR "w+/bg,gr+/N" VALID m_ddoc2>=m_ddoc1
READ
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
RETURN .t.
#undef  ITOG1
#undef  ITOG0
#define ITOG1 REPLICATE(CHR(255),5)+" "
#define ITOG0 REPLICATE(CHR(255),6)
Function Ms09()
  LOCAL m_file1,m_file2,m_gauge,a_struct:={}
  LOCAL m_mol:="  ",m_ddoc1:=CTOD(""),m_ddoc2:=CTOD("")
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  LOCAL n_file1,n_file2,n_kapt,n_file3
  DCL MENU
  DCL LIST
IF .not.Get002(@m_ddoc1,@m_ddoc2)
  RETURN .f.
ENDIF
IF NETDISK(LEFT(m_workpath,1))
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  s2+=m_file1+","
  FILECOPY(m_workpath+"nakl1.dbf",m_file1)
  USE (m_file1) NEW READONLY ALIAS file1
  n_file1:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"nakl2.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  s2+=m_file1+","+m_file2+","
  FILECOPY(m_workpath+"nakl2.ntx",m_file2)
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
  n_file2:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"spr03.dbf",m_file1)
  s2+=m_file1+","
  USE (m_file1) NEW READONLY  ALIAS File3
  n_file3:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
  s2+=m_file1+","+m_file2+","
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
  n_kapt:=SELECT()
ELSE
  n_file1:=SELECT("NAKL1")
  n_file2:=SELECT("NAKL2")
  USE (m_workpath+"spr03.dbf") NEW  ALIAS File3
  n_file3:=SELECT()
  n_kapt:=SELECT("KAPTKA1")
ENDIF

  USE  (m_vdisk+"Struct") INDEX (m_vdisk+"Struct") NEW READONLY
  struct->(DS("NAKL09"))
  DO WHILE .NOT.struct->(EOF()).AND."NAKL09"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
m_file1:=TEMPFILE(m_mash,"dbf");FERASE(m_file1)
DBCREATE(m_file1,a_struct)
USE (m_file1) NEW ALIAS buf
m_file2:=TEMPFILE(m_mash,"ntx");FERASE(m_file2)
INDEX ON field->kod+field->mol TO (m_file2)
CLOSE struct
s2+=m_file1+","+m_file2
m_gauge:=InitGauge("Вибiрка сальдо",2)
buf->(DBAP())
buf->kod:=ITOG1;buf->name:="РАЗОМ";buf->clr:="3"
buf->(DBAP())
buf->kod:=ITOG0;buf->name:="КIЛЬКIСТЬ ДОКУМ.";buf->clr:="4"
DO WHILE .NOT.(n_file3)->(EOF())
  IF mnt_dtod(m_ddoc1)==(n_file3)->mnt
    IF .NOT.buf->(DS((n_file3)->kod+(n_file3)->mol))
      buf->(DBAP())
      buf->kod:=(n_file3)->kod
      buf->clr:="1"
      buf->mol:=(n_file3)->mol
      buf->name:=_mol(buf->mol)
    ENDIF
    buf->inkvo1+=(n_file3)->kvo
    buf->outkvo1+=(n_file3)->kvo
    IF (n_file3)->glv<>0
      l_kvo2:=.t.
      buf->inkvo2+=(n_file3)->glv
      buf->outkvo2+=(n_file3)->glv
    ENDIF
    buf->insum+=(n_file3)->stm
    buf->outsum+=(n_file3)->stm
    IF .NOT.buf->(DS((n_file3)->kod+CHR(255)+CHR(255)))
      buf->(DBAP())
      buf->kod:=(n_file3)->kod
      buf->clr:="2"
      buf->mol:=CHR(255)+CHR(255)
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->inkvo1+=(n_file3)->kvo
    buf->outkvo1+=(n_file3)->kvo
    IF (n_file3)->glv<>0
      l_kvo2:=.t.
      buf->inkvo2+=(n_file3)->glv
      buf->outkvo2+=(n_file3)->glv
    ENDIF
    buf->insum+=(n_file3)->stm
    buf->outsum+=(n_file3)->stm
    buf->(DBGOTO(1));buf->insum+=(n_file3)->stm;buf->outsum+=(n_file3)->stm
  ENDIF
  (n_file3)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file3)->(RECNO())/(n_file3)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
NET USE (m_workpath+"NAKL5") new
m_gauge:=InitGauge("Вибiрка даних по переводу ",2)
DO WHILE .NOT.nakl5->(EOF())
  IF nakl5->ddoc>=m_ddoc1.AND.nakl5->ddoc<=m_ddoc2  //.AND.nakl5->mol==m_mol

    IF .NOT.buf->(DS(nakl5->cod2+nakl5->mol))
      buf->(DBAP())
      buf->kod:=nakl5->cod2
      buf->clr:="1"
      buf->mol:=nakl5->mol
      buf->name:=_mol(buf->mol)
    ENDIF
    buf->dbkvo1+=nakl5->kvo
    buf->outkvo1+=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->dbkvo2+=nakl5->glv
      buf->outkvo2+=nakl5->glv
    ENDIF
    buf->dbsum+=nakl5->stm
    buf->outsum+=nakl5->stm
    IF .NOT.buf->(DS(nakl5->cod2+CHR(255)+CHR(255)))
      buf->(DBAP())
      buf->kod:=nakl5->cod2
      buf->clr:="2"
      buf->mol:=CHR(255)+CHR(255)
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->dbkvo1+=nakl5->kvo
    buf->outkvo1+=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->dbkvo2+=nakl5->glv
      buf->outkvo2+=nakl5->glv
    ENDIF
    buf->dbsum+=nakl5->stm
    buf->outsum+=nakl5->stm
    buf->(DBGOTO(1));buf->dbsum+=nakl5->stm;buf->outsum+=nakl5->stm

    IF .NOT.buf->(DS(nakl5->cod1+nakl5->mol))
      buf->(DBAP())
      buf->kod:=nakl5->cod1
      buf->clr:="1"
      buf->mol:=nakl5->mol
      buf->name:=_mol(buf->mol)
    ENDIF
    buf->crkvo1+=nakl5->kvo
    buf->outkvo1+=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->crkvo2+=nakl5->glv
      buf->outkvo2+=nakl5->glv
    ENDIF
    buf->crsum+=nakl5->stm
    buf->outsum-=nakl5->stm
    IF .NOT.buf->(DS(nakl5->cod1+CHR(255)+CHR(255)))
      buf->(DBAP())
      buf->kod:=nakl5->cod1
      buf->clr:="2"
      buf->mol:=CHR(255)+CHR(255)
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->prise:=(n_kapt)->prise
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->crkvo1+=nakl5->kvo
    buf->outkvo1-=nakl5->kvo
    IF nakl5->glv<>0
      l_kvo2:=.t.
      buf->crkvo2+=nakl5->glv
      buf->outkvo2-=nakl5->glv
    ENDIF
    buf->crsum+=nakl5->stm
    buf->outsum-=nakl5->stm
    buf->(DBGOTO(1));buf->crsum+=nakl5->stm;buf->outsum-=nakl5->stm
  ENDIF
  nakl5->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,NAKL5->(RECNO()/LASTREC()))
ENDDO
CLOSE nakl5
DelGauge(m_gauge)

m_gauge:=InitGauge("Вибiрка iнформацiї з накладних",2)
(n_file1)->(DBGOTOP())
DO WHILE .NOT.(n_file1)->(EOF())
    IF (n_file1)->ddoc3>=m_ddoc1.AND.(n_file1)->ddoc3<=m_ddoc2.AND..not.IsBit(ASC((n_file1)->state),3).AND.IsBit(ASC((n_file1)->state),2)
      IF .NOT.IsUslug((n_file1)->kopr)
        (n_file2)->(DS((n_file1)->vnum))
        DO WHILE .NOT.(n_file2)->(EOF()).AND.(n_file2)->vnum==(n_file1)->vnum
            IF .NOT.buf->(DS((n_file2)->kod+(n_file1)->otp))
              buf->(DBAP())
              buf->kod:=(n_file2)->kod
              buf->mol:=(n_file1)->otp
              buf->name:=_mol(buf->mol)
              buf->clr:="1"
            ENDIF
            IF (n_file1)->vdoc>="1"
              buf->crkvo1+=(n_file2)->kvo
              buf->outkvo1-=(n_file2)->kvo
              IF (n_file2)->glv<>0
                l_kvo2:=.t.
                buf->crkvo2+=(n_file2)->glv
                buf->outkvo2-=(n_file2)->glv
              ENDIF
              buf->crsum+=(n_file2)->stm1
              buf->outsum-=(n_file2)->stm1

              IF (n_file1)->kod1=="М "
                IF .NOT.buf->(DS((n_file2)->kod+(n_file1)->mol))
                  buf->(DBAP())
                  buf->kod:=(n_file2)->kod
                  buf->mol:=(n_file1)->mol
                  buf->clr:="1"
                  buf->name:=_mol(buf->mol)
                ENDIF
                buf->dbkvo1+=(n_file2)->kvo
                buf->outkvo1+=(n_file2)->kvo
                IF (n_file2)->glv<>0
                  l_kvo2:=.t.
                  buf->dbkvo2+=(n_file2)->glv
                  buf->outkvo2+=(n_file2)->glv
                ENDIF
                buf->dbsum+=(n_file2)->stm1
                buf->outsum+=(n_file2)->stm1
              ELSE
                IF .NOT.buf->(DS((n_file2)->kod+CHR(255)+CHR(255)))
                  buf->(DBAP())
                  buf->kod:=(n_file2)->kod
                  buf->clr:="2"
                  buf->mol:=CHR(255)+CHR(255)
                  buf->name:=_mol(buf->mol)
                  (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
                  buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
                ENDIF
                buf->crkvo1 +=(n_file2)->kvo
                buf->outkvo1-=(n_file2)->kvo
                buf->crsum  +=(n_file2)->stm1
                buf->outsum -=(n_file2)->stm1
                buf->(DBGOTO(1));buf->crsum+=(n_file2)->stm1;buf->outsum-=(n_file2)->stm1
              ENDIF
            ELSE
                buf->dbkvo1+=(n_file2)->kvo
                buf->outkvo1+=(n_file2)->kvo
                IF (n_file2)->glv<>0
                  l_kvo2:=.t.
                  buf->dbkvo2+=(n_file2)->glv
                  buf->outkvo2+=(n_file2)->glv
                ENDIF
                buf->dbsum+=(n_file2)->stm
                buf->outsum+=(n_file2)->stm
                IF .NOT.buf->(DS((n_file2)->kod+CHR(255)+CHR(255)))
                  buf->(DBAP())
                  buf->kod:=(n_file2)->kod
                  buf->clr:="2"
                  buf->mol:=CHR(255)+CHR(255)
                  buf->name:=_mol(buf->mol)
                  (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
                  buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
                ENDIF
                buf->dbkvo1 +=(n_file2)->kvo
                buf->outkvo1+=(n_file2)->kvo
                buf->dbsum  +=(n_file2)->stm1
                buf->outsum +=(n_file2)->stm1
                buf->(DBGOTO(1));buf->dbsum+=(n_file2)->stm;buf->outsum+=(n_file2)->stm
            ENDIF
      (n_file2)->(DBSKIP())
    ENDDO
  buf->(DBGOTO(2))
  IF (n_file1)->vdoc>="1"
    buf->crkvo1+=1
  ELSE
    buf->dbkvo1+=1
  ENDIF
  ENDIF
  ENDIF
  (n_file1)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file1)->(RECNO())/(n_file1)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
IF NETDISK(LEFT(m_workpath,1))
 CLOSE BASE file1,File2,File3,Kaptka
ELSE
 CLOSE file3
ENDIF
select buf
buf->(DBGOTOP())
buf->(DBGOTOP())
s1:="Звiт по пiдприємству ;за перiод з ~2"+My_Dtos(m_ddoc1)+" ~1по ~2"+My_Dtos(m_ddoc2)
s3:=IF(l_kvo2,"NAKL9","NAKL9A")
ViewMs(s3,s1)
CLOSE BASE buf
n:=NumToken(s2,",")
FOR i:=1 TO n-2
  FERASE(TOKEN(s2,",",i))
NEXT
IF ALERT("Зберiгати машинограму?",{"Нi","Так"},"n/bg,gr+/b")==2
  STRFILE(PADR(s1,160)+PADR(s3,10)+PADR(TOKEN(TOKEN(s2,",",n),"\:"),12)+"ьь",TOKEN(s2,",",n-1),.t.)
ELSE
  FERASE(TOKEN(s2,",",n-1));FERASE(TOKEN(s2,",",n))
ENDIF
RETURN .t.
