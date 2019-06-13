clear
clc

warning('off','all');

samplePeriod = 50/1000000; %in sec
bitsOfRes = 16;
totNumQSteps = 2.^bitsOfRes - 1;
Vcc = 3.3; %in V

fileName = 'DATALOG.TXT';
fileID = fopen(fileName,'r');
formatSpec = '%u';

A = fscanf(fileID,formatSpec);
A = A.*(Vcc./totNumQSteps);

B = A >= 0.1;
V = A(B);
x = 1:length(V);
x = x.*samplePeriod;

plot(x,V);
title('Pressure vs Time');
ylabel('Time (sec)');
ylabel('Pressure Sensor Output (V)');
grid on