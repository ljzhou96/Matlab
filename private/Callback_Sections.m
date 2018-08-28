function Callback_Sections(hObject,~)

handles = guidata(hObject);

sections = str2num(get(handles.Sections,'string'));
                
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

end