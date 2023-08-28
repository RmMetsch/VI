%% VI script for shortsample measurments

%% connect all devices
clear

% Voltage Taps
V1 = VoltageProbe(9,"V1",0.04,1,1);
V2 = VoltageProbe(9,"V2",0.08,1,2);

% Vquench
Vq1 = VoltageProbe(2,"Vq1",1,1,1,1);
Vq2 = VoltageProbe(5,"Vq2",1,1,1,1);
Vq3 = VoltageProbe(18,"vq3",1,1,1,1);

% Current control/probe
Icont = CurrentControl(22,"Icont",10/1220);
Imeas = CurrentProbe(13,"I",2000/10);

% Temperature sensors
T1 = TempProbe(12,"T1","A");
T2 = TempProbe(12,"T2","B");
T3 = TempProbe(12,"T3","C");

% Coil
% Vcoil = VoltageProbe(13,"Vcoil");

% variables


% check instruments
Icont.Output("ON")
I = 0;
Icont.Set(I)
Get(Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3)


%% Measurement loop
% clear data, set current to 0 and initialize a plot

I = 0;
ClearData(Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3)
MakePlot(Imeas,V1,V2,Vq3)


% set current and measure
Icont.Set(0)
Measure(Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3)
UpdatePlot(Imeas,V1,V2,Vq3)


while true
    
    if abs(V1.Data(end)) < 50
        I = I + 0.8;
    end
    
    if abs(V1.Data(end)) > 200
        break
    end

    if I > 40 
        break
    end

    I  = I + 0.3;

    Icont.Set(I)
    Measure(Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3)
    UpdatePlot(Imeas,V1,V2,Vq3)
    
end

Icont.Set(0)

close all
OffsetData(V1,V2,Vq1,Vq2,Vq3)
plot(Imeas.Data(1:height(V1.Data)),[V1.Data V2.Data])
yline(100)

Vars = ["Pressure",1.0176,"Liquid","He2","Tc",94,"Field", 1.5 ,"Angle", 92];
Shang12.AddSet({Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3},"T = 30K, 1,5T 92deg, Degraded 2",Vars);
Shang12.save() 
