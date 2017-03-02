%%hoaps_par_FLUX
%%c to matlab code conversion
%
% OUTPUT:
%
% s:     turbulent flux
% qh:    sensible heat flux
% qe:    latent heat flux
% evap:  evaporation
% ce:    transfer coefficient latent heat flux
%
% INPUT:
% ts                  % SST in deg_C
% qs                  % sea surface humidity in g/kg
% t                   % air temperature in deg_C
% q                   % air humidity in g/kg (q=0.622*(data(:,13).*murphy(t))./data(:,14);)
% u                   % true windspeed in m/s



function [s, qh, qe, evap, ce] = hoaps_par_FLUX(ts, qs, t, q, u, zu, zt, zq)
%parameter

C_von  = 0.4;       % von Karman's constant
C_beta = 1.2;       % Given as 1.25 in Fairall et al.(1996)
C_fdg  = 1.00;      % Fairall's LKB rr to von karman adjustment based on 
                    % results from Flux workshop August 1995
C_tok  = 273.16;    % Celsius to Kelvin
C_cpw  = 4000;      % J/kg/K specific heat water
C_rohw = 1022;      % density water
C_cpa  = 1004.67;   % J/kg/K specific heat of dry air (Businger 1982)
C_rgas = 287.1;     % J/kg/K gas constant of dry air
C_grav = 9.81;      % Gravity
C_zi   = 600;       % mixed layer height
HOAPS_slp = 1013.25;% HOAPS constant, surface layer pressure

% input arguments

% ts=data(:,44);      % SST in deg_C
% qs=data(:,45);      % sea surface humidity in g/kg
% t=data(:,10);       % air temperature in deg_C
% q=data(:,46);       % air humidity in g/kg (q=0.622*(data(:,13).*murphy(t))./data(:,14);)
% u=data(:,17);       % true windspeed in m/s

% height of measurements - TODO
%zu           % height of wind measurement
%zt           % height of air temp and RH
%zq           % height of water vapor measurement





% conversion to kg/kg
q_= q* 0.001;
qs_ = qs* 0.001;

% air temp in K
t_air = t + C_tok;

% latent heat of vaporization at TS - J/kg
xlv = (2.501 - (ts*0.00237)) *1e6;                

% moist air density 
rhoa = HOAPS_slp * 100 / (C_rgas*t_air*(q_*0.61 + 1));

% kinematic viscosity of dry air - Andreas(1989) CRRCEL Rep. 89
visa = 1.326e-5*(1 + t*0.006542 + t*t*8.301e-6 - t*t*t*4.84e-9);

% Initial guess
zo= 1e-4;                                       % roughness length
wg = 0.5;                                       % gustiness factor of wind

% assumes U is measured rel. to current
du = u;                                         % windspeed relative to current

% include gustiness in wind spd. difference equivalent to S in definition
% of fluxes
du_wg = (du * du + wg * wg)^0.5;                % 
% potential temperature diff. Changed sign
dt=ts - t - 0.0098*zt;                          % potential temp. diff. 
dq=qs_ - q_;                                    % difference in humidity

% *** neutral coefficients ***
u10 = du_wg * log(10/zo)/log(zu/zo);
usr = u10 * 0.035;                              % velocity scaling parameter
zo10 = 0.011 * usr*usr/C_grav + 0.11*visa/usr;  % roughness length in 10 m?
cd10 = (C_von/log(10/zo10))^2;                  % transfer coefficients in 10 m?
ch10 = 0.00115;                                 % 
ct10 = ch10/sqrt(cd10);
zot10 = 10/exp(C_von/ct10);                     % 
cd = (C_von/log(zu/zo10))^2;                    % transfere coefficients 

% *********** Grachev and Fairall ( JAM, 1997 ) ***************

ct = C_von/log(zt/zot10);                       % Temperature transfer coeff
cc = C_von * ct/cd;                             % z/L vs Rib linear coeff

% Saturation or plateau Rib

ribcu = -zu / (C_zi*0.004*C_beta*C_beta*C_beta);
ribu = -C_grav * zu * (dt + 0.61 * t_air * dq)/(t_air * du_wg*du_wg);
if (ribu < 0)
    zetu = cc*ribu/(1+ribu/ribcu);              % Unstable G and F
else
    zetu = cc*ribu*(1+27/9*ribu/cc );           % Stable, Chris forgets origin
end

l10 = zu/zetu;                                  % MO length

if (zetu > 50)                                  % iterator
    nits = 1;
else
    nits = 3;
end

% ****** First guess stability dependent scaling params

