function [ ] = diff_policy_compare_Rayleigh(M,Dm,t,T,c,Ep,str)

%global Rth;%全局变量

g=4;%功率最大增益是4
%SNR=0.1;%信噪比是-10dB
%SNR=0.08;%信噪比是-10.9691dB
BW=1*10^6;%频率是1MHZ
fc=1;%方差等于1
%求最大速率Rmax
%Rmax=BW*log2(1+P*g/N0W);%bps
%最大速率的累积函数

%设置初始值
%P=0.1;%W
P=0.1;%W
N0W=1;%噪声功率
Min_receive_power=10^(-1);%最小可接收功率
%Min_receive_power=2^(c/BW)*N0W-1;%最小可接收功率

Eninit=200000;%J
TotalTime=259200;%S
numberc=5;%5种情况
Z=floor(Dm/t);%表示最后的延迟时间序号
for i=1:numberc
     RemainEn(i)=Eninit;%记录发送器的剩余能量,单位是J
     Duration(i)=0;%记录持续时间,单位是S
     TransData(i)=0;%记录传输的数据,单位是bit    
     MaxLossData(i)=0;%记录最大丢失数据
     MinLossData(i)=0;%记录最小丢失数据
     fcLossData(i)=0;%记录丢失数据方差
     TranDataRatio(i)=0;%记录传递数据比例
     detectiontime(i)=0;%记录实际侦测次数
     round(i)=0;%轮次
 end
%第一种情况:放过k个后见优则录的规则进行传输
it=1;%模拟的轮次
itLossData=0;%丢失数据的轮次
sumLossData=0;
formLossData=0;%上一轮没有传输的数据
     TransR=0;
     TransT=0;
     TransP=0;
while(Duration(1)<TotalTime)
    minP=P;%初始最小功率为P
    i=1;
    ob=floor(sqrt(Z))-1;
    while(i<=ob)%前面（根号Z-1）轮可以进行速率判断,得到最大的速率  
       rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
       while(rnd_g>g)%若超出最大值,则重新生成
           rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
       end 
       TransP=Min_receive_power/rnd_g;%传输功率
       if(TransP<minP)
         minP=TransP;
       end
       i=i+1;
    end
    while(i<Z)%与前k个数据进行比较，若速率大于前k的最大速率，则传输数据
        rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        while(rnd_g>g)%若超出最大值,则重新生成
            rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        end
        TransP=Min_receive_power/rnd_g;%传输功率
        if(TransP<minP)
            TransR=BW*log2(1+TransP*rnd_g/N0W ); %生成传输速率
            detectiontime(1)=detectiontime(1)+i; %返回实际侦测次数
            break;
        end
        i=i+1;   
    end
    if(i==Z)%到达传输延迟，必须传输
    	rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        while(rnd_g>g)%若超出最大值,则重新生成
           rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        end
        TransP=P;%传输功率  
        TransR=BW*log2(1+rnd_g*P/N0W ); %生成传输速率
        detectiontime(1)=detectiontime(1)+i; %返回实际侦测次数
    end   
    if(RemainEn(1)<(i*Ep+TransP*T))%剩余能量不够,则结束
        break;
    end 
    producedata=c*(i*t+T);%产生的数据
    if (formLossData~=0)
        if (formLossData/c<=Dm-TransT*t)%如果这些数据没有超过延迟期限
            producedata=formLossData+producedata;%加上上轮未传完的且未超过延迟的数据
        else%如果有数据超过延迟期限，则丢弃超过延迟期限的数据
            producedata=c*(Dm-TransT*t)+producedata;%加上上轮未传完的且未超过延迟的数据
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-TransT*t);%丢失的数量是上一轮未传完且本轮不能传输的数据
            sumLossData=sumLossData+LossData(itLossData);% 累加丢失数据
        end
    end  
    
    transdata=TransR*T;%能传输的数据
    
    if (producedata>transdata)%这段时间内产生的数据更多
       TransData(1)=TransData(1)+transdata;    %只能传输这么多数据
       formLossData=producedata-transdata;%存在这轮没有传输的数据留到下一轮
    else%这段时间内能产生的数据更多,但没有足够的数据可传输
        TransData(1)=TransData(1)+producedata;
        formLossData=0;%这一轮没有不传输的数据
    end
    Duration(1)=Duration(1)+(i*t+T);%等待时间加传输时间就是本轮持续时间
    RemainEn(1)=RemainEn(1)-M*((i*Ep+TransP*T));%本轮能耗是侦测能耗加传输能耗
    round(1)=it*Z;%返回总侦测次数
    it=it+1;
