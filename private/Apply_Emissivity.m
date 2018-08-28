function Apply_Emissivity(hObject,eventdata)

handles = guidata(hObject);

global mode;

if strcmp(mode,'dp811a')
    warndlg('Stop running dp811a');
    return;
end

if strcmp(mode,'temp')
    ShowTemp(hObject,eventdata);
end

emi_data = get(handles.Emissivity,'value');

set_data = {'024445000000000000C072409A9999999999B93F00000000000000007603025A45011E03',...
        '024445000000000000C072409A9999999999C93F00000000000000000603025A45011E03',...
        '024445000000000000C07240333333333333D33F00000000000000001F03025A45011E03',...
        '024445000000000000C072409A9999999999D93F00000000000000001603025A45011E03',...
        '024445000000000000C07240000000000000E03F00000000000000002C03025A45011E03',...
        '024445000000000000C07240333333333333E33F00000000000000002F03025A45011E03',...
        '024445000000000000C07240666666666666E63F00000000000000002A03025A45011E03',...
        '024445000000000000C072409A9999999999E93F00000000000000002603025A45011E03',...
        '024445000000000000C07240CDCCCCCCCCCCEC3F00000000000000002103025A45011E03'};

emi_str = char(set_data(emi_data));
n=length(emi_str)/2;
b={};
for i=1:n
    k(i) = 2*i-1;
    temp = emi_str(k(i):k(i)+1);
    b{i} = reshape(temp,2,[])';
end

b = reshape(b,1,[]);

val = hex2dec(b)';
    
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

fprintf(obj1,val);

h = waitbar(0,'please wait...');
steps = 100;
for step = 1:100
    waitbar(step/steps);
    pause(0.01);
end
close(h);

guidata(hObject,handles);

end