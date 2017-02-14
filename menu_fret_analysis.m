function varargout = menu_fret_analysis(varargin)
% FIGURE1 M-file for figure1.fig
%      FIGURE1, by itself, creates a new FIGURE1 or raises the existing
%      singleton*.
%
%      H = FIGURE1 returns the handle to a new FIGURE1 or the handle to
%      the existing singleton*.
%
%      FIGURE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE1.M with the given input arguments.
%
%      FIGURE1('Property','Value',...) creates a new FIGURE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before menu_fret_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to menu_fret_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure1

% Last Modified by GUIDE v2.5 06-Aug-2008 14:00:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @menu_fret_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @menu_fret_analysis_OutputFcn, ...
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


% --- Executes just before figure1 is made visible.
function menu_fret_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figure1 (see VARARGIN)

% Choose default command line output for figure1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes figure1 wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = menu_fret_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
userData.alex = get(handles.CB_alex, 'Value');
rightbit = bitshift(get(handles.CB_cameraRight,'Value'),1);
leftbit = get(handles.CB_cameraLeft,'Value');
userData.cameraside = rightbit + leftbit;
userData.old_data = get(handles.PM_old_data,'Value') -1;
userData.smoothwidth = str2num(get(handles.ED_smoothwidth, 'String'));
userData.filter = get(handles.PM_filter,'Value');

varargout{1} = userData;
delete(handles.figure1);


% --- Executes on button press in cb_alex.
function CB_alex_Callback(hObject, eventdata, handles)
% hObject    handle to cb_alex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_alex



% --- Executes on button press in CB_cameraLeft.
function CB_cameraLeft_Callback(hObject, eventdata, handles)
% hObject    handle to CB_cameraLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_cameraLeft



% --- Executes on button press in CB_cameraRight.
function CB_cameraRight_Callback(hObject, eventdata, handles)
% hObject    handle to CB_cameraRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_cameraRight
if ~get(hObject,'Value')
    set(handles.CB_alex,'Value',0)
    set(handles.CB_alex,'Enable','off')
else
    set(handles.CB_alex,'Enable','on')
end


% --- Executes on selection change in PM_old_data.
function PM_old_data_Callback(hObject, eventdata, handles)
% hObject    handle to PM_old_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PM_old_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PM_old_data


% --- Executes during object creation, after setting all properties.
function PM_old_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM_old_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'String',{'New Data','Old Programme','Resume Analysis'})
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_OK.
function  PB_OK_Callback(hObject, eventdata, handles)
% hObject    handle to PB_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);



function ED_smoothwidth_Callback(hObject, eventdata, handles)
% hObject    handle to ED_smoothwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_smoothwidth as text
%        str2double(get(hObject,'String')) returns contents of ED_smoothwidth as a double


% --- Executes during object creation, after setting all properties.
function ED_smoothwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_smoothwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PM_filter.
function PM_filter_Callback(hObject, eventdata, handles)
% hObject    handle to PM_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PM_filter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PM_filter




% --- Executes during object creation, after setting all properties.
function PM_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'Value',2);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


