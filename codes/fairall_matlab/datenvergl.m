clear;
close all;
set(0,'DefaultAxesFontSize',20,'DefaultTextFontSize',20);
dataread = exist('data','var');
if dataread == 0
    
lat_=cell(5,1);
lon_=cell(5,1);
date_=cell(5,1);
year=cell(5,1);
data=cell(5,1);
month=cell(5,1);



    for ship=1:5
        %  Polarstern data:
        
        if ship == 1
            data{ship}=load('data_polarstern_donlon.mat');
        end
        
        % Meteor data
        
        if ship == 2
            data{ship}=load('data_meteor_donlon.mat');
        end
        %       Merian data:
        
        if ship == 3
            data{ship}=load('data_merian_donlon.mat');
        end
        
        %  Sonne data:
        
        if ship == 4
            data{ship}=load('data_sonne_donlon.mat');
        end
        
        % Investigator data:
        
        if ship == 5
            data{ship}=load('data_investigator_donlon.mat');
        end
        
        lat_{ship} = data{ship}.lat;
        lon_{ship} = data{ship}.lon;
        date_{ship} = data{ship}.date;
        year{ship} = rem(date_{ship},10000);
        month{ship} = floor(rem(date_{ship},1000000)/10000);
    end
end
col={[0 0 1],[1 0.5 0],[0.8 0.15 0.8],[0 0 0],[0.1 0.8 0.1]};


startmin=1005001;
endmin=1005801;
starttime=datenum('05/07/2012 21:00','mm/dd/yyyy HH:MM');
endtime=datenum('05/08/2012 10:20','mm/dd/yyyy HH:MM');
xDate=linspace(starttime,endtime,length(startmin:endmin));

subplot(2,1,1)
plot(xDate,data{1}.w_10m(startmin:endmin))
datetick('x',15,'keeplimits')
ylabel('Windgeschwindigkeit in m/s')
subplot(2,1,2)
plot(xDate,data{1}.SST(startmin:endmin)-data{1}.Twater(startmin:endmin),'r')
datetick('x',15,'keeplimits')
ylabel('SST_{skin}-T_{bulk} in K')



% figure
% for ship=1:5
%     plot(0,'color',col{ship},'LineWidth',4)
%     hold on
% end
% for ship=1:5
%     plot(data{ship}.w_10m,data{ship}.EVAP,'.','MarkerSize',6,'color',col{ship})
%     hold on
% end
% legend('FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator');
% xlabel('Windgeschwindigkeit in 10 m in m/s')
% ylabel('Evaporation in mm/h')
% 
% figure
% for ship=1:5
%     plot3(0,0,0,'color',col{ship},'LineWidth',4)
%     hold on
% end
% for ship=1:5
%     plot3(data{ship}.SST,data{ship}.w_10m,data{ship}.EVAP,'.','MarkerSize',0.5,'color',col{ship})
%     hold on
% end
% legend('FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator');
% xlabel('SST in °C')
% ylabel('Windgeschwindigkeit in 10 m in m/s');
% zlabel('Evaporation in mm/h')
% 
% figure
% for ship=1:5
%     plot(0,'color',col{ship},'LineWidth',4)
%     hold on
% end
% for ship=1:5
%     plot(data{ship}.SST,data{ship}.EVAP,'.','MarkerSize',2,'color',col{ship})
%     hold on
% end
% legend('FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator');
% xlabel('SST - Lufttemperatur in °C')
% ylabel('Evaporation in mm/h')
% 
% figure
% for ship=1:5
%     plot(0,'color',col{ship},'LineWidth',4)
%     hold on
% end
% for ship=1:5
%     plot(data{ship}.SST-data{ship}.T,data{ship}.EVAP,'.','MarkerSize',2,'color',col{ship})
%     hold on
% end
% legend('FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator');
% xlabel('SST - Lufttemperatur in °C')
% ylabel('Evaporation in mm/h')
% 
% figure
% for ship=1:5
%     plot(0,'color',col{ship},'LineWidth',4)
%     hold on
% end
% for ship=1:5
%     plot(data{ship}.qsurf-data{ship}.qair_corr,data{ship}.EVAP,'.','MarkerSize',1,'color',col{ship})
%     hold on
% end
% legend('FS Polarstern','FS Meteor','FS Merian','FS Sonne','FS Investigator');
% xlabel('q_{surf}-q_{air} in g/kg')
% ylabel('Evaporation in mm/h')

% % 
% % h = get(0,'children');
% % for i=1:length(h)
% %   saveas(h(i), ['figure' num2str(i)], 'png');
% % end















