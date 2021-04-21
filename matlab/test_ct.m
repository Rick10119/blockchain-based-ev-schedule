% ���������з��棬����ȡ�����������
clc;clear;close;
total_date = 1;%�ܹ���������

% �����java�Ĳ���
endTime = 24;%ÿ�εķ���ʱ�������������������24������ͳһ20
nofStation = 1;%���վ����
movementModel = " ChangeTime";

%�洢��������
sim_data = [];
NofEV = repmat(nofEV(0,0,0,0),[total_date,1]);
avg_ChargeTime = [];% ÿ���ƽ��ʱ��
deviationTime = [];
expectTime = [];% ÿ��ÿ��ʱ�ε�ƽ��ʱ��(���յ���ʱ���¼)


% д���綯�����ֲ�����lambdaK.txt
lambdaMode = 2;% 1�Ǻ㶨��2�����׵ķ�ʱlambda����������lambda
system("javac param/QueryTimeSet.java -encoding utf-8");
system(".\one-compile.bat");
%

charge_profile;
 % ��һ���ʼ��Ԥ��ʱ��Ϊ0
 nday = 20;
lambda_forecast = zeros(96, 1);
lambda_history = zeros(96, nday);
queueTime_history = zeros(96,1);
avg_queueTime_history = zeros(96,1);
count_buffer = zeros(96, 1);
handle_arrive_rate;


%%
for date = 1:total_date
    
    
    disp("���з��棺 " + date +"/" + total_date);
    % ���з��棬ÿһ��ѭ����һ���������������
    command = "java param/QueryTimeSet " + endTime +" "+nofStation + " "+movementModel;
    system(command, "-echo");
    
    %
    command = ".\one.bat   -b 1 param/newSetting.txt";
    system(command, "-echo");
    
    % ��ȡtxt�ļ�
    sim_data = load('.\reports\default_scenario_ChargingReport.txt');
    
    % ������ز���
    
    % ����һ�� sim_data���������ָ�꣬�򵥴���
    
    handle_arrive_rate;
    
    %% ͳ�Ƴ�������
%     % 1�ĸ�����ʵ����Ҳ���ܵĳ�����
%     if isempty(sim_data)
%         sim_data = [0 0 0 0];
%     end
%     NofEV(i) = nofEV(length(find(sim_data(:,2) == 1)), ...,%�ܳ�����
%         length(find(sim_data(:,2) == 4)), ...,%���ɹ���
%         length(find(sim_data(:,2) == -1)), ...,%���ʧ����������1 - (4)
%         length(find(sim_data(:,2) == 2)));%��Ҫ�Ŷӵĳ�����,����
    %     %% ͳ�Ƴ��վ��������
    %     for j = 0 : nofStation-1
    %         rowNumber = find(sim_data(:,4) == j);
    %         eventTime = sim_data(rowNumber,3);
    %         queueLength = sim_data(rowNumber,5);
    %         stairs(eventTime, queueLength);
    %         hold on;
    %     end
    %     legend("cs0","cs1","cs2");


%%
expectTime = [expectTime, avg_queueTime_history];
avg_ChargeTime = [avg_ChargeTime, avg_queueTime_daywise];
end

%%
% meanChargeTime = mean(ChargeTime');


%%
save("sim-paper-l9.mat",'expectTime','avg_ChargeTime');
