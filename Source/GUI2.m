function varargout = GUI2(varargin)
% GUI2 MATLAB code for GUI2.fig
%      GUI2, by itself, creates a new GUI2 or raises the existing
%      singleton*.
%
%      H = GUI2 returns the handle to a new GUI2 or the handle to
%      the existing singleton*.
%
%      GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI2.M with the given input arguments.
%
%      GUI2('Property','Value',...) creates a new GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI2

% Last Modified by GUIDE v2.5 18-Jan-2013 16:00:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI2 is made visible.
function GUI2_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI2 (see VARARGIN)

% Choose default command line output for GUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
axes(handles.axes1);
setappdata(gca,'exit',1);
disp('application started');
% UIWAIT makes GUI2 wait for user response (see UIRESUME)
uiwait(handles.figure1);

function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
exit=getappdata(gca,'exit');
if exit==0
    setappdata(gca,'exit',1);
    output=getappdata(gca,'output');
    savestats=questdlg('Do you want to save?','Save','Yes','No','Yes');
    switch savestats
        case 'Yes'
         uiwait(savinGUI(output));  
    end
end
close('all');

function varargout = GUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure





function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

developermode=1; %also in Load

set(hObject,'Enable','Off');
ARFilt=str2double(get(handles.ARFilt,'string'));
ARBorder=str2double(get(handles.edit1,'String'));
FlagBorder=get(handles.Border,'Value');
px=str2double(get(handles.Conv1,'string'));
mc=str2double(get(handles.Conv2,'string'));
gs=get(handles.listbox3,'Value')+2;
kernelTop=(get(handles.Kernel,'Value')*2)+5;
kernelBot=(get(handles.KernelMin,'Value')*2)+5;
if get(handles.Radio110,'Value')==1
    Angle=3;
elseif get(handles.Radio120,'Value')==1
    Angle=2;
elseif get(handles.Radio135,'Value')==1
    Angle=1;
end
bw=getappdata(handles.axes1,'Assetdata');
resflag=getappdata(handles.axes1,'Resflag');

if exist('developermode')==0
    developermode=0;
end

if (isempty(ARBorder) && FlagBorder==1) ||(isnan(ARBorder) && FlagBorder==1) || ((ARBorder < 0 || ARBorder > 1)&& FlagBorder==1)
    msgbox(['Non valid input for Filtering',char(10),'Value of Aspect Ratio must be between 0 and 1',char(10),'Check and try again']);
elseif ARFilt>1 || ARFilt<0 || isempty(ARFilt) || isnan(ARFilt)
    msgbox(['Non valid input for Filtering',char(10),'Value of Aspect Ratio must be between 0 and 1',char(10),'Check and try again']);
elseif (isempty(px) && get(handles.ConvCB,'Value')==1) || (isnan(px) && get(handles.ConvCB,'Value')==1)
    msgbox(['Non valid input for Pixel Conversion',char(10),'Check and try again']);
elseif (isempty(mc) && get(handles.ConvCB,'Value')==1) || (isnan(mc) && get(handles.ConvCB,'Value')==1)
    msgbox(['Non valid input for Pixel Conversion',char(10),'Check and try again']);
elseif isempty(bw)
    msgbox('You have to load an image');
