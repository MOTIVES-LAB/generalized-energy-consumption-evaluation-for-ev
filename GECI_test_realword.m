%% Validate the GECIs using realword driving data
% 
% This script applies the characterized Generalized Energy 
% Consumption Indices (GECIs) (from CharacterizeGECI_lab.m) to realworld 
% driving trips, to further validate the generalizability of the GECIs.

%% ABOUT this code
%     Version: 1.0, 20-August-2023
%     Authors: Xinmei Yuan
%     E-mail:  yuan@jlu.edu.cn

%     Underlying method described in:
%     X. Yuan, J. He, Y. Li, Y. Liu, Y. Ma, B Bao, L. Li, H. Zhang Y. Jin 
%     and L. Sun (2023) Data-driven evaluation of electric vehicle energy 
%     consumption for generalizing standard testing to real-world driving.
%     Joule, submitted.
%%


clc;
clear;

addpath(genpath(pwd));

%% -------------------training------------------------- %%


% ----- parameters -----%
    load("results\GECIs.mat")
    % ----- file info -----%
    % ----- dyno info -----%
    A = 179.4;      % N
    B = 0.28;      % N/(km/h)
    C = 0.0235;    % N/(km/h)^2
    m = 1919;       % kg

    para = [A,B,C,m];

%     est_eff = 1; % for compensate elevation impact
    
    % ----- trainging parameter ----- %
    err_const_spd = 1;      % km/h the extract const speed segment should meet this speed err requirement.
    spd_lv = 15;            % km/h threshold for low- and high-speed braking 

 

 
%% -------------------test real driving------------------------- %%

% ----- parameters -----%

    % ----- file info -----%
    data_path_test_set = "data\real_world_data\";
    num_data_path = length(data_path_test_set);

    ind_test_start = 1;       % Samples at high SOC are discarded

    % ----- init -----%
    test_data_sets = cell(num_data_path,1);

    for i = 1:num_data_path
        
        % ----- file info -----%
        data_path_test = data_path_test_set(i);

        dirOutput=dir(strcat(data_path_test,"*.xlsx"));
        filenames_test={dirOutput.name};

        ind_CS = zeros(length(filenames_test),1);
%         split_temp = split(string(filenames_test(ind_CS)),["_", "."]);
        speed_CS = [];
        
        % ----- read files -----%
        data_summary = raw_summarize_elev(data_path_test,filenames_test,para,ind_CS,speed_CS,err_const_spd,spd_lv,0,0,0);
        
        ind_test = ind_test_start(i):length(filenames_test);
        test_data_sets{i} = data_summary(ind_test,:);
    end
    
    % ----- combine test sets -----%
    data_summary_realworld = vertcat(test_data_sets{:});

%     str_feature =cellstr(["cyc_no","spd_intensity","brk_intensity_hi","brk_intensity_lo","slwdrv_intensity","ECR"]);
%     filename_feature_realworld = "exportfile\feature_realworld.xlsx";
%     feature_realworld = table2cell(data_summary_realworld(:,[1 2 4 5 6 7]));    
%     writecell([str_feature;feature_realworld],filename_feature_realworld)

%% =============== realworld bias correction and tests =============== %

N_sel = 6; % number of trips used to learn the bias (the tires of the vehicle was replaced)
num_test = 100; % number of tests 

% initialization
[results_realworld,MAPE_realworld,RMSE_realworld] = GECI_test(GECIs,data_summary_realworld,m,1,0);
ECR_meas = results_realworld{:,2};
num_realworld_test = length(ECR_meas);
N_trips = height(results_realworld);

cor_real_driving = nan(num_test,1);
mape_real_driving = nan(num_test,1);
rmse_real_driving = nan(num_test,1);

ECR_est = nan(num_realworld_test,num_test);
err_est = nan(num_realworld_test,num_test);

for i = 1:num_test
    rng(i*15);

    % random select trips for learn the bias
    ind = randperm(N_trips);
    ind_cor = ind(1:N_sel);
    cor_real_driving(i) = mean(results_realworld{ind_cor,2})-mean(results_realworld{ind_cor,3});

    % test GECIs adapt to all trips
    [test_result,mape_real_driving(i),rmse_real_driving(i)] = GECI_test(GECIs,data_summary,m,1,cor_real_driving(i));
    ECR_est(:,i) = test_result{:,3};
    err_est(:,i) = test_result{:,4};
end
disp("-----------------------------------------------------------------------------------------------");
disp(strcat("The mean MAPE of the ",num2str(num_test)," tests is ", num2str(mean(mape_real_driving))," %."));
disp(strcat("The mean RMSE of the ",num2str(num_test)," tests is ", num2str(mean(rmse_real_driving))," Wh/km."));


        

% data for error bar plots
    ECR_est_exp = mean(ECR_est,2);
    ECR_err_exp = mean(err_est,2);
    
    ECR_est_errplus = max(ECR_est,[],2)-ECR_est_exp;
    ECR_est_errminus = ECR_est_exp-min(ECR_est,[],2);
    
    ECR_err_errplus = max(err_est,[],2)-ECR_err_exp;
    ECR_err_errminus = ECR_err_exp-min(err_est,[],2);
    
    str_ECR =cellstr(["cyc No.","ECR_meas [Wh/km]","ECR_est [Wh/km]","ECR_err+[Wh/km]","ECR_err-[Wh/km]","relative err[%]","relative err+[%]","relative err-[%]"]);
    num_col = length(str_ECR);
    
    ECR_realworld = cell(num_realworld_test,num_col);
    for i = 1:num_realworld_test
    %         cyc_no = char(results_realworld{i,1});
    %         ECR_realworld{i,1} = strcat(cyc_name(1:end-2),"_",cyc_name(end));
            ECR_realworld{i,1} = results_realworld{i,1};
            ECR_realworld{i,2} = ECR_meas(i);
            ECR_realworld{i,3} = ECR_est_exp(i);
            ECR_realworld{i,4} = ECR_est_errplus(i);
            ECR_realworld{i,5} = ECR_est_errminus(i);
            ECR_realworld{i,6} = ECR_err_exp(i);
            ECR_realworld{i,7} = ECR_err_errplus(i);
            ECR_realworld{i,8} = ECR_err_errminus(i);
    end
% filename_ECR_realworld = "exportfile\ECR_realworld_new.xlsx";
% writecell([str_ECR;ECR_realworld],filename_ECR_realworld)