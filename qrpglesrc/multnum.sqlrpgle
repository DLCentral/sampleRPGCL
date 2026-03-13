**free
ctl-opt NoMain bnddir('INABIND1');

dcl-proc multNum EXPORT;

  // Prototype Definition for multNum
  /define multNum_pr
  /include 'multNum.rpgleinc'

  // Procedure Interface Definition for multNum
  /define multNum_pi
  /include 'multNum.rpgleinc'

  Dcl-s result                  packed(5:0)     inz(0);
  Dcl-s wField1                 packed(5:0)     inz(0);
  Dcl-s wField2                 packed(5:0)     inz(0);       

  wField1 = pValue1;
  wField2 = pValue2;
  result = wField1 * wField2;

  return result;

  *InLR = *on;
End-Proc multNum;