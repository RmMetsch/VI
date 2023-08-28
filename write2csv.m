function write2csv(DataSet,FileName)
    % make DataTable which will hold the Data from the connections, and input the values of the dataset into the
    DataTable = [];
    DataTableVars = [];
    for i = 1:numel(DataSet)
        DataTable =  [DataTable DataSet{i}.Data];
        DataTableVars =  [DataTableVars DataSet{i}.Name];
    end
    DataTable = array2table(DataTable,"VariableNames", DataTableVars);
    DataTable.Properties.VariableNames = DataTableVars;

    % write to csv
    writetable(DataTable,string(datetime("today"))+" "+FileName,WriteMode="append")
end
