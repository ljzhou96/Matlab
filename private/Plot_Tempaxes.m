% Current this function is useless!

function Plot_Tempaxes(hObject)

handles = guidata(hObject);

global Time
global Temp
global t0

%if strcmp(get(handles.TempPlotButt,'string'),'Stop Plotting')
    t = clock;
    delta_t = etime(t,t0);
    Time = [Time;delta_t];
    Temp_data = str2num(get(handles.Temp,'string'));
    Temp = [Temp;Temp_data];
    delta_t
%    plot(handles.Tempaxes,Time,Temp);

    if delta_t <500
        xlim(handles.Tempaxes,[0,500]);
    else 
        xlim(handles.Tempaxes,[delta_t-500,delta_t])
    end
%end

guidata(hObject,handles);

end