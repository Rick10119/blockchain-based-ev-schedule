% 命令行运行仿真，并读取、处理仿真结果
clc;clear;close;
total_date = 1;%总共仿真天数

% 输入给java的参数
endTime = 24;%每次的仿真时长，如果用文献数据用24；否则统一20
nofStation = 1;%充电站个数
movementModel = " ChangeTime";

%存储仿真数据
sim_data = [];
NofEV = repmat(nofEV(0,0,0,0),[total_date,1]);
avg_ChargeTime = [];% 每天的平均时间
deviationTime = [];
expectTime = [];% 每天每个时段的平均时间(按照到达时间记录)


% 写进电动汽车分布，到lambdaK.txt
lambdaMode = 2;% 1是恒定；2是文献的分时lambda，不用设置lambda
system("javac param/QueryTimeSet.java -encoding utf-8");
system(".\one-compile.bat");
%

charge_profile;
 % 第一天初始化预测时间为0
 nday = 20;
lambda_forecast = zeros(96, 1);
lambda_history = zeros(96, nday);
queueTime_history = zeros(96,1);
avg_queueTime_history = zeros(96,1);
count_buffer = zeros(96, 1);
handle_arrive_rate;


%%
for date = 1:total_date
    
    
    disp("运行仿真： " + date +"/" + total_date);
    % 运行仿真，每一个循环是一组随机产生的汽车
    command = "java param/QueryTimeSet " + endTime +" "+nofStation + " "+movementModel;
    system(command, "-echo");
    
    %
    command = ".\one.bat   -b 1 param/newSetting.txt";
    system(command, "-echo");
    
    % 读取txt文件
    sim_data = load('.\reports\default_scenario_ChargingReport.txt');
    
    % 分析相关参量
    
    % 给定一组 sim_data，分析相关指标，简单处理
    
    handle_arrive_rate;
    
    %% 统计车辆个数
%     % 1的个数，实际上也是总的车辆数
%     if isempty(sim_data)
%         sim_data = [0 0 0 0];
%     end
%     NofEV(i) = nofEV(length(find(sim_data(:,2) == 1)), ...,%总车辆数
%         length(find(sim_data(:,2) == 4)), ...,%充电成功数
%         length(find(sim_data(:,2) == -1)), ...,%充电失败数，等于1 - (4)
%         length(find(sim_data(:,2) == 2)));%需要排队的车辆数,等于
    %     %% 统计充电站的相关情况
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
