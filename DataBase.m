classdef DataBase < handle
   
    properties
        Name
        DataSets
        Vars
        Ic
        n
        AdjustedIc
        RawData
    end
    
    methods
        
        function obj = DataBase(DataSet,set,Vars)
            
            if isempty(DataSet)
                return
            end

            warning("off",'MATLAB:table:RowsAddedExistingVars')

            % populate the DataSet property with the provided DataSet 
            
            VarTypes = ["cell","string","string"];
            VarNames = ["Data","Date","Opperator"];

            obj.DataSets = table(Size = [1 numel(VarTypes)], VariableTypes = VarTypes, VariableNames = VarNames);
            
            TempTable = table();
            for i = 1:numel(DataSet)
                TempTable(:,i) =  array2table(DataSet{i}.Data);
                TempTable.Properties.VariableNames(i) = string(DataSet{i}.Name);
            end
            
            obj.DataSets.Data(end) = {TempTable};
            obj.DataSets.Date(end) = datetime();
            obj.DataSets.Opperator(end) = "Roel";
            obj.DataSets.Properties.RowNames = set;
            obj.DataSets.Comments = " ";

            % populate the measurment conditions table with the measurement
            % conditions provided
            Types = strings(1,numel(Vars)/2);
            Names = strings(1,numel(Vars)/2);
            for i = 1:numel(Vars)/2
                if isnan(double((Vars(2*i))))
                    Types(i) = "string";
                else
                    Types(i) = "double";
                end
                Names(i) = string(Vars(2*i-1));
            end
            
            obj.Vars = table('Size', [1 numel(Vars)/2], 'VariableTypes', cellstr(Types), 'VariableNames', Names, 'RowNames',set);
            
            for i = 1:numel(Vars)/2
                obj.Vars{1,i} = Vars(2*i);
            end
            
            % expand RawData to include more information at first glance
            obj.RawData = table();
            obj.RawData{set,:} = DataSet;
            obj.n  = table();
            obj.Ic = table();
            obj.AdjustedIc = table(); 
            

        end
                
        function FindIc(DataBase,set,opt)
            arguments
                DataBase (1,1)
                set string
                % Name value
                opt.Ec double = 100
                opt.Voltages string = DataBase.GetHeaders(set,Probe = 'VoltageProbe')

            end
            
            % initializing some arrays for later use
            Icvals = zeros(1,numel(opt.Voltages));
            
            % getting the current DataSet and interpolating
            Idata = DataBase.DataSets.Data{set}.(DataBase.GetHeaders(set,Probe = 'CurrentProbe'));
            IntrpCurrent = linspace(Idata(1),Idata(end),1000);
            
            % looping through all Voltage headers                
            for i = 1: numel(opt.Voltages)
                % interpolate the current column
                IntrpVolt = interp1(Idata,DataBase.DataSets.Data{set}.(opt.Voltages(i)),IntrpCurrent,"makima");
                
                % Get index of value closest to Ec
                [~ ,Index] = min(abs(IntrpVolt - opt.Ec));
                
                % Save Ic to table with correct header
                DataBase.Ic{set,opt.Voltages(i)}  = IntrpCurrent(Index);
                Icvals(i) = IntrpCurrent(Index);
            end
            
            % adding standard diviation and mean
            DataBase.Ic{set,"Average"} = mean(Icvals);
            DataBase.Ic{set,"StandDev"} = std(Icvals);
        end
        
        function FindN(DataBase,set,opt)
            arguments
                DataBase  
                set
                opt.Ec double = 100
                opt.Voltages string   = GetHeaders(DataBase,set,Probe = "VoltageProbe") 
            end
            
            % find Ic first if not yet found
            if isempty('DataBase.Ic')
                DataBase.FindIc(set);
            end
            

            Narray = zeros(1,numel(opt.Voltages));
            Iraw = DataBase.DataSets.Data{set}.(DataBase.GetHeaders(set,Probe = "CurrentProbe"));
            

            % prepare curve DataSet
            for i = 1:numel(opt.Voltages)

                [Idata, Vdata] = prepareCurveData(Iraw(6:end),DataBase.DataSets.Data{set}.(opt.Voltages(i))(6:end));
                
                % Set up fittype and options.
                ft = fittype( string(opt.Ec) +'*(x/' + string(DataBase.Ic{set,opt.Voltages(i)}) + ")^n" , 'independent', 'x', 'dependent', 'y' );
                opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                opts.Display = 'Off';
                opts.StartPoint = 20;
                
                % Fit model to data.
                [fitresult, ~] = fit( Idata, Vdata, ft, opts );
