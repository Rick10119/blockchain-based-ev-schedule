% to give the J
close;
nofStation = 9;
m = 12 * nofStation; % max cars
n = 6 * nofStation; % slots
R = 30; % revenue
w = 6;
J = 0.04;
mu = 0.5;
t0 = 15;

t_davidson = [];
t_MMn = [];
t_MMnm = [];
t_MMnm1 = [];
delta_c = [];
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
    
%     t_MMnm = [t_MMnm;1/mu + W_q_MMnm*0.8];
    t_MMnm = [t_MMnm;tq_MMnm(lambda, mu, n, m)];
    t_MMnm1 = [t_MMnm1;tq_MMnm(lambda, mu, n-1, m-1)];
    
    delta_c = [delta_c;(tq_MMnm(lambda, mu, n-1, m-1) - tq_MMnm(lambda, mu, n, m)) * lambda];
    
end
% ��ȡ���ڵ�ϵͳ
% load('sim-result-l1.mat');
% t_queue =  [t0 * t_davidson,t0 * t_MMn,t0 * t_MMnm,expectTime'];
lambda = 0.5:h:n*mu - h;
linewidth = 2;
% lambda = lambda * 3;
% plot(lambda,t0 * t_davidson,'LineWidth',linewidth);
% hold on
% plot(lambda,t0 * t_MMn,'LineWidth',linewidth);

hold on
plot(lambda,t0 * t_MMnm,'LineWidth',linewidth);

hold on
plot(lambda,t0 * t_MMnm1,'LineWidth',linewidth);
% 
% hold on
% plot(lambda,expectTime','LineWidth',linewidth);

hold on
plot(lambda,delta_c,'LineWidth',linewidth);



%%

t1 = title('t-queue','FontSize',24);
x1 = xlabel('lambda','FontSize',18);          %����������tex����
y1 = ylabel('t_s','FontSize',18);

% legend('t-Davidson','t-MMn','t-MMnm',"t-sim");
legend('t-MMnm','t-MMnm1',"t-sim-1");
saveas(gcf,'queue-time.jpg'); %���浱ǰ���ڵ�ͼ��66666666



  