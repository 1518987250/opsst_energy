function [ ] = diff_policy_compare_Rayleigh(M,Dm,t,T,c,Ep,str)

%global Rth;%ȫ�ֱ���

g=4;%�������������4
%SNR=0.1;%�������-10dB
%SNR=0.08;%�������-10.9691dB
BW=1*10^6;%Ƶ����1MHZ
fc=1;%�������1
%���������Rmax
%Rmax=BW*log2(1+P*g/N0W);%bps
%������ʵ��ۻ�����

%���ó�ʼֵ
%P=0.1;%W
P=0.1;%W
N0W=1;%��������
Min_receive_power=10^(-1);%��С�ɽ��չ���
%Min_receive_power=2^(c/BW)*N0W-1;%��С�ɽ��չ���

Eninit=200000;%J
TotalTime=259200;%S
numberc=5;%5�����
Z=floor(Dm/t);%��ʾ�����ӳ�ʱ�����
for i=1:numberc
     RemainEn(i)=Eninit;%��¼��������ʣ������,��λ��J
     Duration(i)=0;%��¼����ʱ��,��λ��S
     TransData(i)=0;%��¼���������,��λ��bit    
     MaxLossData(i)=0;%��¼���ʧ����
     MinLossData(i)=0;%��¼��С��ʧ����
     fcLossData(i)=0;%��¼��ʧ���ݷ���
     TranDataRatio(i)=0;%��¼�������ݱ���
     detectiontime(i)=0;%��¼ʵ��������
     round(i)=0;%�ִ�
 end
%��һ�����:�Ź�k���������¼�Ĺ�����д���
it=1;%ģ����ִ�
itLossData=0;%��ʧ���ݵ��ִ�
sumLossData=0;
formLossData=0;%��һ��û�д��������
     TransR=0;
     TransT=0;
     TransP=0;
while(Duration(1)<TotalTime)
    minP=P;%��ʼ��С����ΪP
    i=1;
    ob=floor(sqrt(Z))-1;
    while(i<=ob)%ǰ�棨����Z-1���ֿ��Խ��������ж�,�õ���������  
       rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
       while(rnd_g>g)%���������ֵ,����������
           rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
       end 
       TransP=Min_receive_power/rnd_g;%���书��
       if(TransP<minP)
         minP=TransP;
       end
       i=i+1;
    end
    while(i<Z)%��ǰk�����ݽ��бȽϣ������ʴ���ǰk��������ʣ���������
        rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        while(rnd_g>g)%���������ֵ,����������
            rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        end
        TransP=Min_receive_power/rnd_g;%���书��
        if(TransP<minP)
            TransR=BW*log2(1+TransP*rnd_g/N0W ); %���ɴ�������
            detectiontime(1)=detectiontime(1)+i; %����ʵ��������
            break;
        end
        i=i+1;   
    end
    if(i==Z)%���ﴫ���ӳ٣����봫��
    	rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        while(rnd_g>g)%���������ֵ,����������
           rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        end
        TransP=P;%���书��  
        TransR=BW*log2(1+rnd_g*P/N0W ); %���ɴ�������
        detectiontime(1)=detectiontime(1)+i; %����ʵ��������
    end   
    if(RemainEn(1)<(i*Ep+TransP*T))%ʣ����������,�����
        break;
    end 
    producedata=c*(i*t+T);%����������
    if (formLossData~=0)
        if (formLossData/c<=Dm-TransT*t)%�����Щ����û�г����ӳ�����
            producedata=formLossData+producedata;%��������δ�������δ�����ӳٵ�����
        else%��������ݳ����ӳ����ޣ����������ӳ����޵�����
            producedata=c*(Dm-TransT*t)+producedata;%��������δ�������δ�����ӳٵ�����
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-TransT*t);%��ʧ����������һ��δ�����ұ��ֲ��ܴ��������
            sumLossData=sumLossData+LossData(itLossData);% �ۼӶ�ʧ����
        end
    end  
    
    transdata=TransR*T;%�ܴ��������
    
    if (producedata>transdata)%���ʱ���ڲ��������ݸ���
       TransData(1)=TransData(1)+transdata;    %ֻ�ܴ�����ô������
       formLossData=producedata-transdata;%��������û�д��������������һ��
    else%���ʱ�����ܲ��������ݸ���,��û���㹻�����ݿɴ���
        TransData(1)=TransData(1)+producedata;
        formLossData=0;%��һ��û�в����������
    end
    Duration(1)=Duration(1)+(i*t+T);%�ȴ�ʱ��Ӵ���ʱ����Ǳ��ֳ���ʱ��
    RemainEn(1)=RemainEn(1)-M*((i*Ep+TransP*T));%�����ܺ�������ܺļӴ����ܺ�
    round(1)=it*Z;%������������
    it=it+1;
