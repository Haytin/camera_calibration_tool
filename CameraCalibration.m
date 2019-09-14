function varargout = CameraCalibration(varargin)
% CAMERACALIBRATION MATLAB code for CameraCalibration.fig
%      CAMERACALIBRATION, by itself, creates a new CAMERACALIBRATION or raises the existing
%      singleton*.
%
%      H = CAMERACALIBRATION returns the handle to a new CAMERACALIBRATION or the handle to
%      the existing singleton*.
%
%      CAMERACALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAMERACALIBRATION.M with the given input arguments.
%
%      CAMERACALIBRATION('Property','Value',...) creates a new CAMERACALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CameraCalibration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CameraCalibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% Edit the above text to modify the response to help CameraCalibration

% Last Modified by GUIDE v2.5 13-Aug-2017 22:00:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CameraCalibration_OpeningFcn, ...
                   'gui_OutputFcn',  @CameraCalibration_OutputFcn, ...
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


% --- Executes just before CameraCalibration is made visible.
function CameraCalibration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CameraCalibration (see VARARGIN)

% Choose default command line output for CameraCalibration

%--- default settings
clc
%get toolbar
set(hObject,'toolbar','figure') 
handles.output = hObject;


% set default img
axis(handles.mainaxes); 
default_img = imread('default_img.png');
imshow(default_img);

% set table sizes
set(handles.uitable_K,'Data', cell(3,3) )
set(handles.uitable_Rt,'Data', cell(3,4))
set(handles.uitable_params,'Data', cell(4,1))

%--- inital values
handles.objpoints = [];
handles.imgpoints = [];
handles.img_undistorted = [];
handles.K = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CameraCalibration wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CameraCalibration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% -*-*-*-*-*-*-*-*-*-*-*-*  CALIBRATION PANEL *-*-*-*-*-*-*-*-*-*-*-*-*-*-*
% *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

% --- PUSHBUTTON: load img points
function pb_loadimgpoints_Callback(hObject, eventdata, handles)
    
    % choose and save img points   
    [pathname,dirname] = uigetfile();
    imgstruct = load(fullfile(dirname, pathname));
    names = fieldnames(imgstruct);
    imgstring = names{1,1};
    imgpoints = getfield(imgstruct,imgstring);   
    % check if img points are homogeneous and three dimensional
    if size(imgpoints,1) ~= 3
        errordlg('Please load  3xn vector of homogeneous image points ',...
                     'ERROR')  
    else 
        %show 'loaded' status
        handles.imgpoints = imgpoints;
        set(handles.imgstatus,'String', 'loaded')
    end
    
guidata(hObject, handles);


% --- PUSHBUTTON: load marker points 
    function pb_loadobjpoints_Callback(hObject, eventdata, handles)
        
        % choose and save marker points   
        [pathname,dirname] = uigetfile();
        objstruct = load(fullfile(dirname, pathname));
        names = fieldnames(objstruct);
        objstring = names{1,1};
        objpoints = getfield(objstruct, objstring);
        % check if marker points are homogeneous and four dimensinonal
        if  size(objpoints,1) ~= 4
            errordlg('Please load  4xn vector of homogeneous object points ',...
                     'ERROR')  
        else 
            % show loading status
            handles.objpoints = objpoints;
            set(handles.objstatus,'String', 'loaded')
        end
        
guidata(hObject, handles);


