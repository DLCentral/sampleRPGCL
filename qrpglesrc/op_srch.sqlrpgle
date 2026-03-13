**free
Ctl-Opt bnddir('INABIND1');
Dcl-f op_srchfm WORKSTN   sfile(S1SFL:S1CurrentRecord)
                          infds(info_DS)
                          IndDS(indicator_DS);

// Prototype Definition for op_srch
/define op_srch_pr
/include 'op_srch.rpgleinc'

// Procedure Interface Definition for op_srch
/define op_srch_pi
/include 'op_srch.rpgleinc'

Dcl-ds indicator_DS;
  PAGEDOWN ind pos(25);
  PAGEUP ind pos(26);
  SFLEND ind pos(40);
  SFLCLR ind pos(50);
  SFLDSP ind pos(51);
  INVALID_OPTION ind pos(60);
  NO_RECORDS ind pos(91);
End-ds;

// Program Status Data Structure
Dcl-ds  pgm_stat  PSDS;
  pgm_name     *PROC;
  pgm_job   char(10) pos(244);
  pgm_user  char(10) pos(254);
End-ds;

Dcl-ds  info_DS;
  FUNCTION_KEY         Char(1)  Pos(369);
End-ds;

/include 'ddsConst.rpgleinc'

Dcl-S  Exit                         Ind             Inz(*Off);
Dcl-s  ScrnId                       char(2)         inz('S1');
Dcl-s  c1open                       ind             inz(*off);

Dcl-c  S1PAGESIZE                   const(12);
Dcl-s  S1TotalRecords               packed(5:0)     inz(*Zeros);
Dcl-s  S1CurrentRecord              packed(5:0)     inz(*Zeros);
Dcl-s  S1RecordInPage               packed(5:0)     inz(*Zeros);
Dcl-s  S1Bld                        char(2)         inz(*Blanks);

Dcl-s  wFilterOpCode                 char(3)           inz(''); 
Dcl-s  wFilterOpDesc                 char(22)          inz(''); 
Dcl-s  wOldP1OpCode                  char(1)           inz(''); 
Dcl-s  wOldP1OpDesc                  char(20)          inz('');
Dcl-s  wOp_Code                     char(1)           inz('');
Dcl-s  wOp_Name                     char(20)          inz(''); 

SFLCLR  = *On;
SFLDSP  = *On;

// Define Program Name
$PGMNAME = pgm_name;

// Get Program Description
$PGMDESC  = 'Search Available Operations';

ScrnId = 'S1';
S1Bld  = *On;

Exit = *OFF;

Dow (Not Exit);

  SELECT;
    WHEN (ScrnId = 'S1');
      ScrnS1();
    OTHER;
      EndPgm();
  ENDSL;

ENDDO;

// *******************************************************************
// SubProcedure to process 1st Screen ( ScrnS1 )
// *******************************************************************

Dcl-Proc ScrnS1;
  IF (S1Bld = *On);
    BldS1();
  ENDIF;

  If (S1CurrentRecord = *Zero);
    NoRecs();
  Endif;

  Write S1WIN;
  Write S1FOOT;
  Exfmt S1CTL;

  INVALID_OPTION  = *Off;

  SELECT;

    WHEN (FUNCTION_KEY = F03);
      EndPgm();
    WHEN (FUNCTION_KEY = F05);
      S1RefreshScreen();
    WHEN (FUNCTION_KEY = F12);
      EndPgm();
    When (PAGEDOWN = *On);  
      S1PageDown();
    When (PAGEUP = *On);    
      S1RedrawScrollPosition();  
    OTHER;
      S1Process();
  ENDSL;
End-Proc;

// *******************************************************************
// SubProcedure to Build Screen 2
// *******************************************************************

Dcl-Proc BldS1;

  SFLCLR  = *On;              // SFLCLR - Subfile Clear

  Write S1CTL;

  SFLCLR = *Off;              // SFLCLR - Subfile Clear
  SFLEND = *Off;              // SFLEND
  SFLDSP = *On;               // SFLDSP - Display Subfile
  NO_RECORDS = *On;           // No records to display

  S1CurrentRecord  = *Zero;
  S1TopRcrd  = 1;
  S1CRRN  = *Zero;
  S1TotalRecords    = *Zero;

  SqlCod  = *Zero;
  closec1();

  wOldP1OpCode = %TRIM(P1OpCode);
  wOldP1OpDesc = %TRIM(P1OpDesc);

  // Set Parameter Values
  wFilterOpCode = '%' + %TRIM(P1OpCode) + '%';
  wFilterOpDesc = '%' + %TRIM(P1OpDesc) + '%';

  // Select records for processing
  EXEC SQL
    DECLARE C1 CURSOR FOR
      SELECT OP_CODE AS OP_CODE, OP_NAME AS OP_NAME
      FROM OPERATIONS
      WHERE UPPER(TRIM(OP_CODE)) LIKE UPPER(TRIM(:wFilterOpCode))
      AND UPPER(TRIM(OP_NAME)) LIKE UPPER(TRIM(:wFilterOpDesc))
      ORDER BY OP_NAME ASC;

  EXEC SQL OPEN C1;
  c1open=*on;

  S1PageDown();

  S1Bld = *Off;
