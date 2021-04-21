function t = tq_MMnm(lambda, mu, n, m)

ro1 = lambda/mu;
ro = lambda / mu/n;% utility

temp_k = zeros(1, n);
for k = 0:n-1
    temp_k(k+1) = ro1^k/(factorial(k));
end

%M/M/n/m
p0 = 1/ (sum(temp_k)+ ro1^n/factorial(n)/(1-ro)*(1-ro^(m-n+1)));
temp_pk = zeros(1,n);
for k = 0:n-1
    temp_pk(k+1) = (n-k)*ro1^k/factorial(k)*p0;
end
W_q_MMnm = n^n*ro^(n+1)*p0*(1-(m-n+1)*ro^(m-n)+(m-n)*ro^(m-n+1))/(factorial(n)*(1-ro)^2*mu*(n-sum(temp_pk)));

t = 1/mu + W_q_MMnm;

end

