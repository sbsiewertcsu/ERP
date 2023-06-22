% clear; clc;

%Connect to Raspberry Pi
rpi = raspi('172.19.175.69','pi','ICARUS2021');
inputfile = 'record_input.txt';     % Name of DAq input file
script = 'record.py';      % Name of DAq script
datafile = 'accel_data_02.csv';          % Name of output file
folder = '/home/pi/Documents/Accelerometers/';

% Inputs for Accel data acquisition code
%--------------------------------------------------------------------------
outfilename = append(folder,datafile);   % Output file name
mtime = 20;                      % Measurement time (seconds)
rate = 250;                    % Data rate (Hz)
% Only the following values are possible:
%  4000, 2000, 1000, 500, 250, 125, 62.5, 31.25, 15.625, 7.813, 3.906
G_range = 2;                    % Range of acceleration values:  2, 4, 8

% Write input file for data acquisition code
InputFile = fopen(inputfile,'w');
fprintf(InputFile,'%s\n',outfilename);
fprintf(InputFile,'%i\n',mtime);
fprintf(InputFile,'%f\n',rate);
fprintf(InputFile,'%i\n',G_range);
fclose(InputFile);

% Write input file to destination folder
source = pwd;
source = append(source,'\',inputfile);
destination = folder;
putFile(rpi,source,destination);
%-------------------------------------------------------------------------

% Execute Python script to acquire accel data
system(rpi, append('python ', folder, script));

% Retrieve output file from R-Pi
getFile(rpi,outfilename);

DATAg = importdata(datafile);   % Read data file
DATA = [DATAg(:,1),DATAg(:,2:4).*9.81]; % Multiply accel data by 9.81 to convert from g to m/s^2

plot(DATA(:,1),DATA(:,2),'r');
hold on; grid on;
plot(DATA(:,1),DATA(:,3),'g');
plot(DATA(:,1),DATA(:,4),'b');
legend('X', 'Y', 'Z');
% axis AUTO;
xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');
