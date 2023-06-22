function [t, compass, accel, gyro, tempC] = read_YOST_IMU(s)
% Function Description:
%   Reads one frame of the YOST IMU data from the serial port
%
% INPUTS:
%   s = Serial port object
%   
% OUTPUTS:
%   t       Time (sec)
%   Compass Magnetic Field (Gauss)
%   Accel   Accelerometer triad (m/s^2)
%   Gyro    Gyroscope triad (rad/s)
%   TempC   Temperature (°C)
%
% NOTES:
%   This fn monitors the Number of Bytes available in the serial Port's
%   buffer.  If > 400 you are trying to sample too fast and need to lower Fs.

    if s.NumBytesAvailable > 400
        error(' Your sample rate is too high - Please lower Fs !!');
    end
    g = 9.8;                        % Approx accel due to gravity (m/s^2)
    resp = readline(s);             % Gyro (rad/s), Accel (g), Mag (Gauss), Temp(°C)

% Example of the IMU data string:
% 9180        ,0.00319,-0.00319,0.00106,-0.50366,0.86981,0.07123,0.18545,-0.45828,-0.13211
% Time in usec, Gyro       data        ,  Accel data            , Magnetomrter data  

    IMU_data = sscanf(resp, '%d, %f,%f,%f, %f,%f,%f, %f,%f,%f ');
    t        = IMU_data(1)*1e-6;    % Gyro data (in sec)
    gyro     = IMU_data(2:4);       % Gyro data (in rad/s)
    accel    = IMU_data(5:7)*g;     % Accel data array (in g)
    compass  = IMU_data(8:10);      % Compass data (in Gauss)

    resp     = readline(s);         % Read the temperature (in °C)
    tempC    = sscanf(resp, '%f');

end     % End of function read_YOST_IMU