1 goto 4000
10 ************************************
20 * pl/0 compiler for c64 v0.4       *
30 * (c)2023 by ir. marc dendooven    *
40 * compiler starts at line 4000     *
50 * pl/0 program after this header   *
60 * every line should start with '"' *
70 * do not remove or change header   *
80 ************************************


100" !(4+4+2)-(7+2+1)-(2+3+5).

3000 rem cf$="lit":cl=0:ca$=str$(iv):gosub 5300

4000 print " +------------------------------------+"
4010 print " !       pl/0 compiler for c64        !"
4020 print " !   (c)2023 by ir. marc dendooven    !"
4030 print " +------------------------------------!"

4100 rem *** settings ***
4110 ea=2384:rem editor address of first '"' in editor
4120 ni=20:rem max number of identifiers
4130 ns=10:rem max number in recursion stack
4140 ss=10:rem vm stacksize
4150 cs=30:rem vm code size
4290 rem *** end of settings ***

4299 rem ---------- main ----------

4300 gosub 5500:rem initialisation
4302 rem test pcode
4304 rem gosub 9900:goto 4500
4310 gosub 5600:rem getch
4320 gosub 5800:rem getsym
4340 gosub 6200:rem block
4350 if sy$<>"." then er$= "'.' expected":goto 5450: rem error
4355 cf$="jmp":cl=0:ca$="0":gosub 5300:rem gen
4360 print:print "parsing successful"
4365 rem end

4500 rem ------ p-code machine ------

4510 print " +------------------------------------+"
4520 print " !      p-code machine for c-64       !"
4530 print " !     (c) 2023 ir. m. dendooven      !"
4540 print " +------------------------------------+"
4550 print

4560 print "executing":print
4570 t=0:b=1:p=0:rem stackpointer,basepointer,programcounter
4580 s(1)=0:s(2)=0:s(3)=0:rem be sure begin stack empty

4600 rem *** fetch execute loop *** 
4610 cf$=cf$(p):cl=cl(p):ca$=ca$(p):ca=val(ca$)
4612 rem print,,"p=";p;" c=(";cf$;cl;ca$;")"
4615 p=p+1
4620 if cf$="lit" then t=t+1:s(t)=ca
4630 if cf$="opr" then gosub 5000
4640 if cf$="lod" then t=t+1:gosub 5200:s(t)=s(ba+ca)
4650 if cf$="sto" then gosub 5200:s(ba+ca)=s(t):t=t-1
4660 if cf$="cal" then gosub 5200:s(t+1)=ba:s(t+2)=b:s(t+3)=p:b=t+1:p=ca
4670 if cf$="ins" then t=t+ca 
4680 if cf$="jmp" then p=ca
4690 if cf$="jpc" then if s(t)=0 then p=ca$:t=t-1
4695 rem for i=0 to t:print s(i);:next:print
4700 if p<>0 then 4610
4710 print:print"done
4720 end

5000 rem ** opr **
5005 if ca$="return" then t=b-1:p=s(t+3):b=s(t+2)
5010 if ca$="neg" then s(t)=-s(t)
5020 if ca$="+" then t=t-1:s(t)=s(t)+s(t+1)
5030 if ca$="-" then t=t-1:s(t)=s(t)-s(t+1)
5040 if ca$="*" then t=t-1:s(t)=s(t)*s(t+1)
5050 if ca$="/" then t=t-1:s(t)=s(t)/s(t+1)
5060 if ca$="odd" then s(t)=-(s(t) and 1)
5080 if ca$="=" then t=t-1:s(t)=s(t)=s(t+1)
5090 if ca$="#" then t=t-1:s(t)=s(t)<>s(t+1)
5100 if ca$="<" then t=t-1:s(t)=s(t)<s(t+1)
5110 if ca$=">=" then t=t-1:s(t)=s(t)>=s(t+1)
5120 if ca$=">" then t=t-1:s(t)=s(t)>s(t+1)
5130 if ca$="<=" then t=t-1:s(t)=s(t)<=s(t+1)
5140 if ca$="?" then t=t+1:input s(t)
5150 if ca$="!" then print ">>>";s(t):t=t-1
5160 return

