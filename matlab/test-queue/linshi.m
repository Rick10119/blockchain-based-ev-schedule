% 指数分布
clc;clear;
lambda = 1;
for i = 1:1000
    x(i) = rand;
    y(i) = -log(1-x(i))/lambda;
end



%%
lambda = 1;
x = 0.01:0.01:10;
sumof = 0;
for i = 1:1000
    y(i) =  exp(-lambda*x(i));
    if x(i) > 1/3 && x(i) < 3
        sumof = sumof + y(i);
    end
end


sum(0.01*y(:))
% (exp(-1/3)/3 + exp(-1/3) - 4*exp(-3)) /(exp(-1/3)-exp(-3))