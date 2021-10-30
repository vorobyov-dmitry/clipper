#INCLUDE "new.ch"
#include "menu.ch"

#XCOMMAND CheckLink(<fz1>,<fz2>,<vnum1>) =>;
ChErr1(SELECT(<"fz1">),SELECT(<"fz2">),<"vnum1">);;
IF n_ret==0;n_fat:=1;l_exit:=.t.;EXIT;END;;
IF n_ret==1;LOOP;END
#XCOMMAND cherr2(<fz1>,<fz2>,<vnum1>) =>;
IF .NOT.ChErr03(<fz1>,<fz2>,<vnum1>);LOOP;END
#XCOMMAND CheckKod(<sp01>,<kod>,<fz1>,<name>) => ;
Checkww(SELECT(<"sp01">),<kod>,SELECT(<"fz1">),<name>)
#XCOMMAND SkipVnum(<fz1>,<fz2>,<vnum1>) =>SkipVn(SELECT(<"fz1">),SELECT(<"fz2">),<"vnum1">)
#XCOMMAND SetVnum(<fz1>,<fz2>,<vnum1>,<var>) =>SkipVn1(SELECT(<"fz1">),SELECT(<"fz2">),<"vnum1">,<var>)


#DEFINE N_SYMBOL 4
#define MAKET_NUM "90"
#define FIRST_TABL 8 // номер строки в a_const - дебет

MEMVAR a_menu,m_mainpath,m_sprpath,m_bufpath,p_npr,m_mash,m_tabn,m_imja
MEMVAR m_temppath,m_platpath,m_oper,m_syspath,m_computer,m_exepath,m_copypath
STATIC m_vnum,m_color,lApnd:=.f.,m_oldvnum,m_level
STATIC n_error:=-1,n_warn:=-1

//  STATIC lCopy:=.f.

Function Prov(var)
LOCAL m_browse,m_br1,a_get1:={},a_const:={},m_maket,a_get2:={},l_print:={},m_col
LOCAL m_path:=IF(a_menu[1]=="MAIN",m_mainpath,m_bufpath),n_win,a_files:={},m_mnt
LOCAL m_key,a_get3:={},n1,a_data1:={},i,n_pole,l_delete:=.t.,n3,s_const2:=""
LOCAL m_mnt2 // для хранения месяца документа получаемого по дате
LOCAL l_first:=.f.,l_update:=.f.,m_buf,m_recno,m_last,j,m_screen,k,m_vnum1,a_func:={}
LOCAL b_mnt1:={|x|SETPOS(1,36),DISPOUT(LEFT(PADR(mnt_dtoc(x),15),15),"Gr+/B")}
DCL MENU
 AADD(a_func,{K_ALT_F,{||SelMaket(@a_const,MAKET_NUM,{|p|SetName90(p)},{|p|EditMt90(p)}),CrBr2(@m_br1,@m_browse,@a_const,@s_const2)}})
 AADD(a_func,{K_ALT_W,{||EditMt90(@a_const),CrBr2(@m_br1,@m_browse,@a_const,@s_const2)}})

NET USE (m_path+"fvnum.dbr") NEW
m_mnt:=fvnum->mnt1
IF .NOT.RECURS()
  n_win:=InitScr("PROV")
  READEXIT(.t.)
  @1,2 SayDisp LEFT(p_npr,20) COLOR "GR+/B"
//  WaitMessage("Програма книги господарчих операцiй "+IF(a_menu[1]=="MAIN","основної","буферної")+" бази даних")
  OpenFp(m_path)
//  SET RELATION TO Fp2->vnum INTO Fp1
NET USE (m_platpath+"FIRM01") INDEX (m_platpath+"Firm01"),(m_platpath+"Firm01a"),(m_platpath+"Firm01b") NEW
NET USE (m_platpath+"BANK01") INDEX (m_platpath+"BANK01") NEW
NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
  sOpenFiles("201",a_files)
  m_vnum:=Fp2->vnum;m_color:=.t.;m_oldvnum:=BLANK(Fp2->vnum,.t.)
  CrBr1(@m_br1,@l_print,@a_get2,@a_get3,@m_browse)
  n3:=LEN(a_get3)
// Установка таксировки ЛЗК
  a_get2[n3-2]:postblock:=a_get3[n3-2]:postblock:={||CalcKg(m_maket,m_mnt2)}

  CrGet1(@a_get1)
  a_const:=ReadMaket("01",MAKET_NUM,{|p|SetName90(p)})
//  m_browse:=m_br1
  CrBr2(@m_br1,@m_browse,@a_const,@s_const2)


 n1:=LEN(a_get1)
 ASIZE(a_data1,n1)
  FOR i:=1 TO n1
    a_get1[i]:block:=COLBR(a_data1[n_pole])
  NEXT
  a_get1[6]:Block:={|x|IF(x==NIL,mnt_data(a_data1[6]),a_data1[6]:=Mnt_field(x))}
  a_get1[6]:PostBlock:={||EVAL(b_mnt1,a_data1[6]),.t.}
  a_get1[1]:PostBlock:=a_get1[2]:PostBlock:={|p|EVAL(p:block,;
 JustRight(EVAL(p:block))),p:display(),IF(.NOT.EMPTY(p:buffer),Check01(a_data1[1],a_data1[2]),.f.)}
 a_get1[4]:Postblock:={|p|CheckTabn(a_data1,m_maket)}
 a_get1[5]:PostBlock:={|p|CheckNum(p,m_maket)}
// a_get1[4]:PreBlock:={||.f.}
  SET ESCAPE ON
  lApnd:=.f.
  CREATE MENU STANDART
  INIT MENU
  DO WHILE .t.
    m_browse:ColorRect({m_browse:Rowpos,1,m_browse:Rowpos,m_browse:ColCount},EVAL(m_browse:GetColumn(1):colorBlock))
    STABILIZE BROWSE m_browse
    IF m_browse:stabilize().AND..NOT.Fp2->(BOF())
      m_browse:ColorRect({m_browse:Rowpos,1,m_browse:Rowpos,m_browse:ColCount},Color1())
      m_browse:ColorRect({m_browse:Rowpos,m_browse:ColPos,m_browse:Rowpos,m_browse:ColPos},Color2())
      Fp2->(DBGOTO(RECNO()))

      IF m_oldvnum<>m_vnum .OR.Fp2->(BOF()).AND.Fp2->(EOF())     //перейшли на новий документ или пустая база
    //    Вивiд шапки документа
        fp1->(DS(fp2->vnum))
        IF .NOT.Fp1->(FOUND())
          DispError("Для данної проводки не iснує заголовка!!!;Вона iгнорується при розрахунках; i її необхiдно удалити")
        ENDIF
        SayShapka(@a_get1,@n_pole,@n1,@a_data1,b_mnt1)


        IF .NOT.EMPTY(fp1->num)
          DO CASE
            CASE  fp1->maket=="02" // Водiї
              inv_a->(DBSEEK(fp1->num))
              Sp13a->(DBSEEK(inv_a->kavt))
              @5,19 SayDisp sp13a->naim13a  COLOR "GR+/B"
            CASE fp1->maket=="03" // Трактористи - машинiсти
              inv_t->(DBSEEK(fp1->num))
              Sp13b->(DBSEEK(inv_t->kmtr))
              @5,19 SayDisp sp13b->naim13b  COLOR "GR+/B"
          OTHERWISE
              @5,19 SayDisp SPACE(20)  COLOR "GR+/B"
          ENDCASE
        ELSE
              @5,19 SayDisp SPACE(20)  COLOR "GR+/B"
        ENDIF
        m_oldvnum:=m_vnum
      ENDIF
      // Вивiд строки
      Say3()
      AEVAL(a_get3,{|x|x:display()})
     ENDIF
      Fp2->(DBGOTO(RECNO()))
    IF .NOT.(Fp2->(BOF()).AND.Fp2->(EOF()))
      m_key:=INKEY(0)
    ELSE
      m_key:=K_TAB
    ENDIF

    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_1
            Fp2->(DBSETORDER(1))
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent();m_browse:refreshAll()
      CASE m_key==K_ALT_2
            Fp2->(DBSETORDER(2))
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent();m_browse:refreshAll()
      CASE m_key==K_ALT_3
            Fp2->(DBSETORDER(3))
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent();m_browse:refreshAll()
      CASE m_key==K_ALT_4
            Fp2->(DBSETORDER(4))
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent();m_browse:refreshAll()
      CASE m_key==K_SH_F6
            ShiftF6(m_browse)
      CASE m_key==K_F2;PrintProv()
      CASE m_key==K_INS
        m_mnt2:=mnt_dtod(Fp1->ddoc)
        m_maket:=Fp1->maket
        ReadFp2(@m_browse,@a_get2,@a_get3,@a_const,@m_br1,fp1->vnum,a_func)
      CASE m_key==K_ENTER
        SET ESCAPE ON
        m_mnt2:=mnt_dtod(Fp1->ddoc)
        m_maket:=Fp1->maket
        STABILIZE BROWSE m_browse
        IF m_browse:GetColumn(m_browse:ColPos):cargo<>NIL
          i:=m_browse:GetColumn(m_browse:ColPos):cargo
          IF fp2->(NetRlock())
            a_get2[i]:Row:=ROW();a_get2[i]:Col:=COL();ReadMy({a_get2[i]})
            Fp2->(DbUnlock())
          ENDIF
          m_browse:RefreshCurrent()
        ENDIF
      CASE m_key==K_DEL
          IF .NOT.l_delete.OR.( ANSWERu( "Ви дiйсно бажаєте знищити запис ?" )==YES )
            IF   Fp1->(FOUND()).AND.fp2->(IsSingle(FIELDBLOCK("vnum")))
              DispError("Запис не може бути видалено !; Видалите весь документ ")
            ELSE
              IF Fp2->(NetRlock())
                  fp2->(dbdelete())
                  Fp2->(dbUNLOCK())
              ENDIF
              Fp2->(DBSKIP(1))
              IF Fp2->(EOF())
                Fp2->(DBSKIP(-1))
              ENDIF
              m_browse:RefreshAll()
            ENDIF
          ENDIF
    CASE m_key==K_CTRL_BS .AND.m_level==0
        IF Fp2->(NetRlock())
            fp2->(dbdelete())
            Fp2->(dbUNLOCK())
        ENDIF
        Fp2->(DBSKIP(1))
        IF Fp2->(EOF())
          Fp2->(DBSKIP(-1))
        ENDIF
        m_browse:RefreshAll()

      CASE m_key==K_F10
        Calcul()
      CASE m_key==K_ALT_F
        SelMaket(@a_const,MAKET_NUM,{|p|SetName90(p)},{|p|EditMt90(p)})
        CrBr2(@m_br1,@m_browse,@a_const,@s_const2)
      CASE m_key==K_ALT_W
        EditMt90(@a_const)
        CrBr2(@m_br1,@m_browse,@a_const,@s_const2)
      CASE m_key==K_ALT_F10
        Calc()
      CASE m_key==K_CTRL_RET.OR.m_key==K_F11
        m_browse:ColorRect({m_browse:Rowpos,m_browse:ColPos,m_browse:Rowpos,m_browse:ColPos},Color1())
        n_pole:=1
        DO WHILE .t.
          a_get3[n_pole]:ColorDisp("b/w")
          m_key:=INKEY(0)
          a_get3[n_pole]:ColorDisp("w/b*,Gr+/N")
          DO CASE
            CASE m_key==K_ESC.OR.m_key==K_TAB
              EXIT
            CASE m_key==K_RIGHT
              IF n_pole==1;n_pole:=5;ENDIF
              IF n_pole==2;n_pole:=6;ENDIF
              IF n_pole==3;n_pole:=7;ENDIF
              IF n_pole==4;n_pole:=8;ENDIF
              IF n_pole==10;n_pole:=11;ENDIF
              IF n_pole==11;n_pole:=12;ENDIF
              IF n_pole==12;n_pole:=13;ENDIF
            CASE m_key==K_LEFT
              IF n_pole==5 ;n_pole:=1;ENDIF
              IF n_pole==6 ;n_pole:=2;ENDIF
              IF n_pole==7 ;n_pole:=3;ENDIF
              IF n_pole==8 ;n_pole:=4;ENDIF
              IF n_pole==13;n_pole:=12;ENDIF
              IF n_pole==12;n_pole:=11;ENDIF
              IF n_pole==11;n_pole:=10;ENDIF
            CASE m_key==K_UP
              n_pole:=MAX(1,n_pole-1)
            CASE m_key==K_DOWN
              n_pole:=MIN(n3,n_pole+1)
            CASE m_key==K_ALT_F
              SelMaket(@a_const,MAKET_NUM,{|p|SetName90(p)},{|p|EditMt90(p)})
              CrBr2(@m_br1,@m_browse,@a_const,@s_const2)
            CASE m_key==K_ALT_W;EditMt90(@a_const);CrBr2(@m_br1,@m_browse,@a_const,@s_const2)
            CASE m_key==K_F10
              Calcul()
            CASE m_key==K_ALT_F10
              Calc()
            CASE m_key==K_INS
              m_recno:=RECNO();lApnd:=.t.
              m_maket:=Fp1->maket
              m_mnt2:=mnt_dtod(Fp1->ddoc)
              m_vnum1:=Fp2->vnum
              DO WHILE lApnd
                fp2->(DBGOBOTTOM())
                fp2->(DBSKIP())
                Say3()
                AEVAL(a_get3,{|x|x:display()})
                m_buf:=ReadGet1(a_get3[1],l_first,@l_update,a_func)
                DO CASE
                  CASE LASTKEY()==K_UP.OR.LASTKEY()==K_ESC.OR.EMPTY(m_buf).AND..NOT.l_update
                    lApnd:=.f.
                    EXIT
                  OTHERWISE
                  IF  fp2->(NetDBAP())
                    // Заполнение константами
                      FillConst(@m_br1,@a_const,a_get2,m_buf,m_vnum1)
                      m_recno:=Fp2->(RECNO())
                    // Ввод строки
                      Say3()
                      AEVAL(a_get3,{|x|x:display()})
                      n_pole:=2
                      DO WHILE .T.
                          IF a_const[a_get3[n_pole]:cargo,3]<>"Н"
                            ReadMy({a_get3[n_pole]})
                            IF LASTKEY()==K_UP.OR.LASTKEY() == K_LEFT
                              DO WHILE n_pole>1
                                n_pole--
                                IF a_const[a_get3[n_pole]:cargo,3]<>"Н";
                                  .AND.(a_get3[n_pole]:PreBlock==NIL.OR.EVAL(a_get3[n_pole]:PreBlock))
                                  EXIT
                                ENDIF
                              ENDDO
                              LOOP
                            ENDIF
                          ENDIF
                          IF n_pole==LEN(a_get3)
                            EXIT
                          ENDIF
                          n_pole++
                     ENDDO
                      Fp2->(DbUnlock())
                  ENDIF
                  ENDCASE
              ENDDO
              fp2->(DBGOTO(m_recno))
              m_browse:RefreshAll()
              STABILIZE BROWSE m_browse
              Say3()
              AEVAL(a_get3,{|x|x:display()})
            CASE m_key==K_ENTER
              SET ESCAPE ON
              IF fp2->(NetRlock())
                ReadMy({a_get3[n_pole]})
                Fp2->(dbUnlock())
                m_browse:RefreshCurrent()
              ENDIF
          ENDCASE
        ENDDO
        m_browse:ColorRect({m_browse:Rowpos,m_browse:ColPos,m_browse:Rowpos,m_browse:ColPos},Color2())
      CASE m_key==K_TAB // Редагування заголовка документа
        m_browse:ColorRect({m_browse:Rowpos,m_browse:ColPos,m_browse:Rowpos,m_browse:ColPos},Color1())
        n_pole:=1
        m_maket:=Fp1->maket
        m_mnt2:=mnt_dtod(Fp1->ddoc)
        DO WHILE .t.
          a_get1[n_pole]:ColorDisp("b/w")
          Fp2->(DBGOTO(RECNO()))
          IF .NOT.(Fp2->(BOF()).AND.Fp2->(EOF()))
            m_key:=INKEY(0)
          ELSE
            m_key:=K_INS
          ENDIF
          a_get1[n_pole]:ColorDisp("w/b*,Gr+/N")
          DO CASE
            CASE m_key==K_ESC.OR.m_key==K_TAB
              EXIT
              CASE m_key==K_DEL
                IF .NOT.l_delete.OR.( ANSWERu( "Ви дiйсно бажаєте знищити документ ?" )==YES )
                  Fp2->(DS(fp1->vnum))
                  DO WHILE (Fp1->vnum==Fp2->vnum.AND..NOT.Fp2->(EOF()))
                      IF Fp2->(NetRlock())
                          fp2->(dbdelete())
                          Fp2->(dbUNLOCK())
                      ENDIF
                    Fp2->(DBSKIP())
                  ENDDO
                  IF Fp1->(NetRlock())
                      fp1->(dbdelete())
                      Fp1->(dbUNLOCK())
                  ENDIF
                ENDIF
                // ОТОБРАЖЕНИЕ НОВОГО ДОКУМЕНТА
                IF Fp2->(EOF())
                  Fp2->(DBSKIp(-1))
                ENDIF
                m_browse:rowPos:=1;m_browse:configure()
                m_browse:refreshCurrent();m_browse:refreshAll()
                exit
  /*
            CASE m_key==K_RIGHT
              IF n_pole==4;n_pole:=5;ENDIF
              IF n_pole==1;n_pole:=4;ENDIF
              IF n_pole==3;n_pole:=6;ENDIF
            CASE m_key==K_LEFT
              IF n_pole==4;n_pole:=1;ENDIF
              IF n_pole==5;n_pole:=4;ENDIF
              IF n_pole==6;n_pole:=3;ENDIF */
            CASE m_key==K_UP
                n_pole:=MAX(1,n_pole-1)
            CASE m_key==K_DOWN
              n_pole:=MIN(n1,n_pole+1)
            CASE m_key==K_F10
              Calcul()
            CASE m_key==K_ALT_F10
              Calc()
            CASE m_key==K_ENTER
              SET ESCAPE ON
              ReadMy({a_get1[n_pole]},a_func)
              IF LASTKEY()<>K_ESC .AND.fp1->(NetRlock())
                   fp1->(FIELDPUT(a_get1[n_pole]:cargo,a_data1[n_pole]))
                   Fp1->(dbUnlock())
              ENDIF

              SET ESCAPE OFF
            CASE m_key==K_ALT_F
              SelMaket(@a_const,MAKET_NUM,{|p|SetName90(p)},{|p|EditMt90(p)})
              CrBr2(@m_br1,@m_browse,@a_const,@s_const2)
            CASE m_key==K_ALT_W
              EditMt90(@a_const)
              CrBr2(@m_br1,@m_browse,@a_const,@s_const2)


            CASE m_key==K_INS //Вввод нового документа
              IF SelMaket(@a_const,MAKET_NUM,{|p|SetName90(p)},{|p|EditMt90(p)})
                EditMt90(@a_const)
                CrBr2(@m_br1,@m_browse,@a_const,@s_const2)
                STABILIZE BROWSE m_browse
                FOR i:=1 TO n1
                  a_data1[i]:=BLANK(fp1->(FIELDGET(a_get1[i]:cargo)),.t.)
