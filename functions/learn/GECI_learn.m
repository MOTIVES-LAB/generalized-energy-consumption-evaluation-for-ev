function C_sens = GECI_learn(data_summary,ind_cltc_train,ind_CS_train,ind_sub_train,flag_loss_brk)

% ---------------- training step 1 ------------ %

ind_idle_train = ind_cltc_train; 
p_idle_train = [data_summary{ind_idle_train,8}];
C_slw = sens_idle_learn(mean(p_idle_train));

% ---------------- training step 2 ------------ %
ind_const_train = ind_CS_train; 
I_spd_train = data_summary{ind_const_train,2};
I_slw_train = data_summary{ind_const_train,6};
EC_train = data_summary{ind_const_train,7};

reg_mode = 1; % least squre
% reg_mode = 2; % quantile regression
flag_showfig = 0;

C_const_spd = sens_CS_learn(I_spd_train,EC_train,reg_mode,I_slw_train,C_slw,flag_showfig);
C_const = C_const_spd(1);
C_spd = C_const_spd(2);

% ---------------- training step 3 ------------ %
ind_brk_train = ind_cltc_train; 
if flag_loss_brk
    Loss_brk_hi = data_summary{ind_brk_train,13};
    Loss_brk_lo = data_summary{ind_brk_train,14};
    I_brk_hi_train = data_summary{ind_brk_train,4};
    I_brk_lo_train = data_summary{ind_brk_train,5};
%     Y1 = [(EC_train - C_const - C_spd*I_spd_train - C_slw*I_slw_train);zeros(size(EC_train))];
%     X1 = [I_brk_hi_train I_brk_lo_train;I_brk_hi_train./Loss_brk_hi -I_brk_lo_train./Loss_brk_lo];
    
    r_lo_hi = mean(I_brk_hi_train.*Loss_brk_lo./Loss_brk_hi./I_brk_lo_train);

    ind_hi_lo_brk_train = ind_sub_train;

    I_spd_train = data_summary{ind_hi_lo_brk_train,2};
    I_brk_hi_train = data_summary{ind_hi_lo_brk_train,4};
    I_brk_lo_train = data_summary{ind_hi_lo_brk_train,5};
    I_slw_train = data_summary{ind_hi_lo_brk_train,6};
    EC_train = data_summary{ind_hi_lo_brk_train,7};


    Y2 = (EC_train - C_const - C_spd*I_spd_train - C_slw*I_slw_train);
    X2 = I_brk_hi_train+I_brk_lo_train*r_lo_hi;
    
    C_hi_brk = X2\Y2;
%     C_hi_brk = C_hi_lo_brk(1);
    C_lo_brk = C_hi_brk*r_lo_hi;

else
    ind_hi_lo_brk_train = ind_sub_train;
    I_spd_train = data_summary{ind_hi_lo_brk_train,2};
    I_brk_hi_train = data_summary{ind_hi_lo_brk_train,4};
    I_brk_lo_train = data_summary{ind_hi_lo_brk_train,5};
    I_slw_train = data_summary{ind_hi_lo_brk_train,6};
    EC_train = data_summary{ind_hi_lo_brk_train,7};
    
    C_hi_lo_brk = [I_brk_hi_train I_brk_lo_train]\(EC_train - C_const - C_spd*I_spd_train - C_slw*I_slw_train);
    C_hi_brk = C_hi_lo_brk(1);
    C_lo_brk = C_hi_lo_brk(2);
end

if C_hi_brk<0
    C_lo_brk = C_lo_brk + C_hi_brk; 
    C_hi_brk = 0;
end
% 

name_C_sens = {'EC constant [Wh/km]:';'Speed Sinsitivity [Wh/km]:';'Braking Sinsitivity (high-speed) [Wh/km]:';'Braking Sensitivity (low-speed) [Wh/km]:';'Slow-driving Sinsitivity [Wh/km]:'};
C_sens = cell2table([name_C_sens num2cell(roundn([C_const C_spd C_hi_brk C_lo_brk C_slw]',-1))],"VariableNames",["name","value [Wh/km]"]);

disp(C_sens);