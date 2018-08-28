function VacLocation(hObject,~)

handles = guidata(hObject);

fold_name = uigetdir;

set(handles.VacLocation,'string',fold_name);

guidata(hObject,handles);

end