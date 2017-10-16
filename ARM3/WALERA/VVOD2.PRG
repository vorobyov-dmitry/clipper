#include "wal.ch"

#define DBAP()     DBAPPEND()
#define DS(var)    DBSEEK(var)
#DEFINE VVOD_CLR    'w/b,gr+/n,,,n/w'
#DEFINE HL_CLR      'n/w,gr+/n'
#command CLOSE base <var1>[,<varN>] = >;
         <var1>->(dbclosearea()) ;
         [;<varN>->(dbclosearea())  ]

#command UI <(db)>                                                     ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ex: EXCLUSIVE>]                                          ;
             [<sh: SHARED>]                                             ;
             [<ro: READONLY>]                                           ;
                                                                        ;
      => dbUseArea(                                                     ;
                    <.new.>, <rdd>, <(db)>, <(a)>,                      ;
                    if(<.sh.> .or. <.ex.>, !<.ex.>, NIL), <.ro.>        ;
                  )                                                     ;
                                                                        ;
        ; dbSetIndex( <(db)> )                                      ;


MEMVAR getlist,m_dbspath,m_bufpath
MEMVAR hello1_clr
MEMVAR msg_clr
MEMVAR p_npr
MEMVAR m_oper
MEMVAR m_vdoc
MEMVAR m_sprpath
MEMVAR arr1


//
//╔══════════════════════════════════════════════════════════
//║ Модуль: 01.prg
//║ Автор: Шнайдеp В. О.
//║ Дата создания: 24-07-91.
//║ Содержит: процедуры s_vs001 , s_vk001 , s_vs002 , s_vk002
//║           функции sdelfile1 , Skipped , slzkuse , _delfill
//╚═══════
//

#include "wal.ch"

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_vs001
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 28/05/91
//║ Параметры:
//║ Назначение:  Ввод бухгалтерской справки
//║ Используемые внешние переменные:  m_vdoc
//║ Используемые процедуры и функции:  WaitMig,
//║                                    F014_1,
//║                                    A61,
//║                                    CopyDbfNtx,
//║                                    DelDbfNtx,
//║                                    Sdoc,
//║                                    Warr1,
//║                                    ReplaceRecord,
//║                                    sdelfile1
//║
//║ Используемые файлы и внешние устройства: buhsp.wdf ,
//║  sp10.dbf , sp10.ntx ,
//║  sp01.dbf , sp01.ntx ,
//║  sp02.dbf , sp02.ntx ,
//║  sp05.dbf , sp05.ntx ,
//║  SP44.dbf , SP44.ntx ,
//║  funnum.dbf , fvnum.dbf
//║  fdbcr.dbf  , fdbcr.ntx
//║
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC L_TAX:=.t.


STATIC FUNCTION Skipped(n,n1,n2,nalias)
LOCAL ncount := 0
IF n > 0
   WHILE ncount < n
       (nalias)->(DBSKIP())
       IF (nalias)->(RECNO())> n2
          (nalias)->(DBSKIP(-1))
          EXIT
       END
       ncount++
   END
ELSEIF n < 0
   WHILE ncount > n
       (nalias)->(DBSKIP(-1))
       IF (nalias)->(RECNO() )< n1
          (nalias)->(DBSKIP())
          EXIT
       END
       ncount--
   END
END
RETURN ncount

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_vv002
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 31/05/91
//║ Параметры:
//║ Назначение: Ввод кассовой ведомости
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION s_vv002

