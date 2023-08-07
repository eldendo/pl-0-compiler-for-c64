1 goto 5000
10 ************************************
20 * pl/0 compiler for c64 v0.0       *
30 * (c)2023 by ir. marc dendooven    *
40 * compiler starts at line 5000     *
50 * pl/0 program after this header   *
60 * every line should start with '"' *
70 * do not remove or change header   *
80 ************************************

100" const a=69, prom=138;
110" var b,test;
115"
120" procedure double;
130" begin
140"   !test+test
150" end;
160"
170" begin
180"   !138;
190"   b := prom;
200"   !b; 
210"   test := a;
220"   call double
230" end.

5000 print " +------------------------------------+"
5010 print " !       pl/0 compiler for c64        !"
5020 print " !   (c)2023 by ir. marc dendooven    !"
5030 print " +------------------------------------!"

5100 rem *** compiler settings ***
5110 ea=2384:rem editor address of first '"' in editor
5290 rem *** end of compiler settings

5300 gosub 5500:rem initialisation
5310 gosub 5600:rem getch
5320 gosub 5800:if sy$="." then end
5330 print sy$,
5331 if sy$="id" then print id$;
5332 if sy$="num" then print num;
5333 print
5340 goto 5320

5500 rem *** initialisation ***
5510 print "initialising..."
5520 read nrw
5530 dim rw$(nrw-1)
5530 for i=0 to nrw-1: read rw$(i):next
5590 return

5600 rem *** getch ***
5610 ea=ea+1:ch=peek(ea)
5630 if ch=0 then print:ea=ea+5:goto 5610
5640 ch$=chr$(ch)
5650 rem print ch$;
5660 return

5800 rem *** getsym ***
5810 if ch$=" " then gosub 5600:goto 5810
5820 if ch$>="0" and ch$<="9" then 5900
5830 if ch$>="a" and ch$<="z" then 5950
5840 sy$ = ch$:gosub 5600
5850 return

5900 rem ** number **
5910 sy$="num":num=0
5920 if ch$<"0" or ch$>"9" then return
5930 num=num*10+val(ch$):gosub 5600
5940 goto 5920

5950 rem ** ident **
5960 sy$="id":id$=""
5970 if (ch$<"a" or ch$>"z") and (ch$<"0" or ch$>"9") then 6000
5980 id$=id$+ch$:gosub 5600
5990 goto 5970
6000 for i=0 to nrw-1
6010 if rw$(i)=id$ then sy$=id$
6020 next i
6030 return

10000 data 11:rem number of reserved words
10010 data "const","var","procedure","call","begin","end","if","then"
10020 data "while","do","odd"


