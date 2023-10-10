function sortedData = convertOutput(Out)
    
    if class(Out) ~= "char"
        Out = char(Out);
    end

    temp = '';
    j = 1;
    sortedData = [];

    for i = 1:numel(Out)
        if Out(i) == ","
            sortedData(end+1) = str2double(string(temp));
            temp = '';
            j = 1;
            continue
        end
        temp(j) = Out(i);
        j = 1 + j;
    end
    sortedData(end+1) = str2double(string(temp));
end
