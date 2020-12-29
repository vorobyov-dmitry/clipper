#include "New.ch"
#include "menu.ch"
MEMVAR a_menu,m_mainpath,m_sprpath,m_bufpath,p_npr,m_mash,m_tabn,m_imja
MEMVAR m_temppath,m_platpath,m_oper,m_syspath,m_computer,m_exepath,m_copypath,m_uchpath
#define SCHT_OST "04"
#define R_CH CHR(255)
#define SCHT_KORMA "10"
#define SCHT_ZRPL "661"
STATIC m_schtgsm:=""
STATIC m_koprgsm:=""

Function SetParMsh(var)
LOCAL i,n_win,a_get:={},a_recno:={},GetList:={},m_kod,m_scht

  n_win:=InitScr("PARMSH")
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh") new
  NET USE (m_syspath+"parmsh") INDEX  (m_syspath+"parmsh") new
//  WaitMessage("Редагування даних машинограми["+var+"]")

  msh->(DS(STR(VAL(var),3)))
  m_kod:=msh->kod
  m_scht:=msh->scht
  IF parmsh->(DS(var))
    DO WHILE .NOT.parmsh->(EOF()).AND.parmsh->ms==var
      AADD(a_get,{parmsh->name,parmsh->type,parmsh->two,parmsh->clr,parmsh->p1,parmsh->p2,parmsh->p3})
      AADD(a_recno,parmsh->(RECNO()))
      parmsh->(DBSKIP())
    ENDDO
    @1,39 Get m_kod COLOR "n/w,gr+/n"
    /*
    */
    @7,9  SAY a_get[1,1] COLOR "Gr+/b"
    @7,31 Get a_get[1,2] COLOR "n/w,Gr+/n"
    @7,35 Get a_get[1,3] COLOR "n/w,Gr+/n"
    @7,38 Get a_get[1,4] COLOR (a_get[1,4]+",Gr+/N")
    @7,52 Get a_get[1,5] COLOR "n/w,Gr+/n"
    @7,61 Get a_get[1,6] COLOR "n/w,Gr+/n"
    @7,69 Get a_get[1,7] COLOR "n/w,Gr+/n"
    IF LEN(a_get)>=2
      @8,9  SAY a_get[2,1] COLOR "Gr+/b"
      @8,31 Get a_get[2,2] COLOR "n/w,Gr+/n"
      @8,35 Get a_get[2,3] COLOR "n/w,Gr+/n"
      @8,38 Get a_get[2,4] COLOR (a_get[2,4]+",Gr+/N")
      @8,52 Get a_get[2,5] COLOR "n/w,Gr+/n"
      @8,61 Get a_get[2,6] COLOR "n/w,Gr+/n"
      @8,69 Get a_get[2,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=3
      @9,9  SAY a_get[3,1] COLOR "Gr+/b"
      @9,31 Get a_get[3,2] COLOR "n/w,Gr+/n"
      @9,35 Get a_get[3,3] COLOR "n/w,Gr+/n"
      @9,38 Get a_get[3,4] COLOR (a_get[3,4]+",Gr+/N")
      @9,52 Get a_get[3,5] COLOR "n/w,Gr+/n"
      @9,61 Get a_get[3,6] COLOR "n/w,Gr+/n"
      @9,69 Get a_get[3,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=4
      @10,9  SAY a_get[4,1] COLOR "Gr+/b"
      @10,31 Get a_get[4,2] COLOR "n/w,Gr+/n"
      @10,35 Get a_get[4,3] COLOR "n/w,Gr+/n"
      @10,38 Get a_get[4,4] COLOR (a_get[4,4]+",Gr+/N")
      @10,52 Get a_get[4,5] COLOR "n/w,Gr+/n"
      @10,61 Get a_get[4,6] COLOR "n/w,Gr+/n"
      @10,69 Get a_get[4,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=5
      @11,9  SAY a_get[5,1] COLOR "Gr+/b"
      @11,31 Get a_get[5,2] COLOR "n/w,Gr+/n"
      @11,35 Get a_get[5,3] COLOR "n/w,Gr+/n"
      @11,38 Get a_get[5,4] COLOR (a_get[5,4]+",Gr+/N")
      @11,52 Get a_get[5,5] COLOR "n/w,Gr+/n"
      @11,61 Get a_get[5,6] COLOR "n/w,Gr+/n"
      @11,69 Get a_get[5,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=6
      @12,9  SAY a_get[6,1] COLOR "Gr+/b"
      @12,31 Get a_get[6,2] COLOR "n/w,Gr+/n"
      @12,35 Get a_get[6,3] COLOR "n/w,Gr+/n"
      @12,38 Get a_get[6,4] COLOR (a_get[6,4]+",Gr+/N")
      @12,52 Get a_get[6,5] COLOR "n/w,Gr+/n"
      @12,61 Get a_get[6,6] COLOR "n/w,Gr+/n"
      @12,69 Get a_get[6,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=7
      @13,9  SAY a_get[7,1] COLOR "Gr+/b"
      @13,31 Get a_get[7,2] COLOR "n/w,Gr+/n"
      @13,35 Get a_get[7,3] COLOR "n/w,Gr+/n"
      @13,38 Get a_get[7,4] COLOR (a_get[7,4]+",Gr+/N")
      @13,52 Get a_get[7,5] COLOR "n/w,Gr+/n"
      @13,61 Get a_get[7,6] COLOR "n/w,Gr+/n"
      @13,69 Get a_get[7,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=8
      @14,9  SAY a_get[8,1] COLOR "Gr+/b"
      @14,31 Get a_get[8,2] COLOR "n/w,Gr+/n"
      @14,35 Get a_get[8,3] COLOR "n/w,Gr+/n"
      @14,38 Get a_get[8,4] COLOR (a_get[8,4]+",Gr+/N")
      @14,52 Get a_get[8,5] COLOR "n/w,Gr+/n"
      @14,61 Get a_get[8,6] COLOR "n/w,Gr+/n"
      @14,69 Get a_get[8,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=9
      @15,9  SAY a_get[9,1] COLOR "Gr+/b"
      @15,31 Get a_get[9,2] COLOR "n/w,Gr+/n"
      @15,35 Get a_get[9,3] COLOR "n/w,Gr+/n"
      @15,38 Get a_get[9,4] COLOR (a_get[9,4]+",Gr+/N")
      @15,52 Get a_get[9,5] COLOR "n/w,Gr+/n"
      @15,61 Get a_get[9,6] COLOR "n/w,Gr+/n"
      @15,69 Get a_get[9,7] COLOR "n/w,Gr+/n"
    ENDIF
    IF LEN(a_get)>=10
      @16,9  SAY a_get[10,1] COLOR "Gr+/b"
      @16,31 Get a_get[10,2] COLOR "n/w,Gr+/n"
      @16,35 Get a_get[10,3] COLOR "n/w,Gr+/n"
      @16,38 Get a_get[10,4] COLOR (a_get[10,4]+",Gr+/N")
      @16,52 Get a_get[10,5] COLOR "n/w,Gr+/n"
      @16,61 Get a_get[10,6] COLOR "n/w,Gr+/n"
      @16,69 Get a_get[10,7] COLOR "n/w,Gr+/n"
    ENDIF
IF var<>"75".AND.var<>"70"  // Защелка на главную книгу и оборотный баланс
    @18,12 get m_scht   COLOR  "w/b*,Gr+/n" PICTURE "@s60"
ENDIF

    SET CURSOR ON
    SET ESCAPE ON
    READ
    IF LASTKEY()<>K_ESC
      IF msh->(NetRlock())
        msh->kod:=m_kod
        msh->scht:=m_scht
      ENDIF
      FOR i:=1 TO LEN(a_get)
        parmsh->(DBGOTO(a_recno[i]))
        IF parmsh->(NetRlock())
        parmsh->name :=a_get[i,1]
        parmsh->type :=a_get[i,2]
        parmsh->two  :=a_get[i,3]
        parmsh->clr  :=a_get[i,4]
        parmsh->p1   :=a_get[i,5]
        parmsh->p2   :=a_get[i,6]
        parmsh->p3   :=a_get[i,7]
        parmsh->(dbunlock())
        ENDIF
      NEXT

    ENDIF

  ELSE
    DispError("Параметри машинограми"+var+";не знайденi")
  ENDIF
  CLOSE base parmsh,msh
  Wclose(n_win)
RETURN .t.
Function RestVar(m_name)
myvar->(DBSEEK(PADR(LOWER(ALLTRIM(m_name)),12)))
DO CASE
  CASE myvar->kod=="C"
    RETURN (ALLTRIM(myvar->value))
  CASE myvar->kod=="N"
    RETURN (VAL(myvar->value))
  CASE myvar->kod=="L"
    RETURN (IF(AT(UPPER(ALLTRIM(myvar->value)),"1TYД")<>0,.t.,.f.))
  CASE myvar->kod=="D"
    RETURN (CTOD(ALLTRIM(myvar->value)))
ENDCASE
DispError("Помилка при читаннi "+m_name)
RETURN ""
/*
* Чтение параметров машинограммы и ввод даты
*
*/
Static Function MsReadMnt(m_num_mash,m_scht,m_kod,m_mnt1,m_mnt2,a_files,l1)
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh") READONLY new
  msh->(DS(" "+m_num_mash))
  m_kod:=msh->kod
  m_scht:=PADR(msh->scht,80)
  CLOSE msh
  IF .NOT.GetMntMash(@m_mnt1,@m_mnt2,@m_scht,@m_kod,l1)
    return .f.
  ENDIF
  Fp1SetIndex(a_files)
  m_scht:=ALLTRIM(m_scht)
RETURN .t.
/*
* Чтение параметров машинограммы и ввод даты
*
*/
Static Function MsRdMnt(m_num_mash,a_scht,m_kod,m_mnt1,m_mnt2,a_files,l1)
LOCAL m_scht,i,n
a_scht:={}
IF .NOT.MsReadMnt(m_num_mash,@m_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
// @0,40 SAY "["+m_scht+"]" COLOR "gr+/r"
// inkey(0)
IF m_scht=="*"
  a_scht:={"*"}
ELSE
n:=NUMTOKEN(m_scht)
FOR i:=1 TO n
  AADD(a_scht,TOKEN(m_scht,i))
NEXT
ENDIF
return .t.
Static Function IsScht(m_dbt,a_scht)
LOCAL i:=ASCAN(a_scht,{|x|(x==LEFT(m_dbt,LEN(x)))})
// @0,0 SayDisp "   " color 'bg/w'

IF i==0
// @1,0 SayDisp "i==0   " color 'n/r'
// @5,0 SayDisp LEN(a_scht) color 'n/r'
  IF LEN(a_scht)==1
// @2,0 SayDisp "a_scht==1" color 'n/r'
// @3,0 SayDisp "["+a_scht[1]+"]" color 'n/r'
    IF a_scht[1]=="*"
      RETURN .T.
    endif
  ENDIF
  RETURN .f.
ENDIF
RETURN .t.

/*
* Создает массив характеристик итогов - хотя нужен только тип
* TODO убрать ненужные параметры
*/

Function CreateAtotal(m_num_mash,a_total)
  NET USE (m_syspath+"parmsh") INDEX  (m_syspath+"parmsh") new
  parmsh->(DS(m_num_mash))
    DO WHILE .NOT.parmsh->(EOF()).AND.parmsh->ms==m_num_mash
      AADD(a_total,{parmsh->name,parmsh->type,parmsh->two,parmsh->clr,parmsh->p1,parmsh->p2,parmsh->p3})
      parmsh->(DBSKIP())
    ENDDO
CLOSE parmsh
RETURN .t.
/*
* Поиск соответстующей записи в fp1
*
*/
Function Fp1Check(n_error)
LOCAL m_vnum
      IF Fp1->vnum<>Fp2->vnum
        IF .NOT.Fp1->(DS(Fp2->vnum))
          IF n_error==0
            DispError("Знайдена проводка без заголовку")
          ENDIF
          n_error++
          // Если ошибка пропускаем все записи fp2 с таким внутренним номером
          m_vnum:=Fp2->vnum
          DO WHILE .NOT.fp2->(EOF()).and.Fp2->vnum==m_vnum
            fp2->(DBSKIP())
          ENDDO
          RETURN .F.
        ENDIF
      ENDIF
RETURN .T.
/*
* Завершающие операции по расчету машинограммы
*/
STATIC Function CloseRasch(n_error,m_num_mash,l_exit,a_files,m_str)
  IF n_error<>0
    DispError("При розрахунку знайдено ;"+STR(n_error,4)+" помилок")
  ENDIF
  Close buf
  // Записать информацию о машинограмме
  // m_mnt1 - m_mnt2 информация за период
  // l_glv  - есть ли головы в машинограмме
  // m_oper - оператор расчета машинограммы
  // m_kod - Код расчета :
  //             пробел - аналитический код по умолчанию (из справочника субсчетов)
  //             1      - использовать аналитический код обязательно
  //             2      - не использовать аналитический код
  // a_total[1,2]   - если Z , то номер пачек и документов не используються
  //

  IF l_exit  // ЕСЛИ РАСЧЕТ МАШИНОГРАММЫ БЫЛ ПРЕРВАН , ТО УДАЛИТЬ ЕЕ
    FERASE(m_mash+"m"+m_num_mash+".dbf")
    FERASE(m_mash+"m"+m_num_mash+".ntx")
  ELSE
    STRFILE(m_str,m_mash+"m"+m_num_mash+".dbf",.t.)
  ENDIF
  SCLOSEFILES(a_files)
  CLOSE base fp2,fp1,Firm01,Bank01,Kaptka1
RETURN .t.
/* Вывод расшифровки
* Если определен аналитический код то расшифровка аналитического кода
* иначе расшифровка аналитического счета
*/
STATIC FUNCTION GetAnName(m_dbt,m_cod,m_kod)
    IF .not.EMPTY(m_cod).AND.(m_kod==" ".OR.m_kod=="1")
      RETURN(AnCodName(m_dbt,m_cod))
    ENDIF
    Sp44->(DS(m_dbt))
RETURN Sp44->naim7
/**
 Создание структуры файла
*/
STATIC Function CrStr(m_name)
LOCAL a_struct:={}
  NET USE  (m_syspath+"Struct") INDEX (m_syspath+"Struct") NEW READONLY
  struct->(DS("M"+m_name))
  DO WHILE .NOT.struct->(EOF()).AND."M"+m_name==ALLTRIM(struct->name)
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
  IF FILE(m_mash+"M"+m_name+".dbf")
    FERASE(m_mash+"M"+m_name+".dbf")
  ENDIF
  DBCREATE(m_mash+"M"+m_name,a_struct)
  CLOSE STRUCT

RETURN .T.
STATIC Function GetMntMash(m_mnt1,m_mnt2,m_scht,m_kod,l_1)
  Local m_month1:="01",m_month2:="  ",m_year1:="    ",m_year2:="    ",;
  n_win,Getlist:={},m_month,l_edit:=IF(l_1==NIL,.t.,l_1)
  IF MONTH(DATE())==1
    m_year1:=m_year2:=STR(YEAR(DATE())-1,4)
    m_month2:="12"
  ELSE
    m_year1:=m_year2:=STR(YEAR(DATE()),4)
    m_month2:=STRZERO(MONTH(DATE())-1,2)
  ENDIF
  n_win:=InitScr("GETMNTMS")
  SET ESCAPE ON
  SET CURSOR ON
  @2,7 get m_month1 PICTURE "99" COLOR "gr+/B*,gr+/n" VALID (m_month1<"13".and.m_month1>"00")
  @2,17 get m_year1 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2020".and.m_year1>="1999")
  @3,7 get m_month2 PICTURE "99" COLOR "gr+/b*,gr+/n" VALID (m_month2<"13".and.m_month2>"00")
  @3,17 get m_year2 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2020".and.m_year1>="1999")
  @15,10 get m_scht PICTURE "@s46" COLOR "gr+/b*,gr+/n" WHEN l_edit
  @16,27 get m_kod PICTURE "9" COLOR "gr+/b*,gr+/n" VALID (m_kod==" " .or.m_kod=="1" .or.m_kod=="2")
  READ
  SET CURSOR OFF
  m_mnt1:=RIGHT(m_year1,2)+m_month1
  m_mnt2:=RIGHT(m_year2,2)+m_month2
  Wclose(n_win)
  IF LASTKEY() = K_ESC
    RETURN .F.
  ENDIF

return .t.


STATIC Function Fp1SetIndex(a_files)
LOCAL m_message
NET USE (m_platpath+"FIRM01") INDEX (m_platpath+"Firm01"),(m_platpath+"Firm01a"),(m_platpath+"Firm01b") NEW
NET USE (m_platpath+"BANK01") INDEX (m_platpath+"BANK01") NEW
NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
sOpenFiles("201",a_files)
USE (m_mainpath+"Fp2") READONLY NEW
USE (m_mainpath+"Fp1") READONLY NEW
IF .NOT.FILE(m_mainpath+"Fp1.ntx")
  m_message:=DispMessage("Iндексацiя файлу")
  INDEX ON fp1->vnum TO (m_mainpath+"Fp1")
  DelMessage(m_message)
  return .t.
ELSE
  IF FILEDATE(m_mainpath+"Fp1.DBF")>FILEDATE(m_mainpath+"Fp1.NTX")
  m_message:=DispMessage("Iндексацiя файлу")
    INDEX ON fp1->vnum TO (m_mainpath+"Fp1")
  DelMessage(m_message)
  return .t.
  ELSE
    IF FILEDATE(m_mainpath+"Fp1.DBF")==FILEDATE(m_mainpath+"Fp1.NTX").AND.;
     FILETIME(m_mainpath+"Fp1.DBF")>FILETIME(m_mainpath+"Fp1.NTX")
    m_message:=DispMessage("Iндексацiя файлу")
      INDEX ON fp1->vnum TO (m_mainpath+"Fp1")
    DelMessage(m_message)
  return .t.
    ENDIF
  ENDIF
ENDIF
SET INDEX TO  (m_mainpath+"Fp1")
return .t.

STATIC FUNCTION GetAnCod(m_dbt,m_cod,m_kod)
IF m_kod=="1"
  RETURN (m_cod)
endif
IF m_kod=="2"
  RETURN BLANK(m_cod,.t.)
endif
Sp44->(DS(m_dbt))
IF EMPTY(Sp44->type1)
  RETURN BLANK(m_cod,.t.)
ENDIF
RETURN m_cod


Function RMs62()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={}

  LOCAL m_num_mash:="62",a_files:={},l_exit:=.f.
LOCAL   m_kopr2,s_kormday
// Условие при которых не суммируется количество
// приход - это не синтетический и аналитический учет (т/км и т.д.) и не кормодни
// расход - то же самое но исключаеться списание ГСМ с водителей

LOCAL   b_cond1db:={||IF((fp1->maket<> "51") .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL   b_cond1cr:={||IF((fp1->maket <> "51".OR.fp2->kopr==m_kopr2) .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}

//  WaitMessage("Розрахунок 62-й машинограми")

// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ
  RESTMEM s_kormday // кормодни и т.д.
  RESTMEM m_schtgsm  // счет ГСМ - литры сумируются в головы
  CLOSE myvar
  s_kormday:=ALLTRIM(s_kormday)
  m_kopr2:=ALLTRIM(m_kopr2)

// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kplh+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 62")
  DO WHILE .NOT. Fp2->(EOF())
    IF IsScht(Fp2->dbt,a_scht).or.IsScht(Fp2->crt,a_scht) // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF

         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА ИЛИ ГОДА то есть подходит по дате

      IF (mnt_year(fp1->mnt)==mnt_year(m_mnt1).AND.fp1->mnt<m_mnt1).OR.(fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
        // приход
         IF IsScht(Fp2->dbt,a_scht)

          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->crt:=fp2->crt
             buf->cod1:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod2:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kplh:=fp2->kplh
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF LEFT(buf->dbt,LEN(m_schtgsm))==m_schtgsm
              buf->dbglv:=fp2->kvo2
              IF fp2->kvo2<>0;l_glv:="1";ENDIF

            ENDIF


             IF .not.EMPTY(buf->cod2)
              buf->name:=buf->kopr+" "+buf->crt+" "+buf->cod2
            ELSE
              Sp44->(DS(buf->crt))
              buf->name:=buf->kopr+" "+buf->crt+" "+Sp44->naim7
            ENDIF
          ENDIF
        ENDIF
      // Исходная строка машинограммы по МВО
      m62dbap(fp2->dbt,GetAnCod(buf->dbt,fp2->cod1,m_kod),fp2->kplh,"2",m_mnt1,m_mnt2,{||_mol(fp2->kplh)},b_cond1db)
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF

      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[3,2]<>"Z" // Итог по аналит. коду не отключен в настройке
        // Исходная строка машинограммы по аналитическому коду
      m62dbap(fp2->dbt,fp2->cod1,R_CH+R_CH,"3",m_mnt1,m_mnt2,{||AnCodName(fp2->dbt,fp2->cod1)},b_cond1db)
     ENDIF
     // Итог по аналитическому счету
    IF a_total[4,2]<>"Z"
      m62dbap(fp2->dbt,REPLICATE(R_CH,10),R_CH+R_CH,"4",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},b_cond1db)
    ENDIF

    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[5,2]<>"Z"
    FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
      IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
        m62dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),R_CH+R_CH,"5",m_mnt1,m_mnt2,{||Sp44->naim7},b_cond1db)
      ENDIF
    NEXT
    ENDIF
     // Итог по счету
    IF a_total[6,2]<>"Z"
      m62dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),R_CH+R_CH,"6",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(LEFT(fp2->dbt,2)+SPACE(5))),Sp44->naim7},b_cond1db)
    ENDIF
     // ОБЩИЙ Итог
    IF a_total[7,2]<>"Z"
      m62dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),R_CH+R_CH,"7",m_mnt1,m_mnt2,{||""},b_cond1db)
    ENDIF
  ENDIF // ПРИХОД

        // расход
         IF IsScht(Fp2->crt,a_scht)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->crt:=fp2->dbt
             buf->cod1:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->cod2:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->kplh:=fp2->otp
             buf->kopr:=fp2->kopr
             buf->crkvo:=fp2->kvo
             buf->crstm:=fp2->stm
             buf->crglv:=fp2->glv
            IF LEFT(buf->dbt,LEN(m_schtgsm))==m_schtgsm
              buf->crglv:=fp2->kvo2
              IF fp2->kvo2<>0;l_glv:="1";ENDIF
            ENDIF
             IF .not.EMPTY(buf->cod2)
              buf->name:=buf->kopr+" "+buf->crt+" "+buf->cod2
            ELSE
              Sp44->(DS(buf->crt))
              buf->name:=buf->kopr+" "+buf->crt+" "+Sp44->naim7
            ENDIF
          ENDIF
        ENDIF
      // Исходная строка машинограммы по МВО
      m62crap(fp2->crt,GetAnCod(buf->crt,fp2->cod2,m_kod),fp2->otp,"2",m_mnt1,m_mnt2,{||_mol(fp2->otp)},b_cond1cr)
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[3,2]<>"Z" // Итог по аналит. коду не отключен в настройке
        // Исходная строка машинограммы по аналитическому коду
      m62crap(fp2->crt,fp2->cod2,R_CH+R_CH,"3",m_mnt1,m_mnt2,{||AnCodName(fp2->crt,fp2->cod2)},b_cond1cr)
     ENDIF
     // Итог по аналитическому счету
    IF a_total[4,2]<>"Z"
      m62crap(fp2->crt,REPLICATE(R_CH,10),R_CH+R_CH,"4",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},b_cond1cr)
     ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[5,2]<>"Z"
    FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
      IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
        m62crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),R_CH+R_CH,"5",m_mnt1,m_mnt2,{||Sp44->naim7},b_cond1cr)
      ENDIF
    NEXT
     ENDIF
     // Итог по счету
    IF a_total[6,2]<>"Z"
      m62crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),R_CH+R_CH,"6",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(LEFT(fp2->crt,2)+SPACE(5))),Sp44->naim7},b_cond1cr)
     ENDIF
     // ОБЩИЙ Итог
    IF a_total[7,2]<>"Z"
      m62crap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),R_CH+R_CH,"7",m_mnt1,m_mnt2,{||""},b_cond1cr)
     ENDIF
  ENDIF // РАСХОД


 ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF


    Fp2->(DBSKIP())
