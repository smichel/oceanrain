close all;
clear;
formatSpec_PSD_na=    strcat('%08i %08i %04i %04i %12.6f %12i %8.4f %9.4f %7.2f %7.2f %7.2f %5i %5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f', repmat('%12.4f ',1,128),'\r\n');
formatSpec_PSD_num_na=strcat('%08i %08i %04i %04i %12.6f %12i %8.4f %9.4f %7.2f %7.2f %7.2f %5i %5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f', repmat('%12i ',1,128),'\r\n');
% Variable  c,   date,time,mmday,kc,  UTC,  lat,  lon,  head,temp,  dewt,wtemp,rh ,pres,relF,relD,trueF,trueD,rad1,vis,ceil,maxFF,sal,gauge,ww,   w1, w2,  perc99,train,tsnow,rpar,spar,mpar,flag,flag20,bins,nums,precip,refl,dbr,dbz,wind,uref
formatSpec_or='%08i %08i %04i %04i %10.6f %12i %8.4f %9.4f %5.1f %5.1f %5.1f %5.1f %4i %6.1f %4.1f %4i %4.1f %3i %6.1f %6i %6i %5.1f %6.2f %6.2f % 03i % 03i % 03i %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f % 5i % 5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f\r\n';
formatSpec_firstLine=strcat(repmat('%8.4f ',1,128),'\r\n');
firstLine=[0.0375  0.0632  0.0896  0.1166  0.1443  0.1727  0.2018  0.2316  0.2621  0.2934  0.3255  0.3583  0.3920  0.4266  0.4619  0.4982  0.5353  0.5734  0.6124  0.6524  0.6934  0.7354  0.7784  0.8225  0.8677  0.9140  0.9615  1.0101  1.0600  1.1111  1.1634  1.2171  1.2720  1.3284  1.3861  1.4453  1.5059  1.5681  1.6318  1.6970  1.7639  1.8324  1.9027  1.9747  2.0484  2.1240  2.2015  2.2809  2.3622  2.4456  2.5311  2.6186  2.7084  2.8003  2.8946  2.9911  3.0901  3.1915  3.2955  3.4020  3.5112  3.6230  3.7377  3.8552  3.9755  4.0989  4.2254  4.3550  4.4877  4.6238  4.7633  4.9062  5.0527  5.2028  5.3566  5.5142  5.6758  5.8413  6.0110  6.1848  6.3630  6.5456  6.7327  6.9244  7.1210  7.3223  7.5287  7.7402  7.9570  8.1791  8.4067  8.6400  8.8790  9.1240  9.3750  9.6323  9.8960 10.1662 10.4431 10.7269 11.0177 11.3157 11.6211 11.9341 12.2548 12.5835 12.9203 13.2655 13.6193 13.9818 14.3533 14.7341 15.1242 15.5241 15.9339 16.3538 16.7841 17.2251 17.6771 18.1402 18.6149 19.1013 19.5998 20.1106 20.6341 21.1706 21.7204 22.2838];
% parameter list for data
% 01: discontinuous /continuous count % 02: date (ddmmyyyy) % 03: time (hhmm) % 04: mmday
% 05: julian date (cont. count) % 06: unix time (cont. count) % 07: latitude % 08: longitude
% 09: heading % 10: temperature % 11: dewpoint temperature (nicht für sonne2) % 12: water temperature
% 13: relative humidity % 14: pressure % 15: relFF % 16: relDD % 17: trueF F % 18: trueDD
% 19: global radiation (nicht für sonne2)% 20: visibility (nicht für sonne2) % 21: ceiling (nicht für meteor, sonne2)
% 22: max FF (gusts) (nicht für meteor, sonne2)% 23: salinity % 24: gauge precip (nicht für sonne2)
% 25: ww (nicht für sonne2)% 26: w1 (nicht für sonne2)% 27: w2 (nicht für sonne2) % 28: 99% precentile
% 29: theo rain rate % 30: theo snow rate % 31: rain probability % 32: snow probability % 33: mix probability
% 34: flag1: 0 rain,1 snow,2 mixed-phase,3 true-zero,4 out of order,5
% harbor % 35: flag2: -9 harbor/out of order, 10 true 0, 11 false measurements, 12-17 intensities
% see parameter list for detailed informations
% 36: number of bins allocated % 37: number of particles % 38: precip rate according to parameters 31-33
% 39: reflectivity % 40: dBR % 41: dBZ % 42: relative windspeed (anemometer) % 43: anemometer relFF 
%data=vertcat(load('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt'),load('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt'),load('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt'),load('joint_investigator_disdro_2016T01-2016T02_colloc_cont_ww_na.txt'));
data_name_V3=('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt');
%data_name_V1=('joint_investigator_disdro_2017V01-2017V02_colloc_cont_ww_na.txt');
data=load(data_name_V3);
%c_data=load('joint_investigator_disdro_2016T01-2016V04_colloc_cont_ww_na_ancillary_checked.txt');
T=data(:,10);
G_Pre=data(:,24);
G_Pre(G_Pre<0)=0;
P=data(:,38);
T(T>45)=T(T>45)-65.3;
k=1;
c_P=P;


