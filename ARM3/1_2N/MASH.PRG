#include "new.ch"
MEMVAR m_mash,m_syspath
STATIC n_itog:=1
Function FormMsh(nAlias,m_numA,m_month,m_month1)
  Local a_tabl:={},a_coor:={},i,nSum:=0,nCol,m_margin
  LOCAL j,k,x,m_col,m_gauge1,a_itog:={},n1,l,k1,m
  LOCAL m_num:=LEFT(m_numA,2),m_count:=1,k2,s1,a_fault:={},;
  l_first,n_count,l_finish
DBSELECTAREA(nAlias)
(nAlias)->(DBGOTOP())
IF .NOT.  Pshapka(@a_coor,m_num)
  RETURN .F.
ENDIF
a_tabl:=FormTabl(m_num,nAlias,@nSum)
IF LEN(a_tabl)<>LEN(a_coor)
  DispError("Кiлькiсть стовбцiв в шапцi машинограми "+STR(LEN(a_coor),2)+";не дорiвнює опису ("+STR(LEN(a_tabl),2)+")")
  RETURN .F.
ENDIF
IF( ! msh->(DBSEEK(PADL(ALLTRIM(STR(VAL(m_num))),3))))
  DispError( "Машинограма N "+m_num+" вiдсутня в файлi опису")
  RETURN .f.
ENDIF
m_margin:=msh->p005
k2:=IF(msh->itog==0,1,msh->itog)
a_itog:=FormItog(m_numA,nAlias)
n1:=LEN(a_itog)
m_gauge1:=InitGauge("Вивiд  машинограми N "+m_num,2)
SET PRINTER TO (m_mash+m_num+".txt")
SET DEVICE TO PRINTER
// @PROW()+1,0 SAY n1
FOR j:=1 TO n1
  a_itog[j][2]:=(nAlias)->(EVAL(a_itog[j][1]))
  a_itog[j][3]:=0
//  @PROW()+1,0 SAY j
//  @PROW(),20 SAY a_itog[j][4]

NEXT
DBSELECTAREA(nAlias)
(nAlias)->(DBGOTOP())
DO WHILE .NOT.(nAlias)->(EOF())
  k:=1;nSum:=1
  IF msh->itog==0
  @PROW()+1,0 SAY ""
  a_itog[1][3]+=1
  FOR i:=1 TO LEN(a_tabl)
    DO CASE
      CASE a_tabl[i,4]=='01'.OR.a_tabl[i,4]=='05'
        x:=TRANSFORM((nAlias)->(EVAL(a_tabl[i,1])),a_tabl[i,5])
        IF a_tabl[i,2]<>0
          x:=LEFT(x,a_tabl[i,2])
        ENDIF
        x:=LEFT(x,a_coor[i]-k-1)
        @PROW(),k+m_margin SAY x
      CASE a_tabl[i,4]=='02'
        x:=TRANSFORM((nAlias)->(EVAL(a_tabl[i,1])),a_tabl[i,5])
        IF a_tabl[i,2]<>0
          x:=LEFT(x,a_tabl[i,2])
        ENDIF
        x:=LEFT(x,a_coor[i]-k-1)
        @PROW(),k+m_margin SAY x
      CASE a_tabl[i,4]=='03'
        x:=(nAlias)->(EVAL(a_tabl[i,1]))
        @PROW(),k+m_margin SAY SumToStr(x,a_coor[i]-k-1)
      CASE a_tabl[i,4]=='04'
        x:=(nAlias)->(EVAL(a_tabl[i,1]))
        @PROW(),k+m_margin SAY NumToStr(x,a_coor[i]-k-1,a_tabl[i,2])
    ENDCASE
    k:=a_coor[i]
  NEXT
  ENDIF
  // Суммирование для итогов

  FOR j:=1 TO LEN(a_itog)
