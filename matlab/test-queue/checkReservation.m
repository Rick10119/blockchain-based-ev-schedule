lambdaBar = 8/3;
m = 6;% number of charging slots
L = 3;
R = 30;
w = 6;
J = 0.04;
p_b1 = [];% �������վ
p_b2 = [];% �����Ŷӵ���
p_t = [];
p_aver = [];
%%
p_b1 = [];% �������վ
p_b2 = [];% �����Ŷӵ���
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


t1 = title('ԤԼ�۸���ԤԼ���仯������Ԥ�⳵����','FontSize',24);
x1 = xlabel('ԤԼ��������/��λʱ�䣩','FontSize',18);          %����������tex����
y1 = ylabel('�۸񣨵�λ�۸�','FontSize',18);
t1.FontName = '����';                   %�����ʽ����Ϊ���壬���������
x1.FontName = '����'; 
y1.FontName = '����'; 
 legend('�������վ����','�����Ŷ�ʱ��');
saveas(gcf,'price3.jpg'); %���浱ǰ���ڵ�ͼ��66666666



