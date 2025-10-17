function [lab,stats,del,numT,numPC]=Filt_Anal(divBw,skel,flagBorder,ARBorder,ARFilt)
clear del lab eraser
[labT,numT]=bwlabel(divBw,4);                                                      

statsT=zeros(numT,5);
for l=1:numT
    idxtemp=(labT==l);
    areaBW=sum(sum(idxtemp));
    statsT(l,1)=l;
    statsT(l,2)=areaBW;
end
idxAREA=find(statsT(:,2)<(sum(statsT(:,2))*0.0008));
lab=labT;
stats=statsT;
for I=1:length(idxAREA)
    stats((idxAREA(I)-I+1),:)=[];
    [r,c]=find(labT==idxAREA(I));
    if isempty(r)
        asdidxArea=1;
    end
    for j=1:length(r)
        lab(r(j),c(j))=0;
    end
end

for l=1:length(stats)                                                               %creating stats file
idxtemp=(lab==stats(l,1));
tempa=skel&idxtemp;
lenSKEL=sum(tempa);
lenSKEL=sum(lenSKEL);
stats(l,3)=lenSKEL;
stats(l,4)=stats(l,2)/lenSKEL;
stats(l,5)=stats(l,4)/lenSKEL;

end
idx2=find(stats(:,5)>ARFilt);
for i=1:length(idx2)
    labtobeerased=stats((idx2(i)-i+1),1);
    stats((idx2(i)-i+1),:)=[];
    [r,c]=find(lab==labtobeerased);
        if isempty(r)
        asdidx2=1;
        end

    for j=1:length(r)
        lab(r(j),c(j))=0;
    end
end

count=0;
y=size(stats);
for k=1:y(1)
    idx=(lab==stats((k-count),1));
    temp=idx&skel;
    tips=bwmorph(temp,'endpoints');
    [r,~]=find(tips);
    if isempty(r)
        lab(idx)=0;
        stats(k-count,:)=[];
        count=count+1;
    elseif length(r)==1
        lab(idx)=0;
        stats(k-count,:)=[];
        count=count+1;
    end
    clear temp r idx tips
end

del=xor(im2bw(lab),im2bw(labT));
numPC=length(stats);

clear idx idx2 idx3
if flagBorder==1
clear label
d=size(lab);
[Rtop,Ctop]=find(lab(1:10,:));
[Rbottom,Cbottom]=find(lab((d(1)-10):d(1),:));
[Rleft,Cleft]=find(lab(:,1:10));
[Rright,Cright]=find(lab(:,((d(2)-10):d(2))));
Rbottom(:,1)=Rbottom(:,1)+d(1)-11;
Cright(:,1)=Cright(:,1)+d(2)-11;
if isempty(Rtop) && isempty(Rbottom) && isempty(Rleft) && isempty(Rright)
else
for i=1:length(Rtop)
    BorderElements(i)=lab(Rtop(i),Ctop(i)); %#ok<*AGROW>
end
for i=1:length(Rbottom)
    BorderElements(i+length(Rtop))=lab(Rbottom(i),Cbottom(i));
end
for i=1:length(Rleft)
    BorderElements(i+length(Rtop)+length(Rbottom))=lab(Rleft(i),Cleft(i));
end
for i=1:length(Rright)
    BorderElements(i+length(Rtop)+length(Rbottom)+length(Rleft))=lab(Rright(i),Cright(i));
end
BorderElements=unique(BorderElements);

for i=1:length(BorderElements)
    rownumber=find(stats(:,1)==BorderElements(1,i));
    idx2(i,1)=rownumber;
end
extractedStats=stats(idx2,:);
idx=find(extractedStats(:,5)>=ARBorder);
EraserNbr=extractedStats(idx,1);
clear rownumber
if isempty(EraserNbr)
else
for i=1:length(EraserNbr)
    r=find(stats(:,1)==EraserNbr(i));
    rownumber(i,1)=r;
    [r,c]=find(lab==EraserNbr(i));
    for j=1:length(r)
        lab(r(j),c(j))=0;
    end
end
for i=1:length(rownumber)
    stats((rownumber(i)+1-i),:)=[];
end
 
del=xor(im2bw(lab),im2bw(labT));
end
numPC=length(stats);
end
end
end