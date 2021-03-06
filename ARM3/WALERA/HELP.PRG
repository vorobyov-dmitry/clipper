#include    "wal.ch"
#include    "achoice.ch"

#define      LIMIT       "$"                  // ��㦥��� ࠧ����⥫�
#define      MAX_WIDTH   200                  // ��ਭ� ��ப� 䠩��
#define      SIZE_BUF    60000                // ������ ����

#define      NAME_MENU   "helpmenu.dbf"       // ��� 䠩�� help ����
#define      NAME_NTX    "help.dbf"            // ��� �����᭮�� 䠩�� ��� help
#define      NAME_HELP   "help.txt"            // ��� ��⮢��� help 䠩��

#define      MEN_TEXT     1                   // ���� ⥪�� ����
#define      MEN_NUM      2                   // ���� ����� ����樨 ����
#define      NTX_NUM      1                   // ���� ����� ����樨 䠩��
#define      NTX_POS      2                   // ���饭�� �� 䠩��
#define      NTX_SIZE     3                   // ������ ���㬥�� � �����

#define      H_T          2                    // ���न���� ���  HELP
#define      H_L          4
#define      H_B          22
#define      H_R          74
#define      Y_MSG        11                   // ��ப� ��� �뢮�� ᮮ�饭��

#define      BEEP_ERR     TONE(125, 0)
#define      BEEP_ASK     TONE(3000, 0)
// #define      N_BOX_1      "�Ŀ���Ƴ "
// #define      N_BOX_2      "�͵���Ƴ "
// #define      N_BOX_3      "�͵����� "

#define      N_BOX_1      "�ͻ���Ǻ "
#define      N_BOX_2      "�Ķ���Ǻ "
#define      N_BOX_3      "�Ķ���Ⱥ "
#define      N_BOX_4      "�ͻ���Ⱥ "


// The elements in aTab
#define      TB_ROWTOP         1
#define      TB_COLTOP         2
#define      TB_ROWBOTTOM      3
#define      TB_COLBOTTOM      4
#define      TB_COLOR_1        5
#define      TB_COLOR_2        6
#define      TB_POSITION       7

#define      TB_ELEMENTS       7

// The Up and Down arrows, highlight and background char's for the thumb tab
#define      TB_UPARROW       ''
#define      TB_DNARROW       ''
#define      TB_HIGHLIGHT     '�'
#define      TB_BACKGROUND    '�'

#define      CR               CHR(13)

#define      POS_EXIT         1
#define      POS_INDEX        2

#define      MSG_HEAD         " ������ "
#define      MSG_WAIT         "��� �㦭� ࠧ��� �����"
#define      MSG_EXIT         " ��室 �� ����� "
#define      MSG_INDEX        " ���������� ࠧ����� ����� "
#define      MSG_KEY          " ��ᬮ�� : "+CHR(24)+" "+CHR(25)+" <PgUp> <PgDn>       ���������� : <F1> "

STATIC       a_menu     := 0                   // ����� 䠩�� help ����
STATIC       a_ntx      := 0                   // ����� ���. help 䠩��
STATIC       s_han_help := 0                   // ��ࠡ��稪 help .TXT

STATIC       s_menu_txt := {}                  // ����� ����
STATIC       s_menu_num := {}                  // ����� ����権 ����
STATIC       s_all_num                         // �ᥣ� ����権 ����
STATIC       s_buf_txt                         // ���� ��� ⥪��
STATIC       s_all_str                         // ������⢮ ��ப � ⥪�饩
                                               //   ���樨 ⥪��
STATIC       s_bar                             // ���ᨢ ��� SCROLL BAR

STATIC       s_pos_menu := POS_EXIT            // ������ � ���� HELP


// STATIC       s_path_help :=  "d:\buhgal\nf\"

STATIC       clr_help   :=  "w+/bg,w+/bg,,,w+/bg"
STATIC       clr_bar    :=  "w+/n"
STATIC       clr_view_msg := "n/bg"
STATIC       clr_msg    :=  "w+/bg"
STATIC       clr_menu_ind := "w+/bg,n/w,,,w+/bg"
STATIC       clr_head   := "gr+/bg"

MEMVAR       p_help_code,m_syspath

/*
function Main()

  PUBLIC    p_help_code := 4

  wait

return NIL
*/



FUNCTION     Help(name_proc, num_line, name_var)

