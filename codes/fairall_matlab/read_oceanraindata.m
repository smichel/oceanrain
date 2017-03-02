function read_oceanrain=
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
%TOFIX:   [sst,shf,lhf]           = SST_cor3_0af(Date,U,Tsea,Tair,qair,Rs,Rl,rain,Lat,Lon,win_height,zq,zt,bt,warmlayer)
%   [s, qh, qe, evap, ce] = hoaps_par_FLUX(ts, qs, t, q, u)

%%%Ship meta data, in m:
meteor = 0;
polarstern = 0;
investigator = 1;
sonne = 0;
merian = 0;


% Meteor: Wind, Temp, Humidity on 37.5 m height, Watertemp on 2.5 m
if meteor == 1
    win_height = 37.5;     % height of wind measurement
    temp_height = 37.5;     % height of temp measurement
    hum_height  = 37.5;     % height of humidity measurement
    bulktemp_depth= 2.5;      % depth of watertemperature measurement
    
% Polarstern: Wind on 39 m, Humidity and Temp on 29 m, Watertemp on 5 m
elseif polarstern == 1

    win_height = 39;
    temp_height = 29;
    hum_height  = 29;
    bulktemp_depth= 5;

% Investigator: Wind on 22.1 m, Humidity and Temp on 31.4m,  Watertemp on 6.9m
elseif investigator == 1

    win_height = 22.1;
    temp_height = 31.4;
    hum_height  = 31.4;
    bulktemp_depth= 6.9;

% Sonne: Wind on 34m, Humidity and Temp on 27 m, Watertemp on 2m
elseif sonne == 1
    
    win_height = 34;
    temp_height = 27;
    hum_height = 27;
    bulktemp_depth = 2;
    
% Merian: Wind on 30.76m, Humidity and Temp on 20.18, Watertemp on 4.2m
elseif merian == 1
    
    win_height = 30.76;
    temp_height = 20.18;
    hum_height = 20.18;
    bulktemp_depth = 4.2;
        
end 

%Algorithm specs
sigma=5.67*10^(-8); % W/m2/K4 Boltzmannconstant
warmlayer = 0;      % Warmlayer flag for the Coare algorithm
hoaps=0;            % Hoaps algorithm isnt calculated
%lengthcheck

%find the beginning of the first full day



numel=length(data);


%data reshaping and throwing away exceeding minutes for 60 min vectors 
date=   data(1:(length(data(:,4))-mod(length(data(:,4)),60)),2);        % date in DDMMYYYY
time=   data(1:(length(data(:,4))-mod(length(data(:,4)),60)),3);        % time
mmday=  data(1:(length(data(:,4))-mod(length(data(:,4)),60)),4);        % daily minutes
lat=    data(1:(length(data(:,4))-mod(length(data(:,4)),60)),7);        % latitude
lon=    data(1:(length(data(:,4))-mod(length(data(:,4)),60)),8);        % longitude
T=      data(1:(length(data(:,4))-mod(length(data(:,4)),60)),10);       % air temperature in C
Twater= data(1:(length(data(:,4))-mod(length(data(:,4)),60)),12);       % water temperature in C
RH=     data(1:(length(data(:,4))-mod(length(data(:,4)),60)),13);       % relative humidity in %
P_air=  data(1:(length(data(:,4))-mod(length(data(:,4)),60)),14);       % pressure in hPA
u=      data(1:(length(data(:,4))-mod(length(data(:,4)),60)),17);       % windspeed in m/s
R_g=    data(1:(length(data(:,4))-mod(length(data(:,4)),60)),19);       % global Radiation in W/m2
sal=    data(1:(length(data(:,4))-mod(length(data(:,4)),60)),23);       % salinity in PSU
rain=   data(1:(length(data(:,4))-mod(length(data(:,4)),60)),38);       % rain rate in mm/h
% counts
j=1; k=1; o=1;

% calculating the localtime of the ship with the longitude

localtime_zone=timezone(lon);
localtime=time-localtime_zone*100;


