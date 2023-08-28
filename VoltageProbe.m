classdef VoltageProbe < Connection
    properties
        Data
        error
        Points
        Unit
        Seperation
        Gain
        SCPI
        Channel
        RemoveCharFromOutput
    end
    methods
        function obj = VoltageProbe(Adress,Name,Seperation,Gain,Channel,Points)
            arguments
                Adress (1,1) double
                Name (1,1) string
                Seperation double = 1;
                Gain double = 1;
                Channel double = 1;
                Points double = 3;
            end

            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})
            
            % set values specific to Voltage probe constructor
            obj.Points = Points;
            obj.Seperation = Seperation;
            obj.Gain = Gain;
            obj.Unit = "uV/m";
            obj.RemoveCharFromOutput = "";
            obj.Channel = Channel;
            
            % set remaining fields depending on model used.
            Configure(obj)
        end           
    end
end

