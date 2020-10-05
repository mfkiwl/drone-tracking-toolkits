% Matlab codes for the automatic control of a Leica TS60 total station 
% By YUE PAN @ ETHZ IGP
% IPA project: Measuring Drone Trajectory using Total Stations with Visual Tracking

clear; clc;

% CONSTANTS

%%
%COM port number
COMPort = '/dev/ttyUSB0';  %on Linux
%COMPort = 'COM3';         %on Windows
%dB = 115200;
dB=9600;

%%
% PRSIM TYPE
% PRISM_ROUND = 0,
% PRISM_MINI = 1,
% PRISM_TAPE = 2,
% PRISM_360 = 3,     [used,large one]
% PRISM_USER1 = 4,
% PRISM_USER2 = 5,
% PRISM_USER3 = 6,
% PRISM_360_MINI = 7, [used,small one]
% PRISM_MINI_ZERO = 8,
% PRISM_USER = 9
% PRISM_NDS_TAPE = 10
prism_type = 7; 
%%
% REFLECTOR_TARGET = 0
% REFLECTORLESS_TARGET = 1
target_type = 0; 

%%
atr_state = 1; % ATR state on (1)

%%
% ANGLE MEASUREMENT TOLERANCE
% RANGE FROM 1[cc] ( =1.57079 E-06[ rad ], highest resolution, slowest) 
% TO 100[cc] ( =1.57079 E-04[ rad ], lowest resolution, fastest)
hz_tol = 1.57079e-04; % Horizontal tolerance (moderate resolution) 
v_tol = 1.57079e-04; % Vertical tolerance (moderate resolution)

%%
% DISTANCE MEASUREMENT MODE
% SINGLE_REF_STANDARD = 0,
% SINGLE_REF_FAST = 1,      [IR Fast]
% SINGLE_REF_VISIBLE = 2    [LO Standard]
% SINGLE_RLESS_VISIBLE = 3,
% CONT_REF_STANDARD = 4,   [used, IR Tracking]
% CONT_REF_FAST = 5,
% CONT_RLESS_VISIBLE = 6,
% AVG_REF_STANDARD = 7,
% AVG_REF_VISIBLE = 8,
% AVG_RLESS_VISIBLE = 9

distmode = 4; % Default distance mode (from BAP_SetMeasPrg)

%%

% Open port, connect to TPS
TPSport = ConnectTPS(COMPort, dB);

%Configure TPS for measurements
setPropertiesTPS(TPSport, prism_type, target_type, atr_state, hz_tol, v_tol);


%%

% get current time
begin_time_str = datestr(now,'yyyymmddHHMMSS');

% track the prism
track_status = trackPrism(TPSport);

% figure for listening the keyboard event
figure(1);
title('Enter E on the keyboard to terminate the tracking');
plot3(0,0,0,'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',15);
hold on;
grid on;
xlabel('X(m)');
ylabel('Y(m)');
zlabel('Z(m)');
pause(0.1);

meas_polar=[];
meas_cart=[];
meas_ts=[];
count = 0;
% keep take measurements (both in polar and cartesian coordinate systems)
while(1)
    count=count+1;
    fprintf('Measurement [%s]\n',num2str(count));
    meas_ts =[meas_ts; str2num(datestr(now,'HHMMSSFFF'))]; % get approximate timestamp
    [D,Hr,V] = getMeasurements(TPSport, distmode);
    meas_polar = [meas_polar;[D,Hr,V]]; % in m, deg, deg
    [X,Y,Z]= polar2cart(D,Hr,V);
    meas_cart = [meas_cart; [X,Y,Z]]; % in m, m, m
    if strcmpi(get(gcf,'CurrentCharacter'),'e')
        break;
    end
    %plot3(X,Y,Z,'r:p'); % plot in real-time
    %hold on;
    pause(0.01);
end

plot3(meas_cart(:,1),meas_cart(:,2),meas_cart(:,3),'r:p'); % plot the final trajectory

% save coordinates
save(['results' filesep 'meas_cart_' begin_time_str '.mat'],'meas_cart');
save(['results' filesep 'meas_polar_' begin_time_str '.mat'],'meas_polar');
save(['results' filesep 'meas_ts_' begin_time_str '.mat'],'meas_ts');


% TODO LISTS:
% 1. increase the tracking frequency (now it's only about 5Hz)
% 2. add timestamp (verify its accuracy)
% 3. add status (warning, accuracy...)
% 4. deal with some errors (lose distance measurement 1285)
% 5. deal with the pre-locking function

%%
%Measure the targets with TPS 
% if isfile('Points.mat')
%     load('Points.mat');
% else    
%     mat_Points = RequestPoints(TPSport, distmode);
%     save('Points', 'mat_Points');
% end
% 
% %Automatic measurements phase
% mat_meas  = takeMeasurements(TPSport, distmode, mat_Points);
% 
% %close connection
% fclose(TPSport);
% fprintf('\nTPS is disconnected\n\n');

%Statistical analysis