else
    if get(handles.ConvCB,'Value')==0
        conv=0;
    else
        conv=mc/px;
    end
    
    if kernelTop-kernelBot>0
        waitflag=0;
        if kernelTop-kernelBot==2
            matlabpool size;
            if ans~=2 && ans~=0
                waitflag=1;
                waittxt=msgbox(['Preparing the system for parallel computing',char(10),'please wait']);
                edithandle = findobj(waittxt,'Style','pushbutton');
                delete(edithandle);
                matlabpool close
                matlabpool open 2
            elseif ans==0
                waitflag=1;
                waittxt=msgbox(['Preparing the system for parallel computing',char(10),'please wait']);
                edithandle = findobj(waittxt,'Style','pushbutton');
                delete(edithandle);
                matlabpool open 2
            end
        elseif kernelTop-kernelBot>=4
            matlabpool size;
            if ans~=3 && ans~=0
                waitflag=1;
                waittxt=msgbox(['Preparing the system for parallel computing',char(10),'please wait']);
                edithandle = findobj(waittxt,'Style','pushbutton');
                delete(edithandle);
                matlabpool close
                matlabpool open 3
            elseif ans==0
                waitflag=1;
                waittxt=msgbox(['Preparing the system for parallel computing',char(10),'please wait']);
                edithandle = findobj(waittxt,'Style','pushbutton');
                delete(edithandle);
                matlabpool open 3
            end
        end
        if waitflag==1
            if ishandle(waittxt)==1
            close(waittxt);
            pause (0.5);
            end
        end
    end
        
    
    [stats,lab,rgb1,rgb2,fig,divBw,hist]=core(bw,kernelTop,kernelBot,Angle,gs,FlagBorder,ARBorder,conv,ARFilt,resflag,developermode);
    axes(handles.axes1);
    output=struct('stats',stats,'lab',lab,'rgb1',rgb1,'rgb2',rgb2,'divBw',divBw,'hist',hist,'fig',fig,'conv',conv);
    setappdata(gca,'exit',0);
    setappdata(gca,'output',output);
end

set(hObject,'Enable','On');
set(handles.Save,'Enable','On');
set(handles.Supervised,'Enable','On');

function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
setappdata(gca,'exit',1);
close all force;

function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

developermode=1; %also in Start


set(handles.figure1,'HandleVisibility','off');
close all;
set(handles.figure1,'HandleVisibility','On');
set(handles.Save,'Enable','Off');
set(handles.Supervised,'Enable','Off');
[name,path]=uigetfile({'*.jpg;*.bmp;*.tif;*.png;*.gif','All Image Files';'labeled.mat','Label file from previous analysis'});
if strcmp(name,'labeled.mat')
    load (strcat(path,name));
    importing=msgbox('Importing results from previous analysis','Importing');
    pause(0.5);
    LABELS=unique(lab);
    LABELS(1)=[];
    NUMLABELS=length(LABELS);
    MAP=rand(max(LABELS),3);
    MAP=(30+(225.*MAP))/255;
    rgb=label2rgb(lab,MAP,'k');
    divBW=im2bw(rgb,0.0001);
    OPENSTATS=0;
    while OPENSTATS==0
        [~,PATHSTATS]=uigetfile({'stats.txt','Geometrical descriptors from previous analysis'},'Geometrical descriptor file',strcat(path,'stats.txt'));
        if isequal(PATHSTATS,0)
            BUTTON=questdlg('File not found, do you want to recompute it?');
            switch BUTTON
                case 'Yes'
                    stats=zeros(NUMLABELS,5);
                    for I=1:NUMLABELS
                        ACTUALLABEL=LABELS(I);
                        IDX=(lab==ACTUALLABEL);
                        AREA=sum(sum(IDX));
                        stats(I,1)=ACTUALLABEL;
                        stats(I,2)=AREA;
                        SKEL=bwmorph(IDX,'thin',inf);
                        stats(I,3)=sum(sum(SKEL));
                        stats(I,4)=stats(I,2)/stats(I,3);
                        stats(I,5)=stats(I,4)/stats(I,3);
                        skel=bwmorph(divBW,'thin',inf);
                        gs=8;
                        [stats,~,~]=Orientation(lab,stats,skel,gs);
                        OPENSTATS=1;
                    end
                case 'No'
                    msgbox ('refiltering not implemented, try to load another file');
                case 'Cancel'
                    msgbox ('refiltering not implemented');
                    OPENSTATS=1;
            end
        else
            stats=dlmread(strcat(path,'stats.txt'),'\t',1,0);
            if isequal(LABELS,stats(:,1))
                close (importing);
                OPENSTATS=1;
                set(handles.Supervised,'Enable','On');
            else
                BUTTON=questdlg('stats.txt and labelled.mat do not match!!','What to do?','Open another file','Recompute it','Cancel','Open another file');
                switch BUTTON
                    case 'Open another file'
                    case 'Recompute it'
                        stats=zeros(NUMLABELS,5);
                        for I=1:NUMLABELS
                            ACTUALLABEL=LABELS(I);
                            IDX=(lab==ACTUALLABEL);
                            AREA=sum(sum(IDX));
                            stats(I,1)=ACTUALLABEL;
                            stats(I,2)=AREA;
                            SKEL=bwmorph(IDX,'thin',inf);
                            stats(I,3)=sum(sum(SKEL));
                            stats(I,4)=stats(I,2)/stats(I,3);
                            stats(I,5)=stats(I,4)/stats(I,3);
                            skel=bwmorph(divBW,'thin',inf);
                            gs=8;
                            [stats,~,~]=Orientation(lab,stats,skel,gs);
                            OPENSTATS=1;
                        end
                    case 'Cancel'
                        msgbox ('refiltering not implemented');
                        OPENSTATS=0;
                end
            end
        end
    end
    conv=0.5;
    dim=size(rgb);
    set(handles.ResolutionShow,'String',['Resolution:',num2str(dim(2)),'x',num2str(dim(1))]);
    axes(handles.axes1);
    imshow(divBW);
    rgbfig=figure;
    imshow(rgb);
    assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)},'FerretMax',{stats(:,8)},'FerretMin',{stats(:,9)},'FerretOrient',{stats(:,10)},'conv',{conv},'developermode',{developermode});
    setappdata(gca,'AssetData',assetData);
    dcm_obj=datacursormode(rgbfig);
    set(dcm_obj,'UpdateFcn',@displayquery)
    
    output=struct('stats',stats,'lab',lab,'rgb1',divBW,'rgb2',rgb,'divBw',divBW,'fig',rgbfig,'conv',conv,'developermode',{developermode});
    axes(handles.axes1);
    setappdata(gca,'output',output);
    
    msgbox ('results succesfully loaded');


    
