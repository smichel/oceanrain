function outdata=oceanflux(filepath,win_height,temp_height,hum_height,bulktemp_depth)
tic
% Input: 1.FULL filepath to the OR file; 2. height of wind measurement in m
% 3. height of temp measurement in m, 4. height of humidity measurement in m
% 5. depth of watertemperature measurement (positiv value)
if ischar(win_height)
win_height=str2num(win_height);temp_height=str2num(temp_height);hum_height=str2num(hum_height);temp_height=str2num(bulktemp_depth);
end
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
% uses functions: 
%   [w_corr]              = neutral_equiv_winh_correction(U,win_height)
%:  [qs, cd, ce, ch, hl_webb, Hrain, sst,hf,ef,evap] = coare3_0(Date,U,Tsea,Tair,qair,Pair,Rs,Rl,Rain,Lat,Lon,zu,zq,zt,bt,jwarm)
%   [s, qh, qe, evap, ce] = hoaps_par_FLUX(ts, qs, t, q, u)

data=load(filepath);


% %%%Ship meta data, in m:
% meteor = 0;
% polarstern = 0;
% investigator = 1;
% sonne = 0;
% merian = 0;
% 
% 
% % Meteor: Wind, Temp, Humidity on 37.5 m height, Watertemp on 2.5 m
% if meteor == 1
%     win_height = 37.5;     % height of wind measurement
%     temp_height = 37.5;     % height of temp measurement
%     hum_height  = 37.5;     % height of humidity measurement
%     bulktemp_depth= 2.5;      % depth of watertemperature measurement
%     
% % Polarstern: Wind on 39 m, Humidity and Temp on 29 m, Watertemp on 5 m
% elseif polarstern == 1
% 
%     win_height = 39;
%     temp_height = 29;
%     hum_height  = 29;
%     bulktemp_depth= 5;
% 
% % Investigator: Wind on 22.1 m, Humidity and Temp on 31.4m,  Watertemp on 6.9m
% elseif investigator == 1
% 
%     win_height = 22.1;
%     temp_height = 31.4;
%     hum_height  = 31.4;
%     bulktemp_depth= 6.9;
% 
% % Sonne: Wind on 34m, Humidity and Temp on 27 m, Watertemp on 2m
% elseif sonne == 1
%     
%     win_height = 34;
%     temp_height = 27;
%     hum_height = 27;
%     bulktemp_depth = 2;
%     
% % Merian: Wind on 30.76m, Humidity and Temp on 20.18, Watertemp on 4.2m
% elseif merian == 1
%     
%     win_height = 30.76;
%     temp_height = 20.18;
%     hum_height = 20.18;
%     bulktemp_depth = 4.2;
%         
% end 

%Algorithm specs
sigma=5.67*10^(-8); % W/m2/K4 Boltzmannconstant
warmlayer = 0;      % Warmlayer flag for the Coare algorithm // NOT FULLY IMPLEMENTED YET // DONT USE THIS
hoaps=0;            % Hoaps algorithm isnt calculated
%lengthcheck

%find the beginning of the first full day


org_numel=length(data(:,4));                        % number of elements in the original data
numel=length(data(:,4))-mod(length(data(:,4)),60);  % number of elements with modulo 60 - for 1h vectors


%data reshaping and throwing away exceeding minutes for 60 min vectors 
date=       data(1:(length(data(:,4))-mod(length(data(:,4)),60)),2);        % date in DDMMYYYY
lat=        data(1:(length(data(:,4))-mod(length(data(:,4)),60)),7);        % latitude
lon=        data(1:(length(data(:,4))-mod(length(data(:,4)),60)),8);        % longitude
T=          data(1:(length(data(:,4))-mod(length(data(:,4)),60)),10);       % air temperature in C
T_water=    data(1:(length(data(:,4))-mod(length(data(:,4)),60)),12);       % water temperature in C
RH=         data(1:(length(data(:,4))-mod(length(data(:,4)),60)),13);       % relative humidity in %
P_air=      data(1:(length(data(:,4))-mod(length(data(:,4)),60)),14);       % pressure in hPA
u=          data(1:(length(data(:,4))-mod(length(data(:,4)),60)),17);       % windspeed in m/s
R_g=        data(1:(length(data(:,4))-mod(length(data(:,4)),60)),19);       % global Radiation in W/m2
sal=        data(1:(length(data(:,4))-mod(length(data(:,4)),60)),23);       % salinity in PSU
rain=       data(1:(length(data(:,4))-mod(length(data(:,4)),60)),38);       % rain rate in mm/h
% counts
j=1; k=1; o=1;

% calculating the localtime of the ship with the longitude

localtime_zone=timezone(data(:,8));
localtime=data(:,3)+localtime_zone*100;
localdate=date;

parfor i = 1:org_numel
    if localtime(i)>2359
        localtime(i)=localtime(i)-2400;
    elseif localtime(i)<0
        localtime(i)=localtime(i)+2400;
    end
    t=datetime(data(i,6)+localtime_zone(i)*60*60,'ConvertFrom','posixtime');
    localdate(i)=t.Year+t.Month*10000+t.Day*1000000;
end



%preallocating vectors for speed
qair=NaN(length(lon),1);  % spec air humidity in g/kg
u_10=NaN(length(lon),1); % 10m windspeed in m/s
R_s=NaN(length(lon),1);   % short wave radiation in W/m2 (=global radiation)
R_l=NaN(length(lon),1);   % long wave radiation in W/m2
qsurf=NaN(length(lon),1); % sea surface spec humidity in g/kg
e_s=NaN(length(lon),1);   % saturation water vapor in hPa
e=NaN(length(lon),1);     % saturation water vapor in hPa