end
AveTransData(1)=TransData(1)/Duration(1);%平均数据传输
TranDataRatio(1)=(TransData(1))/(c*Duration(1));%传递数据比例
%结束后计算平均轮次时间和丢失数据的轮次,最大值,最小值,平均值,方差
TurnLossData(1)=itLossData;
AveSchedule(1)=(Duration(1)-(it-1)*T)/(it-1);
AveLossData(1)=sumLossData/Duration(1);%平均每秒丢失数据
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%丢失数据平均值
    fcLossData(1)=(LossData(1)-Ave)^2;
    MaxLossData(1)=LossData(1);%最大值
    MinLossData(1)=LossData(1);%最小值
    for i=2:itLossData
        if (LossData(i)>MaxLossData(1))
            MaxLossData(1)=LossData(i);
        end
        if(LossData(i)<MinLossData(1))
            MinLossData(1)=LossData(i);
        end
        fcLossData(1)=fcLossData(1)+(LossData(i)-Ave)^2;
    end
    fcLossData(1)=fcLossData(1)/itLossData;
end
%第一种情况:放过k个后见优则录的规则进行传输,结束
%第二种情况:第一次侦测数据后传输
it=1;%模拟的轮次
itLossData=0;%丢失数据的轮次
sumLossData=0;
formLossData=0;%上一轮没有传输的数据
TransR=0;
TransT=0;
TransP=0;
while(Duration(2)<TotalTime)
%     minP=P;%初始最小功率为P
    i=1;
    rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
    while(rnd_g>g)%若超出最大值,则重新生成
        rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
    end
    TransP=Min_receive_power/rnd_g;%传输功率
    TransR=BW*log2(1+TransP*rnd_g/N0W ); %生成传输速率
    detectiontime(2)=detectiontime(2)+1; %返回实际侦测次数
    if(RemainEn(2)<(i*Ep+TransP*T))%剩余能量不够,则结束
         break;
    end 
    producedata=c*(i*t+T);%产生的数据
    if (formLossData~=0)
        if (formLossData/c<=Dm-TransT*t)%如果这些数据没有超过延迟期限
            producedata=formLossData+producedata;%加上上轮未传完的且未超过延迟的数据
        else%如果有数据超过延迟期限，则丢弃超过延迟期限的数据
            producedata=c*(Dm-TransT*t)+producedata;%加上上轮未传完的且未超过延迟的数据
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-TransT*t);%丢失的数量是上一轮未传完且本轮不能传输的数据
            sumLossData=sumLossData+LossData(itLossData);% 累加丢失数据
        end
    end  
    transdata=TransR*T;%能传输的数据
    if (producedata>transdata)%这段时间内产生的数据更多
       TransData(2)=TransData(2)+transdata;    %只能传输这么多数据
       formLossData=producedata-transdata;%存在这轮没有传输的数据留到下一轮
    else%这段时间内能产生的数据更多,但没有足够的数据可传输
        TransData(2)=TransData(2)+producedata;
        formLossData=0;%这一轮没有不传输的数据
    end
    Duration(2)=Duration(2)+(i*t+T);%等待时间加传输时间就是本轮持续时间
    RemainEn(2)=RemainEn(2)-M*(TransP*T);%本轮能耗是侦测能耗加传输能耗
    round(2)=it*1;%返回总侦测次数
    it=it+1;
