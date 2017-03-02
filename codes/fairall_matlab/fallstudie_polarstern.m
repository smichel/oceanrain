close all;
dataread = exist('data','var');
set(0,'DefaultAxesFontSize',20,'DefaultTextFontSize',20);

if dataread == 0
    load('data_polarstern_donlon');
end
cmap  = jet(64);
cmap  = cmap(1:end-20,:);
startmin=1575500;
endmin=1630000;
x_corner=[-180, 180,180,-180];
y_corner=[90,90,-90,-90];
display(date(startmin))
startdate=datenum('06-27-2013');
enddate=datenum('08-03-2013');
display(date(endmin))
xDate=linspace(startdate,enddate,length(startmin:endmin));
figure

plot(xDate,T(startmin:endmin))
hold on
plot(xDate,SST(startmin:endmin))
legend('T_{air}','SST_{skin}')
ylabel('Temperatur in ̊ C')
datetick('x',20,'keeplimits')
v=get(gca);
lh = line([v.XLim(1) v.XLim(2)],[0 0]);
set(lh,'Color',[.25 .25 .25],'LineStyle','--')

T_min=min(T(startmin:endmin));
T_max=max(T(startmin:endmin));

% alongtrack plot
figure
plot(w_10m(startmin:endmin),T(startmin:endmin),'.')
xlabel('Windgeschwindigkeit in m/s');
ylabel('Lufttemperatur in °C');

figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 
for ship=1:5
    hold on
    plot(lon(startmin:endmin),lat(startmin:endmin),'.','MarkerSize',0.1,'Color',[0 0 0])
end
x = lon(startmin:endmin);
y = lat(startmin:endmin);
C = zeros(length(T(startmin:endmin)),1);

for i=1:length(T(startmin:endmin))
    C(i) = T(startmin+i-1);
end

hold on
cdivs = size(cmap,1);
edges = linspace(T_min,T_max,cdivs+1); % to include all points
[Nk, bink] = histc(C,edges);


for ii=1:cdivs
idx = bink==ii;
plot(x(idx),y(idx),'.','MarkerSize',3,'Color',cmap(ii,:));
end
colormap(cmap)
caxis([0 cdivs])
xlim([-70 10])
ylim([-80 -55])
%     xlabel('Länge in \circ','Interpreter','tex')
%     ylabel('Breite in \circ','Interpreter','tex')
hcb=colorbar;
set(hcb,'Ytick',0:(cdivs+2)/9:cdivs+2,'Yticklabel',-32:4:4)
hcb.Label.String = 'Temperatur in \circ C';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 18;

% Timeseries

figure
hold on
plot(xDate,w_10m(startmin:endmin),'-')
ylabel('Windgeschwindigkeit in 10 m in m/s')
datetick('x',20,'keeplimits')
v=get(gca);
lh = line([v.XLim(1) v.XLim(2)],[0 0]);
set(lh,'Color',[.25 .25 .25],'LineStyle','--')

figure
subplot(2,1,1)
plot(xDate,EVAP(startmin:endmin))
hold on
ylabel('Verdunstung in mm/h')
datetick('x',20,'keeplimits')
subplot(2,1,2)

col={[0,0,1],[0,0,0],[1,0,0]};
rain_=rain(startmin:endmin); %Ausschnitt des Zeitraumes
map=[0,0,1
    0,0,0
    1,0,0];
% for k=1:3
%     plot(xDate(1),'Color',col{k})
% end
hold on
C=data(startmin:endmin,34);
cdivs=3;
edges=0:2;
[Nk,bink]=histc(C,edges);
cmap=map;
for ii=1:cdivs
    idx=bink==ii;
    plot(xDate(idx),rain_(idx),'.','MarkerSize',6,'Color',cmap(ii,:));
    hold on
end
box on
legend('Regen','Schnee','Mischphase');
ylabel('Niederschlag in mm/h')
datetick('x',20,'keeplimits')


for i = startmin:endmin
    if RH(i) < 0
        RH(i)=NaN;
    end
end

figure
hold on
plot(xDate,qair(startmin:endmin),'Linestyle','--','Color','k')
hold on
plot(xDate,qsurf(startmin:endmin),'k')
ylabel('Spezifische Feuchte in g/kg')
yyaxis right
plot(xDate,RH(startmin:endmin))
ylabel('Relative Luftfeuchte in %')
ylim([0 100])
datetick('x',20,'keeplimits')
legend('q_{air}','q_{surf}','RF')
% v=get(gca);
% lh = line([v.XLim(1) v.XLim(2)],[0 0]);
% set(lh,'Color',[.25 .25 .25],'LineStyle','--')