%preparing the parameters for further calculations, e.g. filling the
%missing/ error values with NaNs
%throwing away harbormeasurements: data(:,34)== 5 means harbor
parfor i=1:length(lon)
    if data(i,34) ~=5
        if T(i) < -90
            T(i) = NaN;
        end
        if T_water(i) < -90
            T_water(i) = NaN;
        end
        if lat(i) == -99.9999
            lat(i) = NaN;
        end
        if lon(i) == -999.9999
            lon(i) = NaN;
        end
        if lat(i) == 0 && lon(i) == 0 %&& data(i,9) == 0
            lat(i) = NaN;
            lon(i) = NaN;
        end
        if isnan(lon(i))
            localtime(i)=NaN;
        end
        if sal(i) == -99.99
            sal(i) = NaN;
        end
        %calculating the saturation water vapor pressure and water vapor pressure
        %with the temperature and the relative humidity
        if RH(i) ~= -99 && P_air(i) ~= -999.9 && ~isnan(T(i))
            e_s(i)=murphy(T(i)+273.15);
            e(i)=RH(i)/100*e_s(i);
        end
        %calculating the specific humidity with the water vapor pressure
        
        if RH(i) ~= -99 && P_air(i) ~= -999.9 && ~isnan(T(i))
            qair(i)=((0.622*e(i))/(((P_air(i)*100))-0.377*e(i)))*1000; %0.622e/(p-0.377e)
        else
            qair(i) = NaN;
        end
        
        % calculating the 10m with the measured wind speed in given height
        % (e.g. 37.5m for the R.V. Meteor)
        if u(i) > 0
            u_10(i) = neutral_equiv_wind_correction(u(i),win_height);
        else
            u_10(i) = NaN;
        end
        
        % if the warmlayer effect is relevant in the calculations the longwave
        % radiation will be calculated with the sigma T^4 formula
        if warmlayer==1
            if R_g(i) < 2000 && R_g(i) >-5
                R_l(i)=0;    %sigma*0.98*(T(i)+273.15)^4; % longwave out
                R_s(i)=R_g(i);          % shortwave in
                if R_s(i) < 0
                    R_s(i) = 0;
                end
            else
                R_s(i) = NaN;
                R_l(i) = NaN;
                R_g(i) = NaN;
            end
        end
        % rainrate of -99.99 means no measurement of rainrate, -88.88 means 0
        % precip
        if rain(i) == -99.99 || rain(i) > 200
            rain(i) = NaN;
        elseif rain(i) == -88.88
            rain(i) = 0;
        end
    else
        T(i)=NaN;
        T_water(i)=NaN;
        sal(i)=NaN;
        lat(i)=NaN;
        lon(i)=NaN;
        rain(i)=NaN;
        R_s(i) = NaN;
        R_l(i) = NaN;
        R_g(i) = NaN;
        u_10(i)=NaN;
        qair(i)=NaN;
    end
end

% missing minutes check
% finds and fixes single minutes with a simple linear interpolation

T_idx=mincheck(T);
T=minfix(T,T_idx);

T_water_idx=mincheck(T_water);
T_water=minfix(T_water,T_water_idx);

sal_idx=mincheck(sal);
sal=minfix(sal,sal_idx);

rain_idx=mincheck(rain);
rain=minfix(rain,rain_idx);

R_s_idx=mincheck(R_s);
R_s=minfix(R_s,R_s_idx);

R_g_idx=mincheck(R_g);
R_g=minfix(R_g,R_g_idx);

R_l_idx=mincheck(R_l);
R_l=minfix(R_l,R_l_idx);

qair_idx=mincheck(qair);
qair=minfix(qair,qair_idx);

u_10_idx=mincheck(u_10);
u_10=minfix(u_10,u_10_idx);

P_air_idx=mincheck(P_air);
P_air=minfix(P_air,P_air_idx);

warmflag=zeros(length(lon),1);
for i=1:length(lon)
    if u_10(i) < 2
        warmflag(i) = 1;
    elseif u_10(i) < 6 && R_g(i) >50
        warmflag(i) = 2;
    end
end 
if warmlayer ==0
    R_g(:)=0;
    R_l(:)=0;
    R_s(:)=0;
end

%reshaping the date from ddmmyyyy to YYYYMMDDHHMMSS localtime for the COARE
%CODE, needed for implementing the warmlayereffect in the future
c_date=rem(date,10000)*10000000000+floor(rem(date,1000000)/10000)*100000000+floor(date/1000000)*1000000+localtime(1:(length(data(:,4))-mod(length(data(:,4)),60)))*100;

%after calculating the 10 m windspeed with the logarithmic wind profile the
%new "measurement height" is 10 m for future algorithms
win_height=10;

% number of available minutes where all relevant parameters are measured
avail_min = sum(~isnan(u_10(:)) & ~isnan(T_water(:)) & ~isnan(T(:)) & ~isnan(qair(:)) & ~isnan(P_air(:)) & ~isnan(R_l(:)) & ~isnan(rain(:)));
timestep=60;
%check if the data is already calculated
datacalculated = exist('sst','var'); %clear data;
% if data is calculated, it wont be calculated again
if datacalculated == 0
    
    datalength=length(date)/timestep;
    % Preallocating for speed - shaping the data into hourly data
    h_date=NaN(timestep,datalength);
    h_u_10=NaN(timestep,datalength);
    h_T_water=NaN(timestep,datalength);
    h_T=NaN(timestep,datalength);
    h_q=NaN(timestep,datalength);
    h_rain=NaN(timestep,datalength);
    h_P_air=NaN(timestep,datalength);
    h_R_s=zeros(timestep,datalength);
    h_R_l=zeros(timestep,datalength);
    h_lat=NaN(timestep,datalength);
    h_lon=NaN(timestep,datalength);
    sst = NaN(timestep,datalength);
    hrain=NaN(timestep,datalength);
    webb=NaN(timestep,datalength);
    shf = NaN(timestep,datalength);
    lhf = NaN(timestep,datalength);
    c_evap= NaN(timestep,datalength);
    CD=NaN(timestep,datalength);
    CE = NaN(timestep,datalength);
    CH = NaN(timestep,datalength);
    Qs = NaN(timestep,datalength);
    for i=1:length(lon)
        % splitting the whole data set into hours for faster calculations
        h_date(j,k) = c_date(i);
        h_u_10(j,k) = u_10(i);
        h_T_water(j,k) = T_water(i);
        h_T(j,k) = T(i);
        h_q(j,k) = qair(i);
        h_P_air(j,k) = P_air(i);
        h_R_s(j,k) = R_s(i);
        h_rain(j,k) = rain(i);
        h_R_l(j,k) = R_l(i);
        h_lat(j,k) = lat(i);
        h_lon(j,k) = lon(i);
        
        j=j+1;
        % if one hour of data(timestep values - 1 minute values) is put into a
        % h_(Variable) vector the sea surface temperature, the sensible
        % heat flux and the latent heat flux will be calculated for that
        % hour
        if mod(i,timestep) == 0
            % checking if all data is available
            if ~isnan(h_u_10(:,k)) & ~isnan(h_T_water(:,k)) & ~isnan(h_T(:,k)) & ~isnan(h_q(:,k)) & ~isnan(h_P_air(:,k)) & ~isnan(h_R_s(:,k)) & ~isnan(h_R_l(:,k)) & ~isnan(h_rain(:,k))
                [qs, cd, ce, ch, h_webb, h_rain, h_sst, h_shf ,h_lhf,h_evap]=coare3_0(h_date(:,k),h_u_10(:,k),h_T_water(:,k),h_T(:,k),h_q(:,k),h_P_air(:,k),h_R_s(:,k),h_R_l(:,k),h_rain(:,k),h_lat(:,k),h_lon(:,k),win_height,hum_height,temp_height,bulktemp_depth,warmlayer);
                webb(:,k)=h_webb(:);%webb heatfluxcorrection 
                hrain(:,k)=h_rain(:);%rain heatflux
                sst(:,k)=h_sst(:);% sea surface temperature
                shf(:,k)=h_shf(:); % sensible heat flux
                lhf(:,k)=h_lhf(:); % latent heat flux
                c_evap(:,k)=h_evap(:); % evaporation
                CD(:,k)=cd(:);  % drag transfer coefficient
                CE(:,k)=ce(:);  % latent heat transfer coefficient
                CH(:,k)=ch(:);  % sensible heat transfer coefficient
                Qs(:,k)=qs(:);  % specific seasurface humidity
                k=k+1;
            else
                webb(:,k)=NaN(timestep,1);
                hrain(:,k)=NaN(timestep,1);
                sst(:,k)=NaN(timestep,1);
                lhf(:,k)=NaN(timestep,1);
                shf(:,k)=NaN(timestep,1);
                c_evap(:,k)=NaN(timestep,1);
                CD(:,k)=NaN(timestep,1);
                CE(:,k)=NaN(timestep,1);
                CH(:,k)=NaN(timestep,1);
                Qs(:,k)=NaN(timestep,1);
                k=k+1;
            end
            j=1;
        end
    end
