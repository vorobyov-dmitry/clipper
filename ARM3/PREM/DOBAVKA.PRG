//
//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
//� 蹍罐ゃ��: D_DOPL()
//� �≒��: ����ア �.�.
//� ���� ��о�｀皖�: 10/09/94.
//� ��Л�腑�┘:
//�       ���竍キ┘ ��腑� ぎ�祠キ皰� N 5 �� ��腮甄キ�� ��ぁ�→�
//�       � ��牆��皀 � ぅ�ウ��� ����キ��罔�.
//� ��Б����モ:
//�       NIL
//� �����モ琺:
//�       �モ.
//� �甎��讌礇�襯 ↓ヨ�┘ �ムガキ�襯:
//�       �モ.
//� �甎��讌礇�襯 �牀罐ゃ琺 � 粃��罔�:
//�       BegInit(), GetMonth(), AskUser(), pFilPoz().
//� �甎��讌礇�襯 ����� か� ��痰牀���:
//�  \JS\inidpl.dbf, \ST\fdopl.dbf, \ST\fkomp.dbf
//� ��｀膈襯 辟筌�硅: ├�キエ� ����� fvnum.dbf.
//� 踸�ョ����: �モ.
//藩様様様
//

#define    BEEP_ASK     TONE( 3000, 0 )
#include "setcurs.ch"
#include "inkey.ch"
#include "set.ch"
#include "buh.ch"
Function Main(var1)
  local m_month:=0,m_ddoc,m_prc,m_proc1:=0,m_proc2:=0
  local m_shpz,m_kopldpl,m_koplkmp,m_npchdpl,m_npchkmp,m_kopudpl
  local m_mp,m_komp,m_overkmp,m_x,m_recno1,m_recno2
  local GETLIST:={}
  local m_time:=TIME(),m_env,m_path,m_name,rstr,rstr1
  local m_var:=IF(var1==NIL,"",alltrim(var1)),m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())

   // �����讚�� 竅����→� 瓱痰ガ�諷 �ムガキ�諷///////////////////////////////
   BegInit()                                                               //

   SET (_SET_EXIT        , .t. )
   USE       ("d:\buhgal\js\init.dbf")
             M_SYSPATH  :=  ALLTRIM(init->sys)  // ������� �  瓱痰ガ��� ┃筮爼�罔ォ
   PUBLIC    M_BUFPATH  :=  ALLTRIM(init->bufpath)  // ������� � ＜筌爿�� ��
   PUBLIC    M_MAINPATH :=  ALLTRIM(init->mainpath) // ������� � �甅�↓�� ��
   PUBLIC    M_SPRPATH  :=  ALLTRIM(init->sprpath)  // ������� 甌 甎��〓膈┴���
   PUBLIC    M_MASH     :=  ALLTRIM(init->mash)     // ������� か� ��荐�������
   PUBLIC    M_oldsys   :=  ALLTRIM(init->oldsys)
   PUBLIC    M_PLATPATH :=  ALLTRIM(init->platpath)  // ������� か� ���┤
   PUBLIC    M_WORKPATH :=  m_var
   PUBLIC    p_help_code  := 0                     // �����モ� か� 蹣������� HELP
   PUBLIC    F_MENU     :=  ALLTRIM(init->menu) // ���� �キ�
   PUBLIC    p_npr:=""
   m_name:=init->name
   CLOSE  init

   PUBLIC a_menu:={}
   CLEARWIN(0,0,MAXROW(),MAXCOL(),'N/W','�')
   SET KEY K_F10 TO Calc
   SETKEY(K_INS,{||READINSERT(.NOT.READINSERT()),;
                   SETCURSOR(IF(READINSERT(),SC_INSERT,SC_NORMAL))})
   KEYBOARD ""
   InitParPrn()
   // ****************************************///////////////////////////////

   SetColor ( "N+/W,GR+/N" )
   SET CURSOR OFF
   CLS

   // B〓� ＜紕��皀珀���� �メ閹�/////////////////////////////////////////////
      m_month := GetMonth ()                                               //
   IF m_month == -1                                                        //
      RETURN                                                               //
   ENDIF                                                                   //
   // **************************/////////////////////////////////////////////


   CLS
   SET CURSOR ON
   SET ESCAPE ON

   // �����讚�� 竅����→� m_prc, m_shpz, m_kopldpl, /////////////////////////
   //                     m_koplkmp, m_komp, m_overkmp///////////////////////
   USE D:\BUHGAL\JS\inidpl NEW READONLY                                    //
   m_prc := inidpl->prc          //�牀罐�� ぎ����                          //
   m_shpz := inidpl->shpz        //��� か� ���.����薑                      //
   m_kopldpl := inidpl->kopldpl  //��� ����� か� ぎ����                    //
   m_koplkmp := inidpl->koplkmp  //��� ����� か� ���.����薑                //
   m_mp := inidpl->komp          //��Кム ���.����薑                       //
   m_overkmp := inidpl->overkmp  //������腑�┘ ����キ��罔�                 //
   m_npchdpl := inidpl->npchdpl  //���ム ��腦� か� ぎ����                  //
   m_npchkmp := inidpl->npchkmp  //���ム ��腦� か� ���.����薑              //
   m_kopudpl := inidpl->kopudpl  //��る �� ��皰琺� ��腮甄錺矚� ぎ�����     //
   close inidpl                                                            //
   // ***********************************************////////////////////////

   // �襤�� �����モ牀� �� 蹣��� え甎�ワ か� ��玻オ罔�////////////////////////
   rstr1:='25/01/00'
   if m_month<10
      m_x:=1
   else
      m_x:=2
   endif
   rstr:=stuff(rstr1,6-m_x,m_x,ALLTRIM(str(m_month)))
   m_ddoc:=ctod(stuff(rstr,7,2,right(ALLTRIM(str(year(date()))),2)))
   USE D:\BUHGAL\SP\SP07 INDEX d:\BUHGAL\SP\SP07 NEW READONLY              //
   USE D:\BUHGAL\SP\SP08 INDEX d:\BUHGAL\SP\SP08 NEW READONLY              //
   SetColor ( ten_clr )                                                    //
   @9,16 CLEAR TO 15,52                                                    //
   SetColor ( vvod_clr )                                                   //
   @8,14 CLEAR TO 14,50                                                    //
   DISPBOX(8,14,14,50,1,vvod_clr)                                          //
   @09,15 say '蹍罐�� ぎ����            ' get m_prc picture '99999.99'    //
                                                                           //
   @10,15 say '��Кム ���.����薑         ' get m_mp picture '99999999'     //
                                                                           //