//                  a_get1[i]:Display()
                NEXT
                a_data1[1]:=BLANK(a_data1[1],.t.)
                a_data1[2]:=BLANK(a_data1[2],.t.)
                m_last:=a_data1[2]
//                a_data1[3]:=BLANK(date(),.t.)
                a_get1[3]:PreBlock:={||IF(a_const[1,3]<>"Н",.t.,.f.)}
                a_get1[4]:PreBlock:={||IF(a_const[2,3]<>"Н",.t.,.f.)}
                a_get1[5]:PreBlock:={||IF(a_const[3,3]<>"Н",.t.,.f.)}
                a_get1[6]:PreBlock:={||IF(a_const[4,3]<>"Н",.t.,.f.)}
                a_get1[7]:PreBlock:={||IF(a_const[5,3]<>"Н",.t.,.f.)}
                a_get1[8]:PreBlock:={||IF(a_const[6,3]<>"Н",.t.,.f.)}
                a_get1[9]:PreBlock:={||IF(a_const[7,3]<>"Н",.t.,.f.)}
                @1,58 SayDisp m_oper  COLOR "Gr+/b"
                @1,61 SayDisp LEFT(_fio(GetOper(m_oper)),20) COLOR "Gr+/b"
                m_maket:=a_const[LEN(a_const)][1]
                DO WHILE .t.
                  // Опробелить значение всех полей
                  FOR i:=3 TO LEN(a_data1)
                    // Для лимитно - заборных карт не делаеться очистка даты , таб. номер и номера машины
                    IF (m_maket<>"02".AND.m_maket<>"03").OR.(i<>3.AND.i<>4.AND.i<>5)
                      a_data1[i]:=BLANK(a_data1[i],.t.)
                    ENDIF
                  NEXT
                  // присвоение предопределенных значений
                  FOR i:=1 TO 7
                    IF .NOT.EMPTY(a_const[i][2])
                      a_data1[i+2]:=a_const[i][2]
                    ENDIF
                  NEXT
                  IF EMPTY(a_const[4,2])
                    a_data1[6]:=m_mnt
                  ELSE
                    a_data1[6]:=a_const[4,2]
                  ENDIF
                  // Вывод шапки документа
                  n_pole:=1;AEVAL(a_get1,{|x|a_get1[n_pole]:Display(),n_pole++})
                  @2,31 SayDisp m_last COLOR "gr+/b"
                  @2,47 SayDisp a_const[len(a_const),1] COLOR "gr+/b"
                  @2,50 SayDisp a_const[len(a_const),2]
                  n_pole:=IF(EMPTY(a_data1[1]),1,2)
                  // Ввод шапки документа
                  SET ESCAPE ON
                  IF ReadList(a_get1,@n_pole,a_func)==0
                    EXIT
                  ENDIF
                  // Запис документа
                  m_last:=a_data1[2]
                  // Ввод строк документа
                  IF fvnum->(NetRlock())
                    m_vnum1:=STR(fvnum->vnum,7)
                    fvnum->vnum:=fvnum->vnum+1
                    fvnum->(DBCOMMIT())
                    fvnum->(DbUnlock())
                  ELSE
                    DispError("Вiдмовлено в доступi")
                    EXIT
                  ENDIF
                  m_mnt2:=mnt_dtod(a_data1[3])

                  IF .NOT.ReadFp2(@m_browse,@a_get2,@a_get3,@a_const,@m_br1,m_vnum1,a_func)
                    DispError("Не було введено жодної строки документа;Документ буде iгноровано !")
                  ELSE
                    IF fp1->(NetDBAP())
                       j:=1
                       AEVAL(a_get1,{|X|Fp1->(FIELDPUT(x:cargo,a_data1[j++]))})
                       Fp1->vnum:=m_vnum1
                       Fp1->oper:=m_oper
                       Fp1->maket:=a_const[LEN(a_const)][1]
                       Fp1->dvv:=DATE()
                       Fp1->(DbUnlock())
                    ENDIF

                  ENDIF
                  a_data1[2]:=STR(VAL(a_data1[2])+1,LEN(a_data1[2]))
                ENDDO
               FOR i:=3 TO LEN(a_get1)
                a_get1[i]:PreBlock:={||.t.}
                NEXT
              ENDIF
//              Fp2->(DBGOTO(RECNO()))
        // Вышли из ввода и перерисовали экран
        // перерисовывем таблицу
        Fp2->(DBSETORDER(0))
        Fp2->(DBGOBOTTOM())  // ПЕРЕХОД НА ПОСЛЕДНЮЮ ВВЕДЕННУЮ СТРОКУ
        Fp2->(DBSETORDER(1))
        m_browse:rowPos:=1;m_browse:configure()
        m_browse:refreshCurrent();m_browse:refreshAll()
        STABILIZE BROWSE m_browse
        m_browse:ColorRect({m_browse:Rowpos,m_browse:ColPos,m_browse:Rowpos,m_browse:ColPos},Color1())
        // перерисовываем шапку
        Fp1->(DS(Fp2->vnum))
        IF .NOT.Fp1->(FOUND())
          DispError("Для данної проводки не iснує заголовка!!!;Вона iгнорується при розрахунках; i її необхiдно удалити")
        ENDIF
        SayShapka(@a_get1,@n_pole,@n1,@a_data1,b_mnt1)

          ENDCASE
        ENDDO
/*        IF fp1->(NetRlock())
          FOR n_pole:=1 TO n1
            fp1->(FIELDPUT(a_get1[n_pole]:cargo,a_data1[n_pole]))
          NEXT
          Fp1->(dbUnlock())
        ENDIF */

    ENDCASE
  ENDDO
  SCLOSEFILES(a_files)
  CLOSE base fp2,fp1,Firm01,Bank01,Kaptka1,fvnum
  Wclose(n_win)
ENDIF
RETURN .t.
STATIC FUNCTION SkipDb(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // Если конец файла
       IF  EOF()
          IF  lApnd
             nCount++
          ELSE
             DBSKIP( -1 )
          ENDIF
          EXIT
       END
       ncount++
       IF m_vnum<>fp2->vnum.AND..NOT.lApnd
        m_vnum:=fp2->vnum
        m_color:=.NOT.m_color
       ENDIF
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
       IF m_vnum<>fp2->vnum.AND..NOT.lApnd
        m_vnum:=fp2->vnum
        m_color:=.NOT.m_color
       ENDIF
   ENDDO
END
RETURN ( ncount )
STATIC Function  CrBr1(m_br1,l_print,a_get2,a_get3,m_browse)
LOCAL m_col,i,j

  m_br1:=TBrowseDB(14,1,MAXROW()-1,MAXCOL()-1)
  m_br1:colorspec:='W/B,B/W,w+/b,w/gr,gr/w,w+/gr'
  m_br1:SkipBlock     := { |n| fp2->(SkipDb(n)) }
  m_br1:goBottomBlock := { ||  fp2->(DBGOBOTTOM()) }
  m_br1:goTopBlock    := { ||  fp2->(DBGOTOP())  }

  m_browse:=TBrowseDB(14,1,MAXROW()-1,MAXCOL()-1)
  m_browse:colorspec:='W/B,B/W,w+/b,w/gr,gr/w,w+/gr'
  m_browse:SkipBlock     := { |n| fp2->(SkipDb(n)) }
  m_browse:goBottomBlock := { ||  fp2->(DBGOBOTTOM()) }
  m_browse:goTopBlock    := { ||  fp2->(DBGOTOP())  }

  // Описание блоков

  //  Код   дебету
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->dbt)
      m_col:heading:="Код;дебету"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp44->(Sp_vl("SP44"))}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:=7;a_get3[LEN(a_get3)]:col:=5
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp44->(Sp_vl("SP44",,7,15,"Sp44->naim7","Gr+/b"))}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7}
      m_col:heading:=" Назва дебету"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->cod1)
      m_col:heading:="Код аналiт;дебету"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:={|x|IF(x==NIL,AnalCod(x,fp2->dbt,fp2->cod1),fp2->cod1:=PADR(x,10))}
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|AnCodValid(fp2->dbt,fp2->cod1)}
      a_get2[LEN(a_get2)]:PreBlock:={||PreAnCod(fp2->dbt)}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=a_get2[LEN(a_get2)]:Block
      a_get3[LEN(a_get3)]:row:=8;a_get3[LEN(a_get3)]:col:=5
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|AnCodValid(fp2->dbt,fp2->cod1,8,15,,24)}
      a_get3[LEN(a_get3)]:PreBlock:={||PreAnCod(fp2->dbt)}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||AnCodName(fp2->dbt,fp2->cod1)}
      m_col:heading:=" Назва дебету"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)

  // Одержувач

      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->kplh)
      m_col:heading:="Од;ер"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp02->(Sp_vl("SP02","2"))}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:= 9;a_get3[LEN(a_get3)]:col:= 8
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp02->(Sp_vl("SP02","2",9,11,"_mol()","Gr+/b",28))}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||_mol(fp2->kplh)}
      m_col:heading:=" Ф.I.Б. одержувача"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)