%preallocating vectors for speed
qair=NaN(length(lon),1);  % spec air humidity in g/kg
w_10m=NaN(length(lon),1); % 10m windspeed in m/s
R_s=NaN(length(lon),1);   % short wave radiation in W/m2 (=global radiation)
R_l=NaN(length(lon),1);   % long wave radiation in W/m2
qsurf=NaN(length(lon),1); % sea surface spec humidity in g/kg
e_s=NaN(length(lon),1);   % saturation water vapor in hPa
e=NaN(length(lon),1);     % saturation water vapor in hPa

%preparing the parameters for further calculations, e.g. filling the
%missing/ error values with NaNs
%throwing away harbormeasurements: data(:,34)== 5 means harbor
for i=1:length(lon)

    if localtime(i)>2359
        localtime(i)=localtime(i)-2400;
    elseif localtime(i)<0
        localtime(i)=localtime(i)+2400;
    end
        
    if data(i,34) ~=5
        if T(i) < -90
            T(i) = NaN;
        end
        if Twater(i) < -90
            Twater(i) = NaN;
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
            w_10m(i) = neutral_equiv_wind_correction(u(i),win_height);
        else
            w_10m(i) = NaN;
        end
        
        % if the warmlayer effect is relevant in the calculations the longwave
        % radiation will be calculated with the sigma T^4 formula
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
        if sonne == 1
            R_g(i)=0;
            R_l(i)=0;
            R_s(i)=0;
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
        Twater(i)=NaN;
        sal(i)=NaN;
        lat(i)=NaN;
        lon(i)=NaN;
        rain(i)=NaN;
        R_s(i) = NaN;
        R_l(i) = NaN;
        R_g(i) = NaN;
        w_10m(i)=NaN;
        qair(i)=NaN;
    end
end

%reshaping the date from ddmmyyyy to YYYYMMDDHHMMSS localtime for the COARE
%CODE, needed for implementing the warmlayereffect in the future
c_date=rem(date,10000)*10000000000+floor(rem(date,1000000)/10000)*100000000+floor(date/1000000)*1000000+localtime*100;

%after calculating the 10 m windspeed with the logarithmic wind profile the
%new "measurement height" is 10 m for future algorithms
win_height=10;

% number of available minutes where all relevant parameters are measured
avail_min = sum(~isnan(w_10m(:)) & ~isnan(Twater(:)) & ~isnan(T(:)) & ~isnan(qair(:)) & ~isnan(P_air(:)) & ~isnan(R_s(:)) & ~isnan(R_l(:)) & ~isnan(rain(:)));
timestep=60;
%check if the data is already calculated
datacalculated = exist('sst','var'); %clear data;
% if data is calculated, it wont be calculated again
if datacalculated == 0
    
    datalength=length(date)/timestep;
    % Preallocating for speed - shaping the data into hourly data
    h_date=NaN(timestep,datalength);
    h_w_10m=NaN(timestep,datalength);
    h_Twater=NaN(timestep,datalength);
    h_T=NaN(timestep,datalength);
    h_q=NaN(timestep,datalength);
    h_rain=NaN(timestep,datalength);
    h_P_air=NaN(timestep,datalength);
    h_R_s=NaN(timestep,datalength);
    h_R_l=NaN(timestep,datalength);
    h_lat=NaN(timestep,datalength);
    h_lon=NaN(timestep,datalength);
    sst = NaN(timestep,datalength);
    hrain=NaN(timestep,datalength);
    webb=NaN(timestep,datalength);
    shf = NaN(timestep,datalength);
    lhf = NaN(timestep,datalength);
    c_evap= NaN(timestep,datalength);
    Cd=NaN(timestep,datalength);
    Ce = NaN(timestep,datalength);
    Ch = NaN(timestep,datalength);
    Qs = NaN(timestep,datalength);
    for i=1:length(lon)
        % splitting the whole data set into days for faster calculations
        h_date(j,k) = c_date(i);
        h_w_10m(j,k) = w_10m(i);
        h_Twater(j,k) = Twater(i);
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
            if ~isnan(h_w_10m(:,k)) & ~isnan(h_Twater(:,k)) & ~isnan(h_T(:,k)) & ~isnan(h_q(:,k)) & ~isnan(h_P_air(:,k)) & ~isnan(h_R_s(:,k)) & ~isnan(h_R_l(:,k)) & ~isnan(h_rain(:,k))
                [qs, cd, ce, ch, h_webb, h_rain, h_sst, h_shf ,h_lhf,h_evap]=coare3_0(h_date(:,k),h_w_10m(:,k),h_Twater(:,k),h_T(:,k),h_q(:,k),h_P_air(:,k),h_R_s(:,k),h_R_l(:,k),h_rain(:,k),h_lat(:,k),h_lon(:,k),win_height,hum_height,temp_height,bulktemp_depth,warmlayer);
                webb(:,k)=h_webb(:);%webb heatfluxcorrection 
                hrain(:,k)=h_rain(:);%rain heatflux
                sst(:,k)=h_sst(:);% sea surface temperature
                shf(:,k)=h_shf(:); % sensible heat flux
                lhf(:,k)=h_lhf(:); % latent heat flux
                c_evap(:,k)=h_evap(:); % evaporation
                Cd(:,k)=cd(:);  % drag transfer coefficient
                Ce(:,k)=ce(:);  % latent heat transfer coefficient
                Ch(:,k)=ch(:);  % sensible heat transfer coefficient
                Qs(:,k)=qs(:);  % specific seasurface humidity
                k=k+1;
            else
                webb(:,k)=NaN(timestep,1);
                hrain(:,k)=NaN(timestep,1);
                sst(:,k)=NaN(timestep,1);
                lhf(:,k)=NaN(timestep,1);
                shf(:,k)=NaN(timestep,1);
                c_evap(:,k)=NaN(timestep,1);
                Cd(:,k)=NaN(timestep,1);
                Ce(:,k)=NaN(timestep,1);
                Ch(:,k)=NaN(timestep,1);
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
Cd_vec=reshape(Cd,size(Cd,1)*size(Cd,2),1);
Ce_vec=reshape(Ce,size(Ce,1)*size(Ce,2),1);
Ch_vec=reshape(Ch,size(Ch,1)*size(Ch,2),1);
Qs_vec=reshape(Qs,size(Qs,1)*size(Qs,2),1);

