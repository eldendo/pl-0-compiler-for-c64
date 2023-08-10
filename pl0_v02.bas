1 goto 5000
10 ************************************
20 * pl/0 compiler for c64 v0.2       *
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
125" var c;
130"    procedure trouble;
140"    var d;
150"    d:=0;
230" begin
240"    !test+test+c-5+d
250" end;
260"
270" begin
280"   !138;
290"   b := prom;
300"   !b+c; 
310"   test := 3;
320"   call double
500" end.

5000 print " +------------------------------------+"
5010 print " !       pl/0 compiler for c64        !"
5020 print " !   (c)2023 by ir. marc dendooven    !"
5030 print " +------------------------------------!"

5100 rem *** compiler settings ***
5110 ea=2384:rem editor address of first '"' in editor
5120 ni=20:rem max number of identifiers
5130 ns=2:rem max of recursion stack
5290 rem *** end of compiler settings

5299 rem ---------- main ----------

5300 gosub 5500:rem initialisation
5310 gosub 5600:rem getch
5320 gosub 5800:rem getsym
5340 gosub 6200:rem block
5350 if sy$<>"." then er$= "'.' expected but '"+sy$+"' found":goto 5450
5360 print:print "parsing succesfull"
5370 print:print" identifier table:":print
5375 print "name","class","level","value"
5376 print "----","-----","-----","-----"
5378 if ip=0 then print "empty":goto 5390
5380 for i=0 to ip-1:print in$(i),ic$(i),il(i),iv(i):next
5390 end

5400 rem *** expect ***
5410 if ex$=sy$ then gosub 5800:return: rem getsym
5420 er$="'"+ex$+"' expected but '"+sy$+"' found"

5450 rem *** error ***
5460 print:print:print "error: ";er$
5470 stop

5500 rem *** initialisation ***
5510 print "initialising...":print
5520 read nrw:rem number of reserved words
5530 dim rw$(nrw-1):rem list of reserved words
5540 for i=0 to nrw-1: read rw$(i):next
5550 dim in$(ni-1),ic$(ni-1),il(ni-1),iv(ni-1):ip=0:
5560 rem identifier name,class,level,value and pointer
5570 lv=0: rem level
5580 dim rs(ns-1):sp=0:rem recursionstack and pointer 
5590 return

5600 rem *** getch ***
5610 ea=ea+1:ch=peek(ea):rem get lookahead character
5630 if ch=0 then print:ea=ea+5:goto 5610:rem eol,skip to next
5640 ch$=chr$(ch)
5645 if ch$="@" then stop:rem debug
5650 print ch$; :rem print lookahead character 
5660 return

5799 rem ---------- scanner ----------

5800 rem *** getsym ***
5810 if ch$=" " then gosub 5600:goto 5810: rem skip whitespace
5820 if ch$>="0" and ch$<="9" then 5900: rem number
5830 if ch$>="a" and ch$<="z" then 5950: rem identifier (or reserved word)
5840 sy$ = ch$:gosub 5600:rem getch
5850 if sy$=":" and ch$="=" then sy$=":=":gosub 5600
5860 if sy$="<" and ch$="=" then sy$="<=":gosub 5600
5870 if sy$=">" and ch$="=" then sy$=">=":gosub 5600
5880 return

5900 rem ** number **
5910 sy$="num":num=0
5920 if ch$<"0" or ch$>"9" then return
5930 num=num*10+val(ch$):gosub 5600:rem getch
5940 goto 5920

5950 rem ** ident **
5960 sy$="id":name$=""
5970 if (ch$<"a" or ch$>"z") and (ch$<"0" or ch$>"9") then 6000
5980 name$=name$+ch$:gosub 5600:rem getch
5990 goto 5970
6000 for i=0 to nrw-1: rem test for reserved word
6010 if rw$(i)=name$ then sy$=name$
6020 next i
6030 return

6199 rem ---------- parser ----------

6200 rem *** block ***
6210 lv=lv+1
6215 rs=ip:gosub 8600:rem push ip
6220 if sy$="const" then gosub 6300
6230 if sy$="var" then gosub 6500
6240 if sy$="procedure" then gosub 6700: goto 6240
6250 gosub 7000:rem statement
6260 lv=lv-1
6270 gosub 8700:ip=rs:rem pull ip 
6280 return