//   @11,15 say '��Кム ������腑��� (����.)' get m_overkmp picture '99999999'//
                                                                           //
   @11,15 say '���� 筮爼. ぎ�祠キ皰�     ' get m_ddoc                      //
                                                                           //
   @12,15 say '��� か� ���.����薑        ' get m_shpz picture 'NNNNNNNN' VALID  f_valid('sp07->ksash','sp07->naim7',25,15)
                                                                           //
//   @14,15 say '��� ����� か� ぎ����      ' get m_kopldpl picture '99999999' valid f_valid("sp08->kopu","sp08->name8",25,15)
                                                                           //
   @13,15 say '��� ����� か� ぎ����      ' get m_kopldpl picture '99999999' valid f_valid("sp08->kopu","sp08->name8",25,15)
   read                                                                    //
      IF( LASTKEY() == K_ESC )                                             //
          BEEP_ASK                                                         //
          IF( AskUser( ,"�������� �牀������ , �� 磚ムキ� ?", 2 ))          //
            RETURN                                                         //
          ENDIF                                                            //
          KEYBOARD   ""                                                    //
      ENDIF                                                                //
                                                                           //
   CLOSE SP07                                                              //
   CLOSE SP08                                                              //
   // ***********************************************////////////////////////

   SetColor ( "N+/W,GR+/N" )
   SET CURSOR OFF
   CLS

   //�皖琺皋� 甎��〓膈┴� ��｀皚┴��/////////////////////////////////////////
   use d:\buhgal\sp\sp10 index d:\buhgal\sp\sp10 NEW READONLY              //
   //*******************************/////////////////////////////////////////

   //��Г��┘ 甄礒ァ. ����� か� ��爛ぅ�キ�� ��腮甄キ┤///////////////////////
   //��｀皚┴�� � ��оェ� ���. ���ム��///////////////////////////////////////
   SELECT 0                                                                //
   CREATE d:\buhgal\temp\fdopl FROM d:\buhgal\st\fdopl                       //
   INDEX ON fdopl->tabn TO d:\buhgal\temp\fdopl                              //
   //*************************************************///////////////////////

   //��Г��┘ 甄礒ァ. ����� か� ��爛ぅ�キ�� ��腮甄キ┤///////////////////////
   //��｀皚┴�� � ��оェ� ���.���.+���+�爬����///////////////////////////////
   SELECT 0                                                                //
   CREATE d:\buhgal\temp\fkomp FROM d:\buhgal\st\fkomp                       //
   INDEX ON fkomp->tabn+fkomp->ksash+fkomp->brgd TO d:\buhgal\temp\fkomp     //
   //*************************************************///////////////////////

   //���罔��├�罔� ┃え��皰�� N 1////////////////////////////////////////////
   m_proc1 := Workinit ( 8,10,10,70, "�諛�甄キ┘ 痺�� か� ぎ���� �� �ム※膈覓 ぎ�祠キ��� ���" )
   WorkWindow ( m_proc1 )                                                  //
   //****************************////////////////////////////////////////////

   //�皖琺皋� ��щ ����諷 ぎ�祠キ皰� �� ��腮甄キ�� ��////////////////////////
   USE d:\buhgal\mn\fz1 NEW                                                //
   USE d:\buhgal\mn\fz2 NEW                                                //
   USE d:\buhgal\mn\fz3 NEW                                                //
   //************************************************////////////////////////

   SELECT fz1
   GOTO TOP
   DO WHILE ! fz1->( Eof () )
      //����キ┘ ぎ�祠キ皰� N 5 �爬 ��≒�爿�� ���竅�� �牀������//////////////
      //� 皰� Ε �メ閹�//////////////////////////////////////////////////////
      IF fz1->vdoc==5.AND.BuhMonth(fz1->ddoc)==Buhmonth(m_ddoc)            //
         IF pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )                            //
            DO WHILE fz2->vnum1 == fz1->vnum1 .AND. !fz2->(EOF())          //
               //蹍絎え� �� ����瘴� fz2, 瓣錻���覓 � 皀�竕ォ ����瘡� fz1  //
               IF pFilPoz ( 'fz3' , 'vnum2' , 'fz2' )                      //
                  DO WHILE fz3->vnum2 == fz2->vnum2 .AND. !fz3->(EOF())    //
                     fz3->(dbdelete())                                     //
                     fz3->(DBSKIP())                                       //
                  ENDDO                                                    //
               ENDIF                                                       //
               fz2->(DBDELETE())                                           //
               fz2->(DBSKIP())                                             //
            ENDDO                                                          //
         ENDIF                                                             //
         fz1->(dbdelete())                                                 //
         fz1->(dbskip())                                                   //
         LOOP                                                              //
      ENDIF                                                                //
      //*******************************************************//////////////

      //ｯ爛ぅ�キ┘ ������ 痺��� ��腮甄キ┤ � ��爛ぅ�キ┘ 痺��� ��腮甄キ┤///
      //� ��ぎ�  =m_kopudpl=  � ��оェ� ���.���ム�� (���� fdopl.dbf);////////
      //��爛ぅ�キ┘ 痺��� ��腮甄キ┤ � ��ぎ�  =m_kopudpl=  � ��оェ� ���.��-/
      //�ム��+���+�爬���� (���� fkomp.dbf)///////////////////////////////////
      IF BuhMonth ( fz1->ddoc ) == m_month
         IF pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )
            DO WHILE fz2->vnum1 == fz1->vnum1 .AND. !fz2->(EOF())
               //蹍絎� �� ����瘴� fz2, 瓣錻���覓 � 皀�竕ォ ����瘡� fz1
               sp10->(DBSEEK(fz2->tabn))
