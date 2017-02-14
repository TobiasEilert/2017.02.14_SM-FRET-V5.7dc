function varargout = menu_batch_analysis(varargin)
% MENU_BATCH_ANALYSIS M-file for menu_batch_analysis.fig
%      MENU_BATCH_ANALYSIS, by itself, creates a new MENU_BATCH_ANALYSIS or raises the existing
%      singleton*.
%
%      H = MENU_BATCH_ANALYSIS returns the handle to a new MENU_BATCH_ANALYSIS or the handle to
%      the existing singleton*.
%
%      MENU_BATCH_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MENU_BATCH_ANALYSIS.M with the given input arguments.
%
%      MENU_BATCH_ANALYSIS('Property','Value',...) creates a new MENU_BATCH_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before menu_batch_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to menu_batch_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help menu_batch_analysis

% Last Modified by GUIDE v2.5 21-May-2010 10:09:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @menu_batch_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @menu_batch_analysis_OutputFcn, ...
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


% --- Executes just before menu_batch_analysis is made visible.
function menu_batch_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to menu_batch_analysis (see VARARGIN)

% Choose default command line output for menu_batch_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes menu_batch_analysis wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command
% line.CB_cameraRight
function varargout = menu_batch_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
userData.thresh = get(handles.PM_threshold,'Value');
userData.start_frame = str2num(get(handles.ED_start_frame,'String'));
userData.stop_frame = str2num(get(handles.ED_stop_frame,'String'));
userData.half_region = str2num(get(handles.ED_half_region,'String'));
userData.alex = get(handles.CB_alex,'Value');
userData.correct_min = get(handles.CB_correct_min,'Value');
userData.correct_backgnd = get(handles.CB_correct_bckgnd,'Value');
rightbit = bitshift(get(handles.CB_cameraRight,'Value'),1);
leftbit = get(handles.CB_cameraLeft,'Value');
userData.cameraside = rightbit + leftbit;
userData.dual_cameras = get(handles.CB_dual_cam,'Value');
varargout{1} = userData;
delete(handles.figure1);

function PM_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to PM_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function PM_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'String',{'Very Low','Low','Medium','High','Extra High'},'Value',3)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_OK.
function PB_OK_Callback(hObject, eventdata, handles)
% hObject    handle to PB_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);



% --- Executes on button press in CB_alex.
function CB_alex_Callback(hObject, eventdata, handles)
% hObject    handle to CB_alex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_alex

% --- Executes on button press in CB_correct_bckgnd.
function CB_correct_bckgnd_Callback(hObject, eventdata, handles)
% hObject    handle to CB_correct_bckgnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_correct_bckgnd



function ED_half_region_Callback(hObject, eventdata, handles)
% hObject    handle to ED_half_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_half_region as text
%        str2double(get(hObject,'String')) returns contents of ED_half_region as a double


% --- Executes during object creation, after setting all properties.
function ED_half_region_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_half_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_stop_frame_Callback(hObject, eventdata, handles)
% hObject    handle to ED_stop_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_stop_frame as text
%        str2double(get(hObject,'String')) returns contents of ED_stop_frame as a double


% --- Executes during object creation, after setting all properties.
function ED_stop_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_stop_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_start_frame_Callback(hObject, eventdata, handles)
% hObject    handle to ED_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_start_frame as text
%        str2double(get(hObject,'String')) returns contents of ED_start_frame as a double


% --- Executes during object creation, after setting all properties.
function ED_start_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_correct_min.
function CB_correct_min_Callback(hObject, eventdata, handles)
% hObject    handle to CB_correct_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_correct_min


% --- Executes on button press in CB_cameraRight.
function CB_cameraRight_Callback(hObject, eventdata, handles)
% hObject    handle to CB_cameraRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_cameraRight
%if ~get(hObject,'Value')
 %   set(handles.CB_alex,'Value',0)
  %  set(handles.CB_alex,'Enable','off')
%else
 %   set(handles.CB_alex,'Enable','on')
%end

% --- Executes on button press in CB_cameraLeft.
function CB_cameraLeft_Callback(hObject, eventdata, handles)
% hObject    handle to CB_cameraLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_cameraLeft


% --- Executes on button press in CB_dual_cam.
function CB_dual_cam_Callback(hObject, eventdata, handles)
% hObject    handle to CB_dual_cam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_dual_cam
handles = guihandles(hObject);
if get(hObject,'Value')
    set(handles.CB_cameraLeft, 'Value', 0);
    set(handles.CB_cameraLeft,'Enable','off');
    set(handles.CB_cameraRight,'Value',0)
    set(handles.CB_cameraRight,'Enable','off')
else
    set(handles.CB_cameraLeft,'Value',1)
    set(handles.CB_cameraLeft,'Enable','on')
    set(handles.CB_cameraRight,'Value',1)
    set(handles.CB_cameraRight,'Enable','on')
end
