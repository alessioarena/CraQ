function [divBw]= Segmentation(bw2,skel,Angle,ks)


if ks==4 && Angle==3  
else
switch Angle%setting conditions for n==2, when in the searching kernel there are only 2 lines touching borders
    case 1
        C0=(ks-1)*2;
        C1_2=(-4*(ks^2))+(8*ks)-4;
        C3=(4*(ks^2))+(-12*ks)+8;
        C4=C3;
    case 2
        C0=(ks-1)*2;
        C1_2=-((2*(ks^2))-(2*ks));
        C3=C1_2*-1;
        C4=C3*2;
    case 3
        C0=(ks-1)*2;
        C1_2=(-2*(ks^2))+(6*ks)-4;
        C3=8*ks-8;
        C4=(4*(ks^2))-2*ks+2;
end
end
BorderK=ks+2;
d=size(bw2); %setting up some variables
mask=zeros(d,'uint8');
line=zeros(d,'uint8');
bp= bwmorph (skel,'branchpoints');               %finds branchpoints and their coordinates
[row,col]= find(bp);


for i=1:length(row)
    center=[row(i),col(i)];
    topleft=[center(1)-(ks-1),center(2)-(ks-1)];%setting up searching kernel
    botright=[center(1)+(ks-1),center(2)+(ks-1)];
    
    if topleft(1,1)<=0 %dimensional controls of searching kernel                            
        topleft(1,1)=1;
    end
    if topleft(1,2)<=0
        topleft(1,2)=1;
    end
    if botright(1,1)>=d(1,1);
        botright(1,1)=d(1,1)-1;
    end
    if botright(1,2)>=d(1,2);
        botright(1,2)=d(1,2)-1;
    end
    
    temp=skel(topleft(1):botright(1),topleft(2):botright(2));
    [lab,~]=bwlabel(temp,8);
    c=lab(ks,ks);
    idx=find(lab~=c);
    temp(idx)=0;
    temp(2:(2*ks-2),2:(2*ks-2))=0; %clearing the center part of kernel for having only pixels touching borders
    [rowT,colT]=find(temp);
    j=length(rowT);
    clear idx c lab
    if j~=0% controls for anomalous branchpoints, without pixels touching borders of kernel
        pnt=[rowT-ks,colT-ks];
    
        if j>1 %search for adjacent pixels (same line)
            adjac=0;
            for k=1:(j-1)
                if ((pnt(k,1)==pnt(k+1,1))&&(abs(pnt(k,2)-pnt(k+1,2))<=1))||((pnt(k,2)==pnt(k+1,2))&&(abs(pnt(k,1)-pnt(k+1,1))<=1))
                    adjac=vertcat(adjac,(k+1));
                end
            end
            adjac(1,:)=[];
            if isempty(adjac)
            else
                for k=1:length(adjac)
                    pnt(adjac(k)-k,:)=[];
                    j=j-1;
                end
            end
        end
        pnt(j+1,:)=pnt(1,:);

                
        if j>=4
            left=find(pnt(:,2)==-ks+1);
            bot=find(pnt(:,1)==ks-1);
            right=find(pnt(:,2)==ks-1);
            top=find(pnt(:,1)==-ks+1);
            idx=1;
            if isempty(left)
            else
                for or=1:length(left)
                    tmp(or)=pnt(left(or),1);
                end
                tmp=sort(tmp);
                for or=1:length(tmp)
                    pntT(idx,:)=[tmp(or),-ks+1];
                    idx=idx+1;
                end
                clear tmp
    
            end
            if isempty(bot)
            else
                for or=1:length(bot)
                    tmp(or)=pnt(bot(or),2);
                end
                tmp=sort(tmp);
                for or=1:length(tmp)
                    pntT(idx,:)=[ks-1,tmp(or)];
                    idx=idx+1;
                end
                clear tmp
            end
            if isempty(right)
            else
                for or=1:length(right)
                    tmp(or)=pnt(right(or),1);
                end
                tmp=sort(tmp,'descend');
                for or=1:length(tmp)
                    pntT(idx,:)=[tmp(or),ks-1];
                    idx=idx+1;
                end
                clear tmp
            end
            if isempty(top)
            else
                for or=1:length(top)
                    tmp(or)=pnt(top(or),2);
                end
                tmp=sort(tmp,'descend');
                for or=1:length(tmp)
                    pntT(idx,:)=[-ks+1,tmp(or)];
                    idx=idx+1;
                end
                clear tmp
            end
            if length(pntT)~=j
                [pntT,~,~]=unique(pntT,'rows','stable');
            end
            pnt=pntT;
            pnt(j+1,:)=pnt(1,:);

            for k=1:j
                divpntT=round(pnt(k,:)*1.4)+round(pnt(k+1,:)*1.4);
                if (divpntT(1,1)~=0)&&(divpntT(1,2)~=0)
                    divpntT=divpntT+center;   %check if divisory points are into the whole image, and fix when necessary
                    if divpntT(1,1)<=0                             
                        divpntT(1,1)=1;
                    end
                    if divpntT(1,2)<=0
                        divpntT(1,2)=1;
                    end
                    if divpntT(1,1)>=d(1,1);
                        divpntT(1,1)=d(1,1)-1;
                    end
                    if divpntT(1,2)>=d(1,2);
                        divpntT(1,2)=d(1,2)-1;
                    end
        
                    m=(center(1,1)-divpntT(1,1))/(center(1,2)-divpntT(1,2));                
                    if ((m==inf)||(m==-inf))%existence conditions for the slope                
                        nn=abs(center(1,1)-divpntT(1,1))+1;
                        x(1:nn)=center(1,2);
                        y(1:nn)=linspace(divpntT(1,1),center(1,1),nn);
                    else
                        x=linspace(divpntT(1,2),center(1,2));
                        y=m*(x-center(1,2))+center(1,1);
                    end
                    index=sub2ind(d,round(y),round(x));
                    line(index)=255;
                    mask=mask|line;% the divisory line
                    clear index x y m ;
                end
            end
        elseif j==3% 3 points
            prog=1;
            for k=1:j
                divpntT=round(pnt(k,:)*1.4)+round(pnt(k+1,:)*1.4);
                divpntT=divpntT+center;%check if divisory points are into the whole image, and fix when necessary
                if divpntT(1,1)<=0                             
                    divpntT(1,1)=1;
                end
                if divpntT(1,2)<=0
                    divpntT(1,2)=1;
                end
                if divpntT(1,1)>=d(1,1);
                    divpntT(1,1)=d(1,1)-1;
                end
                if divpntT(1,2)>=d(1,2);
                    divpntT(1,2)=d(1,2)-1;
                end
                divpnt(prog,:)=divpntT;  
                prog=prog+1;
            end
        
            alig(:,1)=divpnt(:,1)-center(1,1);
            alig(:,2)=divpnt(:,2)-center(1,2);
            alig(:,3)=abs(alig(:,1)).^2+abs(alig(:,2)).^2;
            [asort,bsort]=sort(alig(:,3));
            inner=4+round(ks/10);
            inner2=round(ks/15);
            if (abs(alig(bsort(1),1))<=inner) && (abs(alig(bsort(1),2))<=inner)
                divpnt(bsort(1),:)=[];
                    if bsort(1)<bsort(2)
                        if (alig(bsort(2),1)<=inner2) && (alig(bsort(2),2)<=inner2)
                            divpnt(bsort(2)-1,:)=[];
                        end
                    else
                        if (abs(alig(bsort(2),1))<=inner2) && (abs(alig(bsort(2),2))<=inner2)
                            divpnt(bsort(2),:)=[];
                        end
                    end
            end
            sizediv=size(divpnt);
            for k=1:sizediv(1)
                m=(center(1,1)-divpnt(k,1))/(center(1,2)-divpnt(k,2));                
                if ((m==inf)||(m==-inf))%existence conditions for the slope                
                    nn=abs(center(1,1)-divpnt(k,1))+1;
                    x(1:nn)=center(1,2);
                    y(1:nn)=linspace(divpnt(k,1),center(1,1),nn);
                else
                    x=linspace(divpnt(k,2),center(1,2));
                    y=m*(x-center(1,2))+center(1,1);
                end
                index=sub2ind(d,round(y),round(x));
                line(index)=255;
                mask=mask|line;% the divisory line
                clear index x y m ;
            end
            clear alig divpnt
        elseif j==2 && ((abs(pnt(1,1))-abs(pnt(2,1))~=0)&&(abs(pnt(1,2))-abs(pnt(2,2))~=0))
            a(1,:)=round(pnt(1,:)*1.4);
            b(1,:)=round(pnt(2,:)*1.4);
            if (((a(1,1)~=0)&&(b(1,1)~=0))||((a(1,2)~=0)&&(b(1,2)~=0)))
                if ((a(1,2)*b(1,2)==0)&&(a(1,2)+b(1,2)==C0)&&(a(1,1)*b(1,1)>=C1_2))%FIRST CONDITION
                    divpnt=(a+b)+center;
                    oppdivpnt=(-1*(a+b))+center;
                    if divpnt(1,1)<=0                             
                        divpnt(1,1)=1;
                    end
                    if divpnt(1,2)<=0
                        divpnt(1,2)=1;
                    end
                    if divpnt(1,1)>=d(1,1)
                        divpnt(1,1)=d(1,1)-1;
                    end
                    if divpnt(1,2)>=d(1,2)
                        divpnt(1,2)=d(1,2)-1;
                    end
                    if oppdivpnt(1,1)<=0                             
                        oppdivpnt(1,1)=1;
                    end
                    if oppdivpnt(1,2)<=0
                        oppdivpnt(1,2)=1;
                    end
                    if oppdivpnt(1,1)>=d(1,1)
                        oppdivpnt(1,1)=d(1,1)-1;
                    end
                    if oppdivpnt(1,2)>=d(1,2)
                        oppdivpnt(1,2)=d(1,2)-1;
                    end
            
                    m=(oppdivpnt(1,1)-divpnt(1,1))/(oppdivpnt(1,2)-divpnt(1,2));
                    if ((m==inf)||(m==-inf))
                        nn=abs(divpnt(1,1)-oppdivpnt(1,1))+1;
                        x(1:nn)=center(1,2);
                        y(1:nn)=linspace(divpnt(1,1),oppdivpnt(1,1),nn);
                    else
                        x=linspace(divpnt(1,2),oppdivpnt(1,2));
                        y=m*(x-divpnt(1,2))+divpnt(1,1);
                    end
            
                    index=sub2ind(d,round(y),round(x));
                    line(index)=255;
                    mask=mask|line;
                    clear index y x m 
            
                elseif ((a(1,1)*b(1,1)==0)&&(a(1,1)+b(1,1)==C0)&&(a(1,2)*b(1,2)>=C1_2))%SECOND CONDITION
                    divpnt=(a+b)+center;
                    oppdivpnt=(-1*(a+b))+center;
                    if divpnt(1,1)<=0                             
                        divpnt(1,1)=1;
                    end
                    if divpnt(1,2)<=0
                        divpnt(1,2)=1;
                    end
                    if divpnt(1,1)>=d(1,1)
                        divpnt(1,1)=d(1,1)-1;
                    end
                    if divpnt(1,2)>=d(1,2)
                        divpnt(1,2)=d(1,2)-1;
                    end
                    if oppdivpnt(1,1)<=0                             
                        oppdivpnt(1,1)=1;
                    end
                    if oppdivpnt(1,2)<=0
                        oppdivpnt(1,2)=1;
                    end
                    if oppdivpnt(1,1)>=d(1,1)
                        oppdivpnt(1,1)=d(1,1)-1;
                    end
                    if oppdivpnt(1,2)>=d(1,2)
                        oppdivpnt(1,2)=d(1,2)-1;
                    end
            
                    m=(oppdivpnt(1,1)-divpnt(1,1))/(oppdivpnt(1,2)-divpnt(1,2));
                    if ((m==inf)||(m==-inf))
                        nn=abs(divpnt(1,1)-oppdivpnt(1,1))+1;
                        x(1:nn)=center(1,2);
                        y(1:nn)=linspace(divpnt(1,1),oppdivpnt(1,1),nn);
                    else
                        x=linspace(divpnt(1,2),oppdivpnt(1,2));
                        y=m*(x-divpnt(1,2))+divpnt(1,1);
                    end
                    index=sub2ind(d,round(y),round(x));
                    line(index)=255;
                    mask=mask|line;
                    clear index y x m
            
                elseif (a(1,2)/a(1,1))/(b(1,2)/b(1,1))>0 %THIRD CONDITION
                    if a(1,2)*b(1,2)>0
                        divpnt=(a+b)+center;
                        oppdivpnt=(-1*(a+b))+center;
                        if divpnt(1,1)<=0                             
                            divpnt(1,1)=1;
                        end
                        if divpnt(1,2)<=0
                            divpnt(1,2)=1;
                        end
                        if divpnt(1,1)>=d(1,1)
                            divpnt(1,1)=d(1,1)-1;
                        end
                        if divpnt(1,2)>=d(1,2)
                            divpnt(1,2)=d(1,2)-1;
                        end
                        if oppdivpnt(1,1)<=0
                            oppdivpnt(1,1)=1;
                        end
                        if oppdivpnt(1,2)<=0
                            oppdivpnt(1,2)=1;
                        end
                        if oppdivpnt(1,1)>=d(1,1)
                            oppdivpnt(1,1)=d(1,1)-1;
                        end
                        if oppdivpnt(1,2)>=d(1,2)
                            oppdivpnt(1,2)=d(1,2)-1;
                        end
                
                        m=(oppdivpnt(1,1)-divpnt(1,1))/(oppdivpnt(1,2)-divpnt(1,2));
                        if ((m==inf)||(m==-inf))
                            nn=abs(divpnt(1,1)-oppdivpnt(1,1))+1;
                            x(1:nn)=center(1,2);
                            y(1:nn)=linspace(divpnt(1,1),oppdivpnt(1,1),nn);
                        else
                            x=linspace(divpnt(1,2),oppdivpnt(1,2));
                            y=m*(x-divpnt(1,2))+divpnt(1,1);
                        end
                        index=sub2ind(d,round(y),round(x));
                        line(index)=255;
                        mask=mask|line;
                        clear index y x m
                    elseif (abs(a(1,2)*b(1,2)))+(abs(a(1,1)*b(1,1)))<=C3
                        divpnt=(a+b)+center;
                        oppdivpnt=(-1*(a+b))+center;
                        if divpnt(1,1)<=0                             
                            divpnt(1,1)=1;
                        end
                        if divpnt(1,2)<=0
                            divpnt(1,2)=1;
                        end
                        if divpnt(1,1)>=d(1,1)
                            divpnt(1,1)=d(1,1)-1;
                        end
                        if divpnt(1,2)>=d(1,2)
                            divpnt(1,2)=d(1,2)-1;
                        end
                        if oppdivpnt(1,1)<=0
                            oppdivpnt(1,1)=1;
                        end
                        if oppdivpnt(1,2)<=0
                            oppdivpnt(1,2)=1;
                        end
                        if oppdivpnt(1,1)>=d(1,1)
                            oppdivpnt(1,1)=d(1,1)-1;
                        end
                        if oppdivpnt(1,2)>=d(1,2)
                            oppdivpnt(1,2)=d(1,2)-1;
                        end
                
                        m=(oppdivpnt(1,1)-divpnt(1,1))/(oppdivpnt(1,2)-divpnt(1,2));
                        if ((m==inf)||(m==-inf))
                            nn=abs(divpnt(1,1)-oppdivpnt(1,1))+1;
                            x(1:nn)=center(1,2);
                            y(1:nn)=linspace(divpnt(1,1),oppdivpnt(1,1),nn);
                        else
                            x=linspace(divpnt(1,2),oppdivpnt(1,2));
                            y=m*(x-divpnt(1,2))+divpnt(1,1);
                        end
                        index=sub2ind(d,round(y),round(x));
                        line(index)=255;
                        mask=mask|line;
                        clear  index y x m
                    end
            
                elseif (((a(1,2)/a(1,1))/(b(1,2)/b(1,1)))<0) %FORTH CONDITION
                    if (a(1,2)==-b(1,2))||(b(1,1)==-a(1,1))
                        if (abs(a(1,2)*a(1,1))+abs(b(1,2)*b(1,1)))>=C4
                            divpnt=(a+b)+center;
                            oppdivpnt=(-1*(a+b))+center;
                            if divpnt(1,1)<=0                             
                                divpnt(1,1)=1;
                            end
                            if divpnt(1,2)<=0
                                divpnt(1,2)=1;
                            end
                            if divpnt(1,1)>=d(1,1)
                                divpnt(1,1)=d(1,1)-1;
                            end
                            if divpnt(1,2)>=d(1,2)
                                divpnt(1,2)=d(1,2)-1;
                            end
                            if oppdivpnt(1,1)<=0                             
                                oppdivpnt(1,1)=1;
                            end
                            if oppdivpnt(1,2)<=0
                                oppdivpnt(1,2)=1;
                            end
                            if oppdivpnt(1,1)>=d(1,1)
                                oppdivpnt(1,1)=d(1,1)-1;
                            end
                            if oppdivpnt(1,2)>=d(1,2)
                                oppdivpnt(1,2)=d(1,2)-1;
                            end
            
                            m=(oppdivpnt(1,1)-divpnt(1,1))/(oppdivpnt(1,2)-divpnt(1,2));
                            if ((m==inf)||(m==-inf))
                                nn=abs(divpnt(1,1)-oppdivpnt(1,1))+1;
                                x(1:nn)=center(1,2);
                                y(1:nn)=linspace(divpnt(1,1),oppdivpnt(1,1),nn);
                            else
                                x=linspace(divpnt(1,2),oppdivpnt(1,2));
                                y=m*(x-divpnt(1,2))+divpnt(1,1);
                            end
                            index=sub2ind(d,round(y),round(x));
                            line(index)=255;

                            mask=mask|line;
                            clear  index y x m
                        end
                    elseif (Angle~=3)||((Angle==3)&&(((a(1,1)*b(1,1)==(4*BorderK))&&(a(1,2)*b(1,2)~=-((BorderK*2)^2)))||(a(1,2)*b(1,2)==(4*BorderK))&&(a(1,1)*b(1,1)~=-((BorderK*2)^2)))) 
                        divpnt=(a+b)+center;
                        oppdivpnt=(-1*(a+b))+center;
                        if divpnt(1,1)<=0                             
                            divpnt(1,1)=1;
                        end
                        if divpnt(1,2)<=0
                            divpnt(1,2)=1;
                        end
                        if divpnt(1,1)>=d(1,1)
                            divpnt(1,1)=d(1,1)-1;
                        end
                        if divpnt(1,2)>=d(1,2)
                            divpnt(1,2)=d(1,2)-1;
                        end
                        if oppdivpnt(1,1)<=0                             
                            oppdivpnt(1,1)=1;
                        end
                        if oppdivpnt(1,2)<=0
                            oppdivpnt(1,2)=1;
                        end
                        if oppdivpnt(1,1)>=d(1,1)
                            oppdivpnt(1,1)=d(1,1)-1;
                        end
                        if oppdivpnt(1,2)>=d(1,2)
                            oppdivpnt(1,2)=d(1,2)-1;
                        end
            
                        m=(oppdivpnt(1,1)-divpnt(1,1))/(oppdivpnt(1,2)-divpnt(1,2));
                        if ((m==inf)||(m==-inf))
                            nn=abs(divpnt(1,1)-oppdivpnt(1,1))+1;
                            x(1:nn)=center(1,2);
                            y(1:nn)=linspace(divpnt(1,1),oppdivpnt(1,1),nn);
                        else
                            x=linspace(divpnt(1,2),oppdivpnt(1,2));
                            y=m*(x-divpnt(1,2))+divpnt(1,1);
                        end
                        index=sub2ind(d,round(y),round(x));
                        line(index)=255;
                        
                        mask=mask|line;
                        clear  index y x m
            
                    end
                end
            end
        end
    end
end

mask2=mask&bw2;                                                                     
divBw= bw2-mask2;
end
