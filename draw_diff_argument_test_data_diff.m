function [ ]=draw_diff_argument_test_data_diff()
   
	case_number=5;%5�ֲ��ԱȽ�
    Dm_number=50;%100������
    fi=fopen('test_compare_diff_c_Rician1.txt','r');
    for i=1:Dm_number
       fgets(fi)%��������˵��
       fgets(fi);%�����س�
       for j=1:case_number  
           EnEf(i,j)=0;
           fgets(fi)%�������˵��
           fgets(fi)%��������˵��
           result_number=13;%12�����
           result_value=fscanf(fi,'%d%d%f%f%f%d%d%d%d%f%f%d%f',[1,result_number]);%��ȡ13�����
           EnEf(i,j)=EnEf(i,j)+result_value(3)/result_value(1);%��λʱ���ƽ���ܺ�
           fgets(fi)%�����س�
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
%     xlabel('�������ʱDm(s)');
%     ylabel('���Ч��','fontsize',20);
%     set(gca,'fontsize',20);
%     legend('OTSSP');
%     set(get(gca,'Children'),'LineWidth',2);
     
%     [AX]=plotyy(x,y2,x,y4,'plot');
%     set(gca,'position',[0.15 0.25 0.7 0.7]);
%     xlabel('����c(��10^{2}bps)');
%     ylabel('�������ʱDm(s)','fontsize',22,'color','k');
%     set(gca,'fontsize',22);
%     legend('TSTB','RTS');
%     set(AX(2),'Fontsize',22);
%     set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
%     set(findobj(get(AX(2),'Children'),'LineWidth',0.5),'LineWidth',2);

    [AX]=plotyy(x,[y1;y4],x,y2,'plot');
    set(gca,'position',[0.15 0.25 0.7 0.63]);
    xlabel('����c(��10^{2}bps)');
    ylabel('�ܺ�Ч��','fontsize',22,'color','k');
    set(gca,'fontsize',22);
    legend('OTSSP','RTS','TSTB');
    set(AX(2),'Fontsize',22);
    set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
    set(findobj(get(AX(2),'Children'),'LineWidth',0.5),'LineWidth',2);
 end
 