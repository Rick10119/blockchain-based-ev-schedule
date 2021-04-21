

% ����綯���������ĸ��ʣ���������վ��Lambda_K
% lambda ͳһ���� 0-3��������ת��Ϊ���ϳ��վ����
%% �������׷�ʱ����
if lambdaMode == 2
    SLOTS = 96;
    % �������׵�����
    lambdaK = [zeros(7,1);0.20;0.18;0.30;0.23;0.29;0.19;0.22;0.25;0.20;0.11;0.13;0.16;0.15;0;0;0;0;0];
%     lambdaK = [2;zeros(24,1)];
%��ǰһ��Сʱ(�Ȳ���)
%     lambdaK = [zeros(7,1);0.20;0.18;0.30;0.23;0.29;0.19;0.22;0.25;0.20;0.11;0.13;0.16;0.15;zeros(5,1)];
    lambdaK = nofStation * 12 * lambdaK;% 12�����ȡ�ģ�ʹ�����lambdaΪ13.6
    t = 4*(0:24);
    i = 1:SLOTS;
    % ���Բ�ֵ
    lambdaK = interp1(t,lambdaK,i,'linear');
   
    
    fid = fopen('.\param\lambdaK.txt', 'wt');
    
    fprintf(fid, '%.5f\n',lambdaK);
    
    fclose(fid);
end

%% ���ú㶨 lambda,��ʱ���endTime������20Сʱ
if lambdaMode == 1
    SLOTS = 4 * endTime;
    
    lambdaK = lambda * nofStation * ones(1, SLOTS);
    
    fid = fopen('.\param\lambdaK.txt', 'wt');
    
    fprintf(fid, '%.5f\n',lambdaK);
    
    fclose(fid);
    
end

% plot(lambdaK);hold on;
% plot(lambda_forecast);
%% д��������
    SLOTS = 4 * endTime;
    
    base_price = 1 * ones(1, SLOTS);
    
    fid = fopen('.\param\basePrice.txt', 'wt');
    
    fprintf(fid, '%.5f\n',base_price);
    
    fclose(fid);
