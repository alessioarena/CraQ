function varargout = Supervised(varargin)
% SUPERVISED MATLAB code for Supervised.fig
%      SUPERVISED, by itself, creates a new SUPERVISED or raises the existing
%      singleton*.
%
%      H = SUPERVISED returns the handle to a new SUPERVISED or the handle to
%      the existing singleton*.
%
%      SUPERVISED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUPERVISED.M with the given input arguments.
%
%      SUPERVISED('Property','Value',...) creates a new SUPERVISED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Supervised_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Supervised_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Supervised

% Last Modified by GUIDE v2.5 12-Dec-2012 11:38:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Supervised_OpeningFcn, ...
                   'gui_OutputFcn',  @Supervised_OutputFcn, ...
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


% --- Executes just before Supervised is made visible.
function Supervised_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Supervised (see VARARGIN)

% Choose default command line output for Supervised
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


input=varargin{1};
figure(input.fig);
datacursormode on
setappdata(handles.add,'input',varargin{1});
setappdata(handles.add,'fig',input.fig)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Supervised wait for user response (see UIRESUME)
uiwait(handles.Supervised);


% --- Outputs from this function are returned to the command line.
function varargout = Supervised_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
output=getappdata(handles.add,'input');
varargout{1} = output;
fig=getappdata(handles.add,'fig');
close (fig)
close Supervised


% --- Executes on selection change in list.
function list_Callback(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list


% --- Executes during object creation, after setting all properties.
function list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list=get(handles.list,'string');
if length(list)<1; return; end;
n=get(handles.list,'value');
list=str2num(list);
list(n)=[];
list=num2str(list);
n=n-1;
if n==0
    n=1;
end
set(handles.list,'value',n);
set(handles.list,'string',list);


% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig=getappdata(handles.add,'fig');
figure(fig);
selected=getappdata(gca,'SelectedLabel');
set(handles.selected,'string',num2str(selected));

add=str2num(get(handles.selected,'string'));
list=str2num(get(handles.list,'string'));
if sum(list==add)==0
if isempty(list)
    new=num2str(add);
else new=num2str(vertcat(list,add));
end
set(handles.list,'string',new);
end


function selected_Callback(hObject, eventdata, handles)
% hObject    handle to selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selected as text
%        str2double(get(hObject,'String')) returns contents of selected as a double


% --- Executes during object creation, after setting all properties.
function selected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compute.
function compute_Callback(hObject, eventdata, handles)
% hObject    handle to compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list=str2num(get(handles.list,'string'));
input=getappdata(handles.add,'input');
stats=input.stats;
lab=input.lab;
for i=1:length(list)
    [idxs,c]=find(stats(:,1)==list(i));
    stats(idxs,:)=[];
    idxl=find(lab==list(i));
    lab(idxl)=0;
end
figure(input.fig);
input.stats=stats;
input.lab=lab;
setappdata(handles.add,'input',input);
uiresume(handles.Supervised);
% --- Executes on button press in display.
function display_Callback(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input=getappdata(handles.add,'input');
fig=getappdata(handles.add,'fig');
rgb=input.rgb2;
lab=input.lab;

list=str2num(get(handles.list,'string'));
for i=1:length(list)
    [r,c]=find(lab==list(i));
    for k=1:length(r)
        rgb(r(k),c(k),1)=255;
        rgb(r(k),c(k),2)=255;
        rgb(r(k),c(k),3)=255;
    end
end
figure(fig);
imshow(rgb);

stats=input.stats;
conv=input.conv;
developermode=input.developermode;
assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)},'conv',{conv},'developermode',{developermode});
setappdata(gca,'AssetData',assetData);
dcm_obj=datacursormode(fig);
set(dcm_obj,'UpdateFcn',@displayquery)
datacursormode on


% --- Executes on button press in Hide.
function Hide_Callback(hObject, eventdata, handles)
% hObject    handle to Hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input=getappdata(handles.add,'input');
fig=getappdata(handles.add,'fig');
rgb=input.rgb2;
lab=input.lab;

list=str2num(get(handles.list,'string'));
for i=1:length(list)
    [r,c]=find(lab==list(i));
    for k=1:length(r)
        rgb(r(k),c(k),1)=0;
        rgb(r(k),c(k),2)=0;
        rgb(r(k),c(k),3)=0;
    end
end
figure(fig);
imshow(rgb);

stats=input.stats;
conv=input.conv;
developermode=input.developermode;
assetData=struct('lab',{lab},'label',{stats(:,1)},'area',{stats(:,2)},'length',{stats(:,3)},'width',{stats(:,4)},'aspectratio',{stats(:,5)},'orientation',{stats(:,7)},'conv',{conv},'developermode',{developermode});
setappdata(gca,'AssetData',assetData);
dcm_obj=datacursormode(fig);
set(dcm_obj,'UpdateFcn',@displayquery)
datacursormode on
