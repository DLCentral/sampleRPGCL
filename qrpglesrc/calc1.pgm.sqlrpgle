**free
Ctl-Opt bnddir('INABIND1');
Dcl-f calc1fm WORKSTN infds(info_DS)
                      IndDS(indicator_DS);

Dcl-DS indicator_DS;
  INVALID_OPTION ind pos(60);
End-DS;

// Program Status Data Structure
Dcl-ds  pgm_stat  PSDS;
  pgm_name     *PROC;
  pgm_job   char(10) pos(244);
  pgm_user  char(10) pos(254);
End-ds;

Dcl-DS info_DS;
  FUNCTION_KEY         Char(1)    Pos(369);
End-DS;

/include 'ddsConst.rpgleinc'

// Prototype Definition for addNum
/define addNum_pr
/include 'addNum.rpgleinc'

// Prototype Definition for subNum
/define subNum_pr
/include 'subNum.rpgleinc'

// Prototype Definition for multNum
/define multNum_pr
/include 'multNum.rpgleinc'

// Prototype Definition for divNum
/define divNum_pr
/include 'divNum.rpgleinc'

// Prototype Definition for op_srch
/define op_srch_pr
/include 'op_srch.rpgleinc'

Dcl-s Exit                    Ind               Inz(*Off);
Dcl-s ScrnId                  char(2)           inz(*Blanks);

Dcl-s S1Bld                   char(2)           inz(*Blanks);

Dcl-s Today                   packed(8:0)       inz(*Zeros);
Dcl-s operationCode           char(1)           inz('+');
Dcl-s operationDesc           char(20)          inz('Addition');
Dcl-s result                  packed(5:0)       inz(0);
Dcl-s field1                  packed(5:0)       inz(0);
Dcl-s field2                  packed(5:0)       inz(0);

// *******************************************************************
// Main Processing
// *******************************************************************

// Get Company Nmae
$CMPNAME = '    Dan''s Wonder Emporium';

// Define Program Name
$PGMNAME = pgm_name;

// Get Program Description
$PGMDESC  = 'Simple Calculator';

// Get System Date as Today
EXEC SQL
  SET :Today = DEC(CURRENT DATE);

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

return;

// *******************************************************************
// Subroutine to process 1st Screen ( ScrnS1 )
// *******************************************************************

Dcl-Proc ScrnS1;

  IF (S1Bld = *On);
    BldS1();
  ENDIF;

  Exfmt S1FMT;
  
  INVALID_OPTION  = *Off;

  SELECT;

    WHEN (FUNCTION_KEY = F03);
      EndPgm();

    WHEN (FUNCTION_KEY = F04);
      S1Search();

    WHEN (FUNCTION_KEY = F05);
      S1RefreshScreen();

    WHEN (FUNCTION_KEY = F12);
      EndPgm();

    OTHER;
      S1Process();

  ENDSL;

End-Proc;

// *******************************************************************
// Subroutine to Build Screen 2
// *******************************************************************

Dcl-Proc BldS1;

  // Set field values 
  setFieldValues();

  S1Bld = *Off;
End-Proc;

// *******************************************************************
// Subroutine to process
// *******************************************************************

Dcl-Proc S1Process;

  // GET Field Values
  getFieldValues();

  if (operationCode = '+');
    result = addNum(field1 :field2);
  elseif (operationCode = '-');
    result = subNum(field1 :field2);
  elseif (operationCode = '*');
    result = multNum(field1 :field2);
  elseif (operationCode = '/');
    result = divNum(field1 :field2);
  else;
    INVALID_OPTION = *on;
    return;
  endif;

  // Set field Values
  setFieldValues();
  return;

End-Proc;


// **********************************************************************
// Subroutine to Search
// **********************************************************************

Dcl-Proc S1Search;

  getFieldValues();
  
  SELECT;
    when (csrfld = 'S1OPER');
      op_srch(operationCode :operationDesc);
  endsl;

  S1Bld = *On;
  return;
End-Proc;

// **********************************************************************
// Subroutine to Refresh
// **********************************************************************

Dcl-Proc S1RefreshScreen;
  S1Bld  = *On;
  ScrnId = 'S1';

  // Blank out variables
  field1 = 0;
  field2 = 0;
  operationCode = '';
  result = 0;
  
  // Set field Values
  setFieldValues();
  return;
End-Proc;

// **********************************************************************
// Set Field Values
// **********************************************************************

Dcl-Proc setFieldValues;
  S1NUM1 = field1;
  S1NUM2 = field2;
  S1OPER = operationCode;
  S1RESULT = result;
  S1Bld = *On;
  return;
End-Proc;

// **********************************************************************
// Get Field Values
// **********************************************************************

Dcl-Proc getFieldValues;
  field1 = S1NUM1;
  field2 = S1NUM2;
  operationCode = S1OPER;
  result = S1RESULT;
  return;
End-Proc;

// **********************************************************************
// SubProcedure to End Program
// **********************************************************************

Dcl-Proc EndPgm;
  *INLR = *On;
  Exit = *On;
  return;
End-Proc;