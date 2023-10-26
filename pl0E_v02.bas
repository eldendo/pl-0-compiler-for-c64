1 goto 4000
10 ************************************
20 * pl/0E compiler for c64 v0.2      *
30 * (c)2023 by ir. marc dendooven    *
40 * compiler starts at line 4000     *
50 * pl/0 program after this header   *
60 * every line should start with '"' *
70 * do not remove or change header   *
80 ************************************

100" (* test program for array *)
110" const max=10;
120" var i,arr[5];
125" begin
130"   i:=4;
140"   while i>=0 do begin arr[i]:=2*i;i:=i-1 end;
145"   i:=4;
150"   while i>=0 do begin !arr[i];i:=i-1 end
170" end.



4000 print " +------------------------------------+"
4010 print " !       pl/0 compiler for c64        !"
4020 print " !   (c)2023 by ir. marc dendooven    !"
4030 print " +------------------------------------!"

4100 rem *** settings ***
4105 db=0:rem debug value
4110 ea=2384:rem editor address of first '"' in editor
4120 ni=100:rem max number of identifiers
4130 ns=100:rem max number in recursion stack
4140 ss=100:rem vm stacksize
4150 cs=100:rem vm code size
4290 rem *** end of settings ***

4299 rem ---------- main ----------

4300 gosub 5500:rem initialisation
4310 gosub 5600:rem getch
4320 gosub 5800:rem getsym
4340 gosub 6200:rem block
4350 if sy$<>"." then er$= "'.' expected":goto 5450: rem error
4355 cf$="jmp":cl=0:ca=0:gosub 5300:rem gen
4360 print:print "compiling successful"
4365 rem end

4400 rem ------ show code -------

4401 if db=0 then 4500

4405 print
4410 for i=0 to p-1
4420 print i;cf$(i);cl(i);ca(i)
4430 next i

4500 rem ------ p-code machine ------
4510 rem -- translated to basic from N. Wirth's P-code machine --

4560 print "executing":print
4570 t=0:b=1:p=0:rem stackpointer,basepointer,programcounter
4580 s(1)=0:s(2)=0:s(3)=0:rem be sure begin stack empty

4600 rem *** fetch execute loop *** 
4610 cf$=cf$(p):cl=cl(p):ca=ca(p)
4612 if db > 2 then print,,"p=";p;" c=(";cf$;cl;ca;")"
4615 p=p+1
4620 if cf$="lit" then t=t+1:s(t)=ca
4630 if cf$="opr" then gosub 5000
4640 if cf$="lod" then t=t+1:gosub 5200:s(t)=s(ba+ca)
4645 if cf$="ldi" then gosub 5200:s(t)=s(ba+ca+s(t))
4650 if cf$="sto" then gosub 5200:s(ba+ca)=s(t):t=t-1
4655 if cf$="sti" then gosub 5200:s(ba+ca+s(t-1))=s(t):t=t-2
4660 if cf$="cal" then gosub 5200:s(t+1)=ba:s(t+2)=b:s(t+3)=p:b=t+1:p=ca
4670 if cf$="int" then t=t+ca 
4680 if cf$="jmp" then p=ca
4690 if cf$="jpc" then t=t-1:if s(t+1)=0 then p=ca
4695 if db > 3 then for i=0 to t:print s(i);:next:print
4700 if p<>0 then 4610
4710 print:print"done
4720 end

5000 rem ** opr **
5005 if ca=0 then t=b-1:p=s(t+3):b=s(t+2)
5010 if ca=1 then s(t)=-s(t)
5020 if ca=2 then t=t-1:s(t)=s(t)+s(t+1)
5030 if ca=3 then t=t-1:s(t)=s(t)-s(t+1)
5040 if ca=4 then t=t-1:s(t)=s(t)*s(t+1)
5050 if ca=5 then t=t-1:s(t)=int(s(t)/s(t+1))
5060 if ca=6 then s(t)=-(s(t) and 1)
5070 if ca=7 then print chr$(s(t));:t=t-1
5080 if ca=8 then t=t-1:s(t)=s(t)=s(t+1)
5090 if ca=9 then t=t-1:s(t)=s(t)<>s(t+1)
5100 if ca=10 then t=t-1:s(t)=s(t)<s(t+1)
5110 if ca=11 then t=t-1:s(t)=s(t)<=s(t+1)
5120 if ca=12 then t=t-1:s(t)=s(t)>s(t+1)
5130 if ca=13 then t=t-1:s(t)=s(t)>=s(t+1)
5140 if ca=14 then t=t+1:input s(t)
5150 rem if ca=15 then print ">>>";s(t):t=t-1
5151 if ca=15 then print s(t);:t=t-1
5160 return

