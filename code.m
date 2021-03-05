% Ahmad Osman
% 101070948

R1 = 1;
cap = 0.25;
R2 = 2;
L = 0.2;
R3 = 10;
alpha = 100;
R4 = 0.1;
R0 = 1000;

%{ 
Unknowns that are to be solved for:
V1
V2
V3
V4
V0
IL
%}

G = [1 0 0 0 0 0;
    1/R1 ((-1/R1)-(1/R2)) 0 0 0 -1;
    0 0 -1/R3 0 0 1;
    0 0 -alpha/R3 1 0 0;
    0 0 (-alpha*R0)/R3 0 (1+R0) 0;
    0 -1 1 0 0 0];

C = [0 0 0 0 0 0;
    cap -cap 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 L];

%a) DC Case
counter = 1;
vout = zeros(21,1);
for loop = -10:10
    F = [loop 0 0 0 0 0];
    V = G\F';
    vout(counter) = V(5);
    counter = counter + 1;
end

vin = linspace(-10,10,21);

f1 = figure(1);
plot(vin,vout,'-*b')
xlabel('Vin (V)')
ylabel('Vout (V)')
title('DC Case, AO-101070948')
xlim([-10,10])
ylim([min(vout),max(vout)])
movegui(f1,'northwest')

%b) AC Case
w = linspace(0,1000,1001);
voutAC = zeros(1001,1);
F = [1 0 0 0 0 0];
for loop = 1:1001
acMatrix = G + (1i*w(loop)*C);
V = acMatrix\F';
voutAC(loop) = V(5); 
end

magV = abs(voutAC);

f2 = figure(2);
plot(w,magV,'b')
xlabel('Frequency (Hz)')
ylabel('Vout (V)')
title('AC Case, AO-101070948')
movegui(f2,'northeast')

gain = 20*log10(magV);

f3 = figure(3);
plot(w,gain,'b')
xlabel('Frequency (Hz)')
ylabel('Gain (dB)')
title('AC Gain, AO-101070948')
movegui(f3,'southwest')

%c) Pertubations of C
miu = cap;
std = 0.05;
w = pi;
cVector = linspace(0.01,0.5,50);
cProb = (1/(std*sqrt(2*pi)))*exp(-0.5*(((cVector-miu)./std).^2));
cProb = cProb*10;

start = 1;
probVector = zeros(round(sum(cProb)),1);
for loop = 1:length(cProb)
    prob = round(cProb(loop));
    if(prob==1)
        probVector(start) = cVector(loop);
        start = start + 1;
    elseif(prob>1)
        stop = start + prob - 1;
        probVector(start:stop) = cVector(loop);
        start = stop + 1;
    end
end    

probVector = probVector(randperm(length(probVector)));
clear gain V voutAC magV
gain = zeros(1000,1);

for time = 1:1000
    index = randperm(length(probVector),1);
    newCap = probVector(index);
    
    C = [0 0 0 0 0 0;
    newCap -newCap 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 L];
    
    acMatrix = G + (1i*w*C);
    V = acMatrix\F';
    voutAC = V(5); 
    magV = abs(voutAC);
    gain(time) = 20*log10(magV);
    
    f4 = figure(4);
    histogram(gain(1:time),50,'FaceColor','b')
    xlabel('Gain (dB)')
    ylabel('Counts')
    title('Histogram for Gain including the Pertubations of C, AO-101070948')
    movegui(f4,'southeast')
    
    pause(0.01)
end