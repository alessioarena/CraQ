function evaluate(bw,resflag)

ass(1)=0;
bss(1)=0;

bw=bwmorph(bw,'diag');                          %morphological filtering: adding diagonal pixels
bw=bwmorph(bw,'close');                        %morphological closing, dilatation follows by erosion
bw=bwmorph(bw,'spur');
bw=bwmorph(bw,'clean');

d=size(bw);
r=random('unid',d(1),d(1)*0.1,1);
c=random('unid',d(2),d(1)*0.1,1);
for i=1:length(r)
a{i}=find(bw(r(i),:));
end
for i=1:length(c)
b{i}=find(bw(:,c(i)));
end

for i=1:(d(1)*0.1)
    as=a{i};
    bs=b{i};
    for j=1:(length(as)-1)
        temp=as(j+1)-as(j);
        if temp>=3
            ass=horzcat(ass,temp);
        end
    end
    for j=1:(length(bs)-1)
        temp=bs(j+1)-bs(j);
        if temp>=3
            bss=horzcat(bss,temp);
        end
    end
end
ass(1)=[];
bss(1)=[];
Ma=mean(ass);
Mb=mean(bss);
mina=min(ass);
minb=min(bss);
maxa=max(ass);
maxb=max(bss);
[ca,xa]=hist(ass,500);
[cb,xb]=hist(bss,500);
cc1(1,1)=ca(1);
cc2(1,1)=cb(1);
cc1(1,2)=cc1(1,1)/length(ass);
cc2(1,2)=cc2(1,1)/length(bss);
for i=2:500
    cc1(i,1)=ca(i)+cc1(i-1,1);
    cc2(i,1)=cb(i)+cc2(i-1,1);
    cc1(i,2)=cc1(i,1)/length(ass);
    cc2(i,2)=cc2(i,1)/length(bss);
end

%figure, scatter(xa,cc1(:,2));
%figure, scatter(xb,cc2(:,2));

temp2a=abs(cc1(:,2)-0.2);
temp2b=abs(cc2(:,2)-0.2);
temp3a=abs(cc1(:,2)-0.3);
temp3b=abs(cc2(:,2)-0.3);
temp4a=abs(cc1(:,2)-0.4);
temp4b=abs(cc2(:,2)-0.4);
temp5a=abs(cc1(:,2)-0.5);
temp5b=abs(cc2(:,2)-0.5);

[i2a,i2a]=min(temp2a);
[i2b,i2b]=min(temp2b);
[i3a,i3a]=min(temp3a);
[i3b,i3b]=min(temp3b);
[i4a,i4a]=min(temp4a);
[i4b,i4b]=min(temp4b);
[i5a,i5a]=min(temp5a);
[i5b,i5b]=min(temp5b);

v2a=xa(i2a);
v2b=xb(i2b);
v3a=xa(i3a);
v3b=xb(i3b);
v4a=xa(i4a);
v4b=xb(i4b);
v5a=xa(i5a);
v5b=xb(i5b);
if v2a<v2b
    v2=v2a;
else
    v2=v2b;
end
if v3a<v3b
    v3=v3a;
else
    v3=v3b;
end
if v4a<v4b
    v4=v4a;
else
    v4=v4b;
end
if v5a<v5b
    v5=v5a;
else
    v5=v5b;
end
if resflag==1
    v2=v2*2;
    v3=v3*2;
    v4=v4*2;
    v5=v5*2;
end
msgbox(['evaluation of space between cracks',char(10),'20% are closer then ',num2str(round(v2)),' pixels',char(10),'30% are closer then ',num2str(round(v3)),' pixels',char(10),'40% are closer then ',num2str(round(v4)),' pixels',char(10),'50% are closer then ',num2str(round(v5)),' pixels'],'Evaluate');
clear ass bss
