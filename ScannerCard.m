classdef ScannerCard < Connection
    %SCANNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data
        Unit
        SCPI
        NoChannels
        Seperation
    end
    
    methods
        function obj = ScannerCard(Adress,Name,NoChannels,Seperation)

            % call the connection constructor
            superArgs{1} = Adress;
            superArgs{2} = Name;        
            obj@Connection(superArgs{:})

            % set values specific to Scanner constructor
            obj.NoChannels = NoChannels;
            obj.Data = [];
            obj.Seperation = Seperation;
            obj.Unit = "uV/m";
            

            % configure multimeter to scanner
            write(obj.Instr,"*RST")
            pause(0.1)
            write(obj.Instr,"FORM:ELEM READ")
            pause(0.1)
            write(obj.Instr,"TRAC:CLE")
            pause(0.1)
            write(obj.Instr,"INIT:CONT OFF")
            pause(0.1)
            write(obj.Instr,"TRIG:SOUR IMM")
            pause(0.1)
            write(obj.Instr,"TRIG:COUN 1")
            pause(0.1)
            write(obj.Instr,"SAMP:COUN "+obj.NoChannels)
            pause(0.1)
            write(obj.Instr,"ROUT:SCAN (@101:104, 111:113)")
            pause(0.1)
            write(obj.Instr,"ROUT:SCAN:TSO IMM")
            pause(0.1)
            write(obj.Instr,"ROUT:SCAN:LSEL INT")
  
            Configure(obj)       

            obj.SCPI = "READ?";

        end
    end
end

