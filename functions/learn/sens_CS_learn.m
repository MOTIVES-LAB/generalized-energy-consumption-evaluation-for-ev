function C = sens_CS_learn(I_spd,EC,mode_reg,I_slw,C_slw,flag_showfig)

filename_standard = 'CLTC_P.csv';
T = readtable(filename_standard);
v_b = T.Speed_km_h;
I_spd_b = feature_spd_intensity_cal(v_b);

spd = sqrt(I_spd*I_spd_b);

if nargin==5
    X = [ones(size(I_spd)),I_spd,I_slw];
    y = EC;


    C = sens_reg(y,X,mode_reg);
    
%     disp(strcat('R^2: ',num2str(STATS(1))));
    if flag_showfig
        scatter3(I_spd,I_slw,y,'filled');
        hold on
        x1fit = min(I_spd):0.01:max(I_spd);
        x2fit = min(I_slw):0.01:max(I_slw);
        [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
        YFIT = C(1) + C(2)*X1FIT + C(3)*X2FIT;
        mesh(X1FIT,X2FIT,YFIT)
        hold off
    end    
%     Aeq = ones(1,width(X));
%     beq = ec_beq;
%     A = [ones(1,width(X));-ones(1,width(X))];
%     b = [ec_beq + 5;-(ec_beq - 5)];
%     C = lsqlin(X,Y,A,b);
%     disp(strcat('R^2: ',num2str(STATS(1))));
elseif nargin==4
    X = [ones(size(I_spd)),I_spd];
    y = EC;

    C = sens_reg(y,X,mode_reg);
%     [C,~,~,~,STATS] = regress(y,X);
%     disp(strcat('R^2: ',num2str(STATS(1))));
    if flag_showfig
        scatter(I_spd,y,'filled');
        hold on
        yFIT = C(1) + C(2)*I_spd;
        plot(I_spd,yFIT)
        hold off
    end
elseif nargin==6
    X = [ones(size(I_spd)),I_spd];
    y = EC-I_slw*C_slw;
    
    C = sens_reg(y,X,mode_reg);
%     [C,~,~,~,STATS] = regress(y,X);
%     disp(strcat('R^2: ',num2str(STATS(1))));
    if flag_showfig
        figure()
        scatter(spd,y,'filled');
        hold on
        spd_est = (10:5:100)';
        I_spd_FIT = zeros(size(spd_est));
        for i = 1:length(spd_est)
            I_spd_FIT(i) = spd_intensity_cal(spd_est(i))/I_spd_b;
        end
        yFIT = C(1) + C(2)*I_spd_FIT;
        plot(spd_est,yFIT)
        xlabel("speed [km/h]")
        ylabel("energy consumption rate [wh/km]")
        legend("training samples","esitimated model",'Location','northwest')
        grid
        hold off
    end
else
    error("incorrect number of inputs!")
end