LOCAL    m_clr, m_scr, m_cur, x, y, m_sel, old_code, i, old_block
STATIC   l_bus := .T.          // ���� �室� � HELP
STATIC   l_init := .T.         // ���樠����樨 ���� �� �� �뫮

IF( !l_bus ) ; RETURN  NIL ; END

l_bus := .F.
m_clr := SETCOLOR(clr_help)
m_scr := SAVESCREEN(0, 0, 24, 79)
m_cur := SETCURSOR(0)
x := COL()
y := ROW()
m_sel := SELECT()
old_code := p_help_code
old_block := SETKEY(K_F1, NIL)
  // �᫨ �宦����� ���� ࠧ, ���樠�����㥬 ���� �����
  IF( l_init )
    l_init := .F.
    // ���⠫� ���� � ���ᨢ
    pInitHelp()
  END
// ���뢠�� ������� 䠩� � 䠩� �����
pInitFile()

IF( VALTYPE(p_help_code) == "N")
   // �饬 ����室��� ��᮪
   IF( pGotoPos(p_help_code))
     IF(pViewHelp() == POS_INDEX)
        i := IF(( i := ASCAN(s_menu_num, p_help_code)) == 0, 1, i)
        // ���� ���� ࠧ����� <-> ������ �� ࠧ����
        WHILE(.T.)
          i := pMenuIndex(H_T, H_L, H_B, H_R, i)
          // ��室 �� ���� ����������
          IF(i == 0)
            EXIT
          END
          p_help_code := s_menu_num[i]
          IF( ! pGotoPos(p_help_code))
            // �� ��褨 ��࠭�� �㭪�
            WaitMessage("p_help_code =" + LTRIM(STR(p_help_code)) + " �� �������� ...")
            LOOP
          END
          IF(pViewHelp() != POS_INDEX)
            // ��室 �� ���� ����������
            EXIT
          END
        END

     END
   ELSE
     WaitMessage("p_help_code =" + LTRIM(STR(p_help_code)) + " �� �������� ...")
   END
ELSE
  WaitMessage("p_help_code  �� �����祭 ...")
END

// ����뢠�� ��᫥ ᥡ� 䠩��
pCloseFile()
p_help_code := old_code
SELECT(m_sel)
SETPOS(y, x)
SETCURSOR(m_cur)
SETCOLOR(m_clr)
RESTSCREEN(0, 0, 24, 79, m_scr)
SETKEY(K_F1, old_block)
l_bus := .T.

RETURN  NIL



STATIC FUNCTION    pViewHelp()

LOCAL    msg, m_clr := SETCOLOR(clr_help), m_ret := POS_EXIT, i

  // ��⥬ �㦭� ��᮪ ⥪��
  IF( pReadDoc())
     @H_T, H_L, H_B, H_R BOX B_DOUBLE+" " COLOR "gr+/BG"
     @   H_T+2, H_L, H_B-2, H_R   BOX   N_BOX_2
     SETCOLOR(clr_view_msg)
      // �饬 ��������� � 䠩�� ����
      i := IF(( i := ASCAN(s_menu_num, p_help_code)) == 0, 0, i)
      msg := IF(i == 0, "", ALLTRIM(s_menu_txt[i]) )
      msg := IF(LEN(msg) > H_R-H_L-4, LEFT(msg, H_R-H_L-4), msg)
      SETPOS(H_T+1, H_L + ROUND((H_R - H_L - LEN(msg))/2,0) )
      DISPOUT(msg)
      msg := MSG_KEY
      SETPOS(H_B-1, H_L + ROUND((H_R - H_L - LEN(msg))/2,0) )
      DISPOUT(msg)
     SETCOLOR(clr_head)
      msg := MSG_HEAD
      SETPOS(H_T, H_L + ROUND((H_R - H_L - LEN(msg))/2,0) )
      DISPOUT(msg)
     SETCOLOR(clr_help)
     s_bar := ScrollBarNew(H_T+3, H_R, H_B-3, clr_help, clr_bar, 1)
     ScrollBarDisplay(s_bar)
     ACHOICE( H_T+3, H_L+1, H_B-3, H_R-1, s_buf_txt, .T., "pHKeyAch")
       //  �ॡ���� �뢮� ����������
       IF(s_pos_menu == POS_INDEX)
         s_pos_menu := POS_EXIT
         m_ret := POS_INDEX
       END
     s_bar := {}
  END
  SETCOLOR(m_clr)

