function C_slw = sens_idle_learn(p_idle)

filename_standard = 'CLTC_P.csv';

T = readtable(filename_standard);
v_b = T.Speed_km_h;
I_slw_b = 1/mean(v_b);

C_slw = p_idle*I_slw_b;