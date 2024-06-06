function [I_spd,I_brk,I_brk_hi,I_brk_lo,I_slw,EC,p_idle,D,t_idle,E,duration,Loss_brk_hi,Loss_brk_lo] = feature_cal(spd,pow,ts,para,spd_lv)

[EC,p_idle,D,t_idle,E,duration] = feature_ec_cal(spd,pow,ts);

filename_standard = strcat('CLTC_P.csv');

T = readtable(filename_standard);
t = T.Time_s;
v_b = T.Speed_km_h;
ts_b = t(2)-t(1);

% ----- calcu
I_spd_b = feature_spd_intensity_cal(v_b);
[I_brk_b,I_brk_hi_b,I_brk_lo_b,~,~]  = feature_brk_intensity_cal(v_b,zeros(size(v_b)),ts_b,para,spd_lv,0);
I_slw_b = 1/mean(v_b);


I_spd = feature_spd_intensity_cal(spd)/I_spd_b;
[I_brk,I_brk_hi,I_brk_lo,Loss_brk_hi,Loss_brk_lo] = feature_brk_intensity_cal(spd,pow,ts,para,spd_lv,0);
I_brk = I_brk/I_brk_b;
I_brk_hi = I_brk_hi/I_brk_hi_b;
I_brk_lo =I_brk_lo/I_brk_lo_b;
I_slw = 1/mean(spd)/I_slw_b;