% --- PUSHBUTTON: do calibration with given img and marker points
function pb_calibrate_Callback(hObject, eventdata, handles)
    
    % check if img and markerpoints are loaded
    objpoints = handles.objpoints;
    imgpoints = handles.imgpoints;
    if isempty(objpoints)
        errordlg('Please load object points first', 'ERROR')
    elseif isempty(imgpoints)
        errordlg('Please load image points first', 'ERROR')
    else   
        % message box    
        msgbox('Please make sure to have the right correspondence between IMG VECTOR and OBJECT VECTOR','NOTE','warn')    
        % check sign
        sign = str2num(get(handles.edit_sign, 'String')) 
        if isempty(sign) || sign ~= -1
            sign = 1;
        end
        % calibration 
        [K_dlt, Rt_dlt] = dlt(objpoints, imgpoints, sign);
        [K_opti, Rt_opti, rad_dist, tang_dist] = optimize(K_dlt, Rt_dlt, objpoints, imgpoints);    
        % get rotation angles around Z,Y,X axis
        [phi theta psi] = zyx_euler(Rt_opti(1:3,1:3));
        % get pixel pitch and calculate focal length
        x_pitch = str2num(get(handles.edit_xpitch,'String'));
        y_pitch = str2num(get(handles.edit_ypitch,'String'));
        if isempty(x_pitch) && isempty(y_pitch)
            f = 0;
        else 
            fs = [ K_opti(1,1)*x_pitch K_opti(2,2)*y_pitch];
            f = fs(1);
        end   
        % sava parameters and put in tables
        zyx_rot = [phi; theta; psi];
        handles.f = f;   
        handles.zyx_rot = zyx_rot;
        handles.K = K_opti;
        handles.Rt = Rt_opti;
        handles.rad_dist = rad_dist;
        handles.tang_dist = tang_dist;
        set(handles.uitable_K,'Data', K_opti)
        set(handles.uitable_Rt,'Data', Rt_opti)
        set(handles.uitable_params,'Data', [f; zyx_rot] ) 
    end 
    
guidata(hObject, handles);


% --- PUSHBUTTON: save calibration data to directory
function pb_savedata_Callback(hObject, eventdata, handles)

    data = struct('K', handles.K, 'Rt', handles.Rt, 'f', handles.f,...
                  'zyx_rot', handles.zyx_rot, 'rad_dist', ...
                   handles.rad_dist, 'tang_dist', handles.tang_dist);   
    dirname = uigetdir;
    save(fullfile(dirname,'calib_data.mat'), 'data')


    
    
% -*-*-*-*-*-*-*-*-*-*-*-*  UNDISTORT PANEL *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
% *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
% --- PUSHBUTTON: load file to undistort
function pb_loadfile_Callback(hObject, eventdata, handles)
      
    [pathname,dirname] = uigetfile({'*.jpg;*.bmp;*.tif;*.png;*.gif','All Image Files';'*.*','All Files' });
    img_distorted = imread(fullfile(dirname, pathname));
    handles.img_distorted=  img_distorted;
    axis(handles.mainaxes);
    imagesc(img_distorted)
 
guidata(hObject, handles);
 
 


% --- PUSHBUTTON: clear file and set default img
function pb_clearfile_Callback(hObject, eventdata, handles)
    cla (handles.mainaxes, 'reset');
    axis(handles.mainaxes); 
    default_img = imread('default_img.png');
    imshow(default_img);

% --- PUSHBUTTON: undistort img
function pb_undistort_Callback(hObject, eventdata, handles)

    % check if calibration was done
    K_opti = handles.K;
    if isempty(K_opti)
        errordlg('please calibrate first!', 'ERROR')
    else 
        w = waitbar(0,'Please wait');    
        img_distorted = handles.img_distorted;
        rad_dist = handles.rad_dist;
        tang_dist = handles.tang_dist;    
        % undistort img
        img_undistorted = undistort_real(img_distorted, rad_dist, tang_dist, K_opti);
        waitbar(0.8)
        handles.img_undistorted = img_undistorted;
        waitbar(1)
        close(w)
        axis(handles.mainaxes);
        imagesc(img_undistorted)
    end

 guidata(hObject, handles);



% --- PUSHBUTTON: save undistorted img to directory
function pb_saveundistortedimg_Callback(hObject, eventdata, handles)

    % check if img was undistorted
    img_undistorted = handles.img_undistorted;
    if isempty(img_undistorted)
        errordlg('Please undistort first','ERROR')
    else
        dirname = uigetdir;
        %get mainaxes figure
        fh = figure;
        copyobj(handles.mainaxes, fh)
        saveas(fh, fullfile(dirname, 'img_undistorted.fig'))
        close(fh)
        save(fullfile(dirname,'img_undistorted.mat'), 'img_undistorted')
    end

    
% *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
% *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*




function edit_xpitch_Callback(hObject, eventdata, handles)

function edit_xpitch_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_ypitch_Callback(hObject, eventdata, handles)

function edit_ypitch_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_sign_Callback(hObject, eventdata, handles)

function edit_sign_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
