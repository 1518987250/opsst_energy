function [ ]=draw_diff_argument_test_data_diff()
   
	case_number=5;%5种策略比较
    Dm_number=50;%100种速率
    fi=fopen('test_compare_diff_c_Rician1.txt','r');
    for i=1:Dm_number
       fgets(fi)%读出参数说明
       fgets(fi);%读出回车
       for j=1:case_number  
           EnEf(i,j)=0;
           fgets(fi)%读出情况说明
           fgets(fi)%读出参数说明
           result_number=13;%12个结果
           result_value=fscanf(fi,'%d%d%f%f%f%d%d%d%d%f%f%d%f',[1,result_number]);%读取13个结果
           EnEf(i,j)=EnEf(i,j)+result_value(3)/result_value(1);%单位时间的平均能耗
           fgets(fi)%读出回车
       end        
    end
    
    x=[1:1:50];
    for i=1:Dm_number
        y1(i)=EnEf(i,1);
        y2(i)=EnEf(i,2);
        y3(i)=EnEf(i,3);
        y4(i)=EnEf(i,4);
        y5(i)=EnEf(i,5);
    end
    figure();
    hold on;
 
%     plot(x,y1);
% %     axis([0,10,0.05,0.3])
%     set(gca,'position',[0.15 0.25 0.7 0.7]);
%     xlabel('最大传输延时Dm(s)');
%     ylabel('侦测效率','fontsize',20);
%     set(gca,'fontsize',20);
%     legend('OTSSP');
%     set(get(gca,'Children'),'LineWidth',2);
     
%     [AX]=plotyy(x,y2,x,y4,'plot');
%     set(gca,'position',[0.15 0.25 0.7 0.7]);
%     xlabel('速率c(×10^{2}bps)');
%     ylabel('最大传输延时Dm(s)','fontsize',22,'color','k');
%     set(gca,'fontsize',22);
%     legend('TSTB','RTS');
%     set(AX(2),'Fontsize',22);
%     set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
%     set(findobj(get(AX(2),'Children'),'LineWidth',0.5),'LineWidth',2);

    [AX]=plotyy(x,[y1;y4],x,y2,'plot');
    set(gca,'position',[0.15 0.25 0.7 0.63]);
    xlabel('速率c(×10^{2}bps)');
    ylabel('能耗效率','fontsize',22,'color','k');
    set(gca,'fontsize',22);
    legend('OTSSP','RTS','TSTB');
    set(AX(2),'Fontsize',22);
    set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
    set(findobj(get(AX(2),'Children'),'LineWidth',0.5),'LineWidth',2);
 end
 