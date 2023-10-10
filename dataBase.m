classdef dataBase < handle
   
    properties
        Name
        DataSets
        Vars
        Ic
        N
        AdjustedIc
        RawData
        Log
    end
    
    methods
        
        function obj = dataBase(dataSet,setName,vars,dateBaseName,opt)
            
            arguments
                dataSet cell 
                setName  string
                vars 
                dateBaseName string
                opt.SaveCSV logical = 0;
            end

            baseVars = evalin("base","who");

            assert(~any(string(baseVars) == dateBaseName),"Name of DB already exists in workspace chose another name")
 
            % return if the provided dataset is empty such that an empty
            % database can be created. 
            if isempty(dataSet)
                return
            end

            % turn off this stupid warning
            warning("off",'MATLAB:table:RowsAddedExistingVars')
            
            %% populate the DataSet Field with the provided DataSet 
            % get correct data structures and names
            varTypes = ["cell","string","string","string"];
            varNames = ["Data","Date","Opperator","Comments"];
            
            % prealocate table of correct size
            obj.DataSets = table(Size = [1 numel(varTypes)], VariableTypes = varTypes, VariableNames = varNames);
            
            % make DataTable which will hold the Data from the connections, and input the values of the dataset into the
            shortestSetLenght = inf;              
            for i = 1:numel(dataSet)
                if shortestSetLenght > height(dataSet{i}.Data)
                    shortestSetLenght = height(dataSet{i}.Data);
                end
            end
            
            dataTable = [];
            headerArray = [];
            for i = 1:numel(dataSet)

                dataTable = [dataTable dataSet{i}.Data(1:shortestSetLenght)];
                headerArray = [headerArray dataSet{i}.Name];

                if class(dataSet{i}) == "voltageProbe" && ~any(dataSet{i}.Error == 0)
                    dataTable = [dataTable dataSet{i}.Error(1:shortestSetLenght)];
                    headerArray = [headerArray dataSet{i}.Name+"Error"];
                end

            end
                
            dataTable = array2table(dataTable,VariableNames=headerArray);

            % write to csv
            if opt.SaveCSV
                writetable(dataTable,string(datetime("today"))+" "+setName,WriteMode="append")
            end

            % put the TempTable as a cell into the dataBase allong with
            % some other stuff
            obj.DataSets.Data(end) = {dataTable};
            obj.DataSets.Date(end) = datetime();
            obj.DataSets.Opperator(end) = "Roel";
            obj.DataSets.Properties.RowNames = setName;
            obj.DataSets.Comments = " ";
            
            %% populate the measurment conditions table with the measurement onditions provided
            % Make two string arrays
            types = strings(1,numel(vars)/2);
            names = strings(1,numel(vars)/2);
            for i = 1:numel(vars)/2
                if isnan(double((vars(2*i))))
                    types(i) = "string";
                else
                    types(i) = "double";
                end
                names(i) = string(vars(2*i-1));
            end
            
            obj.Vars = table('Size', [1 numel(vars)/2], 'VariableTypes', cellstr(types), 'VariableNames', names, 'RowNames',setName);
            
            for i = 1:numel(vars)/2
                obj.Vars{1,i} = vars(2*i);
            end
            
            % expand RawData to include more information at first glance
            obj.RawData = table(Size = [1 3],VariableTypes = repmat("cell",1,3),VariableNames = ["Data","Vars","Probes"]);
            obj.RawData{setName,:} = [{dataTable} {vars} {dataSet}];
            obj.RawData("Row1",:) = [];
           
            RawTotal = [{dataSet},{setName},{vars}]; 

            %% initialize the rest of the Fields as tables
            obj.N  = table();
            obj.Ic = table();
            obj.AdjustedIc = table(); 
            obj.Log = table();
            obj.Name = dateBaseName;      
            
            % save Raw data to csv file
            save(string(datetime("today"))+" "+dateBaseName+" "+setName+"_Raw","RawTotal")
            

        end
                
        function addSet(dataBase,dataSet,setName,vars,opt)
            arguments
                dataBase 
                dataSet cell
                setName (1,1) string 
                vars string
                opt.SaveCSV logical = 0
            end
            
            if any(string(dataBase.DataSets.Properties.RowNames) == setName)
                disp("SetName already used, please name set differently")
                return
            end

            % Extract data from DataSet cell array
            % make DataTable which will hold the Data from the connections, and input the values of the dataset into the
            dataTable = [];
            headerArray = [];

            shortestSetLenght = inf;            
            for i = 1:numel(dataSet)
                if shortestSetLenght > height(dataSet{i}.Data)
                    shortestSetLenght = height(dataSet{i}.Data);
                end
            end

            for i = 1:numel(dataSet)
                dataTable = [dataTable dataSet{i}.Data(1:shortestSetLenght,1)];
                headerArray = [headerArray dataSet{i}.Name];
                
                if class(dataSet{i}) == "voltageProbe" && ~any(dataSet{i}.Error == 0)
                    dataTable = [dataTable dataSet{i}.Error(1:shortestSetLenght)];
                    headerArray = [headerArray dataSet{i}.Name+"Error"];
                end
            end

            dataTable = array2table(dataTable,VariableNames=headerArray);
            
            if opt.SaveCSV
                writetable(dataTable,string(datetime("today"))+" "+dataBase.Name+" "+setName,WriteMode="append")
            end

            % populate DataSets
            dataBase.DataSets{setName,"Data"} = {dataTable};
            dataBase.DataSets{setName,"Date"} = datetime();
            dataBase.DataSets{setName,"Opperator"} = dataBase.DataSets{1,"Opperator"};
            
            % Populate Vars
            var  = vars((1:2:numel(vars)));
            vals = vars((1:2:numel(vars))+1); 
            for i = 1:numel(vars)/2
                dataBase.Vars{setName,var(i)} = vals(i);
            end
            
            % Raw data cell
            RawTotal = [{dataSet},{setName},{vars}]; 
            
            % Populate RawData table
            dataBase.RawData{setName,:} = [{dataTable} {vars} {dataSet}];
            
            % Save raw data for archiving
            save(string(datetime("today"))+" "+dataBase.Name+" "+setName+"_Raw","RawTotal")   
        end

        function importRaw(dataBase,rawTotal)
            arguments
                dataBase 
                rawTotal cell
            end
            
            date = [];
            comments = [];
            % Date needs to be saved, but dataset might not exist
            try
                date = dataBase.DataSets{rawTotal{2},"Date"};
                comments = dataBase.DataSets{rawTotal{2},"Comments"};
            catch
            end

            rowPosition = find(strcmp(string(dataBase.DataSets.Properties.RowNames),rawTotal{2}));
            

            
            % remove dataSet, then add it again.
            dataBase.removeSet(rawTotal{2})
            dataBase.addSet(rawTotal{1},rawTotal{2},rawTotal{3},"SaveCSV",1)
            
            % if the dateSet existed, then the date is nonempty, thus save
            % old date.
            if ~isempty(date)
                dataBase.DataSets{rawTotal{2},"Date"} = date;
                dataBase.DataSets{rawTotal{2},"Comments"} = comments;
            end
            
            % move dataSet to original position
            dataBase.reorderSet(height(dataBase.DataSets),rowPosition)
            
        end
       
        function renameSet(dataBase,SetNum, Name)
            arguments
                dataBase (1,1)
                SetNum double 
                Name string 
            end

              
            % get array of all properties in dataBase
            prop = string(properties(dataBase));
            
            % convert row number to set name
            SetName = string(dataBase.RawData.Properties.RowNames(SetNum));  


            % loop through all properties
            for i = 1:numel(prop)
                % check if property is a table
                if class(dataBase.(prop(i))) ~= "table"
                    continue
                end

                % loop through all rownames
                RowNames = dataBase.(prop(i)).Properties.RowNames;
                for k = 1:numel(RowNames)
                    %compare all rownames to Name of specified SetNum
                    if strcmp(string(RowNames{k}),SetName)
                        dataBase.(prop(i)).Properties.RowNames(k) = Name;                            
                    end
                end

            end


        end
        
        function removeSet(dataBase,set)
            arguments
                dataBase
                set
            end
            
            if class(set) == "double"
                set = string(dataBase.RawData.Properties.RowNames(set));
            end

            prop = string(properties(dataBase));

            for p = 1:numel(prop)
                if class(dataBase.(prop(p))) == "table"
                    CommonRow = intersect(set,dataBase.(prop(p)).Properties.RowNames);
                    if ~isempty(CommonRow)
                        dataBase.(prop(p))(CommonRow,:) = [];
                    end
                end
            end
        end
        
        function reorderSet(dataBase,from,to)

            arguments
                dataBase 
                from double
                to double
            end

            % to and from can't be empty, it will delete whole DB.
            if isempty(from) || isempty(to)
                return
            end

            % Throw error if you are moving to within its own set.
            if any(to == from)
                Disp("Moving rows within own range is not allowed, please select a destination outside the range of the to be moved rows")
                return 
            end
            
            % if To is larger then From, subtract the length of From from
            % To.
            if any(to > from)
                to = to - length(from);
            end


            Property = ["DataSets" "Vars" "RawData"];

            for i = 1:numel(Property)    
                % Save rows that require moving in Temp
                Temp = dataBase.(Property(i))(from,:);
                % Delete the rows from the property
                dataBase.(Property(i))(from,:) = [];
                % restack property using vertcat
                dataBase.(Property(i)) = [dataBase.(Property(i))(1:to-1,:);  Temp;  dataBase.(Property(i))(to:end,:)];      
            end

        end

        function findIc(dataBase,setNum,opt)
            arguments
                dataBase (1,1)
                setNum double
                % Name value
                opt.Ec double = 100
                opt.Voltages = dataBase.getHeaders(setNum,Probe = 'voltageProbe')
            end
            
            % convert row number to set name
            setName = string(dataBase.RawData.Properties.RowNames(setNum)); 
            
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
                IdataHeader = dataBase.getHeaders(setNum(s),Probe = 'currentProbe');
                Idata = dataBase.DataSets.Data{setName(s)}.(IdataHeader{1,1});
                IntrpCurrent = linspace(Idata(1),Idata(end),1000);
                
                % looping through all Voltage headers                
                for i = 1: numel(opt.Voltages{setName(s),:})
                    % interpolate the current column
                    IntrpVolt = interp1(Idata,dataBase.DataSets.Data{setName(s)}.(opt.Voltages{setName(s),i}),IntrpCurrent,"makima");
                    
                    % Get index of value closest to Ec
                    [~ ,Index] = min(abs(IntrpVolt - opt.Ec));
                    
                    % Save Ic to table with correct header
                    dataBase.Ic{setName(s),opt.Voltages{setName(s),i}}  = IntrpCurrent(Index);
                    Icvals(i) = IntrpCurrent(Index);
                end

            % adding standard diviation and mean
            dataBase.Ic{setName(s),"Average"} = mean(Icvals);
            dataBase.Ic{setName(s),"StandDev"} = std(Icvals);

            end
        end
        
        function findN(dataBase,setNum,opt)
            arguments
                dataBase  
                setNum double = 1:height(dataBase.Ic)
                opt.Ec double = 100
                opt.Voltages = getHeaders(dataBase,setNum,Probe = "voltageProbe") 
            end
   
            % convert row number to set name
            setName = string(dataBase.RawData.Properties.RowNames(setNum));
              
            if class(opt.Voltages) == "string"
                T = repmat(opt.Voltages,numel(setName),1);
                T = array2table(T);
                T.Properties.RowNames = setName;
                opt.Voltages = T;
            end 

            for s = 1:numel(setName)
                % find Ic first if not yet found
                if isempty(dataBase.Ic)
                    dataBase.findIc(setNum(s),"Voltages",opt.Voltages);
                end
    
                Narray = zeros(1,numel(opt.Voltages(s,:)));
                Iraw = dataBase.DataSets.Data{setName(s)}.(table2array(dataBase.getHeaders(setNum(s),Probe = "currentProbe")));
               
                % prepare curve DataSet
                for i = 1:numel(opt.Voltages(s,:))
    
                    [Idata, Vdata] = prepareCurveData(Iraw,dataBase.DataSets.Data{setName(s)}.(opt.Voltages{setName(s),i}));
                    
                    % Set up fittype and options.
                    ft = fittype( string(opt.Ec) +'*(x/' + string(dataBase.Ic{setName(s),opt.Voltages{setName(s),i}}) + ")^n" , 'independent', 'x', 'dependent', 'y' );
                    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                    opts.Display = 'Off';
                    opts.StartPoint = 20;
                    
                    % Fit model to data.
                    [fitresult, gof] = fit( Idata, Vdata, ft, opts );
  %                 dataBase.n.(opt.Headers(i)) = array2table(zeros(0,2),VariableNames = ["fitresult","gof"]);
                    dataBase.N{setName(s),opt.Voltages{setName(s),i}} = fitresult.n;
                    dataBase.N{setName(s),opt.Voltages{setName(s),i}+" fit"} = {fitresult};
                    dataBase.N{setName(s),opt.Voltages{setName(s),i}+" gof"} = gof;
                    Narray(i) = fitresult.n;
                end              
                dataBase.N{setName(s),"Average"} = mean(Narray);
                dataBase.N{setName(s),"Std"} = std(Narray);       
            end
        end 

        function findTop(dataBase,setNum)
            arguments
                dataBase
                setNum double = 1:height(dataBase.DataSets)
            end
            
            warning("off",'MATLAB:table:RowsAddedNewVars');


            % convert row number to set name
            setName = string(dataBase.RawData.Properties.RowNames(setNum));
            
            % set the right values for constants
            if dataBase.Vars.Liquid == "H2"
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
                P   = dataBase.Vars{setName(i), "Pressure"};
                dataBase.Vars{setName(i),"Top"} = (-B/(log10(P)-A))-C;
            end

        end

        function adjustIc(dataBase,setNum,opt)
            arguments
                dataBase
                setNum double = 1:height(dataBase.Ic)
                opt.T (1,1) double  = 77.34
                opt.Voltages = dataBase.getHeaders(setNum,Probe="VoltageProbe")
            end

            % convert row number to set name
            setName = string(dataBase.RawData.Properties.RowNames(setNum)); 

            
            % if an input is given in the form of string array, convert to
            % table. In all sets the voltages in the string will evaluated.
            if class(opt.Voltages) == "string"
                T = repmat(opt.Voltages,numel(setName),1);
                T = array2table(T);
                T.Properties.RowNames = setName;
                opt.Voltages = T;
            end 
            
            % First find Top
            findTop(dataBase,setNum)

            % get Tc and Top
    	    Tc  = dataBase.Vars{setName,"Tc"};
            Top = dataBase.Vars{setName,"Top"};

            
            for s = 1:numel(setName)

