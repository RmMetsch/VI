classdef CurrentControl < Connection
    properties
        Data
        ConvertFactor
        SCPI
        Unit
    end
    
    methods
        function obj = CurrentControl(Adress,Name,ConvertFactor)
            arguments
                Adress
                Name
                ConvertFactor
            end
        
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})
            
            obj.ConvertFactor = ConvertFactor;
            obj.SCPI = "SOUR:VOLT";
            obj.Unit = "A";
            obj.Data = [];

        end

        function set(obj,I)
            write(obj.Instr,strcat(obj.SCPI," ",string(obj.ConvertFactor*I)))
            obj.Data(end+1) = I;
        end

    end
end
