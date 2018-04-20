function [  ] = test_diff_policy_compare()

M=20;%M
Dm=10;%s
t=0.9;%s
T=1;%s
c=10*10^2;%bit
Ep=1*10^(-8);
for i=1:1:M
    diff_policy_compare_Rician(i,Dm,t,T,c,Ep,'M');
end

end