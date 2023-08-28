function SortedData = ConvertOutput(Out)
    temp = '';
    j = 1;
    SortedData = [];
    for i = 1:numel(Out)
        if Out(i) == ","
            SortedData(end+1) = str2double(string(temp));
            temp = '';
            j = 1;
            continue
        end
        temp(j) = Out(i);
        j = 1 + j;
    end
    SortedData(end+1) = str2double(string(temp));
end
