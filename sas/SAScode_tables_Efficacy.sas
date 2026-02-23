
%*-------------------------------------------------------------------------------*;
%* 表3 感觉总分较基线变化值MMRM的LSMEANS组间差值历时性比较(FAS);
%*-------------------------------------------------------------------------------*;
 proc format;
 	value vis
	201='D2'
	202='D3'
	203='D4'
	301='D7'
	302='D14'
	303='D28'
	;
run;
 
 data adam;
	set adam.adqs;
	where paramn<=10 and anl01fl='是' and 0<avisitn<400;
	if trt01pn=99 then trt01pn=0;
	if avisitn=0 then do; chg=0; pchg=0; end;
	ord=1;
	res=aval;
	output;
	if chg^=. or avisitn=0 then do;
	ord=2;
	res=chg;
	output;
	end;
	if pchg^=. or avisitn=0 then do;
	ord=3;
	res=pchg;
	output;
	end;
run;

proc sort data=adam;
	by trt01pn trt01p paramn param avisitn avisit ord;
run;

proc univariate data=adam;
	by trt01pn trt01p paramn param avisitn avisit ord;
	output out=uni n=n mean=mean std=std stderr=stderr;
	var res;
quit;

proc sort data=uni out= dum(keep=trt: param:) nodupkey;
	by trt01pn paramn;
run;

data dum2;
	length avisit $100;
	set dum;
	do avisitn=201,202,203,301,302,303;
	avisit=put(avisitn,vis.);
	do ord=1 to 3;
	output;
	end;
	end;
run;

proc sort data=dum2;
	by trt01pn trt01p paramn param avisitn avisit ord;
run;

proc sort data=uni;
	by trt01pn trt01p paramn param avisitn avisit ord;
run;

data tot;
	merge dum2 uni;
	by trt01pn trt01p paramn param avisitn avisit ord;
	if n=. then n=0;
run;
 
%macro q(con=,num=);
data qc&num;
	set tot(where=(&con));
	drop paramn ord std ;
	label trt01p=' '  trt01pn=' ' param=' ' avisit=' ' avisitn=' ' n=' ' mean=' ' stderr=' ';
run;
%mend;
%q(con=%str(paramn=3 and ord=2),num=3);

%*-------------------------------------------------------------------------------*;
%* 表8 运动总分评分较基线变化值MMRM的LSMEANS组间差值历时性比较（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=8 and ord=2),num=8);



%*-------------------------------------------------------------------------------*;
%* 图14.2.1.1.2 感觉总分-左评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
 proc format;
 	value vis
	0='基线'
	201='D2'
	202='D3'
	203='D4'
	301='D7'
	302='D14'
	303='D28'
	400='D56'
	;
quit;
 
 
 data adam;
	set adam.adqs;
	where paramn<=10 and anl01fl='是';
	if avisitn=0 then do; chg=0; pchg=0; end;
	if chg^=. or avisitn=0 then do;
	ord=2;
	res=chg;
	output;
	end;

run;

proc sort data=adam;
	by trt01pn trt01p paramn param avisitn avisit ord subjid;
run;


proc means data=adam n mean std stderr clm alpha=0.05;
	by trt01pn trt01p paramn param avisitn avisit ord  ;
	output out=means n=n mean=mean lclm=lclm uclm=uclm;
	var res;
run;

proc sort data=means out= dum(keep=trt: param:) nodupkey;
	by trt01pn paramn;
run;

data dum2;
	length avisit $100;
	set dum;
	do avisitn=0,201,202,203,301,302,303,400;
	avisit=put(avisitn,vis.);
	do ord=1 to 3;
	output;
	end;
	end;
run;

proc sort data=dum2;
	by trt01pn paramn avisitn ord ;
run;

proc sort data=means;
	by trt01pn paramn avisitn ord ;
run;

data tot;
	merge adam(keep=trt01pn paramn avisitn ord res subjid) dum2 means;
	by trt01pn paramn avisitn ord ;
	if n=. then n=0;
	rename res=chg;
	drop _:;