// Бригада замовник

      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->brgd1)
      m_col:heading:="Бр;гд"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp01->(Sp_vl("SP01","2"))}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:=10;a_get3[LEN(a_get3)]:col:=8
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp01->(Sp_vl("SP01","2",10,11,"Sp01->naim1","Gr+/b"))}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||Sp01->(DBSEEK(fp2->brgd1)),Sp01->naim1}
      m_col:heading:=" Назва бригади"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)

// кредiт

      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->crt)
      m_col:heading:="Код;кред."
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp44->(Sp_vl("SP44"))}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:= 7;a_get3[LEN(a_get3)]:col:= 44
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp44->(Sp_vl("SP44",,7,52,"Sp44->naim7","Gr+/b"))}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7}
      m_col:heading:=" Назва кредiту"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->cod2)
      m_col:heading:="Код аналiт;кредiту"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:={|x|IF(x==NIL,AnalCod(x,fp2->crt,fp2->cod2),fp2->cod2:=PADR(x,10))}
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|AnCodValid(fp2->crt,fp2->cod2)}
      a_get2[LEN(a_get2)]:PreBlock:={||PreAnCod(fp2->crt)}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=a_get2[LEN(a_get2)]:Block
      a_get3[LEN(a_get3)]:row:=8;a_get3[LEN(a_get3)]:col:=44
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|AnCodValid(fp2->crt,fp2->cod2,8,54,,24)}
      a_get3[LEN(a_get3)]:PreBlock:={||PreAnCod(fp2->crt)}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||AnCodName(fp2->crt,fp2->cod2)}
      m_col:heading:=" Назва кредiту"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)

// Вiдправник

      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->otp)
      m_col:heading:="Вi;дп"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp02->(Sp_vl("SP02","2"))}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:=9;a_get3[LEN(a_get3)]:col:=47
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp02->(Sp_vl("SP02","2",9,50,"_mol()","Gr+/b",28))}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||_mol(fp2->otp)}
      m_col:heading:=" Ф.I.Б. вiдправника"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)

// Бригада виконавець

      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->brgd2)
      m_col:heading:="Бр;гд"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp01->(Sp_vl("SP01","2"))}
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:=10;a_get3[LEN(a_get3)]:col:=47
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp01->(Sp_vl("SP01","2",10,50,"Sp01->naim1","Gr+/b"))}
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||Sp01->(DBSEEK(fp2->brgd2)),Sp01->naim1}
      m_col:heading:=" Назва бригади"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"
  m_br1:addColumn(m_col)

// Стаття витрат

      m_Col           := TBColumnNew()
      m_col:block:=COLBR(fp2->kopr)
      m_col:heading:="Оп;ер"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=m_col:block
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      a_get2[LEN(a_get2)]:PostBlock:={|p|Sp05->(Sp_vl("SP05","2"))}
      m_col:Cargo:=LEN(a_get2)
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=m_col:block
      a_get3[LEN(a_get3)]:row:=11;a_get3[LEN(a_get3)]:col:=47
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      a_get3[LEN(a_get3)]:PostBlock:={|p|Sp05->(Sp_vl("SP05","2",11,50,"Sp05->naim5a","Gr+/b"))}
  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a}
      m_col:heading:=" Назва операцiї"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "──";m_col:footsep:="══"

// Кiлькiснi показники

  m_br1:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:={||NumToStr(fp2->glv,7,0)}
      m_col:heading:="Голiв"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=COLBR(fp2->glv)
      a_get2[LEN(a_get2)]:picture="999'999"
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=COLBR(fp2->glv)
      a_get3[LEN(a_get3)]:row:=13;a_get3[LEN(a_get3)]:col:=4
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)

      m_Col           := TBColumnNew()
      m_col:block:={||NumToStr(fp2->kvo2,14,2)}
      m_col:heading:="Залiкова вага; Лiтри"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=COLBR(fp2->kvo2)
      a_get2[LEN(a_get2)]:picture="999'999'999.99"
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=COLBR(fp2->kvo2)
      a_get3[LEN(a_get3)]:row:=13;a_get3[LEN(a_get3)]:col:=15
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)

      m_Col           := TBColumnNew()
      m_col:block:={||NumToStr(fp2->kvo,14,2)}
      m_col:heading:="Кiлькiсть"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=COLBR(fp2->kvo)
      a_get2[LEN(a_get2)]:picture="999'999'999.99"
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:Block:=COLBR(fp2->kvo)
      a_get3[LEN(a_get3)]:row:=13;a_get3[LEN(a_get3)]:col:=31
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)

      m_Col           := TBColumnNew()
      m_col:block:={||SumToStr(fp2->stm,17)}
      m_col:heading:="Сума"
      AADD(l_print,.t.);m_Col:colorblock:=  {||IF(m_color,{1,2},{4,5})}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      AADD(a_get2,GetNew())
      a_get2[LEN(a_get2)]:Block:=COLBR(fp2->stm)
      a_get2[LEN(a_get2)]:picture="999'999'999.99"
      a_get2[LEN(a_get2)]:ColorSpec:="w/B*,Gr+/N"
      AADD(a_get3,GetNew())
      a_get3[LEN(a_get3)]:row:=13;a_get3[LEN(a_get3)]:col:=52
      a_get3[LEN(a_get3)]:Block:=COLBR(fp2->stm)
      a_get3[LEN(a_get3)]:ColorSpec:="w/B*,Gr+/N"
      m_col:Cargo:=LEN(a_get2)
  m_br1:addColumn(m_col)

// Связка с a_get  с  a_const

j:=1
FOR i:=8 TO 25 STEP 2
  a_get2[j]:cargo:=a_get3[j]:cargo:=i
  j++
NEXT
FOR i:=26 TO 29
  a_get2[j]:cargo:=a_get3[j]:cargo:=i
  j++
NEXT
RETURN .t.
STATIC Function Crget1(a_get1)
LOCAL i
  tbget->(DS("PROV1"));i:=1
  DO WHILE .NOT.tbget->(EOF()).AND.ALLTRIM(tbget->p01)=="PROV1"
    AADD(a_get1,GETNEW())
    a_get1[i]:row:=tbget->row;a_get1[i]:col:=tbget->col
    IF .NOT.EMPTY(tbget->pict)
      a_get1[i]:picture:="@K "+ALLTRIM(tbget->pict)
    ELSE
      a_get1[i]:picture := "@K"
    ENDIF
    a_get1[i]:cargo:=fp1->(FIELDNUM(ALLTRIM(tbget->name)))
    a_get1[i]:ColorSpec:="w/B*,Gr+/N"
    tbget->(DBSKIP())
    i++
  ENDDO
RETURN .t.
Function Color1()
  IF m_color
    RETURN {3,3}
  ENDIF
RETURN {6,6}
Function Color2()
  IF m_color
    RETURN {2,2}
  ENDIF
RETURN {5,5}
STATIC Function Check01(m_npch,m_ndoc)
LOCAL m_recno:=Fp1->(RECNO()),m_ret:=.t.
fp1->(DBSETORDER(2))
IF Fp1->(DS(m_npch+m_ndoc))
  DO WHILE .NOT.fp1->(EOF()).AND.fp1->npch==m_npch.AND.fp1->ndoc==m_ndoc
    IF fp1->(RECNO())<>m_recno
      IF DispError("Попередження !!!;Документ N "+m_ndoc+" пачка N "+m_npch+";вже iснує") ==K_ESC
        m_ret:= .f.
        EXIT
      ENDIF
    ENDIF
      Fp1->(DBSKIP())
    ENDDO
ENDIF
fp1->(DBSETORDER(1))
Fp1->(DBGOTO(m_recno))
RETURN m_ret

STATIC Function SetName90(a_const)
  sp44->(DS(a_const[08,2]))
  a_const[09,2]:=a_const[08,6]:=Sp44->naim7
  a_const[11,2]:=a_const[10,6]:=AnCodName(a_const[08,2],a_const[10,2])
  a_const[13,2]:=a_const[12,6]:=_mol(a_const[12,2])
  sp01->(DS(a_const[14,2]))
  a_const[15,2]:=a_const[14,6]:=Sp01->naim1
  sp44->(DS(a_const[16,2]))
  a_const[17,2]:=a_const[16,6]:=Sp44->naim7
  a_const[19,2]:=a_const[18,6]:=AnCodName(a_const[16,2],a_const[18,2])
  a_const[21,2]:=a_const[20,6]:=_mol(a_const[20,2])
  sp01->(DS(a_const[22,2]))
  a_const[23,2]:=a_const[22,6]:=Sp01->naim1
  sp05->(DS(a_const[24,2]))
  a_const[25,2]:=a_const[24,6]:=Sp05->naim5a
RETURN a_const

STATIC Function EditMt90(a_const)
  Local n_row:=1,m_br,m_col,GetList:={},i
  LOCAL a_get:={},m_state:="1",m_key,n:=len(a_const)
  SavePar()
    ASIZE(a_get,LEN(a_const)-1)
    FOR i:=1 TO LEN(a_const)-1
      a_get[i]:=GetNew()
      a_get[i]:block:=COLBR(a_const[n_row,2])
      a_get[i]:picture:=a_const[i,5]
      a_get[i]:colorSpec:="GR+/n,GR+/n"
      IF ALLTRIM(a_const[i,5])=="MM.MM"  // анализ поля месяца
        a_get[i]:block:={|x|IF(x==NIL,RIGHT(a_const[n_row,2],2)+"."+LEFT(a_const[n_row,2],2),a_const[n_row,2]:=RIGHT(x,2)+LEFT(x,2))}
        a_get[i]:picture:="99.99"
        a_get[i]:Postblock:={||IF(EMPTY(a_const[n_row,2]).OR.(Left(a_const[n_row,2],2)>="00".AND.LEFT(a_const[n_row,2],2)<="99".AND.;
                         RIGHT(a_const[n_row,2],2)>="01".AND.RIGHT(a_const[n_row,2],2)<="12"),.t.,.f.)}
      ENDIF

    NEXT

    // ПРИСВОИТЬ valid  в соотв. с a_get допустить ввод пустой строки

//  ЭТОТ БЛОК УНИКАЛЕН ДЛЯ КАЖДОГО ВИДА ДОКУМЕНТОВ

//  a_get[4]:picture:="99.99"
//  a_get[4]:Block:={|x|IF(x==NIL,mnt_data(a_const[4,2]),a_const[4,2]:=Mnt_field(x))}
  a_get[08]:PostBlock:={|p|Sp44->(Sp_vl("SP44","2"))}
  a_get[10]:Block:={|x|IF(x==NIL,AnalCod(x,a_const[08,2],a_const[10,2]),a_const[10,2]:=PADR(x,10))}
  a_get[10]:PostBlock:={|p|AnCodValid(a_const[08,2],a_const[10,2])}
  a_get[12]:PostBlock:={|p|Sp02->(Sp_vl("SP02","2"))}
  a_get[14]:PostBlock:={|p|Sp01->(Sp_vl("SP01","2"))}
  a_get[16]:PostBlock:={|p|Sp44->(Sp_vl("SP44","2"))}
  a_get[18]:Block:={|x|IF(x==NIL,AnalCod(x,a_const[16,2],a_const[18,2]),a_const[18,2]:=PADR(x,10))}
  a_get[18]:PostBlock:={|p|AnCodValid(a_const[16,2],a_const[18,2])}
  a_get[20]:PostBlock:={|p|Sp02->(Sp_vl("SP02","2"))}
  a_get[22]:PostBlock:={|p|Sp01->(Sp_vl("SP01","2"))}
  a_get[24]:PostBlock:={|p|Sp05->(Sp_vl("SP05","2"))}
  a_get[7]:PreBlock:={||.f.}
  /*
  FOR i:=09 TO 25 STEP 2  // Расшифровки не вводить
    a_get[i]:PreBlock:={||.f.}
  NEXT
  */
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " '" COLOR 'W/B'
  @0,0 SayDisp PADC("НАСТРОЙКА МАКЕТУ ВВОДУ",MAXCOL()-1) COLOR "N/W"
  @1,5 SayText "~1Документ:~2Бух. справка     ~1  Макет ввода № ~2"
  @1,46 SayDisp  a_const[LEN(a_const)][1] COLOR "Gr+/b"
  @1,49 SayDisp  a_const[len(a_const)][2] COLOR "Gr+/b"
  // Создание BROWSE
  m_br:=TBROWSENEW(2,1,MAXROW()-1,MAXCOL()-1)
  m_br:ColorSpec:="W/b,b/w,w+/b,Gr+/b"
  m_br:SkipBlock:={|x|MySkip(x,@n_row,n-1)}
  m_br:GoTopBlock:={||n_row:=1};m_br:GoBottomBlock:={||n_row:=n-1}
  m_br:ColSep:='│'
  m_col:=TBColumnNew()
  m_col:block:={||a_const[n_row,1]}
  m_col:heading:="Поле вводу /стовбець"
  m_col:colorBlock:={||IF(a_const[n_row,4]=="Н",{1,2},{3,2})}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
