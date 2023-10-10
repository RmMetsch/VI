classdef voltageProbe < connection
    properties
        Data
        Error
        Unit
        Seperation
        Gain
        SCPI
        Channel
    end
    methods
        function obj = voltageProbe(adress,name,seperation,analogGain,channel)
            arguments
                adress (1,1) double
                name (1,1) string
                seperation double = 1;
                analogGain double = 1;
                channel double = 1;
            end

            % call the connection constructor
            superArgs{1} = adress;
            superArgs{2} = name;        
            obj@connection(superArgs{:})
            
            % set properties specific to Voltage probe constructor
            obj.Seperation = seperation;
            
            % set gain
            obj.Gain = struct;
            obj.Gain.Analog  = analogGain;
            obj.Gain.Digital = 10^6;

            % set unit
            obj.Unit = "uV/m";
            
            % set channel
            obj.Channel = channel;

            % Set Trace to ON(= 1)
            obj.Settings.Trace = 1;
            
            % set remaining fields depending on model used.
            configure(obj)
        end           
    end
end