run;
 
%macro q(con=,num=);
data qc&num;
	set tot(where=(&con));
	drop paramn ord param;
	label trt01p=' ' trt01pn=' ' param=' ' avisit=' ' avisitn=' ' n=' ' mean=' '  lclm=' ' uclm=' ' subjid =' ';
run;
 
%mend;

%q(con=%str(paramn=1 and ord=2),num=1_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.2.2 感觉总分-右评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=2 and ord=2),num=2_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.3.2 感觉总分评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=3 and ord=2),num=3_2);

%*-------------------------------------------------------------------------------*;
%* 14.2.1.4.2 针刺觉总分评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=4 and ord=2),num=4_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.5.2 轻触觉总分评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=5 and ord=2),num=5_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.6.2 运动总分-左评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=6 and ord=2),num=6_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.7.2 运动总分-右评分较基线变化值mean+CI-时间图（FAS） ;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=7 and ord=2),num=7_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.8.2 运动总分评分较基线变化值mean+CI-时间图（FAS） ;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=8 and ord=2),num=8_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.9.2 上肢运动评分评分较基线变化值mean+CI-时间图（FAS）;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=9 and ord=2),num=9_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.10.2  下肢运动评分较基线变化值mean+CI-时间图（FAS） ;
%*-------------------------------------------------------------------------------*;
%q(con=%str(paramn=10 and ord=2),num=10_2);






%*-------------------------------------------------------------------------------*;
%* 图14.2.1.1.2.1 感觉总分-左评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
 proc format;
 	value vis
	0='基线'
	201='D2'
	202='D3'
	203='D4'
	301='D7'
	302='D14'
	303='D28'
	400='D56'
	;
	value p
	3='Pooled'
	5='Placebo'
	;
quit;
 
 %macro q(num=,model=,paramn=);
 data adam;
	set adam.adqs;
	where paramn=&paramn and anl01fl='是'  and avisitn<=303 and fasfl='是';
	if trt01pn=99 then trt01pn=5;
	else if trt01pn=4 or trt01pn=5 then trt01pn=trt01pn-1;
	else trt01pn=trt01pn;
run;

proc sort data=adam;
	by paramn usubjid  trt01pn avisitn;
run;


ods trace on;
proc mixed data=adam;
  	class trt01pn avisitn  subjid;
  	model chg= trt01pn base avisitn trt01pn*avisitn/ddfm=kr solution ;
  	repeated avisitn/subject=subjid type=&model;
  	lsmeans trt01pn*avisitn/diff cl om;
	
	ods output lsmeans=lsmeans;
run;
ods trace off;


proc sort data=adam out= dum(keep=trt: param:) nodupkey;
	by trt01pn paramn;
run;

data dum2;
	length avisit $100;
	set dum;
	do avisitn=0,201,202,203,301,302,303;
	avisit=put(avisitn,vis.);
	output;
	end;
run;

proc sort data=adam;
	by trt01pn avisitn ;
run;

data tot;
	length tr01pg1 $200;
	merge Adam(keep=trt01pn avisitn subjid chg) dum2 lsmeans;
	by trt01pn avisitn;
	if trt01pn^=3 and trt01pn^=5 then delete;
	if avisitn=0 then do; chg=0; estimate=0; end;
	tr01pg1=put(trt01pn,p.);
	label avisitn=' ' estimate=' ' subjid=' ' chg=' ' lower=' ' upper=' ';
	format _all_;
	informat _all_;
	keep estimate subjid chg lower upper avisitn tr01pg1;
run;

%mend;

%q(model=un,paramn=1,num=1_2);



