classdef DataBase < handle
   
    properties
        Name
        DataSets
        Vars
        Ic
        n
        AdjustedIc
        RawData
        Log
    end
    
    methods
        
        function obj = DataBase(DataSet,setName,Vars,DBName,opt)
            
            arguments
                DataSet cell 
                setName  string
                Vars 
                DBName string
                opt.filter double = 1:numel(DataSet)
            end
            
            % return if the provided dataset is empty such that an empty
            % database can be created. 
            if isempty(DataSet)
                return
            end
            % turn off this stupid warning
            warning("off",'MATLAB:table:RowsAddedExistingVars')
            
            %% populate the DataSet Field with the provided DataSet 
            % get correct data structures and names
            VarTypes = ["cell","string","string"];
            VarNames = ["Data","Date","Opperator"];
            % prealocate table of correct size
            obj.DataSets = table(Size = [1 numel(VarTypes)], VariableTypes = VarTypes, VariableNames = VarNames);
            % make temp table which will hold the Data from the connections, and input the values of the dataset into the
            % TempTable.
            TempTable = table();
            for i = opt.filter
                TempTable(:,i) =  array2table(DataSet{i}.Data);
                TempTable.Properties.VariableNames(i) = string(DataSet{i}.Name);
            end
            % put the TempTable as a cell into the DataBase allong with
            % some other stuff
            obj.DataSets.Data(end) = {TempTable};
            obj.DataSets.Date(end) = datetime();
            obj.DataSets.Opperator(end) = "Roel";
            obj.DataSets.Properties.RowNames = setName;
            obj.DataSets.Comments = " ";
            
            %% populate the measurment conditions table with the measurement onditions provided
            % Make two string arrays
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
            
            obj.Vars = table('Size', [1 numel(Vars)/2], 'VariableTypes', cellstr(Types), 'VariableNames', Names, 'RowNames',setName);
            
            for i = 1:numel(Vars)/2
                obj.Vars{1,i} = Vars(2*i);
            end
            
            % expand RawData to include more information at first glance
            obj.RawData = table(Size = [1 4],VariableTypes = repmat("cell",1,4),VariableNames = ["FilteredData","FilteredProbes","Vars","RawData"]);
            obj.RawData{setName,:} = [{TempTable} {DataSet([opt.filter])}  {Vars} {DataSet}];
            obj.RawData("Row1",:) = [];
            
            %% initialize the rest of the Fields as tables
            obj.n  = table();
            obj.Ic = table();
            obj.AdjustedIc = table(); 
            obj.Log = table();
            obj.Name = DBName;      
            
            % save Raw data to csv file
            
%             save(string(datetime)+" "+setName ,[{TempTable} {DataSet([opt.filter])}  {Vars} {DataSet}])
            

        end
                
        function AddSet(DataBase,DataSet,setName,Vars,opt)
            arguments
                DataBase 
                DataSet cell
                setName (1,1) string 
                Vars string
                opt.filter double
            end
            
            % Extract data from DataSet cell array
            TempTable = table();
            for i = opt.filter
                TempTable(:,i) =  array2table(DataSet{i}.Data);
                TempTable.Properties.VariableNames(i) = string(DataSet{i}.Name);
            end
            
            % populate DataSets
            DataBase.DataSets{setName,"Data"} = {TempTable};
            DataBase.DataSets{setName,"Date"} = datetime();
            DataBase.DataSets{setName,"Opperator"} = DataBase.DataSets{1,"Opperator"};
            
            % Populate Vars
            var  = Vars((1:2:numel(Vars)));
            vals = Vars((1:2:numel(Vars))+1); 
            for i = 1:numel(Vars)/2
                DataBase.Vars{setName,var(i)} = vals(i);
            end
            

            % Raw data cell
            RawTotal = [{TempTable} {DataSet(opt.filter)} {Vars} {DataSet}];
            % Populate RawData table
            DataBase.RawData{setName,:} = [{TempTable} {DataSet(opt.filter)} {Vars} {DataSet}];
            % Save raw data for archiving