data(data(:,6)==1453433640,7)=-50.9224;
data(data(:,6)==1453433640,8)=75.3376;
changed={[1453433640 7]};
changed=[changed,{[1453433640 8]}];


j=1;
for i=2:size(data,1)-1
    if (data(i,38)>10 & data(i,24) ==-99.99)
        susp(k,1)=i;
        susp(k,2)=data(i,29);
        susp(k,3)=data(i,30);
        k=k+1;
    elseif data(i,24) ==-99.99 & (abs(data(i-1,38)-data(i,38))>15 | abs(data(i,38)-data(i+1,38))>15)
        susp(k,1)=i;
        susp(k,2)=data(i,29);
        susp(k,3)=data(i,30);
        k=k+1;
    end
    if ((data(i,6)>=1454835300) & (data(i,6)<=1456518900))
        data(i,34)=4;
        data(i,35)=-9;
        data(i,36)=-99;
        data(i,37)=-9999;
        data(i,38:43)=-99.99;
        changed=[changed,{[data(i,6) 34:43]}];
    end
    if (data(i,23)<20)
        data(i,23)= -99.99;
        changed=[changed,{[data(i,6) 23]}];
    end
    if (data(i,10)>=45)
        data(i,10)=data(i,10)-65.3;
        snow_susp(j)=i;
        j=j+1;
    end
    
        
end

%wrong gps data





susp=vertcat(susp(:,1),(23700:24000)');
susp=unique(susp);
susp_dd=data(susp,2);
susp_mm=data(susp,3);
susp_changed=data(susp(:),6);

snow_susp_dd=data(snow_susp,2);
snow_susp_mm=data(snow_susp,3);
snow_changed=data(snow_susp(:),6);

for i=1:length(susp)
    changed=[changed,{[susp_changed(i) 34:43]}];
end
data(data(:,6)==1466749320,7)=0;
changed=[changed,{[1466749320 7]}];
for i=1:length(snow_susp)
    changed=[changed,{[snow_changed(i) [10 34:43]]}];
end


% % PSD_na_name='joint_investigator_disdro_2016V03-2016V04_psd_na.txt';
% % PSD_num_na_name='joint_investigator_disdro_2016V03-2016V04_psd_num_na.txt';
% % PSD_na=load(PSD_na_name);
% % PSD_num_na=load(PSD_num_na_name);
% % rain_snow=load('rainsnow_data_2016V03-2016V04.txt');
% % rain=load('rain_minute_psd_num_2016V03-2016V04.dat');
% % 
% % snow_PSD_na=load('snow_minute_psd_num_2016V03-2016V04.dat');
% % snow_PSD_num_na=load('snow_minute_psd_dbz_2016V03-2016V04.dat');
% % 
% % PSD_na(2:end,1)=1:size(PSD_na,1)-1;
% % PSD_num_na(1:end,1)=2:size(PSD_num_na,1)+1;
% % PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
% % PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
% % PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);


PSD_na_name='joint_investigator_disdro_2016V03-2016V04_psd_na.txt';
PSD_num_na_name='joint_investigator_disdro_2016V03-2016V04_psd_num_na.txt';
PSD_na=load(PSD_na_name);
PSD_num_na=load(PSD_num_na_name);
rain_snow=load('rainsnow_data_2016V03-2016V04.txt');
rain=load('rain_minute_psd_num_2016V03-2016V04.dat');

snow_PSD_num_na=load('snow_minute_psd_num_2016V03-2016V04.dat');
snow_PSD_na=load('snow_minute_psd_dbz_2016V03-2016V04.dat');

PSD_na(1,:)=[];
PSD_na(1:end,1)=1:size(PSD_na,1);
PSD_num_na(1:end,1)=1:size(PSD_num_na,1);
% PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
% PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
% PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);
% PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1));
% PSD_na(2:end,1)=1:size(PSD_na(2:end,1));


[snow_lia_na,snow_loc_na]=ismember(snow_changed,PSD_na(:,6));
[snow_lia_fillin_na,snow_loc_fillin_na]=ismember(snow_susp_dd(:)+snow_susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);

[lia_na,loc_na]=ismember(susp_changed,PSD_na(:,6));
[lia_fillin_na,loc_fillin_na]=ismember(susp_dd(:)+susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);