//    DO WHILE Fp2->vnum==Fp1->vnum
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.l_exit
    // Удаляем нулевые строки и рассчитываем исходящее сальдо
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
      IF buf->docCount==0.AND.buf->crkvo==0.AND. buf->crstm==0.AND. buf->crglv==0.AND.;
        buf->dbkvo==0.AND.buf->dbstm==0.AND.buf->dbglv==0.AND.;
        buf->inkvo==0.AND.buf->instm==0.AND.buf->inglv==0
         buf->(DBDELETE())
      ELSE
       IF buf->level<>"1"
        buf->otglv:=buf->inglv+buf->dbglv-buf->crglv
        buf->otkvo:=buf->inkvo+buf->dbkvo-buf->crkvo
        buf->otstm:=buf->instm+buf->dbstm-buf->crstm
       ENDIF
      ENDIF
      buf->(DBSKIP())
    ENDDO
   ENDIF
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC Function m62dbap(m_dbt,m_cod1,m_kplh,m_level,m_mnt1,m_mnt2,b_name,b_kvo)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kplh+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kplh:=m_kplh
        buf->name:=EVAL(b_name)
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
         // В ПРИХОД ЕГО !!!!
        IF EVAL(b_kvo)
          buf->dbkvo+=fp2->kvo
        ENDIF
        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        buf->docCount:=1 // Признак наличия первичного документа в оборотах
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->dbglv+=fp2->kvo2
        ENDIF
      ELSE
        // ВХОДЯЩЕЕ САЛЬДО
        IF EVAL(b_kvo)
          buf->inkvo+=fp2->kvo
        ENDIF
        buf->instm+=fp2->stm
        buf->inglv+=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->inglv+=fp2->kvo2
        ENDIF
      ENDIF
RETURN .T.
STATIC Function m62crap(m_dbt,m_cod1,m_kplh,m_level,m_mnt1,m_mnt2,b_name,b_kvo)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kplh+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kplh:=m_kplh
        buf->name:=EVAL(b_name)
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
         // В РАСХОД ЕГО !!!!
        IF EVAL(b_kvo)
          buf->crkvo+=fp2->kvo
        ENDIF
        buf->docCount:=1 // Признак наличия первичного документа в оборотах
        buf->crstm+=fp2->stm
        buf->crglv+=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->crglv+=fp2->kvo2
        ENDIF
      ELSE
        // ВХОДЯЩЕЕ САЛЬДО
        IF EVAL(b_kvo)
          buf->inkvo-=fp2->kvo
        ENDIF
        buf->instm-=fp2->stm
        buf->inglv-=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->inglv-=fp2->kvo2
        ENDIF
      ENDIF
RETURN .T.
Function RMs63()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={}

  LOCAL m_num_mash:="63",a_files:={},l_exit:=.f.
  LOCAL   m_kopr2,s_kormday,m_schtkvo2

LOCAL   b_cond1db:={||IF((fp1->maket<> "51") .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL   b_cond1cr:={||IF((fp1->maket <> "51".OR.fp2->kopr==m_kopr2) .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}

//  WaitMessage("Розрахунок 63-й машинограми")

// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ

  RESTMEM s_kormday // кормодни и т.д.
  RESTMEM m_schtgsm  // счет ГСМ - литры сумируются в головы
  RESTMEM m_schtkvo2 // count with kvo 2
  CLOSE myvar
  s_kormday:=ALLTRIM(s_kormday)
  m_kopr2:=ALLTRIM(m_kopr2)


// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->kplh+buf->dbt+buf->cod1+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 63")
  DO WHILE .NOT. Fp2->(EOF())
    IF IsScht(Fp2->dbt,a_scht).or.IsScht(Fp2->crt,a_scht) // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА ИЛИ ГОДА то есть подходит по дате

      IF (mnt_year(fp1->mnt)==mnt_year(m_mnt1).AND.fp1->mnt<m_mnt1).OR.(fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
        // приход
          IF fp2->glv<>0
            l_glv:="1"
          ENDIF
         IF IsScht(Fp2->dbt,a_scht)

          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->crt:=fp2->crt
             buf->cod1:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod2:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kplh:=fp2->kplh
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             //buf->dbkvo2:=fp2->kvo2
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
        IF LEFT(buf->dbt,LEN(m_schtgsm))==m_schtgsm
              buf->dbglv:=fp2->kvo2
              IF fp2->kvo2<>0;l_glv:="1";ENDIF
         ENDIF
        IF LEFT(buf->dbt,LEN(m_schtkvo2))==m_schtkvo2
              buf->dbglv:=fp2->kvo2
              IF fp2->kvo2<>0;l_glv:="1";ENDIF
         ENDIF
            IF .not.EMPTY(buf->cod2)
              buf->name:=buf->kopr+" "+buf->crt+" "+buf->cod2
            ELSE
              Sp44->(DS(buf->crt))
              buf->name:=buf->kopr+" "+buf->crt+" "+Sp44->naim7
            ENDIF
          ENDIF
        ENDIF
      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[2,2]<>"Z" // Итог по аналит. коду не отключен в настройке
        // Исходная строка машинограммы по аналитическому коду
      m63dbap(fp2->dbt,fp2->cod1,fp2->kplh,"2",m_mnt1,m_mnt2,{||AnCodName(fp2->dbt,fp2->cod1)},b_cond1db)
     ENDIF
     // Итог по аналитическому счету
    IF a_total[3,2]<>"Z"
      m63dbap(fp2->dbt,REPLICATE(R_CH,10),fp2->kplh,"3",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},b_cond1db)
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[4,2]<>"Z"
    FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
      IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
        m63dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kplh,"4",m_mnt1,m_mnt2,{||Sp44->naim7},b_cond1db)
      ENDIF
    NEXT
    ENDIF
     // Итог по счету
    IF a_total[5,2]<>"Z"
      m63dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kplh,"5",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(LEFT(fp2->dbt,2)+SPACE(5))),Sp44->naim7},b_cond1db)
    ENDIF
    // ИТОГ ПО МВО
    IF a_total[6,2]<>"Z"
      m63dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),fp2->kplh,"6",m_mnt1,m_mnt2,{||_mol(fp2->kplh)},b_cond1db)
    ENDIF
    // итог по предприятию
    IF a_total[7,2]<>"Z"
      m63dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),R_CH+R_CH,"7",m_mnt1,m_mnt2,{||""},b_cond1db)
    ENDIF
  ENDIF // ПРИХОД

        // расход
         IF IsScht(Fp2->crt,a_scht)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->crt:=fp2->dbt
             buf->cod1:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->cod2:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->kplh:=fp2->otp
             buf->kopr:=fp2->kopr
             buf->crkvo:=fp2->kvo
             //buf->crkvo2:=fp2->kvo2
             buf->crstm:=fp2->stm
             buf->crglv:=fp2->glv
            IF LEFT(buf->dbt,LEN(m_schtgsm))==m_schtgsm
              buf->crglv:=fp2->kvo2
              IF fp2->kvo2<>0;l_glv:="1";ENDIF
            ENDIF
            IF LEFT(buf->dbt,LEN(m_schtkvo2))==m_schtkvo2
              buf->crglv:=fp2->kvo2
              IF fp2->kvo2<>0;l_glv:="1";ENDIF
            ENDIF
             IF .not.EMPTY(buf->cod2)
              buf->name:=buf->kopr+" "+buf->crt+" "+buf->cod2
            ELSE
              Sp44->(DS(buf->crt))
              buf->name:=buf->kopr+" "+buf->crt+" "+Sp44->naim7
            ENDIF
          ENDIF
        ENDIF
      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[2,2]<>"Z" // Итог по аналит. коду не отключен в настройке
        // Исходная строка машинограммы по аналитическому коду
      m63crap(fp2->crt,fp2->cod2,fp2->otp,"2",m_mnt1,m_mnt2,{||AnCodName(fp2->crt,fp2->cod2)},b_cond1cr)
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
     ENDIF
     // Итог по аналитическому счету
    IF a_total[3,2]<>"Z"
      m63crap(fp2->crt,REPLICATE(R_CH,10),fp2->otp,"3",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},b_cond1cr)
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[4,2]<>"Z"
    FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
      IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
        m63crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->otp,"4",m_mnt1,m_mnt2,{||Sp44->naim7},b_cond1cr)
      ENDIF
    NEXT
    ENDIF
     // Итог по счету
    IF a_total[5,2]<>"Z"
      m63crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->otp,"5",m_mnt1,m_mnt2,{||Sp44->(DBSEEK(LEFT(fp2->crt,2)+SPACE(5))),Sp44->naim7},b_cond1cr)
    ENDIF
    // ИТОГ ПО МВО
    IF a_total[6,2]<>"Z"
      m63crap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),fp2->otp,"6",m_mnt1,m_mnt2,{||_mol(fp2->otp)},b_cond1cr)
    ENDIF
    // итог по предприятию
    IF a_total[7,2]<>"Z"
      m63crap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),R_CH+R_CH,"7",m_mnt1,m_mnt2,{||""},b_cond1cr)
    ENDIF
  ENDIF // РАСХОД


 ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
//    DO WHILE Fp2->vnum==Fp1->vnum
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.l_exit
    // Удаляем нулевые строки и рассчитываем исходящее сальдо
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
      IF buf->docCount==0.AND.buf->crkvo==0.AND. buf->crstm==0.AND. buf->crglv==0.AND.;
        buf->dbkvo==0.AND.buf->dbstm==0.AND.buf->dbglv==0.AND.;
        buf->inkvo==0.AND.buf->instm==0.AND.buf->inglv==0
         buf->(DBDELETE())
      ELSE
       IF buf->level<>"1"
        buf->otglv:=buf->inglv+buf->dbglv-buf->crglv
        buf->otkvo:=buf->inkvo+buf->dbkvo-buf->crkvo
        buf->otstm:=buf->instm+buf->dbstm-buf->crstm
       ENDIF
      ENDIF
      buf->(DBSKIP())
    ENDDO
    Ms63MolApp()
   ENDIF
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC Function m63dbap(m_dbt,m_cod1,m_kplh,m_level,m_mnt1,m_mnt2,b_name,b_kvo)
      IF .not.buf->(DS(m_kplh+m_dbt+m_cod1+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kplh:=m_kplh
        buf->name:=EVAL(b_name)
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
         // В ПРИХОД ЕГО !!!!
        IF EVAL(b_kvo)
          buf->dbkvo+=fp2->kvo
        ENDIF
        buf->docCount:=1 // Признак наличия первичного документа в оборотах

        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->dbglv+=fp2->kvo2
        ENDIF
      ELSE
        // ВХОДЯЩЕЕ САЛЬДО
        IF EVAL(b_kvo)
          buf->inkvo+=fp2->kvo
        ENDIF

        buf->instm+=fp2->stm
        buf->inglv+=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->inglv+=fp2->kvo2
        ENDIF
      ENDIF
RETURN .T.
STATIC Function m63crap(m_dbt,m_cod1,m_kplh,m_level,m_mnt1,m_mnt2,b_name,b_kvo)
      IF .not.buf->(DS(m_kplh+m_dbt+m_cod1+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kplh:=m_kplh
        buf->name:=EVAL(b_name)
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
         // В РАСХОД ЕГО !!!!
        IF EVAL(b_kvo)
          buf->crkvo+=fp2->kvo
        ENDIF
        buf->crstm+=fp2->stm
        buf->crglv+=fp2->glv
        buf->docCount:=1 // Признак наличия первичного документа в оборотах
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->crglv+=fp2->kvo2
        ENDIF
      ELSE
        // ВХОДЯЩЕЕ САЛЬДО
        IF EVAL(b_kvo)
          buf->inkvo-=fp2->kvo
        ENDIF
        buf->instm-=fp2->stm
        buf->inglv-=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->inglv-=fp2->kvo2
        ENDIF
      ENDIF
RETURN .T.
STATIC Function Ms63MolApp()
LOCAL s1:="",i,n
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
       IF buf->kplh<>R_CH+R_CH
          IF AT(buf->kplh+",",s1)==0
            s1+=buf->kplh+","
          ENDIF
        ENDIF
      buf->(DBSKIP())
    ENDDO
    n:=NUMTOKEN(s1)
    FOR i:=1 TO n
      buf->(DBAPPEND())
      buf->kplh:=TOKEN(s1,",",i)
      buf->name:=""
      buf->npch:=buf->ndoc:=""
      buf->dbt:=buf->cod1:=""
      buf->level:="6"
      buf->(DBAPPEND())
      buf->kplh:=TOKEN(s1,",",i)
      buf->name:=buf->kplh+"  "+_mol(buf->kplh)
      buf->npch:=buf->ndoc:="******"
      buf->dbt:=buf->cod1:="***************"
      buf->level:="6"
      buf->(DBAPPEND())
      buf->kplh:=TOKEN(s1,",",i)
      buf->name:=""
      buf->npch:=buf->ndoc:=""
      buf->dbt:=buf->cod1:="."
      buf->level:="6"
  NEXT
return .t.
Function RMs64()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={}

  LOCAL m_num_mash:="64",a_files:={},l_exit:=.f.
LOCAL   m_kopr2,s_kormday
// Условие при которых не суммируется количество
// приход - это не синтетический и аналитический учет (т/км и т.д.) и не кормодни
// расход - то же самое но исключаеться списание ГСМ с водителей

LOCAL   b_cond1db:={||IF((fp1->maket<> "51") .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL   m_ost64
// LOCAL   b_cond1cr:={||IF((fp1->maket <> "51".OR.fp2->kopr==m_kopr2) .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}


//  WaitMessage("Розрахунок 64-й машинограми")

// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ
  RESTMEM s_kormday // кормодни и т.д.
  RESTMEM m_schtgsm  // счет ГСМ - литры сумируются в головы
  RESTMEM m_ost64  // Суммировать остатки или нет
  CLOSE myvar
  s_kormday:=ALLTRIM(s_kormday)

  m_kopr2:=ALLTRIM(m_kopr2)

// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kopr+buf->level+buf->crt+buf->cod2 TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 64")
  DO WHILE .NOT. Fp2->(EOF())
    IF IsScht(Fp2->dbt,a_scht).AND.LEFT(fp2->crt,2)<>m_ost64 // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
        // приход
          IF fp2->glv<>0
            l_glv:="1"
          ENDIF
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->ndog:=fp1->ndog
             buf->ndoc1:=fp1->ndoc1
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->crt:=fp2->crt
             buf->cod1:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod2:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr  //+IF(EVAL(b_cond1db)," √","")   // Суммируется количество или нет
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF LEFT(buf->dbt,LEN(m_schtgsm))==m_schtgsm
              buf->dbglv:=fp2->kvo2
            ENDIF
             //расшифровка корсчета
             IF .not.EMPTY(buf->cod2).AND.(m_kod==" ".OR.m_kod=="1")
              buf->name:=AnCodName(fp2->crt,fp2->cod2)
            ELSE
              Sp44->(DS(buf->crt))
              buf->name:=Sp44->naim7
            ENDIF
        ENDIF
       // Итог по корсчету
      IF a_total[2,2]<>"Z" // Итог по аналит. коду не отключен в настройке
        // Исходная строка машинограммы по аналитическому коду
        Sp44->(DS(fp2->crt))
      m64dbap(fp2->dbt,fp2->cod1,fp2->kopr,"2",fp2->crt,;
      fp2->cod2,{||Sp44->naim7},b_cond1db)
     ENDIF
     // Итог по операции
    IF a_total[3,2]<>"Z"
      m64dbap(fp2->dbt,fp2->cod1,fp2->kopr,"3",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},b_cond1db,IF(EVAL(b_cond1db),"√","*"))
    ENDIF
    // Итог по аналитическому коду
    IF a_total[4,2]<>"Z".and.(m_kod=="1".OR.m_kod==" ")
      m64dbap(fp2->dbt,fp2->cod1,REPLICATE(R_CH,2),"4",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||AnCodName(fp2->dbt,fp2->cod1)},b_cond1db)
    ENDIF
    // Итог по аналитическому cчету
    IF a_total[5,2]<>"Z"
      m64dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},b_cond1db)
       // Реализация сложного итога по операциям
      m64dbap(fp2->dbt,REPLICATE(R_CH,10),fp2->kopr,"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.},IF(EVAL(b_cond1db),"√","*"))
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[6,2]<>"Z"
    FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
      IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
        m64dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp44->naim7},b_cond1db)
        m64dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.},IF(EVAL(b_cond1db),"√","*"))
      ENDIF
    NEXT
    ENDIF
     // Итог по счету
    IF a_total[7,2]<>"Z"
      Sp44->(DS(LEFT(fp2->dbt,2)+SPACE(5)))
      m64dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"7",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp44->naim7},b_cond1db)
      m64dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,"7",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.},IF(EVAL(b_cond1db),"√","*"))
    ENDIF
    // итог по предприятию
    IF a_total[7,2]<>"Z"
      m64dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"7",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||""},b_cond1db)
    ENDIF
  ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
