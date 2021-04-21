classdef nofEV
    
    properties
     Total %总车辆数
     Success 
     Fail %充电失败数，等于1 - (4)
     Queued %需要排队的车辆数,等于
     ChargingTime % 对排队时间的统计
        
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