clear
clc



testNum = 3; %experiment number (CHAGNE)



dataName = sprintf('probe_calibration_%d.txt',testNum);
fileID = fopen(dataName,'w');



teensy_COM = 'COM3'; %Teensy COM port (CHANGE)
teensy_port = serial(teensy_COM);
set(teensy_port,'BaudRate',115200);
initialize_teensy(teensy_port,teensy_COM);


while 1
    data = fscanf(teensy_port);
    
    fprintf(fileID, data);
    fprintf(fileID, '\n');
    
    fprintf(data);
    fprintf('\n');
end



fclose(fileID);

fclose(teensy_port);
delete(teensy_port);
clear teensy_port;




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