//    @PROW()+1,0 SAY j
//    @PROW(),20 SAY n1
//    @PROW(),30 SAY a_itog[j,3]
    IF a_itog[j][4]<>"04"
      FOR l:=1 TO LEN(a_itog[j][5])
        IF VALTYPE(a_itog[j][5][l])=="N"
          a_itog[j][5][l]:=a_itog[j][5][l]+(nAlias)->(EVAL(a_tabl[l,1]))
        ENDIF
      NEXT
    ELSE
      k:=0
      FOR l:=2 TO LEN(a_itog[j][5])
        IF a_itog[j][5][l][n_itog]==(nAlias)->(EVAL(a_tabl[n_itog,1]))
          k:=l
          EXIT
        ENDIF
      NEXT
      IF k==0
        AADD(a_itog[j][5],{})
        k:=LEN(a_itog[j][5])
        FOR l:=1 TO LEN(a_itog[j][5][1])
          AADD(a_itog[j][5][k],a_itog[j][5][1][l])
        NEXT
        FOR l:=1 TO LEN(a_itog[j][5][k])
          IF VALTYPE(a_itog[j][5][k][l])=="N"
              a_itog[j][5][k][l]:=0
          ENDIF
        NEXT
        a_itog[j][5][k][n_itog]:=(nAlias)->(EVAL(a_tabl[n_itog,1]))
      ENDIF
      FOR l:=1 TO LEN(a_itog[j][5][k])
        IF VALTYPE(a_itog[j][5][k][l])=="N"
          a_itog[j][5][k][l]:=a_itog[j][5][k][l]+(nAlias)->(EVAL(a_tabl[l,1]))
          a_itog[j][5][1][l]:=a_itog[j][5][1][l]+(nAlias)->(EVAL(a_tabl[l,1]))
        ENDIF
      NEXT
    ENDIF
  NEXT
  (nAlias)->(DBSKIP())
  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд машинограми ?")==YES
      EXIT
    ENDIF
  ENDIF
  m_gauge1:=DispGauge(m_gauge1,m_count++/(nAlias)->(LASTREC()))

  // подведение итогов

  k1:=0
  FOR j:=LEN(a_itog) TO k2 STEP -1
    IF (nAlias)->(EVAL(a_itog[j][1]))<>a_itog[j][2]
      k1:=j
      EXIT
    ENDIF
  NEXT

  FOR j:=k2 TO k1
    // Вывод итога
    DO CASE
      CASE a_itog[j][4]=="04"
        // выводить итог если ??? - вставить определение
        n1:=IF(j==LEN(a_itog),LEN(a_itog[j][5]),LEN(a_itog[j][5])-1)
        ASORT(a_itog[j][5],2,,{|x,y|(x[n_itog]<y[n_itog])})
        AADD(a_itog[j][5],a_itog[j][5][1])
        ADEL(a_itog[j][5],1)
        ASIZE(a_itog[j][5],LEN(a_itog[j][5])-1)
//        ASORT(a_itog[j][5],,,{|x,y|(x[n_itog]<y[n_itog])})
        FOR m:=1 TO n1
          @PROW()+1,0 SAY ""
          IF j<LEN(a_itog)
            a_itog[j+1][3]+=1
          ENDIF
          IF m_margin<>0.AND..NOT.EMPTY(a_itog[j][6])
            @PROW(),PCOL() SAY LEFT(a_itog[j][6],m_margin-1)
          ENDIF
          k:=1