SHF=shf_vec+hrain_vec;
SST=sst_vec;
LHF=lhf_vec+webb_vec;
EVAP=reshape(c_evap,length(date),1);
RAIN=rain;

%Preparing the outdata - mixing OR data with calculated data
outdata=NaN(numel,54);
outdata(:,1:12)=data(:,1:12);               %12 first parameters like the original format
outdata(1:(end-mod(numel,60)),13)=SST;      % adding the SST
outdata(:,14)=data(:,13);                   % Relative Humidity
outdata(1:(end-mod(numel,60)),15)=Qs_vec;   % spec hum at sea surface
outdata(1:(end-mod(numel,60)),16)=qair;     % spec air humidity
outdata(:,17)=data(:,14);                   % pressure         
outdata(:,18)=data(:,15);                   % relative windspeed
outdata(:,19)=data(:,16);                   % relative winddirection
outdata(:,20)=data(:,17);                   % true windspeed
outdata(:,21)=data(:,18);                   % true winddirection
outdata(1:(end-mod(numel,60)),22)=w_10m;    % windspeed in 10 m height
outdata(:,23)=data(:,19);                   % global radiation
outdata(1:(end-mod(numel,60)),24)=shf_vec;  % SHF
outdata(1:(end-mod(numel,60)),25)=lhf_vec;  % LHF
outdata(1:(end-mod(numel,60)),26)=Cd_vec;   % drag transfer coeff
outdata(1:(end-mod(numel,60)),27)=Ce_vec;   % lhf transfer coeff
outdata(1:(end-mod(numel,60)),28)=Ch_vec;   % shf transfer coeff
outdata(1:(end-mod(numel,60)),29)=EVAP;     % evaporation
outdata(1:(end-mod(numel,60)),30)=EVAP-RAIN;% budget
outdata(:,42:54)=data(:,31:43);             % last 12 parameters from the original data








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
        if ~isnan(sst_vec(i)) && ~isnan(qsurf(i)) && ~isnan(T(i)) && ~isnan(qair_corr(i)) && ~isnan(w_10m(i))
            [s_, qh_, qe_, evap_, ce_] = hoaps_par_FLUX(sst_vec(i), qsurf(i), T(i), qair_corr(i), w_10m(i),win_height,temp_height,hum_height);
            
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