//               IF fz1->vdoc != 38.AND.sp10->(FOUND()).AND.sp10->kpn<>'4' && �甄� ���.
               IF fz1->vdoc != 38.AND.sp10->(FOUND()).AND.sp10->kpn<>'4'.AND.sp10->kpn<>'6'.AND.sp10->kpn<>'7' && �甄� ���.
                  && ���ム� �モ � 甎��〓膈┴�  �� 痺���牀��碎
                  && �� 蹣甎�����罔� �≒���爲�
                  IF pFilPoz ( 'fz3' , 'vnum2' , 'fz2' )
                     DO WHILE fz3->vnum2 == fz2->vnum2 .AND. !fz3->(EOF())
                        //蹍絎� �� ����瘴� fz3, 瓣錻���覓 � 皀�竕ォ ����瘡� fz2
                        SELECT fdopl
                        SEEK fz2->tabn
                        IF .not.FOUND()
                           APPEND BLANK
                           fdopl->tabn := fz2->tabn
                           fdopl->sum := 0
                           fdopl->sumpol := 0
                           fdopl->prc := m_prc
                           fdopl->kass := sp10->kass
                        ENDIF

                        fdopl->sumpol += fz3->sum //������ 痺���

                        //if fz3->kopu>='001'.and.fz3->kopu<='003'
                        if AT(fz3->kopu,m_kopudpl)!=0
                           fdopl->sum := fdopl->sum+fz3->sum //痺��� �� �����, ��
                                                            // ��皰�. ���. ぎ���硅 (���爬�ム 001, 002, 003)
                           fkomp->(DBSEEK(fz2->tabn+fz2->ksash+fz2->brgd))
                           IF .NOT.fkomp->(FOUND())
                              fkomp->(dbappend())
                              fkomp->tabn := fz2->tabn
                              fkomp->ksash := fz2->ksash
                              fkomp->brgd := fz2->brgd
                              fkomp->sum := 0
                              fkomp->sumkmp := 0
                           ENDIF

                           fkomp->sum += fz3->sum //痺��� �� �����, �� ��皰�. ���. ぎ���硅
                                                 // (���爬�ム 001, 002, 003)

                        endif
                        SKIP 1 ALIAS fz3
                     ENDDO
                  ENDIF
               ENDIF
               SKIP 1 ALIAS fz2
            ENDDO
         ENDIF
      ENDIF
      //******************************************************************///

      SELECT fz1
      WorkDisplay(m_proc1, RECNO()/LASTREC()) //�皙モ�� ┃え��皰�� N 1
      SKIP
   ENDDO
   WorkDisplay(m_proc1, 1.00) //���琺皋� ┃え��皰�� N 1

   close fz1                                                               //
   close fz2                                                               //
   close fz3                                                               //

   //���罔��├�罔� ┃え��皰�� N 1////////////////////////////////////////////
   m_proc1 := Workinit ( 8,10,10,70, "�諛�甄キ┘ 痺�� か� ぎ���� �� �ム※膈覓 ぎ�祠キ��� ���" )
   WorkWindow ( m_proc1 )                                                  //
   //****************************////////////////////////////////////////////

   //�皖琺皋� ��щ ����諷 ぎ�祠キ皰� �� ��腮甄キ�� ��////////////////////////
   USE d:\buhgal\bf\fz1 NEW                                                //
   USE d:\buhgal\bf\fz2 NEW                                                //
   USE d:\buhgal\bf\fz3 NEW                                                //
   //************************************************////////////////////////

   SELECT fz1
   GOTO TOP
   DO WHILE ! fz1->( Eof () )
      //����キ┘ ぎ�祠キ皰� N 5 �爬 ��≒�爿�� ���竅�� �牀������//////////////
      //� 皰� Ε �メ閹�//////////////////////////////////////////////////////
      IF fz1->vdoc==5.AND.BuhMonth(fz1->ddoc)==Buhmonth(m_ddoc)            //
         IF pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )                            //
            DO WHILE fz2->vnum1 == fz1->vnum1 .AND. !fz2->(EOF())          //
               //蹍絎え� �� ����瘴� fz2, 瓣錻���覓 � 皀�竕ォ ����瘡� fz1  //
               IF pFilPoz ( 'fz3' , 'vnum2' , 'fz2' )                      //
                  DO WHILE fz3->vnum2 == fz2->vnum2 .AND. !fz3->(EOF())    //
                     fz3->(dbdelete())                                     //
                     fz3->(DBSKIP())                                       //
                  ENDDO                                                    //
               ENDIF                                                       //
               fz2->(DBDELETE())                                           //
               fz2->(DBSKIP())                                             //
            ENDDO                                                          //
         ENDIF                                                             //
         fz1->(dbdelete())                                                 //
         fz1->(dbskip())                                                   //
         LOOP                                                              //
      ENDIF                                                                //
      //*******************************************************//////////////

      //ｯ爛ぅ�キ┘ ������ 痺��� ��腮甄キ┤ � ��爛ぅ�キ┘ 痺��� ��腮甄キ┤///
      //� ��ぎ�  =m_kopudpl=  � ��оェ� ���.���ム�� (���� fdopl.dbf);////////
      //��爛ぅ�キ┘ 痺��� ��腮甄キ┤ � ��ぎ�  =m_kopudpl=  � ��оェ� ���.��-/
      //�ム��+���+�爬���� (���� fkomp.dbf)///////////////////////////////////
      IF BuhMonth ( fz1->ddoc ) == m_month
         IF pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )
            DO WHILE fz2->vnum1 == fz1->vnum1 .AND. !fz2->(EOF())
               //蹍絎� �� ����瘴� fz2, 瓣錻���覓 � 皀�竕ォ ����瘡� fz1
               sp10->(DBSEEK(fz2->tabn))
