%% VI script for shortsample measurments

%% connect all devices
clear

% Voltage Taps
V1 = voltageProbe(7,"V1",0.04);
V2 = voltageProbe(9,"V2",0.08);

% Vquench
Vq1 = voltageProbe(2,"Vq1");
Vq2 = voltageProbe(16,"Vq2");
Vq3 = voltageProbe(18,"vq3");

Vq1.Settings.Trace = 0;
Vq2.Settings.Trace = 0;
Vq3.Settings.Trace = 0;

% Current control/probe
Icont = currentControl(22,"Icont",10/1000);
Imeas = currentProbe(13,"I",2000/10);

% Temperature sensors
T1 = tempProbe(12,"T1","A");
T2 = tempProbe(12,"T2","B");
T3 = tempProbe(12,"T3","C");

% Hall probe
Hall  = voltageProbe(30,"hallProbe");
Hall.Settings.Trace = 0;
Hall.Gain.Digital = 1;

% check instruments
Icont.output("ON")
I = 0;
Icont.set(I)
get(Imeas,V1,V2,HallPlus,HallMinus,Vq1,Vq2,Vq3,T1,T2,T3)

%% Measurement loop
% clear data, set current to 0 and initialize a plot

I = 0;
clearData(Icont,Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3,HallMinus,HallPlus)
makePlot(Imeas,V1,V2,Vq3)


% set current and measure
Icont.set(0)
measure(Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3,HallMinus,HallPlus)
updatePlot(Imeas,V1,V2,Vq3)

% hallSignal = (HallPlus.Data(end)-HallMinus.Data(end))/2;
% angle = 180-real(asind(hallSignal/maxSignal))


while true
    
    if V1.Data(end) < 20
        I = I + 7;
    end

    if Vq3.Data(end) > 200
        break
    end

    I  = I + 3;
    Icont.set(I)
    measure(Imeas,V1,V2,Vq1,Vq2,Vq3,T1,T2,T3,HallMinus,HallPlus)
    updatePlot(Imeas,V1,V2,Vq3) 
    
end

Icont.set(0)

close all
offsetData(V1,V2,Vq1,Vq2,Vq3)
plot(Imeas.Data(1:height(V1.Data)),[V1.Data V2.Data])
yline(100)

%%
measure(HallMinus,HallPlus)
hallSignal = (HallPlus.Data-HallMinus.Data)/2;
angle = 180-real(asind(hallSignal/maxSignal));
plot(hallSignal)
%%
Vars = ["Pressure",1.0106,"Liquid","He2","Tc",94,"Field", 0, "angle",0];
Shang14.addSet({Hall},"Hall calibration 0,1T",Vars,"SaveCSV",1);

Shang14.saveDB() 