//  m_col:block:={||PADR(LEFT(TRANSFORM(a_const[n_row,2],a_const[n_row,5])+" "+a_const[n_row,6],30),30)}
  m_col:block:={||PADR(LEFT(MyFunc1(a_const[n_row,2],a_const[n_row,5])+" "+a_const[n_row,6],30),30)}
  m_col:heading:="Значення/назва"
  m_col:colorBlock:={||{1,2}}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
  m_col:block:={||IF(a_const[n_row,3]=="Д","Так",IF(a_const[n_row,3]=="Н","Нi ","   "))}
  m_col:heading:="Пiдтв.;ввода"
  m_col:colorBlock:={||IF(a_const[n_row,3]=="Н",{1,2},{4,2})}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
  m_col:block:={||IF(a_const[n_row,4]=="Д","Так",IF(a_const[n_row,4]=="Н","Нi ","   "))}
  m_col:heading:="Вiдобр.;на экранi"
  m_col:colorBlock:={||IF(a_const[n_row,4]=="Н",{1,2},{4,2})}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_br:ColPos:=2
  m_br:freeze:=1
  SET ESCAPE ON
  DO WHILE .T.
    DO CASE
      CASE m_state=="0"
        @1,46 Get a_const[LEN(a_const),1] COLOR "GR+/B,GR+/N"
        @1,49 Get a_const[LEN(a_const),2] COLOR "GR+/B,GR+/N"
        READ
        m_state:="1";m_br:AutoLite:=.t.
      CASE m_state=="1"
        // Display Browse m_br
        STABILIZE BROWSE m_br
        m_key:=INKEY(0)
        DO CASE
          CASE m_key==K_TAB
            m_br:AutoLite:=.f.
            m_br:Dehilite()
            m_state:="0"
        CASE m_key==K_ESC.AND.ANSWER("Завершити настройку макета ?")==YES
            SavePar(1)
            RETURN a_const
        CASE m_key==K_F12
            SavePar(1)
            RETURN a_const
          CASE m_key==K_F12.OR.m_key==K_CTRL_END.AND.ANSWER("Сохранить макет ввода?")==YES
            IF a_const[LEN(a_const),3]<>"SYSTEM"
              IF .NOT.maket->(DS(MAKET_NUM+a_const[n][1]+"00"))
                maket->(DBAP())
                maket->num:=a_const[LEN(a_const),1]
                maket->kod:=MAKET_NUM;maket->value:=a_const[n][1]
                maket->name:=a_const[n,2];maket->num:=a_const[n][1]
                maket->punkt:="00"
                FOR i:=1 TO n-1
                  maket->(DBAP())
                  maket->kod:=MAKET_NUM;maket->num:=a_const[n][1]
                  maket->punkt:=STRZERO(i,2)
                  maket->name:=a_const[i,1]
                  maket->ent:=a_const[i,3]
                  maket->view:=a_const[i,4]
                  maket->pict:=a_const[i,5]
                  DO CASE
                    CASE ALLTRIM(a_const[i,5])=="MM.MM"
                      maket->type:="M";maket->value:=a_const[i,2]
                    CASE VALTYPE(a_const[i,2])=="C"
                      maket->type:="C";maket->value:=a_const[i,2]
                    CASE VALTYPE(a_const[i,2])=="N"
                      maket->type:="N";maket->value:=TRANSFORM(a_const[i,2],a_const[i,5])
                    CASE VALTYPE(a_const[i,2])=="D"
                      maket->type:="D";maket->value:=DTOC(a_const[i,2])
                  ENDCASE
                NEXT
                ELSE
                IF Maket->(Flock())
                  maket->num:=a_const[LEN(a_const),1]
                  maket->kod:=MAKET_NUM;maket->value:=a_const[n][1]
                  maket->name:=a_const[n,2];maket->num:=a_const[n][1]
                  maket->punkt:="00"
                  FOR i:=1 TO n-1
                    IF maket->(DBSEEK(MAKET_NUM+a_const[n][1]+STRZERO(i,2),.F.))
                    maket->kod:=MAKET_NUM;maket->num:=a_const[n][1]
                    maket->punkt:=STRZERO(i,2)
                    maket->name:=a_const[i,1]
                    maket->ent:=a_const[i,3]
                    maket->view:=a_const[i,4]
                    maket->pict:=a_const[i,5]
                    DO CASE
                      CASE ALLTRIM(a_const[i,5])=="MM.MM"
                        maket->type:="M";maket->value:=a_const[i,2]
                      CASE VALTYPE(a_const[i,2])=="C"
                        maket->type:="C";maket->value:=a_const[i,2]
                      CASE VALTYPE(a_const[i,2])=="N"
                        maket->type:="N";maket->value:=TRANSFORM(a_const[i,2],a_const[i,5])
                      CASE VALTYPE(a_const[i,2])=="D"
                        maket->type:="D";maket->value:=DTOC(a_const[i,2])
                    ENDCASE
                  ELSE
                    DispError("Службова помилка ;"+MAKET_NUM+a_const[n][1]+STRZERO(i,2))
                  ENDIF
                  NEXT
                  maket->(dbUnlock())
                ENDIF
                ENDIF
              ENDIF
          CASE m_key==K_LEFT
            IF m_br:ColPos>=3
              m_br:LEFT()
            ENDIF
          CASE m_key==K_RIGHT
            IF m_br:ColPOs==2.OR.(m_br:ColPos==3.AND.a_const[n_row,4]<>" ")
              m_br:Right()
            ENDIF
          CASE m_key==K_UP;m_br:Up()
          CASE m_key==K_DOWN;m_br:down()
         CASE m_key == K_PGDN     ; m_br:pagedown()
         CASE m_key == K_PGUP     ; m_br:pageup()
         CASE m_key == K_CTRL_PGUP; m_br:gotop()
         CASE m_key == K_CTRL_PGDN; m_br:gobottom()
         CASE m_key==K_ENTER
            STABILIZE BROWSE m_br
            DO CASE
              CASE m_br:ColPos==2.AND.a_const[n_row,3]<>"Р" // не расшифровка
                a_get[n_row]:row:=ROW();a_get[n_row]:col:=COL()
                READMODAL({a_get[n_row]})
                // Отработать расшифровки
                   SetName90(@a_const)
                   m_br:RefreshAll()
              CASE m_br:ColPos==3.OR.m_br:ColPos== 4
                IF a_const[n_row,m_br:ColPos]=="Д"
                  a_const[n_row,m_br:ColPos]:="Н"
                ELSE
                  IF a_const[n_row,m_br:ColPos]=="Н"
                    a_const[n_row,m_br:ColPos]:="Д"
                  ENDIF
                ENDIF
            ENDCASE
          ENDCASE
          m_br:RefreshCurrent()
      ENDCASE
  ENDDO
SavePar(1)
RETURN a_const
Function AnCodName(m_ksash,m_kod)
  LOCAL m_str:=SPACE(30)
  Sp44->(DS(m_ksash))
  DO CASE
    CASE Sp44->type1 == " "
      RETURN m_str
    CASE Sp44->type1 == "1"
      Kaptka1->(DS(m_kod))
      RETURN(LEFT(kaptka1->name,30))
    CASE Sp44->type1 == "2"
      RETURN(PADR(LEFT(_fio(LEFT(m_kod,4)),30),30))
    CASE Sp44->type1 == "3"
      Firm01->(DBSETORDER(2))
      Firm01->(DS(m_kod))
      Firm01->(DBSETORDER(1))
      RETURN(LEFT(firm01->short,30))
    CASE Sp44->type1 == "4".OR.Sp44->type1 == "5"
      Sp08->(DS(LEFT(m_kod,3)))
      RETURN PADR(Sp08->Name8,30)
    CASE Sp44->type1 == "6"
      Inv_a->(DS(LEFT(m_kod,5)))
      Sp13a->(DS(inv_a->kavt))
      RETURN PADR(sp13a->naim13a,30)
    CASE Sp44->type1 == "7"
      Inv_t->(DS(LEFT(m_kod,5)))
      Sp13b->(DS(inv_t->kmtr))
      RETURN PADR(sp13b->naim13b,30)
    CASE Sp44->type1 == "8"
     Inv_mo->(DS(LEFT(m_kod,5)))
     RETURN PADR(inv_mo->naim,30)
    CASE Sp44->type1 == "9"
      Sp17->(DS(m_kod))
      RETURN PADR(LEFT(ALLTRIM(sp17->fam)+" "+ALLTRIM(sp17->imja)+"."+ALLTRIM(sp17->otch)+".",30),30)
ENDCASE
RETURN m_str
Function PreAnCod(m_ksash)
Sp44->(DS(m_ksash))
IF Sp44->type1 == " "
  RETURN .f.
ENDIF
RETURN .t.


Function AnCodValid(m_ksash,m_kod,xrow,xcol,xcolor,xlen)
  LOCAL i
Sp44->(DS(m_ksash))
  DO CASE
    CASE Sp44->type1 == " "
      RETURN .t.
    CASE Sp44->type1 == "1"
      i:=Kaptka1->(Kaptka_vl())
    CASE Sp44->type1 == "2"
      i:=Sp10->(Sp_vl("SP10"))
    CASE Sp44->type1 == "3"
      i:=firm01->(Firm01_vl())
    CASE Sp44->type1 == "4".OR.Sp44->type1 == "5"
      i:=(Sp08->(Sp_vl("SP08")))
    CASE Sp44->type1 == "6"
      i:=(inv_a->(Sp_vl("INV_A")))
    CASE Sp44->type1 == "7"
      i:=(inv_t->(Sp_vl("INV_T")))
    CASE Sp44->type1 == "8"
      i:=(inv_mo->(Sp_vl("INV_MO")))
    CASE Sp44->type1 == "9"
      i:=(sp17->(sp_vl("SP17")))
ENDCASE
IF xrow<>NIL.AND.xCol<>NIL
  @xrow,xcol SayDisp LEFT(AnCodName(m_ksash,m_kod),IF(xlen==NIL,30,xlen));
   COLOR (IF(xcolor==NIL,"GR+/B",xcolor))
ENDIF
RETURN i
Function AnalCod(x,m_ksash,m_cod)
Sp44->(DS(m_ksash))
    DO CASE
      CASE Sp44->type1 == "1"
        RETURN (m_cod)
      CASE Sp44->type1 == "2"
        RETURN(LEFT(m_cod,4))
      CASE Sp44->type1 == "3"
        RETURN (m_cod)
      CASE Sp44->type1 == "4".OR.Sp44->type1 == "5"
        RETURN(LEFT(m_cod,3))
      CASE Sp44->type1 == "6"
        RETURN(LEFT(m_cod,5))
      CASE Sp44->type1 == "7"
        RETURN(LEFT(m_cod,5))
      CASE Sp44->type1 == "8"
        RETURN(LEFT(m_cod,5))
      CASE Sp44->type1 == "9"
        RETURN (m_cod)
  ENDCASE
RETURN (m_cod)
STATIC Function Say3
 sp44->(DS(fp2->dbt))
 @7,15 SayDisp Sp44->naim7 COLOR "Gr+/b"
 @8,15 SayDisp LEFT(AnCodName(fp2->dbt,fp2->cod1),24) COLOR "Gr+/b"
 Sp02->(DS(fp2->kplh))
 @9,11 SayDisp LEFT(_fio(Sp02->tabn),28) COLOR "Gr+/b"
 Sp01->(DS(fp2->brgd1))
 @10,11 Saydisp Sp01->naim1 COLOR "Gr+/b"
 sp44->(DS(fp2->crt))
 @7,52 SayDisp Sp44->naim7 COLOR "Gr+/b"
 @8,54 SayDisp LEFT(AnCodName(fp2->crt,fp2->cod2),24) COLOR "Gr+/b"
 Sp02->(DS(fp2->otp))
 @9,50 SayDisp LEFT(_fio(Sp02->tabn),28) COLOR "Gr+/b"
 Sp01->(DS(fp2->brgd2))
 @10,50 Saydisp Sp01->naim1 COLOR "Gr+/b"
 Sp05->(DS(fp2->kopr))
 @11,50 SayDisp Sp05->naim5a COLOR "Gr+/b"
 @8,05 SayDisp SPACE(10) COLOR "w/b"
 @8,44 SayDisp SPACE(10) COLOR "w/b"
Return .t.
STATIC function MyFunc1(var,pict)
  IF pict=="MM.MM" // Поле Mnt
    RETURN mnt_data(var)
  ENDIF

RETURN TRANSFORM(var,pict)


STATIC FUNCTION Crbr2(m_br1,m_browse,a_const,s_const2)
LOCAL i,n:=m_browse:ColCount
s_const2:=""
FOR i:=n TO 1 Step -1
  m_browse:DelColumn(i)
NEXT
n:=m_br1:ColCount
IF .NOT.EMPTY(a_const)
FOR i:=1 TO n
  IF a_const[i+FIRST_TABL-1,4]<>"Н"
    m_browse:AddColumn(m_br1:GetColumn(i))
    s_const2+=CHR(i+FIRST_TABL-1)
  ENDIF
NEXT
ELSE
FOR i:=1 TO n
    m_browse:AddColumn(m_br1:GetColumn(i))
    s_const2+=CHR(i+FIRST_TABL-1)
NEXT
ENDIF
m_browse:Configure()
RETURN .t.

STATIC Function Readget1(m_get,l_first,l_update,a_func,x_const)
LOCAL  m_block:=m_get:block
LOCAL  m_buf:=EVAL(m_block),m_valid1:=m_get:postBlock
IF x_const<>NIL .AND..NOT.EMPTY(x_const)
  m_buf:=x_const
ENDIF


m_get:postBlock:={|x|IF(x==NIL.OR.(EMPTY(EVAL(x:block)).AND..NOT.l_first),.t.,EVAL(m_valid1,x))}
m_get:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
l_update:=ReadMy({m_get},a_func)
m_get:block:=m_block;m_get:postBlock:=m_valid1
RETURN m_buf

STATIC Function FillConst(m_br,a_const,a_get,m_buf,m_vnum1)
LOCAL n:=m_br:ColCOunt,i
// Заполнение константами
FOR i:=1 TO n
  IF m_br:GetColumn(i):cargo<>NIL
    EVAL(a_get[m_br:GetColumn(i):cargo]:block,a_const[i+FIRST_TABL-1,2])
  ENDIF
