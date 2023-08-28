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
            obj.Unit = "A";
            obj.Data = [];

            Configure(obj)


        end

        function Set(obj,I)
            write(obj.Instr,strcat(obj.SCPI," ",string(obj.ConvertFactor*I)))
            obj.Data(end+1) = I;
            pause(1)
        end

        function Output(obj,status)
            arguments
                obj CurrentControl
                status string
            end
            write(obj.Instr,strcat("OUTP ", status))
        end
        
    end
end
