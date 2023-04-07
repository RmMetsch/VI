classdef TempProbe < connection
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
                Adress = 1
                Name   = 1
                Points = 1;
                unit string = "K";
                SCPI string = 'SENS:DATA?';
            end
            
            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Points = Points;
            obj.SCPI = SCPI;
            obj.unit = unit;

        end           
    end
end
