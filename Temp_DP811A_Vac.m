function Temp_DP811A_Vac()

FontSize = 8;
delete(instrfind);
% handles.dp811a = visa('ni','USB0::0x1AB1::0x0E11::DP8D192700092::INSTR');
scrsz = get(0,'screensize');
handles.figure = figure('position',[scrsz(3)/6,scrsz(4)/6,2*scrsz(3)/3,2*scrsz(4)/3],'closerequestfcn',@CloseFig);

% construct the home
handles.home = uix.HBox('parent',handles.figure);
handles.TPVBox = uix.VBox('parent',handles.home);
handles.TempPanel = uix.Panel('parent',handles.TPVBox,'title','Temperature','padding',5,'fontsize',FontSize+5);
handles.PIDPanel = uix.Panel('parent',handles.TPVBox,'title','PID Parameter','padding',5,'fontsize',FontSize+5);
handles.DP811APanel = uix.Panel('parent',handles.home,'title','DP811A','padding',5,'fontsize',FontSize+5);
handles.DVVBox = uix.VBox('parent',handles.home);
handles.DP811APlotPanel = uix.Panel('parent',handles.DVVBox,'title','DP811A Plot','padding',5,'fontsize',FontSize+5);
handles.VacPanel = uix.Panel('parent',handles.DVVBox,'title','Vacuum','padding',5,'fontsize',FontSize+5);

% construct the Temperature Panel
handles.TempVBox = uix.VBox('parent',handles.TempPanel);
handles.TempParaGrid = uix.Grid('parent',handles.TempVBox);
handles.TempShow = uix.HButtonBox('parent',handles.TempVBox);
handles.Tempaxes = axes('parent',handles.TempVBox);
% handles.TempPlot = uix.HButtonBox('parent',handles.TempVBox);

uicontrol('parent',handles.TempParaGrid,'style','text','string','Serial','fontsize',FontSize+5);
handles.EmButt = uicontrol('parent',handles.TempParaGrid,'style','pushbutton','string','Emissivity','fontsize',FontSize+5,'callback',@Apply_Emissivity);
handles.TempSerial = uicontrol('parent',handles.TempParaGrid,'style','popupmenu','string',{'COM1','COM2',...
    'COM3','COM4','COM5','COM6','COM7','COM8','COM9','COM10'},'fontsize',FontSize+5);
handles.Emissivity = uicontrol('parent',handles.TempParaGrid,'style','popupmenu','string',{'0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'},'fontsize',FontSize+5);
set(handles.TempParaGrid,'width',[-1,-1],'height',[30,30],'spacing',5);

handles.ShowTemp = uicontrol('parent',handles.TempShow,'style','pushbutton','string','Display Temperature','fontsize',FontSize+1,'callback',@ShowTemp);
handles.Temp = uicontrol('parent',handles.TempShow,'style','edit','fontsize',FontSize+5);
set(handles.TempShow,'buttonsize',[120,30],'spacing',5);

% handles.TempPlotButt = uicontrol('parent',handles.TempPlot,'style','pushbutton','string','Plot Temperature','fontsize',FontSize+5,'callback',@PlotTemp);
% set(handles.TempPlot,'buttonsize',[200,30],'spacing',5);

set(handles.TempVBox,'height',[70,40,-1]);

% construct the PID Panel
handles.PIDVBox = uix.VBox('parent',handles.PIDPanel);
handles.PIDGrid = uix.Grid('parent',handles.PIDVBox);
uicontrol('parent',handles.PIDGrid,'style','text','string','Kp','fontsize',FontSize+5);
uicontrol('parent',handles.PIDGrid,'style','text','string','Ki','fontsize',FontSize+5);
uicontrol('parent',handles.PIDGrid,'style','text','string','Kd','fontsize',FontSize+5);
handles.Kp = uicontrol('parent',handles.PIDGrid,'style','edit','string','0.002','fontsize',FontSize+5);
handles.Ki = uicontrol('parent',handles.PIDGrid,'style','edit','string','0.001','fontsize',FontSize+5);
handles.Kd = uicontrol('parent',handles.PIDGrid,'style','edit','string','0','fontsize',FontSize+5);
set(handles.PIDGrid,'width',[-1,-1],'height',[30,30,30],'spacing',5);
uicontrol('parent',handles.PIDVBox,'style','text','string','Suggestion: Kp = 0.0015,Ki = 0.00017,Kd = 0 for SiC');
set(handles.PIDVBox,'height',[-1,30],'spacing',5);

