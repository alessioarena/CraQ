function varargout = savinGUI(varargin)
% SAVINGUI MATLAB code for savinGUI.fig
%      SAVINGUI, by itself, creates a new SAVINGUI or raises the existing
%      singleton*.
%
%      H = SAVINGUI returns the handle to a new SAVINGUI or the handle to
%      the existing singleton*.
%
%      SAVINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVINGUI.M with the given input arguments.
%
%      SAVINGUI('Property','Value',...) creates a new SAVINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before savinGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to savinGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help savinGUI

% Last Modified by GUIDE v2.5 23-Oct-2012 14:35:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @savinGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @savinGUI_OutputFcn, ...
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

% --- Outputs from this function are returned to the command line.
function varargout = savinGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% --- Executes just before savinGUI is made visible.
function savinGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to savinGUI (see VARARGIN)

% Choose default command line output for savinGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
setappdata(handles.save,'output',varargin{1});

% UIWAIT makes savinGUI wait for user response (see UIRESUME)
 uiwait(handles.savinGUI);





% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (strcmp(get(handles.statsTXT,'string'),'Path')==1 && get(handles.statsCB,'value')==1) ...
        || (strcmp(get(handles.labTXT,'string'),'Path')==1 && get(handles.labCB,'value')==1) ...
        || (strcmp(get(handles.divbwTXT,'string'),'Path')==1 && get(handles.divbwCB,'value')==1) ...
        || (strcmp(get(handles.delTXT,'string'),'Path')==1 && get(handles.delCB,'value')==1) ...
        || (strcmp(get(handles.histTXT,'string'),'Path')==1 && get(handles.histCB,'value')==1)
    msgbox('You have to choose all the paths before saving','Incorrect Path');
else
output=getappdata(handles.save,'output');
stats=output.stats;
SIZESTATS=size(stats);
if SIZESTATS(2)==7
    if output.conv==0
        header=sprintf('ID \t Area \t Length \t Width \t AspectRatio \t Orientation(rad Xaxis) \t Orientation(deg Xaxis) \t values in pixels');
    else
        header=sprintf('ID \t Area \t Length \t Width \t AspectRatio \t Orientation(rad Xaxis) \t Orientation(deg Xaxis) \t values in micron');
    end
    fid=fopen(get(handles.statsTXT,'string'),'w');
    fprintf(fid,'%s\r\n',header);
    fclose(fid);
    dlmwrite(get(handles.statsTXT,'string'),stats,'precision',4,'delimiter','\t','newline','pc','-append');
elseif SIZESTATS(2)==10
    if output.conv==0
        header=sprintf('ID \t Area \t Length \t Width \t AspectRatio \t Orientation(rad Xaxis) \t Orientation(deg Xaxis) \t Ferret length \t Ferret width \t Ferret orientation \t values in pixels');
    else
        header=sprintf('ID \t Area \t Length \t Width \t AspectRatio \t Orientation(rad Xaxis) \t Orientation(deg Xaxis) \t Ferret length \t Ferret width \t Ferret orientation \t values in micron');
    end
        fid=fopen(get(handles.statsTXT,'string'),'w');
    fprintf(fid,'%s\r\n',header);
    fclose(fid);
    dlmwrite(get(handles.statsTXT,'string'),stats,'precision',4,'delimiter','\t','newline','pc','-append');
end
a=1;
if get(handles.divbwCB,'Value')==1
    divBw=output.divBw;
    imwrite(divBw,get(handles.divbwTXT,'string'),'bmp');
    a=a+1;
end
if get(handles.labCB,'Value')==1
    rgb2=output.rgb2;
    lab=output.lab;
    imwrite(rgb2,get(handles.labTXT,'string'),'bmp');
    str=regexprep(get(handles.labTXT,'string'),'bmp','mat');
    save(str,'lab','-mat');
    a=a+2;
end
if get(handles.delCB,'Value')==1
    del=output.rgb1;
    imwrite(del,get(handles.delTXT,'string'),'bmp');
    a=a+1;
end
if get(handles.histCB,'Value')==1
    hist=output.hist;
    saveas(hist,get(handles.histTXT,'string'),'bmp');
    a=a+1;
end
msgbox(sprintf('%d files saved',a));
close savinGUI;
end

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('savinGUI');

