close all;
clear;
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
data=load('joint_METEORDISDRO_M109-M116_colloc_cont_ww_na.txt');
data_name='joint_METEORDISDRO_M109-M116_colloc_cont_ww_na.txt';

data_name='joint_METEORDISDRO_M109-M116_colloc_cont_ww_na.txt';
PSD_na_name='joint_METEORDISDRO_M109-M116_psd_na.txt';
PSD_num_na_name='joint_METEORDISDRO_M109-M116_psd_num_na.txt';
PSD_na=load(PSD_na_name);
PSD_num_na=load(PSD_num_na_name);
rain_snow=load('rainsnow_data_M109-M116.txt');
rain=load('rain_minute_psd_num_M109-M116.dat');

snow_PSD_num_na=load('snow_minute_psd_num_M109-M116.dat');
snow_PSD_na=load('snow_minute_psd_dbz_M109-M116.dat');

rain_PSD_num_na=load('rain_minute_psd_num_M109-M116.dat');
rain_PSD_na=load('rain_minute_psd_dbz_M109-M116.dat');


PSD_na(2:end,1)=1:size(PSD_na,1)-1;
PSD_num_na(1:end,1)=2:size(PSD_num_na,1)+1;
PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);
PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1));
PSD_na(2:end,1)=1:size(PSD_na(2:end,1));

k=1;
for i=1:size(data,1)
    if data(i,23) < 28 & data(i,23) ~= -99.99 
        data(i,23)=-99.99;
        
        changed{k}={[data(i,6) 23]};
        k=k+1;
    end
end


safe=1;
if safe
    colloc_outfile=strcat(data_name(1:end-4),'_ancillary_checked','.txt');
    f1=fopen(colloc_outfile,'w');
    fprintf(f1,formatSpec_or,data');


    PSD_outfile=strcat(PSD_na_name(1:end-4),'_ancillary_checked','.txt');
    f2=fopen(PSD_outfile,'w');
    fprintf(f2,formatSpec_PSD_na,PSD_na');


    PSD_num_outfile=strcat(PSD_num_na_name(1:end-4),'_ancillary_checked','.txt');
    f3=fopen(PSD_num_outfile,'w');
    fprintf(f3,formatSpec_PSD_num_na,PSD_num_na');
   
    parameter_outfile=strcat(PSD_na_name(1:29),'changed_parameters.txt');
    if exist(parameter_outfile, 'file')==2
       delete(parameter_outfile);
    end
    for i=1:length(changed)
        dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
    end
end