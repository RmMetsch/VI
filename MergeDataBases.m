
% required input is a cellarray in for form of
% {DB1,[setsDB1],DB2,[setsDB2]}. Where DBn is a Database and the sets are
% given as an array of indices

function MergedDB = MergeDataBases(Array,Name)

    arguments
        Array cell
        Name string = "MergedDB"
    end
    
    % check if any elements in array is a double, 
    tmp = false(1,numel(Array));
    for i = 1:numel(Array)
        if class(Array{i}) == "double"
        tmp(i) = true;
        end
    end

    % break up Input array in Databases and setNumbers.
    if any(tmp) % if specific sets are specified
        DataBases = Array(1:2:numel(Array));
        SetNums   = Array(2:2:numel(Array));
    else % else
        DataBases = Array;
        SetNums = cell(1,numel(Array));
        for i = 1:numel(Array)
            SetNums(i) = {1:height(Array{i}.RawData)};
        end
    end
    
    % Convert setnumbers to setnames
    SetNames = cell(1,numel(SetNums));
    for d = 1:numel(DataBases)
        SetNames(d) = {string(DataBases{d}.RawData.Properties.RowNames(SetNums{d}))};
    end
    
    % Make empty datbase
    MergedDB = DataBase({},1,"2",Name);

    % Merge tables
    MergedDB.Name = Name;
    
    % get array of database properties
    prop = string(properties(MergedDB));


    % loop through the databases
    for d = 1:numel(DataBases)
        % loop through the properties
        for p = 1:numel(prop)
            % if the property is a table
            if class(DataBases{d}.(prop(p))) == "table"
                if SetNames{d} == "All"
                    % if all keyword is given take all sets
                    commonset = DataBases{d}.(prop(p)).Properties.RowNames;
                else
                    % determine which sets are acutally present in the table
                    commonset = intersect(SetNames{d},DataBases{d}.(prop(p)).Properties.RowNames);
                end
                % assign a temporary table with the commonSet
                T = DataBases{d}.(prop(p))(commonset,:);
                % change the rownames to include the database name
                T.Properties.RowNames =  DataBases{d}.Name+" "+T.Properties.RowNames;
                % Append the table to the database
                MergedDB.(prop(p)) = AppendTables(MergedDB.(prop(p)),T);
            end
        end
    end
end