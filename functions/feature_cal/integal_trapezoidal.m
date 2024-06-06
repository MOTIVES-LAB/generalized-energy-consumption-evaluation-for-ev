function e = integal_trapezoidal(f,ts)
%  trapezoidal rule approximating the integal of the function
e = sum((f(1:end-1)+f(2:end))/2*ts);