clear
clc

warning('off','all');

samplePeriod = 150/1000000; %in sec
bitsOfRes = 16;
totNumQSteps = 2.^bitsOfRes - 1;
Vcc = 3.3; %in V

fileName = 'DATALOG.TXT';
fileID = fopen(fileName,'r');
formatSpec = '%u';

A = fscanf(fileID,formatSpec);
A = A.*(Vcc./totNumQSteps);

k = 1;
for i = 1:5:(length(A) - 4)
    sensor_1(k) = A(i);
    sensor_2(k) = A(i+1);
    sensor_3(k) = A(i+2);
    sensor_4(k) = A(i+3);
    sensor_5(k) = A(i+4);
    
    k = k + 1;
end

x = 1:length(sensor_1);
x = x.*samplePeriod;

plot(x,sensor_1);
title('Pressure vs Time');
xlabel('Time (sec)');
ylabel('Pressure Sensor Output (V)');
grid on

hold on

plot(x,sensor_2);

hold on

plot(x,sensor_3);

hold on

plot(x,sensor_4);

hold on

plot(x,sensor_5);

legend('Sensor 1', 'Sensor 2', 'Sensor 3', 'Sensor 4', 'Sensor 5');



% 2nd order LPF cutoff at 4Hz, 100Hz sample rate
fc = 1;
fs = 6666.66666667;

[b, a] = butter(2, fc/(fs/2));
filteredPressureData = filter(b, a, sensor_2);

Fs = 6666.66666667; %6.7KHz
L = length(filteredPressureData);
Y = fft(filteredPressureData);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

figure
subplot(2,1,1);
plot(x, filteredPressureData)
title('Filtered Pressure Data')
xlabel('time (s)')
ylabel('V')
grid on

subplot(2,1,2);
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of Filtered Pressure Data')
xlabel('f (Hz)')
ylabel('|P1(f)|')
grid on



