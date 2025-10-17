function [stats,prova,rosedata]=Orientation(lab,stats,skel,gs)

prova=0;
d=size(lab);
crack=zeros(size(lab));
h=waitbar(0,'Calculating the orientation of cracks..');
y=size(stats);
for i=1:y(1)
    a=stats(i,1);
    idx=(lab==a);
    crack=skel&idx;
    tips=bwmorph(crack,'endpoints');
    [r,c]=find(tips);
    for j=1:length(r)
        r(j)=d(1)-r(j);
    end
    if isempty(r)
    else
    if length(r)>=3
        for j=2:length(r)
            a(j)=sqrt(((r(1)-r(j))^2)+(c(1)-c(j))^2);
        end
        row=find(a==max(a));
        tempr=r(row(1));
        tempc=c(row(1));
        r(row)=[];
        c(row)=[];
        r(end+1)=tempr; %#ok<*SAGROW>
        c(end+1)=tempc;
        clear a
        for j=1:(length(r)-1)
            a(j)=sqrt(((r(end)-r(j))^2)+(c(end)-c(j))^2);
        end
        row=find(a==max(a));
        tempr2=r(row(1));
        tempc2=c(row(1));
        r=[tempr,tempr2];
        c=[tempc,tempc2];
        clear tempc tempc2 tempr tempr2 row
    end
    Dr=abs(r(1)-r(2));
    Dc=abs(c(1)-c(2));
    if Dr>Dc
        clear m x y
        n=floor(Dr/gs);
        Dn=(Dr/gs)-n;
        if Dn<=0.6
            n=n-1;
        end
        if n==0
            m=(r(1)-r(2))/(c(1)-c(2));
            stats(i,6)=atan(m);
            prova=horzcat(prova,m); %#ok<*AGROW>
        else
            row=find(r==min(r));
            y(1)=r(row);
            x(1)=c(row);
            for j=1:n
                y(j+1)=y(1)+(j*gs);
                xs=find(crack(y(j+1),:));
                x(j+1)=d(1)-(floor(mean(xs)));
            end
            if Dr==0
                y(end+1)=y(1);
            else
                y(end+1)=r(r~=y(1));
            end
            if Dc==0
                x(end+1)=x(1);
            else
                x(end+1)=c(c~=x(1));
            end
            idxNaN=find(isnan(x));
            if ~isempty(idxNaN)
                y(idxNaN)=[];
                x(idxNaN)=[];
                clear idxNaN
            end
            for j=1:(length(x)-1)
                m(j)=atan((y(j)-y(j+1))/(x(j)-x(j+1)));
            end
            prova=horzcat(prova,m);
            stats(i,6)=mean(m);
        end
    else
        clear m x y
        n=floor(Dc/gs);
        Dn=(Dc/gs)-n;
        if Dn<=0.6
            n=n-1;
        end
        if n==0
            m=(r(1)-r(2))/(c(1)-c(2));
            stats(i,6)=atan(m);
            prova=horzcat(prova,m);
        else
            row=find(c==min(c));
            y(1)=r(row);
            x(1)=c(row);
            for j=1:n
                x(j+1)=x(1)+(j*gs);
                ys=find(crack(:,x(j+1)));
                y(j+1)=d(1)-(floor(mean(ys)));
            end
            if Dr==0
                y(end+1)=y(1);
            else
                y(end+1)=r(r~=y(1));
            end
            if Dc==0
                x(end+1)=x(1);
            else
                x(end+1)=c(c~=x(1));
            end
            idxNaN=find(isnan(y));
            if ~isempty(idxNaN)
                y(idxNaN)=[];
                x(idxNaN)=[];
                clear idxNaN
            end
            for j=1:(length(x)-1)
                m(j)=atan((y(j)-y(j+1))/(x(j)-x(j+1)));
            end
            prova=horzcat(prova,m);
            stats(i,6)=mean(m);
        end 
    end
    end
    stats(i,7)=(stats(i,6)*180/pi);

    
    if stats(i,7)>=45 || stats(i,7)<=-45
        coef=sqrt(1+(1/(tand(stats(i,7))^2)));
        stats(i,3)=stats(i,3)*coef;
        stats(i,4)=stats(i,4)*coef;
    else
        coef=sqrt(1+(tand(stats(i,7))^2));
        stats(i,4)=stats(i,4)*coef;
        stats(i,3)=stats(i,3)*coef;
    end
    waitbar(i/length(stats));
end
rosedata=stats(:,6);
for q=1:length(rosedata)
    rosedata(q)=rosedata(q)+pi;
end
rosedata=vertcat(stats(:,6),rosedata);
close(h);
end
        
                    
                
        

