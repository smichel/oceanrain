% fehlmessungen/messungen der abgasfahne


close all;

dataread = exist('data','var');
if dataread == 0
    load('data_merian_donlon');
end
cmap  = hot(64);
cmap  = cmap(1:2:end,:);
startmin=130000;
endmin=140000;
startdate=datenum('01-23-2013');
enddate=datenum('01-30-2013');
xDate=linspace(startdate,enddate,length(startmin:endmin));

x_corner=[-180, 180,180,-180];
y_corner=[90,90,-90,-90];
figure

plot(xDate,T(startmin:endmin))
hold on
grid on
plot(xDate,SST(startmin:endmin))
plot(xDate,Twater(startmin:endmin))

legend('Lufttemperatur','Meeresoberflächentemperatur')
ylabel('Temperatur in ̊ C')
datetick('x',1,'keeplimits')





T_min=min(T(startmin:endmin));
T_max=max(T(startmin:endmin));



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

%     xlabel('Länge in \circ','Interpreter','tex')
%     ylabel('Breite in \circ','Interpreter','tex')
hcb=colorbar;
set(hcb,'Ytick',0:(cdivs+2)/15:cdivs+2,'Yticklabel',T_min:1:T_max-0.2)
hcb.Label.String = 'Temperatur in \circ C';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 12;


figure
plot(xDate,SHF(startmin:endmin),'-','Color',[0, 0, 1])
hold on
grid on
plot(xDate,LHF(startmin:endmin),'-','Color',[0, 0, 0.7])
legend('sensible heat flux','latent heat flux')
ylabel('W/m^2')
datetick('x',1,'keeplimits')