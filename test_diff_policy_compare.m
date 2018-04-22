function [  ] = test_diff_policy_compare()

M=5;%M
Dm=10;%s
t=0.9;%s
T=1;%s
c=25*10^2;%bit
Ep=1*10^(-8);
for i=100:50:c
    diff_policy_compare_Rayleigh(M,Dm,t,T,i,Ep,'c');
end

end