b_loc_na=loc_na;
%snow
% 25: ww (nicht für sonne2)% 26: w1 (nicht für sonne2)% 27: w2 (nicht für sonne2) % 28: 99% precentile
% 29: theo rain rate % 30: theo snow rate % 31: rain probability % 32: snow probability % 33: mix probability
% 34: flag1: 0 rain,1 snow,2 mixed-phase,3 true-zero,4 out of order,5
% harbor % 35: flag2: -9 harbor/out of order, 10 true 0, 11 false measurements, 12-17 intensities
% see parameter list for detailed informations
% 36: number of bins allocated % 37: number of particles % 38: precip rate according to parameters 31-33
% 39: reflectivity % 40: dBR % 41: dBZ % 42: relative windspeed (anemometer) % 43: anemometer relFF 


for i=1:length(snow_susp)
    if snow_susp(i)~=0 & snow_loc_fillin_na(i)~=0 & snow_loc_na(i) ~= 0
        %Disdrodata:
        %flag 1: switched to snow
        data(snow_susp(i),34)=2;
        %flag 2: switched to the according intensity
        if rain_snow(snow_loc_fillin_na(i),11) ==0
            data(snow_susp(i),35) = 12;
        elseif rain_snow(snow_loc_fillin_na(i),11)<=0.09
            data(snow_susp(i),35) = 13;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.09 & rain_snow(snow_loc_fillin_na(i),11)<=0.99
            data(snow_susp(i),35) = 14;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.99 & rain_snow(snow_loc_fillin_na(i),11)<=10
            data(snow_susp(i),35) = 15;
        elseif rain_snow(snow_loc_fillin_na(i),11)>10   & rain_snow(snow_loc_fillin_na(i),11)<=50
            data(snow_susp(i),35) = 16;
        elseif rain_snow(snow_loc_fillin_na(i),11)>50
            data(snow_susp(i),35) = 17;
        end
        %tocheck: yyyy,mo,dd,hh,mm,%02 kc2, %03 UTC,%04 lat,%05 lon,%06 head,%07 temp,%08 dewt,%09 wtemp,%10 rh,%11 pres,
%12 relFF,%13 relDD,%14 trueFF,%15 trueDD,%16 rad1,%17 vis,%18 ceil,%19 maxFF,%20 sal,%21 gauge,%22 perc99,%23 rain,
%24 rain_bins,%25 rain_nums,%26 rain_refl,%27 rain_dbr,%28 rain_dbz,%29 snow,%30 snow_bins,%31 snow_nums,
%32 snow_refl,%33 snow_dbr,%34 snow_dbz,%35 rpar,%36 spar,%37 mpar,%38 flag,%39 precip,%40 wind,%41 uref
%fixing the oceanrain data from rain to snow
        data(snow_susp(i),36)=rain_snow(snow_loc_fillin_na(i),30); % num_bins
        data(snow_susp(i),37)=rain_snow(snow_loc_fillin_na(i),31); % num_particles
        data(snow_susp(i),38)=rain_snow(snow_loc_fillin_na(i),29); % preciprate
        data(snow_susp(i),39)=rain_snow(snow_loc_fillin_na(i),32); % reflectivity
        data(snow_susp(i),40)=rain_snow(snow_loc_fillin_na(i),33); % dBr
        data(snow_susp(i),41)=rain_snow(snow_loc_fillin_na(i),34); % dBZ
        
        %PSD_num
        
        %flag 1: switching it to snow(1)
        PSD_na(snow_loc_na(i),12)=2;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(snow_loc_fillin_na(i),11) ==0
            PSD_na(snow_loc_na(i),13) = 12;
        elseif rain_snow(snow_loc_fillin_na(i),11)<=0.09
            PSD_na(snow_loc_na(i),13) = 13;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.09 & rain_snow(snow_loc_fillin_na(i),11)<=0.99
            PSD_na(snow_loc_na(i),13) = 14;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.99 & rain_snow(snow_loc_fillin_na(i),11)<=9.99
            PSD_na(snow_loc_na(i),13) = 15;
        elseif rain_snow(snow_loc_fillin_na(i),11)>10   & rain_snow(snow_loc_fillin_na(i),11)<=49.99
            PSD_na(snow_loc_na(i),13) = 16;
        elseif rain_snow(snow_loc_fillin_na(i),11)>50
            PSD_na(snow_loc_na(i),13) = 17;
        end
        
        PSD_na(snow_loc_na(i),14)=rain_snow(snow_loc_fillin_na(i),12); % num_bins
        PSD_na(snow_loc_na(i),15)=rain_snow(snow_loc_fillin_na(i),13); % num_particles
        PSD_na(snow_loc_na(i),16)=rain_snow(snow_loc_fillin_na(i),11); % preciprate
        PSD_na(snow_loc_na(i),17)=rain_snow(snow_loc_fillin_na(i),14); % reflectivity
        PSD_na(snow_loc_na(i),18)=rain_snow(snow_loc_fillin_na(i),15); % dBr
        PSD_na(snow_loc_na(i),19)=rain_snow(snow_loc_fillin_na(i),16); % dBZ
        
        PSD_na(snow_loc_na(i),22:149)=snow_PSD_na(snow_loc_fillin_na(i),5:132); %bins
        
        
        
        
        %PSD_num_na
        
        %flag 1: switching it to snow(1)
        PSD_num_na(snow_loc_na(i),12)=2;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(snow_loc_fillin_na(i),11) ==0
            PSD_num_na(snow_loc_na(i),13) = 12;
        elseif rain_snow(snow_loc_fillin_na(i),11)<=0.09
            PSD_num_na(snow_loc_na(i),13) = 13;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.09 & rain_snow(snow_loc_fillin_na(i),11)<=0.99
            PSD_num_na(snow_loc_na(i),13) = 14;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.99 & rain_snow(snow_loc_fillin_na(i),11)<=10
            PSD_num_na(snow_loc_na(i),13) = 15;
        elseif rain_snow(snow_loc_fillin_na(i),11)>10   & rain_snow(snow_loc_fillin_na(i),11)<=50
            PSD_num_na(snow_loc_na(i),13) = 16;
        elseif rain_snow(snow_loc_fillin_na(i),11)>50
            PSD_num_na(snow_loc_na(i),13) = 17;
        end
        
        PSD_num_na(snow_loc_na(i),14)=rain_snow(snow_loc_fillin_na(i),12); % num_bins
        PSD_num_na(snow_loc_na(i),15)=rain_snow(snow_loc_fillin_na(i),13); % num_particles
        PSD_num_na(snow_loc_na(i),16)=rain_snow(snow_loc_fillin_na(i),11); % preciprate
        PSD_num_na(snow_loc_na(i),17)=rain_snow(snow_loc_fillin_na(i),14); % reflectivity
        PSD_num_na(snow_loc_na(i),18)=rain_snow(snow_loc_fillin_na(i),15); % dBr
        PSD_num_na(snow_loc_na(i),19)=rain_snow(snow_loc_fillin_na(i),16); % dBZ
        
        PSD_num_na(snow_loc_na(i),22:149)=snow_PSD_num_na(snow_loc_fillin_na(i),5:132); %bins
    end