%             save(string(datetime)+" "+setName ,"RawTotal")
 
        end

        function RenameSets(DataBase,opt)
            arguments
                DataBase (1,1)
                opt.Name string = DataBase.Name
                opt.SetNum double = missing
                opt.Replace = 0
            end
            
            if isempty(DataBase.Name)
                disp("Error: Give Name to database or specify name explicitly")
                return
            end
            
              

            % get array of all properties in DataBase
            prop = string(properties(DataBase));
            
            % if a certain row is specified
            if ~ismissing(opt.SetNum)

                % convert row number to set name
                opt.SetName = string(DataBase.RawData.Properties.RowNames(opt.SetNum));  

                % loop through all properties
                for i = 1:numel(prop)
                    % check if property is a table
                    if class(DataBase.(prop(i))) == "table"
                        % loop through all rownames
                        RowNames = DataBase.(prop(i)).Properties.RowNames;
                        for k = 1:numel(RowNames)
                            %compare all rownames to specified row
                            if any(strcmp(RowNames{k},opt.SetName))
                                % Append name to the rowname.
                                if opt.Replace == true
                                    DataBase.(prop(i)).Properties.RowNames(k) = opt.Name;
                                else
                                    DataBase.(prop(i)).Properties.RowNames(k) = opt.Name+" "+ DataBase.(prop(i)).Properties.RowNames(k); 
                                end

                                
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
        
        function RemoveSet(DataBase,setNum)
            arguments
                DataBase
                setNum double
            end

            set = string(DataBase.RawData.Properties.RowNames(setNum));
            
            prop = string(properties(DataBase));

            for p = 1:numel(prop)
                if class(DataBase.(prop(p))) == "table"
                    CommonRow = intersect(set,DataBase.(prop(p)).Properties.RowNames);
                    if ~isempty(CommonRow)
                        DataBase.(prop(p))(CommonRow,:) = [];
                    end
                end
            end
        end
        
        function FindIc(DataBase,setNum,opt)
            arguments
                DataBase (1,1)
                setNum double = 1:height(DataBase.DataSets)
                % Name value
                opt.Ec double = 100
                opt.Voltages = DataBase.GetHeaders(setNum,Probe = 'VoltageProbe')
            end
            
            % convert row number to set name
            setName = string(DataBase.RawData.Properties.RowNames(setNum)); 
            
            if class(opt.Voltages) == "string"
                T = repmat(opt.Voltages,numel(setName),1);
                T = array2table(T);
                T.Properties.RowNames = setName;
                opt.Voltages = T;
            end 

            for s = 1:numel(setName)
                % initializing some arrays for later use
                Icvals = zeros(1,numel(opt.Voltages(s,:)));
                
                % getting the current DataSet and interpolating
                Idata = DataBase.DataSets.Data{setName(s)}.(DataBase.GetHeaders(setNum(s),Probe = 'CurrentProbe'));
                IntrpCurrent = linspace(Idata(1),Idata(end),1000);
                
                % looping through all Voltage headers                
                for i = 1: numel(opt.Voltages{setName(s),:})
                    % interpolate the current column
                    IntrpVolt = interp1(Idata,DataBase.DataSets.Data{setName(s)}.(opt.Voltages{setName(s),i}),IntrpCurrent,"makima");
                    
                    % Get index of value closest to Ec
                    [~ ,Index] = min(abs(IntrpVolt - opt.Ec));
                    
                    % Save Ic to table with correct header
                    DataBase.Ic{setName(s),opt.Voltages{setName(s),i}}  = IntrpCurrent(Index);
                    Icvals(i) = IntrpCurrent(Index);
                end

            % adding standard diviation and mean
            DataBase.Ic{setName(s),"Average"} = mean(Icvals);
            DataBase.Ic{setName(s),"StandDev"} = std(Icvals);

            end
        end
        
        function FindN(DataBase,setNum,opt)
            arguments
                DataBase  
                setNum double = 1:height(DataBase.Ic)
                opt.Ec double = 100
                opt.Voltages = GetHeaders(DataBase,setNum,Probe = "VoltageProbe") 
            end
            
            % convert row number to set name
            setName = string(DataBase.RawData.Properties.RowNames(setNum));
              
            for s = 1:numel(setName)
                % find Ic first if not yet found
                if isempty(DataBase.Ic)
                    DataBase.FindIc(setNum(s),"Voltages",opt.Voltages);
                end
    
                Narray = zeros(1,numel(opt.Voltages(s,:)));
                Iraw = DataBase.DataSets.Data{setName(s)}.(DataBase.GetHeaders(setNum(s),Probe = "CurrentProbe"));
               
                % prepare curve DataSet
                for i = 1:numel(opt.Voltages(s,:))
    
                    [Idata, Vdata] = prepareCurveData(Iraw(6:end),DataBase.DataSets.Data{setName(s)}.(opt.Voltages{setName(s),i})(6:end));
                    
                    % Set up fittype and options.
                    ft = fittype( string(opt.Ec) +'*(x/' + string(DataBase.Ic{setName(s),opt.Voltages{setName(s),i}}) + ")^n" , 'independent', 'x', 'dependent', 'y' );
                    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                    opts.Display = 'Off';
                    opts.StartPoint = 20;
                    
                    % Fit model to data.
                    [fitresult, gof] = fit( Idata, Vdata, ft, opts );
  %                 DataBase.n.(opt.Headers(i)) = array2table(zeros(0,2),VariableNames = ["fitresult","gof"]);
                    DataBase.n{setName(s),opt.Voltages{setName(s),i}} = fitresult.n;
                    DataBase.n{setName(s),opt.Voltages{setName(s),i}+" fit"} = {fitresult};
                    DataBase.n{setName(s),opt.Voltages{setName(s),i}+" gof"} = gof;
                    Narray(i) = fitresult.n;
                end              
                DataBase.n{setName(s),"Average"} = mean(Narray);
                DataBase.n{setName(s),"Std"} = std(Narray);       
            end
        end 

        function FindTop(DataBase,setNum)
            arguments
                DataBase
                setNum double = 1:height(DataBase.DataSets)
            end
            
            warning("off",'MATLAB:table:RowsAddedNewVars');


            % convert row number to set name
            setName = string(DataBase.RawData.Properties.RowNames(setNum));
            
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
            for i = 1:numel(setName)
                P   = DataBase.Vars{setName(i), "Pressure"};
                DataBase.Vars{setName(i),"Top"} = (-B/(log10(P)-A))-C;
            end

        end

        function AdjustIc(DataBase,setNum,opt)
            arguments
                DataBase
                setNum double = 1:height(DataBase.Ic)
                opt.T (1,1) double  = 77.34
                opt.Voltages = DataBase.GetHeaders(setNum,Probe="VoltageProbe")
            end

            % convert row number to set name
            setName = string(DataBase.RawData.Properties.RowNames(setNum)); 

            
            % if an input is given in the form of string array, convert to
            % table. In all sets the voltages in the string will evaluated.
            if class(opt.Voltages) == "string"
                T = repmat(opt.Voltages,numel(setName),1);
                T = array2table(T);
                T.Properties.RowNames = setName;
                opt.Voltages = T;
            end 
            
            % First find Top
            FindTop(DataBase,setNum)

            % get Tc and Top
    	    Tc  = DataBase.Vars{setName,"Tc"};
            Top = DataBase.Vars{setName,"Top"};

            
            for s = 1:numel(setName)

