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

data=load('joint_PSDISDRO_PS85-PS87_colloc_cont_ww_na.txt');

tocheck=load('joint_PSDISDRO_PS85-PS87_phase_algo_prelim_tocheck.txt');

data_name='joint_PSDISDRO_PS85-PS87_colloc_cont_ww_na.txt';
PSD_na_name='joint_PSDISDRO_PS85-PS87_psd_na.txt';
PSD_num_na_name='joint_PSDISDRO_PS85-PS87_psd_num_na.txt';
PSD_na=load(PSD_na_name);
PSD_num_na=load(PSD_num_na_name);
rain_snow=load('rainsnow_data_PS85-PS87.txt');
rain=load('rain_minute_psd_num_PS85-PS87.dat');

snow_PSD_num_na=load('snow_minute_psd_num_PS85-PS87.dat');
snow_PSD_na=load('snow_minute_psd_dbz_PS85-PS87.dat');

rain_PSD_num_na=load('rain_minute_psd_num_PS85-PS87.dat');
rain_PSD_na=load('rain_minute_psd_dbz_PS85-PS87.dat');


PSD_na(2:end,1)=1:size(PSD_na,1)-1;
PSD_num_na(1:end,1)=2:size(PSD_num_na,1)+1;
PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);
PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1));
PSD_na(2:end,1)=1:size(PSD_na(2:end,1));
%tocheck: yyyy,mo,dd,hh,mm,%02 kc2, %03 UTC,%04 lat,%05 lon,%06 head,%07 temp,%08 dewt,%09 wtemp,%10 rh,%11 pres,
%12 relFF,%13 relDD,%14 trueFF,%15 trueDD,%16 rad1,%17 vis,%18 ceil,%19 maxFF,%20 sal,%21 gauge,%22 perc99,%23 rain,
%24 rain_bins,%25 rain_nums,%26 rain_refl,%27 rain_dbr,%28 rain_dbz,%29 snow,%30 snow_bins,%31 snow_nums,
%32 snow_refl,%33 snow_dbr,%34 snow_dbz,%35 rpar,%36 spar,%37 mpar,%38 flag,%39 precip,%40 wind,%41 uref


data(146003,10)=data(146003-1,10)/2+data(146003+1,10)/2;
changed={[data(146003,6) 10]};

data(167873,10)=data(167873-1,10)/2+data(167873+1,10)/2;
changed=[changed,{[data(167873,6) 13]}];

data(95521:95524,11)=linspace(data(95521,11),data(95524,11),length(data(95521:95524,11)));
data(95521:95524,13)=linspace(data(95521,13),data(95524,13),length(data(95521:95524,13)));

for i=95521:95524
    changed=[changed,{[data(i,6) 11 13]}];
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


