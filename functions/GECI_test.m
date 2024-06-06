function [test_summary_4featured,MAPE_4featured,RMSE_4featured] = GECI_test(C_sens,data_summary,m,eff,cor)

g=9.8;

C_const = C_sens.("value [Wh/km]")(1);
C_spd = C_sens.("value [Wh/km]")(2);
C_hi_brk = C_sens.("value [Wh/km]")(3);
C_lo_brk = C_sens.("value [Wh/km]")(4);
C_slw = C_sens.("value [Wh/km]")(5);

cycname_test = data_summary(:,1);
I_spd_test = data_summary{:,2};
% I_brk_test = data_summary{:,3};
I_brk_hi_test = data_summary{:,4};
I_brk_lo_test = data_summary{:,5};
I_slw_test = data_summary{:,6};
EC_test = data_summary{:,7};
dist_test = data_summary{:,9};
% E_test = data_summary{:,11};

if exist('m','var')
    if ~exist('eff','var')
        eff=1;
    end
    if any("diff_elev" == string(data_summary.Properties.VariableNames))
        diff_elev = data_summary{:,15};
        EC_est_elev = m*g*diff_elev./dist_test/3600;
        if EC_est_elev>0    %Uphill
            EC_est_elev = EC_est_elev/eff;   
        else
            EC_est_elev = EC_est_elev*eff;
        end
    end
else
   EC_est_elev = 0;
end

if ~exist('cor','var')
    cor=0;
end

EC_est = C_const + C_spd*I_spd_test + I_brk_hi_test*C_hi_brk + I_brk_lo_test*C_lo_brk + C_slw*I_slw_test + EC_est_elev + cor;


str_results = ["measured EC [Wh/km]","estimated EC [Wh/km]","relative err [%]","cycle distance [km]"];

test_summary_4featured = [cycname_test, cell2table([num2cell(roundn([EC_test,EC_est],0)), num2cell(roundn((EC_est-EC_test)*100./EC_test,-2)),...
                                                num2cell(roundn(dist_test,-1))], "VariableNames", str_results)];

RMSE_4featured = sqrt(mean((test_summary_4featured.("estimated EC [Wh/km]")-test_summary_4featured.("measured EC [Wh/km]")).^2));

MAPE_4featured  = mean(abs(table2array(test_summary_4featured(:,4))));

