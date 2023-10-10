classdef connection < handle
    properties
        Instr
        Name
        Settings
    end
    methods

        function obj = connection(adress,name)  
            % Try to connect to Instrument, if connection already exists
            % copy connection from existing variable over to new one. 
            try
                obj.Instr = visadev("GPIB0::"+string(adress)+"::INSTR");
                fopen(obj.Instr);
            catch
                baseVars = evalin("base","who");
                for i = 1:numel(baseVars)  
                    if ~any("connection" == superclasses(evalin("base",baseVars{i})))
                       continue
                    end

                    if adress == evalin("base",baseVars{i}+".Instr.PrimaryAddress")
                        obj.Instr = evalin("base", baseVars{i} + ".Instr");
                    end
                end
            end

            if isempty(obj.Instr)
                disp("Failed to initilize Instrument: "+name+", at adress: "+adress)
                return
            end

            obj.Name  = name;      
            obj.Settings = struct;
        end
        
        function get(varargin)

             for i = 1:numel(varargin)
                
                % voltageProbe
                if class(varargin{i}) == "voltageProbe"
                    if varargin{i}.Instr.Model == "MODEL 2182A"
                        currentChannel = double(convertCharsToStrings(query(varargin{i}.Instr, "SENS:CHAN?")));
                        if currentChannel ~= varargin{i}.Channel
                            write(varargin{i}.Instr,"SENS:CHAN "+varargin{i}.Channel)
                            pause(2)
                        end
                    end
                    

                    rawData = convertOutput(writeread(varargin{i}.Instr,varargin{i}.SCPI.Get));
                    scaledData = (varargin{i}.Gain.Digital/varargin{i}.Gain.Analog).*rawData./varargin{i}.Seperation;

                    disp(varargin{i}.Name+ " = "+string(scaledData)+" "+ varargin{i}.Unit)
                    pause(varargin{i}.Settings.SettleTime)

                end  
                % currentProbe
                if class(varargin{i}) == "currentProbe"
                    rawData = str2double(query(varargin{i}.Instr,varargin{i}.SCPI.Get))*varargin{i}.ConvertionFactor;
                    disp(varargin{i}.Name+ " = "+string(rawData) +" "+ varargin{i}.Unit)

                end
                % temperatureProbe
                if class(varargin{i}) == "tempProbe"
                    rawData = str2double(query(varargin{i}.Instr,varargin{i}.SCPI));
                    disp(varargin{i}.Name+ " = "+string(rawData)+" "+ varargin{i}.Unit)
                end

                % field Probe
                if class(varargin{i}) == "fieldProbe"
                    Data = convertOutput(writeread(varargin{i}.Instr,varargin{i}.SCPI.Get));
                    rawData = asind((Data)/varargin{i}.RightAngleSignal);
                    disp(varargin{i}.Name+ " = "+rawData+" "+ varargin{i}.Unit);
                end
                                    

                
                pause(0.1) 
             end
        end

        function measure(varargin)

            for i = 1:numel(varargin)

                % voltageProbe
                if class(varargin{i}) == "voltageProbe"
                    
                    % change channel of Nanovolt meter
                    if varargin{i}.Instr.Model == "MODEL 2182A"
                        currentChannel = double(convertCharsToStrings(query(varargin{i}.Instr, "SENS:CHAN?")));
                        if currentChannel ~= varargin{i}.Channel
                            write(varargin{i}.Instr,"SENS:CHAN "+varargin{i}.Channel)
                            pause(2)
                        end
                    end
                    
                    % perform measurement and read
                    if varargin{i}.Settings.Trace
                        write(varargin{i}.Instr,varargin{i}.SCPI.Trigger)
                        pause(0.2*varargin{i}.Settings.Points/varargin{i}.Settings.Rate)
                        rawData = convertOutput(writeread(varargin{i}.Instr,varargin{i}.SCPI.Read));
                    else
                        rawData = convertOutput(writeread(varargin{i}.Instr,varargin{i}.SCPI.Get));
                    end

                    % multiply rawData with Gains and Seperation
                    scaledData = (varargin{i}.Gain.Digital/varargin{i}.Gain.Analog).*rawData./varargin{i}.Seperation;
                
                    % save to Data and Error
                    varargin{i}.Data(end+1,1)  = mean(scaledData);
                    varargin{i}.Error(end+1,1) = std(scaledData); 
                end
                
                % currentProbe
                if class(varargin{i}) == "currentProbe"
                    varargin{i}.Data(end+1,1) = str2double(query(varargin{i}.Instr,varargin{i}.SCPI.Get))*varargin{i}.ConvertionFactor;
                end

                % fieldProbe
                if class(varargin{i}) == "fieldProbe"
                    Data = convertOutput(writeread(varargin{i}.Instr,varargin{i}.SCPI.Get));
                    varargin{i}.Data(end+1,1) = Data;
                    varargin{i}.Data(end,2) = asind((Data)/varargin{i}.RightAngleSignal);
                end
                
                % temperatureProbe
                if class(varargin{i}) == "tempProbe"
                    pause(0.1)
                     varargin{i}.Data(end+1,1) = str2double(query(varargin{i}.Instr,varargin{i}.SCPI));
                end
                    
                % scannercard
                if class(varargin{i}) == "scannerCard"
                    varargin{i}.Data(end+1,:) = convertOutput(query(varargin{i}.Instr,varargin{i}.SCPI));
                end




            end
        end

        function clearData(varargin)
            for v = 1:numel(varargin)
                varargin{v}.Data = [];
                if isprop(varargin{v},'Error')
                    varargin{v}.Error = [];
                end

            end
        end

        function offsetData(varargin)
            for v = 1:numel(varargin)
                varargin{v}.Data = varargin{v}.Data - varargin{v}.Data(1); 
            end
        end
   
    end
end



