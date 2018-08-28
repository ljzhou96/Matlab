function KeyPress_Sections(hObject,eventdata)

handles = guidata(hObject);

sections = str2num(get(handles.Sections,'string'));

switch eventdata.Key
    case 'uparrow'
        sections = sections+1;
        set(handles.Sections,'string',sections);
    case 'downarrow'
        sections = sections-1;
        set(handles.Sections,'string',sections);
    otherwise
        return;
end
        
        
if sections >= 1 && sections <11
    sections = round(sections);
    new_data = zeros(sections,2);
    data = get(handles.ParaTable,'data');
else
    return
end

rows=min(sections,size(data,1));
new_data(1:rows,:)=data(1:rows,:);
set(handles.ParaTable,'data',new_data);

guidata(hObject,handles);

end