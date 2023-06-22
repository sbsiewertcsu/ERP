% EE 440 Modern Nav
% Test code for the YOST IMU
% Plot Gyro, accel, compass data, and IMU temperature
%
% Author: S. Bruder
% Date: July 2021
% NOTES: 
%   Sensor configured with:
%       X-forward, Y-right, Z-down (a right-hand coord frame)
%       -4g         < accel     < +4g
%      -2,000 °/s   < gyro      < +2,000 °/s
%      -1.3 Gauss   < compass   < +1.3 Gauss
%
%   Uncomment the last line to save data to a time-stamped mat file

clear all;                      % Clear all variables from the workspace
close all;                      % Close all windows
clc;                            % "Clean" the command window
addpath(genpath(pwd));          % Add all subfolders the the path (current session)

% Save_file_name = 'PreTest_Range';
nSec = 5;                      % Duration of data collection (sec)
Fs = 50;                        % Set Sample frequency < 100 (Hz)
dT = 1/Fs;                      % Sample interval (sec)
N = Fs*nSec+1;                  % Number of samples to collect (dimless)

t       = zeros(N, 1);          % Initialize the time array (in sec)
compass = zeros(N, 3);          % Initialize the compass data array (in Gauss)
gyro    = zeros(N, 3);          % Initialize the gyro data array (rad/s)
accel   = zeros(N, 3);          % Initialize the accel data array (in g)
tempC   = zeros(N, 1);          % Initialize the temperature data array (°C)

fprintf('Collecting YOST IMU data for %2i sec at %d Hz\n\n', nSec, Fs);

% Collect YOST IMU measurements
[s, SN] = initialize_YOST_IMU(Fs);   % Initialize the YOST IMU and begin data transmission
for k = 1:N                     % Retrieve data from YOST IMU
    [t(k), compass(k,:), accel(k,:), gyro(k,:), tempC(k)] = read_YOST_IMU(s); % Get YOST IMU data
    
    if ~mod(N-k+1,Fs)
        fprintf('Please wait %i more seconds!!!\n', round((N-k+1) / Fs));
    end
end
stop_YOST_IMU(s)                % Terminates the YOST IMU data transmission
t = t - t(1);                   % Set starting time to 0 sec

%% Plot the YOST IMU data
% Plot the accel data (in m/s^2)
figure('Position', [50, 50, 1000, 900])
subplot(2,2,1)
plot(t, accel(:,1), 'r', t, accel(:,2), 'g', t, accel(:,3), 'b');
title('Plot of YOST Accel Data', 'FontSize', 12);
xlabel('Time (sec)');
ylabel('Accel (m/s^2)')
legend('a_x', 'a_y', 'a_z')
grid

% Plot the Gyro data (in deg/s)
subplot(2,2,2)
plot(t, gyro(:,1)*180/pi, 'r', t, gyro(:,2)*180/pi, 'g', t, gyro(:,3)*180/pi, 'b');
title('Plot of YOST Gyro Data', 'FontSize', 12);
xlabel('Time (sec)');
ylabel('Angular Rate (°/s)')
legend('\omega_x', '\omega_y', '\omega_z')
grid

% Plot the compass/magnetometer data (in Gauss)
subplot(2,2,3)
plot(t, compass(:,1), 'r', t, compass(:,2), 'g', t, compass(:,3), 'b');
title('Plot of YOST Compass Data', 'FontSize', 12);
xlabel('Time (sec)');
ylabel('Magnetic Field (Gauss)')
legend('m_x', 'm_y', 'm_z')
grid

% Plot the Temperature data (in deg C)
subplot(2,2,4)
plot(t, tempC, 'k');
title('Plot of YOST Temperature Data', 'FontSize', 12);
xlabel('Time (sec)');
ylabel('Temperature (°C)')
grid

%% Save the data to a time-stamped *.mat file
% Date_Time = clock;              % Obtain a date/time stamp to name files
% Save_file_name = sprintf('YOST_data_%d_%02.0f_%02.0f_%02.0f_%02.0f_%02.0f',...
%             Date_Time(1), Date_Time(2),Date_Time(3),Date_Time(4),Date_Time(5),round(Date_Time(6)));
UNITS.compass = 'Gauss';
UNITS.accel = 'm/s^2';
UNITS.gyro = 'rad/s';
UNITS.tempC = '°C';
UNITS.Fs = 'Hz';
% Uncomment line to save data to a mat file
% save(Save_file_name, 'compass', 'accel', 'gyro', 'tempC', 'UNITS', 'Fs', 'SN');