end
AveTransData(2)=TransData(2)/Duration(2);%平均数据传输
TranDataRatio(2)=(TransData(2))/(c*Duration(2));%传递数据比例
%结束后计算平均轮次时间和丢失数据的轮次,最大值,最小值,平均值,方差
TurnLossData(2)=itLossData;
AveSchedule(2)=(Duration(2)-(it-1)*T)/(it-1);
AveLossData(2)=sumLossData/Duration(2);%平均每秒丢失数据
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%丢失数据平均值
    fcLossData(2)=(LossData(1)-Ave)^2;
    MaxLossData(2)=LossData(1);%最大值
    MinLossData(2)=LossData(1);%最小值
    for i=2:itLossData
        if (LossData(i)>MaxLossData(2))
            MaxLossData(2)=LossData(i);
        end
        if(LossData(i)<MinLossData(2))
            MinLossData(2)=LossData(i);
        end
        fcLossData(2)=fcLossData(2)+(LossData(i)-Ave)^2;
    end
    fcLossData(2)=fcLossData(2)/itLossData;
end
%第二种情况:放过k个后见优则录的规则进行传输,结束
%第三种情况:确定传输策略,即在最后的期限传输
it=1;%模拟的轮次
itLossData=0;%丢失数据的轮次
sumLossData=0;
while(Duration(3)<TotalTime)
    if(RemainEn(3)<Z*Ep+P*T)%剩余能量不足,生命结束
        break;
    end
    rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
    while(rnd_g>g)%若超出最大值,则重新生成
        rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
    end
    TransR=BW*log2(1+rnd_g*P/N0W ); %生成传输速率
    detectiontime(1)=detectiontime(1)+1; %返回实际侦测次数   
    producedata=c*(Z*t+T);%产生的数据
    transdata=TransR*T;%能传输的数据
    if (producedata>transdata)%这段时间内产生的数据更多
        TransData(3)=TransData(3)+transdata;
        itLossData=itLossData+1;
        LossData(itLossData)=producedata-transdata;%丢失的数量
        sumLossData=sumLossData+LossData(itLossData);% 累加丢失数据
    else%这段时间内能产生的数据更多,但没有足够的数据可传输
         TransData(3)=TransData(3)+producedata;
    end        
    Duration(3)=Duration(3)+Dm+T;%最大延迟时间加传输时间就是本轮持续时间
    RemainEn(3)=RemainEn(3)-M*(P*T);%本轮的能耗是传输能耗   
    round(3)=it*1;%返回总侦测次数
    it=it+1;
end
AveTransData(3)=TransData(3)/Duration(3);%平均数据传输
TranDataRatio(3)=(TransData(3))/(c*Duration(3));%传递数据比例
%结束后计算平均轮次时间和丢失数据的轮次,最大值,最小值,平均值,方差
TurnLossData(3)=itLossData;
AveSchedule(3)=(Duration(3)-(it-1)*T)/(it-1);
AveLossData(3)=sumLossData/Duration(3);%平均每秒丢失数据
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%丢失数据平均值
    fcLossData(3)=(LossData(1)-Ave)^2;
    MaxLossData(3)=LossData(1);%最大值
    MinLossData(3)=LossData(1);%最小值
    for i=2:itLossData
        if (LossData(i)>MaxLossData(3))
            MaxLossData(3)=LossData(i);
        end
        if(LossData(i)<MinLossData(3))
            MinLossData(3)=LossData(i);
        end
        fcLossData(3)=fcLossData(3)+(LossData(i)-Ave)^2;
    end
    fcLossData(3)=fcLossData(3)/itLossData;
