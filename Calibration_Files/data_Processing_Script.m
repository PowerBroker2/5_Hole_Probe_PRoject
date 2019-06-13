clear
clc



servoAngleArray = [-25 -23 -20 -18 -15 -13 -10 -8 -5 -2 0 2 5 8 10 13 15 18 20 23 25];



fileName = 'servo_calibration_AOA.txt';
fileID = fopen(fileName,'r');
formatSpec = '%f';
AOA_raw = fscanf(fileID,formatSpec)';

fileName = 'servo_calibration_SSA.txt';
fileID = fopen(fileName,'r');
formatSpec = '%f';
SSA_raw = fscanf(fileID,formatSpec)';



AOA_servoAngles = findAngles(AOA_raw,3);
SSA_servoAngles = findAngles(SSA_raw,3);

AOA_groundAngles = findAngles(AOA_raw,2);
SSA_groundAngles = findAngles(SSA_raw,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AOA_servoAngles = bugFix(AOA_servoAngles); %	<<-- remove for future calibration tests
SSA_servoAngles = bugFix(SSA_servoAngles); %	<<-- remove for future calibration tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AOA_gimbalAngles = findAngles(AOA_raw,1);
SSA_gimbalAngles = findAngles(SSA_raw,1);

AOA_trueGimbalAngles = AOA_gimbalAngles - AOA_groundAngles;
SSA_trueGimbalAngles = SSA_gimbalAngles - SSA_groundAngles;



%AOA analysis
for i=1:1:length(servoAngleArray)
    indicies = find(AOA_servoAngles==servoAngleArray(i));
    trueAngles = AOA_trueGimbalAngles(indicies);
    
    %{
    figure
    
    plot(1:1:length(trueAngles),trueAngles);
    title(sprintf('AOA %i%c',servoAngleArray(i),char(176)));
    xlabel('Time (s) (Discontinuous)');
    ylabel(sprintf('AOA Angle (%c)', char(176)));
    
    hold on
    %}
    
    AOA_average(i) = mean(trueAngles);
    
    %{
    x = [1 length(trueAngles)];
    y = [AOA_average(i) AOA_average(i)];
    line(x,y,'Color','green');
    
    hold on
    
    x = [1 length(trueAngles)];
    y = [servoAngleArray(i) servoAngleArray(i)];
    line(x,y,'Color','red','LineStyle','--');
    
    legend('Measured',sprintf('Average: %f',AOA_average(i)),sprintf('Desired: %i',servoAngleArray(i)));
    grid on
    %}
    
    AOA_std_dev(i) = std(trueAngles);
    AOA_error(i) = servoAngleArray(i) - AOA_average(i);
end

%SSA analysis
for i=1:1:length(servoAngleArray)
    indicies = find(SSA_servoAngles==servoAngleArray(i));
    trueAngles = SSA_trueGimbalAngles(indicies);
    
    
    %{
    figure
    
    plot(1:1:length(trueAngles),trueAngles);
    title(sprintf('SSA %i%c',servoAngleArray(i),char(176)));
    xlabel('Time (s) (Discontinuous)');
    ylabel(sprintf('SSA Angle (%c)', char(176)));
    
    hold on
    %}
    
    SSA_average(i) = mean(trueAngles);
    
    %{
    x = [1 length(trueAngles)];
    y = [SSA_average(i) SSA_average(i)];
    line(x,y,'Color','green');
    
    hold on
    
    x = [1 length(trueAngles)];
    y = [servoAngleArray(i) servoAngleArray(i)];
    line(x,y,'Color','red','LineStyle','--');
    
    legend('Measured',sprintf('Average: %f',SSA_average(i)),sprintf('Desired: %i',servoAngleArray(i)));
    grid on
    %}
    
    SSA_std_dev(i) = std(trueAngles);
    SSA_error(i) = servoAngleArray(i) - SSA_average(i);
end


%{
figure
plot((1:1:length(AOA_gimbalAngles)).*0.02,AOA_trueGimbalAngles);

hold on

plot((1:1:length(AOA_servoAngles)).*0.02,AOA_servoAngles);
title('AOA Angle vs Time');
xlabel('Time (s)');
ylabel(sprintf('AOA Angle (%c)', char(176)));
legend('Measured','Desired');
grid on



figure
plot((1:1:length(SSA_gimbalAngles)).*0.02,SSA_trueGimbalAngles);

hold on

plot((1:1:length(SSA_servoAngles)).*0.02,SSA_servoAngles);
title('SSA Angle vs Time');
xlabel('Time (s)');
ylabel(sprintf('SSA Angle (%c)', char(176)));
legend('Measured','Desired');
grid on



figure
plot(servoAngleArray,AOA_std_dev,'*');
title('AOA Standard Deviation vs Desired Angle');
xlabel(sprintf('AOA Angle (%c)', char(176)));
ylabel('Standard Deviation');
grid on

figure
plot(servoAngleArray,SSA_std_dev,'*');
title('SSA Standard Deviation vs Desired Angle');
xlabel(sprintf('SSA Angle (%c)', char(176)));
ylabel('Standard Deviation');
grid on



figure
plot(servoAngleArray,AOA_error,'*');
title('AOA Error vs Desired Angle');
xlabel(sprintf('AOA Angle (%c)', char(176)));
ylabel('AOA Error');
grid on

figure
plot(servoAngleArray,SSA_error,'*');
title('SSA Error vs Desired Angle');
xlabel(sprintf('SSA Angle (%c)', char(176)));
ylabel('SSA Error');
grid on
%}

currentAngle = AOA_servoAngles(1);
angleArray = AOA_trueGimbalAngles(1);
indexCounter = 2;
analysisCounter = 1;
for i=2:1:length(AOA_servoAngles)
    if currentAngle == AOA_servoAngles(i)
        angleArray(indexCounter) = AOA_trueGimbalAngles(i);
        indexCounter = indexCounter + 1;
    else
        angleAnalysisArray(analysisCounter) = AOA_servoAngles(i-1);
        errorArray(analysisCounter) = angleAnalysisArray(analysisCounter) - mean(angleArray);
        stdDevArray(analysisCounter) = std(angleArray);
        
        currentAngle = AOA_servoAngles(i);
        angleArray = AOA_trueGimbalAngles(i);
        indexCounter = 2;
        analysisCounter = analysisCounter + 1;
    end
end



figure
plot(angleAnalysisArray,errorArray,'*');
title('AOA Error vs Desired Angle');
xlabel(sprintf('AOA Angle (%c)', char(176)));
ylabel(sprintf('AOA Error', char(176)));
grid on

figure
plot(angleAnalysisArray,stdDevArray,'*');
title('AOA Standard Deviation vs Desired Angle');
xlabel(sprintf('AOA Angle (%c)', char(176)));
ylabel('Standard Deviation');
grid on



currentAngle = SSA_servoAngles(1);
angleArray = SSA_trueGimbalAngles(1);
indexCounter = 1;
analysisCounter = 1;
for i=2:1:length(SSA_servoAngles)
    if currentAngle == SSA_servoAngles(i)
        angleArray(indexCounter) = SSA_trueGimbalAngles(i);
        indexCounter = indexCounter + 1;
    else
        angleAnalysisArray(analysisCounter) = SSA_servoAngles(i-1);
        errorArray(analysisCounter) = angleAnalysisArray(analysisCounter) - mean(angleArray);
        stdDevArray(analysisCounter) = std(angleArray);
        
        currentAngle = SSA_servoAngles(i);
        angleArray = SSA_trueGimbalAngles(i);
        indexCounter = 2;
        analysisCounter = analysisCounter + 1;
    end
end



figure
plot(angleAnalysisArray,errorArray,'*');
title('SSA Error vs Desired Angle');
xlabel(sprintf('SSA Angle (%c)', char(176)));
ylabel('SSA Error');
grid on

figure
plot(angleAnalysisArray,stdDevArray,'*');
title('SSA Standard Deviation vs Desired Angle');
xlabel(sprintf('SSA Angle (%c)', char(176)));
ylabel('Standard Deviation');
grid on


%{
figure
plot(servoAngleArray,AOA_average,'*');
title('AOA Average Measured Angle vs Desired Angle');
xlabel(sprintf('AOA Desired Angle (%c)', char(176)));
ylabel(sprintf('AOA Measured Angle (%c)', char(176)));
grid on

figure
plot(servoAngleArray,SSA_average,'*');
title('SSA Average Measured Angle vs Desired Angle');
xlabel(sprintf('SSA Desired Angle (%c)', char(176)));
ylabel(sprintf('SSA Measured Angle (%c)', char(176)));
grid on
%}



function servoAngles = findAngles(raw,num)
    k=1;
    for i=num:3:length(raw)
        servoAngles(k) = raw(i);
        k = k + 1;
    end
end



%bug fix (due to a bug in "servo_Calibration_5HP.m"). The bug wasn't found
%until after the first calibration experiment was done. It has since been
%squashed and this fix will not be needed if future calibration runs are
%executed.
function servoAngles = bugFix(servoAngles)
    for i=6601:1:12900
        servoAngles(i) = -servoAngles(i);
    end
end