5200 rem ** calculate base (b,cl)->ba **
5210 ba=b
5220 if cl<=0 then return
5230 ba=s(ba):cl=cl-1
5240 goto 5220

5299 rem ---------- code generator ----------

5300 rem *** generate ***
5310 if p>=cs then er$="code area exceeded":goto 5450
5320 cf$(p)=cf$:cl(p)=cl:ca$(p)=ca$
5325 rem print"gen: p=";p;" c=(";cf$;cl;ca$;")"
5330 p=p+1
5340 return

5399 rem ---------routines -------------

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
5565 lv=0:rem level
5570 dim rs(ns-1):sp=0:rem recursionstack and pointer 
5575 dim s(ss-1):rem stack
5580 dim cf$(cs-1),cl(cs-1),ca$(cs-1):rem codespace
5585 p=0: rem program counter
5586 op$=" "
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
6210 lv=lv+1:vn=2:rem inc level,reset varnum
6215 rs=ip:gosub 9600:rem push ip
6220 if sy$="const" then gosub 6300
6230 if sy$="var" then gosub 6500
6235 rem gosub 9800: rem debug id table
6237 cf$="ins":cl=0:ca$=str$(vn):gosub 5300:rem make place on stack
6240 if sy$="procedure" then gosub 6700: goto 6240
6250 gosub 7000:rem statement
6260 lv=lv-1
6270 gosub 9700:ip=rs:rem pull ip 
6280 return

6300 rem ** const **
6305 ic$="const":il=lv
6310 gosub 5800: rem getsym
6320 in$=name$:ex$="id":gosub 5400: rem expect
6340 ex$="=":gosub 5400
6360 iv=num:ex$="num":gosub 5400
6370 gosub 9400:rem add identifier
6380 if sy$="," then 6310
6390 ex$=";":gosub 5400
6410 return

6500 rem ** var **
6505 ic$="var":il=lv
6510 gosub 5800: rem getsym
6520 in$=name$:ex$="id":gosub 5400: rem expect
6530 iv=vn:vn=vn+1:gosub 9400:rem add identifier
6540 if sy$="," then 6510
6550 ex$=";":gosub 5400
6570 return

6700 rem ** procedure **
6705 ic$="procedure":il=lv:iv=0
6710 gosub 5800: rem getsym
6720 in$=name$:ex$="id":gosub 5400: rem expect
6730 gosub 9400:rem add identifier
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
7204 in$=name$:gosub 9500:rem get identifier
7206 if ic$<>"var" then er$=in$+" is not a variable":goto5450
7210 gosub 5800: rem getsym
7220 ex$=":=":gosub 5400: rem expect
7230 gosub 8000: rem expression !!! varcall in expression -> garbage
7235 cf$="sto":cl=lv-il:ca$=str$(iv):gosub 5300
7240 return

7400 rem ** call **
7410 gosub 5800: rem getsym
7415 in$=name$
7420 ex$="id":gosub 5400: rem expect
7430 gosub 9500: rem get identifier
7440 if ic$<>"procedure" then er$="error: call to var or const":goto 5450 
7450 return

7500 rem ** ? **
7510 gosub 5800: rem getsym
7520 ex$="id":gosub 5400: rem expect
7530 return

7600 rem ** ! **
7610 gosub 5800: rem getsym
7620 gosub 8000: rem expression
7625 cf$="opr":cl=0:ca$="!":gosub 5300
7630 return

7700 rem ** begin **
7710 gosub 5800: rem getsym
7720 gosub 7000: rem statement
7730 if sy$=";" then 7710
7740 ex$="end":gosub 5400: rem expect
7750 return

7800 rem ** if **
7810 gosub 5800: rem getsym
7820 gosub 9000: rem condition
7830 ex$="then":gosub 5400 :rem expect
7840 gosub 7000: rem statement
7850 return

7900 rem ** while **
7910 gosub 5800: rem getsym
7920 gosub 9000: rem condition
7930 ex$="do":gosub 5400 :rem expect
7940 gosub 7000: rem statement
7950 return