NEXT
fp2->vnum:=m_vnum1
EVAL(a_get[1]:block,m_buf)  // Восстановление значения первого столбца
RETURN .t.

STATIC Function InputStr(m_br2,a_const,a_get2,l_first)
LOCAL j
m_br2:right();m_br2:refreshCurrent()
DO WHILE .T.
  m_br2:refreshCurrent()
  IF m_br2:GetColumn(m_br2:ColPos):cargo<>NIL
    j:=m_br2:GetColumn(m_br2:ColPos):cargo
    IF a_const[a_get2[j]:cargo,3]<>"Н"
      IF a_get2[j]:PreBlock==NIL.OR.EVAL(a_get2[j]:PreBlock)
        STABILIZE BROWSE m_br2
        a_get2[j]:Row:=ROW();a_get2[j]:col:=COL()
        ReadMy({a_get2[j]})
      ENDIF
      IF LASTKEY() == K_LEFT
        DO WHILE m_br2:ColPos>1
          m_br2:left();j:=m_br2:GetColumn(m_br2:ColPos):cargo
          IF a_const[a_get2[j]:cargo,3]<>"Н".AND.(a_get2[j]:PreBlock==NIL.OR.EVAL(a_get2[j]:PreBlock))
            EXIT
          ENDIF
        ENDDO
        LOOP
      ENDIF
      IF LASTKEY()==K_UP
        m_br2:up();lApnd:=.f.
        EXIT
      ENDIF
    ENDIF
  ENDIF
  IF m_br2:Colpos==m_br2:ColCount
    EXIT
  ENDIF
  m_br2:right()
ENDDO

// Создание массива для копирования
CopyZap("0")


IF lApnd
  m_br2:refreshCurrent()
  m_br2:panHome();m_br2:down();l_first:=.f.
ENDIF
RETURN .t.
STATIC Function ReadFp2(m_browse,a_get2,a_get3,a_const,m_br1,m_vnum1,a_func)
LOCAL l_first:=.t.,l_update,m_buf,l1:=.f.
    fp2->(DBSETORDER(0))
    m_browse:GoBottom();m_browse:panHome()
    STABILIZE BROWSE m_browse;lApnd:=.t.
    m_browse:down()
    STABILIZE BROWSE m_browse
    DO WHILE lApnd
      Say3()
      AEVAL(a_get3,{|x|x:display()})
      STABILIZE BROWSE m_browse
      SET ESCAPE ON
      a_get2[1]:row:=ROW();a_get2[1]:Col:=COL()
//      lCopy:=.f.
// a_const[FIRST_TABL,2]
      m_buf:=ReadGet1(a_get2[1],l_first,@l_update,@a_func,a_const[FIRST_TABL,2])
      DO CASE
        CASE LASTKEY()==K_UP.OR.LASTKEY()==K_ESC.OR.( EMPTY(m_buf).AND..NOT.l_update.AND..NOT.LASTKEY()==K_PGDN )
          lApnd:=.f.;m_browse:goBottom()
          EXIT
        OTHERWISE
        IF  fp2->(NetDBAP())
         IF LASTKEY()==K_PGDN.AND.CopyZap("1")

         ELSE
          // Заполнение константами
            FillConst(@m_br1,@a_const,a_get2,m_buf,m_vnum1)
         ENDIF
          // Ввод строки
            InputStr(@m_browse,@a_const,@a_get2,@l_first)
            Fp2->(DbUnlock())
            l_first:=.f.
            l1:=.t.
        ENDIF
        ENDCASE
      ENDDO
      fp2->(DBSETORDER(1))
      m_browse:RefreshAll()
RETURN .NOT.l_first