figure
plot(xDate,SHF(startmin:endmin),'r-')
hold on
plot(xDate,LHF(startmin:endmin),'b-')
legend('Sensibler Wärmefluss','Latenter Wärmefluss')
ylabel('Wärmefluss in W/m^2')
datetick('x',20,'keeplimits')
v=get(gca);
lh = line([v.XLim(1) v.XLim(2)],[0 0]);
set(lh,'Color',[.25 .25 .25],'LineStyle','--')

ans=1;


if 1==1
C=w_10m(startmin:endmin);
cmap=parula;
cdivs=length(cmap);
T_dif=T(startmin:endmin)-SST(startmin:endmin);
SHF_=SHF(startmin:endmin);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),SHF_(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/6:64,'Yticklabel',0:4:24)
xlabel('T_{air}-SST_{skin} in K')
ylabel('Sensibler Wärmefluss in W/m^{2}')
hcb.Label.String = 'Windgeschwindigkeit in m/s';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;



C=LHF(startmin:endmin);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),w_10m(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/6:64,'Yticklabel',0:4:24)
xlabel('T_{air}-SST_{skin} in K')
ylabel('Latenter Wärmefluss in W/m^{2}')
hcb.Label.String = 'Windgeschwindigkeit in m/s';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;


C=LHF(startmin:endmin);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),w_10m(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/9:64,'Yticklabel',-10:30:260)
xlabel('T_{air}-SST_{skin} in K')
ylabel('Windgeschwindigkeit in m/s')
hcb.Label.String = 'Latenter Wärmefluss in W/m^{2}';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;





q_dif=qair(startmin:endmin)-qsurf(startmin:endmin);
C=LHF(startmin:endmin);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),q_dif(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/9:64,'Yticklabel',-10:30:260)
xlabel('T_{air}-SST_{skin} in K')
ylabel('q_{air}-q_{surf} in g/kg')
hcb.Label.String = 'Latenter Wärmefluss in W/m^{2}';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;




% EVAP_=EVAP(startmin:endmin);
% [~, edges] = hist(C,cdivs-1);
% edges=[-Inf edges Inf];
% [Nk, bink] = histc(C,edges);
% figure
% for ii=1:cdivs
% idx = bink==ii;
% plot(T_dif(idx),EVAP_(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
% hold on
% end
% caxis([0 cdivs])
% hcb=colorbar;
% set(hcb,'Ytick',0:64/5:64,'Yticklabel',0:2:10)
% xlabel('T_{air}-SST_{skin} in K')
% ylabel('Verdunstung in mm/h')
% hcb.Label.String = 'Spezifische Feuchte in g/kg';
% hcb.Label.Interpreter = 'tex';
% hcb.FontSize = 20;




% C=w_10m(startmin:endmin);
% EVAP_=EVAP(startmin:endmin);
% [~, edges] = hist(C,cdivs-1);
% edges=[-Inf edges Inf];
% [Nk, bink] = histc(C,edges);
% figure
% for ii=1:cdivs
% idx = bink==ii;
% plot(T_dif(idx),EVAP_(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
% hold on
% end
% caxis([0 cdivs])
% hcb=colorbar;
% set(hcb,'Ytick',0:64/6:64,'Yticklabel',0:4:24)
% xlabel('T_{air}-SST_{skin} in K')
% ylabel('Verdunstung in mm/h')
% hcb.Label.String = 'Windgeschwindigkeit in m/s';
% hcb.Label.Interpreter = 'tex';
% hcb.FontSize = 20;



w_10m_=w_10m(startmin:endmin);
C=SHF(startmin:endmin);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),w_10m_(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/8:64,'Yticklabel',-100:100:700)
xlabel('T_{air}-SST_{skin} in K')
ylabel('Windgeschwindigkeit in m/s')
hcb.Label.String = 'Sensibler Wärmefluss in W/m^{2}';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;

C=EVAP(startmin:endmin);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),q_dif(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/6:64,'Yticklabel',0:0.05:0.3)
xlabel('T_{air}-SST_{skin} in K')
ylabel('q_{air}-q_{surf} in g/kg')
hcb.Label.String = 'Verdunstung in mm/h';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;

% C=EVAP(startmin:endmin);
% [~, edges] = hist(C,cdivs-1);
% edges=[-Inf edges Inf];
% [Nk, bink] = histc(C,edges);
% figure
% for ii=1:cdivs
% idx = bink==ii;
% plot(LHF_(idx),SHF_(idx),'.','MarkerSize',8,'Color',cmap(ii,:));
% hold on
% end
% caxis([0 cdivs])
% hcb=colorbar;
% set(hcb,'Ytick',0:64/6:64,'Yticklabel',0:0.05:0.3)
% xlabel('Latenter Wärmefluss in W/m^2')
% ylabel('Sensibler Wärmefluss in W/m^2')
% hcb.Label.String = 'Verdunstung in mm/h';
% hcb.Label.Interpreter = 'tex';
% hcb.FontSize = 20;
end