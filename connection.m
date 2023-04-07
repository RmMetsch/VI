classdef connection < handle
    properties
        Instr
        Name
    end
    methods
        function obj = connection(Adress,N)            
%             % set property values
%             obj.Instr = visadev("GPIB0::"+string(Adress)+"::INSTR");
            obj.Name  = N;
        end

        function Measure(varargin)
            for i = 1:numel(varargin)
                
                % Voltage function
                if class(varargin{i}) == "VoltageProbe"
                    temp = zeros(1,varargin{i}.Points);

                    for j = 1:varargin{i}.Points
                        temp(j) = str2double(query(varargin{i}.Instr,varargin{i}.SCPI));
                        temp(j) = 10^6*temp(j)/(varargin{i}.Distance*varargin{i}.Amplification);
                    end

                    varargin{i}.error(end+1,1) = std(temp);
                    varargin{i}.Data(end+1,1)  = mean(temp);
    
                end
                
                % Current function
                if class(varargin{i}) == "CurrentProbe"
                    varargin{i}.Data(end+1) = str2double(query(varargin{i}.Instr,obj.SCPI))*varargin{i}.ConvertFactor;
                end
                
                % Temperature function
                if class(varargin{i}) == "TemperatureProbe"
                    varargin{i}.Data(end+1) = str2double(query(varargin{i}.Instr,obj.SCPI));
                end

            end
        end
        
    end
end