%                 DataBase.n.(opt.Headers(i)) = array2table(zeros(0,2),VariableNames = ["fitresult","gof"]);
                DataBase.n{set,opt.Voltages(i)} = fitresult.n;
                Narray(i) = fitresult.n;
            end
            
            DataBase.n{set,"Average"} = mean(Narray);
            DataBase.n{set,"Std"} = std(Narray);

        end 

        function SetTop(DataBase,set)
            arguments
                DataBase
                set
            end
            
            % set the right values for constants
            if DataBase.Vars.Liquid == "H2"
                A = 8.759;
                B = 6166.79;
                C = -6.289;
            else
                A = 3.63792;
                B = 257.877;
                C = -6.344;
            end
            
            % get pressure and determine the opperating Temperature
            P   = DataBase.Vars{set, "Pressure"};
            DataBase.Vars{set,"Top"} = (-B/(log10(P)-A))-C;  

        end

        function AdjustIc(DataBase,set,opt)
            arguments
                DataBase
                set
                opt.T   (1,1) double  = 77
                opt.Voltages string = DataBase.GetHeaders(set,Probe="VoltageProbe")
            end

            if DataBase.Vars{set,"Top"} == 0
                SetTop(DataBase,set)
            end

            % get Tc and Top
    	    Tc  = DataBase.Vars{set,"Tc"};
            Top = DataBase.Vars{set,"Top"};
            
            for i = 1:numel(opt.Voltages)
                DataBase.AdjustedIc{set,opt.Voltages(i)} = DataBase.Ic{set,opt.Voltages(i)}*(1+ (Top-opt.T)/(Top-Tc));
            end
            
            % adjust Tc and Top according to linear scaling
            DataBase.AdjustedIc{set,"T"} = opt.T;

        end
        
        function AddSet(DataBase,DataSet,set,Vars)
            arguments
                DataBase 
                DataSet cell
                set (1,1) string 
                Vars string
            end
            
            % Extract data from DataSet cell array
            TempTable = table();
            for i = 1:numel(DataSet)
                TempTable(:,i) =  array2table(DataSet{i}.Data);
                TempTable.Properties.VariableNames(i) = string(DataSet{i}.Name);
            end
            
            % populate DataSets
%             DataBase.DataSets{set,:} = missing;
            DataBase.DataSets{set,"Data"} = {TempTable};
            DataBase.DataSets{set,"Date"} = datetime();
            DataBase.DataSets{set,"Opperator"} = DataBase.DataSets{1,"Opperator"};
            
            % Populate Vars
%             DataBase.Vars{set,:} = missing;
            var  = Vars((1:2:numel(Vars)));
            vals = Vars((1:2:numel(Vars))+1); 
            for i = 1:numel(Vars)/2
                DataBase.Vars{set,var(i)} = vals(i);
            end
            
            % Populate RawData
%             DataBase.RawData{set,:} = missing;
            if width(DataSet) > width(DataBase.RawData{1,:})
                DataBase.RawData{:,width(DataBase.RawData)+1:width(DataSet)} = {[]};
                DataBase.RawData{set,:} = DataSet;
            elseif width(DataSet) < width(DataBase.RawData{1,:})
                DataSet(width(DataSet)+1:width(DataBase.RawData)) = {[]};
                DataBase.RawData{set,:} = DataSet;
            else
                DataBase.RawData{set,:} = DataSet;
            end            

        end

        function RenameRows(DataBase,opt)
            arguments
                DataBase (1,1)
                opt.Name string = DataBase.Name
                opt.Rows string = missing
            end
            
            if isempty(DataBase.Name)
                disp("Error: Give Name to database or specify name explicitly")
                return
            end

            % get array of all properties in DataBase
            prop = string(properties(DataBase));
            
            % if a certain row is specified
            if ~ismissing(opt.Rows)
                % loop through all properties
                for i = 1:numel(prop)
                    % check if property is a table
                    if class(DataBase.(prop(i))) == "table"
                        % loop through all rownames
                        RowNames = DataBase.(prop(i)).Properties.RowNames;
                        for k = 1:numel(RowNames)
                            %compare all rownames to specified row
                            if any(strcmp(RowNames{k},opt.Rows))
                                % Append name to the rowname.
                                DataBase.(prop(i)).Properties.RowNames(k) = opt.Name+" "+ DataBase.(prop(i)).Properties.RowNames(k); 
                            end
                        end
                    end
                end
                return
            end
 
            % loop through all properties
            for i = 1:numel(prop)
                % exclude any property that is not a table from loop
                if class(DataBase.(prop(i))) == "table" 
                   DataBase.(prop(i)).Properties.RowNames = opt.Name+ " " + DataBase.(prop(i)).Properties.RowNames;
                end
            end
        end
        
        

    
        function Headers = GetHeaders(DataBase,set,opt)
            arguments
            DataBase
            set
            opt.Probe string
            end

            Headers = [];
            % Loop through each object in the cell array
            for i = 1:width(DataBase.RawData)
                % Check if the class of the object is "VoltageProbe"
                if isa(DataBase.RawData{set,:}{i}, opt.Probe)
                    % If it is, add the index of the object to the indices vector
                    Headers = [Headers DataBase.RawData{set,:}{i}.Name];
                end
            end
        end

        
    end
end
