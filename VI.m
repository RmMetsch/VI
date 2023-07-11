%% VI script for shortsample measurments

%% connect all devices
clear 

V1 = VoltageProbe(6,"V1",0.04);
V2 = VoltageProbe(5,"V2",0.08,1,3,"uV/m" ,"X","NDCV");
VQuench = VoltageProbe(14,"VQuench");
Icont = CurrentControl(2,"Icont",10/600);
Imeas = CurrentProbe(16,"I",50);

Vars = ["Pressure",1.010,"Liquid","N2","Tc",89];

%% Measurement loop
% clear data and measure
I = 0;

ClearData(V1,V2,VQuench,Icont,Imeas)

Icont.set(I)
pause(1)
measure(Imeas,V1,V2,VQuench)
get(Imeas,V1,V2,VQuench)


while I < 50
    
    Icont.set(I)
    measure(Imeas,V1,V2,VQuench)
    get(Imeas,V1,V2,VQuench)

    I = I + 5;
    
end

while true
    
    Icont.set(I)
    measure(Imeas,V1,V2,VQuench)
    get(Imeas,V1,V2,VQuench)
    
    if I > 90
        Icont.set(0)
        break
    end

%     if abs(V1.Data(end)-V1.Data(1)) < 20
%         I = I + 9;
%     end
    I = I + 1;
    
end




hold on
scatter(Imeas.Data,V2.Data)
yline(100)
hold off

%%

% to make new database ({Probes}, "nameSet", Vars, "NameDB") 
% Shang12 = DataBase({Imeas,V1,V2},"10 mm",Vars,"Shang12");


OffsetData(V1,V2,Imeas)

Shang11.AddSet({Imeas,V1,V2,VQuench,Icont},"2 mm LN2",Vars,"filter",1:3);
Shang11.save()

%%

Shang12.Plot(1,"Title","10mm","x","I","y","V1")