% --- Executes on button press in Same.
function Same_Callback(hObject, eventdata, handles)
% hObject    handle to Same (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')==1
    set(handles.divbwBTN,'Enable','Off');
    set(handles.labBTN,'Enable','Off');
    set(handles.delBTN,'Enable','Off');
    set(handles.histBTN,'Enable','Off');
    set(handles.roseBTN,'Enable','Off');
else
    set(handles.divbwBTN,'Enable','On');
    set(handles.labBTN,'Enable','On');
    set(handles.delBTN,'Enable','On');
    set(handles.histBTN,'Enable','On');
    set(handles.roseBTN,'Enable','On');
end
% Hint: get(hObject,'Value') returns toggle state of Same



% --- Executes on button press in divbwCB.
function divbwCB_Callback(hObject, eventdata, handles)
% hObject    handle to divbwCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==1
    set(handles.divbwTXT,'Enable','On');
    if get(handles.Same,'Value')==0
        set(handles.divbwBTN,'Enable','On');
    end
else
    set(handles.divbwTXT,'Enable','Off');
    set(handles.divbwBTN,'Enable','Off');
end
% Hint: get(hObject,'Value') returns toggle state of divbwCB


% --- Executes on button press in labCB.
function labCB_Callback(hObject, eventdata, handles)
% hObject    handle to labCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==1
    set(handles.labTXT,'Enable','On');
    if get(handles.Same,'Value')==0
        set(handles.labBTN,'Enable','On');
    end
else
    set(handles.labTXT,'Enable','Off');
    set(handles.labBTN,'Enable','Off');
end
% Hint: get(hObject,'Value') returns toggle state of labCB


% --- Executes on button press in delCB.
function delCB_Callback(hObject, eventdata, handles)
% hObject    handle to delCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==1
    set(handles.delTXT,'Enable','On');
    if get(handles.Same,'Value')==0
        set(handles.delBTN,'Enable','On');
    end
else
    set(handles.delTXT,'Enable','Off');
    set(handles.delBTN,'Enable','Off');
end
% Hint: get(hObject,'Value') returns toggle state of delCB


% --- Executes on button press in histCB.
function histCB_Callback(hObject, eventdata, handles)
% hObject    handle to histCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==1
    set(handles.histTXT,'Enable','On');
    if get(handles.Same,'Value')==0
        set(handles.histBTN,'Enable','On');
    end
else
    set(handles.histTXT,'Enable','Off');
    set(handles.histBTN,'Enable','Off');
end
% Hint: get(hObject,'Value') returns toggle state of histCB



function statsTXT_Callback(hObject, eventdata, handles)
% hObject    handle to statsTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statsTXT as text
%        str2double(get(hObject,'String')) returns contents of statsTXT as a double


% --- Executes during object creation, after setting all properties.
function statsTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statsTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function divbwTXT_Callback(hObject, eventdata, handles)
% hObject    handle to divbwTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of divbwTXT as text
%        str2double(get(hObject,'String')) returns contents of divbwTXT as a double


% --- Executes during object creation, after setting all properties.
function divbwTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to divbwTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function labTXT_Callback(hObject, eventdata, handles)
% hObject    handle to labTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labTXT as text
%        str2double(get(hObject,'String')) returns contents of labTXT as a double


% --- Executes during object creation, after setting all properties.
function labTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delTXT_Callback(hObject, eventdata, handles)
% hObject    handle to delTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delTXT as text
%        str2double(get(hObject,'String')) returns contents of delTXT as a double


% --- Executes during object creation, after setting all properties.
function delTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function histTXT_Callback(hObject, eventdata, handles)
% hObject    handle to histTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of histTXT as text
%        str2double(get(hObject,'String')) returns contents of histTXT as a double


% --- Executes during object creation, after setting all properties.
function histTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to histTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roseTXT_Callback(hObject, eventdata, handles)
% hObject    handle to roseTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roseTXT as text
%        str2double(get(hObject,'String')) returns contents of roseTXT as a double


% --- Executes on button press in statsBTN.
function statsBTN_Callback(hObject, eventdata, handles)
% hObject    handle to statsBTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
statsPT=uigetdir;
set(handles.statsTXT,'string',[statsPT,'\stats.txt']);
if get(handles.Same,'Value')==1
    set(handles.divbwTXT,'string',[statsPT,'\divided.bmp']);
    set(handles.labTXT,'string',[statsPT,'\labeled.bmp']);
    set(handles.delTXT,'string',[statsPT,'\deleted.bmp']);
    set(handles.histTXT,'string',[statsPT,'\histograms.bmp']);
end




% --- Executes on button press in divbwBTN.
function divbwBTN_Callback(hObject, eventdata, handles)
% hObject    handle to divbwBTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
divPT=uigetdir;
set(handles.divbwTXT,'string',[divPT,'\divided.bmp']);

% --- Executes on button press in labBTN.
function labBTN_Callback(hObject, eventdata, handles)
% hObject    handle to labBTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
labPT=uigetdir;
set(handles.labTXT,'string',[labPT,'\labeled.bmp']);

% --- Executes on button press in delBTN.
function delBTN_Callback(hObject, eventdata, handles)
% hObject    handle to delBTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delPT=uigetdir;
set(handles.delTXT,'string',[delPT,'\deleted.bmp']);

% --- Executes on button press in histBTN.
function histBTN_Callback(hObject, eventdata, handles)
% hObject    handle to histBTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
histPT=uigetdir;
set(handles.histTXT,'string',[histPT,'\histograms.bmp']);
