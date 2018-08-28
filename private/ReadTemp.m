function Temp = ReadTemp(obj1)

q = quantizer('float',[32,8]);

raw_temp = fread(obj1,51);
raw_temp = dec2hex(raw_temp);
raw_temp = reshape(raw_temp',[1,102]);
index = strfind(raw_temp,'83');
cut_data = [];
if raw_temp(index(2)-2)~=8 || raw_temp(index(2)-1)~=0
    if raw_temp(index(3)-2)~=8 || raw_temp(index(3)-1)~=0
        
        raw_data = raw_temp(index(2)+2:index(3)-1);
        l = length(raw_data);
        index_80 = strfind(raw_data,'80'); % index of 80
        len_80 = length(index_80); % length of index of 80
        
        if len_80 == 0  % no 80 and length equals to 16, compute the temperature 
            if l ==16
                hex_temp = raw_data(1:8);
                Temp = hex2num(q,hex_temp);
            else
                Temp = -1;
            end
        else
            % find the real escape frame
            escape_index = [index_80(1)];
            for i = 2:len_80
                if index_80(i)-index_80(i-1) ~= 2
                    escape_index = [escape_index,index_80(i)];
                end
            end
            len_esc = length(escape_index);
            % delete the real escape frame
            cut_data = strcat(cut_data,raw_data(1:escape_index(1)-1));
            for i = 1:(len_esc -1)
                cut_data = strcat(cut_data,raw_data(escape_index(i)+2:escape_index(i+1)-1));
            end
            cut_data = strcat(cut_data,raw_data(escape_index(len_esc)+2:l));
            if length(cut_data) == 16
                hex_temp = cut_data(1:8);
                Temp = hex2num(q,hex_temp);
            else
                Temp = -1;
            end
                
        end
        
    else
        Temp = -1;
    end
else
    Temp = -1;
end
return;

end