% ���������з��棬����ȡ�����������
clc;clear;
sim_times = 100;%ÿ��lambda�ķ������

% �����java�Ĳ���
endTime = 24;%ÿ�εķ���ʱ�������������������24
nofStation = 1;%���վ����
nofS = 1;%ģ����վ����
movementModel = " DistanceFirst";

%�洢��������
sim_data = [];
NofEV = repmat(nofEV(0,0,0,0),[sim_times,1]);
expectTime = [];
deviationTime = [];


% д���綯�����ֲ�����lambdaK.txt
lambdaMode = 1;% 1�Ǻ㶨��2�����׵ķ�ʱlambda
system("javac param/QueryTimeSet.java -encoding utf-8");
system(".\one-compile.bat");
%%
%  lambda = 3;lambdaҪ�ֶ���
for lambda = 0.5*nofS : 0.1*nofS : 2.9*nofS
    charge_profile;
    ChargingTime = [];
    for i = 1:sim_times
        
        
        
        % ���з��棬ÿһ��ѭ����һ���������������
        command = "java param/QueryTimeSet " + endTime +" "+nofStation + movementModel;
        system(command, "-echo");
        
        % ��ʾ����
        disp("���з��棺 i/lambda: " + i +"/" + lambda);
        
        command = ".\one.bat   -b 1 param/newSetting.txt";
        system(command, "-echo");
        
        % ��ȡtxt�ļ�
        sim_data = load('.\reports\default_scenario_ChargingReport.txt');
        
        % ������ز���
        
        % ����һ�� sim_data���������ָ�꣬�򵥴���
        
        %% ͳ�Ƴ�������
            % 1�ĸ�����ʵ����Ҳ���ܵĳ�����
            if isempty(sim_data)
                sim_data = [0 0 0 0];
            end
            NofEV(i) = nofEV(length(find(sim_data(:,2) == 1)), ...,%�ܳ�����
                length(find(sim_data(:,2) == 4)), ...,%���ɹ���
                length(find(sim_data(:,2) == -1)), ...,%���ʧ����������1 - (4)
                length(find(sim_data(:,2) == 2)));%��Ҫ�Ŷӵĳ�����,����
        %     %% ͳ�Ƴ��վ��������
        %     for j = 0 : nofStation-1
        %         rowNumber = find(sim_data(:,4) == j);
        %         eventTime = sim_data(rowNumber,3);
        %         queueLength = sim_data(rowNumber,5);
        %         stairs(eventTime, queueLength);
        %         hold on;
        %     end
        %     legend("cs0","cs1","cs2");
        
        
        %% ͳ�Ƴ��ʱ�䣨�����Ŷ�ʱ�䣩
        % �ܹ�Ҫͳ�� Success��
        count = 0;
        chargingTime = zeros(NofEV(i).Success, 1);
        for k = min(sim_data(:,1)) : max(sim_data(:,1))
            % k�ǳ���index��row��һ���ڵ�����վ���֣��ڶ������Ƿ�ɹ����֡���˶Եڶ��ν����ж�
            % ȡ������k��Ӧ�ĺ���
            rowNumber = find(sim_data(:,1) == k);
            % ������û����ĳ���
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
