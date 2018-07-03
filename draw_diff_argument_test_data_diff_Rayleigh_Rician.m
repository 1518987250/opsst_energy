function [ ]=draw_diff_argument_test_data_diff_Rayleigh_Rician()
   
	case_number=5;%5�ֲ��ԱȽ�
    Dm_number=10;%100������
    fi=fopen('test_compare_diff_c_Rayleigh.txt','r');
    for i=1:Dm_number
       fgets(fi)%��������˵��
       fgets(fi);%�����س�
       for j=1:case_number  
           EnEf_rayleigh(i,j)=0;
           fgets(fi)%�������˵��
           fgets(fi)%��������˵��
           result_number=13;%12�����
           result_value=fscanf(fi,'%d%d%f%f%f%d%d%d%d%f%f%d%f',[1,result_number]);%��ȡ13�����
           EnEf_rayleigh(i,j)=EnEf_rayleigh(i,j)+result_value(3)/result_value(1);%��λʱ���ƽ���ܺ�
           fgets(fi)%�����س�
       end 
    end
    fi=fopen('test_compare_diff_c_Rician.txt','r');
    for m=1:Dm_number
       fgets(fi)%��������˵��
       fgets(fi);%�����س�
       for n=1:case_number  
           EnEf_rician(m,n)=0;
           fgets(fi)%�������˵��
           fgets(fi)%��������˵��
           result_number=13;%12�����
           result_value=fscanf(fi,'%d%d%f%f%f%d%d%d%d%f%f%d%f',[1,result_number]);%��ȡ13�����
           EnEf_rician(m,n)=EnEf_rician(m,n)+result_value(3)/result_value(1);%��λʱ���ƽ���ܺ�
           fgets(fi)%�����س�
       end        
    end
    
    x=[1:1:10];
    for i=1:Dm_number
        y1(i)=EnEf_rayleigh(i,1);
        y2(i)=EnEf_rayleigh(i,2);
        y3(i)=EnEf_rayleigh(i,3);
        y4(i)=EnEf_rayleigh(i,4);
        y5(i)=EnEf_rayleigh(i,5);
        y6(i)=EnEf_rician(i,1);
        y7(i)=EnEf_rician(i,2);
        y8(i)=EnEf_rician(i,3);
        y9(i)=EnEf_rician(i,4);
        y10(i)=EnEf_rician(i,5);
    end
    figure();
    hold on;
    
%     plot(x,y1);
%     set(gca,'position',[0.15 0.25 0.7 0.7]);
%     xlabel('����c(��10^{2}bps)');
%     ylabel('�ܺ�Ч��','fontsize',20);
%     set(gca,'fontsize',20);
%     legend('OTSSP');
%     set(get(gca,'Children'),'LineWidth',2);
%     box on;
    
    plot(x,y1);
    plot(x,y2);
    plot(x,y4);
    plot(x,y6);
    plot(x,y7);
    plot(x,y9);
    set(gca,'position',[0.15 0.23 0.7 0.7]);
    xlabel('���Ӧ����ĿM');
    ylabel('ƽ���ܺ�(J/bit)','fontsize',20);
    set(gca,'fontsize',20);
    legend('Rayleigh1','Rayleigh2','Rayleigh3','Rician4','Rician5','Rician6');
    set(get(gca,'Children'),'LineWidth',2);
    box on;
     
%     [AX]=plotyy(x,y2,x,y4,'plot');
%     set(gca,'position',[0.15 0.25 0.7 0.7]);
%     xlabel('����c(��10^{2}bps)');
%     ylabel('�������ʱDm(s)','fontsize',22,'color','k');
%     set(gca,'fontsize',22);
%     legend('TSTB','RTS');
%     set(AX(2),'Fontsize',22);
%     set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
%     set(findobj(get(AX(2),'Children'),'LineWidth',0.5),'LineWidth',2);

%     [AX]=plotyy(x,[y1;y4],x,y2,'plot');
%     set(gca,'position',[0.15 0.25 0.7 0.63]);
%     xlabel('���Ӧ����ĿM');
%     ylabel('ƽ���ܺ�(J/bit)','fontsize',22,'color','k');
%     set(gca,'fontsize',22);
%     legend('OTSSP','RTS','TSTB');
%     set(AX(2),'Fontsize',22);
%     set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
%     set(findobj(get(AX(2),'Children'),'LineWidth',0.5),'LineWidth',2);
%     box on;
 end
 