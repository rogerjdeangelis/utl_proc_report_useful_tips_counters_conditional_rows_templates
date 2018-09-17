Proc report useful tips counters conditional rows templates

github
https://tinyurl.com/yat3vzuz
https://github.com/rogerjdeangelis/utl_proc_report_useful_tips_counters_conditional_rows_templates

  Tips

    1. Overall sequence number
    2. Sequence number by groups
    3. Proc report panels
    4  Conditional lines
    5. Proc report lidt option
    6. Dosubl- where age is less than median age
    7. Create a sorted, summarized and transposed dataset

see
https://tinyurl.com/y7m6g4z2
https://communities.sas.com/t5/SAS-Programming/how-to-assign-sequence-number-in-proc-report/m-p/496014

HAVE
====

  SASHELP.CLASS


EXAMPLE OUTPUTS
---------------

 1. Overall sequence number
 --------------------------

  Sequence  NAME     SEX        AGE
         1  Alfred    M         14
         2  Alice     F         13
         3  Barbara   F         13
         4  Carol     F         14
         5  Henry     M         14
         6  James     M         12


 2. Sequence number by groups
 ----------------------------

  Sex Seq  Patient     Patient
   F    1  Alice            13
        2  Barbara          13
        3  Carol            14
        4  Jane             12
        5  Janet            15
        6  Joyce            11
        7  Judy             14
        8  Louise           12
        9  Mary             15

   M    1  Alfred           14
        2  Henry            14
        3  James            12
        4  Jeffrey          13
        5  John             12
        6  Philip           16
        7  Robert           12
        8  Ronald           15
        9  Thomas           11
       10  William          15


 3. Proc report panels
 ---------------------

   NAME    SEX      AGE    NAME    SEX      AGE
   Alfred   M        14    Louise   F        12
   Alice    F        13    Mary     F        15
   Barbara  F        13    Philip   M        16
   Carol    F        14    Robert   M        12
   Henry    M        14    Ronald   M        15
   James    M        12    Thomas   M        11
   Jane     F        12    William  M        15
   Janet    F        15
   Jeffrey  M        13
   John     M        12
   Joyce    F        11
   Judy     F        14


 4  Conditional lines
 --------------------

   SEX  NAME            AGE
   F    Alice            13
        Barbara          13
        Carol            14
        Jane             12
        Janet            15
        Joyce            11
        Judy             14
   ------------------------  Line after Judy
        Louise           12
        Mary             15
   M    Alfred           14
        Henry            14
        James            12
        Jeffrey          13
        John             12
        Philip           16
        Robert           12
        Ronald           15
        Thomas           11
        William          15


 5. Proc report lidt option
 --------------------------

    proc report data=sashelp.class missing list;
    run;quit;

    PROC REPORT DATA=SASHELP.CLASS LS=171 PS=66  SPLIT="/" NOCENTER MISSING ;
    COLUMN  NAME SEX AGE HEIGHT WEIGHT;

    DEFINE  NAME / DISPLAY FORMAT= $8. WIDTH=8     SPACING=2   LEFT "NAME" ;
    DEFINE  SEX / DISPLAY FORMAT= $1. WIDTH=1     SPACING=2   LEFT "SEX" ;
    DEFINE  AGE / SUM FORMAT= BEST9. WIDTH=9     SPACING=2   RIGHT "AGE" ;
    DEFINE  HEIGHT / SUM FORMAT= BEST9. WIDTH=9     SPACING=2   RIGHT "HEIGHT" ;
    DEFINE  WEIGHT / SUM FORMAT= BEST9. WIDTH=9     SPACING=2   RIGHT "WEIGHT" ;
    RUN;


 6. Dosubl- where age is less than median age
 --------------------------------------------

    NAME     SEC       AGE     HEIGHT     WEIGHT
    James     M         12       57.3         83
    Jane      F         12       59.8       84.5
    John      M         12         59       99.5
    Joyce     F         11       51.3       50.5
    Louise    F         12       56.3         77
    Robert    M         12       64.8        128
    Thomas    M         11       57.5         85


 7. Sort, summarize and transpose
 --------------------------------

 WANT total obs=2 (output dataset from proc report)

  SEX    WEIGHT    MAXHEIGHT    MINHEIGHT   TWELVE    THIRTEEN    FOURTEEN

   F      536.0       65.3         56.3        2          2           2
   M      609.5       69.0         57.3        3          1           2

PROCESS
=======

 1. Overall sequence number
 ---------------------------

  KSharp
  https://communities.sas.com/t5/user/viewprofilepage/user-id/18408

  proc report data=sashelp.class nowd;
  columns n name sex age ;
  define n/computed 'Sequence';
  define name/display;
  compute n;
   _n+1;
   n=_n;
  endcomp;
  run;

 2. Sequence number by groups
 ----------------------------

  options nocenter;
  proc report data=sashelp.class nowd;
  columns sex count name age;
  define sex    / order;
  define count  / computed 'Seq' f=3.;
  define name   / display 'Patient';
  define age   / display 'Patient';
  compute before sex;
  cnt=0;
  endcomp;
  compute count;
  cnt+1;
  count=cnt;
  endcomp;
  run;quit;

 3. Proc report panels
 ---------------------

  options ps=15;
  proc report data=sashelp.class panels=2 pspace=3 spacing=1 split='\';
    columns name sex age;
  run;quit;
  options ls=66;


 4. Conditional lines
 ---------------------

   proc report data=sashelp.class nowd;
   columns sex name age;
   define sex / order width=3 spacing=0;
   define name / order;
   define age / display;
   compute after name;
     msg="------------------------";
     if name ne "Judy" then len=0;
     else len=24;
     line @1 msg $varying24. len;
   endcomp;
   run;quit;


 5. Proc report list option
 ---------------------------

    proc report data=sashelp.class missing list;
    run;quit;

    PROC REPORT DATA=SASHELP.CLASS LS=171 PS=66  SPLIT="/" NOCENTER MISSING ;
    COLUMN  NAME SEX AGE HEIGHT WEIGHT;

    DEFINE  NAME / DISPLAY FORMAT= $8. WIDTH=8     SPACING=2   LEFT "NAME" ;
    DEFINE  SEX / DISPLAY FORMAT= $1. WIDTH=1     SPACING=2   LEFT "SEX" ;
    DEFINE  AGE / SUM FORMAT= BEST9. WIDTH=9     SPACING=2   RIGHT "AGE" ;
    DEFINE  HEIGHT / SUM FORMAT= BEST9. WIDTH=9     SPACING=2   RIGHT "HEIGHT" ;
    DEFINE  WEIGHT / SUM FORMAT= BEST9. WIDTH=9     SPACING=2   RIGHT "WEIGHT" ;
    RUN;


 6. Dosubl- where age is less than median age
 ---------------------------------------------

    proc report data=sashelp.class
      (where=( 0=%sysfunc(dosubl('
          proc sql noprint; select median(age) into :age from sashelp.class;quit;
      ')) and age lt symgetn("age") )) missing nowd;
    run;quit;


 7. Sort, summarize and transpose
 --------------------------------

    proc report data=sashelp.class(
                where=(age in (12,13,14)))
                out=want(rename=(_c2_=Twelve _c3_=Thirteen _c4_=Fourteen))
                nowd missing;
    cols sex age weight height=maxheight height=minheight;
    define sex / group 'Sex';
    define maxheight / analysis max "Max Height";
    define minheight / analysis min "Min Height";
    define age / across  'Ages';
    run;quit;

OUTPUT
======

see above

