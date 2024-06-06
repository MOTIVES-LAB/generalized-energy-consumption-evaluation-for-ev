%% Characterize and validate the GECIs using laboratory test data
% 
% This script utilizes the CLTC (China Light Vehicle Test Cycle) and 
% constant speed segments (CSS) to characterize the Generalized Energy 
% Consumption Indices (GECIs). The generalizability of the GECIs is 
% validated by applying them to other standard driving cycles and CSSs.

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

%% select BEV model %%
BEV_model_No = 1;
data_path_BEV_model = strcat("data\lab_data_m",num2str(BEV_model_No));


para_BEV_model = [  179.4 0.28 0.0235 1919;...
                    116 0.575 0.0273 1808;...
                    228.7 1.55 0.0289 2621];
% Model 1
%     A = 179.4;      % N
%     B = 0.28;      % N/(km/h)
%     C = 0.0235;    % N/(km/h)^2
%     m = 1919;       % kg

% Model 3
%     A = 228.7;      % N
%     B = 1.548;      % N/(km/h)
%     C = 0.02891;    % N/(km/h)^2
%     m = 2621;       % kg


%% -------------------training------------------------- %%


% ----- parameters -----%

    % ----- file info -----%
    data_path_train = strcat(data_path_BEV_model,"\CLTC_CSS\");
    
    dirOutput=dir(strcat(data_path_train,"*.xlsx"));
    filenames_train={dirOutput.name};
    
    ind_cltc = find(contains(filenames_train,"CLTC"));
    ind_CS = contains(filenames_train,"CS");

    split_temp = split(string(filenames_train(ind_CS)),["_", "."," "]);
    speed_CS = str2double(split_temp(:,:,3));

    ind_train = 4:11;       % Samples at high SOC are discarded


    % ----- cycle info -----%
    dur_sub_phase = [674 693 433]; % CLTC-P

    % ----- coastdown coefficients -----%
    A = para_BEV_model(BEV_model_No,1);       % N
    B = para_BEV_model(BEV_model_No,2);       % N/(km/h)
    C = para_BEV_model(BEV_model_No,3);       % N/(km/h)^2
    m = para_BEV_model(BEV_model_No,4);       % kg
    
    para = [A,B,C,m];
    
    % ----- trainging parameter ----- %
    err_const_spd = 1;      % km/h the extract const speed segment should meet this speed err requirement.
    spd_lv = 15;            % km/h threshold for low- and high-speed braking 



% ----- read files -----%
    data_summary = raw_summarize(data_path_train,filenames_train,para,ind_CS,speed_CS,err_const_spd,spd_lv,0,0,0,ind_cltc,dur_sub_phase);

% ----- training ----- %
    [~,ind_cltc_train] = intersect(ind_train,ind_cltc);
    [~,ind_CS_train] = intersect(ind_train,find(ind_CS));
    [~,pos_sub_train] = intersect(ind_cltc,ind_train);
    ind_sub_train = sort([(pos_sub_train-1)'*3+1 (pos_sub_train-1)'*3+2 (pos_sub_train-1)'*3+3]) ;
    
    data_summary_stepwise_train = data_summary([ind_train ind_sub_train + length(filenames_train)],:);
    ind_sub_train = sort([(pos_sub_train-1)'*3+1,(pos_sub_train-1)'*3+3]) ;
    ind_sub_train = (ind_sub_train - ind_sub_train(1) + 1 + length(ind_train))';
    GECIs = GECI_learn(data_summary_stepwise_train,ind_cltc_train,ind_CS_train,ind_sub_train,1);

% ----- training test ----- %
    data_summary_train = data_summary(ind_train,:);
    [results_trainset_lab,MAPE_trainset_lab,RMSE_trainset_lab] = GECI_test(GECIs,data_summary_train);

% ----- disp results ----- %
    disp(results_trainset_lab);
    disp("-----------------------------------------------------------------------------------------------");
    disp(strcat("The metrics of the training set (",num2str(height(results_trainset_lab)), " tested cycles) using GECI model is: "));
    disp(strcat("*RMSE = ", num2str(RMSE_trainset_lab,"%.2f")," Wh/km"));
    disp(strcat("*MAPE = ", num2str(MAPE_trainset_lab,"%.2f")," %"));
%% -------------------test------------------------- %%

% ----- parameters -----%

    % ----- file info -----%
    
    data_path_test_set = [strcat(data_path_BEV_model,"\UDDS_HWY_US06_NYCC_CSS\"),strcat(data_path_BEV_model,"\WLTC_CADC_JC08_CSS\")];
    num_data_path = length(data_path_test_set);

    ind_test_start = [6,5];       % Samples at high SOC are discarded

    % ----- init -----%
    test_data_sets = cell(num_data_path,1);

    for i = 1:num_data_path
        
        % ----- file info -----%
        data_path_test = data_path_test_set(i);

        dirOutput=dir(strcat(data_path_test,"*.xlsx"));
        filenames_test={dirOutput.name};

        ind_CS = contains(filenames_test,"CS");
        split_temp = split(string(filenames_test(ind_CS)),["_", "."," "]);
        speed_CS = str2double(split_temp(:,:,3));
        
        % ----- read files -----%
        data_summary = raw_summarize(data_path_test,filenames_test,para,ind_CS,speed_CS,err_const_spd,spd_lv,0,0,0);
        
        ind_test = ind_test_start(i):length(filenames_test);
        test_data_sets{i} = data_summary(ind_test,:);
    end
    
    % ----- combine test sets -----%
    data_summary_lab_test = vertcat(test_data_sets{:});

    % ----- test ----- % 
       [results_testset_lab,MAPE_testset_lab,RMSE_testset_lab] = GECI_test(GECIs,data_summary_lab_test);
    
  
        disp(results_testset_lab);
        disp("-----------------------------------------------------------------------------------------------");
        disp(strcat("The metrics of the test set (",num2str(height(results_testset_lab)), " tested cycles) using GECI model is: "));
        disp(strcat("*RMSE = ", num2str(RMSE_testset_lab,"%.2f")," Wh/km"));
        disp(strcat("*MAPE = ", num2str(MAPE_testset_lab,"%.2f")," %"));


        save('results\results_lab_test.mat',"data_summary_lab_test",'results_testset_lab') 
        save('results\results_train.mat',"data_summary_train",'results_trainset_lab') 
        save('results\GECIs.mat',"GECIs") 