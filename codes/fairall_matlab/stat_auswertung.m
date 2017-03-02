clear;close all;
load('data_polarstern.mat');

T_depth=sst_vec-Twater;
plot(w_10m,T_depth,'LineStyle','none','Marker','.','MarkerSize',0.1)
xlabel('u (ms^{-1})')
ylabel('SST-Bulktemp (K)')
idx = isnan(w_10m) | isnan(T_depth) | w_10m<2;
eqn = fittype('a+(b*exp(-x/c))');
fit=fit(w_10m(~idx),T_depth(~idx),eqn,'StartPoint',[-0.15,-0.3,4]);
hold on
plot(fit,w_10m,T_depth,w_10m < 2)
fit
xlabel('u (ms^{-1})')
ylabel('SST-Bulktemp (K)')
