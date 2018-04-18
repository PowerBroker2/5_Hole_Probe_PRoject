clear
clc

warning('off','all');

bitsOfRes = 16;
totNumQSteps = 2.^bitsOfRes - 1;
Vcc = 3.3; %in V

fileName = 'DATALOG.TXT';
fileID = fopen(fileName,'r');
formatSpec = '%u';

A = fscanf(fileID,formatSpec);

k = 1;
for i = 1:6:(length(A) - 5)
    sensor_1(k) = A(i);
    sensor_2(k) = A(i+1);
    sensor_3(k) = A(i+2);
    sensor_4(k) = A(i+3);
    sensor_5(k) = A(i+4);
    timeStamp(k) = A(i+5);
    
    k = k + 1;
end

sensor_1 = sensor_1.*(Vcc./totNumQSteps);
sensor_2 = sensor_2.*(Vcc./totNumQSteps);
sensor_3 = sensor_3.*(Vcc./totNumQSteps);
sensor_4 = sensor_4.*(Vcc./totNumQSteps);
sensor_5 = sensor_5.*(Vcc./totNumQSteps);
timeStamp = timeStamp / 1000000;

for i = 1:1:(length(timeStamp) - 1)
    samplePeriod(i) = timeStamp(i+1) - timeStamp(i);
end

sampleFrequency = 1./samplePeriod;

maxSamplePeriod = max(samplePeriod);
meanSamplePeriod = mean(samplePeriod);
minSamplePeriod = min(samplePeriod);

maxSampleFrequency = max(sampleFrequency);
meanSampleFrequency = mean(sampleFrequency);
minSampleFrequency = min(sampleFrequency);

display(sprintf('maxSamplePeriod %fs\nmeanSamplePeriod %fs\nminSamplePeriod %fs\n\nminSampleFrequency %fHz\nmeanSampleFrequency %fHz\nmaxSampleFrequency %fHz', maxSamplePeriod, meanSamplePeriod, minSamplePeriod, minSampleFrequency, meanSampleFrequency, maxSampleFrequency));

subplot(2,1,1);
plot(timeStamp,sensor_1);
title('Pressure vs Time');
xlabel('Time (sec)');
ylabel('Pressure Sensor Output (V)');
grid on

hold on

plot(timeStamp,sensor_2);

hold on

plot(timeStamp,sensor_3);

hold on

plot(timeStamp,sensor_4);

hold on

plot(timeStamp,sensor_5);

legend('Sensor 1', 'Sensor 2', 'Sensor 3', 'Sensor 4', 'Sensor 5');

subplot(2,1,2);

plot(1:1:length(sampleFrequency), sampleFrequency)
hold on
plot(1:1:length(sampleFrequency),ones(length(sampleFrequency),1).*mean(sampleFrequency))
title('Sample Frequency vs Time');
xlabel('Time (sec)');
ylabel('Frequency (Hz)');
grid on

legend('Transient Frequency', 'Mean Frequency');


