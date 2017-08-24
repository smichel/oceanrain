close all;
clear;

formatSpec_PSD_na=    strcat('%08i %08i %04i %04i %12.6f %12i %8.4f %9.4f %7.2f %7.2f %7.2f %5i %5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f', repmat('%12.4f ',1,128),'\r\n');
formatSpec_PSD_num_na=strcat('%08i %08i %04i %04i %12.6f %12i %8.4f %9.4f %7.2f %7.2f %7.2f %5i %5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f', repmat('%12i ',1,128),'\r\n');
% Variable  c,   date,time,mmday,kc,  UTC,  lat,  lon,  head,temp,  dewt,wtemp,rh ,pres,relF,relD,trueF,trueD,rad1,vis,ceil,maxFF,sal,gauge,ww,   w1, w2,  perc99,train,tsnow,rpar,spar,mpar,flag,flag20,bins,nums,precip,refl,dbr,dbz,wind,uref
formatSpec_or='%08i %08i %04i %04i %10.6f %12i %8.4f %9.4f %5.1f %5.1f %5.1f %5.1f %4i %6.1f %4.1f %4i %4.1f %3i %6.1f %6i %6i %5.1f %6.2f %6.2f % 03i % 03i % 03i %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f % 5i % 5i % 03i % 05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f\r\n';
formatSpec_firstLine=strcat(repmat('%6.4f ',1,128),'\r\n');
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

data=load('joint_PSDISDRO_PS88-PS90_colloc_cont_ww_na.txt');
data_name='joint_PSDISDRO_PS88-PS90_colloc_cont_ww_na.txt';


tocheck=load('joint_PSDISDRO_PS88-PS90_phase_algo_prelim_tocheck.txt');
PSD_na_name='joint_PSDISDRO_PS88-PS90_psd_na.txt';
PSD_num_na_name='joint_PSDISDRO_PS88-PS90_psd_num_na.txt';
PSD_na=load(PSD_na_name);
PSD_num_na=load(PSD_num_na_name);
rain_snow=load('rainsnow_data_PS88-PS90.txt');
rain=load('rain_minute_psd_num_PS88-PS90.dat');

snow_PSD_num_na=load('snow_minute_psd_num_PS88-PS90.dat');
snow_PSD_na=load('snow_minute_psd_dbz_PS88-PS90.dat');

rain_PSD_num_na=load('rain_minute_psd_num_PS88-PS90.dat');
rain_PSD_na=load('rain_minute_psd_dbz_PS88-PS90.dat');

PSD_na(2:end,1)=1:size(PSD_na,1)-1;
PSD_na(1,:)=[];
PSD_num_na(1:end,1)=2:size(PSD_num_na,1)+1;
% PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
% PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
% PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);
% PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1));
PSD_na(1:end,1)=1:size(PSD_na(1:end,1));

j=1;p=1;
% global radiation
for i=2:size(data(:,19),1)-1
    if data(i-1,19)~=9999.9 & data(i,19)==9999.9 & data(i+1,19)~=9999.9
        data(i,19)=mean([data(i-1,19) data(i+1,19)]);
        changed{j}=[data(i,6) 19];
        j=j+1;
    elseif data(i,19)==9999.9
        data(i,19)=-999.9;
    end
end

k=1;
for i=2:size(data,1)
    if data(i,10) == 0 & data(i-1,10) ~= 0 & data(i+1,10)~= 0 & (i < 77000 | i > 150000)
        susp(k)=i;
        k=k+1;
    end
end

for i=1:length(susp)
    data(susp(i),10)=data(susp(i)-1,10)/2+data(susp(i)+1,10)/2;
    changed=[changed, {[data(susp(i),6) 10]}];
end


k=1;j=1;
for i=1:size(tocheck,1)
    if tocheck(i,10)==-99 & tocheck(i,7)>6 & tocheck(i,38)==-9
        resc_rain(k)=tocheck(i,3);
        pos_rain(k)=i;
        k=k+1;
    elseif tocheck(i,10)==-99 & tocheck(i,7)<0 & tocheck(i,38)==-9
        resc_snow(j)=tocheck(i,3);
        pos_snow(j)=i;
        j=j+1;
    end
end

[lia,loc]=ismember(resc_rain,data(:,6));
rain_susp_dd=data(loc,2);
rain_susp_mm=data(loc,3);
[lia_rain_na,loc_rain_na]=ismember(resc_rain,PSD_na(:,6));
[rain_lia_fillin_na,rain_loc_fillin_na]=ismember(rain_susp_dd(:)+rain_susp_mm(:)/10000,rain_PSD_na(:,1)+rain_PSD_na(:,2)/10000);



