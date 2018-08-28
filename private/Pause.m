function Pause(hObject,~)

handles = guidata(hObject);

fclose(handles.dp811a);
fopen(handles.dp811a);
fprintf(handles.dp811a,':TIME OFF');
fprintf(handles.dp811a,':OUTP ON');
fprintf(handles.dp811a,':DISP:MODE NORM');
set(handles.Message,'string','Program is Paused');
fclose(handles.dp811a);

guidata(hObject,handles);

end