function [ w_corr ] = neutral_equiv_wind_correction( uz, zh)
%correcting wind speeds [m/s] (below: uz) at height z ASL (below: zh) 
%to neutral equivalent wind speed (below: w_corr) at e.g. 10 m ASL (below: height)
%   

height = 10;        % desired height of wind speed

% parameters
MAX_N = 100;        % maximum number of iterations
C_von = 0.40;        % von karman constant
eps = 0.001;        % small number
chrnk = 0.011;      % Charnock coefficient
visc = 14.5e-6;     % kinematic viscosity of air @ 15C
wg = 0.2;           % wind gustiness

z_=zh;

% first guess of ustar
us  = 0.036*uz;
us2 = 0*uz;
z0 = 0*uz;

%check input // eig. unnötig vllt. TODO
%pos = find(tcnt <= 0 | uz < 0);

%include gustiness in wind spd.
%Du = sqrt(uz^2+wg^2);
Du = uz;

% modification of charnok after Fairall
charn = chrnk;
if (Du >= 10)
    charn = 0.011 + (0.018 - 0.011) * (Du - 10) / (18 - 10);
elseif (Du >= 18)
    charn = 0.018;
end

%iteration loop
for i = 1:MAX_N
    % result checking
    if abs(us2-us) <= eps
        break;
    end
    
    % next iteration
    us2 = us;
    
    % calculate roughness length
    z0=charn*us*us/9.81+0.11*(visc/us);
    
    if (z_*0.5 < z0)
        z0 = z_*0.5;
    end
    
    % calculate ustar
    us = C_von * Du / log10(z_/z0);
end
    
w_corr = (us*log10(height/z0))/ C_von;
end