%*-------------------------------------------------------------------------------*;
%* 图14.2.1.2.2.1 感觉总分-右评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
%q(model=toeph,paramn=2,num=2_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.3.2.1 感觉总分评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
%q(model=toeph,paramn=3,num=3_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.4.2.1 针刺觉总分评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=4,num=4_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.5.2.1 轻触觉总分评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=5,num=5_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.6.2.1 运动总分-左评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	 	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=6,num=6_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.7.2.1 运动总分-右评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=7,num=7_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.8.2.1 运动总分评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS）  	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=8,num=8_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.9.2.1 上肢运动评分评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS）  	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=9,num=9_2);

%*-------------------------------------------------------------------------------*;
%* 图14.2.1.10.2.1 下肢运动评分较基线变化值lsmean+CI-时间图-1200和2400合并（FAS） 	;
%*-------------------------------------------------------------------------------*;
%q(model=un,paramn=10,num=10_2);



%*-------------------------------------------------------------------------------*;
%* VAS评分图;
%*-------------------------------------------------------------------------------*;
 
proc format;
	invalue $namec
	'nt'='例数（缺失）'
	'mean_std'='平均值（标准差）' 
 	'med'='中位数' 
	'q1_q3'='四分位数（Q1，Q3）' 
	'min_max'='最小值，最大值';
 
	invalue namen
	'nt'=1
	'mean_std'=2 
 	'med'=3 
	'q1_q3'=4 
	'min_max'=5;

	invalue atrtn
	'3mg/kg或200mg'=1
	'600mg'=2
	'1200mg'=3
	'2400mg'=4
	'4800mg'=5
	'安慰剂'=6
;
quit; 

 
**-- 1 adam data ***;
data adsl0;
	set adam.adsl;
	where fasfl='是';
	length atrt $200;
	atrt=trt01p;
	atrtn=input(atrt,atrtn.);
	output;
	atrtn=7;
	atrt='汇总';
	output;
run;

proc sql noprint;
	create table subn as
	select count(distinct usubjid) as totn,atrtn,atrt from adsl0 group by atrtn,atrt;

	select count(distinct usubjid) into: plbyn from adsl0 where find(trt01p,'安慰剂')>0;
quit;

data _null_;
	set subn;
	by atrtn atrt;
	call symput("cola"||strip(put(atrtn,best.)),cats(atrt));
	call symput("totn"||strip(put(atrtn,best.)),cats(totn));
run;

%if &plbyn.=0 %then %do;
	%let cola6=安慰剂组;
	%let totn6=0;
%end;

data raw0;
	set adam.adqs;
	where fasfl='是' and parcat1='视觉模拟评分'  and anl01fl='是';
	if index(strip(put(aval,best.)),'.')>0 then dec1=find(reverse(strip(put(aval,best.))),'.')-1;
	else dec1=0;
	if index(strip(put(chg,best.)),'.')>0 then dec2=find(reverse(strip(put(chg,best.))),'.')-1;
	else dec2=0;
	if index(strip(put(pchg,best.)),'.')>0 then dec3=find(reverse(strip(put(pchg,best.))),'.')-1;
	else dec3=0;
	length atrt $200;
	atrt=trt01p;
	atrtn=input(atrt,atrtn.);
	output;
	atrtn=7;
	atrt='汇总';
	output;
run;

%macro stat_visit(indtc=,out=);
ods trace on;
proc tabulate data=&indtc.;
  class paramcd atrtn avisitn;
  var aval chg pchg;
  table paramcd*atrtn,avisitn,(aval chg pchg)*(n mean stddev median q1 q3 min max);
  ods output table=tbout;
run;
ods trace off;

**得到最大小数位，合并统计量 **;
%macro dec_stat(pre=,ord=);
proc sort data=raw0 out=avisit(keep=paramn avisitn avisit) nodupkey;
	by paramn avisitn ;
run;

proc sql noprint;
	create table dec&ord. as 
	select distinct paramcd,param,paramn,max(dec&ord.) as dec from &indtc.
	group by paramcd,param,paramn order by paramcd;
quit;

data stat&ord.;
	merge tbout dec&ord.;
 	by paramcd;
	length nt mean_std med q1_q3 min_max $200;
	%do i=1 %to 7;
	if atrtn=&i. and .<&pre._n<=&&totn&i. then nt=strip(put(&pre._n,best.))||' ('||strip(put(&&totn&i.-&pre._n,best.))||')';
	%end;

	if &pre._n>0 then do;
	if nmiss(&pre._stddev,&pre._mean)=0 then mean_std=strip(putn(round(&pre._mean,0.1**min(4,dec+1)),cats(12.0+min(4,dec+1)/10)))|| ' ('||strip(putn(round(&pre._stddev,0.1**min(4,dec+2)),cats(12.0+min(4,dec+2)/10)))||')';
		else if &pre._mean^=. and &pre._stddev=. then mean_std=strip(putn(round(&pre._mean,0.1**min(4,dec+1)),cats(12.0+min(4,dec+1)/10)))|| ' (-)';
		else mean_std='- (-)';
	if &pre._mean^=. and input(strip(scan(mean_std,1,"(")),best.)=0 and substr(mean_std,1,1)='-' then mean_std=substr(mean_std,2);
	if &pre._median^=. then med=strip(putn(round(&pre._median,0.1**min(4,dec+1)),cats(12.0+min(4,dec+1)/10)));
		else med='-';
	if &pre._n>0 then q1_q3=strip(putn(round(&pre._q1,0.1**min(4,dec+1)),cats(12.0+min(4,dec+1)/10)))|| ', '||strip(putn(round(&pre._q3,0.1**min(4,dec+1)),cats(12.0+min(4,dec+1)/10)));
		else q1_q3='-, -';
	if &pre._n>0 then min_max=strip(putn(round(&pre._min,0.1**min(4,dec)),cats(12.0+min(4,dec)/10)))|| ', '||strip(putn(round(&pre._max,0.1**min(4,dec)),cats(12.0+min(4,dec)/10)));
		else min_max='-, -';
	end;
	ord1=&ord;
	keep paramcd param paramn ord1 nt mean_std med q1_q3 min_max avisitn atrtn;
run;

proc sort data=stat&ord.;
	by ord1 paramn paramcd param avisitn atrtn;
run;

proc transpose data=stat&ord. out=stat&ord.t prefix=col name=name;
	by ord1 paramn paramcd param avisitn;
	id atrtn;
	var nt mean_std med q1_q3 min_max;
run;
%mend;

%dec_stat(pre=AVAL,ord=1);
%dec_stat(pre=chg,ord=2);
%dec_stat(pre=pchg,ord=3);

** 合并三部分 整理成输出格式 **;

data &out.;
	set stat1t stat2t(where=(avisitn>0.5)) stat3t(where=(avisitn>0.5));
	array col col1-col7;
	do over col;
		if col='' then col='-';
	end;
run;
proc sort data=tot01;
	by paramn avisitn ord1;
run;
%mend;

%stat_visit(indtc=raw0,out=tot01);

data tot02(keep=txt1n ord ord1 ord2 txt1 txt2 col1-col7 param paramn);
	length txt1 txt2 col1-col7 $200;
	merge tot01 avisit;
	by paramn avisitn;
	if first.avisitn then txt1n+1;
	if ord1=1 then txt1="  "||strip(avisit);
	else if ord1=2 then txt1="  "||cats(avisit,'较基线变化值');
	else if ord1=3 then txt1="  "||cats(avisit,'较基线变化百分比');
	txt2=strip(input(lowcase(name),$namec.));
	ord2=input(lowcase(name),namen.);
	ord=1;
run;

proc sort data=tot02;
	by paramn ord txt1n ord1 ord2;
run;

data tot03;
	set tot02;
	by paramn ord txt1n ord1 ord2;
	if first.ord1 then tmpord+1;
	pg=ceil(tmpord/2);
run;

proc sort data=tot03;
	by pg paramn ord txt1n ord1 ord2;
run;

data final;
	set tot03;
	by pg paramn ord txt1n ord1 ord2;
	output;
	if first.paramn then do;
		txt1=param;
		call missing(txt2,col1,col2,col3,col4,col5,col6,col7);
		ord=0;
		output;
	end;
run;
proc sort data=final;
	by pg paramn ord txt1n ord1 ord2;
run;
