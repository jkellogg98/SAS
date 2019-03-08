libname hw2 '/home/jkellogg3/pstat130/';

data annual_int;    *creates dataset annual_int, initial at 1000, calculates balance and outputs balance after each year;
balance = 1000;
interest = 4.25;
increase = (interest/100)+1;
do year = 1 to 5;
	balance = increase*balance;
	output;
keep balance year;		*keeps only balance and year; 
end;
run;

proc print data = annual_int noobs;  *prints annual_int, without obs, with a title, and balance dollar formatted;
title1 'Balance with 4.25% Interest After 5 Years';
format balance dollar9.2;
run;

*2;
*A;

data tot_pass;   *creates dataset tot_pass, set as sfosch, and sums the total passengers per flight. If BClassPass equals '.', it doesnt include it in the sum; 
set hw2.sfosch;
if BClassPass eq . then tot_pass = FClassPass + EClassPass;
else tot_pass = FClassPass + BClassPass + EClassPass;
run;


data tot_pass_day (keep= date tot_pass_day);    *creates dataset tot_pass_day (keeping only date and tot_pass_day), set as tot_pass, and uses first.date and last.date and a sum statement to calculate the total passengers for each date;
set tot_pass;
by date;
if First.date then tot_pass_day = 0;
tot_pass_day + tot_pass;
if Last.date;
run;
proc print data = tot_pass_day;     *prints tot_pass_day with appropriate title;
title1 'Total Passengers Per Day';
run;

*B;

data tot_cap_day (keep = date tot_cap_day);    *creates dataset tot_cap_day (keeping only date and tot_cap_day), set as tot_pass, and uses first.date, last.date, and a sum statement to calculate total pass cap for each date; 
set tot_pass;
by date;
if First.date then tot_cap_day = 0;
tot_cap_day + TotPassCap;
if Last.date;
run;

data full_pass;     *creates dataset full_pass as the merged datasets of tot_pass_day and tot_cap_day, merged by date. Uses those two variables to calculate total cap percentage for each date.;
merge tot_pass_day tot_cap_day;
by date;
perc_pass_cap = (tot_pass_day / tot_cap_day);
format perc_pass_cap percent8.2;
run;
proc print data=full_pass;      *prints full_pass with appropriate title;
title1 'Total Pass Capacity Per Day';
run;

*C;

*December 28th, 2000 reported %110.5 capacity which is far over max capacity.;

*3;
*A;

data raw_lab;
infile '/home/jkellogg3/pstat130/labdata.txt';     *reads in labdata.txt and inputs variables ID, Value, and VD(character value);
input ID VD$ Value;
run;

data clean_lab;     *creates dataset clean_lab, set as raw_lab, and reads in first observation as observation 6 which is where the data starts.;
set raw_lab(firstobs=6);
run;

data raw_rand;
infile '/home/jkellogg3/pstat130/randdata.txt';    *reads in randdata.txt and inputs variables ID, Trt(character value);
input ID Trt$;
run;

data clean_rand;	 *creates dataset clean_rand, set as raw_rand, and reads in first observation as observation 5, where the data starts.;
set raw_rand(firstobs=5);
run;

*B;

proc format;	 *creates a treatment format for variable trt with Active and Placebo as A and P;
value $treatment  	'A' = 'Active'
					'P' = 'Placebo';
run;


proc print data=clean_rand;        *prints the dataset clean_rand with format and title applied;
	format trt $treatment.;
	title1 'Data with Trt Format';
run;

	
*C;

proc sort data=clean_lab;   *sorts clean_lab by ID then VD;
by ID VD;
run;	

data measure_change;     *creates dataset measure_change, set as clean_lab, and uses the first.id and last.id functions to calculate the change from BL to M6 for each obs.;
set clean_lab;
by ID;
if First.ID then do;
BaseVal = Value;
Change = .;
end;
if Last.ID then do;
Change = BaseVal - Value;
output;
end;
retain;
run;


proc print data=measure_change label;	*prints measure_change with title, labels for Change and Value, only prints ID, BaseVal, Value, and Change;
label Change = 'Change in Measure after 6 Months'
		Value = 'Value at Month 6';
var ID BaseVal Value Change;
title1 'BaseVal - M6';
run;

*D;
	
data merged_data;	*creates dataset merged_data and merges clean_rand and measure_change by ID;
merge clean_rand measure_change;
by ID;
run;
 

proc sort data=merged_data out = sorted_data;    *sorts merged_data by trt and outputs into new dataset sorted_data;
by trt;
run;


proc means data=sorted_data n mean std;	*creates table of means and standard deviations for baseline values and change values for each treatment level;
var BaseVal Change; 
by trt;
output out = means_trt;
title1 'Means For Trt Groups';
run;


*E;

proc print data=merged_data; 	*prints merged_data and only includes observations where BaseVal > 1000. Formats trt using the user-defined format and formats BaseVal using simple 4.0 format.;
where BaseVal > 1000;
var ID trt BaseVal;
format trt $treatment.
BaseVal 4.0;
title1 'BaseVals Greater than 1000';
run;




