//            FOR l:=1 TO IF(j==LEN(a_itog),LEN(a_itog[j][5][m]),LEN(a_itog[j][5][m])-1)
            FOR l:=1 TO LEN(a_itog[j][5][m])
              DO CASE
                CASE VALTYPE(a_itog[j][5][m][l])=="N"
                  DO CASE
                    CASE a_tabl[l,4]=='03'
                      @PROW(),k+m_margin SAY SumToStr(a_itog[j][5][m][l],a_coor[l]-k-1)
                    CASE a_tabl[l,4]=='04'
                      @PROW(),k+m_margin SAY NumToStr(a_itog[j][5][m][l],a_coor[l]-k-1,a_tabl[l,2])
                  ENDCASE
                  a_itog[j][5][m][l]:=0
                CASE VALTYPE(a_itog[j][5][m][l])=="B".AND.m==2
                      @PROW(),k+m_margin SAY LEFT(EVAL(a_itog[j][5][m][l],a_itog[j][2]),a_coor[l]-k-1)
                CASE VALTYPE(a_itog[j][5][m][l])=="C"
                      IF a_itog[j][5][m][l]=="#"
                        @PROW(),k+m_margin SAY (nAlias)->(EVAL(a_tabl[l,1]))
                      ELSE
                        IF a_itog[j][5][m][l]=="VAR"
                          @PROW(),k+m_margin SAY a_itog[j][2]
                        ELSE
                          IF .NOT.EMPTY(a_itog[j][5][m][l])
                            @PROW(),k+m_margin SAY a_itog[j][5][m][l]
                          ENDIF
                        ENDIF
                      ENDIF
              ENDCASE
              k:=a_coor[l]
            NEXT
          NEXT
          ASIZE(a_itog[j][5],1)
      CASE a_itog[j][4]=="00"
        IF j<LEN(a_itog)
          a_itog[j+1][3]+=1
        ENDIF
        l_first:=.t.
        a_fault:={}
        n_count:=0
        ASIZE(a_fault,LEN(a_itog[j][5]))
        AFILL(a_fault,"0")
        DO WHILE .t.
          n_count++
          @PROW()+1,0 SAY ""
          IF m_margin<>0.AND..NOT.EMPTY(a_itog[j][6]).AND.l_first
            @PROW(),PCOL() SAY LEFT(a_itog[j][6],m_margin-1)
          ENDIF
          k:=1
        l_finish:=.t.
            FOR l:=1 TO LEN(a_itog[j][5])
              IF a_fault[l]=="0"
                DO CASE
                  CASE VALTYPE(a_itog[j][5][l])=="N"
                    DO CASE
                      CASE a_tabl[l,4]=='03'
                        s1:=SumToStr(a_itog[j][5][l],a_coor[l]-k-1)
                        IF LEFT(s1,1)<>"*"
                          @PROW(),k+m_margin SAY s1
                          a_fault[l]:="1"
                        ELSE
                          IF a_fault[l-1]=="0".OR.a_fault[l-1]=="2"
                            s1:=ALLTRIM(SumToStr(a_itog[j][5][l],18))
                            @PROW(),m_margin+a_coor[l]-LEN(s1)-1 SAY s1
                            a_fault[l]:="1"
                          ELSE
                            l_finish:=.f.
                          ENDIF
                        ENDIF
                      CASE a_tabl[l,4]=='04'
                        s1:=NumToStr(a_itog[j][5][l],a_coor[l]-k-1,a_tabl[l,2])
                        IF LEFT(s1,1)<>"*"
                          @PROW(),k+m_margin SAY s1
                          a_fault[l]:="1"
                        ELSE
                          IF a_fault[l-1]=="0".OR.a_fault[l-1]=="2"
                            s1:=ALLTRIM(NumToStr(a_itog[j][5][l],18,a_tabl[l,2]))
                            @PROW(),m_margin+a_coor[l]-LEN(s1)-1 SAY s1
                            a_fault[l]:="1"
                          ELSE
                            l_finish:=.f.
                          ENDIF
                        ENDIF
                    ENDCASE
                  CASE VALTYPE(a_itog[j][5][l])=="B"
                        @PROW(),k+m_margin SAY LEFT(EVAL(a_itog[j][5][l],a_itog[j][2]),a_coor[l]-k-1)
                          a_fault[l]:="1"
                  CASE VALTYPE(a_itog[j][5][l])=="C"
                        IF a_itog[j][5][l]=="#"
                          @PROW(),k+m_margin SAY (nAlias)->(EVAL(a_tabl[l,1]))
                        ELSE
                          IF a_itog[j][5][l]=="VAR"
                            @PROW(),k+m_margin SAY a_itog[j][2]
                          ELSE
                            IF .NOT.EMPTY(a_itog[j][5][l])
                              @PROW(),k+m_margin SAY a_itog[j][5][l]
                            ENDIF
                          ENDIF
                        ENDIF
                          a_fault[l]:="1"
                ENDCASE
              ENDIF
              k:=a_coor[l]
            NEXT
            l_first:=.f.
            IF l_finish.OR.n_count>4
              EXIT
            ENDIF
            FOR l:=1 TO LEN(a_fault)
              IF a_fault[l]=="1"
                a_fault[l]:="2"
              ENDIF
            NEXT
        ENDDO

      OTHERWISE
        IF a_itog[j][4]<>"03".OR.a_itog[j][3]>1
        @PROW()+1,0 SAY ""
        IF j<LEN(a_itog)
          a_itog[j+1][3]+=1
        ENDIF
        IF m_margin<>0.AND..NOT.EMPTY(a_itog[j][6])
          @PROW(),PCOL() SAY LEFT(a_itog[j][6],m_margin-1)
        ENDIF

        k:=1
          FOR l:=1 TO LEN(a_itog[j][5])
            DO CASE
              CASE VALTYPE(a_itog[j][5][l])=="N"
                DO CASE
                  CASE a_tabl[l,4]=='03'
                    s1:=SumToStr(a_itog[j][5][l],a_coor[l]-k-1)
                        IF LEFT(s1,1)<>"*"
                          @PROW(),k+m_margin SAY s1
                        ELSE
                          s1:=Str(a_itog[j][5][l],a_coor[l]-k-1,2)
                          @PROW(),k+m_margin SAY s1
                        ENDIF
                  CASE a_tabl[l,4]=='04'
                    s1:=NumToStr(a_itog[j][5][l],a_coor[l]-k-1,a_tabl[l,2])
                    IF LEFT(s1,1)<>"*"
                      @PROW(),k+m_margin SAY s1
                    ELSE
                      s1:=Str(a_itog[j][5][l],a_coor[l]-k-1,a_tabl[l,2])
                      @PROW(),k+m_margin SAY s1
                    ENDIF
                ENDCASE
                a_itog[j][5][l]:=0
              CASE VALTYPE(a_itog[j][5][l])=="B"
                    @PROW(),k+m_margin SAY LEFT(EVAL(a_itog[j][5][l],a_itog[j][2]),a_coor[l]-k-1)
              CASE VALTYPE(a_itog[j][5][l])=="C"
                    IF a_itog[j][5][l]=="#"
                      @PROW(),k+m_margin SAY (nAlias)->(EVAL(a_tabl[l,1]))
                    ELSE
                      IF a_itog[j][5][l]=="VAR"
                        @PROW(),k+m_margin SAY a_itog[j][2]
                      ELSE
                        IF .NOT.EMPTY(a_itog[j][5][l])
                          @PROW(),k+m_margin SAY a_itog[j][5][l]
                        ENDIF
                      ENDIF
                    ENDIF
            ENDCASE
            k:=a_coor[l]
          NEXT
        ELSE
          FOR l:=1 TO LEN(a_itog[j][5])
            IF VALTYPE(a_itog[j][5][l])=="N"
                a_itog[j][5][l]:=0
            ENDIF
          NEXT

        ENDIF
       ENDCASE
        a_itog[j][2]:=(nAlias)->(EVAL(a_itog[j][1]))
        a_itog[j][3]:=0
        NEXT
