classdef CurrentProbe < Connection
    properties
        Data
        ConvertFactor
        SCPI
        Unit
    end

    methods
        function obj = CurrentProbe(Adress,Name,ConvertFactor)
            arguments
                Adress double 
                Name string
                ConvertFactor double
            end

            % Call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})

            % Populate properties
            obj.Unit = "A";
            
            % Fill in as (A/v)
            obj.ConvertFactor = ConvertFactor;
            
            Configure(obj)
            
        end
    end
end