//    DO WHILE Fp2->vnum==Fp1->vnum
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC Function m64dbap(m_dbt,m_cod1,m_kopr,m_level,m_crt,m_cod2,b_name,b_kvo,s_itog)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_level+m_crt+m_cod2))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->crt:=m_crt
        buf->cod2:=m_cod2
        buf->kopr:=m_kopr
        buf->name:=EVAL(b_name)
      ENDIF
      IF EVAL(b_kvo)
        buf->dbkvo+=fp2->kvo
      ENDIF

        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        IF LEFT(m_dbt,LEN(m_schtgsm))==m_schtgsm
          buf->dbglv+=fp2->kvo2
      ENDIF
      IF .NOT.EMPTY(s_itog)
        buf->itog:=s_itog
      ENDIF

RETURN .T.




Function RMs65()
  LOCAL l_first:=.t.,n_error:=0,m_kod,a_scht:={},i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={}

  LOCAL m_num_mash:="65",a_files:={},l_exit:=.f.
LOCAL   m_kopr2,s_kormday
//LOCAL s_perem
// Условие при которых не суммируется количество
// приход - это не синтетический и аналитический учет (т/км и т.д.) и не кормодни
// расход - то же самое но исключаеться списание ГСМ с водителей

// LOCAL   b_cond1db:={||IF((fp1->maket<> "51") .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL   b_cond1cr:={||IF((fp1->maket <> "51".OR.fp2->kopr==m_kopr2) .AND. AT(fp2->kopr,s_kormday)<>0,.F.,.t.)}
LOCAL   m_ost64


//  WaitMessage("Розрахунок 65-й машинограми")

// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ
  RESTMEM s_kormday // кормодни и т.д.
  RESTMEM m_schtgsm  // счет ГСМ - литры сумируются в головы
  RESTMEM m_ost64  // Суммировать остатки или нет
  //RESTMEM s_perem  // коды операций по внутреннему перемещению


  CLOSE myvar
  s_kormday:=ALLTRIM(s_kormday)
  m_kopr2:=ALLTRIM(m_kopr2)

// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kopr+buf->level+buf->crt+buf->cod2 TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 65")
  DO WHILE .NOT. Fp2->(EOF())
    IF IsScht(Fp2->crt,a_scht).AND.LEFT(fp2->dbt,2)<>m_ost64
      //.AND. AT(fp2->kopr,s_perem)==0 // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
        // приход
          IF fp2->glv<>0
            l_glv:="1"
          ENDIF
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->ndog:=fp1->ndog
             buf->ndoc1:=fp1->ndoc1
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->crt:=fp2->dbt
             buf->cod2:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod1:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr  //+IF(EVAL(b_cond1db)," √","")   // Суммируется количество или нет
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF LEFT(buf->crt,LEN(m_schtgsm))==m_schtgsm
              buf->dbglv:=fp2->kvo2
            ENDIF
             //расшифровка корсчета
             IF .not.EMPTY(buf->cod2).AND.(m_kod==" ".OR.m_kod=="1")
              buf->name:=AnCodName(fp2->crt,fp2->cod2)
            ELSE
              Sp44->(DS(buf->dbt))
              buf->name:=Sp44->naim7
            ENDIF
        ENDIF
       // Итог по корсчету
      IF a_total[2,2]<>"Z" // Итог по аналит. коду не отключен в настройке
        // Исходная строка машинограммы по аналитическому коду
        Sp44->(DS(fp2->dbt))
      m64dbap(fp2->crt,fp2->cod2,fp2->kopr,"2",fp2->dbt,;
      fp2->cod1,{||Sp44->naim7},b_cond1cr)
     ENDIF
     // Итог по операции
    IF a_total[3,2]<>"Z"
      m64dbap(fp2->crt,fp2->cod2,fp2->kopr,"3",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},b_cond1cr,IF(EVAL(b_cond1cr),"√","*"))
    ENDIF
    // Итог по аналитическому коду
    IF a_total[4,2]<>"Z".and.(m_kod=="1".OR.m_kod==" ")
      m64dbap(fp2->crt,fp2->cod2,REPLICATE(R_CH,2),"4",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||AnCodName(fp2->crt,fp2->cod2)},b_cond1cr)
    ENDIF
    // Итог по аналитическому cчету
    IF a_total[5,2]<>"Z"
      m64dbap(fp2->crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},b_cond1cr)
       // Реализация сложного итога по операциям
      m64dbap(fp2->crt,REPLICATE(R_CH,10),fp2->kopr,"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.},IF(EVAL(b_cond1cr),"√","*"))
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[6,2]<>"Z"
    FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
      IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
        m64dbap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp44->naim7},b_cond1cr)
        m64dbap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,"5",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.},IF(EVAL(b_cond1cr),"√","*"))
      ENDIF
    NEXT
    ENDIF
     // Итог по счету
    IF a_total[7,2]<>"Z"
      Sp44->(DS(LEFT(fp2->crt,2)+SPACE(5)))
      m64dbap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"7",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp44->naim7},b_cond1cr)
      m64dbap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,"7",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.},IF(EVAL(b_cond1cr),"√","*"))
    ENDIF
    // итог по предприятию
    IF a_total[7,2]<>"Z"
      m64dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"7",REPLICATE(R_CH,7),REPLICATE(R_CH,10),{||""},b_cond1cr)
    ENDIF
  ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
//    DO WHILE Fp2->vnum==Fp1->vnum
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.

Function RMs66()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={}

  LOCAL m_num_mash:="66",a_files:={},l_exit:=.f.,m_kopr2,m_ost66,s_perem
//  WaitMessage("Розрахунок 66-й машинограми")
// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ для суммирования литров
  RESTMEM m_ost66  // Суммировать остатки или нет
  RESTMEM s_perem  // коды операций по внутреннему перемещению
  CLOSE myvar
  m_kopr2:=ALLTRIM(m_kopr2)
  m_koprgsm:=m_kopr2
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kopr+buf->brgd+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 66")
  DO WHILE .NOT. Fp2->(EOF())
    IF ((IsScht(Fp2->dbt,a_scht).AND.LEFT(fp2->crt,2)<>m_ost66);
      .or.(IsScht(Fp2->crt,a_scht).AND.LEFT(fp2->dbt,2)<>m_ost66)).AND. AT(fp2->kopr,s_perem)==0 // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)  //Документ из расчетного периода
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
        IF Fp2->kopr==m_koprgsm.AND.fp2->kvo2<>0
          l_glv:="1"
        ENDIF
        IF IsScht(Fp2->dbt,a_scht)     // затраты
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->brgd:=fp2->brgd1
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
            ENDIF
              Sp01->(DS(buf->brgd))
              buf->name:=Sp01->naim1
          ENDIF
      // Исходная строка машинограммы по бригадi
      m66dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,fp2->brgd1,"2",{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->Naim1})
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m66dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,REPLICATE(R_CH,2),"3",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
     ENDIF
     // Итог по аналитическому коду
    IF a_total[4,2]<>"Z".AND.m_kod<>"2"
       m66dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"4",{||AnCodName(fp2->dbt,fp2->cod1)})
    ENDIF

     // Итог по аналитическому счету
    IF a_total[5,2]<>"Z"
       m66dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"5",{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7})
       IF m_kod<>"2"
        m66dbap(fp2->dbt,REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[6,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
        IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
          m66dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"6",{||Sp44->naim7})
          m66dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[7,2]<>"Z"
       m66dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"7",{||Sp44->(DBSEEK(LEFT(fp2->dbt,2)+SPACE(5))),Sp44->naim7})
       m66dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
    ENDIF
     // ОБЩИЙ Итог - не нужен не имеет смысла
    ENDIF  // конец учета затрат
        IF IsScht(Fp2->crt,a_scht)     // выход продукции (кредит)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->brgd:=fp2->brgd2
             buf->kopr:=fp2->kopr
             buf->crkvo:=fp2->kvo
             buf->crstm:=fp2->stm
             buf->crglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
            ENDIF
              Sp01->(DS(buf->brgd))
              buf->name:=Sp01->naim1
          ENDIF
      // Исходная строка машинограммы по бригадi
      m66crap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,fp2->brgd2,"2",{||Sp01->(DBSEEK(Fp2->brgd2)),Sp01->Naim1})
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m66crap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,REPLICATE(R_CH,2),"3",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
     ENDIF
     // Итог по аналитическому коду
    IF a_total[4,2]<>"Z".AND.m_kod<>"2"
       m66crap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod1,m_kod),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"4",{||AnCodName(fp2->crt,fp2->cod2)})
    ENDIF

     // Итог по аналитическому счету
    IF a_total[5,2]<>"Z"
       m66crap(fp2->crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"5",{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7})
       IF m_kod<>"2"
        m66crap(fp2->crt,REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[6,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
        IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
          m66crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"6",{||Sp44->naim7})
          m66crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[7,2]<>"Z"
       m66crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"7",{||Sp44->(DBSEEK(LEFT(fp2->crt,2)+SPACE(5))),Sp44->naim7})
       m66crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
    ENDIF
     // ОБЩИЙ Итог - не нужен не имеет смысла
    ENDIF  // конец учета затрат
  ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m66dbap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_brgd+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        buf->dbkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->dbglv+=fp2->kvo2
        ENDIF
RETURN .T.
STATIC Function m66crap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_brgd+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
        buf->crstm+=fp2->stm
        buf->crglv+=fp2->glv
        buf->crkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->crglv+=fp2->kvo2
        ENDIF
RETURN .T.

Function RMs67()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={},m_ost66

  LOCAL m_num_mash:="67",a_files:={},l_exit:=.f.,m_kopr2,s_perem
//  WaitMessage("Розрахунок 67-й машинограми")
// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_ost66  // Суммировать остатки или нет
  RESTMEM m_kopr2  // операция ГСМ для суммирования литров
  RESTMEM s_perem
  CLOSE myvar
  m_kopr2:=ALLTRIM(m_kopr2)
  m_koprgsm:=m_kopr2
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->brgd+buf->dbt+buf->cod1+buf->kopr+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 67")
  DO WHILE .NOT. Fp2->(EOF())
    IF ((IsScht(Fp2->dbt,a_scht).AND.LEFT(fp2->crt,2)<>m_ost66);
      .or.(IsScht(Fp2->crt,a_scht).AND.LEFT(fp2->dbt,2)<>m_ost66)).AND. AT(fp2->kopr,s_perem)==0  // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)  //Документ из расчетного периода
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
        IF IsScht(Fp2->dbt,a_scht)     // затраты
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->brgd:=fp2->brgd1
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
              l_glv:="1"
            ENDIF
              Sp05->(DS(buf->kopr))
              buf->name:=Sp05->naim5a
          ENDIF
      // Исходная строка машинограммы по операцiї
      m67dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,fp2->brgd1,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
     // Итог по аналитическому коду
      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m67dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,fp2->brgd1,"3",{||AnCodName(fp2->dbt,fp2->cod1)})
     ENDIF
     // Итог по аналитическому счету
    IF a_total[4,2]<>"Z"
       m67dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"4",{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7})
       IF m_kod<>"2"
        m67dbap(fp2->dbt,REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"4",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[5,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
        IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
          m67dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"5",{||Sp44->naim7})
          m67dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[6,2]<>"Z"
       m67dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"6",{||Sp44->(DBSEEK(LEFT(fp2->dbt,2)+SPACE(5))),Sp44->naim7})
       m67dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
    ENDIF
     // ОБЩИЙ Итог - по бригадi
    m67dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),Fp2->brgd1,"7",{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->Naim1})
    m67dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),fp2->kopr            ,Fp2->brgd1,"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})

    ENDIF  // конец учета затрат
        IF IsScht(Fp2->crt,a_scht)     // выход продукции (кредит)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->brgd:=fp2->brgd2
             buf->kopr:=fp2->kopr
             buf->crkvo:=fp2->kvo
             buf->crstm:=fp2->stm
             buf->crglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
              l_glv:="1"
            ENDIF
              Sp05->(DS(buf->kopr))
              buf->name:=Sp05->naim5a
          ENDIF
      // Исходная строка машинограммы по бригадi
      m67crap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,fp2->brgd2,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
     // Итог по аналитическому коду
    IF a_total[3,2]<>"Z".AND.m_kod<>"2"
       m67crap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod1,m_kod),REPLICATE(R_CH,2),fp2->brgd2,"3",{||AnCodName(fp2->crt,fp2->cod2)})
    ENDIF

     // Итог по аналитическому счету
    IF a_total[4,2]<>"Z"
       m67crap(fp2->crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd2,"4",{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7})
       IF m_kod<>"2"
        m67crap(fp2->crt,REPLICATE(R_CH,10),fp2->kopr,fp2->brgd2,"4",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[5,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
        IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
          m67crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd2,"5",{||Sp44->naim7})
          m67crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd2,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[6,2]<>"Z"
       m67crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd2,"6",{||Sp44->(DBSEEK(LEFT(fp2->crt,2)+SPACE(5))),Sp44->naim7})
       m67crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd2,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
    ENDIF
     // ОБЩИЙ Итог -  - по бригадi
    m67crap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),Fp2->brgd2,"7",{||Sp01->(DBSEEK(Fp2->brgd2)),Sp01->Naim1})
    m67crap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),fp2->kopr,Fp2->brgd2,"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})

    ENDIF  // конец учета выхода продукции
  ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m67dbap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name)
      IF .not.buf->(DS(m_brgd+m_dbt+m_cod1+m_kopr+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        buf->dbkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->dbglv+=fp2->kvo2
        ENDIF
RETURN .T.
STATIC Function m67crap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name)
      IF .not.buf->(DS(m_brgd+m_dbt+m_cod1+m_kopr+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
        buf->crstm+=fp2->stm
        buf->crglv+=fp2->glv
        buf->crkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->crglv+=fp2->kvo2
        ENDIF
RETURN .T.


Function RMs68()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_kvo2,a_scht:={}

  LOCAL m_num_mash:="68",a_files:={},l_exit:=.f.
  LOCAL   s_korm
//  WaitMessage("Розрахунок 68-й машинограми")

// 1-й шаг ввести расчетный период
NET USE (m_sprpath+"sp24") INDEX (m_sprpath+"sp24") NEW READONLY
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF

  // необходимо определить операцию по кормам
  NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  s_korm:=RESTVAR1("s_korm","MS")
  CLOSE myvar
  s_korm:=ALLTRIM(s_korm)
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->crt+buf->brgd+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 68")
  DO WHILE .NOT. Fp2->(EOF())
    IF (IsScht(Fp2->dbt,a_scht).AND.; // Fp2 подходит
        (s_korm=="*".OR.AT(fp2->kopr,s_korm)<>0))
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->brgd:=fp2->brgd1
             buf->dbt:=fp2->dbt
             buf->crt:=fp2->crt
             buf->kvo:=fp2->kvo
             buf->stm:=fp2->stm
             sp24->(DS(fp2->crt)) //Определение коэффициента
             buf->koef:=sp24->koef
             m_kvo2:=fp2->kvo*sp24->koef
             buf->kvo2:=m_kvo2
             Sp44->(DS(buf->crt))
             buf->name:=Sp44->naim7
            ENDIF
        // Итог по бригаде
        IF a_total[2,2]<>"Z" // Итог не отключен в настройке
         m68dbap(fp2->dbt,fp2->crt,fp2->brgd1,"2",sp24->koef,m_kvo2,{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->naim1})
        ENDIF
      // Итог по корму (кор. счету)
      IF a_total[3,2]<>"Z"
        m68dbap(fp2->dbt,fp2->crt,REPLICATE(R_CH,2),"3",sp24->koef,m_kvo2,{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7})
      ENDIF
      // Итог по потребителю корма (дебету)
      IF a_total[4,2]<>"Z"
        m68dbap(fp2->dbt,REPLICATE(R_CH,7),REPLICATE(R_CH,2),"4",0,m_kvo2,{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7})
      ENDIF
      // Итоги по дереву СУБСЧЕТОВ
      IF a_total[5,2]<>"Z"
        FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
          IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
            m68dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,7),REPLICATE(R_CH,2),"5",0,m_kvo2,{||Sp44->naim7})
          ENDIF
        NEXT
      ENDIF
     // Итог по счету
      IF a_total[6,2]<>"Z"
        Sp44->(DS(LEFT(fp2->dbt,2)+SPACE(5)))
        m68dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,7),REPLICATE(R_CH,2),"6",0,m_kvo2,{||Sp44->naim7})
      ENDIF
      // итог по предприятию
      IF a_total[7,2]<>"Z"
        m68dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,7),REPLICATE(R_CH,2),"7",0,m_kvo2,{||""})
      ENDIF
  ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