end
%%第三种情况:确定传输策略,即在最后的期限传输,结束
%第四种情况:随机选择一个时间进行传输
it=1;%模拟的轮次
itLossData=0;%丢失数据的轮次
sumLossData=0;
formLossData=0;%上一轮没有传输的数据
while(Duration(4)<TotalTime)
    TransT=randi([1,Z]);%随机选择传输时间    
    rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
    while(rnd_g>g)%若超出最大值,则重新生成
        rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
    end   
    TransP=P;%传输功率
    TransR=BW*log2(1+rnd_g*TransP/N0W ); %生成传输速率
    detectiontime(4)=detectiontime(4)+1; %返回实际侦测次数
    if(RemainEn(4)<TransP*T)%剩余能量不足,生命结束
        break;
    end
    producedata=c*(TransT*t+T);%产生的数据
    if (formLossData~=0)
        if (formLossData/c<=Dm-TransT*t)%如果这些数据没有超过延迟期限
            producedata=formLossData+producedata;%加上上轮未传完的且未超过延迟的数据
        else%如果有数据超过延迟期限，则丢弃超过延迟期限的数据
            producedata=c*(Dm-TransT*t)+producedata;%加上上轮未传完的且未超过延迟的数据
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-TransT*t);%丢失的数量是上一轮未传完且本轮不能传输的数据
            sumLossData=sumLossData+LossData(itLossData);% 累加丢失数据
        end
    end  
    
    transdata=TransR*T;%能传输的数据
    
    if (producedata>transdata)%这段时间内产生的数据更多
       TransData(4)=TransData(4)+transdata;    %只能传输这么多数据
       formLossData=producedata-transdata;%存在这轮没有传输的数据留到下一轮
    else%这段时间内能产生的数据更多,但没有足够的数据可传输
        TransData(4)=TransData(4)+producedata;
        formLossData=0;%这一轮没有不传输的数据
    end      
    Duration(4)=Duration(4)+(TransT)*t+T;%等待时间加传输时间就是本轮持续时间
    RemainEn(4)=RemainEn(4)-M*((TransP*T));%本轮的能耗是传输能耗 
    round(4)=it*1;%返回总侦测次数
    it=it+1;
end
AveTransData(4)=TransData(4)/Duration(4);%平均数据传输
TranDataRatio(4)=(TransData(4))/(c*Duration(4));%传递数据比例
%结束后计算平均轮次时间和丢失数据的轮次,最大值,最小值,平均值,方差
TurnLossData(4)=itLossData;
AveSchedule(4)=(Duration(4)-(it-1)*T)/(it-1);
AveLossData(4)=sumLossData/Duration(4);%平均每秒丢失数据
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%丢失数据平均值
    fcLossData(4)=(LossData(1)-Ave)^2;
    MaxLossData(4)=LossData(1);%最大值
    MinLossData(4)=LossData(1);%最小值
    for i=2:itLossData
        if (LossData(i)>MaxLossData(4))
            MaxLossData(4)=LossData(i);
        end
        if(LossData(i)<MinLossData(4))
            MinLossData(4)=LossData(i);
        end
        fcLossData(4)=fcLossData(4)+(LossData(i)-Ave)^2;
    end
    fcLossData(4)=fcLossData(4)/itLossData;
end
%第四种情况:随机选择一个时间进行传输,结束
%第五种情况:观察37%的时间,记下最大值，如果后面某个速率超过这个最大值，则传输
it=1;%模拟的轮次
itLossData=0;%丢失数据的轮次
sumLossData=0;
formLossData=0;%上一轮没有传输的数据

while (Duration(5)<TotalTime)
    minP=P;%初始最小功率为P
    i=1;
    ob=floor(0.37*Dm/t);
    while(i<=ob)%观察37%的时间
         rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
         while(rnd_g>g)%若超出最大值,则重新生成
            rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
         end    
        TransP=Min_receive_power/rnd_g;%传输功率   
        if(TransP<minP)%如果当前这个功率更小，则记录下来
            minP=TransP;
        end   
        i=i+1;
    end
    %观察结束
    while(i<Z)
        rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        while(rnd_g>g)%若超出最大值,则重新生成
            rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        end    
        TransP=Min_receive_power/rnd_g;%传输功率
        if(TransP<minP)%如果当前这个功率更小，则记录下来
            TransR=BW*log2(1+Min_receive_power/N0W ); %生成传输速率
            detectiontime(5)=detectiontime(5)+i; %返回实际侦测次数
            break;
        end  
        i=i+1;
    end
    if(i==Z)%到达最大延迟,必须传输
        rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        while(rnd_g>g)%若超出最大值,则重新生成
           rnd_g=raylrnd(fc);%随机生成符合瑞利分布的增益值
        end    
        TransP=P;%传输功率  
        TransR=BW*log2(1+rnd_g*P/N0W ); %生成传输速率
        detectiontime(5)=detectiontime(5)+i; %返回实际侦测次数
    end
    if(RemainEn(5)<(i*Ep+TransP*T))%剩余能量不够,则结束
        break;
    end
    producedata=c*(i*t+T);%产生的数据
    
    if (formLossData~=0)
        if (formLossData/c<=Dm-i*t)%如果这些数据没有超过延迟期限
            producedata=formLossData+producedata;%加上上轮未传完的且未超过延迟的数据
        else%如果有数据超过延迟期限，则丢弃超过延迟期限的数据
            producedata=c*(Dm-i*t)+producedata;%加上上轮未传完的且未超过延迟的数据
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-i*t);%丢失的数量是上一轮未传完且本轮不能传输的数据
            sumLossData=sumLossData+LossData(itLossData);% 累加丢失数据
        end
    end  
    
    transdata=TransR*T;%能传输的数据
    
    if (producedata>transdata)%这段时间内产生的数据更多
       TransData(5)=TransData(5)+transdata;    %只能传输这么多数据
       formLossData=producedata-transdata;%存在这轮没有传输的数据留到下一轮
    else%这段时间内能产生的数据更多,但没有足够的数据可传输
        TransData(5)=TransData(5)+producedata;
        formLossData=0;%这一轮没有不传输的数据
    end     
   
    Duration(5)=Duration(5)+(i*t+T);%等待时间加传输时间就是本轮持续时间
    RemainEn(5)=RemainEn(5)-M*((i*Ep+TransP*T));%本轮能耗是侦测能耗加传输能耗
    round(5)=it*Z;%返回总侦测次数
    it=it+1;
