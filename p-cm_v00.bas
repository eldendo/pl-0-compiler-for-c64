10 print " +------------------------------------+"
20 print " !      p-code machine for c-64       !"
30 print " !     (c) 2023 ir. m. dendooven      !"
40 print " +------------------------------------+"
50 print

100 rem *** settings ***
110 ss=10:rem stacksize
120 cs=10:rem code size
130 rem ****************

200 rem *** initialisation ***
210 dim s(ss):rem stack
220 dim cf$(cs-1),cl(cs-1),ca$(cs-1):rem codespace
230 rem **********************

250 gosub 2000: rem testcode

500 print "executing":print
510 sp=4:bp=0:pc=0:rem stackpointer,basepointer,programcounter
520 s(1)=0:s(2)=0:s(3)=0

600 rem *** fetch execute loop *** 
610 cf$=cf$(pc):cl=cl(pc):ca$=ca$(pc)
612 print "pc=";pc;" c=";cf$;cl;ca$
615 pc=pc+1
620 if cf$="lit" then sp=sp+1:s(sp)=val(ca$)
630 if cf$="opr" then gosub 1000
640 if cf$="lod" then stop
650 if cf$="sto" then stop
660 if cf$="call" then stop
670 if cf$="int" then stop
680 if cf$="jmp" then pc=val(ca$)
690 if cf$="jpc" then stop
700 if pc<>0 then 610
710 print:print"done
720 end

1000 rem ** opr **
1005 if ca$="return" then stop
1010 if ca$="neg" then s(sp)=-s(sp)
1020 if ca$="+" then sp=sp-1:s(sp)=s(sp)+s(sp+1)
1030 if ca$="-" then sp=sp-1:s(sp)=s(sp)-s(sp+1)
1040 if ca$="*" then sp=sp-1:s(sp)=s(sp)*s(sp+1)
1050 if ca$="/" then sp=sp-1:s(sp)=s(sp)/s(sp+1)
1060 if ca$="odd" then s(sp)=-(s(sp) and 1)
1080 if ca$="=" then sp=sp-1:s(sp)=s(sp)=s(sp+1)
1090 if ca$="#" then sp=sp-1:s(sp)=s(sp)<>s(sp+1)
1100 if ca$="<" then sp=sp-1:s(sp)=s(sp)<s(sp+1)
1110 if ca$=">=" then sp=sp-1:s(sp)=s(sp)>=s(sp+1)
1120 if ca$=">" then sp=sp-1:s(sp)=s(sp)>s(sp+1)
1130 if ca$="<=" then sp=sp-1:s(sp)=s(sp)<=s(sp+1)
1140 if ca$="?" then sp=sp+1:input s(sp)
1150 if ca$="!" then print s(sp):sp=sp-1
1160 return

2000 rem *** test code ***
2010 pc=0
2020 read cf$(pc),cl(pc),ca$(pc)
2030 if cf$(pc)="end" then return
2040 pc=pc+1
2050 goto 2020

2100 data "lit",0,"?"
2105 data "lit",0,"?"
2107 data "opr",0,"*"
2110 data "opr",0,"!"
2120 data "jmp",0,"0"
2130 data "end",0,"0"