STATIC Function PrintProv()
LOCAL m_str ,a_str:={},i,j:=0,s1:="",k,l,a_sum:={0,0,0,0,0},m_file,s_val,n_line_all:=1
LOCAL l_print:={},m_recno:=Fp2->(RECNO()),m_mode,m_npch:=PADR(ALLTRIM(fp1->npch),40),m_vnum
LOCAL GetList:={},n,m_screen,n_pos:={},l_first:=.t.,m_gauge,n_line:=0,l_1:="0"
// [1]- блок, [2] - тип ,  [3] - шаблон ,
// [4] - ширина , [5] - название , [6] - признак печати
LOCAL a_tabl:={;
{{||fp1->npch},"01",NIL,NIL,"Номер пачки",.t.},;                            //01
{{||fp1->ndoc},"01",NIL,NIL,"Номер документа",.t.},;                        //02
{{||fp1->ddoc},"01",NIL,NIL,"Дата документа",.f.},;                         //03
{{||fp1->tabn},"01",NIL,NIL,"Табельний номер",.f.},;                        //04
{{||fp1->num},"01",NIL,NIL,"Номер",.f.},;                                   //05
{{||fp1->(mnt_data(fp1->mnt))},"01",NIL,NIL,"Розрахунковий перiод",.f.},;   //06
{{||fp1->ndoc1},"01",NIL,NIL,"Номер додаткового документа",.f.},;           //07
{{||fp1->prim},"01",NIL,NIL,"Примiтка",.f.},;                               //08
{{||fp1->ndog},"01",NIL,NIL,"Номер договiру",.f.},;                         //09
{{||fp2->dbt},"01",NIL,NIL,"Дебет",.t.},;                                   //10
{{||Sp44->(DBSEEK(fp2->dbt)),Sp44->naim7},"01",NIL,NIL,"Назва",.f.},;       //11
{{||fp2->fp2->cod1},"01",NIL,NIL,"    Код",.t.},;                           //12
{{||AnCodName(fp2->dbt,fp2->cod1)},"01",NIL,NIL,"Назва",.f.},;              //13
{{||fp2->fp2->kplh},"01",NIL,NIL,"    Одержувач",.t.},;                     //14
{{||_mol(fp2->kplh)},"01",NIL,NIL,"    Ф.I.Б. ",.f.},;                      //15
{{||fp2->fp2->brgd1},"01",NIL,NIL,"    Бригада 1",.t.},;                    //16
{{||Sp01->(DBSEEK(fp2->brgd1)),Sp01->naim1},"01",NIL,NIL,"Назва",.f.},;     //17
{{||fp2->fp2->crt},"01",NIL,NIL,"Кредiт",.t.},;                             //18
{{||Sp44->(DBSEEK(fp2->crt)),Sp44->naim7},"01",NIL,NIL,"Назва",.f.},;       //19
{{||fp2->fp2->cod2},"01",NIL,NIL,"    Код",.t.},;                           //20
{{||AnCodName(fp2->crt,fp2->cod2)},"01",NIL,NIL,"Назва",.f.},;              //21
{{||fp2->fp2->otp},"01",NIL,NIL,"    Вiдправник",.t.},;                     //22
{{||_mol(fp2->otp)},"01",NIL,NIL,"    Ф.I.Б. ",.f.},;                       //23
{{||fp2->fp2->brgd2},"01",NIL,NIL,"    Бригада 2",.f.},;                    //24
{{||Sp01->(DBSEEK(fp2->brgd2)),Sp01->naim1},"01",NIL,NIL,"Назва",.f.},;     //25
{{||fp2->kopr},"01",NIL,NIL,"    Код операцiї",.t.},;                       //26
{{||Sp05->(DBSEEK(fp2->kopr)),Sp05->naim5a},"01",NIL,NIL,"Назва",.f.},;     //27
{{||fp2->glv},"04",NIL,2,"    Голiв",.t.},;                                 //28
{{||fp2->kvo2},"04",NIL,2,"    Кiлькiсть",.t.},;                            //29
{{||fp2->kvo},"04",NIL,2,"    Кiлькiсть 2",.t.},;                           //30
{{||fp2->stm},"03",NIL,NIL,"    Сума",.t.}}                                 //31
m_screen:=SaveScreen(((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+5,75)
SET ESCAPE ON
@INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+5,75 BOX B_DOUBLE+" " COLOR ("w+/bg")
@INT((MAXROW()-4)/2)+2,6 SayDisp PADC( 'Введiть номера друкуємих папок',68) COLOR "GR+/bg"
@INT((MAXROW()-4)/2)+3,6 SayDisp PADC( 'Кiлькiсть друкуємих строк     ',68) COLOR "GR+/bg"
@INT((MAXROW()-4)/2)+4,6 SayDisp PADC( 'З першої /поточної            ',68) COLOR "GR+/bg"
@INT((MAXROW()-4)/2)+2,40 GET m_npch COLOR "w/b,Gr+/n" PICTURE "@KS15"
@INT((MAXROW()-4)/2)+3,50 GET n_line COLOR "w/b,Gr+/n" PICTURE "999"
@INT((MAXROW()-4)/2)+4,50 GET l_1  COLOR "w/b,Gr+/n" PICTURE "9"
READ
RestScreen(((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+5,75,m_screen)
IF LASTKEY()==K_ESC
   RETURN .f.
ENDIF
m_npch:=ALLTRIM(m_npch)
n:=NumToken(m_npch)
FOR i:=1 TO n
  s1+=PADL(TOKEN(m_npch,,i),LEN(Fp1->npch))+","
NEXT
m_npch:=s1

// Поиск первой подходящей записи
  IF l_1=="0"
    Fp2->(DBGOTOP())
  ELSE
    Fp2->(DBgoto(m_recno))
  ENDIF

DO WHILE .NOT.fp2->(EOF())
    Fp1->(DS(Fp2->vnum))
    IF EMPTY(m_npch).OR.(AT(fp1->npch,m_npch)<>0)
      EXIT
    ENDIF
    Fp2->(DBSKIP())
ENDDO
IF Fp2->(EOF())
  DispError("Документiв "+IF(EMPTY(m_npch),"","у пачцi "+m_npch+";")+"не знайдено")
  Fp2->(DBGOTO(m_recno))
  RETURN .f.
ENDIF
// m_recno1:=Fp2->(RECNO())
m_mode:=ALERT("Як друкувати реєстр проводок?",{"Стандартно","Вибрати стовбцi","Залежно вiд даних ","Вiдмова "},"n/bg,b/w")
IF m_mode==0.OR.m_mode==4
  RETURN .f.
ENDIF
SavePar()
DO WHILE .t.
  i:=ATNUM(END_LINE,m_str,1,j)
  IF i==0
    EXIT
  ENDIF
  AADD(a_str,SUBSTR(m_str,j+1,i-j-1))
  j:=i+1
ENDDO

Screen->(DS("PROVP"))
m_str:=Screen->vd
DO WHILE .t.
  i:=ATNUM(END_LINE,m_str,1,j)
  IF i==0
    EXIT
  ENDIF
  AADD(a_str,SUBSTR(m_str,j+1,i-j-1))
  j:=i+1
ENDDO

m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
SETPRC(0,0)
SET PRINTER TO (m_file)
SET DEVICE TO PRINTER
n_pos:=SetColPr(@a_str,@a_tabl,m_mode,m_npch,l_1)
IF SetWidthPrn(LEN(a_str[1]))
  m_gauge:=InitGauge("Вивiд у файл")
  i:=1;a_sum:={0,0,0,0,0}
  DO WHILE .NOT.Fp2->(EOF())
    Fp1->(DS(Fp2->vnum))
    IF EMPTY(m_npch).OR.(AT(fp1->npch,m_npch)<>0)
      SkipLinePrn(a_str," Реєстр проводок Пачки N"+m_npch)
      n_line_all++
      a_sum[1]+=1;k:=1;l_first:=.t.
      FOR j:=1 TO 9
        IF a_tabl[j,6]
          s_val:=""
          DO CASE
            CASE a_tabl[j,2]=="01"
              s_val:=LEFT(TRANSFORM(EVAL(a_tabl[j,1]),a_tabl[j,3]),n_pos[k+1]-n_pos[k]-1)
            CASE a_tabl[j,2]=="03"
              s_val:=SumToStr(EVAL(a_tabl[j,1]),n_pos[k+1]-n_pos[k]-1)
            CASE a_tabl[j,2]=="04"
              s_val:=NumToStr(EVAL(a_tabl[j,1]),n_pos[k+1]-n_pos[k]-1,a_tabl[j,4])
          ENDCASE
          @PROW(),n_pos[k++] Say s_val
        ENDIF
      NEXT

      l:=k;m_vnum:=fp1->vnum
      DO WHILE .NOT.Fp2->(EOF()).AND.m_vnum==Fp2->vnum
        k:=l
        IF .NOT.l_first
            SkipLinePrn(a_str," Реєстр проводок Пачки N"+m_npch)
            n_line_all++
        ENDIF
        FOR j:=10 TO 31
          IF a_tabl[j,6]
            s_val:=""
            DO CASE
              CASE a_tabl[j,2]=="01"
                s_val:=LEFT(TRANSFORM(EVAL(a_tabl[j,1]),a_tabl[j,3]),n_pos[k+1]-n_pos[k]-1)
              CASE a_tabl[j,2]=="03"
                s_val:=SumToStr(EVAL(a_tabl[j,1]),n_pos[k+1]-n_pos[k]-1)
              CASE a_tabl[j,2]=="04"
                s_val:=NumToStr(EVAL(a_tabl[j,1]),n_pos[k+1]-n_pos[k]-1,a_tabl[j,4])
            ENDCASE
            @PROW(),n_pos[k++] Say s_val
          ENDIF
        NEXT
        a_sum[2]+=Fp2->glv
        a_sum[3]+=Fp2->kvo2
        a_sum[4]+=Fp2->kvo
        a_sum[5]+=Fp2->stm
        l_first:=.f.
        Fp2->(DBSKIP())
        m_gauge:=DispGauge(m_gauge,i++/Fp2->(LASTREC()))
        IF n_line>0
          IF n_line_all>n_line
            EXIT
          ENDIF
        ENDIF
      ENDDO
    ELSE
     fp2->(DBSKIP())
    ENDIF
    IF n_line>0
      IF n_line_all>n_line
        EXIT
      ENDIF
    ENDIF
  ENDDO
  @PROW()+2,0 Say ""
  FOR i:=1 TO 4
    @PROW(),PCOL()+2 Say ALLTRIM(NumToStr(a_sum[i]))
  NEXT
  @PROW(),PCOL()+2 Say ALLTRIM(SumToStr(a_sum[5]))
  DelGauge(m_gauge)
ELSE
  m_file:=""
ENDIF
/*
FOR i:=1 TO LEN(a_tabl)
  @PROW()+1,0       SAY i PICTURE "99999"
  @PROW(),PCOL()+2  SAY EVAL(a_tabl[i,1])
  @PROW(),PCOL()+2  SAY a_tabl[i,2]
  @PROW(),PCOL()+2  SAY a_tabl[i,5]
NEXT
*/
SET PRINTER TO
SET DEVICE TO SCREEN


MyPrintFile(m_file)

SavePar(1)
Fp2->(DBGOTO(m_recno))

RETURN .t.



STATIC Function SetColPr(a_str,a_tabl,m_mode,m_npch,l_1)
LOCAL m_br,i,m_str1,n,n_row:=1,m_col,m_key,l,j,m_recno,;
m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),m_gauge,n_pos:={}

  // Восстановление переменных

  sptabl->(DBGOTOP())
  sptabl->(dbseek("PROVP"))

// [1]- блок, [2] - тип ,  [3] - шаблон ,
// [4] - ширина , [5] - название , [6] - признак печати

n:=LEN(a_tabl)
FOR i:=1 TO LEN(a_tabl)
  IF Sptabl->(DBSEEK("PROVP"+STRZERO(i,2)))
    a_tabl[i,2]:=Sptabl->type
    a_tabl[i,3]:=ALLTRIM(Sptabl->pict)
    IF Sptabl->width<>0
      a_tabl[i,4]:=Sptabl->width
    ENDIF
    a_tabl[i,5]:=Sptabl->heading
    a_tabl[i,6]:=Sptabl->print
  ENDIF
  a_tabl[i,5]:=LEFT(PADR(a_tabl[i,5],20),20)
NEXT
DO CASE
  CASE m_mode==1 //Стандартний друк
    // По первой записи подходящего документа ????
    IF fp1->maket='02'.OR.fp1->maket='03' // Лiм. заб. карти
      a_tabl[4,6]:=a_tabl[5,6]:=.t.
    ENDIF

  CASE m_mode==2  // Вибрати стовбцi
    m_br:=TBROWSENEW(1,1,MAXROW(),MAXCOL()-1)
    m_br:ColorSpec:="n/bg,b/bg,b/w,r/bg,r/w"
    m_br:SkipBlock:={|x|MySkip(x,@n_row,n)}
    m_br:GoTopBlock:={||n_row:=1};m_br:GoBottomBlock:={||n_row:=n}
    m_br:ColSep:='│'
    m_col:=TBColumnNew()
    m_col:block:={||a_tabl[n_row,5]}
    m_col:heading:="  Назва стовбця  "
    m_col:colorBlock:={||IF(a_tabl[n_row,6],{2,3},{4,5})}
    m_Col:headsep    := "┬─"
    m_col:colsep:="│"
    m_col:footsep:="╧═"
    m_br:AddColumn(m_col)
    m_col:=TBColumnNew()
    m_col:block:={||IF(a_tabl[n_row,6],"Так","Нi ")}
    m_col:heading:=" Ознака; друку"
    m_col:colorBlock:={||IF(a_tabl[n_row,6],{2,3},{4,5})}
    m_Col:headsep    := "┬─"
    m_col:colsep:="│"
    m_col:footsep:="╧═"
    m_br:AddColumn(m_col)
    @0,0,MAXROW(),MAXCOL() BOX B_DOUBLE+ " " COLOR "n/bg"
    DO WHILE .T.
          STABILIZE BROWSE m_br
          m_key:=INKEY(0)
          DO CASE
            CASE m_key==K_ESC.OR.m_key==K_F12
              EXIT
            CASE m_key==K_UP;m_br:Up()
            CASE m_key==K_DOWN;m_br:down()
            CASE m_key == K_PGDN     ; m_br:pagedown()
            CASE m_key == K_PGUP     ; m_br:pageup()
            CASE m_key == K_CTRL_PGUP; m_br:gotop()
            CASE m_key == K_CTRL_PGDN; m_br:gobottom()
            CASE m_key==K_ENTER
              STABILIZE BROWSE m_br
                  a_tabl[n_row,6]:=.NOT.a_tabl[n_row,6]
            m_br:RefreshCurrent()
        ENDCASE
    ENDDO
CASE m_mode==3

      m_recno:=Fp2->(RECNO())
      m_gauge:=InitGauge("Визначення параметрiв")
      FOR i:=1 TO LEN(a_tabl)
        a_tabl[i,6]:=.f.
      NEXT
      a_tabl[1,6]:=a_tabl[2,6]:=a_tabl[31,6]:=.t. // Номер пачки, документа i сума
      i:=1
      DO WHILE .NOT.Fp2->(EOF())
        Fp1->(DS(Fp2->vnum))
        IF EMPTY(m_npch).OR.(AT(fp1->npch,m_npch)<>0)

          IF .NOT.EMPTY(fp1->ddoc); a_tabl[3,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp1->tabn); a_tabl[4,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp1->num);  a_tabl[5,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp1->ndoc1);a_tabl[7,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp1->prim); a_tabl[8,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp1->ndog); a_tabl[9,6]:=.t.;ENDIF

          IF .NOT.EMPTY(fp2->cod1) ;a_tabl[13,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp2->kplh) ;a_tabl[14,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp2->brgd1);a_tabl[16,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp2->cod2) ;a_tabl[20,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp2->otp ) ;a_tabl[22,6]:=.t.;ENDIF
          IF .NOT.EMPTY(fp2->brgd2);a_tabl[24,6]:=.t.;ENDIF

          IF .NOT.EMPTY(fp2->kopr);a_tabl[26,6]:=.t.;ENDIF

          IF fp2->glv<>0 ;a_tabl[28,6]:=.t.;ENDIF
          IF fp2->kvo2<>0;a_tabl[29,6]:=.t.;ENDIF
          IF fp2->kvo<>0 ;a_tabl[30,6]:=.t.;ENDIF
        ENDIF
        Fp2->(DBSKIP())
        m_gauge:=DispGauge(m_gauge,i++/Fp2->(LASTREC()))
      ENDDO
      DelGauge(m_gauge)
      Fp2->(DBGOTO(m_recno))
ENDCASE
// Преобразование a_str согласно s_print
n_pos:={1}
n:=LEN(a_tabl)-1
j:=2


FOR i:=1 TO n
  n_row:=ATNUM("┴",a_str[LEN(a_str)],1,j)
  IF .NOT.a_tabl[i,6]
    IF n_row==0
      DispError("Службова помилка при визначеннi координат стовбцiв")
      BREAK
    ENDIF
    FOR l:=1 TO LEN(a_str)
      a_str[l]:=STUFF(a_str[l],j,n_row-j+1,"")
    NEXT
  ELSE
    j:=n_row+1
    AADD(n_pos,n_row)
  ENDIF
NEXT
IF .NOT.a_tabl[n+1,6]
    n_row:=LEN(a_str[1])-1
    FOR l:=1 TO LEN(a_str)
      a_str[l]:=STUFF(a_str[l],j-1,n_row-j+1,"")
    NEXT
ENDIF

AADD(n_pos,LEN(a_str[1])) // Крайняя правая граница

IF GetParPrn(N_SYMBOL)==2
  FOR i:=1 TO LEN(a_str)
    a_str[i]:=CHARREPL("┌│├└┼┴┬─┘┤┐",a_str[i],"-||-|----||")
  NEXT
ENDIF


RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
RETURN n_pos

Function Reindex(Var)
  LOCAL  m_path:=IF(a_menu[1]=="MAIN",m_mainpath,m_bufpath)
  LOCAL m_gauge,m_message
  IF .NOT.EMPTY(var)
    m_path:=Var
  ENDIF
  m_message:=DispMessage("Iндексацiя "+IF(m_path==m_mainpath,"основної",;
  IF(m_path==m_bufpath,"буферної",""))+";бази даних ")
  m_gauge:=InitGauge("Iндексацiя",2)
  NET USE (m_path+"Fp1") NEW
  IF Fp1->(NETFlock())
    DispGauge(m_gauge,0.05)
    INDEX ON Fp1->Npch+Fp1->ndoc TO  (m_path+"Fp1a")
    INDEX ON Fp1->vnum TO  (m_path+"Fp1")
    DispGauge(m_gauge,0.1)
    NET USE (m_path+"Fp2")  NEW
      IF Fp2->(NETFlock())
        SET RELATION TO Fp2->vnum INTO Fp1
        INDEX ON Fp2->vnum TO (m_path+"Fp2")
        DispGauge(m_gauge,0.25)
        INDEX ON Fp1->npch+Fp1->ndoc+Fp2->vnum TO (m_path+"Fp2a")
        DispGauge(m_gauge,0.5)
        INDEX ON Fp2->dbt+Fp2->cod1+Fp2->crt+Fp2->cod2 TO (m_path+"Fp2b")
        DispGauge(m_gauge,0.75)
        INDEX ON Fp2->crt+Fp2->cod2+Fp2->dbt+Fp2->cod1 TO (m_path+"Fp2c")
        DispGauge(m_gauge,1.0)
      ELSE
        DelGauge(m_gauge)
        Fp1->(DBUNLOCK())
        CLOSE BASE Fp1,Fp2
        DelMessage(m_message)
        RETURN .f.
     ENDIF
  ELSE
    DelGauge(m_gauge)
    CLOSE BASE Fp1
    DelMessage(m_message)
    RETURN .f.
  ENDIF
  DelGauge(m_gauge)
  Fp1->(DBUNLOCK());Fp2->(DBUNLOCK())
  CLOSE BASE Fp1,Fp2
  DelMessage(m_message)
RETURN .t.

STATIC Function ShiftF6(m_browse)
LOCAl m_ndoc:=BLANK(fp1->ndoc,.t.),m_npch:=BLANK(fp1->npch,.t.),m_recno:=Fp2->(RECNO()),;
m_screen:=SaveScreen(13,10,15,52),GetList:={},n_order:=INDEXORD()
// ВВести номер документа
SET ESCAPE ON
@13,10,15,52 BOX B_DOUBLE+" " COLOR "w+/BG"
@13,12 SayDisp " Введiть номер папки i документа" COLOR "GR+/BG"
@14,12 Get m_npch VALID (m_npch:=JustRight(m_npch),.t.) COLOR "GR+/N"
@14,19 Get m_ndoc VALID (m_ndoc:=JustRight(m_ndoc),.t.) COLOR "GR+/N"
READ
RestScreen(13,10,15,52,m_screen)
IF LASTKEY()<>K_ESC
    m_recno:=Fp2->(RECNO())
    Fp2->(DBSETORDER(2))
    IF Fp2->(DS(m_npch+m_ndoc))
      m_browse:rowPos:=1;m_browse:Configure();m_browse:RefreshAll()
    ELSE
      Fp2->(DBGOTO(m_recno))
      DispError("Документ папка "+m_npch+" N "+m_ndoc+" не знайден")
    ENDIF
    Fp2->(DBSETORDER(n_order))
ENDIF
RETURN .t.

Function Checkprov(var)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc:=0,m_vdoc,n_err3:=0
LOCAL m_path:=IF(a_menu[1]=="MAIN",m_mainpath,m_bufpath)
LOCAL l_exit:=.f.,m_gauge,m_rec
LOCAL l_buf
LOCAL l_code:=.t.
LOCAL s_sum:=0,s_kvo:=0,s_glv:=0,s_kvo2:=0,n_rec:=0
LOCAL nSum2:=0,nKvo3:=0,nGlv2:=0
LOCAL n_error:=0
// Перевiрка структури утримань
  IF .NOT.EMPTY(var)
    m_path:=Var
  ENDIF
  l_buf:=IF(m_path==m_mainpath,.f.,.t.)
  /* открытие справочников */
  NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  l_code:=RESTVAR1("l_code","CH")
  CLOSE myvar
  SET PRINTER TO (m_mash+"46.txt")
  SET CONSOLE OFF
  SET PRINTER ON

  USE (m_path+"Fp1")   NEW
  INDEX ON Fp1->vnum TO  (m_path+"Fp1")
  USE (m_path+"Fp2")   NEW
  INDEX ON Fp2->vnum TO (m_path+"Fp2")
  NET USE (m_platpath+"FIRM01") INDEX (m_platpath+"Firm01"),(m_platpath+"Firm01a"),(m_platpath+"Firm01b") NEW
  NET USE (m_platpath+"BANK01") INDEX (m_platpath+"BANK01") NEW
  NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
  sOpenFiles("201",s_file)

  NET USE (m_path+"fvnum.dbr") NEW ALIAS fvnum

  ?"-----Перевiрка проводок-----------------------------------"
  ?"Зроблена "+DMY(DATE())+" Оператор " +m_imja
  //Проверка на уникальность внутреннего номера
//  n_err1:=CheckVnum(SELECT("Fp1"),{||Fp1->vnum})
Fp1->(DBGOTOP())
m_vnum:=Fp1->vnum
m_ndoc:=RECNO()
m_gauge:=InitGauge("Перевiрка унiкальностi кодiв файла Fp1",2)
Fp1->(DBSKIP())
  DO WHILE .NOT.Fp1->(EOF())
    IF m_vnum==Fp1->vnum
      ?"  !!! Помилка, подвоєння VNUM ",m_vnum,"# ",STR(m_rec,6),"# ",STR(Fp1->(RECNO()),6)
      n_error++
    ENDIF
    m_vnum:=Fp1->vnum
    m_rec:=Fp1->(RECNO())
    Fp1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,m_ndoc++/LASTREC())
  ENDDO
  delGauge(m_gauge)
  Fp1->( DBGOTOP() )
  m_gauge:=InitGauge("Перевiрка проводок",2)
  l_exit:=.f.
  s_sum:=s_kvo:=0
  l_buf:=IF(m_path==m_bufpath,.t.,.f.)
  m_ndoc:=0
  DO WHILE ( Fp1->( !EOF() ) )
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати перевiрку ?")==YES
            ?"Перевiрка проводок прервана. Виконано  " +STR(100*Fp1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
           IF l_code
              // ЛЗК
              IF Fp1->maket=='02'.or.Fp1->maket=='03'
                CheckKod(sp10,Fp1->tabn,fp1,"таб. номер")
                IF Fp1->maket=='03'
                    CheckKod(inv_t,fp1->num,fp1,"номер тракт.")
                ELSE
                    CheckKod(inv_a,fp1->num,fp1,"номер авт.")
                ENDIF
                IF l_buf
                  IF fp1->mnt<>fvnum->mnt1
                    ?" Попередження !!! Не спiвп. перiод розр."
                    ?? " Пачка:",fp1->npch,". Номер док.:",fp1->ndoc
                  ENDIF
                ENDIF
              ENDIF
           ENDIF
        /* если совпадение по внутренним номерам */
      IF .NOT.Fp2->(DS(Fp1->vnum))
        ?" Помилка !!! Fp1->Fp2 vnum=",Fp1->vnum," #",STR(Fp1->(RECNO()),6)
        n_error++
      ELSE
        DO WHILE ( Fp1->vnum == Fp2->vnum .AND. Fp2->( !EOF() ) )
           IF l_code
            CheckKod(Sp44,fp2->dbt,fp1,"код дебету")
            IF .NOT.AnCodCheck(Fp2->dbt,Fp2->cod1)
              n_warn++
              ?"Невiрний аналiтичний код дебету "+Fp2->dbt+"-->"+Fp2->cod1
              ?" Док. папка "+Fp1->npch+" N "+Fp1->ndoc+" #"+STR(Fp2->(RECNO()),6)+" @"+Fp2->vnum
            ENDIF
            IF .NOT.EMPTY(Fp2->kplh)
              CheckKod(Sp02,fp2->kplh,fp1," код одерж. ")
            ENDIF
            IF .NOT.EMPTY(Fp2->brgd1)
              CheckKod(Sp01,fp2->brgd1,fp1," код бригади 1")
            ENDIF
            CheckKod(Sp44,fp2->crt,fp1,"код  кредиту ")
            IF .NOT.AnCodCheck(Fp2->crt,Fp2->cod2)
              n_warn++
              ?"Невiрний аналiтичний код кредиту "+Fp2->crt+"-->"+Fp2->cod2
              ?" Док. папка "+Fp1->npch+" N "+Fp1->ndoc+" #"+STR(Fp2->(RECNO()),6)+" @"+Fp2->vnum
            ENDIF
            IF .NOT.EMPTY(Fp2->otp )
              CheckKod(Sp02,fp2->otp,fp1," код отпр. ")
            ENDIF
            IF .NOT.EMPTY(Fp2->brgd2)
              CheckKod(Sp01,fp2->brgd2,fp1," код бригади 2")
            ENDIF
            IF .NOT.EMPTY(Fp2->kopr)
              CheckKod(Sp05,fp2->kopr,fp1," код операцiї ")
            ENDIF
           ENDIF
           s_kvo += Fp2->kvo
           s_kvo2+= Fp2->kvo2
           s_glv += Fp2->glv
           s_sum += Fp2->stm
           Fp2->( DBSKIP() )
        ENDDO
       ENDIF
     Fp1->(DBSKIP())
     m_ndoc++
     m_gauge:=DispGauge(m_gauge,m_ndoc/(2*Fp1->(LASTREC())))
  ENDDO
  Fp2->(DBGOTOP())
  n_rec:=1
  DO WHILE .not.Fp2->(EOF())
      IF .NOT.Fp1->(DS(Fp2->vnum))
        ?" Помилка !!! Fp2->Fp1 vnum=",Fp2->vnum," #",STR(Fp2->(RECNO()),6)
        n_error++
     ENDIF
     Fp2->(DBSKIP())
     n_rec++
     m_gauge:=DispGauge(m_gauge,0.5+n_rec/(Fp2->(LASTREC())))
  ENDDO
  IF .NOT.l_exit
    ?"Перевiрка проводок завершена"
    ? " Контр. сумма "
    ?"  Голiв        ", NumToSTR( s_glv, 12,0)
    ?"  Кiлькiсть лiт", SumToSTR( s_kvo2, 12)
    ?"  Кiлькiсть    ", SumToSTR( s_kvo, 12)
    ?"  Сума         ", SumToSTR( s_Sum, 12)
    ?" Загальна кiлькiсть документiв ", SumToSTR( m_ndoc, 6)
  ENDIF
  ScloseFiles(s_file)
  CLOSE BASE Fp1,Fp2,fvnum,firm01,bank01,kaptka1
  DelGauge(m_gauge)
? STRZERO(MONTH(DATE()),2)+STRZERO(MONTH(DATE()),2)+m_oper+DTOS(DATE())+TIME()+"ZZ"

   SET PRINTER OFF
  SET CONSOLE ON
  SET PRINTER TO

  IF n_error==0
    return .t.
  ENDIF

RETURN .f.




Function ChanProv(var)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge,k:=0,i,n_rec:=1
LOCAL a_file:={"fp1","fp2"},l_change:=.f.
LOCAL m_path:=IF(a_menu[1]=="MAIN",m_mainpath,m_bufpath)
LOCAL m_ret:=.f.
  IF .NOT.EMPTY(var)
    m_path:=Var
  ENDIF

FOR i:=1 TO LEN(a_file)
  FILECOPY(m_path+a_file[i]+".dbf"   ,m_temppath+a_file[i]+".dbf"   )
  USE (m_temppath+a_file[i])   NEW
NEXT
  SET PRINTER TO (m_mash+"46.txt")
  SET CONSOLE OFF
  SET PRINTER ON
  ?"-----Лiкування бази даних проводок -----------------------------------"
  ?"Зроблено "+DMY(DATE())+" Оператор "  + m_imja
  l_exit:=.f.
  sele fp1
  INDEX ON Fp1->vnum TO  (m_temppath+"Fp1")
  sele fp2
  INDEX ON fp2->vnum TO (m_temppath+"fp2")

  m_gauge:=InitGauge("Лiкування проводок - видалення подвiйних записiв ",2)
  fp1->(DBGOTOP())

m_vnum:=Fp1->vnum
Fp1->(DBSKIP())
m_ndoc:=1
  DO WHILE .not.Fp1->(EOF())
    IF m_vnum==Fp1->vnum
      ?"  !!! Помилка, подвоєння VNUM ",m_vnum,"# ",STR(Fp1->(RECNO()),6)
      ?"** Запис буде видалено "
      Fp1->(DBDELETE())
      l_change:=.t.
    ELSE
      m_vnum:=Fp1->vnum
    ENDIF
    Fp1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,m_ndoc++/LASTREC())
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  проводок прервано. Виконано  " +STR(100*fp1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
  ENDDO
delGauge(m_gauge)
Fp1->( DBGOTOP() )
  m_gauge:=InitGauge("Лiкування проводок - видалення записiв без заголовку ",2)
  Fp2->(DBGOTOP())
  n_rec:=1
  DO WHILE .not.Fp2->(EOF()).AND..NOT.l_exit
      IF .NOT.Fp1->(DS(Fp2->vnum))
        ?" Помилка !!! Fp2->Fp1 vnum=",Fp2->vnum," #",STR(Fp2->(RECNO()),6)
        m_vnum:=Fp2->vnum
        DO WHILE .NOT.fp2->(EOF()).AND.Fp2->vnum==m_vnum
          Fp2->(DBDELETE())
          Fp2->(DBSKIP())
          n_rec++
        ENDDO
        l_change:=.t.
    ELSE
      Fp2->(DBSKIP())
      n_rec++
     ENDIF
     m_gauge:=DispGauge(m_gauge,n_rec/(Fp2->(LASTREC())))
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  проводок прервано. Виконано  " +STR(100*fp1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
  ENDDO
delGauge(m_gauge)
m_gauge:=InitGauge("Лiкування проводок - видалення  заголовкiв без запису ",2)
DO WHILE .NOT.l_exit
  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  n_error:=0;k++
  ?STR(k,3)," перегляд бази даних"
  DO WHILE .NOT.fp1->(EOF())
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  проводок прервано. Виконано  " +STR(100*fp1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
        IF .NOT.fp2->(DS(fp1->vnum))
          ?" Видалення !!! fp1->fp2 N",fp1->npch,fp1->ndoc," vnum=",fp1->vnum," #",STR(fp1->(RECNO()),6)
          Fp1->(DBDELETE())
          l_change:=.t.
         ENDIF
     fp1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,fp1->(RECNO()/LASTREC()))
  ENDDO
  IF n_error==0
    EXIT
  ENDIF
ENDDO
DelGauge(m_gauge)
IF .NOT.l_exit
  IF ANSWERu("Виконувати перекодiровку; внутр. номерiв ?")==YES
    ?"Перекодiровка внутр. номерiв"
    perekod4(m_path,a_file)
    l_change:=.t.
  ENDIF
  ?"Лiкування завершено"
  CLOSE BASE fp1,fp2
  IF n_error==0
    FOR i:=1 TO LEN(a_file)
      k:=FERASE(m_path+a_file[i]+".dbf")
      IF k==-1
        DispError("Помилка при видаленнi файла "+a_file[i]+";База даних"+m_path+" зруйнована")
      ELSE
        FILECOPY(m_temppath+a_file[i]+".dbf",m_path+a_file[i]+".dbf")
      ENDIF
    NEXT
  ENDIF
  m_ret:=.t.
ELSE
  CLOSE BASE fp1,fp2
  m_ret:=.f.
ENDIF

? STRZERO(MONTH(DATE()),2)+STRZERO(MONTH(DATE()),2)+m_oper+DTOS(DATE())+TIME()+"ZZ"
  SET PRINTER OFF
  SET CONSOLE ON
  SET PRINTER TO
Reindex(m_path)
return m_ret


STATIC FUNCTION perekod4(m_path,a_file,x1)
LOCAL m_gauge,m_vnum,i,m_vnum1

m_gauge:=InitGauge("Перекодiровка",2)
IF x1==NIL
  DO CASE
    CASE m_path==m_mainpath
      m_vnum:=1
    CASE m_computer>=1.AND.m_computer<=8
      m_vnum:=m_computer*100000
    OTHERWISE
      m_vnum:=100000
  ENDCASE
ELSE
  m_vnum:=x1
ENDIF
fp1->(DBSETORDER(0))
fp1->(DBGOTOP())
  DO WHILE .not.(fp1->(EOF()))
//     SetVnum(fp1,fp2,vnum,STR(m_vnum,7))
    IF fp1->vnum<>STR(m_vnum,7)
      DO WHILE fp2->(DS(fp1->vnum))
         fp2->vnum:=STR(m_vnum,7)
      ENDDO
      fp1->vnum:=STR(m_vnum,7)
    ENDIF

     fp1->(DBSKIP())
     m_vnum++
     m_gauge:=DispGauge(m_gauge,fp1->(RECNO()/LASTREC()))
  ENDDO
  NET USE (m_path+"FVNUM.dbr") NEW
  IF fvnum->(NetRlock())
    fvnum->vnum:=m_vnum
  ENDIF
  close fvnum
fp1->(DBSETORDER(1))

RETURN .T.



Function AnCodCheck(m_ksash,m_kod)
  LOCAL i
Sp44->(DS(m_ksash))
  DO CASE
    CASE Sp44->type1 == " "
      RETURN .t.
    CASE Sp44->type1 == "1"
      i:=Kaptka1->(DS(m_kod))
    CASE Sp44->type1 == "2"
      i:=Sp10->(DS(LEFT(m_kod,4)))
    CASE Sp44->type1 == "3"
      Firm01->(DBSETORDER(2))
      i:=firm01->(DS(m_kod))
      Firm01->(DBSETORDER(1))
    CASE Sp44->type1 == "4".OR.Sp44->type1 == "5"
      i:=Sp08->(DS(LEFT(m_kod,3)))
    CASE Sp44->type1 == "6"
      i:=inv_a->(DS(LEFT(m_kod,5)))
    CASE Sp44->type1 == "7"
      i:=inv_t->(DS(LEFT(m_kod,5)))
    CASE Sp44->type1 == "8"
      i:=inv_mo->(DS(LEFT(m_kod,5)))
    CASE Sp44->type1 == "9"
      i:=sp17->(DS(LEFT(m_kod,5)))
ENDCASE
RETURN i

Function CopyProv()
  LOCAL m_path:=IF(a_menu[1]=="MAIN",m_mainpath,m_bufpath)
  LOCAL a_file:={m_path+"Fp1.dbf",m_path+"Fp2.dbf"}
COpyFl(a_file,IF(m_path==m_mainpath,"Основна","Буферна")+" база даних ")
RETURN .t.






Function DobProv(var)
  LOCAL m_gauge,m_message,m_netpath:="",m_npch:=SPACE(40),;
  m_screen,GetList:={},a_file:={"Fp1","Fp2"},i,m_path,a_struct:={},;
  a1:={"d:\buhgal\bf\fp1","d:\buhgal\bf\fp2"},l_copy:=.f.
// проверить основная база - основного компьютера

// 1-й этап - перекачка в copypath

DO CASE
  CASE var=="DISK"
    IF Restfl1()
    ELSE
      Return .f.
    ENDIF
  CASE var=="BUFER".OR.var=="LINK"
    IF var=="LINK"
      IF .NOT.SelNetPath(@m_path)
        RETURN .f.
      ENDIF
    ELSE
      m_path:=m_bufpath
    ENDIF
    m_screen:=SaveScreen(((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+5,75)
    SET ESCAPE ON
    @INT((MAXROW()-4)/2)+1,5,INT((MAXROW()-4)/2)+5,75 BOX B_DOUBLE+" " COLOR ("w+/bg")
    @INT((MAXROW()-4)/2)+3,6 SayDisp '  Введiть номера пачок' COLOR "GR+/bg"
    @INT((MAXROW()-4)/2)+3,31 GET m_npch COLOR "w/b,Gr+/n"
    READ
    RestScreen(((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+5,75,m_screen)
    IF LASTKEY()==K_ESC
      RETURN .f.
    ENDIF
    m_npch:=ALLTRIM(m_npch)

    FOR i:=1 TO LEN(a_file)
      a1[i]:=m_path+a_file[i]
      IF IsBit(FILEATTR(m_path+a_file[i]+".dbf"),6)
        l_copy:=.t.
      ENDIF
    NEXT
      IF l_copy
        IF ANSWERu("Дуже рекомендую зробити копiю;бази даних!;Робити копiю?")==YES
          COpyFl(a1,"База даних за мiсяць")
        ENDIF
      ENDIF
      IF .not.CheckProv(m_path)
          DispError("Знайденi помилки в базi даних !!!")
          RETURN .f.
      ENDIF
    IF EMPTY(m_npch)
      FOR i:=1 TO LEN(a_file)
        FILECOPY(m_path+a_file[i]+".dbf",m_copypath+a_file[i]+".dbf")
      NEXT
    ELSE
      FOR i:=1 TO LEN(a_file)
        USE (m_mainpath+a_file[i]) NEW
        a_struct:=DBSTRUCT()
        DBCLOSEAREA()
        IF FILE(m_copypath+a_file[i]+".dbf")
          FERASE(m_copypath+a_file[i]+".dbf")
        ENDIF
        DBCREATE(m_copypath+a_file[i],a_struct)
      NEXT
      USE (m_path+"fp1") NEW ALIAS Fp1
      USE (m_path+"fp2") INDEX (m_path+"fp2") NEW ALIAS Fp2
      USE (m_copypath+"fp1") NEW ALIAS File1
      USE (m_copypath+"fp2") NEW ALIAS File2
      m_npch:=m_npch+"."
      DO WHILE .NOT.fp1->(EOF())
        IF AT(ALLTRIM(fp1->npch),m_npch)<>0
          File1->(DBAP())
          FOR i:=1 TO Fp1->(FCOUNT())
            file1->(FieldPut(i,Fp1->(FIELDget(i))))
          NEXT
          Fp2->(DS(Fp1->vnum))
          DO WHILE .NOT.fp2->(EOF()).AND.fp2->vnum==fp1->vnum
              File2->(DBAP())
            FOR i:=1 TO Fp2->(FCOUNT())
              file2->(FieldPut(i,fp2->(FIELDget(i))))
            NEXT
            Fp2->(DBSKIP())
          ENDDO
        ENDIF
        Fp1->(DBSKIP())
      ENDDO
      Close Base Fp1,Fp2,File1,File2
    ENDIF
  OTHERWISE
    RETURN .f.
ENDCASE

// 2-й этап перекачка информации

USE (m_copypath+a_file[1]) NEW
USE (m_copypath+a_file[2]) NEW
INDEX ON fp2->vnum TO (m_copypath+a_file[2])
IF fp1->(EOF())
  DispError("Вiдсутнi записи для переносу")
  CLOSE BASE fp1,fp2
  RETURN .f.
ENDIF
FOR i:=1 TO LEN(a_file)
  FILECOPY(m_mainpath+a_file[i]+".dbf",m_temppath+a_file[i]+".dbf")
NEXT

NET USE (m_mainpath+"FVNUM.dbr") NEW
IF fvnum->(NetRlock())
  m_vnum := fvnum->vnum
ELSE
  close base Fp1,Fp2,fvnum
  RETURN .F.
ENDIF
close fvnum

Perekod4(m_mainpath,a_file,m_vnum)

FOR i:=1 TO LEN(a_file)
  DBSELECTAREA(a_file[i])
  DBCLOSEAREA()
NEXT

FOR i:=1 TO LEN(a_file)
  USE (m_temppath+a_file[i]) NEW ALIAS File1
  APPEND FROM (m_copypath+a_file[i])
//  FERASE(m_copypath+a_file[i]+".dbf")
  CLOSE File1
NEXT

//  Очистка или удаление  перемещенной информации

IF   var<>"DISK"
    IF EMPTY(m_npch)
      FOR i:=1 TO LEN(a_file)
        USE (m_path+a_file[i]) NEW ALIAS File1
        ZAP
        CLOSE File1
      NEXT
    ELSE
      // удаление выбранных пачек

      USE (m_path+"fp1") NEW ALIAS Fp1
      USE (m_path+"fp2") INDEX (m_path+"fp2") NEW ALIAS Fp2

      DO WHILE .NOT.fp1->(EOF())
        IF AT(ALLTRIM(fp1->npch),m_npch)<>0
          Fp2->(DS(Fp1->vnum))
          DO WHILE .NOT.fp2->(EOF()).AND.fp2->vnum==fp1->vnum
            Fp2->(DBDELETE())
            Fp2->(DBSKIP())
          ENDDO
          Fp1->(DBDELETE())
        ENDIF
        Fp1->(DBSKIP())
      ENDDO
      Close Base Fp1,Fp2
    ENDIF
 ENDIF
FOR i:=1 TO LEN(a_file)
  FILECOPY(m_temppath+a_file[i]+".dbf",m_mainpath+a_file[i]+".dbf")
NEXT

 REINDEX(m_mainpath)
RETURN .t.




Function CopySprav()
  LOCAL m_path:=m_sprpath,a_dir:=DIRECTORY(m_path+"*.*")
  LOCAL a_file:={}
  AEVAL(a_dir,{|x|AADD(a_file,x[1])})
COpyFl(a_file,"Справочна база даних ")
RETURN .t.

STATIC Function CheckNum(var,m_maket,a_data1)
DO CASE
  CASE m_maket=="02" // Водiї
     RETURN inv_a->(sp_vl("INV_A",,5,19,"sp13a->naim13a","GR+/B"))
  CASE m_maket=="03" // Трактористи - машинiсти
    EVAL(var:block,JustRight(EVAL(var:block)))
    var:display()
    RETURN inv_t->(sp_vl("INV_T",,5,19,"sp13b->naim13b","GR+/B"))
ENDCASE
EVAL(var:block,JustRight(EVAL(var:block)))
var:display()
RETURN .T.

STATIC Function CopyZap(m_mode)
STATIC a_fp2:={}
LOCAL i:=1
IF m_mode=="0"
  a_fp2:={fp2->dbt,fp2->cod1,fp2->brgd1,fp2->kplh,fp2->crt,fp2->cod2,fp2->brgd2,fp2->otp,fp2->kopr,fp2->glv,fp2->kvo,fp2->kvo2,fp2->stm,fp2->vnum}
   RETURN .t.
ENDIF

IF m_mode=="1"
  IF LEN(a_fp2)==0
    RETURN .f.
  ENDIF
  fp2->dbt   :=  a_fp2[05]
  fp2->cod1  :=  a_fp2[06]
  fp2->brgd1 :=  a_fp2[07]
  fp2->kplh  :=  a_fp2[08]
  fp2->crt   :=  a_fp2[01]
  fp2->cod2  :=  a_fp2[02]
  fp2->brgd2 :=  a_fp2[03]
  fp2->otp   :=  a_fp2[04]
  fp2->kopr  :=  a_fp2[09]
  fp2->glv   :=  a_fp2[10]
  fp2->kvo   :=  a_fp2[11]
  fp2->kvo2  :=  a_fp2[12]
  fp2->stm   :=  a_fp2[13]
  fp2->vnum  :=  a_fp2[14]
ENDIF
RETURN .t.

STATIC FUNCTION Checkww(n1,kod,n2,name)
IF .NOT.(n1)->(DS(kod))
  ?"  Увага, не визн. код "+name, kod
  ??"   Пачка:",(n2)->npch,"N",(n2)->ndoc
ENDIF
return .t.

STATIC Function  SelNetPath(m_netpath)  // Вибiр мереж. дiску
  LOCAL a_choice:={},i,j,n,cLocalName
 i:=0
  DO WHILE .t.
    cLocalName:=NETLOCNAME(i)
    i++
    IF EMPTY(cLocalName)
      EXIT
    ENDIF
    IF FILE(LEFT(cLocalName,1)+SUBSTR(m_exepath,2)+"computer.txt")
      AADD(a_choice,cLocalName+" "+MEMOREAD(LEFT(cLocalName,1)+SUBSTR(m_exepath,2)+"computer.txt"))
    ENDIF
  ENDDO
  IF EMPTY(a_choice)
    DispError("В мережi не знайдено бази Барсу")
    RETURN .f.
  ENDIF
  i:=MyMenu("Вибiр мережевої бази даних",a_choice)
  IF i==0
    RETURN .f.
  ENDIF
  m_netpath:=LEFT(a_choice[i],1)+SUBSTR(m_bufpath,2)
RETURN .t.
/*
* Вывод шапки документов
*
*/
STATIC Function SayShapka(a_get1,n_pole,n1,a_data1,b_mnt1)

        FOR n_pole:=1 TO n1
          a_data1[n_pole]:=fp1->(FIELDGET(a_get1[n_pole]:cargo))
          a_get1[n_pole]:Display()
        NEXT
        @2,47 SayDisp fp1->maket COLOR "gr+/b"
        maket->(DS(MAKET_NUM+fp1->maket+"00"))
        EVAL(b_mnt1,a_data1[6])
//        @1,36 SayDisp LEFT(PADR(mnt_dtoc(fp1->mnt),15),15) COLOR "Gr+/b"
        @2,50 SayDisp Maket->name
        @2,31 SayDisp BLANK(fp1->ndoc,.t.) COLOR "w/b"
        @1,58 SayDisp fp1->oper  COLOR "Gr+/b"
        DO CASE
          CASE fp1->oper=="WW"
            @1,61 SayDisp LEFT("Синт. облiк працi   ",20) COLOR "Gr+/b"
          CASE fp1->oper=="N1"
            @1,61 SayDisp LEFT("Накладнi (в рахунок зарплати)",20) COLOR "Gr+/b"
          CASE fp1->oper=="N2"
            @1,61 SayDisp LEFT("Накладнi (формування проводок)",20) COLOR "Gr+/b"
          CASE fp1->oper=="KS"
            @1,61 SayDisp LEFT("Касса",20) COLOR "Gr+/b"
          OTHERWISE
            @1,61 SayDisp LEFT(_fio(GetOper(fp1->oper)),20) COLOR "Gr+/b"
        endcase

        IF .NOT.EMPTY(a_data1[4])
          @4,19 SayDisp LEFT(_fio(fp1->tabn),20) COLOR "Gr+/b"
        ELSE
          @4,19 SayDisp SPACE(20) COLOR "Gr+/b"
        ENDIF
       n_pole:=1
RETURN .T.
STATIC FUNCTION CalcKg(m_maket,m_mnt)
IF m_maket == "02" .OR. m_maket == "03"  // Лимитно - заборные карты
  IF Sp22->(DS(m_mnt+RIGHT(RTRIM(Fp2->dbt),2)))
    Fp2->kvo:=Sp22->koef*Fp2->kvo2
    Fp2->stm:=Sp22->koef*Fp2->kvo2*Sp22->prise
  ELSE
    DispError("Не знайден темп. коеф; для палива "+RIGHT(RTRIM(Fp2->dbt),2)+";"+;
    MNT_DTOC(m_mnt))
  ENDIF
ENDIF
RETURN .T.
STATIC FUNCTION CheckTabn(a_data1,m_maket)
LOCAL l_return :=Sp10->(Sp_vl("SP10","2",4,19,"_fio()","Gr+/b",20))
IF l_return.AND.EMPTY(a_data1[5])
DO CASE
  CASE m_maket=="02" // Водiї
      Inv_a->(DBSETORDER(2))
      Inv_a->(DS(a_data1[4]))
      a_data1[5]:=Inv_a->gnavt
      Inv_a->(DBSETORDER(1))
  CASE m_maket=="03" // Трактористи - машинiсти
      Inv_t->(DBSETORDER(2))
      Inv_t->(DS(a_data1[4]))
      a_data1[5]:=Inv_t->invnum
      Inv_t->(DBSETORDER(1))
ENDCASE
ENDIF
RETURN l_return
STATIC FUNCTION OpenFp(m_path)
LOCAL l_index :=.f.
IF MoreNew(m_path+"Fp1.dbf",m_path+"Fp1.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp1.dbf",m_path+"Fp1a.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2a.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2b.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2c.ntx");l_index:=.t.;ENDIF

IF l_index.AND.ANSWERu("Можлива невiдповiднiсть iндексiв;Прoiндексувати заново ?")==YES
  Reindex()
ENDIF

  NET USE (m_path+"Fp1") INDEX (m_path+"Fp1"),(m_path+"Fp1a")  NEW
  DBSETORDER(1)
  NET USE (m_path+"Fp2") INDEX (m_path+"Fp2"),(m_path+"Fp2a"),(m_path+"Fp2b"),(m_path+"Fp2c")  NEW
return .t.
STATIC FUNCTION MoreNew(m_file1,m_file2)
IF FILEDATE(m_file1)>FILEDATE(m_file2)
  return .t.
ELSE
 IF FILEDATE(m_file1)==FILEDATE(m_file2).AND.;
     FILETIME(m_file1)>FILETIME(m_file2)
    return .t.
 ENDIF
ENDIF
RETURN .F.