RETURN( m_ret )



STATIC FUNCTION    pInitHelp()

LOCAL    i, m_sel := SELECT(), del := SET(_SET_DELETED,.T.)
NET USE (m_syspath + NAME_MENU)   NEW  READONLY
 // ����쪮 � ���� �㭪⮢ ?
 s_all_num := 0
 dbeval({||s_all_num++},{||.t.})
 DbGoTop()
 s_menu_txt := ARRAY(s_all_num)
 s_menu_num := ARRAY(s_all_num)
   // ���� �� �ᥬ ������
   FOR   i := 1   TO   s_all_num
     // ��⠥� ⥪�� ����
     s_menu_txt[i] := FIELDGET(MEN_TEXT)
     // ��⠥� ����� ����樨 ����
     s_menu_num[i] := FIELDGET(MEN_NUM)
     SKIP   1
   NEXT
 // ����뢠�� 䠩� ����
 CLOSE
 SELECT(m_sel)
 SET(_SET_DELETED,del)
 // ���� ��頥� ⮫쪮 ���� ࠧ  !!!
 s_buf_txt := {}
 s_all_str := 0
RETURN NIL



STATIC FUNCTION     pInitFile()

 // ���뢠�� ������� 䠩�
NET  USE(m_syspath +  NAME_NTX)    NEW  READONLY
 a_ntx := SELECT()
 // ���뢠�� ⥪�⮢� 䠩� HELP
 s_han_help := FOPEN(m_syspath+ NAME_HELP, FO_READ)
 // ��堥� ��६����
 s_bar := {}

RETURN  NIL



STATIC FUNCTION     pCloseFile()

 // ����뢠�� 䠩��
 CLOSE(a_ntx)
 FCLOSE(s_han_help)
 // ��堥� ��६����
 a_menu := a_ntx := s_han_help := 0
 s_pos_menu := POS_EXIT

RETURN NIL



STATIC FUNCTION     pGotoPos( num_pos )

LOCAL     file_pos, m_sel := SELECT(), l_rez := .F.

SELECT(a_ntx)
 // �饬 ����� �� ������ � �����᭮� 䠩��
 LOCATE   FOR   FIELDGET(NTX_NUM) = num_pos
   IF( FOUND())
      l_rez := .T.
      // ���⠫� ᬥ饭�� � ���. 䠩��
      file_pos := FIELDGET(NTX_POS)
      FSEEK(s_han_help, file_pos, FS_SET)
   END
SELECT(m_sel)

RETURN( l_rez )




STATIC FUNCTION     pReadDoc()

LOCAL    m_buf_read, m_len, n := 1, l_ret := .F.
STATIC   old_num_help := -1000

IF( p_help_code != old_num_help )
  pSayMsg(Y_MSG, MSG_WAIT)
  // ��⠥� ����� �����
  old_num_help := p_help_code
  // ��⠥� ࠧ��� ���㬥��
  m_len := (a_ntx) -> (FIELDGET(NTX_SIZE))
  m_buf_read := SPACE( --m_len )
  FREAD(s_han_help, @m_buf_read, m_len)
   // �᫨ ������ �� �㤠, ����력�
   IF( SUBSTR(m_buf_read, 1, 1) == LIMIT )
        // ��१��� ��砫� ���㬥��
        WHILE( SUBSTR(m_buf_read, 1, 1)  $  (LIMIT+"0123456789") )
           m_buf_read := SUBSTR(m_buf_read, 2)
        END
      // ��ନ�㥬 ��室��� ���ᨢ
      s_all_str := 0
      s_buf_txt := {}
        // ���� ���祭�� ��ப
        WHILE( n != 0 )
          n := AT(CR, m_buf_read)
          AADD(s_buf_txt, " " + LEFT(m_buf_read, n - 1))
          m_buf_read := SUBSTR(m_buf_read, n+2)
          s_all_str++
        END
      l_ret := .T.
   ELSE
     m_buf_read := ""
     s_all_str  := 0
   END
  pSayMsg(Y_MSG, NIL)
ELSE
  // ��� HELP 㦥 ���� � �����
  l_ret := .T.
END

RETURN( l_ret )



FUNCTION     pHKeyAch(mode, n, row)

LOCAL    m_key, m_ret := AC_CONT
STATIC   l_process := .F.