usr = du_wg*C_von / (log(zu/zo10)-psiu_(zu/l10));
tsr = -dt*C_von*C_fdg / (log(zt/zot10)-psit_(zt/l10));
qsr = -dq*C_von*C_fdg / (log(zq/zot10)-psit_(zq/l10));

% modifing Charnock for high wind speeds Chris' data
charn = 0.011;
if (du_wg > 10)
    charn = 0.011+(0.018-0.011)*(du_wg-10)/8;
end
if (du_wg > 18)
    charn = 0.018;
end

% bulk loop
for iter=1:nits
    zl = C_von * C_grav * zu / t_air * (tsr + 0.61 * t_air * qsr)/(usr*usr);
                                                    % height/L where L is 
                                                    % the Obukhov length    
    zo = charn * usr * usr / C_grav + 0.11 * visa / usr;
                                                    % roughness length
    rr = zo * usr / visa;                           % Roughness Reynolds number
    
    % *** zoq and zot fitted to results from several Chris cruises ****
    zoq = 5.5e-5/(rr^0.63);                         % roughness length for hum.
    zot = zoq;                                      % roughness length for temp.
    
    l = zu/zl;                                      % Obukhov length
    usr = du_wg*C_von/(log(zu/zo) - psiu_(zu/l));   % velocity scaling parameter 
    tsr = -dt*C_von*C_fdg/(log(zt/zot)-psit_(zt/l));% temperature scaling parameter
    qsr = -dq*C_von*C_fdg/(log(zq/zoq)-psit_(zq/l));% hum scaling parameter
    bf = -C_grav/t_air*usr*(tsr+0.61*t_air*qsr);
    % gustiness factor
    if (bf>0)
        wg = C_beta*(bf*C_zi)^0.333;
    else
        wg = 0.2;
    end
    
    % include gustiness in wind speed
    du_wg = sqrt(du*du + wg*wg);
end
    % compute turbulent flux, sensible heat flux (HF), latent heat flux(EF)
    
    s = sqrt(u*u + wg*wg);
    qh = -C_cpa * rhoa*usr*tsr;
    qe = -xlv *   rhoa*usr*qsr;
    evap = -3600 *rhoa*usr*qsr;
    
    % compute transfer coefficients
    ce=-usr*qsr/(s*dq);
    
end
%  Name
%     psiu_
% 
%  Description
%    evaluate stability function for wind speed
%    matching Kansas and free convection forms with weighting f
%    convective form follows Fairall et al (1996) with profile constants
%    from Grachev et al (2000) BLM
%    stable form from Beljaars and Holtslag (1991)
% 



function psiu = psiu_(zl)      % zl height/L where L is the Obukhov length
% unstable
if (zl < 0)
    x = (1 - zl * 15)^0.25;     % Kansas unstable
    psik = log((x+1)*0.5)*2 + log((x*x + 1)*0.5) - atan(x)*2 + atan(1)*2;
    x = (1 - zl * 10.15)^0.3333;% Convective
    
    psic =        1.5 * log((1+x+x*x) / 3) ...
        - sqrt(3) * atan((1+2*x) / sqrt(3))...
        +      4  * atan(1) / sqrt(3);
    
    f = zl * zl / (zl*zl +1);
    psiu = (1-f)*psik + f * psic;
    % stable
else
    c = min([50 zl*0.35]);
    psiu = -(((1+1*zl)^1) + 0.6667 * (zl - 14.28)/exp(c) + 8.525);
end
end

%  Name
%     psit_
%
%  Description
%   evaluate stability fucntion for scalars
%   matching Kansas and free convection form with weighting f
%   convective form follows Fairall et al (1996) with profile constants
%   from Grachev et al (2000) BLM
%   stable form from Beljaar and Holtslag (1991)
function psit=psit_(zl)
% unstable
if (zl < 0)
    x = (1 - zl * 15)^0.5;          % Kansas unstable
    psik = log((x + 1) * 0.5) * 2;
    x = (1 - zl * 34.15)^0.3333;
        psic =      ...
                    1.5  * log((1. + x + x * x) / 3.) ...
                - sqrt(3.) * atan((x * 2. + 1.) / sqrt(3.))...
                     + 4. * atan(1.) / sqrt(3.);
             
    f = zl * zl / (zl * zl + 1.);
	  psit = (1. - f) * psik + f * psic;
% stable
else 
    c = min([50 zl*0.35]);
    psit =  -(((1+2*zl/3)^1.5) + 0.6667*(zl - 14.28)/exp(c) + 8.525);
end

end