Close sp24
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m68dbap(m_dbt,m_crt,m_brgd,m_level,m_koef,m_kvo2,b_name)
      IF .not.buf->(DS(m_dbt+m_crt+m_brgd+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->brgd:=m_brgd
        buf->crt:=m_crt
        buf->name:=EVAL(b_name)
        buf->koef:=m_koef
      ENDIF
      buf->kvo+=fp2->kvo
      buf->stm+=fp2->stm
      buf->kvo2+=m_kvo2
RETURN .T.



Function RMs69()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_kvo2,a_scht:={}

  LOCAL m_num_mash:="69",a_files:={},l_exit:=.f.
  LOCAL   s_korm
//  WaitMessage("Розрахунок 69-й машинограми")

// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
NET USE (m_sprpath+"sp24") INDEX (m_sprpath+"sp24") NEW READONLY

  // необходимо определить операцию по кормам
  NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  s_korm:=RESTVAR1("s_korm","MS")
  CLOSE myvar
  s_korm:=ALLTRIM(s_korm)
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->brgd+buf->dbt+buf->crt+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 69")
  DO WHILE .NOT. Fp2->(EOF())
    IF (IsScht(Fp2->dbt,a_scht).AND.; // Fp2 подходит
        (s_korm=="*".OR.AT(fp2->kopr,s_korm)<>0))
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->brgd:=fp2->brgd1
             buf->dbt:=fp2->dbt
             buf->crt:=fp2->crt
             buf->kvo:=fp2->kvo
             buf->stm:=fp2->stm
             sp24->(DS(fp2->crt)) //Определение коэффициента
             buf->koef:=sp24->koef
             m_kvo2:=fp2->kvo*sp24->koef
             buf->kvo2:=m_kvo2
             Sp44->(DS(buf->crt))
             buf->name:=Sp44->naim7
            ENDIF
      // Итог по корму (кор. счету)
      IF a_total[2,2]<>"Z"
        m69dbap(fp2->dbt,fp2->crt,fp2->brgd1,"2",sp24->koef,m_kvo2,{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7})
      ENDIF
      // Итог по потребителю корма (дебету)
      IF a_total[3,2]<>"Z"
        m69dbap(fp2->dbt,REPLICATE(R_CH,7),fp2->brgd1,"3",0,m_kvo2,{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7})
      ENDIF
      // Итоги по дереву СУБСЧЕТОВ
      IF a_total[4,2]<>"Z"
        FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
          IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
            m69dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,7),fp2->brgd1,"4",0,m_kvo2,{||Sp44->naim7})
          ENDIF
        NEXT
      ENDIF
     // Итог по счету
      IF a_total[5,2]<>"Z"
        Sp44->(DS(LEFT(fp2->dbt,2)+SPACE(5)))
        m69dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,7),fp2->brgd1,"5",0,m_kvo2,{||Sp44->naim7})
      ENDIF
      // Итог по бригаде
      IF a_total[6,2]<>"Z" // Итог не отключен в настройке
        m69dbap(fp2->dbt,fp2->crt,fp2->brgd1,"6",sp24->koef,m_kvo2,{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->naim1})
      ENDIF
      // итог по предприятию
      IF a_total[7,2]<>"Z"
        m69dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,7),REPLICATE(R_CH,2),"7",0,m_kvo2,{||""})
      ENDIF
  ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
Close sp24
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m69dbap(m_dbt,m_crt,m_brgd,m_level,m_koef,m_kvo2,b_name)
      IF .not.buf->(DS(m_brgd+m_dbt+m_crt+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->brgd:=m_brgd
        buf->crt:=m_crt
        buf->name:=EVAL(b_name)
        buf->koef:=m_koef
      ENDIF
      buf->kvo+=fp2->kvo
      buf->stm+=fp2->stm
      buf->kvo2+=m_kvo2
RETURN .T.

Function RMs72()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_name,m_sum,a_scht:={}

  LOCAL m_num_mash:="72",a_files:={},l_exit:=.f.,s1,s2,s3,s4
  LOCAL m_list_scht:=""

// 1-й шаг  ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  FILECOPY(m_mash+"m"+m_num_mash+".dbf",m_mash+"m"+m_num_mash+"a.dbf")
  NET USE (m_sprpath+"sp11") INDEX (m_sprpath+"sp11") NEW READONLY
  USE (m_mash+"m"+m_num_mash+"a") NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->crt+buf->cod2+buf->level TO (m_mash+"m"+m_num_mash+"a")
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 72")
  DO WHILE .NOT. Fp2->(EOF())
    IF IsScht(Fp2->dbt,a_scht).or.IsScht(Fp2->crt,a_scht)  // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (mnt_year(fp1->mnt)==mnt_year(m_mnt1).AND.fp1->mnt<m_mnt1).OR.(fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
        // дебет
         IF IsScht(Fp2->dbt,a_scht)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ndog:=fp1->ndog
             buf->ddoc:=fp1->ddoc
             buf->dbt:=fp2->dbt
             buf->crt:=fp2->crt
             buf->cod1:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod2:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr
             buf->dbstm:=fp2->stm
             IF .not.EMPTY(buf->cod2)
                buf->name:=AnCodName(fp2->crt,fp2->cod2)
             ELSE
                Sp44->(DS(buf->crt))
                buf->name:=Sp44->naim7
            ENDIF

          ENDIF
        ENDIF
        IF .not.EMPTY(buf->cod2)
          m_name:=AnCodName(fp2->dbt,fp2->cod1)
        ELSE
          Sp44->(DS(buf->crt))
          m_name:=Sp44->naim7
        ENDIF
       // Итог по корсчету - только обороты (Промежуточный итог)
      IF a_total[2,2]<>"Z"
        IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
                .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
          IF .not.buf->(DS(fp2->dbt+GetAnCod(Fp2->dbt,fp2->cod1,m_kod)+fp2->crt+GetAnCod(Fp2->crt,fp2->cod2,m_kod)+"2"))
             buf->(DBAP())
             buf->level:="2"
             buf->dbt:=fp2->dbt
             buf->cod1:=GetAnCod(fp2->dbt,fp2->cod1,m_kod)
             buf->crt:=fp2->crt
             buf->cod2:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->name:=GetAnName(Fp2->crt,fp2->cod2,m_kod)
          ENDIF
           buf->dbstm+=fp2->stm
           buf->count++
        ENDIF
      ENDIF
    IF m_kod=="2" // Исходная строка не использует аналитический код
        m72dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"4",;
        {||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},m_mnt1,m_mnt2,@m_list_scht)
    ELSE
     // аналитический код используется
        m72dbap(fp2->dbt,GetAnCod(buf->dbt,fp2->cod1,m_kod),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"3",;
        {||GetAnName(fp2->dbt,fp2->cod1,m_kod)},m_mnt1,m_mnt2,@m_list_scht)
    ENDIF
   ENDIF
        // кредит
         IF IsScht(Fp2->crt,a_scht)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ndog:=fp1->ndog
             buf->ddoc:=fp1->ddoc
             buf->dbt:=fp2->crt
             buf->crt:=fp2->dbt
             buf->cod2:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod1:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr
             buf->crstm:=fp2->stm
             IF .not.EMPTY(buf->cod2)
                buf->name:=AnCodName(fp2->crt,fp2->cod2)
             ELSE
                Sp44->(DS(buf->crt))
                buf->name:=Sp44->naim7
            ENDIF

          ENDIF
        ENDIF
        IF .not.EMPTY(buf->cod2)
          m_name:=AnCodName(fp2->crt,fp2->cod2)
        ELSE
          Sp44->(DS(buf->crt))
          m_name:=Sp44->naim7
        ENDIF
       // Итог по корсчету - только обороты (Промежуточный итог)
      IF a_total[2,2]<>"Z"
        IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
                .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
          IF .not.buf->(DS(fp2->crt+GetAnCod(Fp2->crt,fp2->cod2,m_kod)+fp2->dbt+GetAnCod(Fp2->dbt,fp2->cod1,m_kod)+"2"))
             buf->(DBAP())
             buf->level:="2"
             buf->dbt:=fp2->crt
             buf->cod1:=GetAnCod(fp2->crt,fp2->cod2,m_kod)
             buf->crt:=fp2->dbt
             buf->cod2:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->name:=GetAnName(Fp2->dbt,fp2->cod1,m_kod)
          ENDIF
           buf->crstm+=fp2->stm
           buf->count++
        ENDIF
      ENDIF
    IF m_kod=="2" // Исходная строка не использует аналитический код
        m72crap(fp2->crt,REPLICATE(R_CH,10),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"4",;
        {||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},m_mnt1,m_mnt2,@m_list_scht)
    ELSE
     // аналитический код используется
        m72crap(fp2->crt,GetAnCod(buf->crt,fp2->cod2,m_kod),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"3",;
        {||GetAnName(fp2->crt,fp2->cod2,m_kod)},m_mnt1,m_mnt2,@m_list_scht)
    ENDIF
   ENDIF
 ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.EMPTY(m_list_scht)
    DispError("Не визначенi аналiтичнi коди ;"+m_list_scht+";рахункiв")
  ENDIF

  IF .NOT.l_exit
/* */
// Сформировали исходные строки теперь можно считать итоги
// Понеслась !!!
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf1
  ZAP
  INDEX ON buf1->dbt+buf1->cod1+buf1->crt+buf1->cod2+buf1->level TO (m_mash+"m"+m_num_mash)
  SELE buf
  SET INDEX TO
  IF   m_kod=="2"
    SET FILTER TO buf->level=="4"
  ELSE
    SET FILTER TO buf->level=="3"
  ENDIF
  m_gauge:=InitGauge("Пiдрахунок пiдсумкiв машинограми N 72")
  buf->(DBGOTOP())
  DO WHILE .NOT.buf->(EOF())
    // РАСЧЕТ ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО исходных строк
         DO CASE
          CASE IsZrpl(buf->dbt)
              buf->indbstm:=0;buf->incrstm:=0
              buf->outdbstm:=0;buf->outcrstm:=0
          CASE buf->type="З"  // Свернутое сальдо
            IF buf->indbstm<0
              buf->incrstm:=ABS(buf->indbstm)
              buf->indbstm:=0
            ENDIF
            m_sum:=buf->indbstm-buf->incrstm+buf->dbstm-buf->crstm
            IF m_sum<0
              buf->outcrstm:=ABS(m_sum)
            ELSE
              buf->outdbstm:=m_sum
            ENDIF
          CASE buf->type="Д" //Дебетовое сальдо
            buf->outdbstm:=buf->indbstm+buf->dbstm-buf->crstm
          CASE buf->type="К" //Кредитовое сальдо
            buf->outcrstm:=buf->incrstm-buf->dbstm+buf->crstm
          CASE buf->type="Р" // Развернутое
            buf->outdbstm:=buf->indbstm+buf->dbstm
            buf->outcrstm:=buf->incrstm+buf->crstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            IF buf->indbstm<0
              buf->incrstm:=ABS(buf->indbstm)
              buf->indbstm:=0
            ENDIF
            m_sum:=buf->indbstm-buf->incrstm+buf->dbstm-buf->crstm
            IF m_sum<0
              buf->outcrstm:=ABS(m_sum)
            ELSE
              buf->outdbstm:=m_sum
            ENDIF
        ENDCASE
    //КОНЕЦ РАСЧЕТА ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО по аналитическому счету
     // Занесение итогов
      // Итоги по дереву СУБСЧЕТОВ
      IF a_total[5,2]<>"Z"
        FOR i:=3 TO LEN(RTRIM(buf->dbt))-1
          IF sp44->(DS(PADR(LEFT(buf->dbt,i),7)))
              IF .not.buf1->(DS(LEFT(LEFT(buf->dbt,i)+REPLICATE(R_CH,7),7)+REPLICATE(R_CH,10)+REPLICATE(R_CH,7)+REPLICATE(R_CH,10)+"5"))
                  buf1->(DBAP())
                  buf1->level:="5"
                  buf1->dbt:=LEFT(LEFT(buf->dbt,i)+REPLICATE(R_CH,7),7)
                  buf1->cod1:=REPLICATE(R_CH,10)
                  buf1->crt:=REPLICATE(R_CH,7)
                  buf1->cod2:=REPLICATE(R_CH,10)
                  buf1->name:=Sp44->naim7
                  IF sp11->(DS(PADR(LEFT(buf1->dbt,i),7)))
                    buf1->type:=sp11->type1
                  ELSE
                    buf1->type:=buf->type1
                  ENDIF
              ENDIF
              buf1->crstm+=buf->crstm
              buf1->dbstm+=buf->dbstm

            DO CASE
              CASE IsZrpl(buf1->dbt)
                  buf1->indbstm:=0
                  buf1->incrstm:=0
                  buf1->outdbstm:=0
                  buf1->outcrstm:=0
              CASE buf1->type="З"  // Свернутое сальдо
                // Все минусуем в дебет а если получиться отрицательное перенесем в кредит
                buf1->indbstm+=buf->indbstm-buf->incrstm
                buf1->outdbstm+=buf->outdbstm-buf->outcrstm
              CASE buf1->type="Д" //Дебетовое сальдо
                buf1->indbstm+=buf->indbstm-buf->incrstm
                buf1->outdbstm+=buf->outdbstm-buf->outcrstm
              CASE buf1->type="К" //Кредитовое сальдо
                buf1->incrstm+=buf->incrstm-buf->indbstm
                buf1->outcrstm+=buf->outcrstm-buf->outdbstm
              CASE buf1->type="Р" // Развернутое
                buf1->incrstm+=buf->incrstm
                buf1->indbstm+=buf->indbstm
                buf1->outcrstm+=buf->outcrstm
                buf1->outdbstm+=buf->outdbstm
              OTHERWISE  //А это шо такое - ну ладно будет свернутым
                buf1->indbstm+=buf->indbstm-buf->incrstm
                buf1->outdbstm+=buf->outdbstm-buf->outcrstm
            ENDCASE
          ENDIF
        NEXT
      ENDIF
     // Итог по счету
      IF a_total[6,2]<>"Z"
        Sp44->(DS(LEFT(buf->dbt,2)+SPACE(5)))

        IF .not.buf1->(DS(LEFT(buf->dbt,2)+REPLICATE(R_CH,5)+REPLICATE(R_CH,10)+REPLICATE(R_CH,7)+REPLICATE(R_CH,10)+"6"))
            buf1->(DBAP())
            buf1->level:="6"
            buf1->dbt:=LEFT(buf->dbt,2)+REPLICATE(R_CH,5)
            buf1->cod1:=REPLICATE(R_CH,10)
            buf1->crt:=REPLICATE(R_CH,7)
            buf1->cod2:=REPLICATE(R_CH,10)
            buf1->name:=Sp44->naim7
            IF sp11->(DS(PADR(LEFT(buf1->dbt,2),7)))
              buf1->type:=sp11->type1
            ELSE
              buf1->type:=buf->type1
            ENDIF
        ENDIF
        buf1->crstm+=buf->crstm
        buf1->dbstm+=buf->dbstm
        DO CASE
          CASE IsZrpl(buf1->dbt)
          CASE buf1->type="З"  // Свернутое сальдо
            // Все в дебет а если получиться отрицательное перенесем в кредит
            buf1->indbstm+=buf->indbstm-buf->incrstm
            buf1->outdbstm+=buf->outdbstm-buf->outcrstm
          CASE buf1->type="Д" //Дебетовое сальдо
            buf1->indbstm+=buf->indbstm-buf->incrstm
            buf1->outdbstm+=buf->outdbstm-buf->outcrstm
          CASE buf1->type="К" //Кредитовое сальдо
            buf1->incrstm+=buf->incrstm-buf->indbstm
            buf1->outcrstm+=buf->outcrstm-buf->outdbstm
          CASE buf1->type="Р" // Развернутое
            buf1->incrstm+=buf->incrstm
            buf1->indbstm+=buf->indbstm
            buf1->outcrstm+=buf->outcrstm
            buf1->outdbstm+=buf->outdbstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            buf1->indbstm+=buf->indbstm-buf->incrstm
            buf1->outdbstm+=buf->outdbstm-buf->outcrstm
        ENDCASE
      ENDIF
    buf->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,buf->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  // пересчитать исходящее сальдо
  m_gauge:=InitGauge("Пiдрахунок вихiдного сальдо машинограми N 72")
  SELE buf1
  SET ORDER TO 0
  buf1->(DBGOTOP())
  DO WHILE .NOT.buf1->(EOF())
    // РАСЧЕТ ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО итогов
         DO CASE
          CASE IsZrpl(buf1->dbt).OR.buf1->type="Р"
          CASE buf1->type="З"  // Свернутое сальдо
            IF buf1->indbstm<0
              buf1->incrstm:=ABS(buf1->indbstm)
              buf1->indbstm:=0
            ENDIF
            m_sum:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm
            IF m_sum<0
              buf1->outcrstm:=ABS(m_sum)
              buf1->outdbstm:=0
            ELSE
              buf1->outdbstm:=m_sum
              buf1->outcrstm:=0
            ENDIF
          CASE buf1->type="Д" //Дебетовое сальдо
            buf1->outdbstm:=buf1->indbstm+buf1->dbstm-buf1->crstm
          CASE buf1->type="К" //Кредитовое сальдо
            buf1->outcrstm:=buf1->incrstm-buf1->dbstm+buf1->crstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            IF buf1->indbstm<0
              buf1->incrstm:=ABS(buf1->indbstm)
              buf1->indbstm:=0
            ENDIF
            m_sum:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm
            IF m_sum<0
              buf1->outcrstm:=ABS(m_sum)
              buf1->outdbstm:=0
            ELSE
              buf1->outdbstm:=m_sum
              buf1->outcrstm:=0
            ENDIF
        ENDCASE
    //КОНЕЦ РАСЧЕТА ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО

    buf1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,buf1->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
// Занесение сальдо по 661 счету
  SET ORDER TO 1

IF buf1->(DS(LEFT(SCHT_ZRPL,3)+REPLICATE(R_CH,4)+REPLICATE(R_CH,10+7+10)+"5")) // Итог по субсчету
  NET USE (m_mainpath+"d52") NEW READONLY
  LOCATE FOR d52->subsch == '700'.AND.d52->month == mnt_month(m_mnt1)-1
   IF FOUND()
      buf1->incrstm:=d52->sumc
      buf1->indbstm:=d52->sumd
      s2:=d52->sumc
      s1:=d52->sumd
   ELSE
      buf1->incrstm:=0
      buf1->indbstm:=0
      s1:=0
      s2:=0
   ENDIF
   LOCATE FOR d52->subsch == '700'.AND.d52->month == mnt_month(m_mnt1)
   IF FOUND()
      buf1->outcrstm:=d52->sumc
      buf1->outdbstm:=d52->sumd
      s4:=d52->sumc
      s3:=d52->sumd
   ELSE
      buf1->outcrstm:=0
      buf1->outdbstm:=0
      s3:=0
      s4:=0
   ENDIF
   i:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm-buf1->outdbstm+buf1->outcrstm
   IF i<>0
         DispError(" Рахунок "+SCHT_ZRPL+ " не пiйшов на сумму;"+SumToSTR(i,14))
  ENDIF

IF buf1->(DS(LEFT(SCHT_ZRPL,2)+REPLICATE(R_CH,5)+REPLICATE(R_CH,10)+REPLICATE(R_CH,7)+REPLICATE(R_CH,10)+"6")) // Итог по счету
      buf1->indbstm +=s1
      buf1->incrstm +=s2
      buf1->outdbstm+=s3
      buf1->outcrstm+=s4
ENDIF

CLOSE d52
ENDIF


  // Перенос записей из buf в buf1
  SELE buf
  set filter to
  IF a_total[1,2]<>"Z".OR.a_total[2,2]<>"Z".OR.a_total[3,2]<>"Z".OR.a_total[4,2]<>"Z"
    buf->(DBGOTOP())
    m_gauge:=InitGauge("Перенiс перв. документiв в машинограму N 72")
    DO WHILE .NOT.buf->(EOF())
      IF a_total[VAL(buf->level),2]<>"Z" // данную запись перенести в buf1
        //TODO анализировать count для корсчетов
        buf1->(DBAP())
        FOR i:=1 TO buf->(FCOUNT())
          buf1->(FIELDPUT(i,buf->(FIELDGET(i))))
        NEXT
      ENDIF
      buf->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,buf->(RECNO()/LASTREC()))
    ENDDO
  ENDIF
  ENDIF // l_exit
Close Sp11
Close buf
Close buf1
USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
INDEX ON buf->dbt+buf->cod1+buf->crt+buf->cod2+buf->level TO (m_mash+"m"+m_num_mash)
// Удаление пустых строчек
  IF .NOT.l_exit
    // Удаляем нулевые строки
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
      IF buf->level<>"1".AND.buf->crstm==0.AND.buf->dbstm==0.AND.buf->indbstm==0.AND.buf->incrstm==0
         buf->(DBDELETE())
      ENDIF
      buf->(DBSKIP())
    ENDDO
   ENDIF


CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.

