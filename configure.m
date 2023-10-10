function configure(obj)
    
    model = string(query(obj.Instr, "*IDN?"));
 
    %% Volt Meters
    % Model DMM6500 
    if contains(model, "DMM6500")
                % Set number of points in sweep
%         obj.Settings.Points = 10;
%         write(obj.Instr, "TRAC:POIN "+obj.Settings.Points)
% 
%         % Select source SENS, set reading ouput
%         write(obj.Instr, "TRAC:FEED SENS")
%         write(obj.Instr, "FORM:ELEM READ")

        % Set SCPI commands for trigger and read
        obj.SCPI = struct();
        obj.SCPI.Read    = "TRAC:DATA?";
        obj.SCPI.Trigger = "TRAC:FEED:CONT NEXT";
        obj.SCPI.Get     = "READ?";
        
        % set rate to medium = 1 Power line cycle ~ 20 ms
        obj.Settings.Rate = 1;
        write(obj.Instr,"SENS:VOLT:NPLC 1" )
        
        % set range to auto
        obj.Settings.Range = "AUTO";
        write(obj.Instr,"VOLT:DC:RANG:AUTO ON");
        
        % save model name
        obj.Settings.Model = obj.Instr.Model;

        % Turn digital filter OFF
        if class(obj) == "voltageProbe"
            write(obj.Instr,":SENS:VOLT:DC:AVER:STAT OFF")
            obj.Settings.digitalFilter = 0;
        else
            obj.Settings.digitalFilter = 1;
        end

        % Set settle time.
        obj.Settings.SettleTime = 0.2;
    end

    % Model 2182 A nanovoltmeter
    if contains(model, "MODEL 2182A")
        
        % Set number of points in sweep
        obj.Settings.Points = 10;
        write(obj.Instr, "TRAC:POIN "+obj.Settings.Points)

        % Select source SENS
        write(obj.Instr, "TRAC:FEED SENS")
        write(obj.Instr, "FORM:ELEM READ")
        
        % Set SCPI commands for trigger and read
        obj.SCPI = struct();
        obj.SCPI.Read    = "TRAC:DATA?";
        obj.SCPI.Trigger = "TRAC:FEED:CONT NEXT";
        obj.SCPI.Get     = "DATA?";

        % range Settings to auto
        obj.Settings.Range = "AUTO";
        write(obj.Instr, "SENS:VOLT:CHAN"+obj.Channel+":RANG:AUTO ON");

        % set rate to medium = 1 Power line cycle ~ 20 ms
        obj.Settings.Rate = 2;
        write(obj.Instr,"SENS:VOLT:NPLC 2" )
        
        % Set ananlog filter off
        write(obj.Instr,":SENS:VOLT:CHAN"+obj.Channel+":LPAS OFF")
        obj.Settings.analogFilter = 0;

        % Turn digital filter off
        write(obj.Instr,":SENS:VOLT:CHAN"+obj.Channel+":DFIL:STAT OFF")
        obj.Settings.digitalFilter = 0;
        
        % Save Name
        obj.Settings.Model = obj.Instr.Model;
        
        % Set settle time.
        obj.Settings.SettleTime = 0.2;
    end
    
    % model 2000 2400 2700 6500
    if contains(model,"MODEL 2000") || contains(model,"MODEL 2400") || contains(model,"MODEL 2700")
        
        % Set number of points in sweep
        obj.Settings.Points = 10;
        write(obj.Instr, "TRAC:POIN "+obj.Settings.Points)

        % Select source SENS, set reading ouput
        write(obj.Instr, "TRAC:FEED SENS")
        write(obj.Instr, "FORM:ELEM READ")

        % Set SCPI commands for trigger and read
        obj.SCPI = struct();
        obj.SCPI.Read    = "TRAC:DATA?";
        obj.SCPI.Trigger = "TRAC:FEED:CONT NEXT";
        obj.SCPI.Get     = "DATA?";
        
        % set rate to medium = 1 Power line cycle ~ 20 ms
        obj.Settings.Rate = 1;
        write(obj.Instr,"SENS:VOLT:NPLC 1" )
        
        % set range to auto
        obj.Settings.Range = "AUTO";
        write(obj.Instr,"VOLT:DC:RANG:AUTO ON");
        
        % save model name
        obj.Settings.Model = obj.Instr.Model;

        % Turn digital filter OFF
        if class(obj) == "voltageProbe"
            write(obj.Instr,":SENS:VOLT:DC:AVER:STAT OFF")
            obj.Settings.digitalFilter = 0;
        else
            obj.Settings.digitalFilter = 1;
        end
        

        % Set settle time.
        obj.Settings.SettleTime = 0.2;

    end
    
    %% Current Controlers
    if contains(model,"2200-20-5")
        obj.SCPI.Set    = "SOUR:VOLT";
        obj.SCPI.Query  = "SOUR:VOLT?";
        obj.SCPI.Output = "OUTP"; 
    end

    if contains(model, "33521B")
        write(obj.Instr,"FUNC DC")
        obj.SCPI = "VOLT:OFFSET";
    end


    %% Temperature Sensors
    % lakeshore MODEL336
    if contains(model,"MODEL336")
        obj.SCPI = "KRDG? "+ obj.Channel; 
    end
    
    
    if isempty(obj.SCPI)
        disp("No SCPI found for instrument: "+obj.Name)
        disp("Check user manual for suitable SCPI command")
    end

end


