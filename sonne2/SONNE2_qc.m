clear; close all;
formatSpec_PSD_na=    strcat('%08i %08i %04i %04i %12.6f %12i %8.4f %9.4f %7.2f %7.2f %7.2f %5i %5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f', repmat('%12.4f ',1,128),'\r\n');
formatSpec_PSD_num_na=strcat('%08i %08i %04i %04i %12.6f %12i %8.4f %9.4f %7.2f %7.2f %7.2f %5i %5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f', repmat('%12i ',1,128),'\r\n');
% Variable  c,   date,time,mmday,kc,  UTC,  lat,  lon,  head,temp,  dewt,wtemp,rh ,pres,relF,relD,trueF,trueD,rad1,vis,ceil,maxFF,sal,gauge,ww,   w1, w2,  perc99,train,tsnow,rpar,spar,mpar,flag,flag20,bins,nums,precip,refl,dbr,dbz,wind,uref
formatSpec_or='%08i %08i %04i %04i %10.6f %12i %8.4f %9.4f %5.1f %5.1f %5.1f %5.1f %4i %6.1f %4.1f %4i %4.1f %3i %6.1f %6i %6i %5.1f %6.2f %6.2f % 03i % 03i % 03i %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f % 5i % 5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f\r\n';

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
data=vertcat(load('joint_sonne2_disdro_SO237-SO246_colloc_cont_ww_na.txt'),load('joint_sonne2DISDRO_SO247-SO254_colloc_cont_ww_na.txt'),load('joint_sonne2DISDRO_SO255-SO256_colloc_cont_ww_na.txt'));
data_name='joint_sonne2_disdro_SO237-SO256_colloc_cont.txt';
PSD_na_name='joint_sonne2_disdro_SO237-SO256_psd_na.txt';
PSD_num_na_name='joint_sonne2_disdro_SO237-SO256_psd_num_na.txt';
PSD_na_1=load('joint_sonne2_disdro_SO237-SO246_psd_na.txt');
PSD_na_2=load('joint_sonne2DISDRO_SO247-SO254_psd_na.txt');
PSD_na_3=load('joint_sonne2DISDRO_SO255-SO256_psd_na.txt');
PSD_num_na_1=load('joint_sonne2_disdro_SO237-SO246_psd_num_na.txt');
PSD_num_na_2=load('joint_sonne2DISDRO_SO247-SO254_psd_num_na.txt');
PSD_num_na_3=load('joint_sonne2DISDRO_SO255-SO256_psd_num_na.txt');

%rain_snow_1=load('rainsnow_data_SO237-SO246.txt');
rain_1=load('rain_minute_psd_num_SO237-SO246.dat');

%rain_snow_2=load('rainsnow_data_SO247-SO254.txt');
rain_2=load('rain_minute_psd_num_SO247-SO254.dat');

rain_3=load('rain_minute_psd_num_SO255-SO256.dat');

% snow_PSD_na=load('snow_minute_psd_num_2017V01-2017V02.dat');
% snow_PSD_num_na=load('snow_minute_psd_dbz_2017V01-2017V02.dat');

PSD_na_1(2:end,1)=1:size(PSD_na_1,1)-1;
PSD_num_na_1(1:end,1)=2:size(PSD_num_na_1,1)+1;
PSD_num_na_1_dummy=horzcat(PSD_na_1(2,1:21),rain_1(3,5:end));
PSD_num_na_1=vertcat(PSD_num_na_1_dummy,PSD_num_na_1);
PSD_num_na_1=vertcat(PSD_na_1(1,:),PSD_num_na_1);

PSD_na_2(2:end,1)=1:size(PSD_na_2,1)-1;
PSD_num_na_2(1:end,1)=2:size(PSD_num_na_2,1)+1;
PSD_num_na_2_dummy=horzcat(PSD_na_1(2,1:21),rain_2(3,5:end));
PSD_num_na_2=vertcat(PSD_num_na_2_dummy,PSD_num_na_2);
PSD_num_na_2=vertcat(PSD_na_2(1,:),PSD_num_na_2);

PSD_na_3(2:end,1)=1:size(PSD_na_3,1)-1;
PSD_num_na_3(1:end,1)=2:size(PSD_num_na_3,1)+1;
PSD_num_na_3_dummy=horzcat(PSD_na_1(2,1:21),rain_3(3,5:end));
PSD_num_na_3=vertcat(PSD_num_na_3_dummy,PSD_num_na_3);
PSD_num_na_3=vertcat(PSD_na_3(1,:),PSD_num_na_3);