end
AveTransData(1)=TransData(1)/Duration(1);%ƽ�����ݴ���
TranDataRatio(1)=(TransData(1))/(c*Duration(1));%�������ݱ���
%���������ƽ���ִ�ʱ��Ͷ�ʧ���ݵ��ִ�,���ֵ,��Сֵ,ƽ��ֵ,����
TurnLossData(1)=itLossData;
AveSchedule(1)=(Duration(1)-(it-1)*T)/(it-1);
AveLossData(1)=sumLossData/Duration(1);%ƽ��ÿ�붪ʧ����
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%��ʧ����ƽ��ֵ
    fcLossData(1)=(LossData(1)-Ave)^2;
    MaxLossData(1)=LossData(1);%���ֵ
    MinLossData(1)=LossData(1);%��Сֵ
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
%��һ�����:�Ź�k���������¼�Ĺ�����д���,����
%�ڶ������:��һ��������ݺ���
it=1;%ģ����ִ�
itLossData=0;%��ʧ���ݵ��ִ�
sumLossData=0;
formLossData=0;%��һ��û�д��������
TransR=0;
TransT=0;
TransP=0;
while(Duration(2)<TotalTime)
%     minP=P;%��ʼ��С����ΪP
    i=1;
    rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
    while(rnd_g>g)%���������ֵ,����������
        rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
    end
    TransP=Min_receive_power/rnd_g;%���书��
    TransR=BW*log2(1+TransP*rnd_g/N0W ); %���ɴ�������
    detectiontime(2)=detectiontime(2)+1; %����ʵ��������
    if(RemainEn(2)<(i*Ep+TransP*T))%ʣ����������,�����
         break;
    end 
    producedata=c*(i*t+T);%����������
    if (formLossData~=0)
        if (formLossData/c<=Dm-TransT*t)%�����Щ����û�г����ӳ�����
            producedata=formLossData+producedata;%��������δ�������δ�����ӳٵ�����
        else%��������ݳ����ӳ����ޣ����������ӳ����޵�����
            producedata=c*(Dm-TransT*t)+producedata;%��������δ�������δ�����ӳٵ�����
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-TransT*t);%��ʧ����������һ��δ�����ұ��ֲ��ܴ��������
            sumLossData=sumLossData+LossData(itLossData);% �ۼӶ�ʧ����
        end
    end  
    transdata=TransR*T;%�ܴ��������
    if (producedata>transdata)%���ʱ���ڲ��������ݸ���
       TransData(2)=TransData(2)+transdata;    %ֻ�ܴ�����ô������
       formLossData=producedata-transdata;%��������û�д��������������һ��
    else%���ʱ�����ܲ��������ݸ���,��û���㹻�����ݿɴ���
        TransData(2)=TransData(2)+producedata;
        formLossData=0;%��һ��û�в����������
    end
    Duration(2)=Duration(2)+(i*t+T);%�ȴ�ʱ��Ӵ���ʱ����Ǳ��ֳ���ʱ��
    RemainEn(2)=RemainEn(2)-M*(TransP*T);%�����ܺ�������ܺļӴ����ܺ�
    round(2)=it*1;%������������
    it=it+1;
end
AveTransData(2)=TransData(2)/Duration(2);%ƽ�����ݴ���
TranDataRatio(2)=(TransData(2))/(c*Duration(2));%�������ݱ���
%���������ƽ���ִ�ʱ��Ͷ�ʧ���ݵ��ִ�,���ֵ,��Сֵ,ƽ��ֵ,����
TurnLossData(2)=itLossData;
AveSchedule(2)=(Duration(2)-(it-1)*T)/(it-1);
AveLossData(2)=sumLossData/Duration(2);%ƽ��ÿ�붪ʧ����
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%��ʧ����ƽ��ֵ
    fcLossData(2)=(LossData(1)-Ave)^2;
    MaxLossData(2)=LossData(1);%���ֵ
    MinLossData(2)=LossData(1);%��Сֵ
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
%�ڶ������:�Ź�k���������¼�Ĺ�����д���,����
%���������:ȷ���������,�����������޴���
it=1;%ģ����ִ�
itLossData=0;%��ʧ���ݵ��ִ�
sumLossData=0;
while(Duration(3)<TotalTime)
    if(RemainEn(3)<Z*Ep+P*T)%ʣ����������,��������
        break;
    end
    rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
    while(rnd_g>g)%���������ֵ,����������
        rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
    end
    TransR=BW*log2(1+rnd_g*P/N0W ); %���ɴ�������
    detectiontime(1)=detectiontime(1)+1; %����ʵ��������   
    producedata=c*(Z*t+T);%����������
    transdata=TransR*T;%�ܴ��������
    if (producedata>transdata)%���ʱ���ڲ��������ݸ���
        TransData(3)=TransData(3)+transdata;
        itLossData=itLossData+1;
        LossData(itLossData)=producedata-transdata;%��ʧ������
        sumLossData=sumLossData+LossData(itLossData);% �ۼӶ�ʧ����
    else%���ʱ�����ܲ��������ݸ���,��û���㹻�����ݿɴ���
         TransData(3)=TransData(3)+producedata;
    end        
    Duration(3)=Duration(3)+Dm+T;%����ӳ�ʱ��Ӵ���ʱ����Ǳ��ֳ���ʱ��
    RemainEn(3)=RemainEn(3)-M*(P*T);%���ֵ��ܺ��Ǵ����ܺ�   
    round(3)=it*1;%������������
    it=it+1;