STATIC Function m72dbap(m_dbt,m_cod1,m_crt,m_cod2,m_level,b_name,m_mnt1,m_mnt2,m_list_scht)
LOCAL i
   IF .not.buf->(DS(m_dbt+m_cod1+m_crt+m_cod2+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->crt:=m_crt
        buf->cod2:=m_cod2
        buf->name:=EVAL(b_name)
        // Определить входящее сальдо свернутое или нет
        FOR i:=LEN(m_dbt)-1 TO 2 STEP -1
          IF Sp11->(DS(PADR(LEFT(m_dbt,i),7)))
            buf->type:=Sp11->type2
            EXIT
          ENDIF
        NEXT
        IF EMPTY(buf->type) // Ну не нашли в справочнике
          IF AT(LEFT(m_dbt,2),m_list_scht)==0
            m_list_scht+=LEFT(m_dbt,2)+","
            DispError("Не визначен тип аналiтичного рахунку "+LEFT(m_dbt,2))
          ENDIF
          buf->type:="З" //По умолчанию свернутое
        ENDIF
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
         // В ДЕБЕТ ЕГО !!!!
         buf->dbstm+=fp2->stm
      ELSE
         DO CASE
          CASE buf->type="З"  // Свернутое сальдо
            // Все суммируем в дебет а если получиться отрицательное перенесем в кредит
            buf->indbstm+=fp2->stm
          CASE buf->type="Д" //Дебетовое сальдо
            buf->indbstm+=fp2->stm
          CASE buf->type="К" //Кредитовое сальдо
            buf->incrstm-=fp2->stm
          CASE buf->type="Р" // Развернутое
            buf->indbstm+=fp2->stm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            buf->indbstm+=fp2->stm
        ENDCASE
      ENDIF
RETURN .T.

STATIC Function m72crap(m_dbt,m_cod1,m_crt,m_cod2,m_level,b_name,m_mnt1,m_mnt2,m_list_scht)
LOCAL i
   IF .not.buf->(DS(m_dbt+m_cod1+m_crt+m_cod2+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->crt:=m_crt
        buf->cod2:=m_cod2
        buf->name:=EVAL(b_name)
        // Определить входящее сальдо свернутое или нет
        FOR i:=LEN(m_dbt)-1 TO 2 STEP -1
          IF Sp11->(DS(PADR(LEFT(m_dbt,i),7)))
            buf->type:=Sp11->type2
            buf->type1:=Sp11->type1
            EXIT
          ENDIF
        NEXT
        IF EMPTY(buf->type) // Ну не нашли в справочнике
          IF AT(LEFT(m_dbt,2),m_list_scht)==0
            m_list_scht+=LEFT(m_dbt,2)+","
            DispError("Не визначен тип аналiтичного рахунку "+LEFT(m_dbt,2))
          ENDIF
          buf->type:="З" //По умолчанию свернутое
          buf->type1:="З" //По умолчанию свернутое
        ENDIF
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
         // В КРЕДИТ ЕГО !!!!
         buf->crstm+=fp2->stm
      ELSE
         DO CASE
          CASE buf->type="З"  // Свернутое сальдо
            // Все минусуем в дебет а если получиться отрицательное перенесем в кредит
            buf->indbstm-=fp2->stm
          CASE buf->type="Д" //Дебетовое сальдо
            buf->indbstm-=fp2->stm
          CASE buf->type="К" //Кредитовое сальдо
            buf->incrstm+=fp2->stm
          CASE buf->type="Р" // Развернутое
            buf->incrstm+=fp2->stm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            buf->incrstm-=fp2->stm
        ENDCASE
      ENDIF
RETURN .T.

Function RMs75()
  LOCAL l_first:=.t.,n_error:=0,m_kod,m_scht,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_name,m_sum

  LOCAL m_num_mash:="75",a_files:={},l_exit:=.f.
  LOCAL m_list_scht:="",m_type
  LOCAL  s_indb:=0,s_db:=0,s_outdb:=0,;
  s_incr:=0,s_cr:=0,s_outcr:=0,s1,s2,s3,s4

// 1-й шаг  ввести расчетный период
IF .NOT.MsReadMnt(m_num_mash,@m_scht,@m_kod,@m_mnt1,@m_mnt2,a_files,.f.)
  return .f.
ENDIF
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  FILECOPY(m_mash+"m"+m_num_mash+".dbf",m_mash+"m"+m_num_mash+"a.dbf")
  NET USE (m_sprpath+"sp11") INDEX (m_sprpath+"sp11") NEW READONLY
  USE (m_mash+"m"+m_num_mash+"a") NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1 TO (m_mash+"m"+m_num_mash+"a")
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 75")
  DO WHILE .NOT. Fp2->(EOF())
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (mnt_year(fp1->mnt)==mnt_year(m_mnt1).AND.fp1->mnt<m_mnt1).OR.(fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
        // дебет
         IF LEFT(fp2->dbt,2)<>SCHT_OST.AND.IsAccount(fp2->dbt)
          IF .NOT.buf->(DS(Fp2->dbt+GetAnCod(Fp2->dbt,fp2->cod1,m_kod)))
            buf->(DBAP())
            buf->dbt:=Fp2->dbt
            buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
          ENDIF
          IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
            .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
                buf->dbstm+=fp2->stm
          ELSE
                buf->indbstm+=fp2->stm
          ENDIF
        ENDIF
         IF LEFT(fp2->crt,2)<>SCHT_OST.AND.IsAccount(fp2->crt)
          IF .NOT.buf->(DS(Fp2->crt+GetAnCod(Fp2->crt,fp2->cod2,m_kod)))
            buf->(DBAP())
            buf->dbt:=Fp2->crt
            buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
          ENDIF
          IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
            .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
                buf->crstm+=fp2->stm
          ELSE
                buf->incrstm+=fp2->stm
          ENDIF
        ENDIF
    ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.EMPTY(m_list_scht)
    DispError("Не визначенi аналiтичнi коди ;"+m_list_scht+";рахункiв")
  ENDIF

  IF .NOT.l_exit
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf1
  ZAP
  INDEX ON buf1->dbt+buf1->level TO (m_mash+"m"+m_num_mash)
  SELE buf
  SET INDEX TO
  m_gauge:=InitGauge("Пiдрахунок пiдсумкiв машинограми N 75")
  buf->(DBGOTOP())
  DO WHILE .NOT.buf->(EOF())
        // Определить входящее сальдо свернутое или нет
        m_type:=" "
        FOR i:=LEN(buf->dbt) TO 2 STEP -1
          IF Sp11->(DS(PADR(LEFT(buf->dbt,i),7)))
             m_type:=Sp11->type2
            EXIT
          ENDIF
        NEXT
        IF EMPTY(m_type) // Ну не нашли в справочнике
          IF AT(LEFT(buf->dbt,2),m_list_scht)==0
            m_list_scht+=LEFT(buf->dbt,2)+","
            DispError("Не визначен тип аналiтичного рахунку "+LEFT(buf->dbt,2))
          ENDIF
          m_type:="З" //По умолчанию свернутое
        ENDIF
     /* Для отладки
     buf->type:=m_type
     buf->type1:="*"
     */
    // РАСЧЕТ ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО исходных строк
         DO CASE
          CASE m_type="З"  // Свернутое сальдо
            buf->indbstm:=buf->indbstm-buf->incrstm
            buf->incrstm:=0
            IF buf->indbstm<0
              buf->incrstm:=ABS(buf->indbstm)
              buf->indbstm:=0
            ENDIF
            m_sum:=buf->indbstm-buf->incrstm+buf->dbstm-buf->crstm
            IF m_sum<0
              buf->outcrstm:=ABS(m_sum)
            ELSE
              buf->outdbstm:=m_sum
            ENDIF
          CASE m_type="Д" //Дебетовое сальдо

            buf->indbstm-=buf->incrstm
            buf->incrstm:=0
            buf->outdbstm:=buf->indbstm+buf->dbstm-buf->crstm

          CASE m_type="К" //Кредитовое сальдо
            buf->incrstm-=buf->indbstm
            buf->indbstm:=0
            buf->outcrstm:=buf->incrstm-buf->dbstm+buf->crstm
          CASE m_type="Р" // Развернутое
            buf->outdbstm:=buf->indbstm+buf->dbstm
            buf->outcrstm:=buf->incrstm+buf->crstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            IF buf->indbstm<0
              buf->incrstm:=ABS(buf->indbstm)
              buf->indbstm:=0
            ENDIF
            m_sum:=buf->indbstm-buf->incrstm+buf->dbstm-buf->crstm
            IF m_sum<0
              buf->outcrstm:=ABS(m_sum)
            ELSE
              buf->outdbstm:=m_sum
            ENDIF
        ENDCASE
    //Защелка на счет зарплаты
    IF IsZrpl(buf->dbt)
            buf->indbstm:=0
            buf->incrstm:=0
            buf->outdbstm:=0
            buf->outcrstm:=0
    ENDIF
    //КОНЕЦ РАСЧЕТА ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО
     // Занесение итогов
     IF a_total[1,2]<>"Z"
        FOR i:=4 TO LEN(RTRIM(buf->dbt))-1
          IF sp11->(DS(PADR(LEFT(buf->dbt,i),7)))
              sp44->(DS(PADR(LEFT(buf->dbt,i),7)))
              m75dbap(LEFT(LEFT(buf->dbt,i)+REPLICATE(R_CH,7),7),"1",sp11->type1)
          ENDIF
        NEXT
      ENDIF
      // СУБСЧЕТА
      IF a_total[2,2]<>"Z"
        Sp44->(DS(LEFT(buf->dbt,3)+SPACE(4)))
        IF .NOT.Sp11->(DS(LEFT(buf->dbt,3)+SPACE(4)))
          Sp11->(DS(LEFT(buf->dbt,2)+SPACE(5)))
        ENDIF

        m75dbap(LEFT(buf->dbt,3)+REPLICATE(R_CH,4),"2",sp11->type1)
     ENDIF
      // СЧЕТА
      IF a_total[3,2]<>"Z"
        Sp44->(DS(LEFT(buf->dbt,2)+SPACE(5)))
        Sp11->(DS(LEFT(buf->dbt,2)+SPACE(5)))
        m75dbap(LEFT(buf->dbt,2)+REPLICATE(R_CH,5),"3",sp11->type1)
     ENDIF
    buf->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,buf->(RECNO()/LASTREC()))
  ENDDO
// Занесение сальдо по 70 счету

IF buf1->(DS(LEFT(SCHT_ZRPL+REPLICATE(R_CH,7),7)))
  NET USE (m_mainpath+"d52") NEW READONLY
  LOCATE FOR d52->subsch == '700'.AND.d52->month == mnt_month(m_mnt1)-1
   IF FOUND()
      buf1->incrstm:=d52->sumc
      buf1->indbstm:=d52->sumd
      s2:=d52->sumc
      s1:=d52->sumd
   ELSE
      buf1->incrstm:=0
      buf1->indbstm:=0
      s1:=0
      s2:=0
   ENDIF
   LOCATE FOR d52->subsch == '700'.AND.d52->month == mnt_month(m_mnt1)
   IF FOUND()
      buf1->outcrstm:=d52->sumc
      buf1->outdbstm:=d52->sumd
      s4:=d52->sumc
      s3:=d52->sumd
   ELSE
      buf1->outcrstm:=0
      buf1->outdbstm:=0
      s3:=0
      s4:=0
   ENDIF
   i:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm-buf1->outdbstm+buf1->outcrstm
   IF i<>0
         DispError(" Рахунок "+SCHT_ZRPL+ " не пiйшов на сумму;"+SumToSTR(i,14))
  ENDIF
  IF sp11->(DS(PADR(LEFT(SCHT_ZRPL,2),7)))
        sp44->(DS(PADR(LEFT(SCHT_ZRPL,2),7)))
        m75db70(LEFT(LEFT(SCHT_ZRPL,2)+REPLICATE(R_CH,7),7),"3",sp11->type1,s1,s2,s3,s4)
  ENDIF

CLOSE d52
ENDIF
buf1->(DBGOTOP())
DO WHILE .NOT.buf1->(EOF())
  IF buf1->type="З"  // Свернутое сальдо
            IF buf1->indbstm<0
              buf1->incrstm:=ABS(buf1->indbstm)
              buf1->indbstm:=0
            ENDIF
            m_sum:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm
            IF m_sum<0
              buf1->outcrstm:=ABS(m_sum)
              buf1->outdbstm:=0
            ELSE
              buf1->outdbstm:=m_sum
              buf1->outcrstm:=0
            ENDIF
  ENDIF
IF buf1->level=="3" // Суммарный итог вытаскиваем с счетов
  s_indb+=buf1->indbstm
  s_db+=buf1->dbstm
  s_outdb+=buf1->outdbstm
  s_incr+=buf1->incrstm
  s_cr+=buf1->crstm
  s_outcr+=buf1->outcrstm
ENDIF
  buf1->(DBSKIP())
ENDDO
      // ПО ПIДПРИЄМСТВУ
 IF a_total[4,2]<>"Z"
    buf1->(DBAP())
    buf1->level:="4"
    buf1->dbt:=REPLICATE(R_CH,7)
    buf1->indbstm  :=s_indb
    buf1->dbstm    :=s_db
    buf1->outdbstm :=s_outdb
    buf1->incrstm  :=s_incr
    buf1->crstm    :=s_cr
    buf1->outcrstm :=s_outcr
  ENDIF


 ENDIF // l_exit

  IF .NOT.EMPTY(m_list_scht)
    IF LEN(m_list_scht)>60
      m_list_scht:=LEFT(m_list_scht,60)
    ENDIF

    DispError("Не визначенi аналiтичнi коди ;"+m_list_scht+";рахункiв")
  ENDIF

Close Sp11
Close buf
Close buf1
USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
INDEX ON buf->dbt+buf->level TO (m_mash+"m"+m_num_mash)

CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC Function IsAccount(m_dbt)
Sp11->(DS(LEFT(m_dbt,2)))
IF sp11->type1=="П" // Позабалансовий
  RETURN .f.
ENDIF
RETURN .T.

STATIC Function m75dbap(m_dbt,m_level,m_type)

IF .not.buf1->(DS(m_dbt+m_level))
    buf1->(DBAP())
    buf1->level:=m_level
    buf1->dbt:=m_dbt
    buf1->name:=Sp44->naim7
    buf1->type:=m_type
ENDIF
buf1->crstm+=buf->crstm
buf1->dbstm+=buf->dbstm
DO CASE
  CASE buf1->type="З"  // Свернутое сальдо
    // Все в дебет а если получиться отрицательное перенесем в кредит
    buf1->indbstm+=buf->indbstm-buf->incrstm
    buf1->outdbstm+=buf->outdbstm-buf->outcrstm
  CASE buf1->type="Д" //Дебетовое сальдо
    buf1->indbstm+=buf->indbstm-buf->incrstm
    buf1->outdbstm+=buf->outdbstm-buf->outcrstm
  CASE buf1->type="К" //Кредитовое сальдо
    buf1->incrstm+=buf->incrstm-buf->indbstm
    buf1->outcrstm+=buf->outcrstm-buf->outdbstm
  CASE buf1->type="Р" // Развернутое
    buf1->incrstm+=buf->incrstm
    buf1->indbstm+=buf->indbstm
    buf1->outcrstm+=buf->outcrstm
    buf1->outdbstm+=buf->outdbstm
  OTHERWISE  //А это шо такое - ну ладно будет свернутым
    buf1->indbstm+=buf->indbstm-buf->incrstm
    buf1->outdbstm+=buf->outdbstm-buf->outcrstm
ENDCASE
RETURN .T.

STATIC Function m75db70(m_dbt,m_level,m_type,s1,s2,s3,s4)

IF .not.buf1->(DS(m_dbt+m_level))
    buf1->(DBAP())
    buf1->level:=m_level
    buf1->dbt:=m_dbt
    buf1->name:=Sp44->naim7
    buf1->type:=m_type
ENDIF
DO CASE
  CASE buf1->type="З"  // Свернутое сальдо
    // Все в дебет а если получиться отрицательное перенесем в кредит
    buf1->indbstm+=s1-s2
    buf1->outdbstm+=s3-s4
  CASE buf1->type="Д" //Дебетовое сальдо
    buf1->indbstm+=s1-s2
    buf1->outdbstm+=s3-s4
  CASE buf1->type="К" //Кредитовое сальдо
    buf1->incrstm+=s2-s1
    buf1->outcrstm+=s4-s3
  CASE buf1->type="Р" // Развернутое
    buf1->incrstm+=s2
    buf1->indbstm+=s1
    buf1->outcrstm+=s4
    buf1->outdbstm+=s3
  OTHERWISE  //А это шо такое - ну ладно будет свернутым
    buf1->indbstm+=s1-s2
    buf1->outdbstm+=s3-s4
ENDCASE
RETURN .T.


Function RMs70()
  LOCAL l_first:=.t.,n_error:=0,m_kod,m_scht,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_name,m_sum

  LOCAL m_num_mash:="70",a_files:={},l_exit:=.f.,j
  LOCAL m_list_scht:="",m_type
  LOCAL  s_indb:=0,s_db:=0,s_outdb:=0,;
  s_incr:=0,s_cr:=0,s_outcr:=0

// 1-й шаг  ввести расчетный период
IF .NOT.MsReadMnt(m_num_mash,@m_scht,@m_kod,@m_mnt1,@m_mnt2,a_files,.f.)
  return .f.
ENDIF
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  NET USE (m_sprpath+"sp11") INDEX (m_sprpath+"sp11") NEW READONLY
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->kopr+buf->crt+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)
  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 70")
  DO WHILE .NOT. Fp2->(EOF())
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
         IF LEFT(fp2->dbt,2)<>SCHT_OST.AND.LEFT(fp2->crt,2)<>SCHT_OST
          // обработка дебета
            FOR i:=LEN(fp2->dbt) TO 3 STEP -1
              IF Sp11->(DS(PADR(LEFT(fp2->dbt,i),7)))
                // СУБСЧЕТ - КОД ОПЕРАЦИИ- СУБСЧЕТ
                IF a_total[1,2]<>"Z"
                FOR j:=LEN(fp2->crt) TO 3 STEP -1
                  IF Sp11->(DS(PADR(LEFT(fp2->crt,j),7)))
                    // занести в базу
                    m70dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),fp2->kopr,LEFT(LEFT(fp2->crt,j)+REPLICATE(R_CH,7),7),"1",{||sp44->(DBSEEK(PADR(LEFT(fp2->crt,j),7))),sp44->naim7})
                  ENDIF
                NEXT
                ENDIF
                // СУБСЧЕТ - КОД ОПЕРАЦИИ
                IF a_total[2,2]<>"Z"
                    m70dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),fp2->kopr,REPLICATE(R_CH,7),"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
                ENDIF
                // СУБСЧЕТ
                IF a_total[3,2]<>"Z"
                    m70dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,2),REPLICATE(R_CH,7),"3",{||sp44->(DBSEEK(PADR(LEFT(fp2->dbt,i),7))),sp44->naim7})
                ENDIF
              ENDIF
            NEXT
          // СЧЕТ - КОД ОПЕРАЦИИ- СЧЕТ
          IF a_total[4,2]<>"Z"
            m70dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),fp2->kopr,LEFT(fp2->crt,2)+REPLICATE(R_CH,5),"4",{||sp44->(DBSEEK(PADR(LEFT(fp2->crt,2),7))),sp44->naim7})
          ENDIF
          // СЧЕТ - КОД ОПЕРАЦИИ
          IF a_total[5,2]<>"Z"
            m70dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),fp2->kopr,REPLICATE(R_CH,7),"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
          ENDIF
          // СЧЕТ
          IF a_total[6,2]<>"Z"
            m70dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,2),REPLICATE(R_CH,7),"6",{||sp44->(DBSEEK(PADR(LEFT(fp2->dbt,2),7))),sp44->naim7})
          ENDIF
          // общий
          IF a_total[7,2]<>"Z"
            m70dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,2),REPLICATE(R_CH,7),"6",{||""})
          ENDIF


          // обработка кредита
            FOR i:=LEN(fp2->crt) TO 3 STEP -1
              IF Sp11->(DS(PADR(LEFT(fp2->crt,i),7)))
                // СУБСЧЕТ - КОД ОПЕРАЦИИ- СУБСЧЕТ
                IF a_total[1,2]<>"Z"
                FOR j:=LEN(fp2->dbt) TO 3 STEP -1
                  IF Sp11->(DS(PADR(LEFT(fp2->dbt,j),7)))
                    // занести в базу
                    m70crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),fp2->kopr,LEFT(LEFT(fp2->dbt,j)+REPLICATE(R_CH,7),7),"1",{||sp44->(DBSEEK(PADR(LEFT(fp2->dbt,j),7))),sp44->naim7})
                  ENDIF
                NEXT
                ENDIF
                // СУБСЧЕТ - КОД ОПЕРАЦИИ
                IF a_total[2,2]<>"Z"
                    m70crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),fp2->kopr,REPLICATE(R_CH,7),"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
                ENDIF
                // СУБСЧЕТ
                IF a_total[3,2]<>"Z"
                    m70crap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,2),REPLICATE(R_CH,7),"3",{||sp44->(DBSEEK(PADR(LEFT(fp2->crt,i),7))),sp44->naim7})
                ENDIF
              ENDIF
            NEXT
          // СЧЕТ - КОД ОПЕРАЦИИ- СЧЕТ
          IF a_total[4,2]<>"Z"
            m70crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),fp2->kopr,LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),"4",{||sp44->(DBSEEK(PADR(LEFT(fp2->dbt,2),7))),sp44->naim7})
          ENDIF
          // СЧЕТ - КОД ОПЕРАЦИИ
          IF a_total[5,2]<>"Z"
            m70crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),fp2->kopr,REPLICATE(R_CH,7),"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a})
          ENDIF
          // СЧЕТ
          IF a_total[6,2]<>"Z"
            m70crap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,2),REPLICATE(R_CH,7),"6",{||sp44->(DBSEEK(PADR(LEFT(fp2->crt,2),7))),sp44->naim7})
          ENDIF
          // общий
          IF a_total[7,2]<>"Z"
            m70crap(REPLICATE(R_CH,7),REPLICATE(R_CH,2),REPLICATE(R_CH,7),"6",{||""})
          ENDIF

        ENDIF
      ENDIF

    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
