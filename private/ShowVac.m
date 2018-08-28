function ShowVac(hObject,~)

handles = guidata(hObject);

fold_name = get(handles.VacLocation,'string');
fid = fopen([fold_name,'\',date,'.txt'],'w+t');
if fid < 3
    warndlg('Can''t open that file','Warning');
    return;
end

com_index = get(handles.VacSerial,'value');

switch com_index
    case 1
        vac_com = 'COM1';
    case 2
        vac_com = 'COM2';
    case 3
        vac_com = 'COM3';
    case 4
        vac_com = 'COM4';
    case 5
        vac_com = 'COM5';
    case 6
        vac_com = 'COM6';
    case 7
        vac_com = 'COM7';
    case 8
        vac_com = 'COM8';
    case 9
        vac_com = 'COM9';
    case 10
        vac_com = 'COM10';
end
hw = instrhwinfo('serial');
if isempty(hw) || isempty(find(strcmp(hw.SerialPorts,vac_com)))
    warndlg('No Input','Warning');
    return;
end
instr_list = instrfind;
if ~isempty(instr_list)
    index = find(strcmp(instr_list.Name,['Serial-',vac_com]));
    if ~isempty(index)
        delete(instrfind(instr_list(index)));
    end
end
s = serial(vac_com);
set(s,'baudrate',9600,'databits',8,'parity','none','stopbits',1,'flowcontrol','none','terminator','CR');
fclose(s);
fopen(s);

fprintf(s,'#0013');
u = fscanf(s);
l = length(u);
if l ~= 4
    warndlg('Error','Warning');
    return;
end
u0 = str2num(u(2:3));
switch u0
    case 0
        u1 = 'torr';
    case 1
        u1 = 'hbar';
    case 2
        u1 = 'pa';
end
fprintf(s,'#0001');
a = fscanf(s);
b = strfind(a,'10');

if strcmp(get(handles.ShowVac,'string'),'Show Vacuum')
    set(handles.ShowVac,'string','Stop');
    while strcmp(get(handles.ShowVac,'string'),'Stop')
        if ~isempty(b)
            fprintf(s,['#0015I',num2str(ceil(b(1)/2))]);
            c1 = fscanf(s);
            set(handles.label1,'string',c1(2:end));
            fprintf(s,['#0002U',c1(2:end)]);
            n1 = fscanf(s);
            set(handles.label1_Pres,'string',[n1(2:end),' ',u1]);
        else
            set(handles.ShowVac,'string','Show Vacuum');
            warndlg('No Vacuum Gauge','Warning');
            return;
        end
        [h,g] = size(b);
        if g-1
            fprintf(s,['#0015I',num2str(ceil(b(2)/2))]);
            c2 = fscanf(s);
            set(handles.label2,'string',c2(2:end));
            fprintf(s,['#0002U',c2(2:end)]);
            n2 = fscanf(s);
            set(handles.label2_Pres,'string',[n2(2:end),' ',u1]);
        else
            continue;
        end
        fprintf(fid,'%c  %d     %c  %d\n',[c1(2:end),n1(2:n),c2(2:end),n2(2:end)]);
        pause(0.1);
    end
else
    set(handles.ShowVac,'string','Show Vacuum');
end

fclose(fid);
clear fid;
fclose(s);
guidata(hObject,handles);

end