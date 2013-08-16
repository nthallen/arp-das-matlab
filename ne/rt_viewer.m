function varargout = rt_viewer(varargin)
% RT_VIEWER MATLAB code for rt_viewer.fig
%      RT_VIEWER, by itself, creates a new RT_VIEWER
%
%      H = RT_VIEWER returns the handle to a new RT_VIEWER
%
%      RT_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RT_VIEWER.M with the given input arguments.
%
%      RT_VIEWER('Property','Value',...) creates a new RT_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rt_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rt_viewer_OpeningFcn via varargin.
%
%      Properties:
%        'Scans': list of scan numbers, nominally increasing.
%        'Axes': array of axes parameters, one row per axis
%           margin_left min_width margin_right stretch_w ...
%             margin_top min_height margin_bottom stretch_h ...
%             x_group
%        'Name': string to put at top of gui
%        'Callback': Callback function (cannot be first property!)
%        'AppData': Data to be stored in handles.data.AppData

% function my_callback(handles, sv_axes)
% if nargin < 2
%   sv_axes = handles.Axes;
% end

% Edit the above text to modify the response to help rt_viewer

% Last Modified by GUIDE v2.5 14-Aug-2013 15:16:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rt_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @rt_viewer_OutputFcn, ...
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


% --- Executes just before rt_viewer is made visible.
function rt_viewer_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to rt_viewer
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rt_viewer (see VARARGIN)

% Choose default command line output for rt_viewer
handles.output = hObject;

% Update handles structure
% handles.data.Scans = [];
% handles.data.Index = 1;
handles.data.CloseRequested = 0;
FP = get(handles.scan_viewer, 'Position');
set(handles.scan_viewer,'UserData',pwd);
for i=1:2:length(varargin)-1
  if strcmpi(varargin{i},'Name')
      set(handles.scan_viewer,'Name',varargin{i+1});
  elseif strcmpi(varargin{i},'Axes')
      handles.data.Axes = varargin{i+1};
      if size(handles.data.Axes,2) ~= 9
          errordlg('Axes property has wrong dimensions');
          close(handles.scan_viewer);
          return;
      end
      Pos = Axes_Positions(handles);
      handles.Axes = zeros(size(Pos,1),1);
      figure(handles.scan_viewer);
      for j=1:size(Pos,1)
          handles.Axes(j) = axes('Units','pixels','Position',Pos(j,:));
          handles.data.xlim{j} = [];
          handles.data.ylim{j} = [];
      end
      handles.Zoom = zoom;
      handles.data.SavedPreZoomState = 'Start';
      set(handles.Zoom,'ActionPostCallback',@Zoom_PostCallback);
      set(handles.Zoom,'ActionPreCallback',@Zoom_PreCallback);
  elseif strcmpi(varargin{i},'AppData')
      handles.data.AppData = varargin{i+1};
  elseif strcmpi(varargin{i},'Callback')
      handles.data.Callback = varargin{i+1};
  else
      errordlg(sprintf('Unrecognized property: %s', varargin{i}));
      close(handles.scan_viewer);
      return;
  end
end
guidata(hObject, handles);
scan_display(handles);
handles = guidata(hObject);
guidata(hObject, handles);
set(hObject,'Interruptible','on');

% UIWAIT makes rt_viewer wait for user response (see UIRESUME)
% uiwait(handles.rt_viewer);


% --- Outputs from this function are returned to the command line.
function varargout = rt_viewer_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to rt_viewer
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = 0;
else
    varargout{1} = handles.output;
end

function scan_viewer_CloseRequestFcn(hObject, ~, ~)
% hObject    handle to rt_viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the rt_viewer
delete *.run
handles = guidata(hObject);
if strcmp(get(handles.Start,'label'),'Stop')
    handles.data.CloseRequested = 1;
    Start_Callback(handles.Start, [], handles);
else
    delete(hObject);
end

