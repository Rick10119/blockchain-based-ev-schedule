classdef nofEV
    
    properties
     Total %�ܳ�����
     Success 
     Fail %���ʧ����������1 - (4)
     Queued %��Ҫ�Ŷӵĳ�����,����
     ChargingTime % ���Ŷ�ʱ���ͳ��
        
    end
    
    properties(Constant)
%         lambda = 12;% unit time cost
        energy = 30;% energy to charge, kWh
%         J = 0.05;% param of the queue
        
    end
    
    % constructor
    methods
        function obj = nofEV(Total,Success,Fail,Queued)
            obj.Total = Total;
            obj.Success = Success;
            obj.Fail = Fail;
            obj.Queued = Queued;
            
        end
    end
    
    
end