max_=0;
min_=1000;
j=1;o=1;
length_=length(lat_{1})+length(lat_{2})+length(lat_{3})+length(lat_{4})+length(lat_{5});
trop=   nan(length_,12);
subtrop=nan(length_,12);
temp=   nan(length_,12);
polar=  nan(length_,12);
comp= nan(length_,9);
j=1;
for ship=1:5
    tic
    for i=1:length(lat_{ship})
        comp(j,1)=data{ship}.SST(i);
        comp(j,2)=data{ship}.T(i);
        comp(j,3)=data{ship}.SHF(i);
        comp(j,4)=data{ship}.LHF(i);
        comp(j,5)=data{ship}.EVAP(i);
        if data{ship}.qair_corr(i)< 30
            comp(j,6)=data{ship}.qair_corr(i)-data{ship}.qsurf(i);
        end
        comp(j,7)=data{ship}.w_10m(i);
        comp(j,8)=data{ship}.RAIN(i);
        comp(j,9)=data{ship}.data(i,34);
        comp(j,10)=data{ship}.Twater(i);
        j=j+1;
    end
    toc
end
% % % 
cmap=parula;
cdivs=length(cmap);
% % 
C=nan(length_,1);
T_dif=nan(length_,1);
% 
for i=1:length_
    if comp(i,2)-comp(i,1) < 30
        C(i)=comp(i,3);
        T_dif(i)=comp(i,2)-comp(i,1);
    end
