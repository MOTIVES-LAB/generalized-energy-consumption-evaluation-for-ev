function data_summary = raw_summarize(data_path,filenames,para,ind_CS,speed_CS,err,spd_lv,row,col,flag_showfig,ind_cltc,dur_sub_phase)

    str_results = ["cycle_name","speed_intensity","braking_intensity","braking_intensity_hi","braking_intensity_lo","slow_driving_intensity",...
                    "energy_consumption_Wh_km","p_idel_W","trip_distance_km","idle_duration_s","trip_consumption_Wh","trip_duration_h","loss_brake_hi","loss_brake_lo"];

    
    % ------------number of cycles ------------- %
    num_cycle = length(filenames);
    
    % --------------------init-------------------%
    name_cycle = strings(num_cycle,1);
    results_cycle = nan(num_cycle,length(str_results)-1);
    
    cnt_CS = 1; 
   for i = 1:num_cycle

%         disp(strcat("No.",num2str(i)," cycle is processing.............................."))

        % -------------------obtian id for the 1st col-----------------%
        temp = filenames{i}(1:end-5);
        name_cycle(i) = strrep(temp,"_"," ");
        % -------------------obtian raw data-----------------%
        filename_cycle = strcat(data_path,filenames{i});
        warning off
            if any(strcmp(sheetnames(filename_cycle), 'Continuous20Hz'))
                T = readtable(filename_cycle,'Sheet','Continuous20Hz');
            else
                T = readtable(filename_cycle);
            end
%         T = readtable(filename_cycle);
        warning on
        if ind_CS(i)
            T = raw_const_speed_cut(T,speed_CS(cnt_CS),err);
            cnt_CS = cnt_CS + 1;
        end

        t = T.PhaseTime;
        t = t - t(1);                   % s
        ts = t(2)-t(1);
        spd = T.DAActualSpeed;            % km/h
        vol = [T.REESSVoltage T.REESSVoltage2];            % V
        cur = [T.REESSCurrent T.REESSCurrent2];            % A
        pow = -sum(vol.*cur,2);                            % W

%         spd_profile = [t spd];
        % -------------------feature calculation-----------------%

        [I_spd,I_brk,I_brk_hi,I_brk_lo,I_slw,EC,p_idle,D,t_idle,E,duration,Loss_brk_hi,Loss_brk_lo] = feature_cal(spd,pow,ts,para,spd_lv);

        results_cycle(i,1) = I_spd;
        results_cycle(i,2) = I_brk;
        results_cycle(i,3) = I_brk_hi;
        results_cycle(i,4) = I_brk_lo;
        results_cycle(i,5) = I_slw;
        results_cycle(i,6) = EC;
        results_cycle(i,7) = p_idle;
        results_cycle(i,8) = D;
        results_cycle(i,9) = t_idle;
        results_cycle(i,10) = E;
        results_cycle(i,11) = duration;
        results_cycle(i,12) = Loss_brk_hi;
        results_cycle(i,13) = Loss_brk_lo;
        

        if flag_showfig==1
            subplot(row,col,i)
            figure()
            show_spd_pow(spd,pow,name_cycle(i))
        end
        
    end

%     data_summary = cell2table([cellstr(name_cycle),num2cell(results_cycle)],...
%         "VariableNames", str_results);
%% ====== deal with sub-pahse data ===== %%
    if nargin>10
        time_sub_phase = cumsum(dur_sub_phase);
        num_sub_cycle = length(ind_cltc);
        num_phase = length(dur_sub_phase);
    
        name_sub_cycle = strings(num_sub_cycle*num_phase,1);
        results_sub_cycle = nan(num_sub_cycle*num_phase,length(str_results)-1);
    
        for i = 1:num_sub_cycle
    
    %         disp(strcat("No.",num2str(i)," cycle is processing.............................."))
            ind_sub_cycle = ind_cltc(i);
            % -------------------obtian raw data-----------------%
            filename_cycle = strcat(data_path,filenames{ind_sub_cycle});
            warning off
            if any(strcmp(sheetnames(filename_cycle), 'Continuous20Hz'))
                T = readtable(filename_cycle,'Sheet','Continuous20Hz');
            else
                T = readtable(filename_cycle);
            end
            warning on
            t = T.PhaseTime;
            t = t - t(1);                   % s
            ts = t(2)-t(1);
            spd = T.DAActualSpeed;            % km/h
            vol = [T.REESSVoltage T.REESSVoltage2];            % V
            cur = [T.REESSCurrent T.REESSCurrent2];            % A
            pow = -sum(vol.*cur,2);                            % W
    
            ind_sub_phase = [1 floor(time_sub_phase/ts)+1];
            ind_sub_phase(end) = min([ind_sub_phase(end),length(spd)]);
            for j = 1:num_phase
                % -------------------feature calculation-----------------%
    
                % -------------------obtian id for the 1st col-----------------%
                name_sub_cycle((i-1)*3+j) = strcat(filenames{ind_sub_cycle}(1:end-5),"-Ph",num2str(j));
                name_sub_cycle((i-1)*3+j) = strrep(name_sub_cycle((i-1)*3+j),"_"," ");
                spd_sub = spd(ind_sub_phase(j):ind_sub_phase(j+1));
                pow_sub = pow(ind_sub_phase(j):ind_sub_phase(j+1));
    
                [I_spd,I_brk,I_brk_hi,I_brk_lo,I_slw,EC,p_idle,D,t_idle,E,duration,Loss_brk_hi,Loss_brk_lo] = feature_cal(spd_sub,pow_sub,ts,para,spd_lv);
        
                results_sub_cycle((i-1)*3+j,1) = I_spd;
                results_sub_cycle((i-1)*3+j,2) = I_brk;
                results_sub_cycle((i-1)*3+j,3) = I_brk_hi;
                results_sub_cycle((i-1)*3+j,4) = I_brk_lo;
                results_sub_cycle((i-1)*3+j,5) = I_slw;
                results_sub_cycle((i-1)*3+j,6) = EC;
                results_sub_cycle((i-1)*3+j,7) = p_idle;
                results_sub_cycle((i-1)*3+j,8) = D;
                results_sub_cycle((i-1)*3+j,9) = t_idle;
                results_sub_cycle((i-1)*3+j,10) = E;
                results_sub_cycle((i-1)*3+j,11) = duration;
                results_sub_cycle((i-1)*3+j,12) = Loss_brk_hi;
                results_sub_cycle((i-1)*3+j,13) = Loss_brk_lo;
    %             figure()
    %             show_spd_pow(spd_sub,pow_sub,name_cycle((i-1)*3+j))
            end
        end
    
        data_summary = cell2table([ cellstr(name_cycle),num2cell(results_cycle);...
                                    cellstr(name_sub_cycle),num2cell(results_sub_cycle)],...
                                    "VariableNames", str_results);
    else
        data_summary = cell2table([ cellstr(name_cycle),num2cell(results_cycle);],...
                                    "VariableNames", str_results);
    end