[lia_snow,loc_snow]=ismember(resc_snow,data(:,6));
snow_susp_dd=data(loc_snow,2);
snow_susp_mm=data(loc_snow,3);
[lia_snow_na,loc_snow_na]=ismember(resc_snow,PSD_na(:,6));
[snow_lia_fillin_na,snow_loc_fillin_na]=ismember(snow_susp_dd(:)+snow_susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);


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
        
        %flag 1: switching it to snow(1)
        PSD_na(loc_rain_na(i),12)=0;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(rain_loc_fillin_na(i),11) ==0
            PSD_na(loc_rain_na(i),13) = 12;
        elseif rain_snow(rain_loc_fillin_na(i),11)<=0.09
            PSD_na(loc_rain_na(i),13) = 13;
        elseif rain_snow(rain_loc_fillin_na(i),11)>0.09 & rain_snow(rain_loc_fillin_na(i),11)<=0.99
            PSD_na(loc_rain_na(i),13) = 14;
        elseif rain_snow(rain_loc_fillin_na(i),11)>0.99 & rain_snow(rain_loc_fillin_na(i),11)<=9.99
            PSD_na(loc_rain_na(i),13) = 15;
        elseif rain_snow(rain_loc_fillin_na(i),11)>10   & rain_snow(rain_loc_fillin_na(i),11)<=49.99
            PSD_na(loc_rain_na(i),13) = 16;
        elseif rain_snow(rain_loc_fillin_na(i),11)>50
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
        
        %flag 1: switching it to mixed phase
        PSD_num_na(loc_rain_na(i),12)=2;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(rain_loc_fillin_na(i),11) ==0
            PSD_num_na(loc_rain_na(i),13) = 12;
        elseif rain_snow(rain_loc_fillin_na(i),11)<=0.09
            PSD_num_na(loc_rain_na(i),13) = 13;
        elseif rain_snow(rain_loc_fillin_na(i),11)>0.09 & rain_snow(rain_loc_fillin_na(i),11)<=0.99
            PSD_num_na(loc_rain_na(i),13) = 14;
        elseif rain_snow(rain_loc_fillin_na(i),11)>0.99 & rain_snow(rain_loc_fillin_na(i),11)<=10
            PSD_num_na(loc_rain_na(i),13) = 15;
        elseif rain_snow(rain_loc_fillin_na(i),11)>10   & rain_snow(rain_loc_fillin_na(i),11)<=50
            PSD_num_na(loc_rain_na(i),13) = 16;
        elseif rain_snow(rain_loc_fillin_na(i),11)>50
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
%snow
for i=1:length(resc_snow)
    data(loc_snow(i),28)=tocheck(pos_snow(i),22);
    data(loc_snow(i),29)=tocheck(pos_snow(i),23);
    data(loc_snow(i),30)=tocheck(pos_snow(i),29);
    data(loc_snow(i),31)=1;
    data(loc_snow(i),32)=0;
    data(loc_snow(i),33)=0;
    data(loc_snow(i),34)=2;
    if tocheck(pos_snow(i),23) ==0
        data(loc_snow(i),35) = 12;
    elseif tocheck(pos_snow(i),23)<=0.09
        data(loc_snow(i),35) = 13;
    elseif tocheck(pos_snow(i),23)>0.09 & tocheck(pos_snow(i),23)<=0.99
        data(loc_snow(i),35) = 14;
    elseif tocheck(pos_snow(i),23)>0.99 & tocheck(pos_snow(i),23)<=10
        data(loc_snow(i),35) = 15;
    elseif tocheck(pos_snow(i),23)>10   & tocheck(pos_snow(i),23)<=50
        data(loc_snow(i),35) = 16;
    elseif tocheck(pos_snow(i),23)>50
        data(loc_snow(i),35) = 17;
    end
    data(loc_snow(i),36)=tocheck(pos_snow(i),30);
    data(loc_snow(i),37)=tocheck(pos_snow(i),31);
    data(loc_snow(i),38)=tocheck(pos_snow(i),29);
    data(loc_snow(i),39)=tocheck(pos_snow(i),32);
    data(loc_snow(i),40)=tocheck(pos_snow(i),33);
    data(loc_snow(i),41)=tocheck(pos_snow(i),34);
    data(loc_snow(i),42)=tocheck(pos_snow(i),40);
    data(loc_snow(i),43)=tocheck(pos_snow(i),41);
    
    %PSD_num
        
        %flag 1: switching it to snow(1)
        PSD_na(loc_snow_na(i),12)=2;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(snow_loc_fillin_na(i),11) ==0
            PSD_na(loc_snow_na(i),13) = 12;
        elseif rain_snow(snow_loc_fillin_na(i),11)<=0.09
            PSD_na(loc_snow_na(i),13) = 13;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.09 & rain_snow(snow_loc_fillin_na(i),11)<=0.99
            PSD_na(loc_snow_na(i),13) = 14;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.99 & rain_snow(snow_loc_fillin_na(i),11)<=9.99
            PSD_na(loc_snow_na(i),13) = 15;
        elseif rain_snow(snow_loc_fillin_na(i),11)>10   & rain_snow(snow_loc_fillin_na(i),11)<=49.99
            PSD_na(loc_snow_na(i),13) = 16;
        elseif rain_snow(snow_loc_fillin_na(i),11)>50
            PSD_na(loc_snow_na(i),13) = 17;
        end
        
        PSD_na(loc_snow_na(i),14)=rain_snow(snow_loc_fillin_na(i),12); % num_bins
        PSD_na(loc_snow_na(i),15)=rain_snow(snow_loc_fillin_na(i),13); % num_particles
        PSD_na(loc_snow_na(i),16)=rain_snow(snow_loc_fillin_na(i),11); % preciprate
        PSD_na(loc_snow_na(i),17)=rain_snow(snow_loc_fillin_na(i),14); % reflectivity
        PSD_na(loc_snow_na(i),18)=rain_snow(snow_loc_fillin_na(i),15); % dBr
        PSD_na(loc_snow_na(i),19)=rain_snow(snow_loc_fillin_na(i),16); % dBZ
        
        PSD_na(loc_snow_na(i),22:149)=snow_PSD_na(snow_loc_fillin_na(i),5:132); %bins
        
        
        
        
        %PSD_num_na
        
        %flag 1: switching it to mixed phase
        PSD_num_na(loc_snow_na(i),12)=2;
        %flag 2: switchting it to the according precip intensity
        if rain_snow(snow_loc_fillin_na(i),11) ==0
            PSD_num_na(loc_snow_na(i),13) = 12;
        elseif rain_snow(snow_loc_fillin_na(i),11)<=0.09
            PSD_num_na(loc_snow_na(i),13) = 13;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.09 & rain_snow(snow_loc_fillin_na(i),11)<=0.99
            PSD_num_na(loc_snow_na(i),13) = 14;
        elseif rain_snow(snow_loc_fillin_na(i),11)>0.99 & rain_snow(snow_loc_fillin_na(i),11)<=10
            PSD_num_na(loc_snow_na(i),13) = 15;
        elseif rain_snow(snow_loc_fillin_na(i),11)>10   & rain_snow(snow_loc_fillin_na(i),11)<=50
            PSD_num_na(loc_snow_na(i),13) = 16;
        elseif rain_snow(snow_loc_fillin_na(i),11)>50
            PSD_num_na(loc_snow_na(i),13) = 17;
        end
        
        PSD_num_na(loc_snow_na(i),14)=rain_snow(snow_loc_fillin_na(i),12); % num_bins
        PSD_num_na(loc_snow_na(i),15)=rain_snow(snow_loc_fillin_na(i),13); % num_particles
        PSD_num_na(loc_snow_na(i),16)=rain_snow(snow_loc_fillin_na(i),11); % preciprate
        PSD_num_na(loc_snow_na(i),17)=rain_snow(snow_loc_fillin_na(i),14); % reflectivity
        PSD_num_na(loc_snow_na(i),18)=rain_snow(snow_loc_fillin_na(i),15); % dBr
        PSD_num_na(loc_snow_na(i),19)=rain_snow(snow_loc_fillin_na(i),16); % dBZ
        
        PSD_num_na(loc_snow_na(i),22:149)=snow_PSD_num_na(snow_loc_fillin_na(i),5:132); %bins
    
    changed=[changed,{[data(loc_snow(i),6) 28:43]}];
