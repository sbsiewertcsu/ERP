function [s, SN] = initialize_YOST_IMU( Fs )
% Function Description:
%   Initializes the YOST IMU and configures the serial port to run from
%   the internal clock at a freq of Fs Hz.
%
% INPUTS:
%   Fs = Sample rate (Hz)  Must be < 100 Hz
%
% OUTPUTS:
%   s = Serial port object
%   SN = Device serial number
%
% NOTES:
%   The default BaudRate of the YOST IMU is 115200.
%   This limits the sample rate to about 100 Hz

    dT = 1/Fs;                      % Sample interval (sec)
    delete(instrfindall);           % Close all open Ports

    % Determine available COM Ports. Assume that the YOST is the last in list
    comPort = serialportlist("available");

    % 8N1 (8 data bits, no parity, 1 stop bit) - This is the default!!
    BaudRate = 115200;              % Baud rate > 90 * 16 * Fs
    s = serialport(comPort(end), BaudRate);  % end of packet = "\n" = "LF" (default)

    % Determine the IMU's serial number
    writeline(s,">0,237\n");        % Request serial number
    SN = readline(s);
    
    % Set sensor axis directions
    writeline(s,'>0,116,11\n'); % X-forward, Y-right, Z-down (right-hand frame)
    
    % Set accelerometer range
    writeline(s,'>0,121,0\n');      % Range of ±2g
%     writeline(s,'>0,121,1\n');      % Range of ±4g
    %writeline(s,'>0,121,2\n');      % Range of ±8g
%     writeline(s,">0,148\n");        % Confirm accel range
%     readline(s)
    
    % Set gyro range
    %writeline(s,'>0,125,0\n');      % Range of ±250 °/s
    %writeline(s,'>0,125,1\n');      % Range of ±500 °/s
    writeline(s,'>0,125,2\n');      % Range of ±2000 °/s
%     writeline(s,">0,154\n");        % Confirm gyro range
%     readline(s)
    
    % Set compass range
    %writeline(s,'>0,126,0\n');      % Range of ±0.88 Gauss
    writeline(s,'>0,126,1\n');      % Range of ±1.30 Gauss
    %writeline(s,'>0,126,2\n');      % Range of ±1.90 Gauss
    %writeline(s,'>0,126,3\n');      % Range of ±2.50 Gauss
%     writeline(s,">0,155\n");        % Confirm compass range
%     readline(s)
    
    % Add a timestamp to the data stream
    writeline(s,'>0,221,2\n');      % Wired response header configuration.
    % writeline(s,">0,222\n");      % Confirm header
    % readline(s);

    % Configure streaming
    %   37(0x25) Get all corrected component sensor data
    %   43(0x2B) Get temperature in °C
    %   Eight slots.  These slots can be set using command 80(0x50)
    %   Unused slots should be filled with 0xff (=255)
    writeline(s,">0,80,37,43,255,255,255,255,255,255\n"); % Gyro (rad/s), Accel (g), Mag (Gauss), Temp(°C)
    % writeline(s,">0,81\n")        % Confirm slots
    % readline(s)

    % Set up the streaming interval, duration, and start delay: 82(0x52)
    %   Interval: (in micro sec) e.g., 20,000 (= 50 Hz)
    %   Duration: (in micro sec) e.g., 5,000,000 = 5 sec. 0xFFFFFFFF (=-1) runs indefinitely
    %   Start Delay = 0 : (in micro sec)
    Interval = num2str(dT*1e6);                 % Compute the period = Interval in usec
    writeline(s,['>0,82,',Interval,',-1,0\n']); % Configure streaming
    % writeline(s,">0,83\n")                    % Confirm timing
    % readline(s)

    % Begin the streaming session
    %    Start command 85(0x55) and include timestamp
    writeline(s,";85\n");               % Note used ";" to include timestamp header
    readline(s);                        % Remove the first response - Does not contain IMU data!!

    writeline(s,">0,95,0\n");           % Initialize the timestamp (in usec)
    
    % Can write all of these settings to non-volatile memory
    %writeline(s,">0,225,0\n");
    
    % Restore factory settings
    %writeline(s,">0,224,0\n");
end