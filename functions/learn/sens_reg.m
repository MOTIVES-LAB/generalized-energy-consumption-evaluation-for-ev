function C = sens_reg(y,X,mode)

if mode==1  % least square
    [C,~,~,~,~] = regress(y,X);

elseif mode==2  % quantile regression
    C=quantreg(X,y,0.5);

elseif mode==3  % ridge regression

else
    error("unrecognized regression mode!")
end