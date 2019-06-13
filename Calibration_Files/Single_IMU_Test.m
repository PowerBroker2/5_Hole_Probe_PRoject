clear
clc



ground_COM = 'COM16';
ground_IMU_port = serial(ground_COM);
set(ground_IMU_port,'BaudRate',115200);
initialize_IMU(ground_IMU_port,ground_COM);


%measure data
while 1
    ground_IMU_roll = read_IMU(ground_IMU_port);
    fprintf('Ground Offset: %f\n',ground_IMU_roll);
end



%{
fclose(ground_IMU_port);
delete(ground_IMU_port);
clear ground_IMU_port;
%}



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



function roll = read_IMU(obj_)
    fwrite(obj_,hex2dec('CE')); %request single shot of Euler Angles

    pause(0.01);

    out2 = fread(obj_,19);

    roll = out2(2:5); %roll
    roll = uint8(roll');
    roll = typecast(fliplr(roll),'single');
    roll = rad2deg(roll);
end