Close Sp11
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC Function m70dbap(m_dbt,m_kopr,m_crt,m_level,b_name)
//обработка дебета
      IF .not.buf->(DS(m_dbt+m_kopr+m_crt+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->crt:=m_crt
        buf->kopr:=m_kopr
        buf->name:=EVAL(b_name)
      ENDIF
      buf->dbkvo +=fp2->kvo
      buf->dbstm +=fp2->stm
      buf->dbglv +=fp2->glv
      buf->dbkvo2+=fp2->kvo2
RETURN .T.
STATIC Function m70crap(m_dbt,m_kopr,m_crt,m_level,b_name)
//обработка кредита
      IF .not.buf->(DS(m_dbt+m_kopr+m_crt+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->crt:=m_crt
        buf->kopr:=m_kopr
        buf->name:=EVAL(b_name)
      ENDIF
      buf->crkvo +=fp2->kvo
      buf->crstm +=fp2->stm
      buf->crglv +=fp2->glv
      buf->crkvo2+=fp2->kvo2
RETURN .T.
Function RMs76()
  LOCAL l_first:=.t.,n_error:=0,m_kod,m_scht,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_crt,l_641,;
  m_scht1:="90",m_scht2:="70"


  LOCAL m_num_mash:="76",a_files:={},l_exit:=.f.,s_kopr
  LOCAL s_nds641,s_nds643,m_nds,b_kopr:={||IF(AT(fp2->kopr,s_kopr)<>0,.f.,.t.)}
// 1-й шаг ввести расчетный период
IF .NOT.MsReadMnt(m_num_mash,@m_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  IF .not.EMPTY(m_scht)
    m_crt:=ALLTRIM(TOKEN(m_scht,".,",1))
    IF .NOT.EMPTY(m_crt)
      m_scht1:=m_crt
    ENDIF
    m_crt:=ALLTRIM(TOKEN(m_scht,".,",2))
    IF .NOT.EMPTY(m_crt)
      m_scht2:=m_crt
    ENDIF
   ENDIF
  // необходимо определить , что не должно суммироваться в количество
  NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  s_kopr:=RESTVAR1("s_kopr","MS") //количество не должно суммироваться
  s_nds641:=RESTVAR1("s_nds641","MS") //НДС на 64-1
  s_nds643:=RESTVAR1("s_nds643","MS") //НДС на 64-3
  m_nds:=RESTVAR1("m_nds","MS")  //Процент по НДС если 0 то НДС не контролируеться
  CLOSE myvar
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kopr+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 76")
  DO WHILE .NOT. Fp2->(EOF())
    IF (LEFT(Fp2->dbt,2)==m_scht1.AND.LEFT(fp2->crt,2)<>SCHT_OST);  //Дебет 90
      .or.(LEFT(Fp2->crt,2)==m_scht2.AND.LEFT(fp2->dbt,2)<>SCHT_OST) ;  // Кредит 70
      .or.(LEFT(Fp2->dbt,2)==m_scht2.AND.LEFT(fp2->crt,LEN(s_nds641))==s_nds641); // НДС дебета 70
      .or.(LEFT(Fp2->dbt,2)==m_scht2.AND.LEFT(fp2->crt,LEN(s_nds643))==s_nds643) // НДС дебета 70
      // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)  //Документ из расчетного периода
        IF LEFT(Fp2->dbt,2)==m_scht1.AND.LEFT(fp2->crt,2)<>SCHT_OST
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->dbt:=fp2->dbt
             buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->glv<>0;l_glv:="1";ENDIF
             IF m_kod=="2"
                Sp44->(DS(Fp2->crt))
                buf->name:=Fp2->crt+ " " +Sp44->naim7
              ELSE
                IF EMPTY(Fp2->cod2)
                  Sp44->(DS(Fp2->crt))
                  buf->name:=Fp2->crt+ " " +Sp44->naim7
                ELSE
                  buf->name:=Fp2->crt+ " " +Fp2->cod2+" "+AnCodName(fp2->crt,fp2->cod2)
                ENDIF
             ENDIF
          ENDIF
          IF a_total[2,2]<>"Z"  // Итог по операции
            m76dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.})
          ENDIF
          IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
            .AND.a_total[3,2]<>"Z"  // Итог по АНАЛИТИЧЕСКОМУ КОДУ
             m76dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),REPLICATE(R_CH,2),"3",{||AnCodName(fp2->dbt,fp2->cod1)},b_kopr)
          ENDIF
          // Итог по аналитическому счету
          IF a_total[4,2]<>"Z"
             m76dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),"4",{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},b_kopr)
          ENDIF
          // Итоги по дереву СУБСЧЕТОВ
          IF a_total[5,2]<>"Z"
            FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
              IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
                  m76dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",{||Sp44->naim7},b_kopr)
                  m76dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.})
              ENDIF
            NEXT
          ENDIF
          // Итог по счету
          IF a_total[6,2]<>"Z"
            m76dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"6",{||Sp44->naim7},b_kopr)
            m76dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.})
          ENDIF
       ENDIF //Завершили выборку дебета
      IF LEFT(Fp2->crt,2)==m_scht2.AND.LEFT(fp2->dbt,2)<>SCHT_OST  // Кредит 70
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->dbt:=m_scht1+SUBSTR(fp2->crt,3)
             buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr
             buf->crkvo:=fp2->kvo
             buf->crkvo2:=fp2->kvo2
             buf->crstm:=fp2->stm
             buf->crglv:=fp2->glv
            IF fp2->glv<>0;l_glv:="1";ENDIF
           IF m_kod=="2"
                Sp44->(DS(Fp2->dbt))
                buf->name:=Fp2->dbt+ " " +Sp44->naim7
              ELSE
                IF EMPTY(Fp2->cod1)
                  Sp44->(DS(Fp2->dbt))
                  buf->name:=Fp2->dbt+ " " +Sp44->naim7
                ELSE
                  buf->name:=Fp2->dbt+ " " +Fp2->cod1+" "+AnCodName(fp2->dbt,fp2->cod1)
                ENDIF
             ENDIF
          ENDIF
          m_crt:=m_scht1+SUBSTR(fp2->crt,3)
          IF a_total[2,2]<>"Z"  // Итог по операции
            m76crap(m_crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.})
          ENDIF
          IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
            .AND.a_total[3,2]<>"Z"  // Итог по АНАЛИТИЧЕСКОМУ КОДУ
             m76crap(m_crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),REPLICATE(R_CH,2),"3",{||AnCodName(fp2->crt,fp2->cod2)},b_kopr)
          ENDIF
          // Итог по аналитическому счету
          IF a_total[4,2]<>"Z"
             m76crap(m_crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),"4",{||Sp44->(DBSEEK(m_crt)),Sp44->naim7},b_kopr)
          ENDIF
          // Итоги по дереву СУБСЧЕТОВ
          IF a_total[5,2]<>"Z"
            FOR i:=3 TO LEN(RTRIM(m_crt))-1
              IF sp44->(DS(PADR(LEFT(m_crt,i),7)))
                  m76crap(LEFT(LEFT(m_crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",{||Sp44->naim7},b_kopr)
                  m76crap(LEFT(LEFT(m_crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.})
              ENDIF
            NEXT
          ENDIF
          // Итог по счету
          IF a_total[6,2]<>"Z"
            m76crap(LEFT(m_crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"6",{||Sp44->naim7},b_kopr)
            m76crap(LEFT(m_crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},{||.t.})
          ENDIF
       ENDIF //Конец выборки 70 счета
        IF (LEFT(Fp2->dbt,2)==m_scht2.AND.LEFT(fp2->crt,LEN(s_nds641))==s_nds641); // НДС дебета 70
           .or.(LEFT(Fp2->dbt,2)==m_scht2.AND.LEFT(fp2->crt,LEN(s_nds641))==s_nds643) // НДС дебета 70
          l_641:=IF(LEFT(fp2->crt,LEN(s_nds641))==s_nds641,.t.,.f.)
          m_crt:=m_scht1+SUBSTR(fp2->dbt,3)
          IF a_total[2,2]<>"Z"  // Итог по операции
            m76ndsap(m_crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_641,{||.f.})
          ENDIF
          IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
            .AND.a_total[3,2]<>"Z"  // Итог по АНАЛИТИЧЕСКОМУ КОДУ
             m76ndsap(m_crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),REPLICATE(R_CH,2),"3",{||AnCodName(fp2->crt,fp2->cod2)},l_641,{||.f.})
          ENDIF
          // Итог по аналитическому счету
          IF a_total[4,2]<>"Z"
             m76ndsap(m_crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),"4",{||Sp44->(DBSEEK(m_crt)),Sp44->naim7},l_641,{||.f.})
          ENDIF
          // Итоги по дереву СУБСЧЕТОВ
          IF a_total[5,2]<>"Z"
            FOR i:=3 TO LEN(RTRIM(m_crt))-1
              IF sp44->(DS(PADR(LEFT(m_crt,i),7)))
                  m76ndsap(LEFT(LEFT(m_crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"5",{||Sp44->naim7},l_641,{||.f.})
                  m76ndsap(LEFT(LEFT(m_crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_641,{||.f.})
              ENDIF
            NEXT
          ENDIF
          // Итог по счету
          IF a_total[6,2]<>"Z"
            m76ndsap(LEFT(m_crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),"6",{||Sp44->naim7},l_641,{||.f.})
            m76ndsap(LEFT(m_crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_641,{||.f.})
          ENDIF //Конец выборки НДС 70 счета

        ENDIF //КОНЕЦ ВЫБОРКИ НДС
     ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
return .t.
STATIC FUNCTION  m76dbap(m_dbt,m_cod1,m_kopr,m_level,b_name,b_kvo)
  IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_level))
    buf->(DBAP())
    buf->level:=m_level
    buf->dbt:=m_dbt
    buf->cod1:=m_cod1
    buf->kopr:=m_kopr
    buf->name:=EVAL(b_name)
  ENDIF
IF EVAL(b_kvo)
  buf->dbkvo+=fp2->kvo
  buf->dbglv+=fp2->glv
ENDIF

  buf->dbstm+=fp2->stm
RETURN .T.
STATIC FUNCTION  m76crap(m_dbt,m_cod1,m_kopr,m_level,b_name,b_kvo)
  IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_level))
    buf->(DBAP())
    buf->level:=m_level
    buf->dbt:=m_dbt
    buf->cod1:=m_cod1
    buf->kopr:=m_kopr
    buf->name:=EVAL(b_name)
  ENDIF
IF EVAL(b_kvo)
  buf->crkvo2+=fp2->kvo2
  buf->crkvo+=fp2->kvo
  buf->crglv+=fp2->glv
ENDIF
  buf->crstm+=fp2->stm
RETURN .T.
STATIC FUNCTION  m76ndsap(m_dbt,m_cod1,m_kopr,m_level,b_name,l_641)
  IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_level))
    buf->(DBAP())
    buf->level:=m_level
    buf->dbt:=m_dbt
    buf->cod1:=m_cod1
    buf->kopr:=m_kopr
    buf->name:=EVAL(b_name)
  ENDIF
  IF l_641
    buf->stm64_1+=fp2->stm
  ELSE
    buf->stm64_3+=fp2->stm
  ENDIF
RETURN .T.
STATIC Function GetMntSvr(m_mnt1,m_mnt2,m_scht,m_cod,m_kod)
  Local m_month1:="01",m_month2:="  ",m_year1:="    ",m_year2:="    ",;
  Getlist:={},m_month,n_win
  IF MONTH(DATE())==1
    m_year1:=m_year2:=STR(YEAR(DATE())-1,4)
    m_month2:="12"
  ELSE
    m_year1:=m_year2:=STR(YEAR(DATE()),4)
    m_month2:=STRZERO(MONTH(DATE())-1,2)
  ENDIF
  n_win:=InitScr("GETMNTSVR")
  SET ESCAPE ON
  SET CURSOR ON
  m_scht:=SPACE(7)
  m_cod:=SPACE(10)
  @2,7 get m_month1 PICTURE "99" COLOR "gr+/B*,gr+/n" VALID (m_month1<"13".and.m_month1>"00")
  @2,17 get m_year1 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2020".and.m_year1>="1999")
  @3,7 get m_month2 PICTURE "99" COLOR "gr+/b*,gr+/n" VALID (m_month2<"13".and.m_month2>"00")
  @3,17 get m_year2 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2020".and.m_year1>="1999")
  @15,9 get m_scht PICTURE "XXXXXXX" COLOR "gr+/b*,gr+/n" VALID Sp44->(Sp_vl("SP44",,15,20,"Sp44->naim7","Gr+/b"))
  @16,9 get m_cod  COLOR "gr+/b*,gr+/n" VALID (EMPTY(m_cod).OR.AnCodValid(m_scht,m_cod,16,20,,34)) WHEN PreAnCod(m_scht)
  GetList[LEN(GetList)]:Block:={|x|IF(x==NIL,AnalCod(x,m_scht,m_cod),m_cod:=PADR(x,10))}
  @17,27 get m_kod PICTURE "9" COLOR "gr+/b*,gr+/n" VALID (m_kod==" " .or.m_kod=="1" .or.m_kod=="2")
  READ

  SET CURSOR OFF
  m_mnt1:=RIGHT(m_year1,2)+m_month1
  m_mnt2:=RIGHT(m_year2,2)+m_month2
  Wclose(n_win)
  IF LASTKEY() = K_ESC
    RETURN .F.
  ENDIF
return .t.
Function RMs74()
  LOCAL l_first:=.t.,n_error:=0,m_kod,m_scht,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_mnt3:=SPACE(4),m_gauge,a_total:={},m_cod

  LOCAL m_num_mash:="74",a_files:={},l_exit:=.f.
  LOCAL b_block,b_dbt,b_crt

//  WaitMessage("Розрахунок 74-й машинограми")

// 1-й шаг ввести расчетный период
  Fp1SetIndex(a_files)
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh") READONLY new
  msh->(DS(" "+m_num_mash))
  m_kod:=msh->kod
  CLOSE msh
  IF .NOT.GetMntSvr(@m_mnt1,@m_mnt2,@m_scht,@m_cod,@m_kod)
    SCLOSEFILES(a_files)
    CLOSE base fp2,fp1,Firm01,Bank01,Kaptka1
    return .f.
  ENDIF
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  FILECOPY(m_mash+"m"+m_num_mash+".dbf",m_mash+"m"+m_num_mash+"a.dbf")
  USE (m_mash+"m"+m_num_mash+"a") NEW ALIAS buf
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 74")
  IF EMPTY(m_cod)
    b_dbt:={||(Fp2->dbt==m_scht)}
    b_crt:={||(Fp2->crt==m_scht)}
  ELSE
    b_dbt:={||(Fp2->dbt==m_scht.AND.m_cod==Fp2->cod1)}
    b_crt:={||(Fp2->crt==m_scht.AND.m_cod==Fp2->cod1)}
  ENDIF
    b_block:={||EVAL(b_dbt).or.EVAL(b_crt)}


  DO WHILE .NOT. Fp2->(EOF())
    IF EVAL(b_block)   // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF

         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА ИЛИ ГОДА то есть подходит по дате

      IF fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2
        // приход
         IF EVAL(b_dbt)
          buf->(DBAP())
          buf->level:="1"
          buf->npch:=fp1->npch
          buf->ndoc:=fp1->ndoc
          buf->ndoc1:=fp1->ndoc1
          buf->ndog:=fp1->ndog
          buf->ddoc:=fp1->ddoc
          buf->mnt:= fp1->mnt
          buf->dbt:=fp2->crt
          buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
          buf->kvo:=fp2->kvo
          buf->kvo2:=fp2->kvo2
          buf->dbstm:=fp2->stm
          buf->glv:=fp2->glv
          IF fp2->glv<>0;l_glv:="1";ENDIF
          buf->kopr:=fp2->kopr
          //расшифровка корсчета
          IF .not.EMPTY(Fp2->cod2).AND.(m_kod==" ".OR.m_kod=="1")
            buf->name:=AnCodName(fp2->crt,fp2->cod2)
          ELSE
            Sp44->(DS(Fp2->crt))
            buf->name:=Sp44->naim7
          ENDIF
         ENDIF // ПРИХОД
          // расход
         IF EVAL(b_crt)
          buf->(DBAP())
          buf->level:="1"
          buf->npch:=fp1->npch
          buf->ndoc:=fp1->ndoc
          buf->ndoc1:=fp1->ndoc1
          buf->ndog:=fp1->ndog
          buf->ddoc:=fp1->ddoc
          buf->mnt:= fp1->mnt
          buf->dbt:=fp2->dbt
          buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
          buf->kvo:=fp2->kvo
          buf->kvo2:=fp2->kvo2
          buf->crstm:=fp2->stm
          buf->glv:=fp2->glv
          IF fp2->glv<>0;l_glv:="1";ENDIF
          buf->kopr:=fp2->kopr
          //расшифровка корсчета
          IF .not.EMPTY(Fp2->cod1).AND.(m_kod==" ".OR.m_kod=="1")
            buf->name:=AnCodName(fp2->dbt,fp2->cod1)
          ELSE
            Sp44->(DS(Fp2->dbt))
            buf->name:=Sp44->naim7
          ENDIF
         ENDIF // РАСХОД
      ENDIF
    ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
USE (m_mash+"m"+m_num_mash) NEW ALIAS buf1
ZAP
//SET PRINTER TO "dddd.txt"
//SET PRINTER ON
INDEX ON buf1->mnt+buf1->level TO (m_mash+"m"+m_num_mash) // +buf1->(DTOS(BUF1->ddoc))
IF .NOT.l_exit
    //рассчитываем исходящее сальдо по месяцам
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
        // Перенос первичных документов
        IF a_total[2,2]<>"Z" // Расчитывать итог за месяц
           IF .NOT.buf1->(DS(buf->mnt+"2"))
            buf1->(DBAP())
            buf1->mnt:=buf->mnt
            buf1->level:="2"
            buf1->name:=" За "+mnt_dtoc(buf->mnt)
           ENDIF
          buf1->crstm+=buf->crstm
          buf1->dbstm+=buf->dbstm
        ENDIF
m_mnt3:=buf1->mnt
//?"=========",buf1->mnt
        IF a_total[3,2]<>"Z" // Расчитывать итог за месяц
DO WHILE(m_mnt3<=m_mnt2)
//?"mn3=",m_mnt3

           IF .NOT.buf1->(DS(m_mnt3+"3"))
            buf1->(DBAP())
            buf1->mnt:=m_mnt3
            buf1->level:="3"
            buf1->name:=" Итог "+mnt_dtoc(m_mnt3)
           ENDIF
          buf1->crstm+=buf->crstm
          buf1->dbstm+=buf->dbstm
m_mnt3:=mnt_inc(m_mnt3)
ENDDO
        ENDIF
        IF a_total[4,2]<>"Z" // Расчитывать  общий итог
           IF .NOT.buf1->(DS(REPLICATE(R_CH,4)+"4"))
            buf1->(DBAP())
            buf1->mnt:=REPLICATE(R_CH,4)
            buf1->level:="4"
            IF  .NOT.EMPTY(m_cod)
//              buf1->name:=ALLTRIM(m_scht)+" "+ALLTRIM(m_cod)+" "+AnCodName(m_scht,m_cod)+" З "+mnt_dtoc(m_mnt1)+" по " +mnt_dtoc(m_mnt1)
              buf1->name:=ALLTRIM(m_scht)+" "+ALLTRIM(m_cod)+" "+AnCodName(m_scht,m_cod)+" З "+mnt_data(m_mnt1)+" по " +mnt_data(m_mnt1)
            ELSE
              Sp44->(DS(m_scht))
              buf1->name:=ALLTRIM(m_scht)+" "+ALLTRIM(Sp44->naim7)+" З "+mnt_data(m_mnt1)+" по " +mnt_data(m_mnt1)
            ENDIF
           ENDIF
          buf1->crstm+=buf->crstm
          buf1->dbstm+=buf->dbstm
        ENDIF
        IF a_total[1,2]<>"Z" // данную запись перенести в buf1
          buf1->(DBAP())
          FOR i:=1 TO buf->(FCOUNT())
            buf1->(FIELDPUT(i,buf->(FIELDGET(i))))
          NEXT
        ENDIF
        buf->(DBSKIP())
    ENDDO
    buf1->(DBGOTOP())
    DO WHILE .NOT.buf1->(EOF())
      IF buf1->level=="4".OR.buf1->level=="3".OR.buf1->level=="3"
        IF buf1->crstm>buf1->dbstm
          buf1->crstm:=buf1->crstm-buf1->dbstm
          buf1->dbstm:=0
        ELSE
          buf1->dbstm:=buf1->dbstm-buf1->crstm
          buf1->crstm:=0
      ENDIF
    endif
        buf1->(DBSKIP())
    ENDDO
    SELE buf1
    SET INDEX TO
    INDEX ON buf1->mnt+buf1->level+buf1->(DTOS(BUF1->ddoc)) TO (m_mash+"m"+m_num_mash)

ENDIF
//SET PRINTER OFF
//SET PRINTER TO

Close buf
Close buf1
USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC FUNCTION IsZrpl(m_dbt)
IF LEFT(m_dbt,LEN(SCHT_ZRPL))==SCHT_ZRPL
  RETURN .T.
ENDIF
RETURN .F.
Function RMs81()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={}

  LOCAL m_num_mash:="81",a_files:={},l_exit:=.f.,m_kopr2,m_ost66,l_month
//  WaitMessage("Розрахунок 81-й машинограми")
// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ для суммирования литров
  RESTMEM m_ost66  // Суммировать остатки или нет
  CLOSE myvar
  m_kopr2:=ALLTRIM(m_kopr2)
  m_koprgsm:=m_kopr2
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kopr+buf->brgd+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 81")
  DO WHILE .NOT. Fp2->(EOF())
    IF (IsScht(Fp2->dbt,a_scht).AND.LEFT(fp2->crt,2)<>m_ost66) // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF fp1->mnt<=m_mnt2  //Документ из расчетного периода
     l_month := IF (fp1->mnt>=m_mnt1,.t.,.f.)
     IF l_month  //Документ из расчетного периода
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->brgd:=fp2->brgd1
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
            ENDIF
              Sp01->(DS(buf->brgd))
              buf->name:=Sp01->naim1
        ENDIF
      ENDIF
      // Исходная строка машинограммы по бригадi
      m81dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,fp2->brgd1,"2",{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->Naim1},l_month)
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m81dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,REPLICATE(R_CH,2),"3",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
     ENDIF
     // Итог по аналитическому коду
    IF a_total[4,2]<>"Z".AND.m_kod<>"2"
       m81dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"4",{||AnCodName(fp2->dbt,fp2->cod1)},l_month)
    ENDIF

     // Итог по аналитическому счету
    IF a_total[5,2]<>"Z"
       m81dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"5",{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},l_month)
       IF m_kod<>"2"
        m81dbap(fp2->dbt,REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[6,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
        IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
          m81dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"6",{||Sp44->naim7},l_month)
          m81dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[7,2]<>"Z"
       m81dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"7",{||Sp44->(DBSEEK(LEFT(fp2->dbt,2)+SPACE(5))),Sp44->naim7},l_month)
       m81dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
    ENDIF
     // ОБЩИЙ Итог - не нужен не имеет смысла
    ENDIF  // конец учета затрат
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m81dbap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name,l_month)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_brgd+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
      IF l_month
        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        buf->dbkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->dbglv+=fp2->kvo2
        ENDIF
     ENDIF
    buf->crstm+=fp2->stm
    buf->crglv+=fp2->glv
    buf->crkvo+=fp2->kvo
    IF Fp2->kopr==m_koprgsm
      buf->crglv+=fp2->kvo2
    ENDIF
