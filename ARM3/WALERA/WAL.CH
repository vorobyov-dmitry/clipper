//
//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
//� ��ゃ��: WAL.CH
//� �≒��: ����ぅp �. �.
//� ���� 甌Г����: 15-10-91.
//� 踸�ョ����:  ���� ������→�
//藩様様様
//

#include "set.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"
#include "dbstruct.ch"
#include "dbedit.ch"
#include "fileio.ch"
#include "memoedit.ch"



// ｯ爛ぅ�キ┘ �����モ牀� �� 祠�������.
// 踸�ム:
//       DEFAULT .T. TO lOpen, ;
//                1  TO nPos , ;
//               "A" TO cString
#command DEFAULT <var2> TO <var1> [,<varN> TO <varM>] =>  ;
                                  <var1> := if(<var1> == NIL,<var2>,<var1>) ;
                                  [;<varM> := if(<varM> == NIL,<varN>,<varM>)]

// ������� ≡��→� ����瓱 � 皀�竕ォ �゛�痰�
#command INSERT [WITHOUT <p: PROCESS>] =>    Insert([!<.p.>])

// �≪��〓� 瓱����
#define NO_DOSTUP   TONE(1000,1)

// ��る ���瘁��痰� か� 矗��皰爬痰��
#define M_KLASSTR "018,019"

// ��る ���瘁��痰� か� Θ〓皚�〓ぎ�
#define M_KLASSGV "016,017"

// ��る ���瘁��痰� か� 〓え皀�ォ
#define M_KLASSAV "020,021"

// ��る , �� ��皰琺� ��腮甄錺矚� ���瘁��痰�
#define M_KOPUTR  "001,002,008,052,053"

#define NOTDOC  '���祠キ� �� ��お�鈑キ � 瓱痰ガ�'

// �甎��讌竡矚� 粃��罔ォ WDF_TABLE � SAYWDF
#define ONE_TIME      2048
#define LEN_KEY       4
#define LEN_MARKER    7


#define L_TIME
//#define _L_BRGD

// .T. - ��瘍モ ���瘁��痰� 〓え皀�ォ �≒-き鍖 , ┃�腑 �� ∇ガキ� � ��瑙ぅ
#define L_AVDN  .T.
#ifdef NEW_VER
#translate InitClock ( <var1> , <var2> , <var3>, <var4> , <var5> ) => SHOWTIME(<var3>,<var4>,.F.,"B/W")
#translate DelClock ( ) => SHOWTIME()
#endif
#command NET USE <(db)> [ALIAS <a>] [<new: NEW>] [<ro: READONLY>] [INDEX <(index1)> [, <(indexn)>]]  ;
                                                                        ;
      => dbUseArea(<.new.>,, <(db)>, <(a)>,.t., <.ro.>)                 ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]

#translate  ANSWERu(<m_var>) => ALERT(<m_var>,{"��","�i"},"N/BG,w/b")
#DEFINE  YES 1
#translate DispError(<var>) =>   WaitMessage(<var>,"GR+/R,w+/R",.t.)

#define Wait_Mig() DispMessage("�え皀 ...")
