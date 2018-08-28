function PlotTemp(hObject,~)

handles = guidata(hObject);
Time = [];
Temp = [];

if strcmp(get(handles.ShowTemp,'string'),'Display Temperature')
    warndlg('Please click Display Temperature Button','Warning');
    return;
else
    if strcmp(get(handles.TempPlotButt,'string'),'Plot Temperature')
        set(handles.TempPlotButt,'string','Stop Plotting');
        t0 = clock;
%         while strcmp(get(handles.TempPlotButt,'string'),'Stop Plotting')
%             
%                 t = clock;
%                 delta_t = etime(t,t0);
%                 Time = [Time;delta_t];
%                 Temp_data = str2num(get(handles.Temp,'string'));
%                 Temp = [Temp;Temp_data];
%                 plot(handles.Tempaxes,Time,Temp);
%                 delta_t
% 
%                 if delta_t <400
%                     xlim(handles.Tempaxes,[0,500]);
%                 else 
%                     xlim(handles.Tempaxes,[delta_t-400,delta_t+100])
%                 end
%                 pause(0.01);  
%             
%         end

    else
        set(handles.TempPlotButt,'string','Plot Temperature');

    end

end

guidata(hObject,handles);
return;
end