m_key := LASTKEY()

  DO CASE
    CASE  (m_key == K_F1)
      // �� ����⨨  <F1> - ���� ࠧ�����
      m_ret := AC_SELECT
      s_pos_menu := POS_INDEX

    CASE  (m_key == K_ESC)
      m_ret := AC_ABORT
      s_pos_menu := POS_EXIT

    CASE   (m_key == K_UP)
      IF( l_process )
        l_process := .F.
      ELSE
        IF(row != 0)
          KEYBOARD  CHR(K_CTRL_HOME) + CHR(K_UP)
          l_process := .T.
        END
      END

    CASE   (m_key == K_DOWN)
      IF( l_process )
        l_process := .F.
      ELSE
        IF(row != H_B - H_T - 6)
          KEYBOARD  CHR(K_CTRL_END) + CHR(K_DOWN)
          l_process := .T.
        END
      END

    CASE   (m_key == K_HOME)
      KEYBOARD  CHR(K_CTRL_PGUP)

    CASE   (m_key == K_END)
      KEYBOARD  CHR(K_CTRL_PGDN)

    CASE   (m_key == K_ENTER)
      m_ret := AC_SELECT

  ENDCASE

 s_bar := ScrollBarUpdate(s_bar, n, s_all_str, .F.)

RETURN( m_ret )



/***
*  ScrollBarNew( <nTopRow>, <nTopColumn>, <nBottomRow>,
*     <cColorString>, <cColorArrow>, <nInitPosition> ) --> aScrollBar
*
*  Create a new scroll bar array with the specified coordinates
*
*/
STATIC FUNCTION  ScrollBarNew( nTopRow, nTopColumn, nBottomRow, ;
                        cColorString, cColorArrow, nInitPosition )

   LOCAL aScrollBar := ARRAY( TB_ELEMENTS )

   aScrollBar[ TB_ROWTOP ]    := nTopRow
   aScrollBar[ TB_COLTOP ]    := nTopColumn
   aScrollBar[ TB_ROWBOTTOM ] := nBottomRow
   aScrollBar[ TB_COLBOTTOM ] := nTopColumn

   aScrollBar[ TB_COLOR_1 ]     := cColorString
   aScrollBar[ TB_COLOR_2 ]     := cColorArrow

   // Set the starting position
   IF nInitPosition == NIL
      nInitPosition := 1
   END
   aScrollBar[ TB_POSITION ]  := nInitPosition

RETURN aScrollBar

/***
*  ScrollBarDisplay( <aScrollBar> ) --> aScrollBar
*  Display a scoll bar array to the screen
*
*/
STATIC FUNCTION  ScrollBarDisplay( aScrollBar )
   LOCAL cOldColor, nRow, x := COL(), y := ROW()

   // ���� ��५�祪
   cOldColor := SETCOLOR( aScrollBar[ TB_COLOR_2 ] )

   // Draw the arrows
   SETPOS( aScrollBar[ TB_ROWTOP ], aScrollBar[ TB_COLTOP ] )
   DISPOUT( TB_UPARROW )
   SETPOS( aScrollBar[ TB_ROWBOTTOM ], aScrollBar[ TB_COLBOTTOM ] )
   DISPOUT( TB_DNARROW )

   SETCOLOR( aScrollBar[ TB_COLOR_1 ] )
   // Draw the background
   FOR nRow := (aScrollBar[ TB_ROWTOP ] + 1) TO (aScrollBar[ TB_ROWBOTTOM ] - 1)
      SETPOS( nRow, aScrollBar[ TB_COLTOP ] )
      DISPOUT( TB_BACKGROUND )
   NEXT

  SETPOS(aScrollBar[TB_ROWTOP] + aScrollBar[TB_POSITION], aScrollBar[TB_COLTOP])
  DISPOUT( TB_HIGHLIGHT )

  SETCOLOR( cOldColor )
  SETPOS(y, x)

RETURN aScrollBar