%                 FindIc(dataBase,set(s),"Voltages",opt.Voltages{set(s),:})

                for v = 1:numel(opt.Voltages{setName(s),:})
                    if ~ismember(opt.Voltages{setName(s),v},dataBase.AdjustedIc.Properties.VariableNames)
                        dataBase.AdjustedIc{:,opt.Voltages{setName(s),v}} = NaN;
                    end
                    if ~ismember(setName(s),dataBase.AdjustedIc.Properties.RowNames) && height(dataBase.AdjustedIc) > 1
                        dataBase.AdjustedIc{setName(s),:} = NaN;
                    end 
                    dataBase.AdjustedIc{setName(s),opt.Voltages{setName(s),v}} = dataBase.Ic{setName(s),opt.Voltages{setName(s),v}}*(1- (Top(s)-opt.T)/(Top(s)-Tc(s)));
                end
            end

            % adjust Tc and Top according to linear scaling
            dataBase.AdjustedIc{setName,"T"} = opt.T;

            if ismember("Row1",dataBase.AdjustedIc.Properties.RowNames)
                dataBase.AdjustedIc("Row1",:) = [];
            end


        end
        
        function plotLogLog(dataBase,setNum,opt)                                                                                                                                                                                                            
            arguments
                dataBase
                setNum double
                opt.x string = "I"
                opt.y string = "V1";
                opt.Title string = "";
            end
            
            dataBase.findIc(setNum,"Voltages",opt.y)
            dataBase.findN(setNum,"Voltages",opt.y)

            %color array
            Color = ['b','r','g','c','y','m'];

            % convert row number to set name
            SetName = string(dataBase.RawData.Properties.RowNames(setNum)); 
            
            hold on
            box on


            for s = 1:numel(SetName)
                for i = 1:numel(opt.y)
                    % prepare x,y data 
                    YData = dataBase.DataSets.Data{SetName(s)}.(opt.y(i));
                    XData = dataBase.DataSets.Data{SetName(s)}.(opt.x);
                    
                    fit = dataBase.N{SetName(s), opt.y(i)+ " fit"}{1};
                    legendName = SetName(s) + " n = " + string(round(fit.n));

                    scatter(XData, YData, 40, Color(mod(s+i-1,numel(Color))),"DisplayName",legendName)  
                    
                    Xfit = linspace(0,XData(end),10000); 
                    Yfit = fit(Xfit);

                    scatter(Xfit,Yfit,0.3, Color(mod(s+i-1,numel(Color))), 'HandleVisibility','off');
                    xline(dataBase.Ic{SetName,opt.y(i)},LineWidth= 0.5,HandleVisibility="off");
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

        function headers = getHeaders(dataBase,setNum,opt)
            arguments
            dataBase
            setNum double
            opt.Probe string = "VoltageProbe"
            end

            warning('off', 'MATLAB:table:RowsAddedExistingVars');
            
            % convert row number to set name
            set = string(dataBase.RawData.Properties.RowNames(setNum));            

            headers =  table();
            
            
            % Loop through each object in the cell array
            for s = 1:numel(set)
                v = 1; 
                for i = 1:width(dataBase.RawData.Probes{set(s),:})
                    % Check if the class of the object is "VoltageProbe"
                    if isa(dataBase.RawData.Probes{set(s),:}{i}, opt.Probe)
                        % If it is, add the index of the object to the indices vector
                        headers{set(s),v} = dataBase.RawData.Probes{set(s),:}{i}.Name;
                        v = v + 1;
                    end
                end
            end

            if opt.Probe == "CurrentProbe"
                headers = table2array(headers);
            end
        end
    
        function [fitresult, gof] = GetFit(dataBase,setNum,opt)
            arguments
                dataBase
                setNum double
                opt.x = "V1"
                opt.y = dataBase.getHeaders(setNum,Probe = "CurrentProbe")
                opt.Ec = 100
            end

            setName = string(dataBase.RawData.Properties.RowNames(setNum));
            
            % first find Ic
            dataBase.findIc(setNum,"Voltages",opt.x);

            
            Iraw = dataBase.DataSets.Data{setName}.(opt.y);
            [Idata, Vdata] = prepareCurveData(Iraw(6:end),dataBase.DataSets.Data{setName}.(opt.x)(6:end));
                    
            % Set up fittype and options.
            ft = fittype( string(opt.Ec) +'*(x/' + string(dataBase.Ic{setName,opt.x}) + ")^n" , 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Display = 'Off';
            opts.StartPoint = 20;
            
            % Fit model to data.
            [fitresult, gof] = fit(Idata, Vdata, ft, opts);

        end
         
        function addLog(dataBase,Log,setNum)
            arguments
                dataBase
                Log string
                setNum double = height(dataBase.DataSets)
            end
            
            if  isa(setNum, "double")
                % convert row number to set name
                setName = string(dataBase.RawData.Properties.RowNames(setNum));
            end

            dataBase.Log = Log;
            dataBase.table.SetName = setName;
            dataBase.Date = datatime();
              
            
        end

        function saveDB(dataBase)
            eval(dataBase.Name+"=dataBase;")
            save(dataBase.Name,dataBase.Name)
        end
    end
end
