function [ ]=draw_diff_argument_test_data_diff()
   
	case_number=4;%4�ֲ��ԱȽ�
    Dm_number=20;%100������
    fi=fopen('test_compare_diff_M_Rayleigh.txt','r');
    for i=1:Dm_number
       fgets(fi)%��������˵��
       fgets(fi);%�����س�
       for j=1:case_number  
           EnEf(i,j)=0;
           fgets(fi)%�������˵��
           fgets(fi)%��������˵��
           result_number=14;%12�����
           result_value=fscanf(fi,'%d%d%d%d%f%f%d%d%d%d%f%f%d%f',[1,result_number]);%��ȡ12�����
           EnEf(i,j)=EnEf(i,j)+result_value(1)/result_value(2);%��λʱ���ƽ���ܺ�
           fgets(fi)%�����س�
       end        
    end
    
    x=[1:1:20];
    for i=1:Dm_number
        y1(i)=EnEf(i,1);
        y2(i)=EnEf(i,2);
        y3(i)=EnEf(i,3);
        y4(i)=EnEf(i,4);
    end
    figure();
    plotyy(x,y1,x,y3);
    xlabel('����(bps)');
    ylabel('�ܺ�Ч��/(��10^{-5}J/bit)');
    legend('OTSSP','RTS');
%     figure(2);
%     plot(x,y2,'b.-');
%     figure(3);
%     plot(x,y3,'g.-');
%     figure(4);
%     plot(x,y4,'k.-');
%  set(gca,'xtick',100:200:2800)
%  set(gca,'ytick',[12000:1000:15000,18000:1000:21000])
 hold on
 end
 