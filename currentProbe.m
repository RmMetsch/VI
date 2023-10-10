classdef currentProbe < connection
    properties
        Data
        ConvertionFactor
        SCPI
        Unit
    end

    methods
        function obj = currentProbe(adress,name,convertionFactor)
            arguments
                adress double 
                name string
                convertionFactor double
            end

            % Call the connection constructor
            superArgs{1} = adress;
            superArgs{2} = name;        
            obj@connection(superArgs{:})

            % Populate properties
            obj.Unit = "A";
            
            % Fill in as (A/v)
            obj.ConvertionFactor = convertionFactor;
            
            % Set Trace to OFF(= 0)
            obj.Settings.Trace = 0;

            % call the configure function
            configure(obj)
            
        end
    end
end
