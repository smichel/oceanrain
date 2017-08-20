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
%data=vertcat(load('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt'),load('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt'),load('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt'),load('joint_investigator_disdro_2016T01-2016T02_colloc_cont_ww_na.txt'));
%data_name_V3=('joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na.txt');
data_name_V1=('joint_investigator_disdro_2017V01-2017V02_colloc_cont_ww_na.txt');
data=load(data_name_V1);
%c_data=load('joint_investigator_disdro_2016T01-2016V04_colloc_cont_ww_na_ancillary_checked.txt');
T=data(:,10);
G_Pre=data(:,24);
G_Pre(G_Pre<0)=0;
P=data(:,38);
T(T>45)=T(T>45)-65.3;

c_P=P;
data(15520,23)=data(15520-1,23)/2+data(15520+1,23)/2;
changed={[data(15520,6) 23]};


scale_factor=10;
searchrad=4;
k=1;
j=1;
for i=1+searchrad:size(data,1)-searchrad
    if (data(i,38)>30 & data(i,24) ==0 & data(i,10) <0.5)
        snow_susp(k,1)=i;
        %data(i,38)=data(i,30);
        k=k+1;
    elseif (data(i,38)>10  & data(i,34)==0) & sum(data(i-searchrad:i+searchrad,34))-3*sum(data(i-searchrad:i+searchrad,34)==3)>0
        snow_susp(k,1)=i;
        k=k+1;
        %data(i,38)=data(i,30);
    elseif data(i,10) < 4 & data(i,38)>5 & data(i,34)==0 & sum(data(i-searchrad:i+searchrad,38)-(data(i,38))>(data(i,38))/scale_factor) %sum(data(i-searchrad:i+searchrad,38)*max_factor<(data(i,38)))
        snow_susp(k,1)=i;
        %data(i,38)=data(i,30);
        k=k+1;
    end
end

%wrong gps data


b_snow_susp=snow_susp;
snow_susp=snow_susp(:,1);

snow_susp_dd=data(snow_susp,2);
snow_susp_mm=data(snow_susp,3);
snow_changed=data(snow_susp,6);

for i=1:length(snow_susp)
    changed=[changed,{[snow_changed(i) 34:41]}];
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


PSD_na_name='joint_investigator_disdro_2017V01-2017V02_psd_na.txt';
PSD_num_na_name='joint_investigator_disdro_2017V01-2017V02_psd_num_na.txt';
PSD_na=load(PSD_na_name);
PSD_num_na=load(PSD_num_na_name);
rain_snow=load('rainsnow_data_2017V01-2017V02.txt');
rain=load('rain_minute_psd_num_2017V01-2017V02.dat');

snow_PSD_num_na=load('snow_minute_psd_num_2017V01-2017V02.dat');
snow_PSD_na=load('snow_minute_psd_dbz_2017V01-2017V02.dat');

PSD_na(2:end,1)=1:size(PSD_na,1)-1;
PSD_num_na(1:end,1)=2:size(PSD_num_na,1)+1;
PSD_num_na_dummy=horzcat(PSD_na(2,1:21),rain(3,5:end));
PSD_num_na=vertcat(PSD_num_na_dummy,PSD_num_na);
PSD_num_na=vertcat(PSD_na(1,:),PSD_num_na);
PSD_num_na(2:end,1)=1:size(PSD_num_na(2:end,1));
PSD_na(2:end,1)=1:size(PSD_na(2:end,1));


[snow_lia_na,snow_loc_na]=ismember(snow_changed,PSD_na(:,6));
[snow_lia_fillin_na,snow_loc_fillin_na]=ismember(snow_susp_dd(:)+snow_susp_mm(:)/10000,snow_PSD_na(:,1)+snow_PSD_na(:,2)/10000);



%fixing the oceanrain data from rain to snow
for i=1:length(snow_susp)
    if snow_loc_fillin_na(i)==0
        snow_loc_fillin_na(i)=snow_loc_fillin_na(i-1);
    end
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
        
        data(snow_susp(i),36)=rain_snow(snow_loc_fillin_na(i),12); % num_bins
        data(snow_susp(i),37)=rain_snow(snow_loc_fillin_na(i),13); % num_particles
        data(snow_susp(i),38)=rain_snow(snow_loc_fillin_na(i),11); % preciprate
        data(snow_susp(i),39)=rain_snow(snow_loc_fillin_na(i),14); % reflectivity
        data(snow_susp(i),40)=rain_snow(snow_loc_fillin_na(i),15); % dBr
        data(snow_susp(i),41)=rain_snow(snow_loc_fillin_na(i),16); % dBZ
        
        %PSD_num
        
        %flag 1: switching it to snow(1)
        PSD_na(snow_loc_na(i),12)=1;
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
        PSD_num_na(snow_loc_na(i),12)=1;
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

%throwing away artificial data and wrong minutes
% for i=1:length(snow_susp)
%     if snow_susp(i)~=0
%         %Disdrodata:
%         %flag 1: switched to snow
%         data(snow_susp(i),34)=2;
%         %flag 2: switched to the according intensity
%         data(snow_susp(i),35)=12; % flag 2 - true zero
%         %data(susp(i),36)=-99; % num bins
%         %data(susp(i),37)=-9999;% num particles
%         data(snow_susp(i),38)=0;% preciprate
%         data(snow_susp(i),39)=-99.99;%reflectivity
%         data(snow_susp(i),40)=-99.99;% dBR
%         data(snow_susp(i),41)=-99.99;% dBZ
%     end
% end
% for i=1:length(loc_na)
%     if loc_na(i) > 0
%         PSD_na(loc_na(i),:)=[];
%         PSD_num_na(loc_na(i),:)=[];
%         loc_na=loc_na-1;
%     end
% end

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
    colloc_outfile=strcat(data_name_V1(1:end-4),'_ancillary_checked','.txt');
    f1=fopen(colloc_outfile,'w');
    fprintf(f1,formatSpec_or,data');


    PSD_outfile=strcat(PSD_na_name(1:end-4),'_ancillary_checked','.txt');
    f2=fopen(PSD_outfile,'w');
    fprintf(f2,formatSpec_PSD_na,PSD_na');


    PSD_num_outfile=strcat(PSD_num_na_name(1:end-4),'_ancillary_checked','.txt');
    f3=fopen(PSD_num_outfile,'w');
    fprintf(f3,formatSpec_PSD_num_na,PSD_num_na');
   
    parameter_outfile='joint_investigator_disdro_2017V01-2017V02_changed_parameters.txt';
    if exist(parameter_outfile, 'file')==2
       delete(parameter_outfile);
    end
    for i=1:length(changed)
        dlmwrite(parameter_outfile,changed{1,i}(:)','delimiter','\t','-append','Precision','%12i')
    end
end