% preallocating vectors for speed
s=NaN(length(lon),1);
qh=NaN(length(lon),1);
qe=NaN(length(lon),1);
evap=NaN(length(lon),1);
ce=NaN(length(lon),1);
e_s_surf=NaN(length(lon),1);
% reshaping the daily vectors of sst,shf,lhf into full time series
sst_vec=reshape(sst,size(sst,1)*size(sst,2),1);
lhf_vec=reshape(lhf,size(lhf,1)*size(lhf,2),1);
shf_vec=reshape(shf,size(shf,1)*size(shf,2),1);
webb_vec=reshape(webb,size(webb,1)*size(webb,2),1);
hrain_vec=reshape(hrain,size(hrain,1)*size(hrain,2),1);
c_evap_vec=reshape(c_evap,size(c_evap,1)*size(c_evap,2),1);
qair_corr=qair;
CD_vec=reshape(CD,size(CD,1)*size(CD,2),1);
CE_vec=reshape(CE,size(CE,1)*size(CE,2),1);
CH_vec=reshape(CH,size(CH,1)*size(CH,2),1);
Qs_vec=reshape(Qs,size(Qs,1)*size(Qs,2),1);

SHF=shf_vec+hrain_vec;
SST=sst_vec;
LHF=lhf_vec+webb_vec;
EVAP=reshape(c_evap,length(date),1);
RAIN=rain;




%Preparing the outdata - mixing OR data with calculated data
outdata=NaN(org_numel,57);
outdata(:,1:3)=data(:,1:3);                     % count, date UT, time UT
outdata(:,4)=localdate;                         % local date of the ship
outdata(:,5)=localtime;                         % local date of the ship
outdata(:,6)=data(:,4);                         % minutes of day
outdata(:,7)=data(:,5);                         % continuous count (julian day)
outdata(:,8)=data(:,6);                         % UTC (seconds since 01.01.1970 00:00)
outdata(:,9:11)=data(:,7:9);                    % lat, lon, heading
outdata(:,12:14)=data(:,10:12);                 % air temp, dew temp, bulk water temp
outdata(1:numel,15)=SST;                        % SST
outdata(:,16)=data(:,13);                       % Relative Humidity
outdata(1:numel,17)=Qs_vec;                     % spec hum at sea surface
outdata(1:numel,18)=qair;                       % spec air humidity
outdata(:,19)=data(:,14);                       % pressure         
outdata(:,20)=data(:,15);                       % relative windspeed
outdata(:,21)=data(:,16);                       % relative winddirection
outdata(:,22)=data(:,17);                       % true windspeed
outdata(:,23)=data(:,18);                       % true winddirection
outdata(1:numel,24)=u_10;                       % windspeed in 10 m height
outdata(:,25)=data(:,19);                       % global radiation
outdata(:,26)=data(:,20);                       % visibility
outdata(:,27)=data(:,21);                       % ceiling
outdata(:,28)=data(:,22);                       % max gusts
outdata(:,29)=data(:,23);                       % salinity
outdata(1:numel,30)=CD_vec;                     % drag transfer coeff
outdata(1:numel,31)=CE_vec;                     % lhf transfer coeff
outdata(1:numel,32)=CH_vec;                     % shf transfer coeff
outdata(1:numel,33)=warmflag;                   % warmlayerflag: 0 - no significant warmlayer, 1 - u10 below 2 m/s, 2 - u10 below 6 m/s and R_g > 50 w/m^2, 3 - harbor
outdata(1:numel,34)=SHF;                        % SHF
outdata(1:numel,35)=LHF;                        % LHF
outdata(1:numel,36)=EVAP;                       % evaporation
outdata(1:numel,37)=EVAP-RAIN;                  % budget

outdata(:,38:57)=data(:,24:43);                 % last 24 parameters from the original data

%Adding errorvalues instead of NaNs

