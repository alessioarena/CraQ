%Script used to merge and plot results from the analysis of several images   


screensize=get(0,'ScreenSize');
    N= inputdlg('How many image have you analyzed?','Number of images to merge');
    N=str2num(N{1});
    stats= [0 0 0 0 0 0 0];
    conversion= questdlg('are values converted in micron?','Conversion1','Yes','No','Yes');
    switch conversion
        case 'Yes'
            answer=inputdlg({'pixels','are equal to micron'},'Conversion2',1,{'1','1'});
            conv=str2num(answer{2})/str2num(answer{1});
        case 'No'
            conv=0;
    end
    size=inputdlg({'what is the size of the images?','x'},'size',1,{'4096','3072'});
    d2=[str2num(size{1}); str2num(size{2})];
    for i=1:N
        if i==1
            [name,path]=uigetfile('*.txt','CSV and textual files');
            temp=importdata(strcat(path,name),'\t',1);
            stats=temp.data;
        else
            [name,path]=uigetfile('*.txt','CSV and textual files',path);
            temp=importdata(strcat(path,name),'\t',1);
            stats=vertcat(stats,temp.data);
        end

    end
    stats(1,:)=[];
    rosedata=stats(:,6);
    for q=1:length(rosedata)
        rosedata(q)=rosedata(q)+pi;
    end
    rosedata=vertcat(stats(:,6),rosedata);





    
    
    lengthFit=lognfit(stats(:,3));
    [widthMean,widthStd]=normfit(stats(:,4));
    [M,V]=lognstat(lengthFit(1),lengthFit(2));
    [s,t]=rose(rosedata,72);
    histplot=figure('unit','normalized','outerposition',[0 0.05 1 0.95]);
    ax1=subplot(3,2,1);
    histfit(stats(:,3),70,'lognormal'),ylab=str2num(get(ax1,'YTickLabel'));
    ylab=(ylab./length(stats))*100;
    ylab=round(ylab*10)/10;
    set(ax1,'YTickLabel',ylab), grid on, ylabel('%'); 
    ax=axis;
    text((ax(2)*0.997),(ax(4)*0.985),...
        ['Lognormal fitting',char(10),'Mean= ',num2str(M),char(10),'Variance= ',num2str(V),char(10),'Max= ',num2str(max(stats(:,3))),char(10),'Min= ',num2str(min(stats(:,3)))],...
        'HorizontalAlignment','Right','VerticalAlignment','Top','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    text((ax(2)/2),(ax(4)*1.105),'Distribution of Length','HorizontalAlignment','Center','VerticalAlignment','Top','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    
    ax2=subplot(3,2,3);
    histfit(stats(:,4),70,'normal'),ylab=str2num(get(ax2,'YTickLabel'));
    ylab=(ylab./length(stats))*100;
    ylab=round(ylab*10)/10;
    set(ax2,'YTickLabel',num2str(ylab)), grid on, ylabel('%'), ax=axis;
    text((ax(2)*0.997),(ax(4)*0.985),...
        ['Gaussian fitting',char(10),'Mean= ',num2str(widthMean),char(10),'St.Dev= ',num2str(widthStd),char(10),'Max= ',num2str(max(stats(:,4))),char(10),'Min= ',num2str(min(stats(:,4)))],...
        'HorizontalAlignment','Right','VerticalAlignment','Top','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    text((((ax(2)-ax(1))/2)+ax(1)),(ax(4)*1.105),'Distribution of Width','HorizontalAlignment','Center','VerticalAlignment','Top','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    
    ax3=subplot(3,2,5);
    hist(stats(:,5),ceil((length(stats)/(length(stats)*0.025)))),ylabT=str2num(get(ax3,'YTickLabel'));
    ylab=(ylabT./length(stats))*100;
    ylab=round(ylab*10)/10;
    set(ax3,'YTickLabel',ylab), grid on, ylabel('%');
    hold on, ARmean=(widthMean/M);
    ARstd=ARmean*(((2*lengthFit(2))/M)+((2*widthStd)/widthMean));
    line([ARmean ARmean],[0 max(ylabT)],'Color',[1 0 0],'LineStyle','-');
    line([(ARmean-(ARstd/2)) (ARmean-(ARstd/2))],[0 max(ylabT)],'Color',[1 0 0],'LineStyle','-.');
    line([(ARmean+(ARstd/2)) (ARmean+(ARstd/2))],[0 max(ylabT)],'Color',[1 0 0],'LineStyle','-.');
    hold off;
    ax=axis;
    text((ax(2)*0.997),(ax(4)*0.985),...
        ['Mean= ',num2str(ARmean),char(10),'Error est.= ',num2str(ARstd/2),char(10),'Min= ',num2str(min(stats(:,5)))],...
        'HorizontalAlignment','Right','VerticalAlignment','Top','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    text((ax(2)/2),(ax(4)*1.105),'Distribution of Aspect Ratio','HorizontalAlignment','Center','VerticalAlignment','Top','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    
    ax4=subplot(1,2,2);
    r=polar(s,((t*100)/length(stats)));
    set(r,'Color','r') ;
    xrose = get(r, 'XData');
    yrose = get(r, 'YData');
    prose = patch(xrose, yrose, [0 0 0.6],'EdgeColor',[1 1 1]);
    ax=axis;
    if conv==0
        text((ax(2)*-1.6),(ax(4)*0.95),['Values expressed in pixels',char(10),'Number of Elements: ',num2str(length(stats)),char(10),'Average total area of cracks: ',num2str((sum(stats(:,2)))/N),char(10),'Average relative Area of cracks: ',num2str((sum(stats(:,2))/(d2(1)*d2(2)*N))*100),' %'],'HorizontalAlignment','Left','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    else
        text((ax(2)*-1.6),(ax(4)*0.95),['Values expressed in micron',char(10),'Number of Elements: ',num2str(length(stats)),char(10),'Average total area of cracks: ',num2str((sum(stats(:,2)))/N),char(10),'Average relative Area of cracks: ',num2str((sum(stats(:,2))/(d2(1)*d2(2)*N*conv*conv))*100),' %'],'HorizontalAlignment','Left','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    end
    
    