lambdaBar = 8/3;
m = 6;% number of charging slots
L = 3;
R = 30;
w = 6;
J = 0.04;
p_b1 = [];% 补偿充电站
p_b2 = [];% 补偿排队的人
p_t = [];
p_aver = [];
%%
p_b1 = [];% 补偿充电站
p_b2 = [];% 补偿排队的人
p_t = [];
p_aver = [];
for lambdaB =0:1:m-lambdaBar-1
    
    p_b1 = [p_b1;R*(L-1)/L*lambdaBar/(m-lambdaB)];
    p_b2 = [p_b2;w*J/L*(lambdaBar)^2/(m-lambdaB-lambdaBar)^2];
    p_t = [p_t;w*J*lambdaBar/(m-lambdaB-lambdaBar)];
%     p_t2 = [p_t2;lambda/(m-r-lambda)-r*(2*r+3*lambda-2*m)/(m-r-lambda)^2];
%     p_aver = [p_aver;lambda^2/(m-r-lambda)/(lambda + r)];
    
end


%%
lambdaB =0:1:m-lambdaBar-1;
linewidth = 2;
plot(lambdaB,p_b1,'LineWidth',linewidth);
 hold on
 plot(lambdaB,p_b2,'LineWidth',linewidth);
P = [p_b1,p_b2];
% hold on
%  plot(lambdaB,p_t,'LineWidth',linewidth);


t1 = title('预约价格随预约量变化（给定预测车流）','FontSize',24);
x1 = xlabel('预约量（车流/单位时间）','FontSize',18);          %轴标题可以用tex解释
y1 = ylabel('价格（单位价格）','FontSize',18);
t1.FontName = '宋体';                   %标题格式设置为宋体，否则会乱码
x1.FontName = '宋体'; 
y1.FontName = '宋体'; 
 legend('补偿充电站收益','补偿排队时间');
saveas(gcf,'price3.jpg'); %保存当前窗口的图像66666666