outdata(isnan(outdata(:,15)),15)=-99.9;     % SST
outdata(isnan(outdata(:,17)),17)=-9.9;      % spec surface humidity
outdata(isnan(outdata(:,18)),18)=-9.9;      % spec air humidity
outdata(isnan(outdata(:,24)),24)=-9.9;      % wind in 10 m height
outdata(isnan(outdata(:,30)),30)=-99.9;     % drag transfer coeff
outdata(isnan(outdata(:,31)),31)=-99.9;     % lhf transfer coeff
outdata(isnan(outdata(:,32)),32)=-99.9;     % shf transfer coeff
outdata(isnan(outdata(:,34)),34)=-9999;     % SHF
outdata(isnan(outdata(:,35)),35)=-9999;     % LHF
outdata(isnan(outdata(:,36)),36)=-999;      % evaporation
outdata(isnan(outdata(:,37)),37)=-999;      % budget (E-P)

pos=strfind(filepath,'/');
outfilename=strcat(filepath(pos(end)+1:end-4),'_of.txt');
outfile=strcat(filepath(1:pos(end)),outfilename);
save(outfile,'outdata','-ascii');
toc






% HOAPS
if hoaps ==1
    for i=1:length(lon)
        % calculatating the humidity variables for the sea surface
        % saturation water vapor pressure:
        if RH(i) ~= -99 && P_air(i) ~= -999.9 && ~isnan(T(i))
            e_s_surf(i)=(murphy(sst_vec(i)+273.15));
        else
            e_s_surf(i) = NaN;
        end
        % specific humidity:
        if RH(i) ~= -99 && P_air(i) ~= -999.9
            qsurf(i)=((0.622*e_s_surf(i))/(((P_air(i)*100))-0.377*e_s_surf(i)))*1000*0.98;
            %0.98 accounting the salinity of 34ppt
        else
            qsurf(i) = NaN;
        end
        
        if qsurf(i)<qair(i)
            qair_corr(i)=qsurf(i)-0.01;
        end
        
        % checking if all data is avialable
        if ~isnan(sst_vec(i)) && ~isnan(qsurf(i)) && ~isnan(T(i)) && ~isnan(qair_corr(i)) && ~isnan(u_10(i))
            [s_, qh_, qe_, evap_, ce_] = hoaps_par_FLUX(sst_vec(i), qsurf(i), T(i), qair_corr(i), u_10(i),win_height,temp_height,hum_height);
            
            s(i) = s_;      % turbulent heat flux in W/m^2
            qh(i) = qh_;    % sensible heat flux in W/m^2
            qe(i) = qe_;    % latent heat flux in W/m^2
            evap(i) = evap_;% evaporation in mm/h
            ce(i) = ce_;    % transfer coefficient latent heat flux
            % else setting the variables as NaNs
        else
            s(i) = NaN;
            qh(i)=NaN;
            qe(i)=NaN;
            evap(i)=NaN;
            ce(i)=NaN;
        end
    end
end
end
end


function [idx] = mincheck(in)
% checks a vector for single missing values and gives back an idx vector
n=numel(in);
idx=nan(1,n);
for i=2:n-1
    if isnan(in(i))                          % minute missing
        idx(i) = NaN;
        if ~isnan(in(i-1)) & ~isnan(in(i+1))
            idx(i) = 1;                     % single minute missing - fixing
        else
            idx(i) = 2;                     % more than 1 minute missing - not fixing
        end
    end
end
end

function [fix] = minfix(in,idx)
% interpolates a vector when single minutes are missing,
% e.g. : 2 3 NaN 5 2 -> 2 3 4 5 2
n=numel(in);
fix=in;
for i=2:n-1
    if idx(i) == 1
        fix(i) = (in(i-1)+in(i+1))/2;
    end
end
end

function [e_s] = murphy(T)
%MURPHY Berechnet den Saettigungsdampfdruck fuer eine gegebene Temperatur
%in K
e_s=exp(54.842763 - 6763.22/T -4.210*log(T)+0.000367*T+tanh(0.0415*(T-218.8))*(53.878 - 1331.22/T - 9.44523*log(T)+0.014025*T));
end

function [qs, cd, ce, ch, hl_webb, Hrain, sst,hf,ef,evap] = coare3_0(Date,U,Tsea,Tair,qair,Pair,Rs,Rl,Rain,Lat,Lon,zu,zq,zt,bt,jwarm)
% Input:
% 1 Date: YYYYMMDDHHmmss.ss, YYYY=year, MM=month, DD=day, HH=hour,
% mm=minute,ss.ss=sec
% 2 U: true wind speed at 15-m height m/s corrected for surface currents
% 3 Tsea: sea surface temp (at about 0.05m depth) deg.C
% 4 Tair: Vaisala air temperature (about 15 m) deg.C
% 5 qair: Vaisala air specific humidity (about 15 m) g/kg
% 6 Rs: solar irradiance W/m2
% 7 Rl: downwelling longwave irradiance W/m2
% 8 Rain: precipitation mm/hr
% 9 Lat: Latitude (N=+)
% 10 Lon: Longitude (E=+)
% 11 zu: height of windmeasurement
% 12 zt: height of air temperature measurement
% 13 zq: height of air humidity measurement
% 14 bt: depth of bulk temp measurement
% 15 jwarm: switch for warmlayer, 0 off, 1 on
% Output:
% SST, hf:sensible heat flux, ef:latent heat flux
jdy=Date;%time in the form YYYYMMDDHHSS.SS
%U true wind speed, m/s; etl sonic anemometer
tsnk=Tsea;%sea snake temperature, C (0.05 m depth)
ta=Tair;%air temperature, C (z=14.5 m)
qa=qair;%air specific humidity, g/kg (z=14.5  m)
%qs=qsea;%sea surface sat specific humidity
rs=Rs;%downward solar flux, W/m^2 (ETL units)
rl=Rl;%downward IR flux, W/m^2 (ETL units)
org=Rain;%rainrate, mm/hr (ETL STI optical rain gauge, uncorrected)
lat=Lat;%latitude, deg  (SCS pcode)
lon=Lon;%longitude, deg (SCS pcode) 

%toga coare bulk flux model version 2.6
%***************************************
%uses following matlab subroutines:
%	cor30a.m
%	psiu_30.m
%	psit_30.m
%	qsee.m
%	grv.m
%***************************************

%*********** basic specifications  *****
%	jwarm=		0=no warm layer calc, 1 =do warm layer calc
%	jcool=		0=no cool skin calc, 1=do cool skin calc
%   jwave=      0= Charnock, 1=Oost et al, 2=Taylor and Yelland