//               IF fz1->vdoc != 38.AND.sp10->(FOUND()).AND.sp10->kpn<>'4' && �甄� ���.
               IF fz1->vdoc != 38.AND.sp10->(FOUND()).AND.sp10->kpn<>'4'.AND.sp10->kpn<>'6'.AND.sp10->kpn<>'7'  && �甄� ���.
                  && ���ム� �モ � 甎��〓膈┴�  �� 痺���牀��碎
                  && �� 蹣甎�����罔� �≒���爲�
                  IF pFilPoz ( 'fz3' , 'vnum2' , 'fz2' )
                     DO WHILE fz3->vnum2 == fz2->vnum2 .AND. !fz3->(EOF())
                        //蹍絎� �� ����瘴� fz3, 瓣錻���覓 � 皀�竕ォ ����瘡� fz2
                        SELECT fdopl
                        SEEK fz2->tabn
                        IF .not.FOUND()
                           APPEND BLANK
                           fdopl->tabn := fz2->tabn
                           fdopl->sum := 0
                           fdopl->sumpol := 0
                           fdopl->prc := m_prc
                           fdopl->kass := sp10->kass
                        ENDIF

                        fdopl->sumpol += fz3->sum //������ 痺���

                        //if fz3->kopu>='001'.and.fz3->kopu<='003'
                        if AT(fz3->kopu,m_kopudpl)!=0
                           fdopl->sum := fdopl->sum+fz3->sum //痺��� �� �����, ��
                                                            // ��皰�. ���. ぎ���硅 (���爬�ム 001, 002, 003)
                           fkomp->(DBSEEK(fz2->tabn+fz2->ksash+fz2->brgd))
                           IF .NOT.fkomp->(FOUND())
                              fkomp->(dbappend())
                              fkomp->tabn := fz2->tabn
                              fkomp->ksash := fz2->ksash
                              fkomp->brgd := fz2->brgd
                              fkomp->sum := 0
                              fkomp->sumkmp := 0
                           ENDIF

                           fkomp->sum += fz3->sum //痺��� �� �����, �� ��皰�. ���. ぎ���硅
                                                 // (���爬�ム 001, 002, 003)

                        endif
                        SKIP 1 ALIAS fz3
                     ENDDO
                  ENDIF
               ENDIF
               SKIP 1 ALIAS fz2
            ENDDO
         ENDIF
      ENDIF
      //******************************************************************///

      SELECT fz1
      WorkDisplay(m_proc1, RECNO()/LASTREC()) //�皙モ�� ┃え��皰�� N 1
      SKIP
   ENDDO
   WorkDisplay(m_proc1, 1.00) //���琺皋� ┃え��皰�� N 1

   close sp10
   close fdopl
   myedit()
   use d:\buhgal\temp\fdopl new
   index on fdopl->tabn to d:\buhgal\temp\fdopl

   //���罔��├�罔� ┃え��皰�� N 2////////////////////////////////////////////
   m_proc2 := Workinit(14,10,16,70, "��瘍モ 痺�� か� ぎ����")              //
   WorkWindow ( m_proc2 )                                                  //
   //****************************////////////////////////////////////////////

   //ｯ爛ぅ�キ┘ ��Кム� ぎ����//////////////////////////////////////////////
   m_proc1:=0                                                              //
   fdopl->(DBGOTOP())                                                      //
   fkomp->(DBGOTOP())                                                      //
   DO WHILE ! fdopl->( Eof () )                                            //
      //��瘍モ ぎ���� � ��оェ� ���. ���ム�� � ��玻オ罔� ������ 痺��� ���. //
      fdopl->sumdpl:=INT((fdopl->prc*fdopl->sum/100)/0.01)*0.01

	IF fdopl->sumdpl-m_mp < 0
         fdopl->sumpol:=fdopl->sumdpl                                      //
         fdopl->sumdpl:=0                                                  //
	ELSE
         fdopl->sumpol:=m_mp                                               //
         fdopl->sumdpl-=m_mp                                               //
	ENDIF

      m_komp:=fdopl->sumdpl
                                                                           //
      //��瘍モ ����キ��罔� � ��оェ� ���. ���ム��, 荐籥�� ��矗�� � ÷┌��  //
      m_x:=m_komp                                                          //
      m_recno1:=fkomp->(RECNO())                                           //
      DO WHILE fkomp->tabn==fdopl->tabn.AND..NOT.fkomp->(EOF())            //
         IF fdopl->sum<>0 .AND. m_komp<>0                                  //
            fkomp->sumkmp:=INT((fkomp->sum*m_komp/fdopl->sum)/0.01)*0.01   //
            m_x-=fkomp->sumkmp                                             //
         ELSE                                                              //
            fkomp->(DBDELETE())                                            //
         ENDIF                                                             //
         m_recno1:=fkomp->(RECNO())                                        //
         fkomp->(DBSKIP(1))                                                //
      ENDDO                                                                //
      IF m_x<>0 .AND. fdopl->sum<>0  .AND. m_komp<>0                       //
         fkomp->(DBGOTO(m_recno1))                                         //
         fkomp->sumkmp+=m_x                                                //
         fkomp->(DBSKIP(1))                                                //
      ENDIF                                                                //
                                                                           //
      IF fdopl->sumdpl==0 .AND. fdopl->sumpol==0                                                 //
         fdopl->(DBDELETE())                                               //
      ENDIF                                                                //
                                                                           //
      fdopl->(DBskip())                                                    //
      WorkDisplay(m_proc2, (m_proc1++)/fdopl->(LASTREC())) //�皙モ�� ┃え��皰�� N 2
  ENDDO                                                                    //
  WorkDisplay ( m_proc2 , 1.00 ) //���琺皋� ┃え��皰�� N 2                 //
   //**************************//////////////////////////////////////////////

   use d:\BUHGAL\JS\fvnum new

   //�▲ぅ�┘ ���.����薑 �發カ讚覓� ぎ�祠キ���� � ��оェ� ���.���ム��////////
   fdopl->(dbgotop())                                                      //
   do while .not.fdopl->(EOF())                                            //
      fz1->(dbappend())                                                    //
      fz1->npch:=m_npchkmp+(m_month-INT(m_month/10)*10)*100                //
      fz1->ndoc:=VAL(SUBSTR(fdopl->tabn,1,2))                              //
      fz1->vdoc:=5                                                         //
      fz1->ddoc:=m_ddoc                                                    //
      fz1->vnum1:=fvnum->vnum1++                                           //
      do while .not.fdopl->(eof()) .and. fz1->ndoc==VAL(SUBSTR(fdopl->tabn,1,2))
         fz2->(dbappend())                                                 //
         fz2->tabn:=fdopl->tabn                                            //
         fz2->ksash:=m_shpz                                                //
         fz2->vnum1:=fz1->vnum1                                            //
         fz2->vnum2:=fvnum->vnum2++                                        //
         fz3->(dbappend())                                                 //
         fz3->sum:=fdopl->sumpol                                           //
         fz3->vnum2:=fz2->vnum2                                            //
         fz3->kopu:=m_koplkmp                                              //
         fdopl->(dbskip())                                                 //
      enddo                                                                //
   enddo                                                                   //
   //************************************************************////////////

   //�▲ぅ�┘ ぎ����      �發カ讚覓� ぎ�祠キ���� � ��оェ� ���.���ム��///////
   //��� � ÷┌��////////////////////////////////////////////////////////////
   fkomp->(dbgotop())                                                      //
   do while .not.fkomp->(EOF())                                            //
      fz1->(dbappend())                                                    //
      fz1->npch:=m_npchdpl+(m_month-INT(m_month/10)*10)*100                //
      fz1->ndoc:=VAL(SUBSTR(fkomp->tabn,1,2))                              //
      fz1->vdoc:=5                                                         //
      fz1->ddoc:=m_ddoc                                                    //
      fz1->vnum1:=fvnum->vnum1++                                           //
      do while .not.fkomp->(eof()) .and. fz1->ndoc == VAL(SUBSTR(fkomp->tabn,1,2))
         fz2->(dbappend())                                                 //
         fz2->tabn:=fkomp->tabn                                            //
         fz2->ksash:=fkomp->ksash                                          //
         fz2->brgd:=fkomp->brgd                                            //
         fz2->vnum1:=fz1->vnum1                                            //
         fz2->vnum2:=fvnum->vnum2++                                        //
         fz3->(dbappend())                                                 //
         fz3->sum:=fkomp->sumkmp                                           //
         fz3->vnum2:=fz2->vnum2                                            //
         fz3->kopu:=m_kopldpl                                              //
         fkomp->(dbskip())                                                 //
      enddo                                                                //
   enddo                                                                   //
   //*****************************************************************///////

   close fz1                                                               //
   close fz2                                                               //
   close fz3                                                               //
   close fvnum                                                             //
