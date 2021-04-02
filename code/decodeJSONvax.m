

function data = decodeJSONvax(l)

data = struct;


indexStartEntry = strfind(l, '"data":[');
indexEndEntry   = strfind(l, ']');indexEndEntry=indexEndEntry(end);

l=l(indexStartEntry+8:indexEndEntry-1);






indexStartEntry = strfind(l, '{');
indexEndEntry   = strfind(l, '}');

for i = 1 : length(indexStartEntry)
    
    fprintf('%d/%d\n', i,length(indexStartEntry))
    
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
        kk = indexEndField(k) + 3       -1;
        if strcmp(l_i(kk),'"')
            while ~strcmp(l_i(kk+1),'"')
                kk = kk + 1;
            end
            value = cellstr(l_i(indexEndField(k) + 4      -1 : kk));
            value = char(value);
            value(strfind(value,''''))= ' ';
            value = cellstr(value);
            if strcmp(value,'ull,')
%                 value='null';
            end
            try
            eval(sprintf('data.%s(i, 1) = cellstr(''%s'');', fieldName, char(value)));
            catch
                
            end
        else
            while ~strcmp(l_i(kk),',') && kk<length(l_i)
                kk = kk + 1;
            end
            if kk == length(l_i)
                kk = length(l_i)+1;
            end
            value = str2double(l_i(indexEndField(k) + 3      -1 : kk-1));
            try
              eval(sprintf('data.%s(i, 1) = %f;', fieldName, value));
            catch
                try
               eval(sprintf('data.%s(i, 1) = %s;', fieldName, value)); 
               
               
                catch
         
                    try
                        if strcmp(data.denominazione_provincia(i, 1),'Napoli')
                             eval(sprintf('data.%s(i, 1) = cellstr(''NA'');', fieldName));
                        else
                            eval(sprintf('data.%s(i, 1) = cellstr('''');', fieldName));
                        end
                    catch
                         eval(sprintf('data.%s(i, 1) = cellstr('''');', fieldName));
                    end
                        
                end
            end
        end        
    end
end
end