else              
    bw=imread(strcat(path,name));
    resflag=0;
    dim=size(bw);
    if dim(1)<500 || dim(2)<500
        res=questdlg(sprintf('the size of the image is %dx%d\n Do you want to resize it?',dim(1),dim(2)),'Resize','No','Yes (2x)','No');
        switch res
            case 'Yes (2x)'
                resflag=1;
                dim=dim.*2;
        end
    end
    set(handles.ResolutionShow,'String',['Resolution:',num2str(dim(2)),'x',num2str(dim(1))]);
    axes(handles.axes1);
    imshow(bw);
    setappdata(gca,'Assetdata',bw);
    setappdata(gca,'Resflag',resflag);
    set(handles.PathShow,'String',strcat(path,name));
end

function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
setappdata(gca,'exit',1);
output=getappdata(gca,'output');
savinGUI(output);

function Supervised_Callback(hObject, eventdata, handles)
% hObject    handle to Supervised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
output=getappdata(gca,'output');

set(handles.figure1,'HandleVisibility','off');
set(output.fig,'HandleVisibility','off');
close all
set(handles.figure1,'HandleVisibility','on');
set(output.fig,'HandleVisibility','on');
figure(output.fig);
super=Supervised(output);
developermode=output.developermode;
output=super;
lab=output.lab;
stats=output.stats;
divBw=output.divBw;
conv=output.conv;



    d2=size(lab);
    ref=zeros(d2(1),d2(2));
    idx=find(divBw);
    ref(idx)=2;
    idx=find(lab);
    ref(idx)=1;
    
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
    ylab=(ylab./length(stats))*100;
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
    figure('units','normalized','outerposition',[0 0 0.5 1]), imshow(rgb1);
    bb=figure('units','normalized','outerposition',[0.5 0 0.5 1]);
    imshow(rgb2);
    assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)},'conv',{conv});
    setappdata(gca,'AssetData',assetData);
    dcm_obj=datacursormode(bb);
    set(dcm_obj,'UpdateFcn',@displayquery)
    
    output=struct('stats',stats,'lab',lab,'rgb1',rgb1,'rgb2',rgb2,'divBw',divBw,'hist',hist,'fig',fig,'conv',conv);
    setappdata(handles.axes1,'exit',0);
    setappdata(handles.axes1,'output',output);
    set(handles.Save,'Enable','On');


