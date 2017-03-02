clear; close all;

N = 100000;
x = rand(N,1);
y = rand(N,1);
C = sin(2*x)+y;

cdivs = 100;
[~, edges] = hist(C,cdivs-1);
edges = [-Inf edges Inf]; % to include all points
[Nk, bink] = histc(C,edges);

figure;
hold on;
cmap = jet(cdivs);
for ii=1:cdivs
    idx = bink==ii;
    plot(x(idx),y(idx),'.','MarkerSize',4,'Color',cmap(ii,:));
end

colormap(cmap)
caxis([min(C) max(C)])
colorbar

x=[0 0];
y=[15 200];
e=fit(x,y,'exp1');