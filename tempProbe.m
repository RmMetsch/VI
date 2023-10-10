classdef tempProbe < connection
    properties
        Data
        error
        Points
        SCPI
        Channel
        Unit
    end
    methods
        function obj = tempProbe(adress,name,channel)

            arguments
                adress double
                name string
                channel string = "A"
            end
            
            % call the connection constructor
            superArgs{1} = adress;
            superArgs{2} = name;        
            obj@connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Unit = "K";
            obj.Channel = channel;
            obj.Data = [];

            configure(obj)

        end           
    end
end

