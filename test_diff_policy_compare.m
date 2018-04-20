function [  ] = test_diff_policy_compare()

M=5;%M
Dm=10;%s
t=0.9;%s
T=1;%s
c=50*10^2;%bit
Ep=1*10^(-8);
for i=100:100:c
    diff_policy_compare_Rician(M,Dm,t,T,i,Ep,'c');
end

end