FIELD naim7
LOCAL   nl:=1                  && Hомер листа
LOCAL   m_ddoc
LOCAL m_glv                  && Количество голов
LOCAL m_kvo                  && Количество
LOCAL m_sum                  && Сумма
LOCAL m_vnuma                  && Внутренний номер документа
LOCAL m_tabn                  && Tабельный номер
LOCAL m_kopu                  && Код оплат
// Условие существования количества
LOCAL m_log1 := ( m_vdoc # 1 ),s_files:={},a_block
LOCAL i
LOCAL ii                  && Текущая строка для печати
LOCAL    m_npch                  && Hомер пачки
LOCAL    m_ndoc                  && Hомер документа
LOCAL m_paj:=" "
// Условие существования количества голов
LOCAL m_log2 := ( m_vdoc = 3 )

PRIVATE arr1 :=Warr1("03")


// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)
sk_use(@s_files)                       && Открытие файлов
// SETCURSOR(SC_NORMAL)                      && Включение курсора
// f014_1(@arr1)
// a_block:={{K_ALT_F9,{||a71(@arr1)}}}

m_ddoc:=arr1[2,2]
WHILE  .t.
   m_vnuma := fvnum -> vnuma
   m_kopu:=SPACE(3)
   SAYWDF("23")
   @ 5,17 SAY p_npr
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"
   ii := 13
   m_ndoc := 0
   m_npch :=arr1[1,2]
   IF !sdoc(3,47,5,46,@m_npch,@m_ndoc) ; EXIT ; END
   m_ddoc:=IF(!EMPTY(arr1[2,2]),arr1[2,2],m_ddoc)
   @ 5,5 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[2,2])
   @ 5,52 GET m_kopu PICTURE '999' ;
          VALID sp08->(sp_vl('SP08',,5,56,'sp08->name8',"GR+/B",18))
   @ 5,76 GET m_paj PICTURE 'X'
