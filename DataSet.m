classdef DataSet < handle
   
    properties
        Data
        MeasCond
        SampleProp
        Comments
        RawData
    end
    
    methods

        function obj = DataSet(DataSet,MeasCond,SampleProp)
           
            % populate the Data property with the provided data 
            obj.Data = array2table(zeros(numel(DataSet{1}.Data),numel(DataSet)));

            for i = 1:numel(DataSet)
                obj.Data{:,i} =  DataSet{i}.Data;
                obj.Data.Properties.VariableNames(i) = string(DataSet{i}.Name);
            end
    
            % populate the measurment conditions table with the measurement
            % conditions provided
            obj.MeasCond = array2table(zeros(1,numel(MeasCond)/2));

            for i = 1:numel(MeasCond)/2
                obj.MeasCond{1,i} = double(MeasCond(2*i));
                obj.MeasCond.Properties.VariableNames(i) = string(MeasCond(2*i-1));

            end

                        
            % populate the measurment conditions table with the measurement
            % conditions provided
            obj.SampleProp = array2table(zeros(1,numel(SampleProp)/2));

            for i = 1:numel(SampleProp)/2
                obj.SampleProp{1,i} = double(SampleProp(2*i));
                obj.SampleProp.Properties.VariableNames(i) = string(SampleProp(2*i-1));
            end
            

            % expand this
            obj.RawData = DataSet.';



        end
                
        function FindIc(DataSet,opt)
            arguments
                DataSet
                % Name value
                opt.Ec double = 100
                opt.Voltages string = DataSet.getHeaders(Probe = 'VoltageProbe')

            end
            
            % initializing some arrays for later use
            Icvals = zeros(1,numel(opt.Voltages));
            DataSet.SampleProp.Ic = array2table(1);

            % getting the current data and interpolating
            Idata = DataSet.Data.(DataSet.getHeaders(Probe = 'CurrentProbe'));
            IntrpCurrent = linspace(Idata(1),Idata(end),1000);
            
            % looping through all Voltage headers                
            for i = 1: numel(opt.Voltages)
                % interpolate the current column
                IntrpVolt = interp1(Idata,DataSet.Data.(opt.Voltages(i)),IntrpCurrent,"makima");
                
                % Get index of value closest to Ec
                [~ ,Index] = min(abs(IntrpVolt - opt.Ec));
                
                % Save Ic to table with correct header
                DataSet.SampleProp.Ic.(opt.Voltages(i))  = IntrpCurrent(Index);
                Icvals(i) = IntrpCurrent(Index);
            end
            
            % adding standard diviation and mean
            DataSet.SampleProp.Ic.("Average") = mean(Icvals);
            DataSet.SampleProp.Ic.("StandDev") = std(Icvals);
            DataSet.SampleProp.Ic = removevars(DataSet.SampleProp.Ic, "Var1");
        end
        
        function FindN(DataSet,opt)
            arguments
                DataSet  

                opt.Ec double = 100
                opt.Voltages string   = getHeaders(DataSet,Probe = "VoltageProbe") 
            end
            
            
            % find Ic first if not yet found
            if ~exist('DataSet.SampleProp.Ic', 'var')
                DataSet.FindIc();
            end
            
            % make empty array if none yet exists
            if ~exist("DataSet.SampleProp.n","var")
                DataSet.SampleProp.("n") = array2table(zeros(1));            
            end

            Narray = zeros(1,numel(opt.Voltages));
            Iraw = DataSet.Data.(DataSet.getHeaders(Probe = "CurrentProbe"));
            

            % prepare curve data
            for i = 1:numel(opt.Voltages)

                [Idata, Vdata] = prepareCurveData(Iraw(6:end),DataSet.Data.(opt.Voltages(i))(6:end));
                
                % Set up fittype and options.
                ft = fittype( string(opt.Ec) +'*(x/' + string(DataSet.SampleProp.Ic.(opt.Voltages(i))) + ")^n" , 'independent', 'x', 'dependent', 'y' );
                opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                opts.Display = 'Off';
                opts.StartPoint = 20;
                
                % Fit model to data.
                [fitresult, ~] = fit( Idata, Vdata, ft, opts );
%                 DataSet.SampleProp.n.(opt.Headers(i)) = array2table(zeros(0,2),VariableNames = ["fitresult","gof"]);
                DataSet.SampleProp.n.(opt.Voltages(i)) = fitresult.n;
                 Narray(i) = fitresult.n;
            end
            
            DataSet.SampleProp.n.("Average") = mean(Narray);
            DataSet.SampleProp.n.("Standard Dev") = std(Narray);
            DataSet.SampleProp.n = removevars(DataSet.SampleProp.n,"Var1");

        end 

        function SetTop(DataSet,Liquid)
            arguments
                DataSet
                Liquid = "N2"
            end
            
            % set the right values for constants
            if Liquid == "H2"
                A = 8.759;
                B = 6166.79;
                C = -6.289;
            else
                A = 3.63792;
                B = 257.877;
                C = -6.344;
            end
            
            % get pressure and determine the opperating Temperature
            P   = DataSet.MeasCond.Pressure;
            DataSet.MeasCond.Top = (-B/(log10(P)-A))-C;  

        end

        function AdjustIc(DataSet,opt)
            arguments
                DataSet
                opt.T   (1,1) double  = 77
                opt.Voltages string = DataSet.getHeaders(Probe="VoltageProbe")
            end
            
            if ~exist("DataSet.SampleProp.AdjustedIc","var")
                DataSet.SampleProp.AdjustedIc = array2table(zeros(1));
            end

            if ~exist("DataSet.MeasCond.Top","var")
                SetTop(DataSet)
            end

            % get Tc and Top
    	    Tc  = DataSet.SampleProp.Tc;
            Top = DataSet.MeasCond.Top;
            
            for i = 1:numel(opt.Voltages)
                Ic = DataSet.SampleProp.Ic.(opt.Voltages(i));
                DataSet.SampleProp.AdjustedIc.(opt.Voltages(i)) = Ic*(1+ (Top-opt.T)/(Top-Tc));
            end
            
            % adjust Tc and Top according to linear scaling
            DataSet.SampleProp.AdjustedIc.T = opt.T;
            DataSet.SampleProp.AdjustedIc = removevars(DataSet.SampleProp.AdjustedIc,"Var1");

  
        end

        function Headers = getHeaders(DataSet,opt)
            arguments
            DataSet
            opt.Probe string
            end

            Headers = [];
            % Loop through each object in the cell array
            for i = 1:length(DataSet.RawData)
                % Check if the class of the object is "VoltageProbe"
                if isa(DataSet.RawData{i}, opt.Probe)
                    % If it is, add the index of the object to the indices vector
                    Headers = [Headers DataSet.RawData{i}.Name];
                end
            end
        end

    end
end
