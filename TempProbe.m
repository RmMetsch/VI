classdef TempProbe < Connection
    properties
        Data
        error
        Points
        SCPI
        Channel
        Unit
    end
    methods
        function obj = TempProbe(Adress,Name,Channel)

            arguments
                Adress double
                Name string
                Channel string = "A"
            end
            
            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Unit = "K";
            obj.Channel = Channel;
            obj.Data = [];

            Configure(obj)

        end           
    end
end

