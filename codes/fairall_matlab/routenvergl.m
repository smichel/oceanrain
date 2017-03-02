clear;close all;
tic
lat_=cell(5,1);
lon_=cell(5,1);
date_=cell(5,1);
year=cell(5,1);
data=cell(5,1);
month=cell(5,1);
doplots = 1;
set(0,'DefaultAxesFontSize',12,'DefaultTextFontSize',12);
for ship=1:5
    % Meteor data
    
    if ship == 2
        data{ship}=load('data_meteor_donlon.mat');
    end
    
    % Investigator data:
    
    if ship == 5
        data{ship}=load('data_investigator_donlon.mat');
    end
    
    %  Polarstern data:
    
    if ship == 1
        data{ship}=load('data_polarstern_donlon.mat');
    end
    
    %  Sonne2 data:
    
    if ship == 4
        data{ship}=load('data_sonne_donlon.mat');
    end
    
%       Merian data:

    if ship == 3
        data{ship}=load('data_merian_donlon.mat');
    end
    
        lat_{ship} = data{ship}.lat;
        lon_{ship} = data{ship}.lon;
        date_{ship} = data{ship}.date;
        year{ship} = rem(date_{ship},10000);
        month{ship} = floor(rem(date_{ship},1000000)/10000);
        
end
% values=cell(5,1);
% for ship=1:5
%     values{ship}=~isnan(data{ship}.T) & ~isnan(data{ship}.Twater) & ~isnan(data{ship}.RH) & ~isnan(data{ship}.P_air) & ~isnan(data{ship}.u) & ~isnan(data{ship}.R_g) & ~isnan(data{ship}.rain);
% end
col={[0 0 1],[1 0.5 0],[0.8 0.15 0.8],[1 0 0],[0.1 0.8 0.1]};
name={'FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator'};
lat_{5}=lat_{5}(1:25920);
lon_{5}=lon_{5}(1:25920);
month{5}=month{5}(1:25920);
% dofits=1;
% if dofits==1
% T_depth=cell(5,1);
% for ship=1:5
% figure
% T_depth{ship}=data{ship}.sst_vec-data{ship}.Twater;
% plot(data{ship}.w_10m,T_depth{ship},'LineStyle','none','Marker','.','MarkerSize',0.3)
% xlabel('u (ms^{-1})')
% ylabel('SST-Bulktemp (K)')
% hold on
% idx{ship} = isnan(data{ship}.w_10m) | isnan(T_depth{ship}) | data{ship}.w_10m<2;
% eqn = fittype('a+(b*exp(-x/c))');
% Tfit{ship}=fit(data{ship}.w_10m(~idx{ship}),T_depth{ship}(~idx{ship}),eqn,'StartPoint',[-0.15,-0.3,4]);
% hold on
% plot(Tfit{ship},data{ship}.w_10m,T_depth{ship},data{ship}.w_10m < 2)
% text(15,-1,strcat(num2str(Tfit{1}.a),num2str(Tfit{1}.b),'*exp(-u / ',num2str(Tfit{1}.c),'))'))
% title(name{ship})
% xlabel('u (ms^{-1})')
% ylabel('SST-Bulktemp (K)')
% end
% end
coast=load ('coast');
x_corner=[-180, 180,180,-180];
y_corner=[90,90,-90,-90];
figure
for ship=1:5
    plot(ship,'color',col{ship},'LineWidth',4)
    hold on
end
patch(x_corner,y_corner,[0.9 0.9 0.9]);
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 

for ship=1:5
    plot(lon_{ship},lat_{ship},'.','MarkerSize',2,'Color',col{ship});
    hold on
end
legend('FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator','Location','Southoutside','Orientation','Horizontal')




figure

col2={'b','g','r','k'};

title('Shiptrack')
for ship=1:4
    plot(ship,col2{ship},'LineWidth',4)
    hold on
end
patch(x_corner,y_corner,[0.9 0.9 0.9]);
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 

map=[0, 0, 1
     0, 0, 1
     0, 1, 0
     0, 1, 0
     0, 1, 0
     1, 0, 0
     1, 0, 0
     1, 0, 0
     0, 0, 0
     0, 0, 0
     0, 0, 0
     0, 0, 1];
 for ship=1:5
     C=month{ship};
     cdivs = 12;
     [~, edges] = hist(C,cdivs-1);
     edges = (1:12);%[-Inf edges Inf]; % to include all points
     [Nk, bink] = histc(C,edges);
     hold on
     cmap = map;
     for ii=1:cdivs
         idx = bink==ii;
         plot(lon_{ship}(idx),lat_{ship}(idx),'.','MarkerSize',2,'Color',cmap(ii,:));
     end
end

legend('DJF','MAM','JJA','SON','Location','Southoutside','Orientation','Horizontal')