%***********   input data **************
%	YYYYMMHHMMSS=		date in toga coare format, Y2K version
%	u=			wind speed (m/s), height zu
%	us=			surface current (m/s)
%	ts=			bulk surface sea temp (cent)
%	ta=			air temp (cent), height zt
%	qs=			sea surface sat specific humidity (g/kg)
%	q=			air specific humidity (g/kg), height zq
%	Rs=			downward solar flux (w/m^2)
%	Rl=			downward IR flux (w/m^2)
%	zi=			inversion height (m)
%	P=			air pressure (mb)
%	rain=		rain rate (mm/hr)
%	lon=		longitude (deg E=+)
%	lat=		latitude (deg N=+)


%********** output data  ***************
%	hsb=			sensible heat flux (w/m^2)
%	hlb=			latent heat flux (w/m^2)
%	RF=			rain heat flux(w/m^2)
%	wbar=	   	webb mean w (m/s)
%	tau=			stress (nt/m^2)
%	zo=			velocity roughness length (m)
%	zot			temperature roughness length (m)
%	zoq=			moisture roughness length (m)
%	L=			Monin_Obukhov stability length
%	usr=			turbulent friction velocity (m/s), including gustiness
%	tsr			temperature scaling parameter (K)
%	qsr			humidity scaling parameter (g/g)
%	dter=			cool skin temperature depression (K)
%	dqer=			cool skin humidity depression (g/g)
%	tkt=			cool skin thickness (m)
%	Cd=			velocity drag coefficient at zu, referenced to u
%	Ch=			heat transfer coefficient at zt
%	Ce=			moisture transfer coefficient at zq
%	Cdn_10=			10-m velocity drag coeeficient, including gustiness
%	Chn_10=			10-m heat transfer coeeficient, including gustiness
%	Cen_10=			10-m humidity transfer coeeficient, including gustiness
%


ts_depth=bt; %bulk water temperature sensor depth, ETL sea snake&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

jcool=1;
jwave=0;
icount=1;
%*********************  housekeep variables  ********	
qcol_ac=0;
tau_ac=0;
jtime=0;
jamset=0;
tau_old=.06;
hs_old=10;
hl_old=100;
RF_old=0;
dsea=0;
dt_wrm=0;
tk_pwp=19;
fxp=.5;
q_pwp=0;
jump=1;
%*******************  set constants  ****************
	tdk=273.16;
	grav=grv(-2);%9.72;
	Rgas=287.1;
	cpa=1004.67;

	be=0.026;
	cpw=4000;
	rhow=1022;
	visw=1e-6;
	tcw=0.6;
    dter=0.3;
    ts=tsnk(1);
%**************************&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%******************  preallocating of variables  ****
jdx=zeros(length(U),1);
locx=zeros(length(U),1);
rnl=zeros(length(U),1);
tsx=zeros(length(U),1);
qsx=zeros(length(U),1);
Hrain=zeros(length(U),1);
tau=zeros(length(U),1);
hs=zeros(length(U),1);
hl=zeros(length(U),1);
hnet=zeros(length(U),1);
dt=zeros(length(U),35);
hl_webb=zeros(length(U),1);
evap=zeros(length(U),1);
sst=zeros(length(U),1);
ef=zeros(length(U),1);
hf=zeros(length(U),1);
ce=zeros(length(U),1);
ch=zeros(length(U),1);
cd=zeros(length(U),1);
Qs=zeros(length(U),1);

