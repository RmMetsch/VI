function Configure(obj)
    

    Model = string(query(obj.Instr, "*IDN?"));
 
    %% Volt Meters
    % Model DMM6500 
    if contains(Model, "DMM6500" )
        obj.SCPI = ":READ?";
    end

    % Model 2182 A nanovoltmeter
    if contains(Model, "MODEL 2182A")
        obj.SCPI = "DATA?";
    end
    
    % model 2000 2400 2700
    if contains(Model,"MODEL 2000")
        obj.SCPI = "SENS:DATA?";
    end

    if contains(Model,"MODEL 2400")
        obj.SCPI = "SENS:DATA?";
    end

    if contains(Model, "MODEL 2700")
        obj.SCPI = "SENS:DATA?";
        write(obj.Instr, "FORM:ELEM READ")
    end

    %% Current Controlers
    if contains(Model,"2200-20-5")
        obj.SCPI = "SOUR:VOLT";
    end

    if contains(Model, "33521B")
        write(obj.Instr,"FUNC DC")
        obj.SCPI = "VOLT:OFFSET";
    end

    %% Temperature Sensors
    % lakeshore MODEL336
    if contains(Model,"MODEL336")
        obj.SCPI = "KRDG? "+ obj.Channel; 
    end
    
    
    if isempty(obj.SCPI)
        disp("No SCPI found for instrument: "+obj.Name)
    end

end


