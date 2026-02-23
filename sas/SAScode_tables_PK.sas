%*-------------------------------------------------------------------------------*;
%* 图14.4.1.1 平均ALMB-0166 (ng/ml) 随时间变化曲线（PKCS）;
%*-------------------------------------------------------------------------------*;
 
data adpc;
	set adam.adpc;
	*单位转化：1000ng=1ug;
	aval=aval/1000;
	where PKCSFL='是' and anl03fl='是' and param='血清ALMB-0166（ng/mL）' and trt01p^='安慰剂' and ^missing(aval);
run; 
proc sort;
	by param visitnum visit atptn atpt trt01pn trt01p usubjid;
run;
 
proc means data=adpc noprint;
	by param visitnum visit atptn atpt trt01pn trt01p;
	var aval;
	output out=m1  mean=mean std=_std;
run;

data final;
	set m1;
	if _std>. then yup=mean+_std;
	else yup=mean;
	if _std>. then ylo=mean-_std;
	else ylo=mean;
	if yup>0 then yup_log=yup;
	if ylo>0 then ylo_log=ylo;
	if mean>0 then mean_log=mean;
	drop _:;
 	format _all_;
	informat _all_;
run;

proc datasets lib=work nolist;
 	modify final;
 	attrib _all_ label="";
quit;


%*-------------------------------------------------------------------------------*;
%* 表14.4.1.2 ALMB-0166PK参数汇总表（PKPS）;
%*-------------------------------------------------------------------------------*;

proc format;
	invalue $txt
	"col1"="n" 
 	"col2"="Mean" 
	"col3"="SD" 
	"col4"='%CV' 
	"col5"="Q1" 
	"col6"="Median" 
	"col7"="Q3" 
	"col8"="Min" 
	"col9"="Max" 
	"col10"="GeoMean" 
	"col11"="Geo.SD"
	"col12"='%CV@{sub b}'
;
quit;

%macro SigDec(invar,outvar,dec);
	length varformat varprx bvarprx $200;
	var = &invar.;
	if var ^= 0 then do;
		dec = &dec.;
		varprx = compress(vvalue(var));
		varprx1 = strip(kscan(varprx,1,'.'));
		varheader = length(compress(varprx1,'-',''));
		if varprx1 not in ('0','-0') then var1 = var/10**varheader;
		else var1 = var;
		bvarprx = compress(vvalue(var1));
		bvarprx1 = strip(kscan(bvarprx,1,'.'));
		bvarprx2 = strip(kscan(bvarprx,2,'.'));
		bvarindex = indexc(bvarprx2,'123456789');
		varformat = strip("12.")||strip(put(bvarindex+dec-1,12.))||strip(".");
		&outvar. = strip(putn(var1,varformat));
		bvarformat = strip("12.")||strip(put(dec-length(compress(varprx1,'-','')),??best12.))||strip(".");
    	if length(compress(varprx1,'-',''))>(dec-1) then &outvar. = strip(put(input(&outvar.,??best12.)*(10**varheader),??best.));
    	else if compress(varprx1,'-','')^='0' then &outvar. = strip(putn(input(&outvar.,??best12.)*(10**varheader),bvarformat));
  	end;
  	else if var = 0 then do;
		&outvar.='0';
  	end;
    drop var dec varprx varprx1 varheader var1 bvarprx bvarprx1 bvarprx2 bvarindex varformat bvarformat;
%mend; 
 

data adsl0;
	set adam.adsl(where=(PKPSFL='是'));
	length grp $200;
	grp=trt01a;
	grpn=trt01an;
run;  
 
proc sql noprint;
/*N */
	create table bign as
	select cats(grp)||"@n(N="||cats(count(usubjid))||")" as grp2,grp,grpn 
	from adsl0 group by grpn,grp;
quit;

data _adpp00;
	set adam.adpp(where=(PKPSFL='是'));
	length grp $200;
	grp=trt01a;
	grpn=trt01an;
	dec=ifn(find(avalc,'.')>0,length(scan(avalc,2,'.')),0);/* for cmax */