for i=1:length(resc_rain)
    data(loc(i),28)=tocheck(pos_rain(i),22);
    data(loc(i),29)=tocheck(pos_rain(i),23);
    data(loc(i),30)=tocheck(pos_rain(i),29);
    data(loc(i),31)=1;
    data(loc(i),32)=0;
    data(loc(i),33)=0;
    data(loc(i),34)=0;
    if tocheck(pos_rain(i),23) ==0
        data(loc(i),35) = 12;
    elseif tocheck(pos_rain(i),23)<=0.09
        data(loc(i),35) = 13;
    elseif tocheck(pos_rain(i),23)>0.09 & tocheck(pos_rain(i),23)<=0.99
        data(loc(i),35) = 14;
    elseif tocheck(pos_rain(i),23)>0.99 & tocheck(pos_rain(i),23)<=10
        data(loc(i),35) = 15;
    elseif tocheck(pos_rain(i),23)>10   & tocheck(pos_rain(i),23)<=50
        data(loc(i),35) = 16;
    elseif tocheck(pos_rain(i),23)>50
        data(loc(i),35) = 17;
    end
    data(loc(i),36)=tocheck(pos_rain(i),24); % BINS
    data(loc(i),37)=tocheck(pos_rain(i),25); % NUMS
    data(loc(i),38)=tocheck(pos_rain(i),23); % RATE
    data(loc(i),39)=tocheck(pos_rain(i),26);
    data(loc(i),40)=tocheck(pos_rain(i),27);
    data(loc(i),41)=tocheck(pos_rain(i),28);
    data(loc(i),42)=tocheck(pos_rain(i),40);
    data(loc(i),43)=tocheck(pos_rain(i),41);
    changed=[changed,{[data(loc(i),6) 28:43]}];
    
    %PSD_num
        
        %flag 1: switching it to rain
        PSD_na(loc_rain_na(i),12)=0;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(rain_loc_fillin_na(i),5) ==0
            PSD_na(loc_rain_na(i),13) = 12;
        elseif rain_snow(rain_loc_fillin_na(i),5)<=0.09
            PSD_na(loc_rain_na(i),13) = 13;
        elseif rain_snow(rain_loc_fillin_na(i),5)>0.09 & rain_snow(rain_loc_fillin_na(i),5)<=0.99
            PSD_na(loc_rain_na(i),13) = 14;
        elseif rain_snow(rain_loc_fillin_na(i),5)>0.99 & rain_snow(rain_loc_fillin_na(i),5)<=9.99
            PSD_na(loc_rain_na(i),13) = 15;
        elseif rain_snow(rain_loc_fillin_na(i),5)>10   & rain_snow(rain_loc_fillin_na(i),5)<=49.99
            PSD_na(loc_rain_na(i),13) = 16;
        elseif rain_snow(rain_loc_fillin_na(i),5)>50
            PSD_na(loc_rain_na(i),13) = 17;
        end
        
        PSD_na(loc_rain_na(i),14)=rain_snow(rain_loc_fillin_na(i),6); % num_bins
        PSD_na(loc_rain_na(i),15)=rain_snow(rain_loc_fillin_na(i),7); % num_particles
        PSD_na(loc_rain_na(i),16)=rain_snow(rain_loc_fillin_na(i),5); % preciprate
        PSD_na(loc_rain_na(i),17)=rain_snow(rain_loc_fillin_na(i),8); % reflectivity
        PSD_na(loc_rain_na(i),18)=rain_snow(rain_loc_fillin_na(i),9); % dBr
        PSD_na(loc_rain_na(i),19)=rain_snow(rain_loc_fillin_na(i),10); % dBZ
        
        PSD_na(loc_rain_na(i),22:149)=rain_PSD_na(rain_loc_fillin_na(i),5:132); %bins
               
        %PSD_num_na
        
        %flag 1: switching it to rain phase
        PSD_num_na(loc_rain_na(i),12)=0;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(rain_loc_fillin_na(i),5) ==0
            PSD_num_na(loc_rain_na(i),13) = 12;
        elseif rain_snow(rain_loc_fillin_na(i),5)<=0.09
            PSD_num_na(loc_rain_na(i),13) = 13;
        elseif rain_snow(rain_loc_fillin_na(i),5)>0.09 & rain_snow(rain_loc_fillin_na(i),5)<=0.99
            PSD_num_na(loc_rain_na(i),13) = 14;
        elseif rain_snow(rain_loc_fillin_na(i),5)>0.99 & rain_snow(rain_loc_fillin_na(i),5)<=10
            PSD_num_na(loc_rain_na(i),13) = 15;
        elseif rain_snow(rain_loc_fillin_na(i),5)>10   & rain_snow(rain_loc_fillin_na(i),5)<=50
            PSD_num_na(loc_rain_na(i),13) = 16;
        elseif rain_snow(rain_loc_fillin_na(i),5)>50
            PSD_num_na(loc_rain_na(i),13) = 17;
        end
        
        PSD_num_na(loc_rain_na(i),14)=rain_snow(rain_loc_fillin_na(i),6); % num_bins
        PSD_num_na(loc_rain_na(i),15)=rain_snow(rain_loc_fillin_na(i),7); % num_particles
        PSD_num_na(loc_rain_na(i),16)=rain_snow(rain_loc_fillin_na(i),5); % preciprate
        PSD_num_na(loc_rain_na(i),17)=rain_snow(rain_loc_fillin_na(i),8); % reflectivity
        PSD_num_na(loc_rain_na(i),18)=rain_snow(rain_loc_fillin_na(i),8); % dBr
        PSD_num_na(loc_rain_na(i),19)=rain_snow(rain_loc_fillin_na(i),9); % dBZ
        
        PSD_num_na(loc_rain_na(i),22:149)=rain_PSD_num_na(rain_loc_fillin_na(i),5:132); %bins
    
    
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
    colloc_outfile=strcat(data_name(1:end-4),'_ancillary_checked','.txt');
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
   
    parameter_outfile=strcat(PSD_na_name(1:25),'changed_parameters.txt');
    if exist(parameter_outfile, 'file')==2
       delete(parameter_outfile);
    end
    for i=1:length(changed)
        dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
    end
end