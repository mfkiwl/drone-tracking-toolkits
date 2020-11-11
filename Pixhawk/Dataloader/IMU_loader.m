%% Load IMU data from flight log file
% format: IMU,QffffffIIfBBHH,TimeUS,GyrX,GyrY,GyrZ,AccX,AccY,AccZ,EG,EA,T,GH,AH,GHz,AHz
clear;

%% select from three different IMU names (IMU, IMU2, IMU3)
% IMUname='IMU,';
IMUname='IMU2';
% IMUname='IMU3';

%% define the log file's path
%log_filename='test_log2.txt';
%log_filename='2019-11-02 16-14-04.txt';
log_filename='2020-11-09 10-36-06.txt';

%log_file_path=['.' filesep 'test_data' filesep log_filename];
%log_file_path=['..' filesep '..' filesep 'dataset' filesep 'indoor_dataset_2' filesep log_filename];
log_file_path=['..' filesep '..' filesep 'dataset' filesep 'outdoor_dataset_0' filesep log_filename];

fid=fopen(log_file_path);
raw_data = textscan(fid,'%s'); % solve the problem for some log files which are segmented with an extra space or tab
raw_data = raw_data{1,1};
fclose(fid); 

%% record data
imu_measure_count=0;

time_us=[];
xgyro=[];
ygyro=[];
zgyro=[];
xacc=[];
yacc=[];
zacc=[];
eg=[];
ea=[];
t=[];
gh=[];
ah=[];
ghz=[];
ahz=[];

for i=1:size(raw_data,1)
   current_str = raw_data{i};
   len_str = size(current_str,2);
   if (len_str < 4)
       continue; 
   end
   current_str_head = current_str(1:4);
   if(current_str_head == IMUname)
       cur_str_split = split(current_str,',');
       cur_str_split = str2double(cur_str_split);
       time_us = [time_us; cur_str_split(2)];
       xgyro=[xgyro; cur_str_split(3)];
       ygyro=[ygyro; cur_str_split(4)];
       zgyro=[zgyro; cur_str_split(5)];
       xacc=[xacc; cur_str_split(6)];
       yacc=[yacc; cur_str_split(7)];
       zacc=[zacc; cur_str_split(8)];
       eg = [eg; cur_str_split(9)];
       ea = [ea; cur_str_split(10)];
       t = [t; cur_str_split(11)];
       gh = [gh; cur_str_split(12)];
       ah = [ah; cur_str_split(13)];
       ghz = [ghz; cur_str_split(14)];
       ahz = [ahz; cur_str_split(15)];
       
       imu_measure_count=imu_measure_count+1;
   end
end

disp(['Collect [', num2str(imu_measure_count), '] IMU data.']); 

%% Plot
figure(1);
plot(1e-3*time_us, [xacc yacc zacc]);
legend('ax','ay','az');
xlabel('timestamp (ms)');
ylabel('acceleration (0.01 m/s^2)');
title('IMU accelerometer measurements');

figure(2);
plot(1e-3*time_us, 180.0/pi*[xgyro ygyro zgyro]);
legend('wx','wy','wz');
xlabel('timestamp (ms)');
ylabel('angular velocity (deg/s)'); % figure out the correct unit
title('IMU gyroscope measurements');