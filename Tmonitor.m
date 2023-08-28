

ClearData(T2,T3)



tic
time = [];

while true
    time(end+1) = toc;
    Measure(T2,T3)
    plot(time,[T2.Data, T3.Data])
end