RETURN .T.
Function RMs82()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={}

  LOCAL m_num_mash:="82",a_files:={},l_exit:=.f.,m_kopr2,m_ost66,l_month
//  WaitMessage("Розрахунок 82-й машинограми")
// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_kopr2  // операция ГСМ для суммирования литров
  RESTMEM m_ost66  // Суммировать остатки или нет
  CLOSE myvar
  m_kopr2:=ALLTRIM(m_kopr2)
  m_koprgsm:=m_kopr2
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->kopr+buf->brgd+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 82")
  DO WHILE .NOT. Fp2->(EOF())
    IF (IsScht(Fp2->crt,a_scht).AND.LEFT(fp2->dbt,2)<>m_ost66) // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF fp1->mnt<=m_mnt2  //Документ из расчетного периода
     l_month := IF (fp1->mnt>=m_mnt1,.t.,.f.)
     IF l_month  //Документ из расчетного периода
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->brgd:=fp2->brgd2
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
            ENDIF
              Sp01->(DS(buf->brgd))
              buf->name:=Sp01->naim1
        ENDIF
      ENDIF
      // Исходная строка машинограммы по бригадi
      m82dbap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,fp2->brgd2,"2",{||Sp01->(DBSEEK(Fp2->brgd2)),Sp01->Naim1},l_month)
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m82dbap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,REPLICATE(R_CH,2),"3",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
     ENDIF
     // Итог по аналитическому коду
    IF a_total[4,2]<>"Z".AND.m_kod<>"2"
       m82dbap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"4",{||AnCodName(fp2->crt,fp2->cod2)},l_month)
    ENDIF

     // Итог по аналитическому счету
    IF a_total[5,2]<>"Z"
       m82dbap(fp2->crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"5",{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},l_month)
       IF m_kod<>"2"
        m82dbap(fp2->crt,REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[6,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
        IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
          m82dbap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"6",{||Sp44->naim7},l_month)
          m82dbap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[7,2]<>"Z"
       m82dbap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),REPLICATE(R_CH,2),"7",{||Sp44->(DBSEEK(LEFT(fp2->crt,2)+SPACE(5))),Sp44->naim7},l_month)
       m82dbap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,REPLICATE(R_CH,2),"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
    ENDIF
     // ОБЩИЙ Итог - не нужен не имеет смысла
    ENDIF  // конец учета затрат
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m82dbap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name,l_month)
      IF .not.buf->(DS(m_dbt+m_cod1+m_kopr+m_brgd+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
      IF l_month
        buf->dbstm+=fp2->stm
        buf->dbglv+=fp2->glv
        buf->dbkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->dbglv+=fp2->kvo2
        ENDIF
     ENDIF
    buf->crstm+=fp2->stm
    buf->crglv+=fp2->glv
    buf->crkvo+=fp2->kvo
    IF Fp2->kopr==m_koprgsm
      buf->crglv+=fp2->kvo2
    ENDIF
RETURN .T.
Function RMs83()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={},m_ost66

  LOCAL m_num_mash:="83",a_files:={},l_exit:=.f.,m_kopr2,l_month
//  WaitMessage("Розрахунок 83-й машинограми")
// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_ost66  // Суммировать остатки или нет
  RESTMEM m_kopr2  // операция ГСМ для суммирования литров
  CLOSE myvar
  m_kopr2:=ALLTRIM(m_kopr2)
  m_koprgsm:=m_kopr2
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->brgd+buf->dbt+buf->cod1+buf->kopr+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 83")
  DO WHILE .NOT. Fp2->(EOF())
    IF (IsScht(Fp2->dbt,a_scht).AND.LEFT(fp2->crt,2)<>m_ost66) // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF fp1->mnt<=m_mnt2  //Документ из расчетного периода
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF fp2->kopr==m_koprgsm.AND.fp2->kvo2<>0
        l_glv:="1"
      ENDIF
     l_month := IF (fp1->mnt>=m_mnt1,.t.,.f.)
          IF a_total[1,2]<>"Z".AND.l_month  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->dbt
             buf->cod1:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->brgd:=fp2->brgd1
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
              l_glv:="1"
            ENDIF
              Sp05->(DS(buf->kopr))
              buf->name:=Sp05->naim5a
          ENDIF
      // Исходная строка машинограммы по операцiї
      m83dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,fp2->brgd1,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
     // Итог по аналитическому коду
      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m83dbap(fp2->dbt,GetAnCod(Fp2->dbt,fp2->cod1,m_kod),fp2->kopr,fp2->brgd1,"3",{||AnCodName(fp2->dbt,fp2->cod1)},l_month)
     ENDIF
     // Итог по аналитическому счету
    IF a_total[4,2]<>"Z"
       m83dbap(fp2->dbt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"4",{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},l_month)
       IF m_kod<>"2"
        m83dbap(fp2->dbt,REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"4",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[5,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->dbt))-1
        IF sp44->(DS(PADR(LEFT(fp2->dbt,i),7)))
          m83dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"5",{||Sp44->naim7},l_month)
          m83dbap(LEFT(LEFT(fp2->dbt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[6,2]<>"Z"
       m83dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"6",{||Sp44->(DBSEEK(LEFT(fp2->dbt,2)+SPACE(5))),Sp44->naim7},l_month)
       m83dbap(LEFT(fp2->dbt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
    ENDIF
     // ОБЩИЙ Итог - по бригадi
    m83dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),Fp2->brgd1,"7",{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->Naim1},l_month)
    m83dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),fp2->kopr            ,Fp2->brgd1,"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)

    ENDIF  // конец учета затрат
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m83dbap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name,l_month)
      IF .not.buf->(DS(m_brgd+m_dbt+m_cod1+m_kopr+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
        IF l_month
          buf->dbstm+=fp2->stm
          buf->dbglv+=fp2->glv
          buf->dbkvo+=fp2->kvo
          IF Fp2->kopr==m_koprgsm
            buf->dbglv+=fp2->kvo2
          ENDIF
        ENDIF
        buf->crstm+=fp2->stm
        buf->crglv+=fp2->glv
        buf->crkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->crglv+=fp2->kvo2
        ENDIF
RETURN .T.

Function RMs84()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},a_scht:={},m_ost66

  LOCAL m_num_mash:="84",a_files:={},l_exit:=.f.,m_kopr2,l_month
//  WaitMessage("Розрахунок 84-й машинограми")
// 1-й шаг ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
  // необходимо определить , что не должно суммироваться в количество
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_ost66  // Суммировать остатки или нет
  RESTMEM m_kopr2  // операция ГСМ для суммирования литров
  CLOSE myvar
  m_kopr2:=ALLTRIM(m_kopr2)
  m_koprgsm:=m_kopr2
// СОЗДАТЬ СТРУКТУРУ
  CrStr(m_num_mash)
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
  ZAP
  INDEX ON buf->brgd+buf->dbt+buf->cod1+buf->kopr+buf->level TO (m_mash+"m"+m_num_mash)
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 84")
  DO WHILE .NOT. Fp2->(EOF())
    IF (IsScht(Fp2->crt,a_scht).AND.LEFT(fp2->dbt,2)<>m_ost66) // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
     IF fp1->mnt<=m_mnt2  //Документ из расчетного периода
      IF fp2->glv<>0
        l_glv:="1"
      ENDIF
      IF fp2->kopr==m_koprgsm.AND.fp2->kvo2<>0
        l_glv:="1"
      ENDIF
     l_month := IF (fp1->mnt>=m_mnt1,.t.,.f.)
          IF a_total[1,2]<>"Z".AND.l_month  // Заносить первичный документ
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ddoc:=fp1->ddoc
             buf->mnt:= fp1->mnt
             buf->dbt:=fp2->crt
             buf->cod1:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->brgd:=fp2->brgd1
             buf->kopr:=fp2->kopr
             buf->dbkvo:=fp2->kvo
             buf->dbstm:=fp2->stm
             buf->dbglv:=fp2->glv
            IF fp2->kopr==m_koprgsm
              buf->dbglv:=fp2->kvo2
              l_glv:="1"
            ENDIF
              Sp05->(DS(buf->kopr))
              buf->name:=Sp05->naim5a
          ENDIF
      // Исходная строка машинограммы по операцiї
      m84dbap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,fp2->brgd1,"2",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
     // Итог по аналитическому коду
      IF (m_kod=="1".OR.m_kod==" ");   // Использовать 17 значный код
        .AND.a_total[3,2]<>"Z" // Итог не отключен в настройке
        // Исходная строка машинограммы по коду операцiї
       m84dbap(fp2->crt,GetAnCod(Fp2->crt,fp2->cod2,m_kod),fp2->kopr,fp2->brgd1,"3",{||AnCodName(fp2->crt,fp2->cod2)},l_month)
     ENDIF
     // Итог по аналитическому счету
    IF a_total[4,2]<>"Z"
       m84dbap(fp2->crt,REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"4",{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},l_month)
       IF m_kod<>"2"
        m84dbap(fp2->crt,REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"4",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
      ENDIF
    ENDIF
    // Итоги по дереву СУБСЧЕТОВ
    IF a_total[5,2]<>"Z"
      FOR i:=3 TO LEN(RTRIM(fp2->crt))-1
        IF sp44->(DS(PADR(LEFT(fp2->crt,i),7)))
          m84dbap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"5",{||Sp44->naim7},l_month)
          m84dbap(LEFT(LEFT(fp2->crt,i)+REPLICATE(R_CH,7),7),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"5",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
        ENDIF
      NEXT
    ENDIF
     // Итог по счету
    IF a_total[6,2]<>"Z"
       m84dbap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),REPLICATE(R_CH,2),fp2->brgd1,"6",{||Sp44->(DBSEEK(LEFT(fp2->crt,2)+SPACE(5))),Sp44->naim7},l_month)
       m84dbap(LEFT(fp2->crt,2)+REPLICATE(R_CH,5),REPLICATE(R_CH,10),fp2->kopr,fp2->brgd1,"6",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)
    ENDIF
     // ОБЩИЙ Итог - по бригадi
    m84dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),REPLICATE(R_CH,2),Fp2->brgd1,"7",{||Sp01->(DBSEEK(Fp2->brgd1)),Sp01->Naim1},l_month)
    m84dbap(REPLICATE(R_CH,7),REPLICATE(R_CH,10),fp2->kopr            ,Fp2->brgd1,"7",{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},l_month)

    ENDIF  // конец учета затрат
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")

