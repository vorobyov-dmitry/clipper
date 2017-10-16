#include "new.ch"
MEMVAR m_tabn,m_oper,m_sprpath,m_imja
memvar m_syspath,a_menu,m_vdoc,M_TEMPPATH,M_BUFPATH,M_MAINPATH,M_EXEPATH
MEMVAR M_MASH,M_COPYPATH,M_DBSPATH,M_LEVEL,M_UCHPATH,M_COMPUTER,m_workpath

FUNCTION raschPaj(var1)
LOCAL m_path:=IF(var1==NIL,"d:\buhgal\",alltrim(var1)),GetList:={}
LOCAL m_mnt:="0401",m_ksash:="8900000",m_kopu:="099",s_files:={},m_paj:="1"

KSETCAPS(.f.)
KSETNUM(.t.)
Beginit (var1)

wboard(0,0,MAXROW(),MAXCOL())
SET KEY K_F10 TO Calcul
SET KEY K_ALT_F10 TO Calc
SET KEY K_F9 TO SetLpechat
SET KEY K_CTRL_U TO LSetprint

InitParPrn()
NET USE (m_syspath+"MENU_NEW") INDEX (m_syspath+"MENU_NEW") ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY

SET PRINTER TO (m_path+"ms\raschPaj.txt")
SET PRINTER ON
SET CONSOLE OFF
//  Sopenfiles("SP10",@s_files)

SopenFiles("001",@s_files)
SET ESCAPE ON
    @07,05,17,70 BOX B_DOUBLE+ " " COLOR "w+/bg"
    @08,07 SayDisp "Формирование начислений по паю >" COLOR "b/bg"
    @09,07 SayDisp "Период>" COLOR "b/bg"
    @09,16 Get m_mnt COLOR "w+/bg,GR+/n" PICTURE "99.99"
    GetList[1]:block:={|x|IF(x==NIL,RIGHT(m_mnt,2)+"."+LEFT(m_mnt,2),m_mnt:=RIGHT(x,2)+LEFT(x,2))}
    @10,07 SayDisp "Шифр>" COLOR "b/bg"
    @10,16 Get m_ksash COLOR "w+/bg,GR+/n" VALID Sp44->(sp_vl("SP44",,10 ,25,"sp44->naim7","Gr+/b"))
    @11,07 SayDisp "Пай>" COLOR "b/bg"
    @11,16 Get m_paj COLOR "w+/bg,GR+/n" 
    @12,07 SayDisp "Код опл>" COLOR "b/bg"
    @12,16 Get m_kopu COLOR "w+/bg,GR+/n" VALID Sp08->(sp_vl("SP08",,12 ,25,"sp08->name8","Gr+/b"))

    READ

Sclosefiles(@s_files)
IF LASTKEY()<>K_ESC
calcPaj(m_mnt,m_paj,m_ksash, m_kopu)
IndBd()
ENDIF


SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON
finish()
RETURN .t.

FUNCTION BegInit (m_var1)

   LOCAL SwapingSpace := 3,i,s1:=LOWER(EXENAME()) // количество свободного пространства
                                     // на диске в Мбайтах, необходимое для
                                     // работы АРМ "Бухгалтер"

   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor (0)
   SETBLINK(.f.)
   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
   PUBLIC   p_help_code  := 0                     // параметр для экранного HELP
   PUBLIC   msg1_clr     := 'w+*/bg'              // цвет сообщений с мерцанием
   PUBLIC   box_clr      := 'w/b'                 // цвет рамок и т.п.
   PUBLIC   hlp_clr      := 'n/w,gr+/w'           // цвет справок ( help'а )
   PUBLIC   psw_clr      := 'w+/bg,n/n'           // цвет пароля
   PUBLIC   hello_clr    := 'gr+/b'               // цвет обычного приветствия
   PUBLIC   head_clr     := 'r+/b'                // цвет начальной заставки
   PUBLIC   dos_clr      := SetColor ()           // цвет MS-DOS
   PUBLIC   str_clr      := 'w+/n'                // цвет
   PUBLIC   mnu_clr      := 'w+/b,n/w'            // цвет меню
   PUBLIC   ten_clr      := 'w/n'                 // цвет тени
   PUBLIC   phn_clr      := 'n/w'                 // цвет фона
   PUBLIC   vvod_clr     := 'w/b,gr+/n,,,n/w'   // цвет экрана ввода-вывода
   PUBLIC   vvod_mig_clr := 'w+*/b,gr+/n,,,w+/b'  // цвет экрана ввода-вывода
                                                  // с мерцанием
   PUBLIC   hello1_clr   := 'w+/bg,w+/n'          // цвет при вводе даты
   PUBLIC   poisk_clr    := 'gr+/bg'              // цвет шапки окна запроса
                                                  // при поиске и переходе
   PUBLIC   hl_clr       := 'n/w,gr+/n'           // цвет выделенного пункта
                                                  // при экранном вводе-выводе

   PUBLIC   m_dbspath   := ''              // каталог с текущей БД
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // каталог для машинограмм
   PUBLIC   m_syspath   := 'd:\buhgal\system\'  // каталог с  системной информацией
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // каталог для копий
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // каталог с буферной БД
   PUBLIC   m_workpath  :=""
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_computer
   IF .NOT.EMPTY(m_var1)
      IF .NOT.IsDigit(m_var1)
        IF RIGHT(m_var1,1)<>"\"
           m_mainpath  := m_var1+SUBSTR(m_mainpath  ,2)
           m_sprpath   := m_var1+SUBSTR(m_sprpath   ,2)
           m_exepath   := m_var1+SUBSTR(m_exepath   ,2)
           m_syspath   := m_var1+SUBSTR(m_syspath   ,2)
           m_bufpath   := m_var1+SUBSTR(m_bufpath   ,2)
           m_mash      := m_var1+SUBSTR(m_mash      ,2)
           m_copypath  := m_var1+SUBSTR(m_copypath  ,2)
           m_temppath  := m_var1+SUBSTR(m_temppath  ,2)
           m_uchpath   := m_var1+SUBSTR(m_uchpath  ,2)
        ELSE
          m_bufpath   := m_var1+'bf\'
          m_mainpath  := m_var1+'mn\'
          m_sprpath   := m_var1+'sp\'
          m_exepath   := m_var1+'bh\'
          m_mash      := m_var1+'ms\'
          m_syspath   := m_var1+'system\'
          m_copypath  := m_var1+'cp\'
          m_temppath  := m_var1+'temp\'
          m_uchpath   :=m_var1+'1_2\'
        ENDIF
      ELSE
        IF FILE("INIT.DBF")
          USE init NEW Readonly
          IF VAL(m_var1)>=1.AND.VAL(m_var1)<=LASTREC()
            DBGOTO(VAL(m_var1))
              m_bufpath   := ALLTRIM(init->bf)
              m_mainpath  := ALLTRIM(init->mn)
              m_sprpath   := ALLTRIM(init->sp)
              m_exepath   := ALLTRIM(init->bh)
              m_mash      := ALLTRIM(init->ms)
              m_syspath   := ALLTRIM(init->js)
              m_copypath  := ALLTRIM(init->cp)
              m_temppath  := ALLTRIM(init->tp)
              m_uchpath   := ALLTRIM(init->uch)
          ENDIF
          CLOSE init
    ENDIF
  ENDIF
 ELSEIF m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_mash      := s1+SUBSTR(m_mash      ,11)
       m_copypath  := s1+SUBSTR(m_copypath  ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
       m_uchpath   := s1+SUBSTR(m_uchpath  ,11)
 ENDIF

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- код оператора ( пользователя )
   PUBLIC m_tabn     := ' '      // --- табельный N оператора ( пользователя )

   PUBLIC m_imja  := ' '         // --- имя-отчество пользователя

   NET USE (m_syspath+"sovhoz") NEW READONLY
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- наименование предприятия
   USE

   PUBLIC m_vdoc    := 0                      // --- вид документа
   PUBLIC m_imjadoc := ''                     // --- название документа

   PUBLIC a_menu:={}
//   PUBLIC a_param:={}


   // проверка наличия свободного пространства на диске

   IF ( i := DiskSpace () ) <= ( SwapingSpace * 1048576 )
      ? Chr ( 7 )
      SetColor ( msg_clr )
      @ 10, 2,14,77 BOX '┌─┐│┘─└│ '
      @ 10, 1,14, 1 BOX ' '
      @ 10,78,14,78 BOX ' '
      @ 11,4 SayDisp 'Для нормальной работы АРМ необходимо ' + ;
                  Str ( SwapingSpace, 2 ) + ' Мбайт свободного места на диске.'
      @ 12,4 SayDisp '            Свободно '+ Str ( i / 1048576 , 5 , 2 ) + ;
                                  ' Мбайт. Запуск системы невозможен.'
      @ 13,4 SayDisp '             Для завершения работы нажмите любую клавишу.'
      i = Inkey ( 0 )
      SetColor ( dos_clr )
      CLEAR SCREEN
      QUIT
   ENDIF
  MEMOREAD(m_exepath+"computer.txt")
  m_computer:=VAL(TOKEN(MEMOREAD(m_exepath+"computer.txt")))

   // переиндексация всех файлов

//   Wait_Mig ()
RETURN .T.
FUNCTION  Finish
         SET COLOR TO &dos_clr
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
FUNCTION  calcPaj(m_mnt,m_paj,m_ksash, m_kopu)
LOCAL m_path,k1,m_gauge
CrStruct("MASH04","buf04")

USE (m_temppath+"buf04") NEW ALIAS buf
INDEX ON buf->tabn to (m_temppath+"buf04")
m_gauge:=InitGauge("Расчет пая",1)
m_path:=m_bufpath
FOR k1:=1 TO 2
NET USE (m_path+"fd2") NEW READONLY
NET USE (m_path+"fd1") NEW READONLY
  DO WHILE .NOT.fd1->(EOF())
      IF fd1->mnt == m_mnt.AND.fd1->paj=m_paj
        IF pFilpoz("fd2","vnuma","fd1")
         DO WHILE fd1->vnuma=fd2->vnuma.AND..NOT.fd2->(EOF())
            IF .NOT.buf->(DBSEEK(fd2->tabn))
              buf->(DBAP())
              buf->tabn:=fd2->tabn
            ENDIF
            buf->sum+=fd2->sum
            fd2->(DBSKIP())
         ENDDO
        ENDIF
      ENDIF
      fd1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fd1->(RECNO()/LASTREC()))
  ENDDO
CLOSE base Fd1,Fd2
  m_path:=m_mainpath

NEXT
DelGauge(m_gauge)
IF ( buf->(Lastrec())>0)
    USE (m_bufpath+"fz1") NEW
    USE (m_bufpath+"fz2") NEW
    USE (m_bufpath+"fz3") NEW
    USE (m_bufpath+"fvnum.dbr") NEW
  buf->(DBGOTOP())
    Fz1->(DBAP())
    fz1->vnum1:=fvnum->vnum1
    fz1->mnt:=m_mnt
//    fz1->ddoc:=CTOD("20/"+STRZERO(m_month)+
    fz1->ndoc:=VAL(RIGHT(m_mnt,2))
    fz1->npch:=603
    fz1->dvv:=DATE()
    fz1->vdoc:=21
   fvnum->vnum1:=fvnum->vnum1+1
  DO WHILE .NOT.buf->(EOF())
      fz2->(DBAP())
      fz2->vnum1:=fz1->vnum1
      fz2->ksash:=m_ksash
      fz2->tabn:=buf->tabn
      fz2->vnum2:=fvnum->vnum2
      fvnum->vnum2:=fvnum->vnum2+1
      fz3->(DBAP())
      fz3->vnum2:=fz2->vnum2
      fz3->kopu:=m_kopu
      fz3->sum:=buf->sum
      buf->(DBSKIP())
	ENDDO

  CLOSE  base fz3,fz1,fz2,fvnum
  ENDIF

Close buf
RETURN .t.
Function IndBd()
  LOCAL m_screen,m_proc,m_select,m_path
  m_path:=m_bufpath
  m_screen:=DispMessage("Iндексацiя;"+IF(m_path=m_bufpath,"бази за мiсяць","з початку року"))
   m_proc := InitGauge(" Iндексацiя бази" )
   DispGauge(m_proc, 0)
   USE (m_path+"fd2") NEW
   INDEX ON Str ( fd2->vnuma , 7 ) TO (m_path+"fd2")
   USE (m_path+"boln2")
   INDEX ON boln2->vnumc TO (m_path+"boln2")
   USE (m_path+"boln1")
   INDEX ON boln1->ser+boln1->num TO (m_path+"boln1")
   DispGauge(m_proc, 0.05)
   DispGauge(m_proc, 0.15)
   DispGauge(m_proc, 0.20)
   DispGauge(m_proc, 0.25)
   DispGauge(m_proc, 0.30)
   DispGauge(m_proc, 0.35)
   DispGauge(m_proc, 0.40)
   USE (m_path+"fz1ae")
   INDEX ON Str ( fz1ae->vnum1 , 7 ) TO (m_path+"fz1ae")
   DispGauge(m_proc, 0.45)
   USE (m_path+"fz1ap")
   INDEX ON Str ( fz1ap->vnum1 , 7 ) TO (m_path+"fz1ap")
   DispGauge(m_proc, 0.50)
   USE (m_path+"fz1at")
   INDEX ON Str ( fz1at->vnum1 , 7 ) TO (m_path+"fz1at")
   DispGauge(m_proc, 0.55)
   USE (m_path+"fz1t")
   INDEX ON Str ( fz1t->vnum1 , 7 ) TO (m_path+"fz1t")
   DispGauge(m_proc, 0.60)
   USE (m_path+"fz1tp")
   INDEX ON Str ( fz1tp->vnum1 , 7 ) TO (m_path+"fz1tp")
   DispGauge(m_proc, 0.65)
   USE (m_path+"fz2")
   INDEX ON Str ( fz2->vnum1 , 7 ) TO (m_path+"fz2")
   DispGauge(m_proc, 0.75)
   USE (m_path+"fz2a")
   INDEX ON Str ( fz2a->vnum2 , 7 ) TO (m_path+"fz2a")
   DispGauge(m_proc, 0.80)
   USE (m_path+"fz2b")
   INDEX ON Str ( fz2b->vnum1 , 7 ) TO (m_path+"fz2b")
   DispGauge(m_proc, 0.85)
   USE (m_path+"fz2t")
   INDEX ON Str ( fz2t->vnum2 , 7 ) TO (m_path+"fz2t")
   DispGauge(m_proc, 0.90)
   USE (m_path+"fz2tp")
   INDEX ON Str ( fz2tp->vnum2 , 7 ) TO (m_path+"fz2tp")
   DispGauge(m_proc, 0.95)
   USE (m_path+"fz3")
   INDEX ON Str ( fz3->vnum2 , 7 ) TO (m_path+"fz3")
   DispGauge(m_proc, 1.00)
   USE
DelGauge(m_proc)
DelMessage(m_screen)
RETURN .t.

Function CrStruct(m_name,m_file)
LOCAL a_struct:={}
  NET USE  (m_syspath+"Struct") INDEX (m_syspath+"Struct") NEW READONLY
  struct->(DS(m_name))
  DO WHILE .NOT.struct->(EOF()).AND.m_name==ALLTRIM(struct->name)
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
  DBCREATE(m_temppath+m_file,a_struct)
  CLOSE STRUCT
RETURN .T.

FUNCTION pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)

LOCAL  m_fict_zap,n1:=(m_nmfl_1)->(FIELDNUM(ALLTRIM(m_nmpl_1)))
LOCAL  m_fict_al,n2:=(m_nmfl_2)->(FIELDNUM(ALLTRIM(m_nmpl_1)))
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
LOCATE  REST  FOR  (m_nmfl_1)->(FIELDGET(n1))==(m_nmfl_2)->(FIELDGET(n2))
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF
RETURN .t.