//   close sp10                                                              //
   close fdopl                                                             //
   close fkomp                                                             //

   ferase("d:\buhgal\temp\fdopl.dbf" )                                     //
   ferase("d:\buhgal\temp\fdopl.ntx" )                                     //
   ferase("d:\buhgal\temp\fkomp.dbf" )                                     //
   ferase("d:\buhgal\temp\fkomp.ntx" )                                     //

   SET ESCAPE OFF

   SetColor ( dos_clr )

   SHOWTIME()
   RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_SCREEN)
//   CLS
RETURN .t.

Function myedit()
  LOCAL m_inkey,i,m_browse,m_col,getlist:={},;
        a_col:={{{||field->tabn},"��．�讚覃;  ���ム"},;
                {{||sp10->(dbseek(field->tabn)),;
                    IF(sp10->(FOUND()),;
                       LEFT(ALLTRIM(sp10->fam)+' '+LEFT(sp10->imja,1);
                       +'. '+LEFT(sp10->otch,1)+"."+SPACE(25),25),SPACE(25))},;
                 "���┼��  ���   �砒メ癶� "},;
                {{||SUMtoSTR(field->sum,16)},"    �祠�� ;   �甅�↓��;   ��牆��硅"},;
                {{||field->prc},"蹍罐�� ;��ぁ�→�"},;
                {{||SumToStr(ROUND(field->sum*field->prc/100,0),16)},;
                 "�祠�� ��ぁ�→�"}},m_screen,;
        l_print:={.t.,.t.,.t.,.t.,.t.}

  m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())

  SET SCOREBOARD OFF
  SET DELETE ON
  SET COLOR TO "W+/b,b/w+"
  CLEAR

  USE ("d:\buhgal\sp\sp10") INDEX ("d:\buhgal\sp\sp10") NEW READONLY
  USE ("d:\buhgal\temp\fdopl") NEW
  INDEX ON field->kass+field->tabn to d:\buhgal\temp\fdopl

  SET RELATION TO field->tabn INTO sp10

  m_browse:=TBrowseDB(2,1,MAXROW()-2,MAXCOL()-1)
  DISPBOX( 1, 0, MAXROW()-1, MAXCOL(), B_DOUBLE + " " )

  FOR i:=1 TO LEN(a_col)
     m_Col           := TBColumnNew()
     m_Col:colorblock:=  {|| {1,2}}
     m_Col:headsep    := "�"
     m_Col:colsep     := "�"
     m_col:heading    := a_col[i,2]
     m_col:block      :=a_col[i,1]
     m_browse:addColumn( m_col )
  NEXT

  m_browse:colorspec     := 'w+/b,b/w+,B/W,G/Y,N/R'
  m_browse:colsep        := '�'
  m_browse:SkipBlock     := { |n| SkipOrder(n) }
  m_browse:goBottomBlock := { ||  DBGOBOTTOM()  }
  m_browse:goTopBlock    := { ||  DBGOTOP()  }

  SET CURSOR OFF
  m_browse:right()
  m_browse:right()
  m_browse:right()

  @MAXROW(),0 SayDisp "                       ENTER - �甎��←キ┘    F2 - �ョ�碎                       " COLOR "b/w"

  DO WHILE .t.
     STABILIZE BROWSE m_browse
     m_browse:colorRect({m_browse:rowPos,1,m_browse:rowPos,m_browse:ColCount},{2,2})
     m_inkey:=INKEY(0)
     DO CASE
        CASE m_inkey == K_DOWN           ; m_browse:down()