%******************  setup read data loop  **********
nx=length(U);	%# of lines of data  
%d1=datenum(1998,12,31);
iyr0=fix(jdy(1)/1e10);%get year for first line of data
for ibg = 1:nx 			%major read loop
    
    %***********   set variables not in data base  ********
    P=Pair(ibg);               %air pressure in hPa
    us=0;                       %surface current
    zi=600;                    %inversion ht
    %*******   decode date  ************
    
    
    %[iyr mon iday ihr imin isec]=datevec(jdy(ibg)+d1);
    st=jdy(ibg);
    iyr=fix(st/1e10);
    mon=fix(st/1e8)-iyr*100;
    iday=fix(st/1e6)-iyr*1e4-mon*100;
    ihr=fix(st/1e4)-iyr*1e6-mon*1e4-iday*100;
    imin=fix(st/100)-fix(st/1e4)*100;
    isec=0;
    %timex=[iyr mon iday ihr imin isec];
    jd=datenum(iyr,mon,iday,ihr,imin,isec)-datenum(iyr0-1,12,31);%year day number, Jan 1=1
    jdx(ibg)=jd;
    %********   decode bulk met data ****
    u=U(ibg);%wind speed
    tsea=tsnk(ibg);%bulk sea surface temp********************&&&&&&&&&&&&&&&&&&&&&&&&&&&
    t=ta(ibg);%air temp
    qs=qsee([tsea P]);%bulk sea surface humidity
    q=qa(ibg);%air humidity
    Rs=rs(ibg);%downward solar flux
    Rl=rl(ibg);%doward IR flux
    rain=org(ibg);%rain rate
    grav=grv(lat(ibg));%9.72;
    lonx=lon(ibg);%longitude
    
    %*****  variables for warm layer  ***
    %ntime=1e6*mon+1e4*iday+100*ihr+imin;
    time=(ihr*3600+imin*60)/24/3600;
    intime=time;
    loc=(lonx+7.5)/15;
    locx(ibg)=loc;
    %Rnl=.97*(5.67e-8*(tsea-dter*jcool+273.16)^4-Rl);
    Rnl=.97*(5.67e-8*(ts-dter*jcool+273.16)^4-Rl);%oceanic broadband emissivity=0.97
    rnl(ibg)=Rnl;
    Rns=.945*Rs;%oceanic albedo=0.055 daily average
    %*********   set condition dependent stuff ******
    Le=(2.501-.00237*tsea)*1e6;
    cpv=cpa*(1+0.84*q/1000);
    rhoa=P*100/(Rgas*(t+tdk)*(1+0.61*q/1000));
    visa=1.326e-5*(1+6.542e-3*t+8.301e-6*t*t-4.84e-9*t*t*t);
    Al=2.1e-5*(tsea+3.2)^0.79;
    
    %**************   apply warm layer  ***********;
    if jwarm==1;                                            %do warm layer
        chktime=loc+intime*24;
        newtime=(chktime-24*fix(chktime/24))*3600;
        if icount>1                                     %not first time thru
            if newtime>21600 && jump==1
                % 					e=[num2str(icount) '  ' num2str(newtime) '  ' num2str(jtime) '   ' num2str(jump) '  ' num2str(q_pwp)  ];
                % 					disp(e)
                %goto 16
            else
                jump=0;
                if newtime <jtime		%re-zero at midnight
                    jamset=0;
                    fxp=.5;
                    tk_pwp=19;
                    tau_ac=0;
                    qcol_ac=0;
                    dt_wrm=0;
                    jump=0;                   %goto 16
                else
                    %****   set warm layer constants  ***
                    rich=.65;                		%crit rich
                    ctd1=sqrt(2*rich*cpw/(Al*grav*rhow));
                    ctd2=sqrt(2*Al*grav/(rich*rhow))/(cpw^1.5);
                    %*********************************
                    dtime=newtime-jtime;			%delta time for integrals
                    qr_out=Rnl+hs_old+hl_old+RF_old;	%total cooling at surface
                    q_pwp=fxp*Rns-qr_out;			%tot heat abs in warm layer
                    if q_pwp<50 & jamset==0			%check for threshold
                        %goto 16
                    else
                        jamset=1;			%indicates threshold crossed
                        tau_ac=tau_ac+max(.002,tau_old)*dtime;	%momentum integral
                        if qcol_ac+q_pwp*dtime>0	%check threshold for warm layer existence
                            for i=1:5		%loop 5 times for fxp
                                
                                fxp=1-(0.28*0.014*(1-exp(-tk_pwp/0.014))+0.27*0.357*(1-exp(-tk_pwp/0.357))+0.45*12.82*(1-exp(-tk_pwp/12.82)))/tk_pwp;
                                %fg=fpaul(tk_pwp);fxp=fg(1);
                                qjoule=(fxp*Rns-qr_out)*dtime;
                                if qcol_ac+qjoule>0
                                    tk_pwp=min(19,ctd1*tau_ac/sqrt(qcol_ac+qjoule));
                                end;
                            end;%  end i loop
                        else				%warm layer wiped out
                            fxp=0.75;
                            tk_pwp=19;
                            qjoule=(fxp*Rns-qr_out)*dtime;
                        end;%   end sign check on qcol_ac
                        qcol_ac=qcol_ac+qjoule;		%heat integral
                        %*******  compute dt_warm  ******
                        if qcol_ac>0
                            dt_wrm=ctd2*(qcol_ac)^1.5/tau_ac;
                        else
                            dt_wrm=0;
                        end;
                    end;%                    end threshold check
                end;%                            end midnight reset
                if tk_pwp<ts_depth
                    dsea=dt_wrm;
                else
                    dsea=dt_wrm*ts_depth/tk_pwp;
                end;
            end;%                                    end 6am start first time thru
        end;%                                            end first time thru check
        jtime=newtime;
    end;%  end jwarm,  end warm layer model appl check
    
    ts=tsea+dsea;
    qs=qsee([ts P]);
    if qs<q
        q=qs-0.01;
    end
    qsx(ibg)=qs;
    tsx(ibg)=ts;
    a=.018;
    b=.729;
    twave=b*u;
    hwave=a*u.^2.*(1+.015*u);
    
    x=[u us ts t qs q Rs Rl rain zi  P zu zt zq lat(ibg) jcool jwave twave hwave] ;		%set data for basic flux alogithm
    %********    call modified LKB routine *******
    [y, m_evap]=cor30a(x);
    %************* output from routine  *****************************
    hsb=y(1);                   %sensible heat flux W/m/m
    hlb=y(2);                   %latent
    taub=y(3);                   %stress
    zo=y(4);                    %vel roughness
    zot=y(5);                   %temp "
    zoq=y(6);                   %hum  "
    L=y(7);                     %Ob Length
    usr=y(8);                   %ustar
    tsr=y(9);                   %tstar
    qsr=y(10);                  %qstar  [g/g]
    dter=y(11);                 %cool skin delta T
    dqer=y(12);                 %  "   "     "   q
    tkt=y(13);                  %thickness of cool skin
    RF=y(14);                   %rain heat flux
    wbar=y(15);                 %webb mean w
    Cd=y(16);                   %drag @ zu
    Ch=y(17);                   %
    Ce=y(18);                   %Dalton
    Cdn_10=y(19);               %neutral drag @ 10 [includes gustiness]
    Chn_10=y(20);               %
    Cen_10=y(21);               %
    Wg=y(22);
    zax(1)=jd;                  %julian day
    zax(2:10)=x(1:9);           %
    zax(4)=tsea;                %Tsea [no cool skin]
    zax(11:32)=y(1:22);               %
    zax(33:35)=[dt_wrm tk_pwp ts];  %warm layer deltaT, thickness, corrected Tsea
    %*******   previous values from cwf hp basic code *****
    
    Hrain(ibg)=RF;
    %**********  new values from this code
    hnet(ibg)=Rns-Rnl-hsb-hlb-Hrain(ibg);%total heat input to ocean
    hs(ibg)=hsb;
    hl(ibg)=hlb;
    evap(ibg)=m_evap;
    tau(ibg)=taub;
    hl_webb(ibg)=rhoa*Le*wbar*qa(ibg)/1000;
    %********************  save various parts of data **********************************
    dt(ibg,:)=zax;
    sst(ibg)=ts-dter*jcool;
    hf(ibg)=hsb;
    ef(ibg)=hlb;
    %Transfer coefficients: cd=drag, ch=sensible heat, ce=latent heat
    cd(ibg)=Cd;
    ch(ibg)=Ch;
    ce(ibg)=Ce;
    Qs(ibg)=qs;
	hs_old=hsb;
	hl_old=hlb;
	RF_old=RF;
	tau_old=taub;
   icount=icount+1;
   
end; %  data line loop


end