end
AveTransData(5)=TransData(5)/Duration(5);%平均数据传输
TranDataRatio(5)=(TransData(5))/(c*Duration(5));%传递数据比例
%结束后计算平均轮次时间和丢失数据的轮次,最大值,最小值,平均值,方差
TurnLossData(5)=itLossData;
AveSchedule(5)=(Duration(5)-(it-1)*T)/(it-1);
AveLossData(5)=sumLossData/Duration(5);%平均每秒丢失数据
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%丢失数据平均值
    fcLossData(5)=(LossData(1)-Ave)^2;
    MaxLossData(5)=LossData(1);%最大值
    MinLossData(5)=LossData(1);%最小值
    for i=2:itLossData
        if (LossData(i)>MaxLossData(5))
            MaxLossData(5)=LossData(i);
        end
        if(LossData(i)<MinLossData(5))
            MinLossData(5)=LossData(i);
        end
        fcLossData(5)=fcLossData(5)+(LossData(i)-Ave)^2;
    end
    fcLossData(5)=fcLossData(5)/itLossData;
end
%第五种情况:观察37%的时间,记下最大值，如果后面某个速率超过这个最大值，则传输，结束
%结束后，将所有值存储
name=sprintf('%s%s%s%s','test_compare_diff_',str,'_Rayleigh','.txt');
fi=fopen(name,'a');
fprintf(fi,'M\tDm:S\tt:S\tT:S\tc:bps\tEp:J(10^-6)\tP:w\tEninit\r\n');
fprintf(fi,'%d\t%d\t%d\t%d\t%d\t%.3f\t%d\t%d\r\n',M,Dm,t,T,c,Ep/10^(-6),P,Eninit);
i=1;
while(i<=numberc)
   fprintf(fi,'Case %d\r\n',i);
   fprintf(fi,'TransData:bit\tDuratiaon:S\tUseEn:J\tEnEf:J/bit\tDeEf\tMaxLossData:bit\tMinLossData\tAveLossData\tAveTransData\tfcLossData\tAveScheduler\tTurnLossData\tTranDataRatio\r\n'); 
   x=(Eninit-RemainEn(i))/TransData(i);
   y=Eninit-RemainEn(i);
   z=detectiontime(i)/round(i);
   fprintf(fi,'%.0f\t%.0f\t%.3f\t%.15f\t%d\t',TransData(i),Duration(i),y,x,z);
   fprintf(fi,'%.0f\t%.0f\t%.0f\t%.0f\t%.2f\t%.2f\t',MaxLossData(i),MinLossData(i),AveLossData(i),AveTransData(i),fcLossData(i),AveSchedule(i));
   fprintf(fi,'%d\t%.5f',TurnLossData(i),TranDataRatio(i));
   fprintf(fi,'\r\n');
   i=i+1;
end
fclose(fi);
%
end
