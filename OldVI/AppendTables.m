function combined_table = AppendTables(varargin)
    % Initialize combined_table with the first input table
    narginchk(1,inf);
    
    for j = 1:numel(varargin)
        if ~isempty(varargin{j})
            combined_table = varargin{j};
            break
        end
    end

    if j == numel(varargin)
        if isempty(varargin{j})
            combined_table = table();
        end
        return
    end
    
    
    % Loop over remaining input tables
    for i = (j+1):numel(varargin)
        if isempty(varargin{i})
            continue   
        end
        % Get the column names for each table
        columns1 = combined_table.Properties.VariableNames;
        columns2 = varargin{i}.Properties.VariableNames;

        % Find the missing columns in each table
        missing_columns1 = setdiff(columns2, columns1);
        missing_columns2 = setdiff(columns1, columns2);

        % Add the missing columns with empty values to each table
        for j = 1:numel(missing_columns1)
            if class(varargin{i}.(missing_columns1{j})) == "cell"
                combined_table.(missing_columns1{j}) = repmat({[]}, height(combined_table), 1);
            else
                combined_table.(missing_columns1{j}) = repmat(missing, height(combined_table), 1);
            end    
        end
        for j = 1:numel(missing_columns2)
            if class(combined_table.(missing_columns2{j})) == "cell" 
                varargin{i}.(missing_columns2{j}) = repmat({[]}, height(varargin{i}), 1);
            else
                varargin{i}.(missing_columns2{j}) = repmat(missing, height(varargin{i}), 1);
            end
        end
        % Combine the two tables
        varargin{i} = varargin{i}(:,combined_table.Properties.VariableNames);
        combined_table = [combined_table; varargin{i}];
    end
end