% col={[0 0 1],[255 162 0]/255,[0 0 0],[1 0 0],[1 0 1]};
% name={'FS Meteor','FS Investigator','FS Polarstern','FS Sonne2','FS Merian'};


% %print('OceanRAIN_shiptracks','-depsc','-tiff')
% Twater(1,:)=data{3}.Twater(find(data{3}.date==23032014));
% Twater(2,:)=data{1}.Twater(find(data{1}.date==23032014));
% 
% 
% lat(1,:)=data{3}.lat(find(data{3}.date==23032014));
% lat(2,:)=data{1}.lat(find(data{1}.date==23032014));
% lon(1,:)=data{3}.lon(find(data{3}.date==23032014));
% lon(2,:)=data{1}.lon(find(data{1}.date==23032014));
% 
% 
% sst_vec(1,:)=data{3}.sst_vec(find(data{3}.date==23032014));
% sst_vec(2,:)=data{1}.sst_vec(find(data{1}.date==23032014));
% 
% balance=zeros(length(data{3}.evap),1);
% balance(1)=data{3}.rain(1)-data{3}.evap(1);
% 
% if isnan(balance(1)) balance(1)=0; end
%        
% for i=2:length(data{3}.evap)
%     m_balance=data{3}.rain(i)-data{3}.evap(i);
%     if isnan(m_balance)
%         m_balance=0;
%     end
%     balance(i)=balance(i-1)+m_balance;
% end
% figure
% plot(balance)
% xlabel('Minuten')
% ylabel('Süsswasserfluss in mm')
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

        cmap  = jet(64);
        cmap  = cmap(15:2:end,:);
        
%% Precipplots
% cmap=rain_map;
if doplots ==1
tic
tic
data{5}.RAIN=data{5}.RAIN(1:25920);

for o=2
figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]);
%     for ship=1:5
%         hold on
%         plot(lon_{ship},lat_{ship},'.','MarkerSize',0.01,'Color',[0.5 0.5 0.5])
%     end
for ship=1:5
    
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(data{ship}.RAIN),1);
    if o==1
    for i=1:length(data{ship}.RAIN)
    
        if data{ship}.RAIN(i)~= 0 && data{ship}.RAIN(i) < 30
            C(i) = data{ship}.RAIN(i);
        else
            C(i) = NaN;
        end
    end
    elseif max(data{ship}.RAIN) >30
    for i=1:length(data{ship}.RAIN)
    
        if data{ship}.RAIN(i) > 30
            C(i) = data{ship}.RAIN(i);
        else
            C(i) = NaN;
        end
    end
    
    end
    hold on
    cdivs = size(cmap,1);
%     [~, edges] = hist(C,cdivs-1);
%     edges = [0 edges 400]; % to include all points
    if o ==1
        edges=linspace(log(0.01),log(30),cdivs+1);
    else
        edges=linspace(log(30),log(300),cdivs+1);
    end
        
    for i=1:length(edges)
        edges(i)=exp(edges(i));
    end
    
    [Nk, bink] = histc(C,edges);
       

    for ii=1:cdivs
        idx = bink==ii;
        plot(x(idx),y(idx),'.','MarkerSize',14,'Color',cmap(ii,:));
    end
    colormap(cmap)
    caxis([0 cdivs]) 
%     xlabel('Länge in \circ','Interpreter','tex')
%     ylabel('Breite in \circ','Interpreter','tex')
    hcb=colorbar;
    if o ==1 
        set(hcb,'Ytick',[0,5, 10, 15, 20, 25],'Yticklabel',[0.01, 0.05, 0.25, 1.2, 6,30])
    else 
        set(hcb,'Ytick',0:5:25,'Yticklabel',[30, 50, 75, 120,190,300])
    end
    hcb.Label.String = 'Niederschlag in mm/h';
    hcb.FontSize = 12;
end

end
toc
%% Temperatur plots
T_min=min(data{1}.T);
Tw_min=min(data{1}.Twater);
T_max=38;
Tw_max=32;
for o=1:2
    figure
    patch(x_corner,y_corner,[0.9 0.9 0.9]);
    hold on
    geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 
    for ship=1:5
        hold on
        plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
    end
    
    if o == 1
        cmap  = jet(64);
        cmap  = cmap(6:2:end,:);
    else
        cmap  = jet(64);
        cmap  = cmap(15:2:end,:);
    end
    
    for ship=1:5
        
        x = lon_{ship};
        y = lat_{ship};
        C = zeros(length(data{ship}.T),1);
        if o==1
            for i=1:length(data{ship}.T)
                C(i) = data{ship}.T(i);
            end
        else
            for i=1:length(data{ship}.Twater)
                
                
                C(i) = data{ship}.Twater(i);
                
            end
            
        end
        hold on
        cdivs = size(cmap,1);
        if o == 1
            edges = linspace(T_min,T_max,cdivs+1); % to include all points
        else
            edges = linspace(Tw_min,Tw_max,cdivs+1); % to include all points
        end
        
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
        if o == 1
            set(hcb,'Ytick',0:3.375:27,'Yticklabel',-32:8:32)
        else
            set(hcb,'Ytick',0:1.8116:1.8116*15,'Yticklabel',-2.5:2.5:2.5*15)
        end
        hcb.Label.String = 'Temperatur in \circ C';
        hcb.Label.Interpreter = 'tex';
        hcb.FontSize = 12;
    end
    