end
AveTransData(3)=TransData(3)/Duration(3);%ƽ�����ݴ���
TranDataRatio(3)=(TransData(3))/(c*Duration(3));%�������ݱ���
%���������ƽ���ִ�ʱ��Ͷ�ʧ���ݵ��ִ�,���ֵ,��Сֵ,ƽ��ֵ,����
TurnLossData(3)=itLossData;
AveSchedule(3)=(Duration(3)-(it-1)*T)/(it-1);
AveLossData(3)=sumLossData/Duration(3);%ƽ��ÿ�붪ʧ����
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%��ʧ����ƽ��ֵ
    fcLossData(3)=(LossData(1)-Ave)^2;
    MaxLossData(3)=LossData(1);%���ֵ
    MinLossData(3)=LossData(1);%��Сֵ
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
%%���������:ȷ���������,�����������޴���,����
%���������:���ѡ��һ��ʱ����д���
it=1;%ģ����ִ�
itLossData=0;%��ʧ���ݵ��ִ�
sumLossData=0;
formLossData=0;%��һ��û�д��������
while(Duration(4)<TotalTime)
    TransT=randi([1,Z]);%���ѡ����ʱ��    
    rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
    while(rnd_g>g)%���������ֵ,����������
        rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
    end   
    TransP=P;%���书��
    TransR=BW*log2(1+rnd_g*TransP/N0W ); %���ɴ�������
    detectiontime(4)=detectiontime(4)+1; %����ʵ��������
    if(RemainEn(4)<TransP*T)%ʣ����������,��������
        break;
    end
    producedata=c*(TransT*t+T);%����������
    if (formLossData~=0)
        if (formLossData/c<=Dm-TransT*t)%�����Щ����û�г����ӳ�����
            producedata=formLossData+producedata;%��������δ�������δ�����ӳٵ�����
        else%��������ݳ����ӳ����ޣ����������ӳ����޵�����
            producedata=c*(Dm-TransT*t)+producedata;%��������δ�������δ�����ӳٵ�����
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-TransT*t);%��ʧ����������һ��δ�����ұ��ֲ��ܴ��������
            sumLossData=sumLossData+LossData(itLossData);% �ۼӶ�ʧ����
        end
    end  
    
    transdata=TransR*T;%�ܴ��������
    
    if (producedata>transdata)%���ʱ���ڲ��������ݸ���
       TransData(4)=TransData(4)+transdata;    %ֻ�ܴ�����ô������
       formLossData=producedata-transdata;%��������û�д��������������һ��
    else%���ʱ�����ܲ��������ݸ���,��û���㹻�����ݿɴ���
        TransData(4)=TransData(4)+producedata;
        formLossData=0;%��һ��û�в����������
    end      
    Duration(4)=Duration(4)+(TransT)*t+T;%�ȴ�ʱ��Ӵ���ʱ����Ǳ��ֳ���ʱ��
    RemainEn(4)=RemainEn(4)-M*((TransP*T));%���ֵ��ܺ��Ǵ����ܺ� 
    round(4)=it*1;%������������
    it=it+1;
end
AveTransData(4)=TransData(4)/Duration(4);%ƽ�����ݴ���
TranDataRatio(4)=(TransData(4))/(c*Duration(4));%�������ݱ���
%���������ƽ���ִ�ʱ��Ͷ�ʧ���ݵ��ִ�,���ֵ,��Сֵ,ƽ��ֵ,����
TurnLossData(4)=itLossData;
AveSchedule(4)=(Duration(4)-(it-1)*T)/(it-1);
AveLossData(4)=sumLossData/Duration(4);%ƽ��ÿ�붪ʧ����
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%��ʧ����ƽ��ֵ
    fcLossData(4)=(LossData(1)-Ave)^2;
    MaxLossData(4)=LossData(1);%���ֵ
    MinLossData(4)=LossData(1);%��Сֵ
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
%���������:���ѡ��һ��ʱ����д���,����
%���������:�۲�37%��ʱ��,�������ֵ���������ĳ�����ʳ���������ֵ������
it=1;%ģ����ִ�
itLossData=0;%��ʧ���ݵ��ִ�
sumLossData=0;
formLossData=0;%��һ��û�д��������

