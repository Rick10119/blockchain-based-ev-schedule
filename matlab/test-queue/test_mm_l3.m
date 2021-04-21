
% to give the J
% 测试3充电站的各种曲线：只考虑距离、mmnm理论值、mm3n3m曲线

m = 36; % max cars
n = 18; % slots
R = 30; % revenue
w = 6;
J = 0.04;
mu = 0.5;
t0 = 15;

t_davidson = [];
t_MMn = [];
t_MMnm = [];
h = 0.1;


%%
for lambda = 0.5:h:n*mu-h

ro1 = lambda/mu;
    ro = lambda / mu/n;% utility

    % Davidson
    t_davidson = [t_davidson;1/mu + 1/mu * J * ro/(1 - ro)];
    
    % M/M/n
    temp_k = zeros(1, n);
    for k = 0:n-1
        temp_k(k+1) = ro1^k/(factorial(k));
    end
       
    p0 = 1/ (sum(temp_k)+ ro1^n/factorial(n)/(1-ro));
    W_q_MMn = ro1^n*p0/(mu*n*factorial(n)*(1-ro)^2);
    
    t_MMn = [t_MMn;1/mu + W_q_MMn];
    
    
    %M/M/n/m  
    p0 = 1/ (sum(temp_k)+ ro1^n/factorial(n)/(1-ro)*(1-ro^(m-n+1)));
    temp_pk = zeros(1,n);
    for k = 0:n-1
        temp_pk(k+1) = (n-k)*ro1^k/factorial(k)*p0;
    end
    W_q_MMnm = n^n*ro^(n+1)*p0*(1-(m-n+1)*ro^(m-n)+(m-n)*ro^(m-n+1))/(factorial(n)*(1-ro)^2*mu*(n-sum(temp_pk)));
    
    t_MMnm = [t_MMnm;1/mu + W_q_MMnm*0.8];
    
end

%% 作图
lambda = 0.5:h:n*mu-h;
linewidth = 2;

% plot(lambda,t0 * t_davidson,'LineWidth',linewidth);
% hold on
% plot(lambda,t0 * t_MMn,'LineWidth',linewidth);
% 理论值
hold on
plot(lambda,t0 * t_MMnm,'LineWidth',linewidth);

% 读取3节点系统，1个大充电站
load('sim-distance-best-l3.mat');
hold on
lambda = 0.8 : 0.2 : 3;
plot(3*lambda,expectTime','LineWidth',linewidth);

% 读取3节点系统，只去最近的充电站
load('sim-distance-l3.mat');
hold on
lambda = 0.8:0.2:3;
plot(3*lambda,expectTime','LineWidth',linewidth);

% 读取3节点系统，查询排队时间
load('sim-query-l3.mat');
hold on
lambda = 0.8:0.2:3;
plot(3*lambda,expectTime','LineWidth',linewidth);


t1 = title('t-queue','FontSize',24);
x1 = xlabel('lambda','FontSize',18);          %锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷tex锟斤拷锟斤拷
y1 = ylabel('t_s','FontSize',18);

% legend('t-Davidson','t-MMn','t-MMnm',"t-sim");
legend('t-MMnm',"sim-distance-best-l3","t-distance-l3","t-query-l3");
saveas(gcf,'queue-time-l3.jpg'); %锟斤拷锟芥当前锟斤拷锟节碉拷图锟斤拷66666666
