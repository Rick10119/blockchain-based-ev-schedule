
% to give the J
% 测试3充电站的各种曲线：只考虑距离、mmnm理论值、mm9n9m曲线

m = 108; % max cars
n = 54; % slots
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
linewidth = 1.3;
%% mmnm理论值
% hold on
% plot(lambda,t0 * t_MMnm,'LineWidth',linewidth);

%% 9节点系统最优值
load('sim-distance-best-l9.mat');
lambda = 0.8:0.2:3;
waitTime = expectTime;

plot(9*lambda, waitTime,'LineWidth',linewidth);
hold on;


% 读取9节点系统
%% 9站，直接去最近的充电站
% load('sim-distance-l9.mat');
% lambda = 0.8:0.2:3;
% waitTime = expectTime;
% 
% plot(9*lambda, waitTime,'LineWidth',linewidth);
% hold on;

%% 画queryTime的9站
% load('sim-query1.mat');
% lambda = 0.8:0.2:1.4;
% waitTime = expectTime;
% load('sim-query2.mat');
% waitTime = [waitTime,expectTime];
% lambda = [lambda,1.6:0.2:2.2];
% load('sim-query3.mat');
% waitTime = [waitTime,expectTime];
% lambda = [lambda,2.4:0.2:2.6];
% load('sim-query4.mat');
% waitTime = [waitTime,expectTime];
% lambda = [lambda,2.8:0.2:3.0];
load('sim-query-l9-over.mat');
lambda = 0.8:0.2:4;
plot(9 * lambda, expectTime,'LineWidth',linewidth);

%% 只看最短排队时间

% load('sim-query-l9-tf.mat');
% lambda = 1:0.4:3;
% plot(9 * lambda, expectTime,'LineWidth',linewidth);
% hold on;

%% 只看距离
% load('sim-query-l9-df2.mat');
% lambda = 1:0.4:3;
% plot(9 * lambda, expectTime,'LineWidth',linewidth);

%% 给定车辆数
load('sim-queue-test-l9-15.mat');
lambda = 1:2:27;
plot(lambda, expectTime,'LineWidth',linewidth);

load('sim-queue-test-l9-60.mat');
lambda = 1:2:27;
plot(lambda(1:end-1), diff(expectTime),'LineWidth',linewidth);
%%

t1 = title('t-queue','FontSize',24);
x1 = xlabel('lambda','FontSize',18);          %锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷tex锟斤拷锟斤拷
y1 = ylabel('t_s','FontSize',18);

% legend('t-Davidson','t-MMn','t-MMnm',"t-sim");
legend("t-sim-best-9","t-query","t-sim-9-15","t-sim-9-60");
saveas(gcf,'queue-time-9-df-qt.jpg'); %锟斤拷锟芥当前锟斤拷锟节碉拷图锟斤拷66666666
