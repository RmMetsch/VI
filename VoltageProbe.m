classdef VoltageProbe < Connection
    properties
        Data
        error
        Points
        Distance
        Gain
        SCPI
        RemoveCharFromOutput
        unit
    end
    methods
        function obj = VoltageProbe(Adress,Name,Distance,Gain,Points,unit,SCPI,RemoveCharFromOutput)
            arguments
                Adress (1,1) double
                Name (1,1) string
                Distance (1,1) double = 1;
                Gain (1,1) double = 1;
                Points (1,1) double = 3;
                unit string = "uV/m";
                SCPI string = 'SENS:DATA?';
                RemoveCharFromOutput string = "";
            end

            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Points = Points;
            obj.Distance = Distance;
            obj.Gain = Gain;
            obj.SCPI = SCPI;
            obj.unit = unit;
            obj.RemoveCharFromOutput = RemoveCharFromOutput;
        end           
    end

      



end