6300 rem ** const **
6305 ic$="const":il=lv
6310 gosub 5800: rem getsym
6320 in$=name$:ex$="id":gosub 5400: rem expect
6340 ex$="=":gosub 5400
6360 iv=num:ex$="num":gosub 5400
6370 gosub 8400:rem add identifier
6380 if sy$="," then 6310
6390 ex$=";":gosub 5400
6410 return

6500 rem ** var **
6505 ic$="var":il=lv:iv=0
6510 gosub 5800: rem getsym
6520 in$=name$:ex$="id":gosub 5400: rem expect
6530 gosub 8400:rem add identifier
6540 if sy$="," then 6510
6550 ex$=";":gosub 5400
6570 return

6700 rem ** procedure **
6705 ic$="procedure":il=lv:iv=0
6710 gosub 5800: rem getsym
6720 in$=name$:ex$="id":gosub 5400: rem expect
6730 gosub 8400:rem add identifier
6750 ex$=";":gosub 5400
6770 gosub 6200:rem block
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
7204 in$=name$:gosub 8500:rem get identifier
7206 if ic$<>"var" then er$=in$+" is not a variable":goto5450
7210 gosub 5800: rem getsym
7220 ex$=":=":gosub 5400: rem expect
7230 gosub 8000: rem expression
7240 return

7400 rem ** call **
7410 gosub 5800: rem getsym
7415 in$=name$
7420 ex$="id":gosub 5400: rem expect
7430 gosub 8500: rem get identifier
7440 if ic$<>"procedure" then er$="error: call to var or const":goto 5450 
7450 return

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
7730 if sy$=";" then 7710
7740 ex$="end":gosub 5400: rem expect
7750 return

7800 rem ** if **
7810 gosub 5800: rem getsym
7820 gosub 8300: rem condition
7830 ex$="then":gosub 5400 :rem expect
7840 gosub 7000: rem statement
7850 return

7900 rem ** while **
7910 gosub 5800: rem getsym
7920 gosub 8300: rem condition
7930 ex$="do":gosub 5400 :rem expect
7940 gosub 7000: rem statement
7950 return

8000 rem *** expression ***
8010 if sy$="-" then gosub 5800:goto 8030
8020 if sy$="+" then gosub 5800:rem getsym
8030 gosub 8100: rem term
8040 if sy$="-" or sy$="+" then 8010
8060 return

8100 rem ** term **
8110 gosub 8200: rem factor
8120 if sy$="*" or sy$="/" then gosub 5800:goto 8110:rem getsym
8130 return

8200 rem ** factor **
8210 if sy$="id" then 8260
8220 if sy$="num" then gosub 5800:return
8230 if sy$="(" then gosub 5800:gosub 8000:ex$=")":gosub 5400:return
8240 ex$="identifier, literal or '('": gosub 5400
8250 stop
8260 in$=name$:gosub 8500:rem get identifier
8270 if ic$="procedure" then er$=in$+" is not an expression":goto 5450
8280 gosub 5800:return:rem getsym

8300 rem *** condition ***
8310 if sy$="odd" then gosub 5800:gosub 8000:return:rem getsym,expression
8320 gosub 8000
8330 if sy$="=" or sy$="#" or sy$="<" then 8360
8340 if sy$="<=" or sy$=">" or sy$=">=" then 8360
8350 ex$="=,#,<,>,<=,>=":gosub 5400:stop:rem expect
8360 gosub 5800:gosub 8000
8370 return

8399 rem ---------- identifers ----------

8400 rem *** add identifier ***
8410 if ip>=ni then er$="identifier list full":goto 5450
8420 in$(ip)=in$:ic$(ip)=ic$:il(ip)=il:iv(ip)=iv:ip=ip+1
8430 return 

8500 rem *** get identifier ***
8510 i=ip
8520 i=i-1: if i<0 then er$="identifier '"+in$+"' not found":goto 5450
8530 if in$<>in$(i) then 8520
8540 ic$=ic$(i):il=il(i):iv=iv(i)
8550 return

8599 rem ---------- recursion stack ----------

8600 rem *** push ***
8610 if sp>=ns then er$="recursion stack overflow":goto 5450
8620 rs(sp)=rs:sp=sp+1
8630 return

8700 rem *** pull ***
8710 if sp<=0 then er$="recursion stack underflow":goto 5450
8720 sp=sp-1:rs=rs(sp)
8730 return

9999 rem ---------- reserved words ----------

10000 data 11:rem number of reserved words
10010 data "const","var","procedure","call","begin","end","if","then"
10020 data "while","do","odd"