Return .t.
STATIC Function m84dbap(m_dbt,m_cod1,m_kopr,m_brgd,m_level,b_name,l_month)
      IF .not.buf->(DS(m_brgd+m_dbt+m_cod1+m_kopr+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->kopr:=m_kopr
        buf->brgd:=m_brgd
        buf->name:=EVAL(b_name)
      ENDIF
        IF l_month
          buf->dbstm+=fp2->stm
          buf->dbglv+=fp2->glv
          buf->dbkvo+=fp2->kvo
          IF Fp2->kopr==m_koprgsm
            buf->dbglv+=fp2->kvo2
          ENDIF
        ENDIF
        buf->crstm+=fp2->stm
        buf->crglv+=fp2->glv
        buf->crkvo+=fp2->kvo
        IF Fp2->kopr==m_koprgsm
          buf->crglv+=fp2->kvo2
        ENDIF
RETURN .T.

Function RMs86()
  LOCAL l_first:=.t.,n_error:=0,m_kod,i,l_glv:="0",;
  m_mnt1:=SPACE(4),m_mnt2:=SPACE(4),m_gauge,a_total:={},m_name,m_sum,a_scht:={}
  LOCAL m_gl_scht;

  LOCAL m_num_mash:="86",a_files:={},l_exit:=.f.,s1,s2,s3,s4
  LOCAL m_list_scht:=""
  LOCAL m_dbt1,m_crt1

// 1-й шаг  ввести расчетный период
IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF
// СОЗДАТЬ СТРУКТУРУ
m_gl_scht:=LEFT(a_scht[1],3)
  CrStr(m_num_mash)

  FILECOPY(m_mash+"m"+m_num_mash+".dbf",m_mash+"m"+m_num_mash+"a.dbf")
  NET USE (m_sprpath+"sp11") INDEX (m_sprpath+"sp11") NEW READONLY
  USE (m_mash+"m"+m_num_mash+"a") NEW ALIAS buf
  ZAP
  INDEX ON buf->dbt+buf->cod1+buf->crt+buf->cod2+buf->level TO (m_mash+"m"+m_num_mash+"a")
  CreateAtotal(m_num_mash,a_total)

  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 86")
  DO WHILE .NOT. Fp2->(EOF())
    IF IsScht(Fp2->dbt,a_scht).or.IsScht(Fp2->crt,a_scht)  // Fp2 подходит
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (mnt_year(fp1->mnt)==mnt_year(m_mnt1).AND.fp1->mnt<m_mnt1).OR.(fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2)
m_dbt1:= PADR(m_gl_scht+ALLTRIM(SUBSTR(fp2->dbt,3)),7)
m_crt1:=PADR(m_gl_scht+ALLTRIM(SUBSTR(fp2->crt,3)),7)
        // дебет
         IF IsScht(Fp2->dbt,a_scht)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ndog:=fp1->ndog
             buf->ddoc:=fp1->ddoc
//             buf->dbt:=fp2->dbt
             buf->dbt:=m_dbt1
             buf->crt:=fp2->crt
             buf->cod1:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod2:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr
             buf->dbstm:=fp2->stm
             IF .not.EMPTY(buf->cod2)
                buf->name:=AnCodName(fp2->crt,fp2->cod2)
             ELSE
                Sp44->(DS(buf->crt))
                buf->name:=Sp44->naim7
            ENDIF

          ENDIF
        ENDIF
        IF .not.EMPTY(buf->cod2)
          m_name:=AnCodName(fp2->dbt,fp2->cod1)
        ELSE
          Sp44->(DS(buf->crt))
          m_name:=Sp44->naim7
        ENDIF
       // Итог по корсчету - только обороты (Промежуточный итог)
      IF a_total[2,2]<>"Z"
        IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
                .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
          IF .not.buf->(DS(m_dbt1+GetAnCod(Fp2->dbt,fp2->cod1,m_kod)+fp2->crt+GetAnCod(Fp2->crt,fp2->cod2,m_kod)+"2"))
             buf->(DBAP())
             buf->level:="2"
             buf->dbt:=m_dbt1
             buf->cod1:=GetAnCod(fp2->dbt,fp2->cod1,m_kod)
             buf->crt:=fp2->crt
             buf->cod2:=GetAnCod(Fp2->crt,fp2->cod2,m_kod)
             buf->name:=GetAnName(Fp2->crt,fp2->cod2,m_kod)

          ENDIF
           buf->dbstm+=fp2->stm
           buf->count++
        ENDIF
      ENDIF

    IF m_kod=="2" // Исходная строка не использует аналитический код
        m86dbap(m_dbt1,REPLICATE(R_CH,10),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"4",;
        {||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},m_mnt1,m_mnt2,@m_list_scht)
    ELSE
     // аналитический код используется
        m86dbap(m_dbt1,GetAnCod(buf->dbt,fp2->cod1,m_kod),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"3",;
        {||GetAnName(fp2->dbt,fp2->cod1,m_kod)},m_mnt1,m_mnt2,@m_list_scht)
    ENDIF
   ENDIF
        // кредит
         IF IsScht(Fp2->crt,a_scht)
          IF a_total[1,2]<>"Z"  // Заносить первичный документ
            IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
             buf->(DBAP())
             buf->level:="1"
             buf->npch:=fp1->npch
             buf->ndoc:=fp1->ndoc
             buf->ndog:=fp1->ndog
             buf->ddoc:=fp1->ddoc
             buf->dbt:=m_crt1
             buf->crt:=fp2->dbt
             buf->cod2:=GetAnCod(buf->dbt,fp2->cod1,m_kod)
             buf->cod1:=GetAnCod(buf->crt,fp2->cod2,m_kod)
             buf->kopr:=fp2->kopr
             buf->crstm:=fp2->stm
             IF .not.EMPTY(buf->cod2)
                buf->name:=AnCodName(fp2->crt,fp2->cod2)
             ELSE
                Sp44->(DS(buf->crt))
                buf->name:=Sp44->naim7
            ENDIF

          ENDIF
        ENDIF
        IF .not.EMPTY(buf->cod2)
          m_name:=AnCodName(fp2->crt,fp2->cod2)
        ELSE
          Sp44->(DS(buf->crt))
          m_name:=Sp44->naim7
        ENDIF
       // Итог по корсчету - только обороты (Промежуточный итог)
      IF a_total[2,2]<>"Z"
        IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
                .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
          IF .not.buf->(DS(m_crt1+GetAnCod(Fp2->crt,fp2->cod2,m_kod)+fp2->dbt+GetAnCod(Fp2->dbt,fp2->cod1,m_kod)+"2"))
             buf->(DBAP())
             buf->level:="2"
             buf->dbt:=m_crt1
             buf->cod1:=GetAnCod(fp2->crt,fp2->cod2,m_kod)
             buf->crt:=fp2->dbt
             buf->cod2:=GetAnCod(Fp2->dbt,fp2->cod1,m_kod)
             buf->name:=GetAnName(Fp2->dbt,fp2->cod1,m_kod)
          ENDIF
           buf->crstm+=fp2->stm
           buf->count++
        ENDIF
      ENDIF
    IF m_kod=="2" // Исходная строка не использует аналитический код
        m86crap(m_crt1,REPLICATE(R_CH,10),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"4",;
        {||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},m_mnt1,m_mnt2,@m_list_scht)
    ELSE
     // аналитический код используется
        m86crap(m_crt1,GetAnCod(buf->crt,fp2->cod2,m_kod),REPLICATE(R_CH,7),REPLICATE(R_CH,10),"3",;
        {||GetAnName(fp2->crt,fp2->cod2,m_kod)},m_mnt1,m_mnt2,@m_list_scht)
    ENDIF
   ENDIF
 ENDIF
ENDIF
    IF inkey()==K_ESC
      IF ANSWERu("Прервати розрахунок машинограми ?")==YES
        l_exit:=.t.
        EXIT
      ENDIF
    ENDIF
    Fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.EMPTY(m_list_scht)
    DispError("Не визначенi аналiтичнi коди ;"+m_list_scht+";рахункiв")
  ENDIF

  IF .NOT.l_exit
/* */
// Сформировали исходные строки теперь можно считать итоги
// Понеслась !!!
  USE (m_mash+"m"+m_num_mash) NEW ALIAS buf1
  ZAP
  INDEX ON buf1->dbt+buf1->cod1+buf1->crt+buf1->cod2+buf1->level TO (m_mash+"m"+m_num_mash)
  SELE buf
  SET INDEX TO
  IF   m_kod=="2"
    SET FILTER TO buf->level=="4"
  ELSE
    SET FILTER TO buf->level=="3"
  ENDIF
  m_gauge:=InitGauge("Пiдрахунок пiдсумкiв машинограми N 86")
  buf->(DBGOTOP())
  DO WHILE .NOT.buf->(EOF())
    // РАСЧЕТ ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО исходных строк
         DO CASE
          CASE IsZrpl(buf->dbt)
              buf->indbstm:=0;buf->incrstm:=0
              buf->outdbstm:=0;buf->outcrstm:=0
          CASE buf->type="З"  // Свернутое сальдо
            IF buf->indbstm<0
              buf->incrstm:=ABS(buf->indbstm)
              buf->indbstm:=0
            ENDIF
            m_sum:=buf->indbstm-buf->incrstm+buf->dbstm-buf->crstm
            IF m_sum<0
              buf->outcrstm:=ABS(m_sum)
            ELSE
              buf->outdbstm:=m_sum
            ENDIF
          CASE buf->type="Д" //Дебетовое сальдо
            buf->outdbstm:=buf->indbstm+buf->dbstm-buf->crstm
          CASE buf->type="К" //Кредитовое сальдо
            buf->outcrstm:=buf->incrstm-buf->dbstm+buf->crstm
          CASE buf->type="Р" // Развернутое
            buf->outdbstm:=buf->indbstm+buf->dbstm
            buf->outcrstm:=buf->incrstm+buf->crstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            IF buf->indbstm<0
              buf->incrstm:=ABS(buf->indbstm)
              buf->indbstm:=0
            ENDIF
            m_sum:=buf->indbstm-buf->incrstm+buf->dbstm-buf->crstm
            IF m_sum<0
              buf->outcrstm:=ABS(m_sum)
            ELSE
              buf->outdbstm:=m_sum
            ENDIF
        ENDCASE
    //КОНЕЦ РАСЧЕТА ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО по аналитическому счету
     // Занесение итогов
      // Итоги по дереву СУБСЧЕТОВ
      IF a_total[5,2]<>"Z"
        FOR i:=3 TO LEN(RTRIM(buf->dbt))-1
          IF sp44->(DS(PADR(LEFT(buf->dbt,i),7)))
              IF .not.buf1->(DS(LEFT(LEFT(buf->dbt,i)+REPLICATE(R_CH,7),7)+REPLICATE(R_CH,10)+REPLICATE(R_CH,7)+REPLICATE(R_CH,10)+"5"))
                  buf1->(DBAP())
                  buf1->level:="5"
                  buf1->dbt:=LEFT(LEFT(buf->dbt,i)+REPLICATE(R_CH,7),7)
                  buf1->cod1:=REPLICATE(R_CH,10)
                  buf1->crt:=REPLICATE(R_CH,7)
                  buf1->cod2:=REPLICATE(R_CH,10)
                  buf1->name:=Sp44->naim7
                  IF sp11->(DS(PADR(LEFT(buf1->dbt,i),7)))
                    buf1->type:=sp11->type1
                  ELSE
                    buf1->type:=buf->type1
                  ENDIF
              ENDIF
              buf1->crstm+=buf->crstm
              buf1->dbstm+=buf->dbstm

            DO CASE
              CASE IsZrpl(buf1->dbt)
                  buf1->indbstm:=0
                  buf1->incrstm:=0
                  buf1->outdbstm:=0
                  buf1->outcrstm:=0
              CASE buf1->type="З"  // Свернутое сальдо
                // Все минусуем в дебет а если получиться отрицательное перенесем в кредит
                buf1->indbstm+=buf->indbstm-buf->incrstm
                buf1->outdbstm+=buf->outdbstm-buf->outcrstm
              CASE buf1->type="Д" //Дебетовое сальдо
                buf1->indbstm+=buf->indbstm-buf->incrstm
                buf1->outdbstm+=buf->outdbstm-buf->outcrstm
              CASE buf1->type="К" //Кредитовое сальдо
                buf1->incrstm+=buf->incrstm-buf->indbstm
                buf1->outcrstm+=buf->outcrstm-buf->outdbstm
              CASE buf1->type="Р" // Развернутое
                buf1->incrstm+=buf->incrstm
                buf1->indbstm+=buf->indbstm
                buf1->outcrstm+=buf->outcrstm
                buf1->outdbstm+=buf->outdbstm
              OTHERWISE  //А это шо такое - ну ладно будет свернутым
                buf1->indbstm+=buf->indbstm-buf->incrstm
                buf1->outdbstm+=buf->outdbstm-buf->outcrstm
            ENDCASE
          ENDIF
        NEXT
      ENDIF
     // Итог по счету
      IF a_total[6,2]<>"Z"
        Sp44->(DS(LEFT(buf->dbt,2)+SPACE(5)))

        IF .not.buf1->(DS(LEFT(buf->dbt,2)+REPLICATE(R_CH,5)+REPLICATE(R_CH,10)+REPLICATE(R_CH,7)+REPLICATE(R_CH,10)+"6"))
            buf1->(DBAP())
            buf1->level:="6"
            buf1->dbt:=LEFT(buf->dbt,2)+REPLICATE(R_CH,5)
            buf1->cod1:=REPLICATE(R_CH,10)
            buf1->crt:=REPLICATE(R_CH,7)
            buf1->cod2:=REPLICATE(R_CH,10)
            buf1->name:=Sp44->naim7
            IF sp11->(DS(PADR(LEFT(buf1->dbt,2),7)))
              buf1->type:=sp11->type1
            ELSE
              buf1->type:=buf->type1
            ENDIF
        ENDIF
        buf1->crstm+=buf->crstm
        buf1->dbstm+=buf->dbstm
        DO CASE
          CASE IsZrpl(buf1->dbt)
          CASE buf1->type="З"  // Свернутое сальдо
            // Все в дебет а если получиться отрицательное перенесем в кредит
            buf1->indbstm+=buf->indbstm-buf->incrstm
            buf1->outdbstm+=buf->outdbstm-buf->outcrstm
          CASE buf1->type="Д" //Дебетовое сальдо
            buf1->indbstm+=buf->indbstm-buf->incrstm
            buf1->outdbstm+=buf->outdbstm-buf->outcrstm
          CASE buf1->type="К" //Кредитовое сальдо
            buf1->incrstm+=buf->incrstm-buf->indbstm
            buf1->outcrstm+=buf->outcrstm-buf->outdbstm
          CASE buf1->type="Р" // Развернутое
            buf1->incrstm+=buf->incrstm
            buf1->indbstm+=buf->indbstm
            buf1->outcrstm+=buf->outcrstm
            buf1->outdbstm+=buf->outdbstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            buf1->indbstm+=buf->indbstm-buf->incrstm
            buf1->outdbstm+=buf->outdbstm-buf->outcrstm
        ENDCASE
      ENDIF
    buf->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,buf->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  // пересчитать исходящее сальдо
  m_gauge:=InitGauge("Пiдрахунок вихiдного сальдо машинограми N 86")
  SELE buf1
  SET ORDER TO 0
  buf1->(DBGOTOP())
  DO WHILE .NOT.buf1->(EOF())
    // РАСЧЕТ ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО итогов
         DO CASE
          CASE IsZrpl(buf1->dbt).OR.buf1->type="Р"
          CASE buf1->type="З"  // Свернутое сальдо
            IF buf1->indbstm<0
              buf1->incrstm:=ABS(buf1->indbstm)
              buf1->indbstm:=0
            ENDIF
            m_sum:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm
            IF m_sum<0
              buf1->outcrstm:=ABS(m_sum)
              buf1->outdbstm:=0
            ELSE
              buf1->outdbstm:=m_sum
              buf1->outcrstm:=0
            ENDIF
          CASE buf1->type="Д" //Дебетовое сальдо
            buf1->outdbstm:=buf1->indbstm+buf1->dbstm-buf1->crstm
          CASE buf1->type="К" //Кредитовое сальдо
            buf1->outcrstm:=buf1->incrstm-buf1->dbstm+buf1->crstm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            IF buf1->indbstm<0
              buf1->incrstm:=ABS(buf1->indbstm)
              buf1->indbstm:=0
            ENDIF
            m_sum:=buf1->indbstm-buf1->incrstm+buf1->dbstm-buf1->crstm
            IF m_sum<0
              buf1->outcrstm:=ABS(m_sum)
              buf1->outdbstm:=0
            ELSE
              buf1->outdbstm:=m_sum
              buf1->outcrstm:=0
            ENDIF
        ENDCASE
    //КОНЕЦ РАСЧЕТА ВХОДЯЩЕГО И ИСХОДЯЩЕГО САЛЬДО

    buf1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,buf1->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)

  // Перенос записей из buf в buf1
  SELE buf
  set filter to
  IF a_total[1,2]<>"Z".OR.a_total[2,2]<>"Z".OR.a_total[3,2]<>"Z".OR.a_total[4,2]<>"Z"
    buf->(DBGOTOP())
    m_gauge:=InitGauge("Перенiс перв. документiв в машинограму N 86")
    DO WHILE .NOT.buf->(EOF())
      IF a_total[VAL(buf->level),2]<>"Z" // данную запись перенести в buf1
        //TODO анализировать count для корсчетов
        buf1->(DBAP())
        FOR i:=1 TO buf->(FCOUNT())
          buf1->(FIELDPUT(i,buf->(FIELDGET(i))))
        NEXT
      ENDIF
      buf->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,buf->(RECNO()/LASTREC()))
    ENDDO
  ENDIF
  ENDIF // l_exit
Close Sp11
Close buf
Close buf1
USE (m_mash+"m"+m_num_mash) NEW ALIAS buf
INDEX ON buf->dbt+buf->cod1+buf->crt+buf->cod2+buf->level TO (m_mash+"m"+m_num_mash)
// Удаление пустых строчек
  IF .NOT.l_exit
    // Удаляем нулевые строки
    buf->(DBGOTOP())
    DO WHILE .NOT.buf->(EOF())
      IF buf->level<>"1".AND.buf->crstm==0.AND.buf->dbstm==0.AND.buf->indbstm==0.AND.buf->incrstm==0
         buf->(DBDELETE())
      ENDIF
      buf->(DBSKIP())
    ENDDO
   ENDIF
CloseRasch(n_error,m_num_mash,l_exit,a_files,";"+m_mnt1+";"+m_mnt2+";"+l_glv+";"+m_oper+";"+m_kod+";"+a_total[1,2]+";")
Return .t.
STATIC Function m86dbap(m_dbt,m_cod1,m_crt,m_cod2,m_level,b_name,m_mnt1,m_mnt2,m_list_scht)
LOCAL i
   IF .not.buf->(DS(m_dbt+m_cod1+m_crt+m_cod2+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->crt:=m_crt
        buf->cod2:=m_cod2
        buf->name:=EVAL(b_name)
        // Определить входящее сальдо свернутое или нет
        FOR i:=LEN(m_dbt)-1 TO 2 STEP -1
          IF Sp11->(DS(PADR(LEFT(m_dbt,i),7)))
            buf->type:=Sp11->type2
            EXIT
          ENDIF
        NEXT
        IF EMPTY(buf->type) // Ну не нашли в справочнике
          IF AT(LEFT(m_dbt,2),m_list_scht)==0
            m_list_scht+=LEFT(m_dbt,2)+","
            DispError("Не визначен тип аналiтичного рахунку "+LEFT(m_dbt,2))
          ENDIF
          buf->type:="З" //По умолчанию свернутое
        ENDIF
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->crt,2)<>SCHT_OST  // и не остатки
         // В ДЕБЕТ ЕГО !!!!
         buf->dbstm+=fp2->stm
      ELSE
         DO CASE
          CASE buf->type="З"  // Свернутое сальдо
            // Все суммируем в дебет а если получиться отрицательное перенесем в кредит
            buf->indbstm+=fp2->stm
          CASE buf->type="Д" //Дебетовое сальдо
            buf->indbstm+=fp2->stm
          CASE buf->type="К" //Кредитовое сальдо
            buf->incrstm-=fp2->stm
          CASE buf->type="Р" // Развернутое
            buf->indbstm+=fp2->stm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            buf->indbstm+=fp2->stm
        ENDCASE
      ENDIF
RETURN .T.

STATIC Function m86crap(m_dbt,m_cod1,m_crt,m_cod2,m_level,b_name,m_mnt1,m_mnt2,m_list_scht)
LOCAL i
   IF .not.buf->(DS(m_dbt+m_cod1+m_crt+m_cod2+m_level))
        buf->(DBAP())
        buf->level:=m_level
        buf->dbt:=m_dbt
        buf->cod1:=m_cod1
        buf->crt:=m_crt
        buf->cod2:=m_cod2
        buf->name:=EVAL(b_name)
        // Определить входящее сальдо свернутое или нет
        FOR i:=LEN(m_dbt)-1 TO 2 STEP -1
          IF Sp11->(DS(PADR(LEFT(m_dbt,i),7)))
            buf->type:=Sp11->type2
            buf->type1:=Sp11->type1
            EXIT
          ENDIF
        NEXT
        IF EMPTY(buf->type) // Ну не нашли в справочнике
          IF AT(LEFT(m_dbt,2),m_list_scht)==0
            m_list_scht+=LEFT(m_dbt,2)+","
            DispError("Не визначен тип аналiтичного рахунку "+LEFT(m_dbt,2))
          ENDIF
          buf->type:="З" //По умолчанию свернутое
          buf->type1:="З" //По умолчанию свернутое
        ENDIF
      ENDIF
      // ОПРЕДЕЛЯЕМ ОБОРОТЫ ЛИ ВХОДЯЩЕЕ САЛЬДО
      IF (fp1->mnt>=m_mnt1.AND.fp1->mnt<=m_mnt2);  //Документ из расчетного периода
              .AND.LEFT(fp2->dbt,2)<>SCHT_OST  // и не остатки
         // В КРЕДИТ ЕГО !!!!
         buf->crstm+=fp2->stm
      ELSE
         DO CASE
          CASE buf->type="З"  // Свернутое сальдо
            // Все минусуем в дебет а если получиться отрицательное перенесем в кредит
            buf->indbstm-=fp2->stm
          CASE buf->type="Д" //Дебетовое сальдо
            buf->indbstm-=fp2->stm
          CASE buf->type="К" //Кредитовое сальдо
            buf->incrstm+=fp2->stm
          CASE buf->type="Р" // Развернутое
            buf->incrstm+=fp2->stm
          OTHERWISE  //А это шо такое - ну ладно будет свернутым
            buf->incrstm-=fp2->stm
        ENDCASE
      ENDIF
RETURN .T.

