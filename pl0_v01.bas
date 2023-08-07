1 goto 5000
10 ************************************
20 * pl/0 compiler for c64 v0.1       *
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
5320 gosub 5800:rem getsym
5330 print ">>> start parsing program <<<"
5340 gosub 6200:rem block
5350 ex$=".":gosub 5400:rem expect
5360 print "parsing sussesfull"
5370 end

5400 rem *** expect ***
5410 if ex$<>sy$ then print "error: ";er$;" expected but ";sy$;" found":stop
5420 gosub 5800: rem getsym
5430 return

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
5650 print ch$;
5660 return

5799 rem ---------- scanner ----------

5800 rem *** getsym ***
5810 if ch$=" " then gosub 5600:goto 5810
5820 if ch$>="0" and ch$<="9" then 5900
5830 if ch$>="a" and ch$<="z" then 5950
5840 sy$ = ch$:gosub 5600
5850 if sy$=":" and ch$="=" then sy$=":=":gosub 5600
5860 if sy$="<" and ch$="=" then sy$="<=":gosub 5600
5870 if sy$=">" and ch$="=" then sy$=">=":gosub 5600
5880 return

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

6199 rem ---------- parser ----------

6200 rem *** block ***
6210 print ">>>entering block<<<"
6220 if sy$="const" then gosub 6300
6230 if sy$="var" then gosub 6500
6240 if sy$="procedure" then gosub 6700: goto 6240
6250 gosub 7000:rem statement
6260 return

6300 rem ** const **
6305 print ">>>found constant declaration<<<"
6310 gosub 5800: rem getsym
6320 ex$="id":gosub 5400: rem expect
6340 ex$="=":gosub 5400
6360 ex$="num":gosub 5400
6380 if sy$="," then 6310
6390 ex$=";":gosub 5400
6410 return

6500 rem ** var **
6505 print ">>>found var declaration<<<"
6510 gosub 5800: rem getsym
6520 ex$="id":gosub 5400: rem expect
6540 if sy$="," then 6510
6550 ex$=";":gosub 5400
6570 return

6700 rem ** procedure **
6705 print ">>>found procedure declaration<<<"
6710 gosub 5800: rem getsym
6720 ex$="id":gosub 5400: rem expect
6750 ex$=";":gosub 5400
6770 gosub 6200: rem block
6790 ex$=";":gosub 5400
6800 return

7000 rem *** statement ***
7010 if sy$="id" then 7200: rem assign
7020 if sy$="call" then 7400
7030 if sy$="?" then 7500
7040 if sy$="!" then 7600
7050 if sy$="begin" then 7700
7060 if sy$="if" then 7800
7070 if sy$="while" then 7900
7080 ex$="statement":gosub 5400:rem expect
7090 stop

7200 rem ** assign **
7210 gosub 5800: rem getsym
7220 ex$=":=":gosub 5400: rem expect
7230 gosub 8000: rem expression
7240 return

7400 rem ** call **
7410 gosub 5800: rem getsym
7420 ex$="id":gosub 5400: rem expect
7430 return

7500 rem ** ? **
7510 gosub 5800: rem getsym
7520 ex$="id":gosub 5400: rem expect
7530 return

7600 rem ** ! **
7610 gosub 5800: rem getsym
7620 gosub 8000: rem expression
7630 return

7700 rem ** begin **
7710 gosub 5800: rem getsym
7720 gosub 7000: rem statement
7730 if sy$=";" then 6710
7740 ex$="end":gosub 5400: rem expect
7750 return

7800 rem ** if **
7810 gosub 5800: rem getsym
7820 gosub ...: rem condition
7830 ex$="then":gosub 5400 :rem expect
7840 gosub 7000: rem statement
7850 return

7900 rem ** while **
7910 gosub 5800: rem getsym
7920 gosub ...: rem condition
7930 ex$="do":gosub 5400 :rem expect
7940 gosub 7000: rem statement
7950 return

8000 rem *** expression ***
8010 print "expressions are not yet implemented":stop


10000 data 11:rem number of reserved words
10010 data "const","var","procedure","call","begin","end","if","then"
10020 data "while","do","odd"


