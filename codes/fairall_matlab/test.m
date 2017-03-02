clear;
Date=1:200;
U=linspace(5,7,200);
Tsea=linspace(20,24,200);
Tair=linspace(23,26,200);
qair=linspace(10,12,200);
Rs=linspace(100,200,200);
Rl=linspace(100,200,200);
Rain=linspace(0,2,200);
Lat=linspace(50,50.5,200);
Lon=linspace(30,30.6,200);
wind_height=30;
zq=25;
zt=25;
bt=-3;

[sst,hf,ef]           = SST_cor3_0af(Date,U,Tsea,Tair,qair,Rs,Rl,Rain,Lat,Lon,wind_height,zq,zt,bt);