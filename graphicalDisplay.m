function varargout = graphicalDisplay(varargin)
% GRAPHICALDISPLAY M-file for graphicalDisplay.fig
%      GRAPHICALDISPLAY, by itself, creates a new GRAPHICALDISPLAY or raises the existing
%      singleton*.
%
%      H = GRAPHICALDISPLAY returns the handle to a new GRAPHICALDISPLAY or the handle to
%      the existing singleton*.
%
%      GRAPHICALDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAPHICALDISPLAY.M with the given input arguments.
%
%      GRAPHICALDISPLAY('Property','Value',...) creates a new GRAPHICALDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before graphicalDisplay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to graphicalDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help graphicalDisplay

% Last Modified by GUIDE v2.5 19-Nov-2009 20:58:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @graphicalDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @graphicalDisplay_OutputFcn, ...
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

handles.selectedCells = [];
% End initialization code - DO NOT EDIT


% --- Executes just before graphicalDisplay is made visible.
function graphicalDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to graphicalDisplay (see VARARGIN)

% Choose default command line output for graphicalDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes graphicalDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = graphicalDisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

handles.selectedCells = eventdata.Indices;


%update the gui data
guidata(hObject, handles);



%Fill with Coarse Data.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global turbineSelectionCoarseData
global dataType
cnames = {'Rated Flow (m3/s)','Pipe Diameter (m)','Pipe Material','Turbine Type (no)','Max Flow Rate (m3/s)','Max Power Generation (W)','Energy Generation (W-h)','Capacity Factor','rpm','Actual Diameter (m)','Turbine Cost (£)','Pipe Costs (£)','Generator Costs(£)','Payback Period (Years)','15 Year Profit (£)','15 Year Costs (£)','15 Year Revenue (£)','Delta H (m)','Net Head at Rated (m)','Static Head (m)','Pipe Length (m)','Intake X','Intake Y','Powerhouse Index',}; 
set(handles.uitable1,'data',turbineSelectionCoarseData)
set(handles.uitable1,'ColumnName',cnames)

%store data type currently selected
dataType=0;

%Fill with Fine Data.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global turbineSelectionFineData
global dataType

cnames = {'Rated Flow (m3/s)','Pipe Diameter (m)','Pipe Material','Turbine Type (no)','Max Flow Rate (m3/s)','Max Power Generation (W)','Energy Generation (W-h)','Capacity Factor','rpm','Actual Diameter (m)','Turbine Cost (£)','Pipe Costs (£)','Generator Costs(£)','Payback Period (Years)','15 Year Profit (£)','15 Year Costs (£)','15 Year Revenue (£)','Delta H (m)','Net Head at Rated (m)','Static Head (m)','Pipe Length (m)','Intake X','Intake Y','Powerhouse Index',}; 
set(handles.uitable1,'data',turbineSelectionFineData)
set(handles.uitable1,'ColumnName',cnames)

%store data type currently selected
dataType=1;

% Displays a plot also showing the profit intensity
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global heightValues;
global turbineSelectionFineData;

%create surrounding height map
filledList=heightValues*2e3;

%fill with profits at points
for i=1:100
    x=turbineSelectionFineData(i,22);
    y=turbineSelectionFineData(i,23);
    
    filledList(x,y)=turbineSelectionFineData(i,15);
    
end

%display
figure
imshow(filledList,'DisplayRange',[1e3,max(turbineSelectionFineData(:,15))])


% Displays a flow duration curve of selected points
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.selectedCells;
cells = (handles.selectedCells);

tableData = get(handles.uitable1,'data');

%create image
global heightValues
global powerHouseData
global dataType
global A90
global A90Weekly
figure

intakeX=tableData(cells(1,1),cells(1,2));
intakeY=tableData(cells(2,1),cells(2,2));

%display graph, data depends on currently displayed coarse/fine results

if dataType==0

FDY=A90(intakeX,intakeY,:);
FDX=1:((1/10)*100):100;
FDY=reshape(FDY,1,10);

%re-convert to before Q90 was applied

FDY=FDY-FDY(10);

elseif dataType==1
intakeX,intakeY
FDY=A90Weekly(intakeX,intakeY,:);
FDX=1:((1/52)*100):100;
FDY=reshape(FDY,1,52);

%re-convert to before Q90 was applied
FDY=FDY-FDY(52);
end

plot (FDX,FDY)

title(sprintf('Flow Duration Curve for [%d,%d]',intakeX,intakeY) );
xlabel({'% Exceedence'});
ylabel({'Flow (m^3/s)'});

%View map with selected data points
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedCells
cells = (handles.selectedCells)

tableData = get(handles.uitable1,'data');

%create image
global heightValues
global powerHouseData
figure
heightValues
powerHouseData
imshow(heightValues, [1 1000], 'InitialMagnification', 'fit')


hold on
%place quivers
intakeX=tableData(cells(1,1),cells(1,2))
intakeY=tableData(cells(2,1),cells(2,2))
powerHouseNo=tableData(cells(3,1),cells(3,2))
powerHouseInfo=powerHouseData(powerHouseNo,:)

powerHouseX=powerHouseInfo(1,1)/50
powerHouseY=powerHouseInfo(1,2)/50

%quiver intake
hold on
quiver (intakeY, intakeX, 00,00,'xr')

%quiver powerhouse
hold on
quiver (powerHouseX,powerHouseY, 00,00,'or')

hold off






% --- Executes during object creation, after setting all properties.
function pushbutton3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