%                 FindIc(DataBase,set(s),"Voltages",opt.Voltages{set(s),:})

                for v = 1:numel(opt.Voltages{setName(s),:})
                    if ~ismember(opt.Voltages{setName(s),v},DataBase.AdjustedIc.Properties.VariableNames)
                        DataBase.AdjustedIc{:,opt.Voltages{setName(s),v}} = NaN;
                    end
                    if ~ismember(setName(s),DataBase.AdjustedIc.Properties.RowNames) && height(DataBase.AdjustedIc) > 1
                        DataBase.AdjustedIc{setName(s),:} = NaN;
                    end 
                    DataBase.AdjustedIc{setName(s),opt.Voltages{setName(s),v}} = DataBase.Ic{setName(s),opt.Voltages{setName(s),v}}*(1- (Top(s)-opt.T)/(Top(s)-Tc(s)));
                end
            end

            % adjust Tc and Top according to linear scaling
            DataBase.AdjustedIc{setName,"T"} = opt.T;

            if ismember("Row1",DataBase.AdjustedIc.Properties.RowNames)
                DataBase.AdjustedIc("Row1",:) = [];
            end


        end
        
        function Plot(DataBase,setNum,opt)
            arguments
                DataBase
                setNum double
                opt.x string = "I"
                opt.y string = "V1";
                opt.Title string = "";
            end
            
            DataBase.FindIc(setNum)
            DataBase.FindN(setNum)

            %color array
            Color = ['b','r','g','c','y','m'];

            % convert row number to set name
            SetName = string(DataBase.RawData.Properties.RowNames(setNum)); 
            
            close all
            hold on
            box on


            for s = 1:numel(SetName)
                for i = 1:numel(opt.y)
                    % prepare x,y data 
                    YData = DataBase.DataSets.Data{SetName(s)}.(opt.y(i));
                    XData = DataBase.DataSets.Data{SetName(s)}.(opt.x);
                    
                    fit = DataBase.n{SetName(s), opt.y(i)+ " fit"}{1};
                    legendName = SetName(s) + " n = " + string(round(fit.n));

                    scatter(XData, YData, 40, Color(mod(s+i-1,numel(Color))),"DisplayName",legendName)  
                    
                    Yfit = linspace(0,YData(end),10000); 
                    Xfit = fit(Yfit);

                    scatter(Yfit,Xfit,0.3, Color(mod(s+i-1,numel(Color))), 'HandleVisibility','off');
                    xline(DataBase.Ic{SetName,opt.y(i)},LineWidth= 0.5,HandleVisibility="off");
                 end
            end
            
            
            % Style options
            set(gca,'XScale','log','YScale','log') % convert both axes to log scale
            legend(location='northwest')
            yline(100,LineWidth=0.5,HandleVisibility="off");
            title(opt.Title)

            ylim([50 1000])


            xlabel('I [A]', 'Interpreter', 'none')
            ylabel('V [uV/m]', 'Interpreter', 'none')

            hold off

        end
        
        function Headers = GetHeaders(DataBase,setNum,opt)
            arguments
            DataBase
            setNum double
            opt.Probe string
            end

            warning('off', 'MATLAB:table:RowsAddedExistingVars');
            
            % convert row number to set name
            set = string(DataBase.RawData.Properties.RowNames(setNum));            

            Headers =  table();
            
            
            % Loop through each object in the cell array
            for s = 1:numel(set)
                v = 1; 
                for i = 1:width(DataBase.RawData.FilteredProbes{set(s),:})
                    % Check if the class of the object is "VoltageProbe"
                    if isa(DataBase.RawData.FilteredProbes{set(s),:}{i}, opt.Probe)
                        % If it is, add the index of the object to the indices vector
                        Headers{set(s),v} = DataBase.RawData.FilteredProbes{set(s),:}{i}.Name;
                        v = v + 1;
                    end
                end
            end

            if opt.Probe == "CurrentProbe"
                Headers = table2array(Headers);
            end
        end
    
        function [fitresult, gof] = GetFit(DataBase,setNum,opt)
            arguments
                DataBase
                setNum double
                opt.x = "V1"
                opt.y = DataBase.GetHeaders(setNum,Probe = "CurrentProbe")
                opt.Ec = 100
            end

            setName = string(DataBase.RawData.Properties.RowNames(setNum));
            
            % first find Ic
            DataBase.FindIc(setNum,"Voltages",opt.x);

            
            Iraw = DataBase.DataSets.Data{setName}.(opt.y);
            [Idata, Vdata] = prepareCurveData(Iraw(6:end),DataBase.DataSets.Data{setName}.(opt.x)(6:end));
                    
            % Set up fittype and options.
            ft = fittype( string(opt.Ec) +'*(x/' + string(DataBase.Ic{setName,opt.x}) + ")^n" , 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Display = 'Off';
            opts.StartPoint = 20;
            
            % Fit model to data.
            [fitresult, gof] = fit(Idata, Vdata, ft, opts);

        end
         
        function AddLog(DataBase,Log,setNum)
            arguments
                DataBase
                Log string
                setNum double = height(DataBase.DataSets)
            end
            
            if  isa(setNum, "double")
                % convert row number to set name
                setName = string(DataBase.RawData.Properties.RowNames(setNum));
            end

            DataBase.Log = Log;
            DataBase.table.SetName = setName;
            DataBase.Date = datatime();
              
            
        end

        function save(DataBase)
            eval(DataBase.Name+"=DataBase;")
            save(DataBase.Name,DataBase.Name)
        end
    end
end
