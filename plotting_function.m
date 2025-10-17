%This is the script I use to plot the data
%If you need it, just load stats.txt into Matlab, and run it    


screensize=get(0,'ScreenSize');

rosedata=data(:,6);
    for q=1:length(rosedata)
    rosedata(q)=rosedata(q)+pi;
    end
    rosedata=vertcat(data(:,6),rosedata);
    
    lengthFit=lognfit(data(:,3));
    [widthMean,widthStd]=normfit(data(:,4));
    [M,V]=lognstat(lengthFit(1),lengthFit(2));
    [s,t]=rose(rosedata,72);
    histplot=figure('unit','normalized','outerposition',[0 0.05 1 0.95]);
    ax1=subplot(3,2,1);
    histfit(data(:,3),70,'lognormal'),ylab=str2num(get(ax1,'YTickLabel'));
    ylab=(ylab./length(data))*100;
    ylab=round(ylab*10)/10;
    set(ax1,'YTickLabel',ylab), grid on, ylabel('%'); 
    ax=axis;
    text((ax(2)*0.95),(ax(4)*0.95),...
        ['Lognormal fitting',char(10),'Mean= ',num2str(M),char(10),'Variance= ',num2str(V),char(10),'Max= ',num2str(max(data(:,3))),char(10),'Min= ',num2str(min(data(:,3)))],...
        'HorizontalAlignment','Right','VerticalAlignment','Top','Backgroundcolor',[1 1 1]);
    text((ax(2)/2),(ax(4)*0.95),'Distribution of Length','HorizontalAlignment','Center','VerticalAlignment','Top','Backgroundcolor',[1 1 1]);
    
    ax2=subplot(3,2,3);
    histfit(data(:,4),70,'normal'),ylab=str2num(get(ax2,'YTickLabel'));
    ylab=(ylab./length(data))*100;
    ylab=round(ylab*10)/10;
    set(ax2,'YTickLabel',num2str(ylab)), grid on, ylabel('%'), ax=axis;
    text((ax(2)*0.95),(ax(4)*0.95),...
        ['Gaussian fitting',char(10),'Mean= ',num2str(widthMean),char(10),'St.Dev= ',num2str(widthStd),char(10),'Max= ',num2str(max(data(:,4))),char(10),'Min= ',num2str(min(data(:,4)))],...
        'HorizontalAlignment','Right','VerticalAlignment','Top','Backgroundcolor',[1 1 1]);
    text(((ax(2)-ax(1))*0.1+ax(1)),(ax(4)*0.95),'Distribution of Width','HorizontalAlignment','Left','VerticalAlignment','Top','Backgroundcolor',[1 1 1]);
    
    ax3=subplot(3,2,5);
    hist(data(:,5),70),ylab=str2num(get(ax3,'YTickLabel'));
    ylab=(ylab./length(data))*100;
    ylab=round(ylab*10)/10;
    set(ax3,'YTickLabel',ylab), grid on, ylabel('%');
    ax=axis;
    text((ax(2)/2),(ax(4)*0.95),'Distribution of Aspect Ratio','HorizontalAlignment','Center','VerticalAlignment','Top','Backgroundcolor',[1 1 1]);
    
    ax4=subplot(1,2,2);
    r=polar(s,((t*100)/length(data)));
    set(r,'Color','r') ;
    ax=axis;
    text((ax(2)*-1),(ax(4)*0.95),['Number of Elements',char(10),num2str(length(data))],'HorizontalAlignment','Center');
   