//          VALID sp08->(sp_vl('SP08',,5,57,'sp08->name8',"GR+/B"))

   READMY(GetList,a_block);GetList:={}
   @ 9,21 SAY  sp25->crt
   fd1->(DBAPPEND())
   fd1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,m_oper,DATE(),m_vnuma,m_kopu,,m_paj}))
   fd1->mnt:=fvnum->mnt
   fvnum->vnuma := m_vnuma+1
   WHILE .t.
      @ 1,50 SAY 'Лист N '+STRZERO(nl,2)
      m_sum:=m_kvo:=m_glv:=0
      m_tabn := SPACE(4)
      SET(_SET_ESCAPE,!(nl=1 .and. ii=13))
      @ ii,17 GET m_tabn ;
              PICTURE '9999' ;
              VALID sp10->(sp_vl("SP10",IF(ii=13 .and. nl=1 ,"1","2"),ii,23,"_fio()","GR+/B"))
       READMY(GetList,a_block);GetList:={}
      SET(_SET_ESCAPE,.F.)
      IF Val(m_tabn)=0 .and. (nl#1 .or. ii#13)
            EXIT
      END
      @ ii,9  SAY IF(Substr( sp25 -> crt , 3 , 4 )='TTTT',;
                      Substr( sp25 -> crt , 1 , 2 ) + m_tabn , sp25 -> crt )
      @ 9,50  SAY  SP44->(EVAL( {  ||  DBSEEK(sp25->crt),IF( FOUND(),naim7,SPACE(20) )  }  ))
      IF  m_log2                  && Если есть количество голов
         @ ii,53 GET m_glv PICTURE '99'
      END
      IF m_log1                   && Если есть количество
         @ ii,59 GET m_kvo PICTURE '9999999.99'
      END
      @ ii,70 GET m_sum PICTURE '99999.99'
      READ
      fd2->(DBAPPEND())
      fd2->(ReplaceRecord({m_vnuma,m_tabn,m_sum,m_kvo,m_glv}))
      IF ii=21                    && Усли новая страница
         FOR i = 13 TO 21
           @ i,2 SAY '      │       │     │' + Space(25) + ;
             '│         │          │        '
         NEXT
         @ 8,50 CLEAR TO 9,70
         ii=13
         nl++
      ELSE
         ii++
      END
END
nl:=1
END
// SETKEY(K_F9,NIL)
_delfilk(@s_files)
CLOSE  fvnum
RETURN .t.

STATIC FUNCTION sk_use(s_files)
//
//════════
// Процедура: sk_use
// Автор:
// Дата:   04/11/91 07:07pm
// Параметры:  NO
// Внешние переменные: NO
// Используемые процедуры и функции:  NO
// Используемые файлы: fvnum,fd1,fd2,sp10,sp25,sp08,
// Примечание:  Открытие файлов для работы с кассовой ведомостью,
//              копирование справочников на виртуальный диск
//════════
//
/* Открытие рабочих баз */
USE (m_bufpath+"fvnum.dbr")   NEW
USE (m_dbspath+"fd1")   NEW
USE_INDEX("fd2")
SopenFiles("SP25",@s_files)
SopenFiles("SP08",@s_files)
sele sp08
SET RELATION TO sp08->kopu INTO sp25

SopenFiles("SP10",@s_files)
SopenFiles("SP44",@s_files)
RETURN  NIL

STATIC FUNCTION _delfilk(s_files)
SET(_SET_SOFTSEEK,.F.)
ScloseFiles(s_files)
CLOSE  fd1
CLOSE  fd2
RETURN NIL


FUNCTION s_kr002(m_r)
   FIELD vnuma , naim5a , tabn
   MEMVAR m_reg , n_fd1
   MEMVAR cg , m

   LOCAL b,column,nKey,k
   LOCAL m_brgd
   LOCAL m_kopr
   LOCAL m_kplh
   LOCAL m_otp
   LOCAL m_ddoc
   LOCAL m_npch
   LOCAL m_paj
   LOCAL m_ndoc,m_kopu

   LOCAL sv_block := {|n1,n2|b:autolite := .f.,;
                        b:dehilite(),;
                        fd2->(DBSETORDER(1)),;
                        fd1->(DBGOTO(fd1->(RECNO()))),;
                        n1:=fd2->(RECNO()),;
                        fd2->(DBSETORDER(0)),;
                        fd2->(DBEVAL({||NIL},;
                               {||vnuma==fd1->vnuma},;
                               {||vnuma==fd1->vnuma})),;
                        fd2->(DBSKIP(-1)),;
                        n2:=fd2->(RECNO()),;
                        fd2->(DBGOTO(n1)),;
                        b:refreshall(),;
                        b:autolite := .t.,;
                        b:hilite()}

   LOCAL say_block := {|l|;
         SETCOLOR(IF(l,HL_CLR,"w+/b")),;
         SETPOS(03,47),DISPOUT(STR(fd1->npch,3)),;
         SETPOS(05,46),DISPOUT(STR(fd1->ndoc,5)),;
         SETPOS(05,05),DISPOUT(fd1->ddoc),;
         SETPOS(05,52),DISPOUT(fd1->kopu),;
         SETPOS(05,76),DISPOUT(fd1->paj),;
         SETCOLOR(VVOD_CLR),;
         SETPOS(5,17),DISPOUT(PADR(p_npr,20),"gr+/b"),;
         SETPOS(5,57),DISPOUT(SUBSTR(sp08->name8,1,18),"gr+/b"),;
         SETPOS(9,22),DISPOUT(sp25->crt,"gr+/b"),;
         SETPOS(9,54),DISPOUT(IF(SP44->(DBSEEK(IF("TTTT"$sp25->crt,SUBSTR(sp25->crt,1,2)+fd2->tabn,sp25->crt))).and.!l,SP44->naim7,SPACE(20)),"gr+/b")}
LOCAL  m_reg1:=(ALLTRIM(m_r)#'просмотр')
LOCAL m_npch1,m_ndoc1
LOCAL n1:=1   // номеp пеpвой записи документа
LOCAL n2:=1  // номеp последней записи документа
LOCAL  uu,s_files:={}

PRIVATE m_reg:=m_r
PRIVATE n_fd1

// SETCURSOR(SC_NONE)
Wait_Mig()                 && ожидание
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)

SopenFiles("SP25",@s_files)
SopenFiles("SP08",@s_files)
sele sp08
SET RELATION TO sp08->kopu INTO sp25
SopenFiles("SP10",@s_files)
SopenFiles("SP44",@s_files)

USE_INDEX("fd2")
SET RELATION TO tabn INTO sp10
USE (m_dbspath+"fd1")     NEW
SET RELATION TO fd1->(STR(vnuma,7)) INTO fd2,;
             TO fd1->kopu           INTO sp08


fd1->(DBGOTOP())
IF fd1->(Deleted())
   fd1->(DBSKIP())
END

SayWdf("23")
IF fd1->(RECNO())=fd1->(Lastrec()+1)
   DispError(' Файл  FD1.DBF не  содержит  записей. ')
   _delfilk(@s_files)
   RETURN .t.
END
EVAL(say_block,.f.)
SETCOLOR(VVOD_CLR)
private cg
SELECT fd2
b:=TBrowseDB(12,2,21,78)
b:colorspec:="W/B,N/W,gr+/b,w+/b"
b:headsep := "┼─"
b:colsep  := "│"
b:gotopblock := {||fd2->(DBGOTO(n1))}
b:gobottomblock := {||fd2->(DBGOTO(n2))}
b:SkipBlock := {|n| Skipped(n,n1,n2,SELECT("fd2")) }
b:cargo := {2,2,21,37,;
                 {'" "+STR(npch)+"   "+STR(ndoc)+"    "+DTOC(ddoc)+"  "'},;
                 {'N пач. N док.     Дата'}}
   /*
   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2,IF("TTTT"$sp25->dbt,SUBSTR(sp25->dbt,1,2)+fd2->tabn,sp25->dbt),SPACE(7))})
   */
   column := TBColumnNew(,{||SPACE(6)})
   column:width  := 6
   column:ColorBlock:={||{4,2}}
   b:addColumn(column)

   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2,IF("TTTT"$sp25->crt,SUBSTR(sp25->crt,1,2)+fd2->tabn,sp25->crt),SPACE(7))})
   column:width  := 7
   column:ColorBlock:={||{3,2}}
   b:addColumn(column)

   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2,;
                           fd2->tabn,SPACE(4))})
   column:width  := 5
   column:cargo  := {"9999",{||sp10->(sp_vl("SP10"))},"fd2->tabn"}
   column:ColorBlock:={||{4,2}}
   b:addColumn(column)

   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2,;
                           _fio(fd2->tabn),SPACE(25))})
   column:width  := 25
   column:ColorBlock:={||{3,2}}
   b:addColumn(column)

   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2.and.fd1->vdoc==3,fd2->glv,SPACE(2))})
   column:width  := 9
   column:cargo  := {"99",{||.t.},"fd2->glv"}
   column:ColorBlock:={||{4,2}}
   b:addColumn(column)

   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2.and.fd1->vdoc#1,fd2->kvo,SPACE(10))})
   column:width  := 10
   column:cargo  := {"9999999.99",{||.t.},"fd2->kvo"}
   column:ColorBlock:={||{4,2}}
   b:addColumn(column)

   column := TBColumnNew(,{||IF(fd2->(RECNO())>=n1.and.;
                           fd2->(RECNO())<=n2,fd2->sum,SPACE(10))})
   column:width  := 8
   column:cargo  := {"99999.99",{||.t.},"fd2->sum"}
   column:ColorBlock:={||{4,2}}
   b:addColumn(column)

   SELECT fd2
   EVAL(sv_block,@n1,@n2)

   WHILE .T.
      DBSELECTAREA("fd2")
      DISPBEGIN()
      @1,39 SAY SPACE(25) COLOR "w/b"
      @1,39 SAY mnt_dtoc(fd1->mnt) COLOR "GR+/b*"
      WHILE !b:stabilize() ; END
      EVAL(SAY_Block,!b:autolite)
      DISPEND()
      IF b:stable
         nkey:=inkey(0)
      END
      IF nkey=K_ENTER .and. m_reg1 .and. n1 # fd2->(LASTREC()+1)
            IF b:autolite
               column := b:GetColumn(b:colpos)
               cg := column:cargo
               IF ASCAN({1,2,4,IF(fd1->vdoc=3,0,5),IF(fd1->vdoc#1,0,6)},b:colpos)==0
                  // m := EVAL(column:block)
                  m := &(cg[3])
                  b:autolite := .F.
                  b:dehilite()
                  b:autolite := .T.
                  @ ROW(),COL() GET m PICTURE cg[1] VALID EVAL(cg[2])
//                  SETCURSOR(SC_NORMAL)
                  READ
//                  SETCURSOR(SC_NONE)
                  REPLACE &(cg[3]) WITH m
                  b:RefreshCurrent()
                  KEYBOARD CHR(K_RIGHT)
               END
            ELSE
               SETCOLOR(VVOD_CLR)
               m_ddoc:=fd1->ddoc
               m_npch:=fd1->npch
               m_ndoc:=fd1->ndoc
               m_kopu:=fd1->kopu
               m_paj:=fd1->paj
               @ 03,47 get m_npch PICTURE '999'   VALID !EMPTY(m_npch)
               @ 05,46 get m_ndoc PICTURE '99999' VALID !EMPTY(m_ndoc)
               @ 5,5   GET m_ddoc VALID !EMPTY(m_ddoc)
               @ 5,52  GET  m_kopu PICTURE '999' ;
                      VALID sp08->(sp_vl('SP08',,5,57,'sp08->name8',"GR+/B",18))
               @ 5,76  GET  m_paj PICTURE 'X'
//               SETCURSOR(SC_NORMAL)
               READ
//               SETCURSOR(SC_NONE)
               IF UPDATED()
                  fd1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,,,,,m_kopu,,m_paj}))
                  b:RefreshAll()
               END
            END
      ELSEIF nkey=K_DEL .and. !b:autolite .and. m_reg1 .and. ;
              ANSWERu("Ви дiйсно бажаєте знищити документ?")==YES
            fd1->(DBDELETE())
            fd2->(DBGOTO(n1))
            WHILE fd2->(RECNO())<=n2
               fd2->(DBDELETE())
               fd2->(DBSKIP())
            END
            fd1->(DBSKIP())
            IF fd1->(EOF())
               fd1->(DBSKIP(-1))
               IF fd1->(BOF())
                  DispError( 'Файл  fd1.DBF не  содержит  записей. ')
                  EXIT
               END
            END
            EVAL(sv_block,@n1,@n2)
      ELSEIF !fd1->(FKEY(nkey,b,@n1,@n2,sv_block,SELECT("FD2"),"VNUMA",m_reg1,SELECT("FD1")))
         EXIT
      END
   END
   DBCOMMITALL()
   _delfilk(@s_files)