end
% [~, edges] = hist(C,cdivs-1);
% edges=[-Inf edges Inf];
% [Nk, bink] = histc(C,edges);
% figure
% for ii=1:cdivs
% idx = bink==ii;
% plot(T_dif(idx),comp(idx,7),'.','MarkerSize',8,'Color',cmap(ii,:));
% hold on
% end
% caxis([0 cdivs])
% hcb=colorbar;
% set(hcb,'Ytick',0:64/8:64,'Yticklabel',-100:100:700)
% xlabel('T_{air}-SST_{skin} in K')
% ylabel('Windgeschwindigkeit in m/s')
% hcb.Label.String = 'Sensibler Wärmefluss in W/m^{2}';
% hcb.Label.Interpreter = 'tex';
% hcb.FontSize = 20;
% % % 
% % % 
C=comp(:,5);%Evaporation
T_dif=comp(:,2)-comp(:,1);
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(T_dif(idx),comp(idx,6),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',0:64/10:64,'Yticklabel',0:0.1:1)
xlabel('T_{air}-SST_{skin} in K')
ylabel('q_{air}-q_{surf} in g/kg')
hcb.Label.String = 'Verdunstung in mm/h';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;
% % % 
% % 
C=nan(length_,1);
for i=1:length_
    if comp(i,4) > -50
        C(i)=comp(i,4);
    end
end
[~, edges] = hist(C,cdivs-1);
edges=[-Inf edges Inf];
[Nk, bink] = histc(C,edges);
figure
for ii=1:cdivs
idx = bink==ii;
plot(comp(idx,6),comp(idx,7),'.','MarkerSize',8,'Color',cmap(ii,:));
hold on
end
caxis([0 cdivs])
hcb=colorbar;
set(hcb,'Ytick',2:62/7:64,'Yticklabel',0:100:700)
xlabel('q_{air}-q_{surf} in g/kg')
ylabel('Windgeschwindigkeit in m/s')
hcb.Label.String = 'Latenter Wärmefluss in W/m^{2}';
hcb.Label.Interpreter = 'tex';
hcb.FontSize = 20;
% % % 
% % C=comp(:,5);%Evaporation
% % [~, edges] = hist(C,cdivs-1);
% % edges=[-Inf edges Inf];
% % [Nk, bink] = histc(C,edges);
% % figure
% % for ii=1:cdivs
% % idx = bink==ii;
% % plot(T_dif(idx),comp(idx,7),'.','MarkerSize',8,'Color',cmap(ii,:));
% % hold on
% % end
% % caxis([0 cdivs])
% % hcb=colorbar;
% % set(hcb,'Ytick',0:64/10:64,'Yticklabel',0:0.1:1)
% % xlabel('T_{air}-SST_{skin} in K')
% % ylabel('Windgeschwindigkeit in m/s')
% % hcb.Label.String = 'Verdunstung in mm/h';
% % hcb.Label.Interpreter = 'tex';
% % hcb.FontSize = 20;


j=1;
for ship=1:5
    tic
    for i=1:length(lat_{ship})-1
        if data{ship}.lat(i) < 23.5 && data{ship}.lat(i) > -23.5
            
            trop(j,1)=data{ship}.Twater(i);
            trop(j,2)=data{ship}.lat(i);
            trop(j,3)=data{ship}.lon(i);
            trop(j,4)=data{ship}.SST(i);
            trop(j,5)=i;
            
            if data{ship}.T(i+1)-data{ship}.T(i) < 0.5 && ~isnan(data{ship}.T(i))
                trop(j,6)=data{ship}.T(i);
            end
            
            trop(j,7)=data{ship}.RAIN(i);
            trop(j,8)=data{ship}.EVAP(i);
            trop(j,9)=data{ship}.SHF(i);
            trop(j,10)=data{ship}.LHF(i);
            trop(j,11)=data{ship}.w_10m(i);
            trop(j,12)=data{ship}.data(i,34);
        elseif (data{ship}.lat(i) > 23.5 && data{ship}.lat(i) < 40) || (data{ship}.lat(i) < -23.5 && data{ship}.lat(i) > -40)
            
            subtrop(j,1)=data{ship}.Twater(i);
            subtrop(j,2)=data{ship}.lat(i);
            subtrop(j,3)=data{ship}.lon(i);
            subtrop(j,4)=data{ship}.SST(i);
            subtrop(j,5)=i;
            if data{ship}.T(i+1)-data{ship}.T(i) < 0.5 && ~isnan(data{ship}.T(i))
                subtrop(j,6)=data{ship}.T(i);
            end
            
            subtrop(j,7)=data{ship}.RAIN(i);
            subtrop(j,8)=data{ship}.EVAP(i);
            subtrop(j,9)=data{ship}.SHF(i);
            subtrop(j,10)=data{ship}.LHF(i);
            subtrop(j,11)=data{ship}.w_10m(i);
            subtrop(j,12)=data{ship}.data(i,34);
        elseif (data{ship}.lat(i) > 40 && data{ship}.lat(i) < 66.5) || (data{ship}.lat(i) < -40 && data{ship}.lat(i) > -66.5)
            
            temp(j,1)=data{ship}.Twater(i);
            temp(j,2)=data{ship}.lat(i);
            temp(j,3)=data{ship}.lon(i);
            temp(j,4)=data{ship}.SST(i);
            temp(j,5)=i;
            if data{ship}.T(i+1)-data{ship}.T(i) < 0.5 && ~isnan(data{ship}.T(i))
                temp(j,6)=data{ship}.T(i);
            end
            temp(j,7)=data{ship}.RAIN(i);
            temp(j,8)=data{ship}.EVAP(i);
            temp(j,9)=data{ship}.SHF(i);
            temp(j,10)=data{ship}.LHF(i);
            temp(j,11)=data{ship}.w_10m(i);
            temp(j,12)=data{ship}.data(i,34);
        elseif data{ship}.lat(i) > 66.5 || data{ship}.lat(i) < -66.5
            
            polar(j,1)=data{ship}.Twater(i);
            polar(j,2)=data{ship}.lat(i);
            polar(j,3)=data{ship}.lon(i);
            polar(j,4)=data{ship}.SST(i);
            polar(j,5)=i;
            if data{ship}.T(i+1)-data{ship}.T(i) < 0.5 && ~isnan(data{ship}.T(i))
                polar(j,6)=data{ship}.T(i);
            end
            polar(j,7)=data{ship}.RAIN(i);
            polar(j,8)=data{ship}.EVAP(i);
            polar(j,9)=data{ship}.SHF(i);
            polar(j,10)=data{ship}.LHF(i);
            polar(j,11)=data{ship}.w_10m(i);
            polar(j,12)=data{ship}.data(i,34);
        end
        %end
        j=j+1;

    end
    toc
end
j=1;
temp(:,12)=NaN;
trop(:,12)=NaN;
subtrop(:,12)=NaN;
polar(:,12)=NaN;
for ship=1:5
    tic
    for i=1:length(lat_{ship})-1
        if ~isnan(polar(j,8))
            polar(j,12)=data{ship}.RAIN(i);
        end
        
        if ~isnan(temp(j,8))
            temp(j,12)=data{ship}.RAIN(i);
        end
        if ~isnan(trop(j,8))
            trop(j,12)=data{ship}.RAIN(i);
        end
        if ~isnan(subtrop(j,8))
            subtrop(j,12)=data{ship}.RAIN(i);
        end
        j=j+1;
    end
    toc
end
% w_2=nan(length_,1);
% w_6=nan(length_,1);
% lat_2=nan(length_,1);
% lon_2=nan(length_,1);
% lat_6=nan(length_,1);
% lon_6=nan(length_,1);
% for ship=1:5
%     for i=1:length(lat_{ship})
%         if data{ship}.w_10m(i) < 2
%             w_2(j)=data{ship}.w_10m(i);
%             lat_2(j)=data{ship}.lat(i);
%             lon_2(j)=data{ship}.lon(i);
%         elseif data{ship}.w_10m(i) < 6
%             w_6(j)=data{ship}.w_10m(i);
%             lat_6(j)=data{ship}.lat(i);
%             lon_6(j)=data{ship}.lon(i);
%         end
%         
%         
%         j=j+1;
%     end
% end

% max_lat=data{ship_max}.lat(pos_max);
% max_lon=data{ship_max}.lon(pos_max);
% min_lat=data{ship_min}.lat(pos_min);
% min_lon=data{ship_min}.lon(pos_min);
% max_T=max_; min_T=min_; max_T_ship=ship_max; min_T_ship=ship_min;