8000 rem *** expression ***
8003 rs=asc(op$):gosub 9600: rem push
8005 op$="+"
8010 if sy$="+" or sy$="-" then op$=sy$:gosub 5800:rem getsym
8030 gosub 8100:rem term
8035 if op$="-" then cf$="opr":cl=0:ca$="neg":gosub 5300
8040 if sy$<>"-" and sy$<>"+" then gosub 9700:op$=chr$(rs):return:rem pull
8060 op$=sy$:gosub 5800:gosub 8100:rem getsym,term
8070 cf$="opr":cl=0:ca$=op$:gosub 5300
8080 goto 8040

8100 rem ** term **  
8105 rs=asc(op$):gosub 9600: rem push
8110 gosub 8200: rem factor
8120 if sy$<>"*" and sy$<>"/" then gosub 9700:op$=chr$(rs):return:rem pull 
8122 op$=sy$:gosub 5800:gosub 8200:rem getsym,factor
8125 cf$="opr":cl=0:ca$=op$:gosub 5300
8130 goto 8120

8200 rem ** factor **
8210 if sy$="id" then 8260
8220 if sy$="num" then cf$="lit":cl=0:ca$=str$(num):gosub 5300:goto 8280
8230 if sy$="(" then gosub 5800:gosub 8000:ex$=")":gosub 5400:return
8240 ex$="identifier, literal or '('": gosub 5400
8250 stop
8260 in$=name$:gosub 9500:rem get identifier
8270 if ic$="procedure" then er$=in$+" is not an expression":goto 5450
8275 if ic$="const" then cf$="lit":cl=0:ca$=str$(iv):gosub 5300
8277 if ic$="var" then cf$="lod":cl=lv-il:ca$=str$(iv):gosub 5300
8280 gosub 5800:return:rem getsym



8300 rem gosub 5800:return:rem getsym

9000 rem *** condition ***
9010 if sy$="odd" then gosub 5800:gosub 8000:return:rem getsym,expression
9020 gosub 8000
9030 if sy$="=" or sy$="#" or sy$="<" then 9060
9040 if sy$="<=" or sy$=">" or sy$=">=" then 9060
9050 ex$="=,#,<,>,<=,>=":gosub 5400:stop:rem expect

9060 gosub 5800:gosub 8000
9070 return

9399 rem ---------- identifers ----------

9400 rem *** add identifier ***
9410 if ip>=ni then er$="identifier list full":goto 5450
9420 in$(ip)=in$:ic$(ip)=ic$:il(ip)=il:iv(ip)=iv:ip=ip+1
9430 return 

9500 rem *** get identifier ***
9510 i=ip
9520 i=i-1: if i<0 then er$="identifier '"+in$+"' not found":goto 5450
9530 if in$<>in$(i) then 9520
9540 ic$=ic$(i):il=il(i):iv=iv(i)
9550 return

9599 rem ---------- recursion stack ----------

9600 rem *** push ***
9610 if sp>=ns then er$="recursion stack overflow":goto 5450
9620 rs(sp)=rs:sp=sp+1
9630 return

9700 rem *** pull ***
9710 if sp<=0 then er$="recursion stack underflow":goto 5450
9720 sp=sp-1:rs=rs(sp)
9730 return

9799 rem --------- debug --------

9800 rem *** print current id table ***
9870 print:print" identifier table:":print
9875 print "name","class","level","value"
9876 print "----","-----","-----","-----"
9878 if ip=0 then print "empty":goto 9890
9880 for i=0 to ip-1:print in$(i),ic$(i),il(i),iv(i):next
9890 return

9900 rem *** test p-code ***
9910 p=0
9920 read cf$(p),cl(p),ca$(p)
9930 if cf$(p)="end" then return
9940 p=p+1
9950 goto 9520

9999 rem ---------- reserved words ----------

10000 data 11:rem number of reserved words
10010 data "const","var","procedure","call","begin","end","if","then"
10020 data "while","do","odd"

11000 rem ----- test p-code -----

11100 data "lit",0,"69"
11105 data "lit",0,"2"
11107 data "opr",0,"*"
11110 data "opr",0,"!"
11120 data "jmp",0,"0"
11130 data "end",0,"0"