5200 rem ** calculate base (b,cl)->ba **
5210 ba=b
5220 if cl<=0 then return
5230 ba=s(ba):cl=cl-1
5240 goto 5220

5299 rem ---------- code generator ----------

5300 rem *** generate ***
5310 if p>=cs then er$="code area exceeded":goto 5450
5320 cf$(p)=cf$:cl(p)=cl:ca(p)=ca
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
5550 dim in$(ni-1),ic$(ni-1),il(ni-1),iv(ni-1),is(ni-1):ip=0:
5560 rem identifier name,class,level,value,(array)size and pointer
5565 lv=0:rem level
5570 dim rs(ns-1):sp=0:rem recursionstack and pointer 
5575 dim s(ss-1):rem stack
5580 dim cf$(cs-1),cl(cs-1),ca(cs-1):rem codespace
5585 p=0: rem program counter
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
5835 if ch$="'" then 6150:rem string
5840 sy$ = ch$:gosub 5600:rem getch
5850 if sy$=":" and ch$="=" then sy$=":=":gosub 5600:rem getch
5860 if sy$="<" and ch$="=" then sy$="<=":gosub 5600:rem getch
5870 if sy$=">" and ch$="=" then sy$=">=":gosub 5600:rem getch
5875 if sy$="(" and ch$="*" then gosub 6050:goto 5810:rem comment,rescan
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

6050 rem ** comment **
6060 gosub 5600:rem getch
6070 if ch$<>"*" then 6060
6080 gosub 5600:rem getch
6090 if ch$<>")" then 6060
6100 gosub 5600:rem getch
6110 return

6150 rem ** string **
6155 sy$="string":sv$="":rem string value
6160 gosub 5600: rem getch
6165 if ch$="'" then gosub 5600:return
6170 if ch$="/" then gosub 6185: rem escape 
6175 sv$=sv$+ch$
6180 goto 6160

6185 gosub 5600: rem getch
6187 if ch$="n" then ch$=chr$(13)
6190 return

6199 rem ---------- parser ----------

6200 rem *** block ***
6205 rs=l1:gosub 9600: rem push label l1
6210 lv=lv+1:vn=3:rem inc level,reset varnum
6215 rs=ip:gosub 9600:rem push ip
6220 if sy$="const" then gosub 6300
6230 if sy$="var" then gosub 6500
6235 if db>0 then gosub 9800: rem debug id table
6237 cf$="int":cl=0:ca=vn:gosub 5300:rem make place on stack
6238 l1=p:cf$="jmp":cl=0:ca=0:gosub 5300:rem mark label,jump to proper code
6240 if sy$="procedure" then gosub 6700: goto 6240
6245 ca(l1)=p:rem adjust code on label l1
6250 gosub 7000:rem statement
6260 lv=lv-1:rem dec level
6270 gosub 9700:ip=rs:rem pull ip 
6275 gosub 9700:l1=rs:rem pull l1
6280 return

6300 rem ** const **
6305 ic$="const":il=lv
6310 gosub 5800: rem getsym
6320 in$=name$:ex$="id":gosub 5400: rem expect
6340 ex$="=":gosub 5400:rem expect
6360 iv=num:ex$="num":gosub 5400:rem expect
6370 gosub 9400:rem add identifier
6380 if sy$="," then 6310
6390 ex$=";":gosub 5400:rem expect
6410 return

6500 rem ** var **
6505 il=lv
6510 is=1:gosub 5800: rem set array size, getsym
6520 tn$=name$:ex$="id":gosub 5400: rem temp store name,expect
6530 if sy$="[" then gosub 8600:rem array
6620 ic$="var":in$=tn$:iv=vn:vn=vn+is:gosub 9400:rem add identifier, +is/+1
6630 if sy$="," then 6510
6640 ex$=";":gosub 5400:rem expect
6650 return

6700 rem ** procedure **
6705 ic$="procedure":il=lv:iv=p
6710 gosub 5800: rem getsym
6720 in$=name$:ex$="id":gosub 5400: rem expect
6730 gosub 9400:rem add identifier
6750 ex$=";":gosub 5400:rem expect
6770 gosub 6200:rem block
6790 ex$=";":gosub 5400:rem expect
6795 cf$="opr":cl=0:ca=0:gosub 5300:rem gen
6800 return

