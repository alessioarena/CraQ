tic
flagBorder=1;
ARBorder=0.05;
ARFilt=0.5;
gs=8;
bw2=bwmorph(bw,'diag');                          %morphological filtering: adding diagonal pixels
bw2=bwmorph(bw2,'close');                        %morphological closing, dilatation follows by erosion
bw2=bwmorph(bw2,'spur');
skel=bwmorph(bw2, 'thin', inf);
skel=bwmorph(skel,'clean');
bp= bwmorph (skel,'branchpoints');               %finds branchpoints and their coordinates

for i=1:20
    bp2= bwmorph (bp,'dilate',i);
    res=bw2 - bp2;
    [labT,numT]=bwlabel( res, 4); 
    a(i)=i;
    b(i)=numT;
end
plot(a,b);
k=inputdlg('what is the best dilatation value?','choice');
w=cell2mat(k);
bp2= bwmorph (bp,'dilate',str2num(w(1)));
res=bw2 - bp2;
[labT,numT]=bwlabel( res, 4); 
rgb=label2rgb(labT,'colorcube','k');
imshow(rgb);
toc
[lab,stats,del,numT,numPC]=Filt_Anal(res,skel,flagBorder,ARBorder,ARFilt);
toc
[stats,~,rosedata]=Orientation(lab,stats,skel,gs);
toc
  
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
        text((ax(2)*-1.2),(ax(4)*0.95),['Values expressed in pixels',char(10),'Number of Elements: ',num2str(length(stats)),char(10),'Total Area of cracks: ',num2str(sum(stats(:,2))),char(10),'Relative Area of cracks: ',num2str((sum(stats(:,2))/(d2(1)*d2(2)))*100),' %'],'HorizontalAlignment','Center','Backgroundcolor',[1 1 1],'EdgeColor',[0 0 0]);
    
    map=[1,1,1;1,0,0];
    premap=rand(max(max(lab)),3);
    map2=(30+(225.*(premap)))/255;
    rgb1=label2rgb(ref,map,'k');
    rgb2=label2rgb(lab,map2,'k');
    figure('units','normalized','outerposition',[0 0 0.5 1]), imshow(rgb1);
    bb=figure('units','normalized','outerposition',[0.5 0 0.5 1]);
    imshow(rgb2);
    assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)});
    setappdata(gca,'AssetData',assetData);
    dcm_obj=datacursormode(bb);
    set(dcm_obj,'UpdateFcn',@displayquery)
    toc
    
    button=questdlg('Do you want to save results?','Save');
    switch button
        case 'Yes'
            path=uigetdir;
            strlab='\labeled.bmp';
            strlab2='\labeledNF.bmp';
            strdiv='\divbw.bmp';
            strstat='\stats.txt';
            strdel='\deleted.bmp';
            imwrite(rgb,strcat(path,strlab2),'bmp');
            imwrite(rgb1,strcat(path,strdel),'bmp');
            imwrite(rgb2,strcat(path,strlab),'bmp');
            imwrite(res,strcat(path,strdiv),'bmp');
            dlmwrite(strcat(path,strstat),stats,'precision',4,'delimiter','\t','newline','pc','-append');
    end

            
        
