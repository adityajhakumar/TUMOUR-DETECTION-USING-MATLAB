function varargout = Brain_Tumor_Detector(varargin)
% BRAIN_TUMOR_DETECTOR MATLAB code for Brain_Tumor_Detector.fig
%      BRAIN_TUMOR_DETECTOR, by itself, creates a new BRAIN_TUMOR_DETECTOR or raises the existing
%      singleton*.
%
%      H = BRAIN_TUMOR_DETECTOR returns the handle to a new BRAIN_TUMOR_DETECTOR or the handle to
%      the existing singleton*.
%
%      BRAIN_TUMOR_DETECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAIN_TUMOR_DETECTOR.M with the given input arguments.
%
%      BRAIN_TUMOR_DETECTOR('Property','Value',...) creates a new BRAIN_TUMOR_DETECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Brain_Tumor_Detector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Brain_Tumor_Detector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Brain_Tumor_Detector

% Last Modified by GUIDE v2.5 23-Feb-2022 05:01:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Brain_Tumor_Detector_OpeningFcn, ...
                   'gui_OutputFcn',  @Brain_Tumor_Detector_OutputFcn, ...
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


% --- Executes just before Brain_Tumor_Detector is made visible.
function Brain_Tumor_Detector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Brain_Tumor_Detector (see VARARGIN)

% Choose default command line output for Brain_Tumor_Detector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Brain_Tumor_Detector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Brain_Tumor_Detector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_mage.
function select_mage_Callback(hObject, eventdata, handles)
% hObject    handle to select_mage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img1 img2

[path, nofile] = imgetfile();

if nofile
    msgbox(sprintf('Image not found!!!'), 'Error', 'Warning');
    return
end

img1 = imread(path);
img1 = im2double(img1);
img2 = img1;

axes(handles.axes1);
imshow(img1);
title('\fontsize{20}\color[rgb]{1,0,1} MRI Image');


% --- Executes on button press in meadian_filtering.
function meadian_filtering_Callback(hObject, eventdata, handles)
% hObject    handle to meadian_filtering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img1
axes (handles.axes2)
if size(img1,3) == 3
    img1 = rgb2gray(img1);
end
K = medfilt2(img1);
axes(handles.axes2);
imshow(K);title('\fontsize{20}\color[rgb]{1,0,1} Med Filtter');

% --- Executes on button press in edge_detection.
function edge_detection_Callback(hObject, eventdata, handles)
% hObject    handle to edge_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img1
axes(handles.axes3);

if size(img1,3) == 3
    img1 = rgb2gray(img1);
end
K = medfilt2(img1);
C = double(K);

for i = 1:size(C,1)-2
    for j = 1:size(C,2)-2
        %Sobel mask for X-direction
        Gx = ((2*C(i+2,j+1)+ C(i+2,j)+C(i+2,j+2))-(2*C(i,j+1)+C(i,j)+C(i,j+2)));
        %Sobel mask for Y-Dirction
        Gy = ((2*C(i+1,j+2)+ C(i,j+2)+C(i+2,j+2))-(2*C(i+1,j)+C(i,j)+C(i+2,j)));
        
        %The Gradient of The Image
        % B(i,j) abs(Gx) + abs(Gy)
        B(i,j) = sqrt(Gx.^2+Gy.^2);
    end
end
axes(handles.axes3)
imshow(B);title('\fontsize{20}\color[rgb]{1,0,1} Edge Detection');


% --- Executes on button press in tumor_detection.
function tumor_detection_Callback(hObject, eventdata, handles)
% hObject    handle to tumor_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img1
axes(handles.axes4);
K = medfilt2(img1);
bw = imbinarize(K, 0.7);
label = bwlabel(bw);

stats = regionprops(label,'Solidity','Area');
density  = [stats.Solidity];
area = [stats.Area];
high_dense_area = density > 0.5;
max_area = max(area(high_dense_area));
tumor_label = find(area == max_area);
tumor = ismember(label,tumor_label);

se = strel('square',5);
tumor = imdilate(tumor,se);

Bound = bwboundaries(tumor,'noholes');
imshow(K);
hold on
for i = 1:length(Bound)
    plot(Bound{i}(:,2),Bound{i}(:,1), 'y','linewidth',1.75)
end
title('\fontsize{20}\color[rgb]{1,0,1} Tumor Detected !!!');

hold off
axes(handles.axes4)