set(handles.TPVBox,'height',[-1,170]);

% construct the DP811A Panel
handles.DP811AVBox = uix.VBox('parent',handles.DP811APanel);
handles.ParaGrid = uix.Grid('parent',handles.DP811AVBox);
handles.ParaTable = uitable('parent',handles.DP811AVBox,'columnname',{'Time','Temperature'},'columnwidth',{135,135},'columneditable',true,'data',[0,0]);
handles.ParaButt = uix.HButtonBox('parent',handles.DP811AVBox);
handles.RemainGrid = uix.Grid('parent',handles.DP811AVBox);

uicontrol('parent',handles.ParaGrid,'style','text','string','Cycles','fontsize',FontSize+5);
uicontrol('parent',handles.ParaGrid,'style','text','string','Sections','fontsize',FontSize+5);
uicontrol('parent',handles.ParaGrid,'style','text','string','MaxPower(W)','fontsize',FontSize+5,'foregroundcolor','r');
uicontrol('parent',handles.ParaGrid,'style','text','string','MaxCurrent(A)','fontsize',FontSize+5,'foregroundcolor','r');
uicontrol('parent',handles.ParaGrid,'style','text','string','MaxTemperature(°„C)','fontsize',FontSize+5,'foregroundcolor','r');
uicontrol('parent',handles.ParaGrid,'style','text','string','Range','fontsize',FontSize+5);
handles.Cycles = uicontrol('parent',handles.ParaGrid,'style','edit','string','1','fontsize',FontSize+5);
handles.Sections = uicontrol('parent',handles.ParaGrid,'style','edit','string','1',...
                   'keypressfcn',@KeyPress_Sections,'callback',@Callback_Sections,'fontsize',FontSize+5);
handles.MaxPower = uicontrol('parent',handles.ParaGrid,'style','edit','string','50','fontsize',FontSize+5,'foregroundcolor','r');
handles.MaxCurrent = uicontrol('parent',handles.ParaGrid,'style','edit','string','0.5','fontsize',FontSize+5,'foregroundcolor','r');
handles.MaxTemperature = uicontrol('parent',handles.ParaGrid,'style','edit','string','600','fontsize',FontSize+5,'foregroundcolor','r');
handles.Range = uicontrol('parent',handles.ParaGrid,'style','popupmenu','string',{'40V/5A','20V/10A'},'fontsize',FontSize+5);
set(handles.ParaGrid,'width',[200,-1],'height',[30,30,30,30,30,30],'spacing',5);

handles.Apply = uicontrol('parent',handles.ParaButt,'style','pushbutton','string','Apply','fontsize',FontSize+2,'callback',@Apply);
handles.Stop = uicontrol('parent',handles.ParaButt,'style','pushbutton','string','Stop','fontsize',FontSize+2,'callback',@Stop);
handles.Pause = uicontrol('parent',handles.ParaButt,'style','pushbutton','string','Pause','fontsize',FontSize+2,'callback',@Pause);
set(handles.ParaButt,'buttonsize',[80,50],'spacing',5,'padding',5);

uicontrol('parent',handles.RemainGrid,'style','text','string','Remaining Time','fontsize',FontSize+5);
uicontrol('parent',handles.RemainGrid,'style','text','string','Remaining Cycles','fontsize',FontSize+5);
uicontrol('parent',handles.RemainGrid,'style','text','string','Message','fontsize',FontSize+5);
handles.RemainingTime = uicontrol('parent',handles.RemainGrid,'style','edit','string','0');
handles.RemainingCycles = uicontrol('parent',handles.RemainGrid,'style','edit','string','0');
handles.Message = uicontrol('parent',handles.RemainGrid,'style','edit','string','Wait for operation','fontsize',FontSize+5,'foregroundcolor','r');
set(handles.RemainGrid,'width',[-1,-1],'height',[30,30,30],'spacing',5);