end

%throwing away artificial data and wrong minutes
for i=1:length(susp)
    if susp(i)~=0
        %Disdrodata:
        %flag 1: switched to snow
        data(susp(i),34)=0;
        %flag 2: switched to the according intensity
        data(susp(i),35)=12; % flag 2 - true zero
        %data(susp(i),36)=-99; % num bins
        %data(susp(i),37)=-9999;% num particles
        data(susp(i),38)=0;% preciprate
        data(susp(i),39)=-99.99;%reflectivity
        data(susp(i),40)=-99.99;% dBR
        data(susp(i),41)=-99.99;% dBZ
    end
end
for i=1:length(loc_na)
    if loc_na(i) > 0
        PSD_na(loc_na(i),:)=[];
        PSD_num_na(loc_na(i),:)=[];
        loc_na=loc_na-1;
    end
end

tic
for i=1:length(changed)
    for j=2:length(changed)
        if (changed{1,j-1}(1)>changed{1,j}(1))
            temp=changed{1,j-1};
            changed{1,j-1}=changed{1,j};
            changed{1,j}=temp;
        end
    end
end
toc

safe=1;
if safe
    colloc_outfile=strcat(data_name_V3(1:end-4),'_ancillary_checked','.txt');
    f1=fopen(colloc_outfile,'w');
    fprintf(f1,formatSpec_or,data');


    PSD_outfile=strcat(PSD_na_name(1:end-4),'_ancillary_checked','.txt');
    f2=fopen(PSD_outfile,'w');
    fprintf(f2,formatSpec_firstLine,firstLine');
    fprintf(f2,formatSpec_PSD_na,PSD_na');


    PSD_num_outfile=strcat(PSD_num_na_name(1:end-4),'_ancillary_checked','.txt');
    f3=fopen(PSD_num_outfile,'w');
    fprintf(f3,formatSpec_firstLine,firstLine');
    fprintf(f3,formatSpec_PSD_num_na,PSD_num_na');
    
    parameter_outfile='joint_investigator_disdro_2016V03-2016V04_changed_parameters.txt';
    if exist(parameter_outfile, 'file')==2
       delete(parameter_outfile);
    end
    for i=1:length(changed)
        dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
    end
end