//        CASE m_inkey == K_CTRL_END       ; m_browse:panend()
//        CASE m_inkey == K_CTRL_HOME      ; m_browse:panhome()
        CASE m_inkey == K_UP             ; m_browse:up()
        CASE m_inkey == K_PGDN           ; m_browse:pagedown()
        CASE m_inkey == K_PGUP           ; m_browse:pageup()
        CASE m_inkey == K_CTRL_PGUP      ; m_browse:gotop()
        CASE m_inkey == K_CTRL_PGDN      ; m_browse:gobottom()
        CASE m_inkey == K_F10      ; Calc()
        CASE m_inkey == K_F2
             OpenPrn("PRN")
             PrintBrowse(@m_browse,@l_print)
             ClosePrn()
        CASE m_inkey == K_ENTER
//          m_browse:colorRect({m_browse:rowPos,4,m_browse:rowPos,4},{2,2})
             STABILIZE BROWSE m_browse
             SET CURSOR ON
             @ROW(),COL() GET field->prc COLOR "GR+/n"
             READ
             SET CURSOR OFF
        CASE m_inkey == K_ESC .AND. AskUser( , "   ��▲琥�碎 ��｀矣 ?   " )
             EXIT
     ENDCASE
     m_browse:refreshCurrent()
  ENDDO

  CLOSE FDOPL
  CLOSE SP10
  RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_SCREEN)

