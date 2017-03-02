close all;

dataread = exist('data','var');
if dataread == 0
lat_=cell(2,1);
lon_=cell(2,1);
date_=cell(2,1);
year=cell(2,1);
data=cell(2,1);
month=cell(2,1);

set(0,'DefaultAxesFontSize',20,'DefaultTextFontSize',20);

    for ship=1:2
        %  Polarstern data:
        
        if ship == 1
            data{ship}=load('data_polarstern_donlon.mat');
        end
        
        % Meteor data
        
        if ship == 2
            data{ship}=load('data_meteor_donlon.mat');
        end
        lat_{ship} = data{ship}.lat;
        lon_{ship} = data{ship}.lon;
        date_{ship} = data{ship}.date;
        year{ship} = rem(date_{ship},10000);
        month{ship} = floor(rem(date_{ship},1000000)/10000);
        
    end
end
%meteor minuten
m_start_m=find(data{2}.date==23032014,1,'first');
m_end_m=find(data{2}.date==23032014,1,'last');
%polarstern minuten
p_start_m=find(data{1}.date==23032014,1,'first');
p_end_m=find(data{1}.date==23032014,1,'last');

startdate=datenum('2014-03-23 00:00:00');
enddate=datenum('2014-03-23 23:59:00');
xDate=linspace(startdate,enddate,length(m_start_m:m_end_m));


sqrt(mean(data{2}.w_10m(m_start_m+700:m_start_m+1100)-data{1}.w_10m(p_start_m+700:p_start_m+1100)).^2)
m_s=m_start_m+700;%meteor anfang
m_e=m_start_m+1100;%meteor ende
p_s=p_start_m+700;%polarstern anfang
p_e=p_start_m+1100;%polarstern ende
% plot(data{2}.lon(m_start_m:m_end_m),data{2}.lat(m_start_m:m_end_m))
% plot(data{1}.lon(p_start_m:p_end_m),data{1}.lat(p_start_m:p_end_m))

%Temperatur
figure
%subplot(2,1,1)
plot(xDate,data{2}.T(m_start_m:m_end_m),'r')
hold on
plot(xDate,data{1}.T(p_start_m:p_end_m),'b')
legend('FS Meteor','FS Polarstern','location','southeast')
ylabel('Temperatur in °C')
datetick('x',15,'keeplimits')
subplot(2,1,2)
plot(xDate,data{2}.Twater(m_start_m:m_end_m),'r')
hold on
plot(xDate,data{1}.Twater(p_start_m:p_end_m),'b')
legend('Wassertemperatur FS Meteor','Wassertemperatur FS Polarstern')
datetick('x',15,'keeplimits')
ylabel('Temperatur in °C')

%Windgeschwindigkeit
figure
plot(xDate,data{2}.w_10m(m_start_m:m_end_m),'r')
hold on
plot(xDate,data{1}.w_10m(p_start_m:p_end_m),'b')
legend('FS Meteor','FS Polarstern')
datetick('x',15,'keeplimits')
ylabel('Windgeschwindigkeit in m/s')

%Wassertemperatur
figure

legend('FS Meteor','FS Polarstern')
datetick('x',15,'keeplimits')
ylabel('Temperatur in °C')

%Feuchtedifferenz
figure
plot(xDate,data{2}.qair(m_start_m:m_end_m)-data{2}.qsurf(m_start_m:m_end_m))
hold on
plot(xDate,data{1}.qair(p_start_m:p_end_m)-data{1}.qsurf(p_start_m:p_end_m))
legend('FS Meteor','FS Polarstern')
datetick('x',15,'keeplimits')
ylabel('q_{air}-q_{surf} in g/kg')
%Latentener Wärmefluss
figure
plot(xDate,data{2}.LHF(m_start_m:m_end_m))
hold on
plot(xDate,data{1}.LHF(p_start_m:p_end_m))
legend('FS Meteor','FS Polarstern')
datetick('x',15,'keeplimits')
ylabel('Wärmefluss in W/m²')
%Verdunstung
figure
plot(xDate,data{2}.EVAP(m_start_m:m_end_m))
hold on
plot(xDate,data{1}.EVAP(p_start_m:p_end_m))
legend('FS Meteor','FS Polarstern')
datetick('x',15,'keeplimits')
ylabel('Verdunstung in mm/h')

m_qdif=data{2}.qair(m_s:m_e)-data{2}.qsurf(m_s:m_e);
p_qdif=data{1}.qair(p_s:p_e)-data{1}.qsurf(p_s:p_e);

mean(m_qdif-p_qdif)
sqrt(mean((m_qdif-p_qdif).^2))

m_T=data{2}.T(m_s:m_e);
p_T=data{1}.T(p_s:p_e);

mean(m_T-p_T)
sqrt(mean((m_T-p_T).^2))

m_Tw=data{2}.Twater(m_s:m_e);
p_Tw=data{1}.Twater(p_s:p_e);

mean(m_Tw-p_Tw)
sqrt(mean((m_Tw-p_Tw).^2))

m_u=data{2}.w_10m(m_s:m_e);
p_u=data{1}.w_10m(p_s:p_e);

mean(m_u-p_u)
sqrt(mean((m_u-p_u).^2))

m_SHF=data{2}.SHF(m_s:m_e);
p_SHF=data{1}.SHF(p_s:p_e);

mean(m_SHF-p_SHF)
sqrt(mean((m_SHF-p_SHF).^2))

m_LHF=data{2}.LHF(m_s:m_e);
p_LHF=data{1}.LHF(p_s:p_e);

mean(m_LHF-p_LHF)
sqrt(mean((m_LHF-p_LHF).^2))

m_EVAP=data{2}.EVAP(m_s:m_e);
p_EVAP=data{1}.EVAP(p_s:p_e);

mean(m_EVAP-p_EVAP)
sqrt(mean((m_EVAP-p_EVAP).^2))

