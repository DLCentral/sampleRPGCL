**free

ctl-opt dftactgrp(*no);

dcl-s mytext char(20);

Dcl-PR printf Int(10) extproc('printf');
  input Pointer value options(*string);
End-PR;

mytext = 'Hello World';
printf(mytext);

dsply mytext;

return;