RETURN .t.


Function SUMtoSTR(x,m_len)
  LOCAL m_str:="",s:=STR(ABS(x),18,2),i

//  if x==0
//     return ""
//  endif
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
  m_str+=IF(substr(s,17,2)=='00',"","-"+substr(s,17,2))
  IF x<0
     m_str:="-"+m_str
  ENDIF
  IF m_len<>NIL.AND.m_len>0
     m_str:=IF(LEN(m_str)>m_len,REPLICATE("*",m_len),PADL(m_str,m_len))
  ENDIF

RETURN m_str


STATIC FUNCTION SkipOrder( n )
  LOCAL  ncount  := 0

  IF n > 0
     DO WHILE ncount < n
        DBSKIP()
        // �甄� ���ユ �����
        IF EOF()
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


FUNCTION BegInit ()

   LOCAL SwapingSpace := 3          // ����腑痰〓 瓣�｀き��� �牀痰���痰��
                                     // �� え瓷� � �������, �ギ≦�え��� か�
                                     // ��｀硅 ��� "�竇���皀�"

   // ----------------------------------------------------
   // --- ����H��K� ����������, ����� ��� ���� ������� ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor ( SC_NONE )

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )

   SET CENTURY       OFF
   SET DATE          BRITISH

   CLEAR SCREEN

// -------------------------------------
// --- ��'����H�� �H��H�� ������HH�� ---
// -------------------------------------
   PUBLIC   p_help_code  := 0                     // �����モ� か� 蹣������� HELP
   PUBLIC   txt_clr      := 'bg+/b,n/bg'          // �甅�↓�� 罌モ 瓱�〓���
   PUBLIC   msg_clr      := 'gr+/r'               // 罌モ 甌�♂キ┤ �� �荐！��
   PUBLIC   msg_mig_clr  := 'gr+*/r'              // 罌モ 甌�♂キ┤
                                                  // �� �荐！�� � �ム���┘�
   PUBLIC   msg1_clr     := 'w+*/bg'              // 罌モ 甌�♂キ┤ � �ム���┘�
   PUBLIC   box_clr      := 'w/b'                 // 罌モ ����� � �.�.
   PUBLIC   hlp_clr      := 'n/w,gr+/w'           // 罌モ 甎��〓� ( help'� )
   PUBLIC   psw_clr      := 'w+/bg,n/n'           // 罌モ ��牀��
   PUBLIC   hello_clr    := 'gr+/b'               // 罌モ �°膈��� �爬▲矚癶��
   PUBLIC   head_clr     := 'r+/b'                // 罌モ �����讚�� ��痰�→�
   PUBLIC   dos_clr      := SetColor ()           // 罌モ MS-DOS
   PUBLIC   str_clr      := 'w+/n'                // 罌モ
   PUBLIC   mnu_clr      := 'w+/b,n/w'            // 罌モ �キ�
   PUBLIC   ten_clr      := 'w/n'                 // 罌モ 皀��
   PUBLIC   phn_clr      := 'n/w'                 // 罌モ 筮��
   PUBLIC   vvod_clr     := 'w+/b,gr+/n,,,w+/b'   // 罌モ 蹣���� □���-�襤���
   PUBLIC   vvod_mig_clr := 'w+*/b,gr+/n,,,w+/b'  // 罌モ 蹣���� □���-�襤���
                                                  // � �ム���┘�
   PUBLIC   hello1_clr   := 'w+/bg,w+/n'          // 罌モ �爬 □�ぅ ��硅
   PUBLIC   poisk_clr    := 'gr+/bg'              // 罌モ ����� ���� ���牀��
                                                  // �爬 ���瓷� � �ムュ�ぅ
   PUBLIC   hl_clr       := 'n/w,gr+/n'           // 罌モ �襪カキ���� �祗���
                                                  // �爬 蹣������ □�ぅ-�襤�ぅ

   PUBLIC   m_dbspath   := ''              // ������� � 皀�竕ォ ��
//   PUBLIC   m_bufpath   := 'd:\buhgal\bf'  // ������� � ＜筌爿�� ��
//   PUBLIC   m_mainpath  := 'd:\buhgal\mn'  // ������� � �甅�↓�� ��
//   PUBLIC   m_sprpath   := 'd:\buhgal\sp'  // ������� 甌 甎��〓膈┴���
   PUBLIC   m_exepath   := 'd:\buhgal\bh'  // ������� か� .EXE ��ゃ�� ���モ�
