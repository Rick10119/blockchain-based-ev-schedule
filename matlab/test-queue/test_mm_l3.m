
% to give the J
% ����3���վ�ĸ������ߣ�ֻ���Ǿ��롢mmnm����ֵ��mm3n3m����

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

%% ��ͼ
lambda = 0.5:h:n*mu-h;
linewidth = 2;

% plot(lambda,t0 * t_davidson,'LineWidth',linewidth);
% hold on
% plot(lambda,t0 * t_MMn,'LineWidth',linewidth);
% ����ֵ
hold on
plot(lambda,t0 * t_MMnm,'LineWidth',linewidth);

% ��ȡ3�ڵ�ϵͳ��1������վ
load('sim-distance-best-l3.mat');
hold on
lambda = 0.8 : 0.2 : 3;
plot(3*lambda,expectTime','LineWidth',linewidth);

% ��ȡ3�ڵ�ϵͳ��ֻȥ����ĳ��վ
load('sim-distance-l3.mat');
hold on
lambda = 0.8:0.2:3;
plot(3*lambda,expectTime','LineWidth',linewidth);

% ��ȡ3�ڵ�ϵͳ����ѯ�Ŷ�ʱ��
load('sim-query-l3.mat');
hold on
lambda = 0.8:0.2:3;
plot(3*lambda,expectTime','LineWidth',linewidth);


t1 = title('t-queue','FontSize',24);
x1 = xlabel('lambda','FontSize',18);          %����������tex����
y1 = ylabel('t_s','FontSize',18);

% legend('t-Davidson','t-MMn','t-MMnm',"t-sim");
legend('t-MMnm',"sim-distance-best-l3","t-distance-l3","t-query-l3");
saveas(gcf,'queue-time-l3.jpg'); %���浱ǰ���ڵ�ͼ��66666666