/***
*  ScrollBarUpdate( <aScrollBar>, <nCurrent>, <nTotal>,
*     <lForceUpdate> ) --> aScrollBar
*
*  Update scroll bar array with new tab position and redisplay tab
*
*/
STATIC FUNCTION  ScrollBarUpdate( aScrollBar, nCurrent, nTotal, lForceUpdate )

   LOCAL cOldColor, nNewPosition, x := COL(), y := ROW()
   LOCAL nScrollHeight := (aScrollBar[TB_ROWBOTTOM] - 1) - ;
         (aScrollBar[TB_ROWTOP])

   IF nTotal < 1
      nTotal := 1
   END
   IF nCurrent < 1
      nCurrent := 1
   END
   IF nCurrent > nTotal
      nCurrent := nTotal
   END
   IF lForceUpdate == NIL
      lForceUpdate := .F.
   END

   cOldColor := SETCOLOR( aScrollBar[ TB_COLOR_1 ] )

   // Determine the new position
   nNewPosition := ROUND( (nCurrent / nTotal) * nScrollHeight, 0 )

   // Resolve algorythm oversights
   nNewPosition := IF( nNewPosition < 1, 1, nNewPosition )
   nNewPosition := IF( nCurrent == 1, 1, nNewPosition )
   nNewPosition := IF( nCurrent >= nTotal, nScrollHeight, nNewPosition )

   // Overwrite the old position (if different), then draw in the new one
   IF nNewPosition <> aScrollBar[ TB_POSITION ] .OR. lForceUpdate
      SETPOS( (aScrollBar[ TB_POSITION ] + aScrollBar[ TB_ROWTOP ]), ;
         aScrollBar[ TB_COLTOP ] )
      DISPOUT( TB_BACKGROUND )
      SETPOS( nNewPosition + aScrollBar[ TB_ROWTOP ], aScrollBar[ TB_COLTOP ] )
      DISPOUT( TB_HIGHLIGHT )
      aScrollBar[ TB_POSITION ] := nNewPosition
   ENDIF

   SETCOLOR( cOldColor )
   SETPOS(y, x)

RETURN aScrollBar



STATIC FUNCTION    pSayMsg( m_y1, m_prompt )

LOCAL    m_color, m_len
STATIC   m_x1, m_y2, m_x2, m_buf := NIL

IF( VALTYPE(m_prompt) == "C")
  m_color := SETCOLOR(clr_msg)
  m_y2 := m_y1 + 2
  m_len := LEN(m_prompt)
  m_x1 := INT( (79 - m_len) / 2)
  m_x2 := m_x1 + m_len + 2
  m_x1--
  m_buf := SAVESCREEN(m_y1, m_x1, m_y2 + 1, m_x2 + 2)
  @m_y1, m_x1, m_y2, m_x2  BOX B_DOUBLE+" " COLOR (clr_msg)
  SETPOS(m_y1 + 1, m_x1 + 2)
  DISPOUT(m_prompt)
  SETCOLOR(m_color)
ELSE
  IF(m_buf != NIL)
    RESTSCREEN(m_y1, m_x1, m_y2 + 1, m_x2 + 2, m_buf)
  END
  m_buf :=  m_x1 := m_y2 := m_x2 := NIL
END

RETURN   NIL



STATIC FUNCTION     pMenuIndex(m_y1, m_x1, m_y2, m_x2, m_alt)

LOCAL   m_ret, m_clr, msg := MSG_INDEX

m_clr := SETCOLOR(clr_menu_ind)
@m_y1, m_x1, m_y2, m_x2  BOX B_DOUBLE+" " COLOR (clr_menu_ind)

SETCOLOR(clr_head)
 SETPOS(m_y1, m_x1 + ROUND((m_x2 - m_x1 - LEN(msg))/2, 0) )
 DISPOUT(msg)

 s_bar := ScrollBarNew(H_T+1, H_R, H_B-1, clr_help, clr_bar, 1)
 ScrollBarDisplay(s_bar)

SETCOLOR(clr_menu_ind)
m_ret := ACHOICE(m_y1+1, m_x1+2, m_y2-1, m_x2-2, s_menu_txt, .T., "IndKeyAch", m_alt, 1)
SETCOLOR(m_clr)

RETURN( m_ret )



FUNCTION    IndKeyAch(mode, n, row)

LOCAL    m_key, m_ret := AC_CONT

m_key := LASTKEY()

IF (m_key == K_ESC)
      m_ret := AC_ABORT
ELSEIF (m_key == K_ENTER)
      m_ret := AC_SELECT
ELSEIF (m_key == K_HOME)
      KEYBOARD  CHR(K_CTRL_PGUP)
ELSEIF (m_key == K_END)
      KEYBOARD  CHR(K_CTRL_PGDN)
END

s_bar := ScrollBarUpdate(s_bar, n, s_all_num, .F.)

RETURN( m_ret )