//   PUBLIC   m_mash      := 'd:\buhgal\ms'  // ������� か� ��荐�������
   PUBLIC   m_syspath   := 'd:\buhgal\js'  // ������� �  瓱痰ガ��� ┃筮爼�罔ォ
   PUBLIC   m_copypath  := 'd:\buhgal\cp'  // ������� か� ���┤

   PUBLIC m_sysparol := 'SYSTEM    '    // --- ��牀�� �が┃�痰��皰�� 瓱痰ガ�
   PUBLIC m_parol    := ' '             // --- ��牀�� 皀�竕ィ� ���讌���皀��
   PUBLIC m_oper     := ' '             // --- ��� ��ム�皰�� ( ���讌���皀�� )
   PUBLIC m_tabn     := ' '      // --- ��．�讚覃 N ��ム�皰�� ( ���讌���皀�� )

   PUBLIC m_pol   := ' '         // --- "覃" ┼� "��"
   PUBLIC m_imja  := ' '         // --- ━�-�砒メ癶� ���讌���皀��

   USE &m_syspath\sovhoz NEW
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- ��━キ����┘ �爛く爬閧��
   USE

   USE &m_syspath\printer NEW
   PUBLIC m_printer := printer->printer         // --- 皋� �爬�皀��:
   PUBLIC m_endpage :=IF(ASCAN(printer->(DBSTRUCT()),{|P|UPPER(p[1])=='ENDPAGE'})<>0,PRINTER->ENDPAGE,64) // --- ��Кム 痰����肓
   USE                                          //     0 - CPF
                                                //     1 - Geniprint
                                                //     2 - Hyundai

   PUBLIC p_paket   := '��� "�竇���皀�"'      // --- ��Б��┘ ���モ�

   PUBLIC m_date    := Date ()                // --- 瓱痰ガ��� ( 皀�竕�� ) ����
   PUBLIC m2_date   := '  /  /   '

   PUBLIC m_vdoc    := 0                      // --- ※� ぎ�祠キ��
   PUBLIC m_npch    := 0                      // --- ���ム ��腦�
   PUBLIC m_ndoc    := 0                      // --- N ぎ�祠キ��
   PUBLIC m_imjadoc := ''                     // --- ��Б��┘ ぎ�祠キ��

   PUBLIC i := 0

   PUBLIC dbms := 'c'      // --- �┓ ����: 'd3+'- dBASE III Plus,
                           // --- 'd4' - dBASE IV,'f'-FoxBASE,'c'- Clipper,

   PUBLIC pr_proc       := ''     /* ━� ���竅��ガ�� �牀罐ゃ琺 */
   PUBLIC pr_vvod       := ''     /* ━� �牀罐ゃ琺 □��� */
   PUBLIC pr_prosmotr   := ''     /* ━� �牀罐ゃ琺 �牀甃�矗� */
   PUBLIC pr_korrect    := ''     /* ━� �牀罐ゃ琺 �甎��←キ�� */
   PUBLIC pr_print      := ''     /* ━� �牀罐ゃ琺 �ョ�皋 */
   PUBLIC par1_proc     := ''     /* 甎�甌� ���-牀� ���竅��ガ�� �牀罐ゃ琺 */
   PUBLIC par1_vvod     := ''     /* 甎�甌� ���-牀� �牀罐ゃ琺 □��� */
   PUBLIC par1_prosmotr := ''     /* 甎�甌� ���-牀� �牀罐ゃ琺 �牀甃�矗� */
   PUBLIC par1_korrect  := ''     /* 甎�甌� ���-牀� �牀罐ゃ琺 �甎��←キ�� */
   PUBLIC par1_print    := ''     /* 甎�甌� ���-牀� �牀罐ゃ琺 �ョ�皋 */

   PUBLIC menu_screen  := ''  // �ムガキ��� か� 甌縲��キ�� 蹣���� �キ�
   PUBLIC kol_menu     := 25  // ����腑痰〓 �キ�
   PUBLIC kol_zap_menu := 1   // ����腑痰〓 �祗�皰� � ��皋↓�� �キ�
   PUBLIC max_kol_zap  := 40  // ���瓱���讚�� ����腑痰〓 �祗�皰� � ��皋↓�� �キ�
   PUBLIC left         := 2   // �-���爐┃��� �ア. ▲璢�. 磽�� ���� � �キ�
   PUBLIC top          := 1   // �-���爐┃��� �ア. ▲璢�. 磽�� ���� � �キ�
   PUBLIC hl_file      := ''  // ━� ��皋※Ж珮ガ��� �����

   PUBLIC highlight [ kol_menu ]     // ��瘁│ ���ム�� �襪カキ�諷
      Afill ( highlight , 1 )        // �祗�皰� 〓 ≡ュ �キ�

   PUBLIC menu_highlight [kol_menu]  // ��瘁│ ��Б��┤ �キ�

   // �牀▲爲� ����腮� 瓣�｀き��� �牀痰���痰�� �� え瓷�

RETURN ( NIL )
