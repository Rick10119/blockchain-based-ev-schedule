% 统计出行情况，用来更新lambda
% 统计每个时段车辆的出行数量，用充电到达数量表示，也就是chargingStatus = 1

% 预测的lambda值，意思是预测该时段会出现多少车辆。


% 第一天初始化预测时间为0

% 统计每个时间段，到达信息
if isempty(sim_data)
    sim_data = [0 0 0 0];
end

for i = 1:length(sim_data(:,1))
    if(sim_data(i,2)==1) %到达事件
        %根据时段信息记录在buffer中,超过96时间段的怎么考虑？先不考虑吧
        if ceil(sim_data(i,3)/15) > 96
            break;
        end
        rowNumber = find(sim_data(:,1) == sim_data(i,1));
        
        % 舍弃还没充完的车辆
        if sim_data(rowNumber(2),2) ~= -1 && length(rowNumber) <3
            continue;
        end
        %处理充电失败的车辆
        % 记录到达信息
        count_buffer(ceil(sim_data(i,3)/15)) = count_buffer(ceil(sim_data(i,3)/15)) + 1;
        
        % 记录排队时间，给相应的记录加上排队时间
        
        queueTime_history(ceil(sim_data(i,3)/15)) = queueTime_history(ceil(sim_data(i,3)/15)) + sim_data(rowNumber(3),3) - sim_data(rowNumber(2),3);
        
        
    end
end
% 用总排队时间除以到达车辆数量，得到平均充电时间（加上排队）
for T = 1:96
    if count_buffer(T)==0
        avg_queueTime_history(T) = 30.0;% 不需要排队，30分钟充完
    else
        avg_queueTime_history(T) = queueTime_history(T)/count_buffer(T);
    end
end


% 总共平均排队时间
avg_queueTime_daywise = sum(queueTime_history)/sum(count_buffer);