RETURN .t.

STATIC FUNCTION FKEY(nkey,b,n1,n2,sv_block,sel_ved,s_vnum,m_reg1,sel_main)
LOCAL uu ,k,m_ndoc1,m_npch1
FIELD npch,ndoc
      IF nkey = K_DOWN .and. b:autolite
            b:down()
      ELSEIF nkey = K_DOWN .and. !b:autolite
            b:autolite := .t.
            b:hilite()
      ELSEIF nkey=K_PGDN        .and. b:autolite
            b:pagedown()
      ELSEIF nkey=K_PGUP        .and. b:autolite
            b:pageup()
      ELSEIF nkey=K_RIGHT       .and. b:autolite
            b:right()
      ELSEIF nkey=K_LEFT        .and. b:autolite
            b:left()
      ELSEIF nkey=K_HOME        .and. b:autolite
            b:gotop()
      ELSEIF nkey=K_END         .and. b:autolite
            b:gobottom()
      ELSEIF nkey=K_END         .and. !b:autolite
            b:autolite := .t.
            b:hilite()
            b:gobottom()
      ELSEIF nkey=K_F1
            help()
      ELSEIF nkey=K_F10
            calc()
      ELSEIF nkey=K_ESC .and. ANSWERu('   Завершити работу ?   ')==YES
            RETURN .f.
      ELSEIF nkey == K_F12
            RETURN .f.
      ELSEIF nkey=K_CTRL_HOME
            (sel_main)->(DBGOTOP())
            EVAL(sv_block,@n1,@n2)
      ELSEIF nkey=K_CTRL_END
            (sel_main)->(DBGOBOTTOM())
            EVAL(sv_block,@n1,@n2)
      ELSEIF nkey=K_F2
            (sel_main)->(DBSKIP())
            (sel_main)->(IF(EOF(),DBSKIP(-1),NIL))
            EVAL(sv_block,@n1,@n2)
      ELSEIF nkey=K_F3
            (sel_main)->(DBSKIP(-1))
            EVAL(sv_block,@n1,@n2)
      ELSEIF nkey=K_F4
            (sel_main)->(DBSKIP(-20))
            EVAL(sv_block,@n1,@n2)
      ELSEIF nkey=K_F5
            (sel_main)->(DBSKIP(20))
            (sel_main)->(IF(EOF(),DBSKIP(-1),NIL))
            EVAL(sv_block,@n1,@n2)
      ELSEIF nkey=K_F7
            uu := SAVESCREEN(6,24,11,57)
            k:=0
            SET(_SET_ESCAPE,.T.)
            SETCOLOR(HELLO1_CLR)
            @6,24,10,55 BOX B_DOUBLE+" " COLOR "gr+/BG"
            @ 07,25 say 'Сколько документов пропустить?'
            @ 09,39 get k picture '999999'