End-Proc;

// *******************************************************************
// SubProcedure to process S1Process
// *******************************************************************

Dcl-Proc S1Process;

  // If filter values have changed, trigger refresh and leave.

  If (P1OpCode <> wOldP1OpCode OR P1OpDesc <> wOldP1OpDesc);
    S1RefreshScreen();
    return;
  Endif;

  Dou (%Eof(op_srchfm));

    Readc S1SFL;

    IF (%Eof(op_srchfm));
      LEAVE;
    ENDIF;

    SELECT;
      WHEN (S1Opt = 'X'); // Select a single record
        wOp_Code = S1OpCode;
        wOp_Name = S1OpDesc;
        EndPgm();
        Iter;
      When (S1Opt <> '');
        S1Opt  = *Blank;
        INVALID_OPTION  = *On;
        Iter;
    ENDSL;

    INVALID_OPTION = *On;
    Update S1SFL;

  ENDDO;

  S1RedrawScrollPosition();

End-Proc;

// **********************************************************************
// SubProcedure to Redraw new Scroll Position ( S1RedrawScrollPosition )
// **********************************************************************

Dcl-Proc S1RedrawScrollPosition;
  IF (S1Scroll > *Zero AND
      S1Scroll <> S1TopRcrd AND
      S1Scroll <= S1CurrentRecord);

    S1TopRcrd    = S1Scroll;
  ENDIF;
End-Proc;

// **********************************************************************
// SubProcedure to Refresh ( S1RefreshScreen )
// **********************************************************************

Dcl-Proc S1RefreshScreen;
  S1Bld  = *On;
  ScrnId = 'S1';
End-Proc;

// **********************************************************************
// SubProcedure to process subfile S1SFL
// **********************************************************************

Dcl-Proc S1PageDown;

  S1RecordInPage = *Zero;
  
  IF (S1TotalRecords > 0);
    S1CurrentRecord = S1TotalRecords;
  ENDIF;

  S1OPT = *BLANK;

  DOW (SQLCOD = *Zero);

    EXEC SQL FETCH NEXT FROM C1 INTO
      :S1OPCODE, :S1OPDESC;
    
    IF (SQLCOD <> *ZERO);
      closec1();
      SQLCOD = *Zero;
      SFLEND = *On;
      LEAVE;
    ENDIF;

    S1CurrentRecord = S1CurrentRecord + 1;
    S1RecordInPage = S1RecordInPage + 1;
    S1TotalRecords   = S1TotalRecords + 1;
    NO_RECORDS = *OFF;

    Write S1SFL;

    IF (S1RecordInPage  = 1 and S1CurrentRecord > S1TopRcrd);
      S1TopRcrd  = S1CurrentRecord;
    ENDIF;

    IF (S1RecordInPage >= S1PAGESIZE);
      return;
    ENDIF;

  ENDDO;

End-Proc;

// **********************************************************************
// SubProcedure to process No Records message for subfile
// **********************************************************************

Dcl-Proc NoRecs;

  S1Opt  = *Blank;

  NO_RECORDS  = *On;
  S1CurrentRecord  = 1;
  S1RecordInPage  = 1;
  SFLEND  = *On;

  Write S1Sfl;

  closec1();
  SqlCod = *Zero;
End-Proc;

// **********************************************************************
// SubProcedure to Close Cursor
// **********************************************************************

Dcl-Proc closec1;
  if (c1open=*on);
    exec Sql Close C1;
    c1open=*off;
  endif;
End-Proc;

// **********************************************************************
// SubProcedure to End Program
// **********************************************************************

Dcl-Proc EndPgm;

  closec1();
  *INLR = *ON;
  Exit = *On;
  op_code = wOp_Code;
  op_name = wOp_Name;
  return;
End-Proc;