classdef VoltageProbe < connection
    properties
        Data
        error
        Points
        Distance
        Gain
        SCPI
        unit
    end
    methods
        function obj = VoltageProbe(Adress,Name,Points,Distance,Gain,unit,SCPI)
            arguments
                Adress = 1
                Name = 1
                Points = 3;
                Distance = 1;
                Gain = 1;
                unit string = "uV/m";
                SCPI string = 'SENS:DATA?';
            end

            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Points = Points;
            obj.Distance = Distance;
            obj.Gain = Gain;
            obj.SCPI = SCPI;
            obj.unit = unit;

        end           
    end
end