ENDDO
Dobms(m_month,IF(m_month1==NIL,1,m_month1))
SET DEVICE TO SCREEN
SET PRINTER TO

RETURN .T.
STATIC FUNCTION pShapka(a_tabl,m_num)
/* ------------- параметры шапки ----------------------------------*/

LOCAL i,m_string,n,m_ktab,j
// LOCAL s1,s2,k

IF .NOT.screen->(DS("SH0"+m_num))
  DispError("Не знайдена шапка машинограми "+m_num)
  RETURN .F.
ENDIF
i:=AT("└",screen->vd)+1
// m_string:=MEMOTRAN(MEMOLINE(screen->vd,MLCOUNT(screen->vd,300)), "",END_LINE)
m_string:=ALLTRIM(SUBSTR(screen->vd,AT("└",screen->vd)))
m_ktab = AT( "┘" ,m_string)        // позиция завершения таблицы
IF m_ktab = 0.OR.EMPTY(m_string)   // определение корректности шапки
   DispError("Параметри шапки визначенi некоректно !!!")
   RETURN(.F.)
ENDIF
n:=LEN(m_string);j:=1
FOR i:=2 TO n
  IF SUBSTR(m_string,i,1)=="┴"
    AADD(a_tabl,i)
  ENDIF
NEXT
AADD(a_tabl,m_ktab)
RETURN(.T.)
STATIC FUNCTION SayItog(a_sum,a_tabl,a_coor,m_margin)
LOCAL nSum,i,j,x,k
nSum:=1;j:=0;k:=m_margin
FOR i:=1 TO LEN(a_tabl)
    IF a_tabl[i,3]
      IF a_tabl[i,4]=='03'
        IF LEFT(ALLTRIM(SumToStr(a_sum[nSum++],a_coor[i]-k-1)),1)=="*"
          j:=1
          EXIT
        ENDIF
      ENDIF
      IF a_tabl[i,4]=='04'
        IF LEFT(ALLTRIM(NumToStr(a_sum[nSum++],a_coor[i]-k-1,a_tabl[i,2])),1)=="*"
          j:=1
          EXIT
        ENDIF
      ENDIF
    ENDIF
    k:=a_coor[i]+m_margin