end
















%% Windplot

figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 

for ship=1:5
    hold on
    plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
end

for ship=1:5
    
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(data{ship}.w_10m),1);

    for i=1:length(data{ship}.w_10m)
        if data{ship}.w_10m(i) < 30
            C(i) = data{ship}.w_10m(i);
        else
            C(i) = NaN;
        end
    end
    hold on
    cdivs = size(cmap,1);
    if ship ==1
        %[~, edges] = hist(C,cdivs-1);
        edges = linspace(0,30,cdivs+1); % to include all points
    end
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
    set(hcb,'Ytick',0:5:length(cmap),'Yticklabel',0:5:length(cmap))
    hcb.Label.String = 'Windgeschwindigkeit in m/s';
    hcb.Label.Interpreter = 'tex';
    hcb.FontSize = 12;
end


%% Spezifische Feuchte
figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 

for ship=1:5
    hold on
    plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
end

for ship=1:5
    
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(data{ship}.qair),1);

    for i=1:length(data{ship}.qair)
        C(i) = data{ship}.qair(i);
    end
    hold on
    cdivs = size(cmap,1);
    if ship == 1
%         [~, edges] = hist(C,cdivs-1);
%         edges = [0 edges 30]; % to include all points
        edges=linspace(0,27,cdivs);
    end

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
    set(hcb,'Ytick',0:25/9:25,'Yticklabel',0:3:27)
    hcb.Label.String = 'Spezifische Feuchte in g/kg';
    hcb.Label.Interpreter = 'tex';
    hcb.FontSize = 12;
end
%% SST plot
SST_min= min(data{1}.sst_vec(:));
SST_max= max(data{4}.sst_vec(:));
figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 
for ship=1:5
    hold on
    plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
end

for ship=1:5
    
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(data{ship}.sst_vec),1);
    for i=1:length(data{ship}.sst_vec)
       C(i) = data{ship}.sst_vec(i);
    end
        
    hold on
    cdivs = size(cmap,1);
    if ship == 1
        [~, edges] = hist(C,cdivs-1);
        edges = [SST_min edges SST_max]; % to include all points
    end
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
    set(hcb,'Ytick',0:3:27,'Yticklabel',-4:4:32)
    hcb.Label.String = 'Temperatur in {\circ}C';
    hcb.Label.Interpreter = 'tex';
    hcb.FontSize = 12;
end
%% Wärmeflüsse plots

data{5}=data{5}.LHF(1:25920);
data{5}=data{5}.SHF(1:25920);
cmap  = jet(64);
cmap  = cmap(10:2:end,:);

for o=1:2
figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 
for ship=1:5
    hold on
    plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
end

for ship=1:5
    
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(data{ship}.LHF),1);
    if o==1
        for i=1:length(data{ship}.LHF)
            C(i) = data{ship}.LHF(i);
        end
    else
        for i=1:length(data{ship}.SHF)
            if  data{ship}.SHF(i) > -100 && data{ship}.SHF(i) < 300
                C(i) = data{ship}.SHF(i);
            else
                C(i) =NaN;
            end
            
        end
    end
    hold on
    cdivs = size(cmap,1);
    
%     if ship == 1 && o == 2
%         [~, edges] = hist(C,cdivs-1);
%     end
    
    if o == 1
        edges = linspace(sqrt(-20),sqrt(max(data{2}.LHF(:))),cdivs+1); % to include all points
    else
        edges = linspace(sqrt(-100),sqrt(300),cdivs+1); % to include all points
    end
    for i=1:length(edges)
        edges(i)=edges(i)^2;
        edges(i)=real(edges(i));
    end
    if o== 2
        edges=linspace(-100,300,cdivs+1);
    end
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
    if o == 1 
        hcb.Label.String = 'Latenter Wärmefluss in W/m^{2}';
        set(hcb,'Ytick',0:4:32,'Yticklabel',[-20,0,45,120,220,360,520,700])
    else
        hcb.Label.String = 'Sensibler Wärmefluss in W/m^{2}';
        set(hcb,'Ytick',0:3.5:28,'Yticklabel',-100:50:300)
    end
    hcb.Label.Interpreter = 'tex';
    hcb.FontSize = 12;
end

end

%% Evaporation plots


