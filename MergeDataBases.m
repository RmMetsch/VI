function MergedDB = MergeDataBases(Array)
    arguments
        Array cell
    end

    % break up Input array in Databases and sets
    DataBases = Array(1:2:numel(Array));
    Sets      = Array(2:2:numel(Array));
    % Make empty datbase
    MergedDB = DataBase({},[],[]);
    % Merge tables
    MergedDB.Name = "merged Data base";
    
    % loop through the databases
    for d = 1:numel(DataBases)
        % loop through the properties
        for p = 1:numel(prop)
            % if the property is a table
            if class(DataBases{d}.(prop(p))) == "table"
                % determine which sets are acutally present in the table
                commonSet = intersect(Sets{d},DataBases{d}.(prop(p)).Properties.RowNames);
                % assign a temporary table with the commonSet
                T = DataBases{d}.(prop(p))(commonSet,:);
                % change the rownames to include the database name
                T.Properties.RowNames =  DataBases{d}.Name+" "+T.Properties.RowNames;
                % Append the table to the database
                MergedDB.(prop(p)) = AppendTables(MergedDB.(prop(p)),T);
            end
        end
    end
end