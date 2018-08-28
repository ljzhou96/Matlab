function Stop(hObject,~)

handles = guidata(hObject);

% mode = 'temp', in temperature measure mode
% mode = 'dp811a',in current mode
% mode = 0, free
global mode;
if strcmp(mode,'temp')==1
    warndlg('Please close temperature block!');
    return;
else
    mode = 0;
end

global stop_flag;
stop_flag = 1;

guidata(hObject,handles);

return;
end