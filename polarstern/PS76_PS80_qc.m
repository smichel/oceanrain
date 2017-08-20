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

data=load('joint_PSDISDRO_PS76-PS80_colloc_cont_ww_na.txt');
data_name='joint_PSDISDRO_PS76-PS80_colloc_cont_ww_na.txt';
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
      if (data(i,38)>30)&(data(i-1,34)==1 | data(i+1,34)==1 |data(i-1,34)==2 |data(i+1,34)==2)
%     if (data(i,38)>30 & data(i,24) ==0 & data(i,10) <0.5) | (data(i,38)>50)
        changed{j}=[data(i,6) 34:43];
        snow_susp(p)=i;
        p=p+1;j=j+1;
    end
end

gusts=find(data(:,22)>50);
for i=1:length(gusts)
    changed=[changed,{[data(gusts(i),6) 22]}];
end
data((data(:,22)>50),22)=0;

for i=205502:205576
        data(i,34)=4;
        data(i,35)=-9;
        data(i,36)=-99;
        data(i,37)=-9999;
        data(i,38:43)=-99.99;
        changed=[changed,{[data(i,6) 34:43]}];
end


biscaya=205502:205576;
biscaya_dd=data(biscaya,2);
biscaya_mm=data(biscaya,3);
biscaya_changed=data(biscaya(:),6);

snow_susp=snow_susp(:,1);
snow_susp_dd=data(snow_susp,2);
snow_susp_mm=data(snow_susp,3);
snow_changed=data(snow_susp,6);

PSD_na_name='joint_PSDISDRO_PS76-PS80_psd_na.txt';
PSD_num_na_name='joint_PSDISDRO_PS76-PS80_psd_num_na.txt';
PSD_na=load(PSD_na_name);
PSD_num_na=load(PSD_num_na_name);
rain_snow=load('rainsnow_data_PS76-PS80.txt');
rain=load('rain_minute_psd_num_PS76-PS80.dat');

snow_PSD_num_na=load('snow_minute_psd_num_PS76-PS80.dat');
snow_PSD_na=load('snow_minute_psd_dbz_PS76-PS80.dat');

PSD_na(2:end,1)=1:size(PSD_na,1)-1;
PSD_num_na(1:end,1)=2:size(PSD_num_na,1)+1;
PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);
PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1));
PSD_na(2:end,1)=1:size(PSD_na(2:end,1));
tocheck=load('joint_PSDISDRO_PS76-PS80_phase_algo_prelim_tocheck.txt');

[snow_lia_na,snow_loc_na]=ismember(snow_changed,PSD_na(:,6));
[snow_lia_fillin_na,snow_loc_fillin_na]=ismember(snow_susp_dd(:)+snow_susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);

[resc_lia_na,resc_loc_na]=ismember(tocheck(:,3),data(:,6));
[resc_fillin_na,resc_loc_fillin_na]=ismember(snow_susp_dd(:)+snow_susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);

[lia_na,loc_na]=ismember(biscaya_changed,PSD_na(:,6));
[lia_fillin_na,loc_fillin_na]=ismember(biscaya_dd(:)+biscaya_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);


for i=1:length(snow_susp)
    if snow_susp(i)~=0 & snow_loc_fillin_na(i)~=0 & snow_loc_na(i) ~= 0
        %Disdrodata:
        %flag 1: switched to mixedphase
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
        
        data(snow_susp(i),36)=rain_snow(snow_loc_fillin_na(i),12); % num_bins
        data(snow_susp(i),37)=rain_snow(snow_loc_fillin_na(i),13); % num_particles
        data(snow_susp(i),38)=rain_snow(snow_loc_fillin_na(i),11); % preciprate
        data(snow_susp(i),39)=rain_snow(snow_loc_fillin_na(i),14); % reflectivity
        data(snow_susp(i),40)=rain_snow(snow_loc_fillin_na(i),15); % dBr
        data(snow_susp(i),41)=rain_snow(snow_loc_fillin_na(i),16); % dBZ
        
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

for i=1:length(loc_na)
    if loc_na(i) > 0
        PSD_na(loc_na(i),:)=[];
        PSD_num_na(loc_na(i),:)=[];
        loc_na=loc_na-1;
    end
end


for i=1:length(changed)
    for j=2:length(changed)
        if (changed{1,j-1}(1)>changed{1,j}(1))
            temp=changed{1,j-1};
            changed{1,j-1}=changed{1,j};
            changed{1,j}=temp;
        end
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
   
    parameter_outfile=strcat(PSD_na_name(1:25),'changed_parameters.txt');
    if exist(parameter_outfile, 'file')==2
       delete(parameter_outfile);
    end
    for i=1:length(changed)
        dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
    end
end

%colloc_outfile=strcat(data_name(1:end-4),'_ancillary_checked','.txt');
%save(colloc_outfile,'data','-ascii');