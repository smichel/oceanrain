clear; close all;
dat=textread('test3_0.txt');

win_height = 15;
temp_height = 15;
hum_height  = 15;
bulktemp_depth= 6;
warmlayer = 0;


h_date=dat(:,1);
h_w_10m=dat(:,2);
h_Twater=dat(:,11);
h_T=dat(:,4);
h_q=dat(:,5);
h_P_air=ones(length(h_q),1)*1008;
h_R_s=dat(:,6);
h_R_l=dat(:,7);
h_rain=dat(:,8);
h_lat=zeros(length(h_q),1);
h_lon=zeros(length(h_q),1);
timesteps=length(h_q);
donlon=1;
dat(1,2)
for donlon=1
    for R_val=1:-1:0
        h_R_s=h_R_s*R_val;
        h_R_l=h_R_l*R_val;
        [~, ~, h_sst, h_shf ,h_lhf,h_evap]=SST_cor3_0af(h_date(:),h_w_10m(:),h_Twater(:),h_T(:),h_q(:),h_P_air(:),h_R_s(:),h_R_l(:),h_rain(:),h_lat(:),h_lon(:),win_height,hum_height,temp_height,bulktemp_depth,warmlayer);
        h_cool=h_Twater-h_sst;
        subplot(5,1,1)
        plot(h_cool)
        title('Coolskin effect')
legend('Radiation normal','Radiation off')
        hold on
        subplot(5,1,2)
        plot(h_shf)
        title('SHF')
legend('Radiation normal','Radiation off')
        hold on
        subplot(5,1,3)
        plot(h_lhf)
        title('LHF')
        hold on
legend('Radiation normal','Radiation off')
        subplot(5,1,4)
        hold on
        plot(h_evap)
        title('Evaporation')
legend('Radiation normal','Radiation off')
        hold on
        subplot(5,1,5)
        
        if donlon==1
            plot(h_q)
            hold on
            legend('normal q','half q')
        end
    end
end

figure
for donlon=1
    for w_val=1:2
        h_w_10m_r=h_w_10m/w_val;
        [~,~, h_shf,h_lhf,h_evap]=SST_cor3_0af(h_date(:),h_w_10m(:),h_Twater(:),h_T(:),h_w_10m_r(:),h_P_air(:),h_R_s(:),h_R_l(:),h_rain(:),h_lat(:),h_lon(:),win_height,hum_height,temp_height,bulktemp_depth,warmlayer);
        h_cool=h_Twater-h_sst;
        subplot(5,1,1)
        plot(h_cool)
        title('Coolskin effect')
legend('Donlon off - normal w_10m', 'Donlon off - half w_10m', 'Donlon on - normal w_10m','Donlon on - half w_10m')
        hold on
        subplot(5,1,2)
        plot(h_shf)
        title('SHF')
legend('Donlon off - normal w_10m', 'Donlon off - half w_10m', 'Donlon on - normal w_10m','Donlon on - half w_10m')
        hold on
        subplot(5,1,3)
        plot(h_lhf)
        title('LHF')
        hold on
legend('Donlon off - normal w_10m', 'Donlon off - half w_10m', 'Donlon on - normal w_10m','Donlon on - half w_10m')
        subplot(5,1,4)
        hold on
        plot(h_evap)
        title('Evaporation')
legend('Donlon off - normal w_10m', 'Donlon off - half w_10m', 'Donlon on - normal w_10m','Donlon on - half w_10m')
        hold on
        subplot(5,1,5)
        
        if donlon==1
            plot(h_w_10m_r)
            hold on
            legend('normal w_10m','half w_10m')
        end
    end
end
