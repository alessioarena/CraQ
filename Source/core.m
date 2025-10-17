function [stats,lab,rgb1,rgb2,bb,divBw,histplot]=core(bw,KTop,KBot,Angle,gs,flagBorder,ARBorder,conv,ARFilt,resflag,developermode)
Kt=(KTop+1)/2;
Kb=(KBot+1)/2;


tic
bw2=bwmorph(bw,'diag');                          %morphological filtering: adding diagonal pixels
bw2=bwmorph(bw2,'close');                        %morphological closing, dilatation follows by erosion
bw2=bwmorph(bw2,'spur');
if resflag==1
    bw2=imresize(bw2,2,'nearest');
end
skel=bwmorph(bw2, 'thin', inf);
skel=bwmorph(skel,'clean');
Tind=zeros(23,1);
TNF=zeros(23,3);
TF=zeros(23,3);


progr=Kt-Kb+1;
parfor_progress(progr);
parfor ks=Kb:Kt
    [divBw]=Segmentation(bw2,skel,Angle,ks);
    [lab,stats,del,numT,numPC]=Filt_Anal(divBw,skel,flagBorder,ARBorder,ARFilt);
    TNF(ks,1)=numT;
    TF(ks,1)=numPC;
    Tind(ks,1)=ks*2-1;
    LAB{ks}=lab;
    DIVBW{ks}=divBw;
    DEL{ks}=del;
    STATS{ks}=stats;
    parfor_progress;

end
for ks=Kb:Kt
    TNF(ks,2)=TNF(ks,1)-min(TNF(Kb:Kt,1));
    TF(ks,2)=TF(ks,1)-min(TF(Kb:Kt,1));
    TNF(ks,3)=(TNF(ks,2)*100)/min(TNF(Kb:Kt,1));
    TF(ks,3)=(TF(ks,2)*100)/min(TNF(Kb:Kt,1));
end
toc
parfor_progress(0);

%choosing the result
    
    if Kb==Kt
        x=Kb*2-1;
    else
        screensize=get(0,'ScreenSize');
        aa=figure('Position',[1,screensize(4)/3,screensize(3),screensize(4)/2]);
        aaa=tight_subplot(1,2);
    
        axes(aaa(1)),plot(Tind(Kb:Kt,1),TNF(Kb:Kt,1),Tind(Kb:Kt,1),TF(Kb:Kt,1)),grid on, set(gca,'XTick',(KBot:2:KTop));
        axes(aaa(2)),plot(Tind(Kb:Kt,1),TNF(Kb:Kt,3),Tind(Kb:Kt,1),TF(Kb:Kt,3)),grid on, set(gca,'XTick',(KBot:2:KTop));
        legend('Non Filtered','Filtered');
    
        Kernel=inputdlg('What kernel size do you want to use?','Maximum Kernel Size',1);
        a=Kernel{1};
        err=0;
        if ~isempty(a)
            x = str2num(a); %#ok<*ST2NM>
            if isempty(x)
                warning('Entry is not a number') %#ok<*WNTAG>
                err=1;
            elseif mod(x,2)==0 || x<=5
                warning('You entered a non valid number');
                err=1;
            end
        else
            warning('Nothing was entered')
            err=1;
        end
        if err==1
            close('all');
            msgbox(lastwarn,'Error','error');
        end
    end
    
    
    lab=LAB{(x+1)/2};
    del=DEL{(x+1)/2};
    stats=STATS{(x+1)/2};
    divBw=DIVBW{(x+1)/2};
    if exist('aa')==1
        close(aa);
    end
    %Working data
    toc
    [stats,~,rosedata]=Orientation(lab,stats,skel,gs);
    
    stats_px=stats;
    if conv~=0
        stats(:,2)=stats(:,2).*(conv*conv);
        stats(:,3)=stats(:,3).*conv;
        stats(:,4)=stats(:,4).*conv;
    end
    
    
    d2=size(lab);
    ref=zeros(d2(1),d2(2));
    idx=find(lab);
    ref(idx)=1;
    idx=find(del);
    ref(idx)=2;
    
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
        text((ax(2)*-1.2),(ax(4)*0.95),['Values expressed in pixels',char(10),'Number of Elements: ',num2str(length(stats)),char(10),'Total Area of cracks: ',num2str(sum(stats(:,2))),char(10),'Relative Area of cracks: ',num2str((sum(stats(:,2))/(d2(1)*d2(2)))*100),' %'],'HorizontalAlignment','Center','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    else
        text((ax(2)*-1.2),(ax(4)*0.95),['Values expressed in micron',char(10),'Number of Elements: ',num2str(length(stats)),char(10),'Total Area of cracks: ',num2str(sum(stats(:,2))),char(10),'Relative Area of cracks: ',num2str((sum(stats(:,2))/(d2(1)*d2(2)*conv*conv))*100),' %'],'HorizontalAlignment','Center','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    end
    
    map=[1,1,1;1,0,0];
    premap=rand(max(max(lab)),3);
    map2=(30+(225.*(premap)))/255;
    rgb1=label2rgb(ref,map,'k');
    rgb2=label2rgb(lab,map2,'k');
    if developermode==1
        altstats=regionprops(lab,'Area','Orientation','MinorAxisLength','MajorAxisLength');
        if conv==0
            for i=1:length(stats)
                LABEL=stats(i,1);
                stats(i,8)=altstats(LABEL).MajorAxisLength;
                stats(i,9)=altstats(LABEL).MinorAxisLength;
                stats(i,10)=altstats(LABEL).Orientation;
            end
        else
            for i=1:length(stats)
                LABEL=stats(i,1);
                stats(i,8)=altstats(LABEL).MajorAxisLength*conv;
                stats(i,9)=altstats(LABEL).MinorAxisLength*conv;
                stats(i,10)=altstats(LABEL).Orientation;
            end

        end   
    end
    figure('units','normalized','outerposition',[0 0 0.5 1]), imshow(rgb1);
    bb=figure('units','normalized','outerposition',[0.5 0 0.5 1]);
    imshow(rgb2);
    assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)},'conv',{conv},'developermode',{developermode});
    if developermode==1
            assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)},'FerretMax',{stats(:,8)},'FerretMin',{stats(:,9)},'FerretOrient',{stats(:,10)},'conv',{conv},'developermode',{developermode});
    end
    setappdata(gca,'AssetData',assetData);
    dcm_obj=datacursormode(bb);
    set(dcm_obj,'UpdateFcn',@displayquery)
    datacursormode('on');
    toc
    
    clear -regexp lab_\n* del_\n* stats_\n* lab3_\n*;
    clear bw2 ks num num2 numT  Angle Test lab1 lab2 c1 c2 c3 idx choice aaa bbb h;
    clear path name a screensize err ax ccc ;

    

    
    
end