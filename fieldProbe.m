classdef fieldProbe < connection
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data
        Error
        Unit
        SCPI
        RightAngleSignal
        Offset
    end
    
    methods

        function obj = fieldProbe(adress,name,rightAngleSignal)
            %   Constructs a field probe, a fieldProbe is assumed to be a
            %   hallprobe type, It calculates the angle of a known field
            %   using the measure method and the following equation,      
            %       
            %       angle = arccos(signal/RightAngleSignal).
            %
            %   To be added: calculate field from known angle.
            
            arguments
                adress double
                name string
                rightAngleSignal double
            end

            % call the connection constructor
            superArgs{1} = adress;
            superArgs{2} = name;        
            obj@connection(superArgs{:})

            % initialize remaining properties
            obj.RightAngleSignal = rightAngleSignal;
            obj.Unit = "degrees";

            % Set Trace to OFF(= 0)
            obj.Settings.Trace = 0;

            % call configure function
            configure(obj)
        end
        

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

