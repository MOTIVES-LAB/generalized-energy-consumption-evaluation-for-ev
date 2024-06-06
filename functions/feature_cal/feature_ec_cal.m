function [EC,p_idle,D,t_idle,E,duration] = feature_ec_cal(v,p,ts)

D = integal_trapezoidal(v/3600,ts); % cycle distance [km]
E = integal_trapezoidal(p,ts)/3600; % total energy consumption [Wh]
ind = abs(v)<=1e-1;
p_idle = mean(p(ind));
t_idle = ts*sum(ind);
EC = E/D;                           % energy consumption [Wh/km]
duration = length(v)*ts/3600;