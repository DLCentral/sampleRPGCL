**free
ctl-opt NoMain bnddir('INABIND1');

dcl-proc addNum EXPORT;

  // Prototype Definition for addNum
  /define addNum_pr
  /include 'addNum.rpgleinc'

  // Procedure Interface Definition for addNum
  /define addNum_pi
  /include 'addNum.rpgleinc'

  Dcl-s result                  packed(5:0)     inz(0);
  Dcl-s wField1                 packed(5:0)     inz(0);
  Dcl-s wField2                 packed(5:0)     inz(0);       

  wField1 = pValue1;
  wField2 = pValue2;
  result = wField1 + wField2;

  return result;

  *InLR = *on;
End-Proc addNum;