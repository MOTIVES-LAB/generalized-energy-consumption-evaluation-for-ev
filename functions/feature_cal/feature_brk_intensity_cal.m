function [I_brk,I_brk_hi,I_brk_lo,Loss_brk_hi,Loss_brk_lo] = feature_brk_intensity_cal(v,pow,ts,para,spd_lv,p_idle)

v = v/3.6;  % km/h  ----> m/s
v_bar = (v(1:end-1)+v(2:end))/2;
pow_bar = (pow(1:end-1)+pow(2:end))/2;
if nargin==4
    I_brk = 0.5*sum(max(v(1:end-1).^2-v(2:end).^2,0))/(sum(v_bar)*ts);
    I_brk_hi = nan;
    I_brk_lo = nan;
elseif nargin==5 || nargin==6
    
    A = para(1);      % N
    B = para(2)*3.6;      % N/(m/s)
    C = para(3)*3.6^2;    % N/(m/s)^2
    m = para(4);       % kg
    num_v = length(v)-1;
    E_brk = nan(num_v,1);
    Loss_brk = nan(num_v,1);
    for i = 1:num_v
        E_brk(i) = 0.5*m*(v(i)^2-v(i+1)^2)-0.5*A*ts*(v(i)+v(i+1))-1/3*B*ts*(v(i)^2+v(i+1)^2+v(i)*v(i+1))-1/4*C*ts*(v(i)^3+v(i)^2*v(i+1)+v(i)*v(i+1)^2+v(i+1)^3);
        if E_brk(i) <0
            E_brk(i) =0;
        end
        Loss_brk(i) = max(E_brk(i) + min((pow_bar(i)-p_idle)*ts,0),0);
    end
    I_brk = sum(E_brk/3600)/sum(v_bar*ts/1000);
    
    
    if nargin==5
        I_brk_hi = nan;
        I_brk_lo = nan;
    elseif nargin==6
        ind_lv =  v_bar>spd_lv;
    
        I_brk_hi = sum(E_brk(ind_lv)/3600)/sum(v_bar*ts/1000);
        I_brk_lo = sum(E_brk(~ind_lv)/3600)/sum(v_bar*ts/1000);
        
        Loss_brk_hi = sum(Loss_brk(ind_lv)/3600)/sum(v_bar*ts/1000);
        Loss_brk_lo = sum(Loss_brk(~ind_lv)/3600)/sum(v_bar*ts/1000);
        if isnan(I_brk_hi)
            I_brk_hi = 0;
            Loss_brk_hi = 0;
        elseif isnan(I_brk_lo)
            I_brk_lo = 0;
            Loss_brk_lo = 0;
        end
    end
    
%     I_brk = sum(v_bar.*max(para(4)*(v(1:end-1)-v(2:end))/3.6-ts*(para(1) + para(2)*v_bar + para(3)*v_bar.^2),0))/sum(v_bar)/(ts);   % unit: kgm/s^2
%     v_bar = v_bar/3.6;
%     I_brk = sum(v_bar.*max(para(4)*(v(1:end-1)-v(2:end))-ts*(para(1) + para(2)*v_bar*3.6 + para(3)*(v_bar*3.6).^2),0))/sum(v_bar)/(ts);% unit: kgm/s^2
else
    warning('The number of input var is not recognized')
end