NEXT
IF j==0
  nSum:=1;k:=m_margin
  @PROW()+1,0 SAY ""
  FOR i:=1 TO LEN(a_tabl)
      IF a_tabl[i,3]
        IF a_tabl[i,4]=='03'
          @PROW(),k SAY SumToStr(a_sum[nSum++],a_coor[i]-k-1)
        ENDIF
        IF a_tabl[i,4]=='04'
          @PROW(),k SAY NumToStr(a_sum[nSum++],a_coor[i]-k-1,a_tabl[i,2])
        ENDIF
      ENDIF
      k:=a_coor[i]+m_margin
  NEXT
ELSE
  FOR j:=0 TO 1
    @PROW()+1,0 SAY ""
    nSum:=1;k:=m_margin
    FOR i:=1 TO LEN(a_tabl)
        IF a_tabl[i,3]
//          IF (nSum % 2) - IF(j==1,1,0) == 0
          IF (nSum % 2) - j == 0
            IF a_tabl[i,4]=='03'
              x:=ALLTRIM(SumToStr(a_sum[nSum],18))
              @PROW(),a_coor[i]-LEN(x)-1 SAY x
            ENDIF
            IF a_tabl[i,4]=='04'
              x:=ALLTRIM(NumToStr(a_sum[nSum],18,a_tabl[i,2]))
              @PROW(),a_coor[i]-LEN(x)-1 SAY x
            ENDIF
          ENDIF
          nSum++
        ENDIF
        k:=a_coor[i]+m_margin
    NEXT
  NEXT
ENDIF
RETURN .t.
STATIC FUNCTION FormItog(m_num,nAlias)
  LOCAL a_itog:={},i:=1,j,n,s1,m_str
  NET USE (m_syspath+"itog") INDEX (m_syspath+"itog")  NEW READONLY
  itog->(DBGOTOP())
  itog->(dbseek("MS"+m_num))
  i:=1
  // описание a_itog
  // [1] - блок сравнения
  // [2] - значение блока сравнения
  // [3] - счетчик строк
  // [4] - тип итога
  //       00   -  общий   итог
  //       01   -  обычный итог
  //       02   -  итог можно размещать на нескольких строках
  //       03   -  умный итог - не выводить если количество строк >1
  //       04   -  массив итогов
  //       05   -  массив итогов - последняя строка
  // [5] - массив выводимых значений
  //       NIL  не выводится
  //       число - итоговая сумма
  //       кодовый блок - расшифровка [2]
  //       "&"          - значение a_tabl
  //       Символы      - постоянная строка
  //  [6] - дополнительная строка

  DO WHILE .NOT.itog->(EOF()).and.ALLTRIM(itog->NAME)=="MS"+m_num
    IF itog->type=="04".OR.itog->type=="05"
      AADD(a_itog,{NIL,NIL,0,"04",{{}},RTRIM(itog->str)})
    ELSE
      AADD(a_itog,{NIL,NIL,0,itog->type,{},RTRIM(itog->str)})
    ENDIF
    IF itog->type=="00".OR.itog->type=="05"
      a_itog[i][1]:={||IF(EOF(),.t.,.f.)}
    ELSE
      a_itog[i][1]:=(nAlias)->(FIELDBLOCK(ALLTRIM(itog->itog)))
    ENDIF
    m_str:=RTRIM(itog->tabl)
    n:=NUMTOKEN(m_str,";")
    IF itog->type<>"04".AND.itog->type<>"05"
        FOR j:=1 TO n
          s1:=TOKEN(m_str,";",j)
          DO CASE
            CASE s1=="*"
              AADD(a_itog[i][5],0)
            CASE s1=="NIL"
              AADD(a_itog[i][5],NIL)
            CASE s1=="#"
              AADD(a_itog[i][5],"#")
            CASE LEFT(s1,1)=="&"
              AADD(a_itog[i][5],Transl(SUBSTR(s1,2)))
            OTHERWISE
              AADD(a_itog[i][5],s1)
          ENDCASE
          NEXT
    ELSE
      FOR j:=1 TO n
        s1:=TOKEN(m_str,";",j)
        DO CASE
          CASE s1=="*"
            AADD(a_itog[i][5][1],0)
          CASE s1=="NIL"
            AADD(a_itog[i][5][1],NIL)
          CASE s1=="#"
            AADD(a_itog[i][5][1],"#")
          CASE LEFT(s1,1)=="&"
            AADD(a_itog[i][5][1],Transl(SUBSTR(s1,2)))
          OTHERWISE
            AADD(a_itog[i][5][1],s1)
        ENDCASE
       NEXT
