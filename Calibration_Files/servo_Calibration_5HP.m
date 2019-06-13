clear
clc



testType = 'AOA';
windspeed = '15mps';
time = 'before';
%time = 'after';



dataName = sprintf('%s_wind_tunnel_servo_calibration_%s_%s.txt',time,testType,windspeed);
fileID = fopen(dataName,'w');



gimbal_COM = 'COM19';
gimbal_IMU_port = serial(gimbal_COM);
set(gimbal_IMU_port,'BaudRate',115200);
initialize_IMU(gimbal_IMU_port,gimbal_COM);

ground_COM = 'COM16';
ground_IMU_port = serial(ground_COM);
set(ground_IMU_port,'BaudRate',115200);
initialize_IMU(ground_IMU_port,ground_COM);

teensy_COM = 'COM3';
teensy_port = serial(teensy_COM);
set(teensy_port,'BaudRate',115200);
initialize_teensy(teensy_port,teensy_COM);

servoAngleArray = [-25 -23 -20 -18 -15 -13 -10 -8 -5 -2 0 2 5 8 10 13 15 18 20 23 25];
reversedServoAngleArray = fliplr(servoAngleArray);
maxDataPoints = 100;
delay = 3;



%start at 0 degrees
commandServos(teensy_port,0)
%wait for servos and IMUs to settle
pause(delay);

%measure data
for x=1:1:maxDataPoints
    gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
    ground_IMU_roll = read_IMU(ground_IMU_port);
    fprintf('Gimbal Roll: %f  Ground Offset: %f\n',gimbal_IMU_roll,ground_IMU_roll);
    fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,0);
end



%sweep from low to high
for k=1:1:length(servoAngleArray)
    %go to next angle
    commandServos(teensy_port,servoAngleArray(k))
    %wait for servos and IMUs to settle
    pause(delay);

    %measure data
    for x=1:1:maxDataPoints
        gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
        ground_IMU_roll = read_IMU(ground_IMU_port);
        fprintf('Gimbal Roll: %f  Ground Offset: %f  Angle: %d\n',gimbal_IMU_roll,ground_IMU_roll,servoAngleArray(k));
        fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,servoAngleArray(k));
    end
end



%sweep from high to low
for k=1:1:length(reversedServoAngleArray)
    %go to next angle
    commandServos(teensy_port,reversedServoAngleArray(k))
    %wait for servos and IMUs to settle
    pause(delay);

    %measure data
    for x=1:1:maxDataPoints
        gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
        ground_IMU_roll = read_IMU(ground_IMU_port);
        fprintf('Gimbal Roll: %f  Ground Offset: %f  Angle: %d\n',gimbal_IMU_roll,ground_IMU_roll,reversedServoAngleArray(k));
        fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,reversedServoAngleArray(k));
    end
end



%start at 0 degrees
commandServos(teensy_port,0)
%wait for servos and IMUs to settle
pause(delay);

%measure data
for x=1:1:maxDataPoints
    gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
    ground_IMU_roll = read_IMU(ground_IMU_port);
    fprintf('Gimbal Roll: %f  Ground Offset: %f\n',gimbal_IMU_roll,ground_IMU_roll);
    fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,0);
end



%sweep from low to high
for k=1:1:length(servoAngleArray)
    %go to next angle
    commandServos(teensy_port,servoAngleArray(k))
    %wait for servos and IMUs to settle
    pause(delay);

    %measure data
    for x=1:1:maxDataPoints
        gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
        ground_IMU_roll = read_IMU(ground_IMU_port);
        fprintf('Gimbal Roll: %f  Ground Offset: %f  Angle: %d\n',gimbal_IMU_roll,ground_IMU_roll,servoAngleArray(k));
        fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,servoAngleArray(k));
    end
end



%go to random positions (return to 0 after each time)
%{
for k=1:1:length(servoAngleArray)*2 %do twice as many iterations as a normal loop
    %find next random angle
    angleIndex = randi([1,length(servoAngleArray)],1,1);
    angle = servoAngleArray(angleIndex);
    
    %go to next angle
    commandServos(teensy_port,angle);
    %wait for servos and IMUs to settle
    pause(delay);
    
    %measure data
    for x=1:1:maxDataPoints
        gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
        ground_IMU_roll = read_IMU(ground_IMU_port);
        fprintf('Gimbal Roll: %f  Ground Offset: %f  Angle: %d\n',gimbal_IMU_roll,ground_IMU_roll,angle);
        fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,angle);
    end
    
    %return to 0
    commandServos(teensy_port,0);
    %wait for servos and IMUs to settle
    pause(delay);
    
    %measure data
    for x=1:1:maxDataPoints
        gimbal_IMU_roll = read_IMU(gimbal_IMU_port);
        ground_IMU_roll = read_IMU(ground_IMU_port);
        fprintf('Gimbal Roll: %f  Ground Offset: %f  Angle: %d\n',gimbal_IMU_roll,ground_IMU_roll,0);
        fprintf(fileID,'%f\n%f\n%d\n',gimbal_IMU_roll,ground_IMU_roll,0);
    end
end
%}



fclose(fileID);

fclose(gimbal_IMU_port);
delete(gimbal_IMU_port);
clear gimbal_IMU_port;

fclose(ground_IMU_port);
delete(ground_IMU_port);
clear ground_IMU_port;

fclose(teensy_port);
delete(teensy_port);
clear teensy_port;







function initialize_IMU(obj_,IMU_COM)

    test = 0;

    while test==0
        ports = seriallist;
        if length(ports)~=0
            for i=1:length(ports)
                if ports(i)==IMU_COM
                    test = 1;
                end
            end
        end
    end

    fopen(obj_);

    fwrite(obj_,hex2dec('D4'))
    fwrite(obj_,hex2dec('A3'))
    fwrite(obj_,hex2dec('47'))
    fwrite(obj_,hex2dec('1'))

    out = fread(obj_,4)
end



function initialize_teensy(obj_,IMU_COM)

    test = 0;

    while test==0
        ports = seriallist;
        if length(ports)~=0
            for i=1:length(ports)
                if ports(i)==IMU_COM
                    test = 1;
                end
            end
        end
    end

    fopen(obj_);
end



function commandServos(obj_,angle)
    newAngle = angle+90
    fwrite(obj_,newAngle);
end



function roll = read_IMU(obj_)
    fwrite(obj_,hex2dec('CE')); %request single shot of Euler Angles

    pause(0.01);

    out2 = fread(obj_,19);

    roll = out2(2:5); %roll
    roll = uint8(roll');
    roll = typecast(fliplr(roll),'single');
    roll = rad2deg(roll);
end