function [y, evap]=cor30a(x)
%version with shortened iteration; modified Rt and Rq
%uses wave information wave period in s and wave ht in m
%no wave, standard coare 2.6 charnock:  jwave=0 
%Oost et al.  zo=50/2/pi L (u*/c)^4.5 if jwave=1
%taylor and yelland  zo=1200 h*(L/h)^4.5 jwave=2
%x=[5.5 0 28.7 27.2 24.2 18.5 141 419 0 600 1010 15 15 15 0 1 1 5 1 ];%sample data stream
u=x(1);%wind speed (m/s)  at height zu (m)
us=x(2);%surface current speed in the wind direction (m/s)
ts=x(3);%bulk water temperature (C) if jcool=1, interface water T if jcool=0  
t=x(4);%bulk air temperature (C), height zt
Qs=x(5)/1000;%bulk water spec hum (g/kg) if jcool=1, ...
Q=x(6)/1000;%bulk air spec hum (g/kg), height zq
Rs=x(7);%downward solar flux (W/m^2)
Rl=x(8);%downard IR flux (W/m^2)
rain=x(9);%rain rate (mm/hr)
zi=x(10);%PBL depth (m)
P=x(11);%Atmos surface pressure (mb)
zu=x(12);%wind speed measurement height (m)
zt=x(13);%air T measurement height (m)
zq=x(14);%air q measurement height (m)
lat=x(15);%latitude (deg, N=+)
jcool=x(16);%implement cool calculation skin switch, 0=no, 1=yes
jwave=x(17);%implement wave dependent rclose alloughness model
twave=x(18);%wave period (s)
hwave=x(19);%wave height (m)

     %***********   set constants *************
     Beta=1.2;
     von=0.4;
     fdg=1.00;
     tdk=273.16;
     grav=grv(lat);%9.82;
     %*************  air constants ************
     Rgas=287.1;
     Le=(2.501-.00237*ts)*1e6;
     cpa=1004.67;
     cpv=cpa*(1+0.84*Q);
     rhoa=P*100/(Rgas*(t+tdk)*(1+0.61*Q));
     visa=1.326e-5*(1+6.542e-3*t+8.301e-6*t*t-4.84e-9*t*t*t);
     %************  cool skin constants  *******
     Al=2.1e-5*(ts+3.2)^0.79;
     be=0.026;
     cpw=4000;
     rhow=1022;
     visw=1e-6;
     tcw=0.6;
     bigc=16*grav*cpw*(rhow*visw)^3/(tcw*tcw*rhoa*rhoa);
     wetc=0.622*Le*Qs/(Rgas*(ts+tdk)^2);
     
     %***************   wave parameters  *********
     lwave=grav/2/pi*twave^2;
     cwave=grav/2/pi*twave;
     
     %**************  compute aux stuff *******
     Rns=Rs*.945;
     
     Rnl=0.97*(5.67e-8*(ts-0.3*jcool+tdk)^4-Rl);
     
     %***************   Begin bulk loop *******
     
     %***************  first guess ************
     du=u-us;
     dt=ts-t-.0098*zt;
     dq=Qs-Q;
     ta=t+tdk;
     ug=.5;
     dter=0.3; 
     dqer=wetc*dter;
     ut=sqrt(du*du+ug*ug);
	  u10=ut*log(10/1e-4)/log(zu/1e-4);
     usr=.035*u10;
	zo10=0.011*usr*usr/grav+0.11*visa/usr;
	Cd10=(von/log(10/zo10))^2;
	Ch10=0.00115;
	Ct10=Ch10/sqrt(Cd10);
	zot10=10/exp(von/Ct10);
	Cd=(von/log(zu/zo10))^2;
	Ct=von/log(zt/zot10);
	CC=von*Ct/Cd;
	Ribcu=-zu/zi/.004/Beta^3;
	Ribu=-grav*zu/ta*((dt-dter*jcool)+.61*ta*dq)/ut^2;
	nits=3;
	if Ribu<0;
		zetu=CC*Ribu/(1+Ribu/Ribcu);
    else
		zetu=CC*Ribu*(1+27/9*Ribu/CC);
    end;		
	L10=zu/zetu;
	if zetu>50;
		nits=1;
	end;
     usr=ut*von/(log(zu/zo10)-psiu_30(zu/L10));
     tsr=-(dt-dter*jcool)*von*fdg/(log(zt/zot10)-psit_30(zt/L10));
     qsr=-(dq-wetc*dter*jcool)*von*fdg/(log(zq/zot10)-psit_30(zq/L10));

     tkt=.001;
	
   charn=0.011;
   if ut>10
      charn=0.011+(ut-10)/(18-10)*(0.018-0.011);
   end;
   if ut>18
      charn=0.018;
   end;
   
     %disp(usr)
     
     %***************  bulk loop ************
  for i=1:nits;
     
     zet=von*grav*zu/ta*(tsr*(1+0.61*Q)+.61*ta*qsr)/(usr*usr)/(1+0.61*Q);
      %disp(usr)
      %disp(zet);
      if jwave==0;zo=charn*usr*usr/grav+0.11*visa/usr;end;
      if jwave==1;zo=50/2/pi*lwave*(usr/cwave)^4.5+0.11*visa/usr;end;%Oost et al
      if jwave==2;zo=1200*hwave*(hwave/lwave)^4.5+0.11*visa/usr;end;%Taylor and Yelland
      rr=zo*usr/visa;
     L=zu/zet;
     zoq=min(1.15e-4,5.5e-5/rr^.6);
     zot=zoq;
     usr=ut*von/(log(zu/zo)-psiu_30(zu/L));
     tsr=-(dt-dter*jcool)*von*fdg/(log(zt/zot)-psit_30(zt/L));
     qsr=-(dq-wetc*dter*jcool)*von*fdg/(log(zq/zoq)-psit_30(zq/L));
     Bf=-grav/ta*usr*(tsr+.61*ta*qsr);
     if Bf>0
     ug=Beta*(Bf*zi)^.333;
     else
     ug=.2;
     end;
     ut=sqrt(du*du+ug*ug);
     Rnl=0.97*(5.67e-8*(ts-dter*jcool+tdk)^4-Rl);
     hsb=-rhoa*cpa*usr*tsr;
     hlb=-rhoa*Le*usr*qsr;
     qout=Rnl+hsb+hlb;
     dels=Rns*(.065+11*tkt-6.6e-5/tkt*(1-exp(-tkt/8.0e-4))); 	% Eq.16 Shortwave
     qcol=qout-dels;
     alq=Al*qcol+be*hlb*cpw/Le;					% Eq. 7 Buoy flux water

     if alq>0;
     		xlamx=6/(1+(bigc*alq/usr^4)^.75)^.333;				% Eq 13 Saunders
            tkt=xlamx*visw/(sqrt(rhoa/rhow)*usr);			%Eq.11 Sub. thk

     else
            xlamx=6.0;
            tkt=min(.01,xlamx*visw/(sqrt(rhoa/rhow)*usr));			%Eq.11 Sub. thk
     end;
     
     %dter=qcol*tkt/tcw;%  Eq.12 Cool skin
     dter= -(-0.14-0.3*exp(-u/3.7));
     dqer=wetc*dter;
     
  end;%bulk iter loop
     tau=rhoa*usr*usr*du/ut;                %stress
     hsb=-rhoa*cpa*usr*tsr;
     hlb=-rhoa*Le*usr*qsr;
     evap=-3600*rhoa*usr*qsr;
     
     %****************   rain heat flux ********
     
      dwat=2.11e-5*((t+tdk)/tdk)^1.94;%! water vapour diffusivity
      dtmp=(1.+3.309e-3*t-1.44e-6*t*t)*0.02411/(rhoa*cpa); 	%!heat diffusivity
      alfac= 1/(1+(wetc*Le*dwat)/(cpa*dtmp));      	%! wet bulb factor
      RF= rain*alfac*cpw*((ts-t-dter*jcool)+(Qs-Q-dqer*jcool)*Le/cpa)/3600;
     %****************   Webb et al. correection  ************
     wbar=1.61*hlb/Le/(1+1.61*Q)/rhoa+hsb/rhoa/cpa/ta;%formulation in hlb already includes webb
     %wbar=1.61*hlb/Le/rhoa+(1+1.61*Q)*hsb/rhoa/cpa/ta;
     hl_webb=rhoa*wbar*Q*Le;
     %**************   compute transfer coeffs relative to ut @meas. ht **********
     Cd=tau/rhoa/ut/max(.1,du);
     Ch=-usr*tsr/ut/(dt-dter*jcool);
     Ce=-usr*qsr/(dq-dqer*jcool)/ut;
     %************  10-m neutral coeff realtive to ut ********
     Cdn_10=von*von/log(10/zo)/log(10/zo);
     Chn_10=von*von*fdg/log(10/zo)/log(10/zot);
     Cen_10=von*von*fdg/log(10/zo)/log(10/zoq);
   
    
   y=[hsb hlb tau zo zot zoq L usr tsr qsr dter dqer tkt RF wbar Cd Ch Ce Cdn_10 Chn_10 Cen_10 ug];
   %   1   2   3   4  5   6  7  8   9  10   11   12  13  14  15  16 17 18  19      20    21    22