run;

proc sort data=_adpp00;
	by grpn grp;
run;

data adpp0;
	merge _adpp00 bign;
	by grpn grp;
run;
proc sort data=adpp0;
	by grpn grp grp2 paramn;
run;

proc sql noprint;
	create table dec as
	select max(dec) as dec,grp2,grp,grpn,paramn
	from adpp0 group by grpn,grp,grp2,paramn;
quit;

proc means data=adpp0(where=(^missing(aval))) noprint;
	by grpn grp grp2 paramn;
	var aval;
	output out=_m1 n=n2 mean=mean2 std=sd2 median=median2 cv=cv2 min=min2 max=max2 q1=q12 q3=q32;
run;

**计算CVb、GeoMean、GMStdErr**;
data cvb;
	set adpp0(where=(aval>0));
	ln=log(aval);
run;
proc sort data=cvb;
	by grpn grp grp2 paramn;
run;

proc means data=cvb noprint;
	by grpn grp grp2 paramn;
	var ln;
	output out=_m2 std=cvbstd mean=a_mean stddev=a_stddev;
run;

data total01;
	merge _m2(drop=_TYPE_ _FREQ_) _m1(drop=_TYPE_ _FREQ_) dec;
	by grpn grp grp2 paramn ;

	length COL1-COL12 $200;
	col1=cats(n2);

	if ^missing(mean2) then col2=strip(put(round(mean2,0.01),12.2));
	if ^missing(sd2) then col3=strip(put(round(sd2,0.01),12.2));
	if ^missing(cv2) then col4=strip(put(round(cv2,0.1),12.1));
	if ^missing(q12) then col5=strip(put(round(q12,0.01),12.2));
	if ^missing(median2) then do;
		if paramn=2 then col6=strip(put(round(median2,0.1**dec),12.1));
		else do;
			%SigDec(median2,col6,3);
		end;
	end;
	if ^missing(q32) then col7=strip(put(round(q32,0.01),12.2));
	if ^missing(min2) then do;
		if paramn=2 then col8=strip(put(round(min2,0.1**dec),12.1));
		else do;
			%SigDec(min2,col8,3);
		end;
	end;
	if ^missing(max2) then do;
		if paramn=2 then col9=strip(put(round(max2,0.1**dec),12.1));
		else do;
			%SigDec(max2,col9,3);
		end;
	end;
	if ^missing(a_mean) then col10=strip(put(round(exp(a_mean),0.01),12.2));
	if ^missing(a_stddev) then col11=strip(put(round(exp(a_stddev),0.01),12.2));
	if ^missing(cvbstd) then col12=strip(put(round(sqrt(exp(cvbstd**2)-1)*100,0.1),12.1));
run;
proc transpose data=total01 out=total01t prefix=COL;
	by grpn grp grp2;
	id paramn;
	var col1-col12;
run;

data total02;
	set total01t;
	length TXT1 TXT2 $200;
	TXT1=grp2;
	TXT2=input(lowcase(_NAME_),$txt.);
	label TXT1="剂量组|（mg）" TXT2="统计量" 
		COL1="T@{sub max}|(h)" COL2="C@{sub max}|(ug/mL)" COL3="AUC@{sub 0-t}|(h*mg/mL)" 
		COL4="AUC@{sub 0-∞}|(h*mg/mL)" COL5='%AUC@{sub ex}|(%)'
		COL6="λ@{sub z}|(10@{super -3}×1/h)" COL7="t@{sub 1/2}|(h)" COL8="V|(L)" COL9="CL|(mL/h)";
	TXT2n=input(compress(_name_,,'dk'),best.);
	array col col1-col9;
	do over col;
		if col='' then col='-';
	end;
	if txt2n in (2,3,4,10,11,12) then call missing(col1);
	keep grpn grp COL1-COL9 TXT1 TXT2 TXT2n;
run;

proc sort data=total02 out=final(keep=COL1-COL9 TXT1 TXT2);
	by grpn TXT2n;
run; 
 