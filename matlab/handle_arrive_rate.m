% ͳ�Ƴ����������������lambda
% ͳ��ÿ��ʱ�γ����ĳ����������ó�絽��������ʾ��Ҳ����chargingStatus = 1

% Ԥ���lambdaֵ����˼��Ԥ���ʱ�λ���ֶ��ٳ�����


% ��һ���ʼ��Ԥ��ʱ��Ϊ0

% ͳ��ÿ��ʱ��Σ�������Ϣ
if isempty(sim_data)
    sim_data = [0 0 0 0];
end

for i = 1:length(sim_data(:,1))
    if(sim_data(i,2)==1) %�����¼�
        %����ʱ����Ϣ��¼��buffer��,����96ʱ��ε���ô���ǣ��Ȳ����ǰ�
        if ceil(sim_data(i,3)/15) > 96
            break;
        end
        rowNumber = find(sim_data(:,1) == sim_data(i,1));
        
        % ������û����ĳ���
        if sim_data(rowNumber(2),2) ~= -1 && length(rowNumber) <3
            continue;
        end
        %������ʧ�ܵĳ���
        % ��¼������Ϣ
        count_buffer(ceil(sim_data(i,3)/15)) = count_buffer(ceil(sim_data(i,3)/15)) + 1;
        
        % ��¼�Ŷ�ʱ�䣬����Ӧ�ļ�¼�����Ŷ�ʱ��
        
        queueTime_history(ceil(sim_data(i,3)/15)) = queueTime_history(ceil(sim_data(i,3)/15)) + sim_data(rowNumber(3),3) - sim_data(rowNumber(2),3);
        
        
    end
end
% �����Ŷ�ʱ����Ե��ﳵ���������õ�ƽ�����ʱ�䣨�����Ŷӣ�
for T = 1:96
    if count_buffer(T)==0
        avg_queueTime_history(T) = 30.0;% ����Ҫ�Ŷӣ�30���ӳ���
    else
        avg_queueTime_history(T) = queueTime_history(T)/count_buffer(T);
    end
end


% �ܹ�ƽ���Ŷ�ʱ��
avg_queueTime_daywise = sum(queueTime_history)/sum(count_buffer);






