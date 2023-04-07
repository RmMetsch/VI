classdef CurrentProbe < connection
    properties
        Data
        ConvertFactor
        SCPI
    end

    methods
        function obj = CurrentProbe(Adress,Name,ConvertFactor)
            arguments
                Adress double 
                Name string = "I"
                ConvertFactor = 10
            end

%             obj.ConvertFactor = ConvertFactor;
            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@connection(superArgs{:})
        end
    end
end