7000 rem *** statement ***
7005 rs=l1:gosub 9600: rem push label
7006 rs=l2:gosub 9600: rem push label
7010 if sy$="id" then gosub 7200:goto 7100:rem assign
7020 if sy$="call" then gosub 7400:goto 7100
7030 if sy$="?" then gosub 7500:goto 7100
7040 if sy$="!" then gosub 7600:goto 7100
7050 if sy$="begin" then gosub 7700:goto 7100
7060 if sy$="if" then gosub 7800:goto 7100
7070 if sy$="while" then gosub 7900:goto 7100
7080 ex$="statement":gosub 5400:rem expect
7090 stop
7100 gosub 9700:l2=rs:rem pull label
7110 gosub 9700:l1=rs:rem pull label
7120 return

7200 rem ** assign **
7204 in$=name$:gosub 9500:rem get identifier
7206 if ic$<>"var" then er$=in$+" is not a variable":goto5450
7210 gosub 5800: rem getsym
7212 tl=lv-il:tv=iv: rem temporary storage avoiding ...
7215 rem ... problems with varcall in expression 
7217 if sy$="[" then 8700:rem array
7220 ex$=":=":gosub 5400: rem expect
7230 gosub 8000: rem expression
7235 cf$="sto":cl=tl:ca=tv:gosub 5300:rem gen
7240 return

7400 rem ** call **
7410 gosub 5800: rem getsym
7415 in$=name$
7420 ex$="id":gosub 5400: rem expect
7430 gosub 9500: rem get identifier
7440 if ic$<>"procedure" then er$="call to var or const":goto 5450 
7445 cf$="cal":cl=lv-il:ca=iv:gosub 5300:rem gen
7450 return

7500 rem ** ? **
7510 gosub 5800: rem getsym
7520 in$=name$:ex$="id":gosub 5400: rem expect
7530 gosub 9500:rem get identifier
7540 if ic$<>"var" then er$="var expected":goto 5450
7550 cf$="opr":cl=0:ca=14:gosub 5300:rem gen
7560 cf$="sto":cl=lv-il:ca=iv:gosub 5300:rem gen
7590 return

7600 rem ** ! **
7610 gosub 5800: rem getsym
7615 if sy$="string" then 7660:rem string
7620 gosub 8000: rem expression
7625 cf$="opr":cl=0:ca=15:gosub 5300:rem gen
7630 if sy$="," then 7610
7650 return

7660 rem * string * !!! spaghetti
7665 l=len(sv$):if l=0 then 7630
7670 for i=1 to l
7675  cf$="lit":cl=0:ca=asc(mid$(sv$,i,1)):gosub 5300:rem gen
7680  cf$="opr":cl=0:ca=7:gosub 5300:rem gen
7685 next i
7690 gosub 5800:goto 7630

7700 rem ** begin **
7710 gosub 5800: rem getsym
7720 gosub 7000: rem statement
7730 if sy$=";" then 7710
7740 ex$="end":gosub 5400: rem expect
7750 return

7800 rem ** if ** 
7810 gosub 5800: rem getsym
7820 gosub 8400: rem condition
7830 ex$="then":gosub 5400 :rem expect
7835 l1=p:cf$="jpc":cl=0:ca=0:gosub 5300:rem set label, gen
7840 gosub 7000: rem statement
7845 ca(l1)=p:rem modify code at label
7850 if sy$<>"else" then return
7852 l2=p:cf$="jmp":cl=0:ca=0:gosub 5300:rem set label, gen
7853 ca(l1)=p:rem if there is an elsepart, it is after the jmp
7855 gosub 5800:gosub 7000:rem getsym,statement
7860 ca(l2)=p:rem modify code at label
7865 return

7900 rem ** while **
7910 gosub 5800: rem getsym
7915 l1=p:rem set label
7920 gosub 8400: rem condition
7925 l2=p:cf$="jpc":cl=0:ca=0:gosub 5300:rem set label,gen
7930 ex$="do":gosub 5400 :rem expect
7940 gosub 7000: rem statement
7945 cf$="jmp":cl=0:ca=l1:gosub 5300:rem gen
7947 ca(l2)=p:rem modify code at label
7950 return

8000 rem *** expression ***
8003 rs=op:gosub 9600: rem push
8005 if sy$="+" then op=2:gosub 5800:goto 8030:rem getsym
8010 if sy$="-" then op=3:gosub 5800:goto 8030:rem getsym
8030 gosub 8100:rem term
8035 if op=3 then cf$="opr":cl=0:ca=1:gosub 5300: rem '-' -> 'neg'
8040 if sy$<>"-" and sy$<>"+" then gosub 9700:op=rs:return:rem pull
8050 if sy$="+" then op=2:goto 8065
8060 if sy$="-" then op=3
8065 gosub 5800:gosub 8100:rem getsym,term
8070 cf$="opr":cl=0:ca=op:gosub 5300:rem gen
8080 goto 8040

