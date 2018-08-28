function ShowTemp(hObject,~)

handles = guidata(hObject);

% mode = 'temp', in temperature measure mode
% mode = 'dp811a',in current mode
% mode = 0, free
global mode;
if strcmp(mode,'dp811a')==1
    warndlg('Please close dp811a block!');
    return;
end

delete(instrfind);
obj1_number = get(handles.TempSerial,'value');

switch obj1_number
    case 1
        obj1_name = 'COM1';
    case 2
        obj1_name = 'COM2';
    case 3
        obj1_name = 'COM3';
    case 4
        obj1_name = 'COM4';
    case 5
        obj1_name = 'COM5';
    case 6
        obj1_name = 'COM6';
    case 7
        obj1_name = 'COM7';
    case 8
        obj1_name = 'COM8';
    case 9
        obj1_name = 'COM9';
    case 10
        obj1_name = 'COM10';
end

info = instrhwinfo('serial');
info_s = info.AvailableSerialPorts;
info_s = char(info_s);
obj_all = reshape(info_s',1,[]);

if ~contains(obj_all,obj1_name)
    warndlg(['Input Error! Please check the port! Available ports are: ',obj_all]);
    return;
end

obj1 = serial(obj1_name);
fopen(obj1);
set(obj1,'baudrate',115200);

t0 = clock;
Time = [];
Temp = [];

if mode == 0
    set(handles.ShowTemp,'string','Stop Displaying');
    mode = 'temp';
     while strcmp(get(handles.ShowTemp,'string'),'Stop Displaying')
         Temp_data = ReadTemp(obj1);
         if Temp_data ~=-1
             set(handles.Temp,'string',num2str(Temp_data));
             t = clock;
             delta_t = etime(t,t0);
             Time = [Time,delta_t];
             Temp = [Temp,Temp_data];
             set(handles.Tempaxes,'nextplot','replace');
             plot(handles.Tempaxes,Time,Temp,'o');
             if delta_t < 400
                 xlim(handles.Tempaxes,[0,500]);
             else
                 xlim(handles.Tempaxes,[delta_t-400,delta_t+100]);
             end
             ylim(handles.Tempaxes,[0,1200]);
         else
             continue;
         end
         
         pause(0.01);
         
     end
     
else
    set(handles.ShowTemp,'string','Display Temperature');
    set(handles.Temp,'string',' ');
    mode = 0;
end

guidata(hObject,handles);

end