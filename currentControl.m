classdef currentControl < connection
    properties
        ConvertionFactor
        rampSpeed
        SCP    
    end
    
    methods
        function obj = currentControl(adress,name,convertionFactor)
            arguments
                adress double
                name string
                convertionFactor double
            end
        
            % calling the superclass
            superArgs{1} = adress;
            superArgs{2} = name;        
            obj@connection(superArgs{:})
            
            obj.ConvertionFactor = convertionFactor;

            configure(obj)
        end

        function set(obj,setPoint)
            arguments
                obj currentControl
                setPoint double
            end
           
            currentSetpoint = double(query(obj.Instr,obj.SCPI.Query))/obj.ConvertionFactor;

            for I = linspace(currentSetpoint,setPoint,1 + 10*(abs(currentSetpoint-setPoint)/rampspeed))
                write(obj.Instr,strcat(obj.SCPI.Set," ",string(obj.ConvertionFactor*I)))
                pause(0.1)
            end            
        end

        function output(obj,status)
            arguments
                obj currentControl
                status 
            end
            
            if status == 1
                status = "ON";
            elseif status == 0
                status = "OFF";
            end
        
            write(obj.Instr,strcat(obj.SCPI.Output, status))
        end
        
    end
end
