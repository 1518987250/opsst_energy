function [  ] = test_diff_policy_compare()

M=5;%M
Dm=30;%s
t=0.9;%s
T=1;%s
c=10*10^2;%bit
Ep=1*10^(-8);
for i=1:Dm
    diff_policy_compare_Rician(M,i,t,T,c,Ep,'Dm');
end

end