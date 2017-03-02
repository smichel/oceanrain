clear; close all;
load('data_polarstern.mat')

%addings nans to the end for plotting
if investigator==1
    lon(end+1)=NaN;
    lat(end+1)=NaN;
    h_waterfluxsum_mm(end+1)=NaN;
    Twater(end+1)=NaN;
    T(end+1)=NaN;
    rain(end+1)=NaN;
    RAIN(end+1)=NaN;
    sst_vec(end+1)=NaN;
    w_10m(end+1)=NaN;
    lhf_vec(end+1)=NaN;
    shf_vec(end+1)=NaN;
    sal(end+1)=NaN;
    EVAP(end+1)=NaN;
end

cumulative_evap=zeros(length(EVAP),1);
cumulative_precip=zeros(length(RAIN),1);

if isnan(EVAP(1))
    cumulative_evap(1)=0;
else
    cumulative_evap(1)=EVAP(1);
end

if isnan(RAIN(1))
    cumulative_precip(i)=0;
else
    cumulative_precip(i)=RAIN(1);
end

for i=2:length(EVAP)
    
    if ~isnan(EVAP(i))
        cumulative_evap(i)=cumulative_evap(i-1)+EVAP(i);
    else
        cumulative_evap(i)=cumulative_evap(i-1);
    end
    
    if ~isnan(RAIN(i))
        cumulative_precip(i)=cumulative_precip(i-1)+RAIN(i);
    else
        cumulative_precip(i)=cumulative_precip(i-1);
    end
    
end

coast=load ('coast');

if drawGraphs ==false
hold on
plot(cumulative_precip)
legend('Evaporation in mm/d','Precipitation in mm/d')


% shiptrackplot of the waterfluxsum
figure
coast=load ('coast');
plot(coast.long, coast.lat)
hold on
title('Waterfluxsum')
patch(lon,lat,h_waterfluxsum_mm,'EdgeColor','flat')
colorbar
[cmin, cmax] = caxis;
caxis([0,cmax])
map=parula;
map(1,:)=[1 0 0];
colormap(map)

% shiptrackplot
figure
coast=load ('coast');
plot(coast.long, coast.lat)
hold on
plot(lon,lat)
title('Shiptrack')


% shiptrackplot of the bulkwatertemperature
figure
coast=load ('coast');
plot(coast.long, coast.lat)
hold on
colormap(parula)
title('Water Temperature')
patch(lon,lat,Twater,'EdgeColor','flat')
colorbar

figure
coast=load ('coast');
plot(coast.long, coast.lat)
hold on
colormap(flipud(parula))
title('Precipitation in mm/h')
patch(lon,lat,rain,'EdgeColor','flat')
colorbar


% shiptrackplot of the 10 m corrected windspeed
figure
plot(coast.long, coast.lat)
hold on
title('10 m Wind')
colormap(parula)
patch(lon,lat,w_10m,'EdgeColor','flat')
colorbar

% shiptrackplot of the seasurfacetemperature
figure
plot(coast.long, coast.lat)
hold on
colormap(parula)
title('sst')
patch(lon,lat,sst_vec,'EdgeColor','flat')
colorbar

% shiptrackplot of the latent heatflux
figure
plot(coast.long, coast.lat)
hold on
colormap(parula)
title('latent heatflux')
patch(lon,lat,lhf_vec,'EdgeColor','flat')
colorbar

% shiptrackplot of the sensible heatflux
figure
plot(coast.long, coast.lat)
hold on
colormap(parula)
title('sensible heatflux')
patch(lon,lat,shf_vec,'EdgeColor','flat')
colorbar

% shiptrackplot of the salinity
figure
plot(coast.long, coast.lat)
hold on
colormap(jet)
title('salinity')
patch(lon,lat,sal,'EdgeColor','flat')
colorbar
end

day=290;
day2=300;
min = day*1440;

figure
subplot(5,1,1)
plot(SHF(day*1440:day2*1440),'-','Color',[0, 0, 1])
hold on
grid on
plot(LHF(day*1440:day2*1440),'-','Color',[0, 0, 0.7])
legend('sensible heat flux','latent heat flux')
ylabel('W/m^2')
subplot(5,1,2)
plot(sst_vec(day*1440:day2*1440),'-','Color',[1, 0.7, 0])
hold on
grid on
ylabel('̊ C')
plot(Twater(day*1440:day2*1440),'-','Color',[0, 0, 1])
plot(T(day*1440:day2*1440),'-','Color',[1, 0.1, 0.0])
legend('SST','Water Temp','Air Temp')
subplot(5,1,3)
yyaxis left
plot(rain(day*1440:day2*1440),'-')
ylabel('mm')
hold on
grid on
yyaxis right
plot(w_10m(day*1440:day2*1440),'-')
legend('rain','10 m wind')
ylabel('m/s')
subplot(5,1,4)
yyaxis left
plot(EVAP(day*1440:day2*1440))
hold on
ylabel('mm/h')
yyaxis right
hold on
plot(qair(day*1440:day2*1440))
hold on
plot(qsurf(day*1440:day2*1440))
ylabel('g/kg')
legend('Evaporation','qair','qsurf')
grid on
subplot(5,1,5)
yyaxis left
plot(RH(day*1440:day2*1440))
ylabel('%')
yyaxis right
plot(P_air(day*1440:day2*1440))
legend('Relative Feuchte','Luftdruck')
ylabel('HPa')


%precip colormap

rain_map=[ 3, 233, 231
            1,159,244
            3, 0 , 244
            2,253,2
            1,197,1
            0,142,0
            253,248,2
            229,188,0
            253,149,0
            253,0,0
            212,0,0
            188,0,0
            248, 0,253
            152,84,198
            0,0,0]/255;
%     "#04e9e7",  # 0.01 - 0.10 inches
%     "#019ff4",  # 0.10 - 0.25 inches
%     "#0300f4",  # 0.25 - 0.50 inches
%     "#02fd02",  # 0.50 - 0.75 inches
%     "#01c501",  # 0.75 - 1.00 inches
%     "#008e00",  # 1.00 - 1.50 inches
%     "#fdf802",  # 1.50 - 2.00 inches
%     "#e5bc00",  # 2.00 - 2.50 inches
%     "#fd9500",  # 2.50 - 3.00 inches
%     "#fd0000",  # 3.00 - 4.00 inches
%     "#d40000",  # 4.00 - 5.00 inches
%     "#bc0000",  # 5.00 - 6.00 inches
%     "#f800fd",  # 6.00 - 8.00 inches
%     "#9854c6",  # 8.00 - 10.00 inches
%     "#fdfdfd"   # 10.00+


x = lon;
y = lat;
C = zeros(length(RAIN),1);
for i=1:length(RAIN)
    if RAIN(i)~= 0
        C(i) = RAIN(i);
    else
        C(i) = NaN;
    end
end
figure
plot(coast.long, coast.lat)
hold on
cdivs = 15;
%[~, edges] = hist(C,cdivs-1);
%edges = [-Inf edges Inf]; % to include all points
    edges=linspace(1,log(150),15);
for i=1:length(edges)
    edges(i)=exp(edges(i));
end
[Nk, bink] = histc(C,edges);

cmap = rain_map;
for ii=1:cdivs
    idx = bink==ii;
    plot(x(idx),y(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
end

colormap(cmap)
caxis([min(edges) max(edges)])
%caxis([min(C) max(C)])
hcb=colorbar;
set(hcb,'Ytick',edges)

% load('data_polarstern.mat')