function Evaluate_Callback(hObject, eventdata, handles)
% hObject    handle to Evaluate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bw=getappdata(handles.axes1,'Assetdata');
if isempty(bw)
    msgbox('You have to load an image');
else
resflag=getappdata(handles.axes1,'Resflag');
evaluate(bw,resflag);
end


    

function Radio110_Callback(hObject, eventdata, handles)
% hObject    handle to Radio110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Start,'Enable','On');

if get(handles.Radio120,'Value')==1
    set(handles.Radio120,'Value',0);
end
if get(handles.Radio135,'Value')==1
    set(handles.Radio135,'Value',0);
end
if get(handles.KernelMin,'Value')==1
    set(handles.KernelMin,'Value',2)
    msgbox(['A kernel size of 7x7 is too small for resolving this angle, and won''t be tried',char(10),'Please check your choices']);
end

function Radio120_Callback(hObject, eventdata, handles)
% hObject    handle to Radio120 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Radio110,'Value')==1
    set(handles.Radio110,'Value',0);
end
if get(handles.Radio135,'Value')==1
    set(handles.Radio135,'Value',0);
end

function Radio135_Callback(hObject, eventdata, handles)
% hObject    handle to Radio135 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Radio110,'Value')==1
    set(handles.Radio110,'Value',0);
end
if get(handles.Radio120,'Value')==1
    set(handles.Radio120,'Value',0);
end


function Kernel_Callback(hObject, eventdata, handles)
% hObject    handle to Kernel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.Radio110,'Value')==1 && get(hObject,'Value')==1
    set(hObject,'Value',2);
end
min=get(handles.KernelMin,'Value');
max=get(hObject,'Value');
if max<min
    set(handles.KernelMin,'Value',(max));
end
min=get(handles.KernelMin,'Value');

set(handles.Times,'string',['(',num2str(max-min+1),' times)']);

function KernelMin_Callback(hObject, eventdata, handles)
% hObject    handle to KernelMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Radio110,'Value')==1 && get(hObject,'Value')==1
    set(hObject,'Value',2);
end
max=get(handles.Kernel,'Value');
min=get(hObject,'Value');
if max<min
    set(handles.Kernel,'Value',(min));
end
max=get(handles.Kernel,'Value');

set(handles.Times,'string',['(',num2str(max-min+1),' times)']);



function ARFilt_Callback(hObject, eventdata, handles)
% hObject    handle to ARFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Border_Callback(hObject, eventdata, handles)
% hObject    handle to Border (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')==1
    set(handles.edit1,'Enable','on')
elseif get(hObject,'Value')==0
    set(handles.edit1,'Enable','off')
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function ConvCB_Callback(hObject, eventdata, handles)
% hObject    handle to ConvCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')==0
    set(handles.Conv1,'Enable','Off');
    set(handles.Conv2,'Enable','Off');
elseif get(hObject,'Value')==1
    set(handles.Conv1,'Enable','On');
    set(handles.Conv2,'Enable','On');
end

function Conv1_Callback(hObject, eventdata, handles)
% hObject    handle to Conv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Conv2_Callback(hObject, eventdata, handles)
% hObject    handle to Conv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function ARFilt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ARFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    % --- Executes during object creation, after setting all properties.
function Kernel_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to Kernel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function KernelMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KernelMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function Conv1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Conv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function Conv2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Conv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