function scan_viewer_ResizeFcn(hObject, ~, handles)
if isfield(handles,'data') % first invocation comes before open fcn
    FP = get(handles.scan_viewer,'Position');
    % SP = get(handles.Slider,'Position');
    % Srm = get(handles.Slider,'UserData');
%     SP(3) = FP(3)-Srm-SP(1);
%     delta = 0;
%     if SP(3) < 60
%         delta = 60-SP(3);
%         SP(3) = 60;
%     end
%     set(handles.Slider,'Position',SP);
%     SP = get(handles.CrntScan,'Position');
%     Srm = get(handles.CrntScan','UserData');
%     SP(1) = FP(3)-Srm-SP(3)+delta;
%     set(handles.CrntScan,'Position',SP);
%     if delta > 0
%         FP(3) = FP(3) + delta;
%         set(handles.scan_viewer,'Position',FP);
%     end
    if ~isfield(handles,'Axes')
        handles.Axes = [];
    end
    if ~isfield(handles.data,'xlim')
        xl = handles.data.xlim{1};
    else
        xl = [];
    end
    Pos = Axes_Positions(handles);
    for j = 1:max(length(handles.Axes),size(Pos,1))
        if j > length(handles.Axes)
            handles.Axes(j) = axes('Units','pixels','Position',Pos(j,:));
            handles.data.xlim{j} = xl;
            handles.data.ylim{j} = [];
        elseif j > size(Pos,1)
            delete(handles.Axes(j));
        else
            set(handles.Axes(j),'Position',Pos(j,:));
        end
    end
    if size(Pos,1) < length(handles.Axes)
        handles.Axes = handles.Axes(1:size(Pos,1));
    end
    guidata(hObject,handles);
    drawnow;
end

function Pos = Axes_Positions(handles, fig)
Axes = handles.data.Axes;
if nargin < 2
    fig = handles.scan_viewer;
end
cur_y = 0;
min_width = sum(sum(Axes(:,1:3)));
min_height = sum(sum(Axes(:,4:7))) + cur_y;
FP = get(fig,'Position');
readjust = 0;
if (FP(3) < min_width)
    FP(3) = min_width;
    readjust = 1;
end
if (FP(4) < min_height)
    delta = min_height-FP(4);
    FP(2) = FP(2) - delta;
    FP(4) = min_height;
    readjust = 1;
end
if readjust
    set(fig,'Position',FP);
end
Pos = zeros(size(Axes,1),4);
v_stretch_wt = sum(Axes(:,8));
v_stretch_px = FP(4) - min_height;
for i = size(Pos,1):-1:1
    cur_y = cur_y + Axes(i,7);
    if v_stretch_wt > 0
        ht = round(v_stretch_px * Axes(i,8) / v_stretch_wt);
        v_stretch_px = v_stretch_px - ht;
        v_stretch_wt = v_stretch_wt - Axes(i,8);
    else
        ht = 0;
    end
    ht = ht + Axes(i,6);
    Pos(i,:) = [ Axes(i,1) cur_y FP(3)-Axes(i,1)-Axes(i,3) ht-1 ];
    cur_y = cur_y + ht + Axes(i,5);
end

% --------------------------------------------------------------------
function scan_display(handles)
guidata(handles.scan_viewer,handles);
if isfield(handles.data, 'Callback')
    handles.data.Callback(handles,'Draw',handles.Axes);
    % rt_viewer(handles.rt_viewer);
    zoom(handles.scan_viewer, 'reset');
    for i = 1:length(handles.Axes)
        if ~isempty(handles.data.xlim{i})
            set(handles.Axes(i),'xlim',handles.data.xlim{i});
        end
        if ~isempty(handles.data.ylim{i})
            set(handles.Axes(i),'ylim',handles.data.ylim{i});
        end
    end
end
drawnow;

function ExportPlot_Callback(~, ~, handles)
fig = figure;
Pos = Axes_Positions(handles, fig);
Axes = zeros(size(Pos,1),1);
for j=1:size(Pos,1)
    Axes(j) = axes('Units','pixels','Position',Pos(j,:));
end
for j=1:size(Pos,1)
    set(Axes(j),'Units','normalized');
end
handles.data.Callback(handles, 'Draw', Axes);
for i = 1:length(Axes)
    if ~isempty(handles.data.xlim{i})
        set(Axes(i),'xlim',handles.data.xlim{i});
    end
    if ~isempty(handles.data.ylim{i})
        set(Axes(i),'ylim',handles.data.ylim{i});
    end
end
addzoom;

% --------------------------------------------------------------------
function ZoomOn_Callback(~, ~, ~)
zoom on;

% --------------------------------------------------------------------
function ZoomOff_Callback(~, ~, ~)
zoom off;

% --------------------------------------------------------------------
function ZoomX_Callback(~, ~, ~)
zoom xon;

% --------------------------------------------------------------------
function ZoomY_Callback(~, ~, ~)
zoom yon;

function Zoom_PreCallback(hObject, ~)
handles = guidata(hObject);
handles.data.SavedPreZoomState = get(handles.Start,'label');
set(handles.Start,'label','Start');
% fprintf(1,'SavedPreZoomState = %s\n', handles.data.SavedPreZoomState);
guidata(hObject,handles);

function Zoom_PostCallback(hObject, eventdata)
handles = guidata(hObject);
% set(handles.Start,'label',handles.data.SavedPreZoomState);
motion = get(handles.Zoom,'Motion');
axes_idx = find(handles.Axes == eventdata.Axes);
xlim = [];
if strcmpi(motion,'horizontal') || strcmpi(motion,'both')
    zmode = get(eventdata.Axes,'xlimmode');
    if strcmp(zmode,'manual')
        xlim = get(eventdata.Axes,'xlim');
        handles.data.xlim{axes_idx} = xlim;
    elseif strcmp(zmode,'auto')
        handles.data.xlim{axes_idx} = [];
    end
    x_group = handles.data.Axes(axes_idx,9);
    for i = 1:length(handles.Axes)
        if i ~= axes_idx && handles.data.Axes(i,9) == x_group
            if isempty(xlim)
                set(handles.Axes(i),'xlimmode','auto');
            else
                set(handles.Axes(i),'xlim',xlim);
            end
            handles.data.xlim{i} = xlim;
        end
    end
end
if strcmpi(motion,'vertical') || strcmpi(motion,'both')
    zmode = get(eventdata.Axes,'ylimmode');
    if strcmp(zmode,'manual')
        ylim = get(eventdata.Axes,'ylim');
        handles.data.ylim{axes_idx} = ylim;
    elseif strcmp(zmode,'auto')
        handles.data.ylim{axes_idx} = [];
    end
end
guidata(hObject, handles);
if strcmp(handles.data.SavedPreZoomState, 'Stop')
    handles.data.SavedPreZoomState = 'Start';
    Start_Callback(handles.Start, [], handles);
end

% --- Executes during object creation, after setting all properties.
function scan_viewer_CreateFcn(~, ~, ~)
% hObject    handle to scan_viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function ExportData_Callback(~, ~, handles)
% hObject    handle to ExportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.data, 'Callback')
    handles.data.Callback(handles,'ExportData');
end

% --------------------------------------------------------------------
function Start_Callback(hObject, ~, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'label'),'Start')
    set(hObject,'label','Stop');
    scan_display(handles);
    while strcmp(get(hObject,'label'),'Stop') && handles.data.CloseRequested == 0
        handles = guidata(handles.scan_viewer);
        if isfield(handles.data, 'Callback')
            if handles.data.Callback(handles,'Acquire',handles.Axes) && ...
                    strcmp(get(hObject,'label'),'Stop')
                handles = guidata(hObject);
                scan_display(handles);
            end
        else
            set(hObject,'label','Start');
        end
    end
else
    set(hObject,'label','Start');
end


% --------------------------------------------------------------------
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