set(handles.DP811AVBox,'height',[200,-1,60,100],'spacing',5);

% construct the DP811A Plot Panel
handles.DP811APlotVBox = uix.VBox('parent',handles.DP811APlotPanel);
handles.DP811APlotParaGrid = uix.Grid('parent',handles.DP811APlotVBox);
handles.DP811Aaxes = axes('parent',handles.DP811APlotVBox);
handles.DP811APlotButtBox = uix.HButtonBox('parent',handles.DP811APlotVBox);

uicontrol('parent',handles.DP811APlotParaGrid,'style','text','string','Running Current','fontsize',FontSize+5);
uicontrol('parent',handles.DP811APlotParaGrid,'style','text','string','Running Voltage','fontsize',FontSize+5);
uicontrol('parent',handles.DP811APlotParaGrid,'style','text','string','Running Power','fontsize',FontSize+5);
handles.Current = uicontrol('parent',handles.DP811APlotParaGrid,'style','edit','string','0');
handles.Voltage = uicontrol('parent',handles.DP811APlotParaGrid,'style','edit','string','0');
handles.Power = uicontrol('parent',handles.DP811APlotParaGrid,'style','edit','string','0');
set(handles.DP811APlotParaGrid,'width',[-1,-1],'height',[30,30,30],'spacing',5)

handles.DP811APlotButt = uicontrol('parent',handles.DP811APlotButtBox,'style','pushbutton','string','Plot Current','fontsize',FontSize+5,'callback',@PlotCurrent);
set(handles.DP811APlotButtBox,'buttonsize',[120,30]);
set(handles.DP811APlotVBox,'height',[100,-1,40]);

% construct the Vacuum Panel
handles.VacVBox = uix.VBox('parent',handles.VacPanel);
handles.VacHBox1 = uix.HBox('parent',handles.VacVBox,'spacing',10);
handles.VacHBox2 = uix.HBox('parent',handles.VacVBox,'spacing',10);
handles.VacButtBox = uix.HButtonBox('parent',handles.VacVBox);
handles.VacGrid = uix.Grid('parent',handles.VacVBox);

uicontrol('parent',handles.VacHBox1,'style','text','string','Serial','fontsize',FontSize+5);
handles.VacSerial = uicontrol('parent',handles.VacHBox1,'style','popupmenu','string',...
    {'COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8','COM9','COM10'},'fontsize',FontSize+5);

handles.VacLocationButt = uicontrol('parent',handles.VacHBox2,'style','pushbutton','string','Location','fontsize',FontSize+5,'callback',@VacLocation);
handles.VacLocation = uicontrol('parent',handles.VacHBox2,'style','edit','fontsize',FontSize+5);

handles.ShowVac = uicontrol('parent',handles.VacButtBox,'style','pushbutton','string','Show Vacuum','fontsize',FontSize+5,'callback',@ShowVac);
set(handles.VacButtBox,'buttonsize',[120,30],'padding',5);

handles.label1 = uicontrol('parent',handles.VacGrid,'style','edit','string','MBE','fontsize',FontSize+5);
handles.label2 = uicontrol('parent',handles.VacGrid,'style','edit','string','STM','fontsize',FontSize+5);
handles.label1_Pres = uicontrol('parent',handles.VacGrid,'style','edit');
handles.label2_Pres = uicontrol('parent',handles.VacGrid,'style','edit');
set(handles.VacGrid,'width',[-1,-4],'height',[30,30],'spacing',5)

set(handles.VacVBox,'height',[30,30,40,90]);
set(handles.DVVBox,'height',[-1,200]);

guidata(handles.figure,handles);

end









