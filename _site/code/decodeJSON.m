

function data = decodeJSON(l)

data = struct;



indexStartEntry = strfind(l, '{');
indexEndEntry   = strfind(l, '}');

for i = 1 : length(indexStartEntry)
    l_i = l(indexStartEntry(i)+1 : indexEndEntry(i)-1);
    
    indexEndField = strfind(l_i, '":');
    
    for k = 1 : length(indexEndField)
        % find fieldName
        kk = indexEndField(k)-1;
        while ~strcmp(l_i(kk),'"')
            kk = kk - 1;
        end
        fieldName = l_i(kk+1 : indexEndField(k)-1);
        
        % find value
        kk = indexEndField(k) + 3;
        if strcmp(l_i(kk),'"')
            while ~strcmp(l_i(kk+1),'"')
                kk = kk + 1;
            end
            value = cellstr(l_i(indexEndField(k) + 4 : kk));
            value = char(value);
            value(strfind(value,''''))= ' ';
            value = cellstr(value);
            eval(sprintf('data.%s(i, 1) = cellstr(''%s'');', fieldName, char(value)));
        else
            while ~strcmp(l_i(kk),',') && kk<length(l_i)
                kk = kk + 1;
            end
            if kk == length(l_i)
                kk = length(l_i)+1;
            end
            value = str2double(l_i(indexEndField(k) + 3 : kk-1));
            try
              eval(sprintf('data.%s(i, 1) = %f;', fieldName, value));
            catch
               eval(sprintf('data.%s(i, 1) = %s;', fieldName, value)); 
            end
        end        
    end
end
end