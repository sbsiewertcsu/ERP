function [] = stop_YOST_IMU(s)
% Function Description:
%   Terminates the YOST IMU data transmission
%
% INPUTS:
%   s = Serial port object
%   
% OUTPUTS:
%   None
%
% NOTES:

% Stop command 86(0x56). End the streaming session
    writeline(s,">0,86\n");
    clear s;        % Close (i.e. remove the serial port object)
end     % end function