8100 rem ** term **  
8105 rs=op:gosub 9600: rem push
8110 gosub 8200: rem factor
8120 if sy$<>"*" and sy$<>"/" then gosub 9700:op=rs:return:rem pull 
8122 if sy$="*" then op=4:goto 8123
8123 if sy$="/" then op=5
8124 gosub 5800:gosub 8200:rem getsym,factor
8125 cf$="opr":cl=0:ca=op:gosub 5300:rem gen
8130 goto 8120

8200 rem ** factor **
8210 if sy$="id" then 8260
8220 if sy$="num" then cf$="lit":cl=0:ca=num:gosub 5300:goto 8300
8230 if sy$="(" then gosub 5800:gosub 8000:ex$=")":gosub 5400:return
8240 ex$="identifier, literal or '('": gosub 5400:rem expect
8250 stop
8260 in$=name$:gosub 9500:rem get identifier
8270 if ic$="procedure" then er$=in$+" is not an expression":goto 5450
8275 if ic$="const" then cf$="lit":cl=0:ca=iv:gosub 5300:goto 8300
8280 cl=lv-il:ca=iv:rem it is a var, prepare for gen
8285 gosub 5800:if sy$="[" then 8900:rem array 
8290 cf$="lod":gosub 5300:return:rem it is a var,gen
8300 gosub 5800:return

8400 rem *** condition ***
8405 rs=op:gosub 9600: rem push
8410 if sy$="odd" then op=6:goto 8470
8420 gosub 8000:rem expression
8430 if sy$="=" then op=8
8432 if sy$="#" then op=9
8434 if sy$="<" then op=10
8436 if sy$="<=" then op=11
8438 if sy$=">" then op=12
8440 if sy$=">=" then op=13
8445 goto 8470
8450 ex$="odd,=,#,<,>,<=,>=":gosub 5400:stop:rem expect
8470 gosub 5800:gosub 8000:rem getsym,expression
8480 cf$="opr":cl=0:ca=op:gosub 5300:rem gen
8490 gosub 9700:op=rs:rem pull
8500 return

8599 rem ----- subroutines for arrays -------

8600 rem *** array def ***
8605 gosub 5800: rem getsym
8610 if sy$="num" then is=num:goto 8650:rem literal
8620 if sy$="id" then in$=name$:gosub 9500:rem get identifier
8630 if ic$<>"const" then er$="literal or const expected":goto 5450:rem error
8640 is=iv: rem set array size to value of constant
8650 gosub 5800: rem getsym
8660 ex$="]":gosub 5400: rem expect
8670 return

8700 rem *** assign array *** tl and tv should probably be saved on stack
8710 gosub 5800: rem getsym
8719 rem print:print "*** assign for arrays under construction ***"
8720 gosub 8000: rem expression
8730 ex$="]":gosub 5400: rem expect
8740 ex$=":=":gosub 5400: rem expect
8750 gosub 8000: rem expression
8760 cf$="sti":cl=tl:ca=tv:gosub 5300:rem gen
8770 return

8900 rem *** use array *** cl and ca should probably be saved on stack
8902 rs=cl:gosub 9600: rem push
8904 rs=ca:gosub 9600: rem push
8910 gosub 5800: rem getsym
8919 rem print:print "*** use of arrays under construction ***"
8920 gosub 8000: rem expression
8930 ex$="]":gosub 5400: rem expect
8932 gosub 9700:ca=rs:rem pull
8934 gosub 9700:cl=rs:rem pull
8940 cf$="ldi":gosub 5300:return:rem gen
8950 rem gosub 5800
8960 rem return


9399 rem ---------- identifers ----------

9400 rem *** add identifier ***
9410 if ip>=ni then er$="identifier list full":goto 5450
9420 in$(ip)=in$:ic$(ip)=ic$:il(ip)=il:iv(ip)=iv:is(ip)=is:ip=ip+1
9430 return 

9500 rem *** get identifier ***
9510 i=ip
9520 i=i-1: if i<0 then er$="identifier '"+in$+"' not found":goto 5450
9530 if in$<>in$(i) then 9520
9540 ic$=ic$(i):il=il(i):iv=iv(i):is=is(i)
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
9875 print "name","class","level","value","size"
9876 print "----","-----","-----","-----","----"
9878 if ip=0 then print "empty":goto 9890
9880 for i=0 to ip-1:print in$(i),ic$(i),il(i),iv(i),is(i):next
9890 return

9999 rem ---------- reserved words ----------

10000 data 12:rem number of reserved words
10010 data "const","var","procedure","call","begin","end","if","then"
10020 data "while","do","odd","else"