end

function [ w_corr ] = neutral_equiv_wind_correction( uz, zh)
%correcting wind speeds [m/s] (below: uz) at height z ASL (below: zh) 
%to neutral equivalent wind speed (below: w_corr) at e.g. 10 m ASL (below: height)
%   

height = 10;        % desired height of wind speed

% parameters
MAX_N = 100;        % maximum number of iterations
C_von = 0.40;        % von karman constant
eps = 0.001;        % small number
chrnk = 0.011;      % Charnock coefficient
visc = 14.5e-6;     % kinematic viscosity of air @ 15C
wg = 0.2;           % wind gustiness

z_=zh;

% first guess of ustar
us  = 0.036*uz;
us2 = 0*uz;
z0 = 0*uz;

%check input // eig. unnötig vllt. TODO
%pos = find(tcnt <= 0 | uz < 0);

%include gustiness in wind spd.
%Du = sqrt(uz^2+wg^2);
Du = uz;

% modification of charnok after Fairall
charn = chrnk;
if (Du >= 10)
    charn = 0.011 + (0.018 - 0.011) * (Du - 10) / (18 - 10);
elseif (Du >= 18)
    charn = 0.018;
end

%iteration loop
for i = 1:MAX_N
    % result checking
    if abs(us2-us) <= eps
        break;
    end
    
    % next iteration
    us2 = us;
    
    % calculate roughness length
    z0=charn*us*us/9.81+0.11*(visc/us);
    
    if (z_*0.5 < z0)
        z0 = z_*0.5;
    end
    
    % calculate ustar
    us = C_von * Du / log(z_/z0);
end
    
w_corr = (us*log(height/z0))/ C_von;
end

function g=grv(lat)
gamma=9.7803267715;
c1=0.0052790414;
c2=0.0000232718;
c3=0.0000001262;
c4=0.0000000007;

phi=lat*pi/180;
x=sin(phi);
g=gamma*(1+c1*x.^2+c2*x.^4+c3*x.^6+c4*x.^8);
end

function s=qsee(y)
x=y(:,1);
p=y(:,2);
es=6.112.*exp(17.502.*x./(x+240.97))*.98.*(1.0007+3.46e-6*p);
s=es*621.97./(p-.378*es);
end

function psi=psiu_30(zet)

	x=(1-15*zet).^.25;
	psik=2*log((1+x)/2)+log((1+x.*x)/2)-2*atan(x)+2*atan(1);
	x=(1-10.15*zet).^.3333;
	psic=1.5*log((1+x+x.*x)/3)-sqrt(3)*atan((1+2*x)/sqrt(3))+4*atan(1)/sqrt(3);
	f=zet.*zet./(1+zet.*zet);
	psi=(1-f).*psik+f.*psic;                                               
   ii=find(zet>0);
   if ~isempty(ii);

	%psi(ii)=-4.7*zet(ii);
  	%c(ii)=min(50,.35*zet(ii));
   c=min(50,.35*zet);
	psi(ii)=-((1+1.0*zet(ii)).^1.0+.667*(zet(ii)-14.28)./exp(c(ii))+8.525);
	end;
end

function psi=psit_30(zet)
	x=(1-15*zet).^.5;
	psik=2*log((1+x)/2);
	x=(1-34.15*zet).^.3333;
	psic=1.5*log((1+x+x.*x)/3)-sqrt(3)*atan((1+2*x)/sqrt(3))+4*atan(1)/sqrt(3);
	f=zet.*zet./(1+zet.*zet);
   psi=(1-f).*psik+f.*psic;  
   
   ii=find(zet>0);
if ~isempty(ii);
	%psi=-4.7*zet;
	c=min(50,.35*zet);
   psi(ii)=-((1+2/3*zet(ii)).^1.5+.6667*(zet(ii)-14.28)./exp(c(ii))+8.525);
end;

end

function y=qsat(y)
x=y(:,1);%temp
p=y(:,2);%pressure
es=6.112.*exp(17.502.*x./(x+241.0)).*(1.0007+3.46e-6*p);
y=es*622./(p-.378*es);
end