//            SETCURSOR(SC_NORMAL)
            READ
            SET(_SET_ESCAPE,.F.)
//            SETCURSOR(SC_NONE)
            IF LASTKEY()#K_ESC.and.k#0
               (sel_main)->(DBSKIP(k))
               (sel_main)->(DBSKIP(IF(EOF(),-1,0)))
               EVAL(sv_block,@n1,@n2)
            END
            RESTSCREEN(6,24,11,57,uu)
      ELSEIF nkey=K_F6
            uu:=SAVESCREEN(6,27,12,54)
            m_npch1 := (sel_main)->npch
            m_ndoc1 := (sel_main)->ndoc
            SET(_SET_ESCAPE,.T.)
            SETCOLOR(hello1_clr)
            @6,27,11,52  BOX B_DOUBLE+" " COLOR "gr+/BG"
            @ 07,30 say 'Введите номер пачки'
            @ 08,39 get m_npch1 picture '999'
            @ 09,28 say 'Введите номер документа'
            @ 10,38 get m_ndoc1 picture '99999'
//            SETCURSOR(SC_NORMAL)
            READ
//            SETCURSOR(SC_NONE)
            SET(_SET_ESCAPE,.F.)
            RESTSCREEN(6,27,12,54,uu)
            IF LASTKEY() # K_ESC
               SAVE SCREEN TO  uu
               Wait_Mig()
               DBSELECTAREA(sel_main)
               k:=(sel_main)->(RECNO())
               DBGOTOP()
               LOCATE FOR IF(m_ndoc1==0,.t.,(sel_main)->ndoc==m_ndoc1) .and.;
                (sel_main)->npch=m_npch1  WHILE INKEY()#K_ESC
               RESTORE SCREEN FROM  uu
               IF (sel_main)->(FOUND())
                  EVAL(sv_block,@n1,@n2)
               ELSEIF LASTKEY()#K_ESC
                  DispError(' Документ N '+TRANSFORM(m_ndoc1,'99999')+;
                       ' в пачке N '+TRANSFORM(m_npch1,'999')+' не найден. ')
                  (sel_main)->(DBGOTO(k))
               ELSE
                  WaitMessage('Поиск пpекращен !')
                  (sel_main)->(DBGOTO(k))
               END
            END
      ELSEIF nkey==K_INS .and. b:autolite .and. m_reg1 .and. n1 # (sel_ved)->(LASTREC()+1) .and. ;
              ANSWERu('Добавити запис ?')==YES
            DBSELECTAREA(sel_ved)
            IF INSERT()
               (sel_ved)->&(s_vnum) := (sel_main)->&(s_vnum)
               n2 += 1
               b:home()
               IF UPPER(ALIAS(sel_ved)) == "FD2"
                  b:right();b:right()
               END
               b:RefreshAll()
               KEYBOARD CHR(K_ENTER)
            END
      ELSEIF nkey=K_UP .and. b:autolite
            IF (sel_ved)->(RECNO())>n1
               b:up()
            ELSEIF (sel_ved)->(RECNO())==n1 .or. n1==(sel_ved)->(LASTREC()+1)
                b:autolite := .F.
                b:dehilite()
            END
      ELSEIF nkey=K_DEL .and. b:autolite .and. m_reg1 .and. n1#(sel_ved)->(LASTREC()+1) .and. ;
            ANSWERu('Ви дiйсно бажаєте знищити запис ?') == YES
            IF n1 # n2
               (sel_ved)->(DBDELETE())
               IF (sel_ved)->(RECNO())==n2
                  (sel_ved)->(DBSKIP(-1))
                  n2 = (sel_ved)->(RECNO())
                  IF n2 == n1
                     KEYBOARD(CHR(K_UP))
                  END
               ELSEIF (sel_ved)->(RECNO())==n1
                  (sel_ved)->(DBSKIP())
                  n1 = (sel_ved)->(RECNO())
               ELSE
                  (sel_ved)->(DBSKIP())
               END
               b:RefreshAll()
            ELSE
               DispError('  Запись не может быть уничтожена  ')
            END
      ELSEIF nkey=K_F8
            k := b:cargo
            uu:=SAVESCREEN(k[1]-1,k[2]-1,k[3]+2,k[4]+3)
            SETCOLOR(HL_CLR)
            @k[1]-1,k[2]-1,k[3]+1,k[4]+1  BOX B_DOUBLE+" " COLOR "gr+/BG"
            DBSELECTAREA(sel_main)
            DBEDIT(k[1],k[2],k[3],k[4],k[5],"s_f_dbe","",k[6])
            SETCOLOR(VVOD_CLR)
            RESTSCREEN(k[1]-1,k[2]-1,k[3]+2,k[4]+3,uu)
            EVAL(sv_block,@n1,@n2)
    END
RETURN .t.