PSD_na=vertcat(PSD_na_1,PSD_na_2);
PSD_num_na=vertcat(PSD_num_na_1,PSD_num_na_2);
pos=find(PSD_na(1:end,1)==99999999);
PSD_na(pos(2:end),:)=[];
PSD_num_na(pos(2:end),:)=[];
clear PSD_num_na_1 PSD_num_na_2 PSD_na_1 PSD_na_2 rain_snow_1 rain_snow_2 %rain_1 rain_2


% finding error minutes of Temperature and Relative humidity
pos=find(data(:,10)==0 & data(:,13)==0);
data(pos,10)=-99.9;
data(pos,13)=-99;
changed={[data(pos(1),6) 10 13]};
changed=[changed,{[data(pos(2),6) 10 13]}];
% error minutes of relative humidity
pos=find(data(:,13)==0);
data(pos,10)=-99.9;
changed=[changed,{[data(pos(1),6) 10 13]}];
changed=[changed,{[data(pos(2),6) 10 13]}];

data(859931,10)=data(859931-1,10)/2+data(859931+1,10)/2;
changed=[changed,{[data(859931,6) 10]}];
susp_sal=find(data(:,23)<26&data(:,23)>=0);
data(susp_sal,23)=-99.99;
susp_extreme=find(data(:,2)==23052015&data(:,3)==2235):find(data(:,2)==24052015&data(:,3)==1139);
susp_extreme=[susp_extreme, find(data(:,38)>150)'];
susp_extreme=unique(susp_extreme);

susp_extreme_dd=data(susp_extreme,2);
susp_extreme_mm=data(susp_extreme,3);
extreme_changed=data(susp_extreme,6);

disdro_off(1)=find(data(:,2)==22112016,1,'first');
disdro_off(2)=find(data(:,2)==19012017,1,'last');

data(disdro_off(1):disdro_off(2),34)=4;
data(disdro_off(1):disdro_off(2),35)=99;
data(disdro_off(1):disdro_off(2),36)=-99;
data(disdro_off(1):disdro_off(2),37)=-9999;
data(disdro_off(1):disdro_off(2),38)=-99.99;
data(disdro_off(1):disdro_off(2),39:43)=-99.99;

for i=1:length(susp_extreme)
    changed=[changed,{[extreme_changed(i) 34:43]}];
end

for i=1:length(susp_sal)
    changed=[changed,{[data(susp_sal(i),6) 23]}];
end

% for i=disdro_off(1):disdro_off(2)
%     changed=[changed,{[data(i,6) 34:43]}];
% end
[lia_na,loc_na]=ismember(extreme_changed,PSD_na(:,6));
%[lia_fillin_na,loc_fillin_na]=ismember(snow_susp_dd(:)+snow_susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);


%throwing away artificial data and wrong minutes
for i=1:length(susp_extreme)
    if susp_extreme(i)~=0
%         Disdrodata:
%         flag 1: switched to 
        data(susp_extreme(i),34)=3;
%         flag 2: switched to the according intensity
        data(susp_extreme(i),35)=10; % flag 2 - missing
        data(susp_extreme(i),36)=-99; % num bins
        data(susp_extreme(i),37)=-9999;% num particles
        data(susp_extreme(i),38)=0;% preciprate
        data(susp_extreme(i),39)=-99.99;%reflectivity
        data(susp_extreme(i),40)=-99.99;% dBR
        data(susp_extreme(i),41)=-99.99;% dBZ
        data(susp_extreme(i),42)=-99.99;% rel wsped aneno
        data(susp_extreme(i),43)=-99.99;% reference voltage
    end
end
for i=1:length(loc_na)
    if loc_na(i) > 0
        PSD_na(loc_na(i),:)=[];
        PSD_num_na(loc_na(i),:)=[];
        loc_na=loc_na-1;
    end
end

data(2:end,1)=1:size(data(2:end,1),1);
PSD_na(2:end,1)=1:size(PSD_na(2:end,1),1);
PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1),1);

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
    colloc_outfile=strcat(data_name(1:end-4),'_ancillary_checked','.txt');
    f1=fopen(colloc_outfile,'w');
    fprintf(f1,formatSpec_or,data');
end

%     PSD_outfile=strcat(PSD_na_name(1:end-4),'_ancillary_checked','.txt');
%     f2=fopen(PSD_outfile,'w');
%     fprintf(f2,formatSpec_PSD_na,PSD_na');
% 
% 
%     PSD_num_outfile=strcat(PSD_num_na_name(1:end-4),'_ancillary_checked','.txt');
%     f3=fopen(PSD_num_outfile,'w');
%     fprintf(f3,formatSpec_PSD_num_na,PSD_num_na');
%    
%     parameter_outfile='joint_sonne2_disdro_SO237-SO256_changed_parameters.txt';
%     if exist(parameter_outfile, 'file')==2
%        delete(parameter_outfile);
%     end
%     for i=1:length(changed)
%         dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
%     end
% end