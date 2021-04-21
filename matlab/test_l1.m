% 命令行运行仿真，并读取、处理仿真结果
clc;clear;
sim_times = 100;%每个lambda的仿真次数

% 输入给java的参数
endTime = 24;%每次的仿真时长，如果用文献数据用24
nofStation = 1;%充电站个数
nofS = 1;%模拟充电站个数
movementModel = " DistanceFirst";

%存储仿真数据
sim_data = [];
NofEV = repmat(nofEV(0,0,0,0),[sim_times,1]);
expectTime = [];
deviationTime = [];


% 写进电动汽车分布，到lambdaK.txt
lambdaMode = 1;% 1是恒定；2是文献的分时lambda
system("javac param/QueryTimeSet.java -encoding utf-8");
system(".\one-compile.bat");
%%
%  lambda = 3;lambda要手动调
for lambda = 0.5*nofS : 0.1*nofS : 2.9*nofS
    charge_profile;
    ChargingTime = [];
    for i = 1:sim_times
        
        
        
        % 运行仿真，每一个循环是一组随机产生的汽车
        command = "java param/QueryTimeSet " + endTime +" "+nofStation + movementModel;
        system(command, "-echo");
        
        % 显示进度
        disp("运行仿真： i/lambda: " + i +"/" + lambda);
        
        command = ".\one.bat   -b 1 param/newSetting.txt";
        system(command, "-echo");
        
        % 读取txt文件
        sim_data = load('.\reports\default_scenario_ChargingReport.txt');
        
        % 分析相关参量
        
        % 给定一组 sim_data，分析相关指标，简单处理
        
        %% 统计车辆个数
            % 1的个数，实际上也是总的车辆数
            if isempty(sim_data)
                sim_data = [0 0 0 0];
            end
            NofEV(i) = nofEV(length(find(sim_data(:,2) == 1)), ...,%总车辆数
                length(find(sim_data(:,2) == 4)), ...,%充电成功数
                length(find(sim_data(:,2) == -1)), ...,%充电失败数，等于1 - (4)
                length(find(sim_data(:,2) == 2)));%需要排队的车辆数,等于
        %     %% 统计充电站的相关情况
        %     for j = 0 : nofStation-1
        %         rowNumber = find(sim_data(:,4) == j);
        %         eventTime = sim_data(rowNumber,3);
        %         queueLength = sim_data(rowNumber,5);
        %         stairs(eventTime, queueLength);
        %         hold on;
        %     end
        %     legend("cs0","cs1","cs2");
        
        
        %% 统计充电时间（加上排队时间）
        % 总共要统计 Success辆
        count = 0;
        chargingTime = zeros(NofEV(i).Success, 1);
        for k = min(sim_data(:,1)) : max(sim_data(:,1))
            % k是车辆index。row第一次在到达充电站出现，第二次在是否成功出现。因此对第二次进行判断
            % 取出车辆k对应的号码
            rowNumber = find(sim_data(:,1) == k);
            % 舍弃还没充完的车辆
            if length(rowNumber) <3
                continue;
            end
            
            count = count + 1;
            chargingTime(count) = sim_data(rowNumber(3),3) - sim_data(rowNumber(2),3);
            
        end
        NofEV(i).ChargingTime = chargingTime;
        ChargingTime = [ChargingTime;chargingTime];
    end

%%
expectTime = [expectTime, mean(ChargingTime)];
deviationTime = [deviationTime, std(ChargingTime)];
end
%%
save("sim-l1.mat",'expectTime', 'deviationTime');