end



%tocheck: yyyy,mo,dd,hh,mm,%02 kc2, %03 UTC,%04 lat,%05 lon,%06 head,%07 temp,%08 dewt,%09 wtemp,%10 rh,%11 pres,
%12 relFF,%13 relDD,%14 trueFF,%15 trueDD,%16 rad1,%17 vis,%18 ceil,%19 maxFF,%20 sal,%21 gauge,%22 perc99,%23 rain,
%24 rain_bins,%25 rain_nums,%26 rain_refl,%27 rain_dbr,%28 rain_dbz,%29 snow,%30 snow_bins,%31 snow_nums,
%32 snow_refl,%33 snow_dbr,%34 snow_dbz,%35 rpar,%36 spar,%37 mpar,%38 flag,%39 precip,%40 wind,%41 uref

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
    fprintf(f2,formatSpec_PSD_na,PSD_na');


    PSD_num_outfile=strcat(PSD_num_na_name(1:end-4),'_ancillary_checked','.txt');
    f3=fopen(PSD_num_outfile,'w');
    fprintf(f3,formatSpec_PSD_num_na,PSD_num_na');
   
    parameter_outfile=strcat(PSD_na_name(1:25),'changed_parameters.txt');
    if exist(parameter_outfile, 'file')==2
       delete(parameter_outfile);
    end
    for i=1:length(changed)
        dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
    end
end