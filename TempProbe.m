classdef TempProbe < Connection
    properties
        Data
        error
        Points
        SCPI
        unit
    end
    methods
        function obj = TempProbe(Adress,Name,Points,unit,SCPI)

            arguments
                Adress double
                Name string
                Points = 1;
                unit string = "K";
                SCPI string = 'SENS:DATA?';
            end
            
            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Points = Points;
            obj.SCPI = SCPI;
            obj.unit = unit;

        end           
    end
end