while (Duration(5)<TotalTime)
    minP=P;%��ʼ��С����ΪP
    i=1;
    ob=floor(0.37*Dm/t);
    while(i<=ob)%�۲�37%��ʱ��
         rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
         while(rnd_g>g)%���������ֵ,����������
            rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
         end    
        TransP=Min_receive_power/rnd_g;%���书��   
        if(TransP<minP)%�����ǰ������ʸ�С�����¼����
            minP=TransP;
        end   
        i=i+1;
    end
    %�۲����
    while(i<Z)
        rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        while(rnd_g>g)%���������ֵ,����������
            rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        end    
        TransP=Min_receive_power/rnd_g;%���书��
        if(TransP<minP)%�����ǰ������ʸ�С�����¼����
            TransR=BW*log2(1+Min_receive_power/N0W ); %���ɴ�������
            detectiontime(5)=detectiontime(5)+i; %����ʵ��������
            break;
        end  
        i=i+1;
    end
    if(i==Z)%��������ӳ�,���봫��
        rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        while(rnd_g>g)%���������ֵ,����������
           rnd_g=raylrnd(fc);%������ɷ��������ֲ�������ֵ
        end    
        TransP=P;%���书��  
        TransR=BW*log2(1+rnd_g*P/N0W ); %���ɴ�������
        detectiontime(5)=detectiontime(5)+i; %����ʵ��������
    end
    if(RemainEn(5)<(i*Ep+TransP*T))%ʣ����������,�����
        break;
    end
    producedata=c*(i*t+T);%����������
    
    if (formLossData~=0)
        if (formLossData/c<=Dm-i*t)%�����Щ����û�г����ӳ�����
            producedata=formLossData+producedata;%��������δ�������δ�����ӳٵ�����
        else%��������ݳ����ӳ����ޣ����������ӳ����޵�����
            producedata=c*(Dm-i*t)+producedata;%��������δ�������δ�����ӳٵ�����
            itLossData=itLossData+1;
            LossData(itLossData)=formLossData-c*(Dm-i*t);%��ʧ����������һ��δ�����ұ��ֲ��ܴ��������
            sumLossData=sumLossData+LossData(itLossData);% �ۼӶ�ʧ����
        end
    end  
    
    transdata=TransR*T;%�ܴ��������
    
    if (producedata>transdata)%���ʱ���ڲ��������ݸ���
       TransData(5)=TransData(5)+transdata;    %ֻ�ܴ�����ô������
       formLossData=producedata-transdata;%��������û�д��������������һ��
    else%���ʱ�����ܲ��������ݸ���,��û���㹻�����ݿɴ���
        TransData(5)=TransData(5)+producedata;
        formLossData=0;%��һ��û�в����������
    end     
   
    Duration(5)=Duration(5)+(i*t+T);%�ȴ�ʱ��Ӵ���ʱ����Ǳ��ֳ���ʱ��
    RemainEn(5)=RemainEn(5)-M*((i*Ep+TransP*T));%�����ܺ�������ܺļӴ����ܺ�
    round(5)=it*Z;%������������
    it=it+1;
end
AveTransData(5)=TransData(5)/Duration(5);%ƽ�����ݴ���
TranDataRatio(5)=(TransData(5))/(c*Duration(5));%�������ݱ���
%���������ƽ���ִ�ʱ��Ͷ�ʧ���ݵ��ִ�,���ֵ,��Сֵ,ƽ��ֵ,����
TurnLossData(5)=itLossData;
AveSchedule(5)=(Duration(5)-(it-1)*T)/(it-1);
AveLossData(5)=sumLossData/Duration(5);%ƽ��ÿ�붪ʧ����
if (itLossData>=1)
    Ave=sumLossData/(itLossData);%��ʧ����ƽ��ֵ
    fcLossData(5)=(LossData(1)-Ave)^2;
    MaxLossData(5)=LossData(1);%���ֵ
    MinLossData(5)=LossData(1);%��Сֵ
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
%���������:�۲�37%��ʱ��,�������ֵ���������ĳ�����ʳ���������ֵ�����䣬����
%�����󣬽�����ֵ�洢
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
