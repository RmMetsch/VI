classdef Connection < handle
    properties
        Instr
        Name
    end
    methods

        function obj = Connection(Adress,Name)  
            % Try to connect to instrument, if connection already exists
            % copy connection from existing variable over to new one. 
            try
                obj.Instr = visadev("GPIB0::"+string(Adress)+"::INSTR");
                fopen(obj.Instr);
            catch
                BaseVars = evalin("base","who");
                for i = 1:numel(BaseVars)   
                    if Adress == evalin("base",BaseVars{i}+".Instr.PrimaryAddress")
                        obj.Instr = evalin("base", BaseVars{i} + ".Instr");
                    end
                end
            end

            if isempty(obj.Instr)
                disp("Failed to initilize instrument: "+Name+", at adress: "+Adress)
            end

            obj.Name  = Name;      
        end
        
        function Get(varargin)

             for i = 1:numel(varargin)
                
                % VoltageProbe
                if class(varargin{i}) == "VoltageProbe"
                    if varargin{i}.Instr.Model == "MODEL 2182A"
                        write(varargin{i}.Instr,"SENS:CHAN "+varargin{i}.Channel)
                        pause(2)
                    end
                    temp = str2double(strrep((query(varargin{i}.Instr,varargin{i}.SCPI)),varargin{i}.RemoveCharFromOutput,""));
                    temp = 10^6*temp/(varargin{i}.Seperation*varargin{i}.Gain);
                    disp(varargin{i}.Name+ " = "+string(temp)+" "+ varargin{i}.Unit )
                end
                    
                % CurrentProbe
                if class(varargin{i}) == "CurrentProbe"
                    temp = str2double(query(varargin{i}.Instr,varargin{i}.SCPI))*varargin{i}.ConvertFactor;
                    disp(varargin{i}.Name+ " = "+string(temp) +" "+ varargin{i}.Unit)
                end
                
                % TemperatureProbe
                if class(varargin{i}) == "TempProbe"
                    temp = str2double(query(varargin{i}.Instr,varargin{i}.SCPI));
                    disp(varargin{i}.Name+ " = "+string(temp)+" "+ varargin{i}.Unit)
                end
                pause(0.1) 
            end

        end

        function Measure(varargin)

            for i = 1:numel(varargin)

                % VoltageProbe
                if class(varargin{i}) == "VoltageProbe"
                    temp = zeros(varargin{i}.Points,1);
                    
                    if varargin{i}.Instr.Model == "MODEL 2182A"
                        write(varargin{i}.Instr,"SENS:CHAN "+varargin{i}.Channel)
                        pause(2)
                    end
                    
                    for j = 1:varargin{i}.Points
                        warning('off');
                        pause(0.2)
                        temp(j) = str2double(strrep((query(varargin{i}.Instr,varargin{i}.SCPI)),varargin{i}.RemoveCharFromOutput,""));
                        temp(j) = 10^6*temp(j)/(varargin{i}.Seperation*varargin{i}.Gain);
                        
                    end
                    warning('on');
                    varargin{i}.error(end+1,1) = std(temp);
                    varargin{i}.Data(end+1,1)  = mean(temp);
                end
                
                % CurrentProbe
                if class(varargin{i}) == "CurrentProbe"
                    varargin{i}.Data(end+1,1) = str2double(query(varargin{i}.Instr,varargin{i}.SCPI))*varargin{i}.ConvertFactor;
                end
                
                % TemperatureProbe
                if class(varargin{i}) == "TempProbe"
                    pause(0.2)
                     varargin{i}.Data(end+1,1) = str2double(query(varargin{i}.Instr,varargin{i}.SCPI));
                end
            end
        end

        function ClearData(varargin)
            for v = 1:numel(varargin)
                varargin{v}.Data = [];
                if isprop(varargin{v},'error')
                    varargin{v}.error = [];
                end

            end
        end

        function OffsetData(varargin)
            for v = 1:numel(varargin)
                varargin{v}.Data = varargin{v}.Data - varargin{v}.Data(1); 
            end
        end
   
    end
end



