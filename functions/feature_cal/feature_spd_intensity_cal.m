function I_spd = spd_intensity_cal(v)
if length(v)>1
    v_bar = (v(1:end-1)+v(2:end))/2;
    I_spd = sum(v_bar.^3)/sum(v_bar);
elseif length(v)==1
    I_spd = v^2;
end