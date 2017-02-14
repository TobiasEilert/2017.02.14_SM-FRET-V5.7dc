function varargout = menu_findGutPlot_parameters(varargin)
% MENU_FINDGUTPLOT_PARAMETERS M-file for menu_findGutPlot_parameters.fig
%      MENU_FINDGUTPLOT_PARAMETERS, by itself, creates a new MENU_FINDGUTPLOT_PARAMETERS or raises the existing
%      singleton*.
%
%      H = MENU_FINDGUTPLOT_PARAMETERS returns the handle to a new MENU_FINDGUTPLOT_PARAMETERS or the handle to
%      the existing singleton*.
%
%      MENU_FINDGUTPLOT_PARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MENU_FINDGUTPLOT_PARAMETERS.M with the given input arguments.
%
%      MENU_FINDGUTPLOT_PARAMETERS('Property','Value',...) creates a new MENU_FINDGUTPLOT_PARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before menu_findGutPlot_parameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to menu_findGutPlot_parameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help menu_findGutPlot_parameters

% Last Modified by GUIDE v2.5 21-Aug-2008 14:45:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @menu_findGutPlot_parameters_OpeningFcn, ...
                   'gui_OutputFcn',  @menu_findGutPlot_parameters_OutputFcn, ...
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


% --- Executes just before menu_findGutPlot_parameters is made visible.
function menu_findGutPlot_parameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to menu_findGutPlot_parameters (see VARARGIN)

% Choose default command line output for menu_findGutPlot_parameters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes menu_findGutPlot_parameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = menu_findGutPlot_parameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ED_maxZeroAcceptor_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxZeroAcceptor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxZeroAcceptor as text
%        str2double(get(hObject,'String')) returns contents of ED_maxZeroAcceptor as a double


% --- Executes during object creation, after setting all properties.
function ED_maxZeroAcceptor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxZeroAcceptor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_maxZeroDonor_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxZeroDonor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxZeroDonor as text
%        str2double(get(hObject,'String')) returns contents of ED_maxZeroDonor as a double


% --- Executes during object creation, after setting all properties.
function ED_maxZeroDonor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxZeroDonor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_maxSTDdonor_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxSTDdonor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxSTDdonor as text
%        str2double(get(hObject,'String')) returns contents of ED_maxSTDdonor as a double


% --- Executes during object creation, after setting all properties.
function ED_maxSTDdonor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxSTDdonor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_maxSTDFRET_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxSTDFRET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxSTDFRET as text
%        str2double(get(hObject,'String')) returns contents of ED_maxSTDFRET as a double


% --- Executes during object creation, after setting all properties.
function ED_maxSTDFRET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxSTDFRET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_maxDonorPeak_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxDonorPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxDonorPeak as text
%        str2double(get(hObject,'String')) returns contents of ED_maxDonorPeak as a double


% --- Executes during object creation, after setting all properties.
function ED_maxDonorPeak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxDonorPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_DonorOutPeak_Callback(hObject, eventdata, handles)
% hObject    handle to ED_DonorOutPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_DonorOutPeak as text
%        str2double(get(hObject,'String')) returns contents of ED_DonorOutPeak as a double


% --- Executes during object creation, after setting all properties.
function ED_DonorOutPeak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_DonorOutPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_maxNegative_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxNegative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxNegative as text
%        str2double(get(hObject,'String')) returns contents of ED_maxNegative as a double


% --- Executes during object creation, after setting all properties.
function ED_maxNegative_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxNegative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_maxDonorOut_Callback(hObject, eventdata, handles)
% hObject    handle to ED_maxDonorOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_maxDonorOut as text
%        str2double(get(hObject,'String')) returns contents of ED_maxDonorOut as a double


% --- Executes during object creation, after setting all properties.
function ED_maxDonorOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_maxDonorOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ED_DonorOutStep_Callback(hObject, eventdata, handles)
% hObject    handle to ED_DonorOutStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ED_DonorOutStep as text
%        str2double(get(hObject,'String')) returns contents of ED_DonorOutStep as a double


% --- Executes during object creation, after setting all properties.
function ED_DonorOutStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ED_DonorOutStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_OK.
function PB_OK_Callback(hObject, eventdata, handles)
% hObject    handle to PB_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


