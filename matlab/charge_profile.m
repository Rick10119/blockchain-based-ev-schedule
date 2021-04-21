

% 输入电动汽车产生的概率，输入给充电站的Lambda_K
% lambda 统一输入 0-3，在这里转换为乘上充电站个数
%% 采用文献分时数据
if lambdaMode == 2
    SLOTS = 96;
    % 来自文献的数据
    lambdaK = [zeros(7,1);0.20;0.18;0.30;0.23;0.29;0.19;0.22;0.25;0.20;0.11;0.13;0.16;0.15;0;0;0;0;0];
%     lambdaK = [2;zeros(24,1)];
%提前一个小时(先不管)
%     lambdaK = [zeros(7,1);0.20;0.18;0.30;0.23;0.29;0.19;0.22;0.25;0.20;0.11;0.13;0.16;0.15;zeros(5,1)];
    lambdaK = nofStation * 12 * lambdaK;% 12是随便取的，使得最大lambda为13.6
    t = 4*(0:24);
    i = 1:SLOTS;
    % 线性插值
    lambdaK = interp1(t,lambdaK,i,'linear');
   
    
    fid = fopen('.\param\lambdaK.txt', 'wt');
    
    fprintf(fid, '%.5f\n',lambdaK);
    
    fclose(fid);
end

%% 采用恒定 lambda,此时最好endTime不超过20小时
if lambdaMode == 1
    SLOTS = 4 * endTime;
    
    lambdaK = lambda * nofStation * ones(1, SLOTS);
    
    fid = fopen('.\param\lambdaK.txt', 'wt');
    
    fprintf(fid, '%.5f\n',lambdaK);
    
    fclose(fid);
    
end

% plot(lambdaK);hold on;
% plot(lambda_forecast);
%% 写入电价数据
    SLOTS = 4 * endTime;
    
    base_price = 1 * ones(1, SLOTS);
    
    fid = fopen('.\param\basePrice.txt', 'wt');
    
    fprintf(fid, '%.5f\n',base_price);
    
    fclose(fid);