Evap_max=max(data{2}.EVAP(:));
figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 
for ship=1:5
    hold on
    plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
end

for ship=1:5
    
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(data{ship}.EVAP),1);
    for i=1:length(data{ship}.EVAP)
       C(i) = data{ship}.EVAP(i);
    end
        
    hold on
    cdivs = size(cmap,1);
    edges=linspace(0,Evap_max,cdivs+1);
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
    set(hcb,'Ytick',0:2.7451:27.451,'Yticklabel',0:0.1:1)
    hcb.Label.String = 'Evaporation in mm/h';
    hcb.Label.Interpreter = 'tex';
    hcb.FontSize = 12;
end
end
%% E-P
% 
% 
% 
% col2=[0 0 0.5625
%     0 0 0.75
%     0 0 1
%     0 0.25 1
%     0 0.5 1 
%     0 0.75 1
%     0 1 1
%     0.5 1 1
%     0.75 1 1
%     1 1 1
%     1 1 0.75
%     1 1 0.5
%     1 1 0
%     1 0.75 0
%     1 0.5 0
%     1 0.25 0
%     1 0 0
%     0.75 0 0
%     0.5 0 0];
cmap  = flipud(hot(64));
cmap  = cmap(1:2:end-10,:);
cmap(1,:)= [46, 203, 255]/255;
for i=2:8
    cmap(i,3)=cmap(i,3);
end

E_P=cell(5,1);
figure
patch(x_corner,y_corner,[0.9 0.9 0.9]);
hold on
geoshow('landareas.shp','FaceColor',[0.8 0.8 0.8]); 
for ship=1:5
    hold on
    plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
    E_P{ship}=data{ship}.EVAP-data{ship}.RAIN;
end

for ship=1:5
    x = lon_{ship};
    y = lat_{ship};
    C = zeros(length(E_P{ship}),1);
    for i=1:length(E_P{ship})
        if E_P{ship}(i) > 0
            C(i) = E_P{ship}(i);
        elseif E_P{ship}(i) < 0
            C(i) = -.05;
        else
            C(i) = NaN;
        end
    end
        
    hold on
    cdivs = size(cmap,1);
    edges=linspace(-0.05,Evap_max,cdivs+1);
    edges(1)=-0.05;
    edges(2)=0;
    
    [Nk, bink] = histc(C,edges);
     
    
        
        
    for ii=1:cdivs
        idx = bink==ii;
        plot(x(idx),y(idx),'.','MarkerSize',3,'Color',cmap(ii,:));
    end
    for ii=1
        idx=bink==ii;
        plot(x(idx),y(idx),'.','MarkerSize',3,'Color',cmap(ii,:));
    end
    colormap(cmap)
    caxis([0 cdivs]) 
%     xlabel('Länge in \circ','Interpreter','tex')
%     ylabel('Breite in \circ','Interpreter','tex')
    hcb=colorbar;
    set(hcb,'Ytick',[0 ,1 ,6.5,11.5,16.5,21.5,26.5],'Yticklabel',{'< 0', 0, 0.2, 0.4, 0.6,0.8,1})
    hcb.Label.String = 'Süßwasserfluss in mm/h';
    hcb.Label.Interpreter = 'tex';
    hcb.FontSize = 12;
end

% 
%  for ship=1:5
% hold on
% plot(lon_{ship},lat_{ship},'.','MarkerSize',0.1,'Color',[0 0 0])
% end
% for ship=1:5
% x = lon_{ship};
% y = lat_{ship};
% C = zeros(length(data{ship}.qair),1);
% for i=1:length(data{ship}.R_g)
% if data{ship}.R_g(i)>0 & data{ship}.R_g(i)<2000
% C(i) = data{ship}.R_g(i);
% end
% end
% hold on
% cdivs = size(cmap,1);
% if ship == 1
% [~, edges] = hist(C,cdivs-1);
% edges = [-5 edges 2000]; % to include all points
% end
% [Nk, bink] = histc(C,edges);
% for ii=1:cdivs
% idx = bink==ii;
% plot(x(idx),y(idx),'.','MarkerSize',3,'Color',cmap(ii,:));
% end
% colormap(cmap)
% caxis([0 cdivs])
% %     xlabel('Länge in \circ','Interpreter','tex')
% %     ylabel('Breite in \circ','Interpreter','tex')
% hcb=colorbar;
% set(hcb,'Ytick',0:1:25,'Yticklabel',edges)
% hcb.Label.String = 'Globalstrahlung in W/m^2';
% hcb.Label.Interpreter = 'tex';
% hcb.FontSize = 12;
% end
% 
% 
% 
% 
% 
% 



toc






% 
% % 
% h = get(0,'children');
% for i=1:length(h)
%   saveas(h(i), ['figure' num2str(i)], 'epsc');
% end