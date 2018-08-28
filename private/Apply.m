function Apply(hObject,eventdata)

handles = guidata(hObject);

% choose mode
% mode = 'temp', in temperature measure mode
% mode = 'dp811a',in current mode
% mode = 0, free
global mode;
if strcmp(mode,'temp')==1
    warndlg('Please close temperature block!');
    return;
else
    mode = 'dp811a';
end

% stop flag
global stop_flag 
stop_flag = 0;

% delete previous graph
cla(handles.Tempaxes);
cla(handles.DP811Aaxes);

% connect to the DP811A
delete(instrfind);
handles.dp811a = visa('ni','USB0::0x1AB1::0x0E11::DP8D192700092::INSTR');

%connect to the temperature measurement
global obj1; 
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

% set PID parameter
Kp = get(handles.Kp,'string');
Ki = get(handles.Ki,'string');
Kd = get(handles.Kd,'string');
% judge if the input is good
if isempty(str2num(Kp)) || isempty(str2num(Ki)) || isempty(str2num(Kd))
    warndlg('Input is wrong! Please check form of Kp,Ki,Kd set!');
    return;
end
Kp = str2num(Kp);
Ki = str2num(Ki);
Kd = str2num(Kd);

% need to be set
max_current = str2num(get(handles.MaxCurrent,'string'));
max_temp = str2num(get(handles.MaxTemperature,'string'));
cycles = str2num(get(handles.Cycles,'string'));

data = get(handles.ParaTable,'data');
if isnan(data)
    set(handles.Message,'string','Input Valid Numbers');
    warndlg('Please Input Valid Numbers','Warning');
    return
end

% interpolate and plot the temperature set data
time = floor(data(end,1));
if time < 1
    fprintf('please type in right data');
    return;
end
interp_x = 1:1:time;
interp_y = interp1(data(:,1),data(:,2),interp_x);
DATA = zeros(time*(cycles+1),2);
for i = 1:1:(cycles+1)
    for j = 1:1:time
        DATA((i-1)*time+j,1) = interp_x(j)+(i-1)*time;
        DATA((i-1)*time+j,2) = interp_y(j);
    end
end
DATA = [0,data(1,end);DATA];

% check dp811a state
fclose(handles.dp811a);
fopen(handles.dp811a);
fprintf(handles.dp811a,':OUTP?');
state_time = fscanf(handles.dp811a);
if contains(state_time,'ON')
    warndlg('DP811A is running,can not apply','Warning');
    set(handles.Message,'string','DP811A is Running!');
    return;
end

fprintf(handles.dp811a,':OUTP ON');

% determine the range
if get(handles.Range,'value')==1
    fprintf(handles.dp811a,':OUTP:RANG HIGH');
    max_voltage = 40;
else
    fprintf(handles.dp811a,'OUTP:RANG LOW');
    max_voltage = 20;
end

% set parameters
Time = [0];
temp_l = ReadTemp(obj1);  % last read temperature
while temp_l == -1
    temp_l = ReadTemp(obj1);
end
Temp = [temp_l];
Error = zeros(1,3);
% Error(1) = interp1(DATA(:,1),DATA(:,2),0) - temp_l;
% Error(2) = Error(1);
Error(1) = 0;
Error(2) = 0;
current = max(min(Kp*Error(2),max_current),0);
% current = 0;
Current = [current];

time_initial = clock; % start time
time1 = clock; % start time of an interval
time2 = clock; % stop time of an interval
time_all = etime(time2,time_initial); % sum of the interval time

set(handles.Message,'string','DP811A is running!');
% start running
for i = 1:cycles
    while time_all < i*time
        
        % check the stop flag
        if stop_flag == 1
            fprintf(handles.dp811a,':OUTP OFF');
            set(handles.Message,'string','DP811A is stopped');
            return;
        end
        
        temp = ReadTemp(obj1);
        if temp ~= -1
            
            % temperature protection
            if temp > max_temp
                warndlg('Temperature Too High!');
                fprintf(handles.dp811a,':OUTP OFF');
                fclose(handles.dp811a);
                return;
            end
            Temp = [Temp,temp];
            set(handles.Temp,'string',num2str(temp));
            
            time2 = clock;
            time_all = etime(time2,time_initial);
            
            % current protection
            Error(3) = interp1(DATA(:,1),DATA(:,2),time_all)- temp;
            current = max(min(current +Kp*(Error(3)-Error(2)) + ...
                       Ki*Error(3)*etime(time2,time1) + Kd*(Error(3)-2*Error(2)+Error(1))/etime(time2,time1),max_current),0); 
%             disp(['set current : ',num2str(current+Kp*(temp - temp_l) + ...
%                       Ki*(temp -interp1(DATA(:,1),DATA(:,2),time_all-(i-1)*time))*etime(time2,time1))]);
%             disp(['time : ',num2str(time_all)]);
            time1 = time2;
%             temp_l = temp;
            Error(1) = Error(2);
            Error(2) = Error(3);
            fprintf(handles.dp811a,[':CURR ',num2str(current)]);
            
            % set the time parameter
            time_rest = cycles * time - time_all;
            hours = floor(time_rest/3600);
            minutes = floor((time_rest-3600*hours)/60);
            seconds = floor(time_rest-3600*hours-60*minutes);
            set(handles.RemainingTime,'string',[num2str(hours),' h ',num2str(minutes),' m ',num2str(seconds),' s']);
            set(handles.RemainingCycles,'string',num2str(cycles-i));
        
            % measure the current, voltage and power
            fprintf(handles.dp811a,[':MEAS:ALL?']);
            measure = str2num(fscanf(handles.dp811a));
            set(handles.Voltage,'string',[num2str(measure(1)),' V']);
            set(handles.Current,'string',[num2str(measure(2)),' A']);
            set(handles.Power,'string',[num2str(measure(3)),' W']);
            Current = [Current,measure(2)];
            Time = [Time,time_all];
            plot(handles.DP811Aaxes,Time,Current);
            
            % plot the temperature
            set(handles.Tempaxes,'nextplot','replace')
            plot(handles.Tempaxes,interp_x,interp_y);
            xlim(handles.Tempaxes,[0,time]);
            set(handles.Tempaxes,'nextplot','add');
            plot(handles.Tempaxes,Time((i-1)*time+1:end)-(i-1)*time,Temp((i-1)*time+1:end));
            
            % overload protection
            maxpower = get(handles.MaxPower,'string');
            if measure(3) > maxpower
                fprintf(handles.dp811a,':OUTP OFF');
                warndlg('Power Overload!');
                fclose(handles.dp811a);
                return;
            end
            pause(0.1);
        
        end
    end
end

fprintf(handles.dp811a,':OUTP OFF');
fclose(handles.dp811a);
set(handles.Message,'string','Finish Running');
mode = 0;

guidata(hObject,handles);

end
























