classdef Connection < handle
    properties
        Instr
        Name
    end
    methods

        function obj = Connection(Adress,Name)  
            % set property values
            obj.Instr = visadev("GPIB0::"+string(Adress)+"::INSTR");
            obj.Name  = Name;
            fopen(obj.Instr);
        end
        
        function get(varargin)

             for i = 1:numel(varargin)
                % VoltageProbe
                if class(varargin{i}) == "VoltageProbe"
                    temp = str2double(strrep((query(varargin{i}.Instr,varargin{i}.SCPI)),varargin{i}.RemoveCharFromOutput,""));
                    temp = 10^6*temp/(varargin{i}.Distance*varargin{i}.Gain);
                    disp(varargin{i}.Name+ " = "+string(temp))
                end
                
                % CurrentProbe
                if class(varargin{i}) == "CurrentProbe"
                    temp = str2double(query(varargin{i}.Instr,varargin{i}.SCPI))*varargin{i}.ConvertFactor;
                    disp(varargin{i}.Name+ " = "+string(temp))
                end
                
                % TemperatureProbe
                if class(varargin{i}) == "TemperatureProbe"
                    temp = str2double(query(varargin{i}.Instr,obj.SCPI));
                    disp(varargin{i}.Name+ " = "+string(temp))
                end

            end

        end

        function measure(varargin)
            for i = 1:numel(varargin)
                % VoltageProbe
                if class(varargin{i}) == "VoltageProbe"
                    temp = zeros(1,varargin{i}.Points);
                    for j = 1:varargin{i}.Points
                        warning('off');
                        pause(0.25)
                        temp(j) = str2double(strrep((query(varargin{i}.Instr,varargin{i}.SCPI)),varargin{i}.RemoveCharFromOutput,""));
                        temp(j) = 10^6*temp(j)/(varargin{i}.Distance*varargin{i}.Gain);
                        
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
                if class(varargin{i}) == "TemperatureProbe"
                    varargin{i}.Data(end+1,1) = str2double(query(varargin{i}.Instr,obj.SCPI));
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