//       a_itog[i][5][1][n_itog]:=CHARREPL("$",a_itog[i][5][1][n_itog],CHR(255))
    ENDIF
      itog->(DBSKIP())
      i++
    ENDDO
  CLOSE itog
RETURN a_itog
STATIC Function Transl(s1)
DO CASE
  CASE s1=="SP01"
    RETURN {|x|Sp01->(DS(x)),Sp01->naim1}
  CASE s1=="SP02"
    RETURN {|x|_mol(x)}
  CASE s1=="SP03"
    RETURN {|x|Sp03->(DS(x)),Sp03->naim3}
  CASE s1=="SP04"
    RETURN {|x|Sp04->(DS(x)),Sp04->name4b}
  CASE s1=="SP05"
    RETURN {|x|Sp05->(DS(x)),Sp05->naim5a}
  CASE s1=="SP06"
    RETURN {|x|Sp06->(DS(x)),Sp06->naim6}
  CASE s1=="SP44"
    RETURN {|x|sp44->(DBSEEK(x)),sp44->naim7}
  CASE s1=="SP08"
    RETURN {|x|Sp08->(DS(x)),Sp08->name8}
  CASE s1=="SP10"
    RETURN {|x|_fio(x)}
  CASE s1=="SP13A"
    RETURN {|x|Sp13a->(DS(x)),Sp13a->naim13a}
  CASE s1=="SP13B"
    RETURN {|x|Sp13b->(DS(x)),Sp13b->naim13b}
  CASE s1=="INV_A"
    RETURN {|x|inv_a->(DS(x)),sp13a->(DS(inv_a->kavt)),Sp13a->naim13a}
  CASE s1=="INV_T"
    RETURN {|x|inv_t->(DS(x)),sp13b->(DS(inv_t->kmtr)),Sp13b->naim13b}
//  CASE s1=="VAR"
//    RETURN {|x|ALLTRIM(TRANSFORM(x,NIL))}
  OTHERWISE
    RETURN {|x|""}
ENDCASE
RETURN {|x|""}
STATIC function FormTabl(m_num,nAlias,nSum)
LOCAL a_tabl:={},i:=0,m_col,x
  sptabl->(DBGOTOP())
  sptabl->(dbseek("MS"+m_num))
  // описание a_tabl
  // [1] - блок
  // [2] - ширина или количество точек после запятой
  // [3] - подведение итогов
  // [4] - тип столбца
  // [5] - шаблон
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)=="MS"+m_num
  i++
    DO CASE
      CASE sptabl->type=='01'
        m_col:=(nAlias)->(FIELDBLOCK(ALLTRIM(sptabl->value)))
//        m_col:=&("{||field->"+(ALLTRIM(sptabl->value))+"}")
    CASE sptabl->type=='02'
        x:="{||"+trn(ALLTRIM(sptabl->value))+"}"
        m_col:=&("{||"+trn(ALLTRIM(sptabl->value))+"}")
      CASE sptabl->type=='03'
//        m_col:={|x,n|IF(x==0,SPACE(n),SumToStr(x,n))}
        m_col=(nAlias)->(FIELDBLOCK(ALLTRIM(sptabl->value)))
      CASE sptabl->type=='04'
//        m_col:={|x,n,n2|IF(x==0,SPACE(n),NumToStr(x,n,n2))}
        m_col:=(nAlias)->(FIELDBLOCK(ALLTRIM(sptabl->value)))
      CASE sptabl->type=='05'
        m_col:=(nAlias)->(FIELDBLOCK(ALLTRIM(sptabl->value)))
        n_itog:=i
    ENDCASE
      AADD(a_tabl,;
      {m_col,IF(sptabl->width==0,0,sptabl->width),;
      sptabl->print,sptabl->type,IF(EMPTY(sptabl->pict),NIL,ALLTRIM(sptabl->pict))})
     Sptabl->(DBSKIP())
    ENDDO
RETURN (a_tabl)
