% Scanning or not
data.MEG = 0;
% Eyetracking or not
data.eye_track = 0;
% Background color
bg_col = [0.2 0.2 0.2];
fix_col = [0.5 0.5 0.5];
instr_col = [0.5 0.5 0.5];

% Configure display & keyboard devices
% ======================================================================= %
cgloadlib;
data.screen.Mode = 1;     % 0=small window, 1=full screen, 2=second screen
data.screen.Res  = 3;     % 1 = normal resolution in behavioural
data.screen.horizontal_cm  	= 38; % adjust in cm (52=office, 38=MEG, 41=testing rooms, 22=laptop)
data.screen.view_dist_cm 	= 53; % adjust in cm
data.screen.refresh         = 60;

% screen resolution used by cogent
data.screen.sizes = [640 480; 800 600; 1024 768; 1152 864; 1280 1024; 1600 1200];
data.screen.resolution = data.screen.sizes(data.screen.Res,:); 

config_display(data.screen.Mode, data.screen.Res, bg_col, [0 0 0], 'Arial', 32, 5);
%config_keyboard(10,1,'nonexclusive');
config_keyboard;

% Triggers
data.scanport      = 888;  % the parallel port address is 888.
data.trig.trial = 10;
data.trig.fixation = 20;
data.trig.dots = 30;
data.trig.delay = 40;
data.trig.instr = 50;
data.trig.choice = 60;
data.trig.iti = 70;

% Durations of presenation
% ======================================================================= %
data.Dur.instructiontime = 5000;
data.Dur.maxChoice      = 1000;     % max time to respond
data.Dur.preStim        = 1000;      % Reward/Earned money
data.Dur.Stim           = 2000;
data.Dur.Delay          = 500;      
data.Dur.ITI            = 1000;
data.Dur.Break          = 5000;

start_cogent;
keys = getkeymap;
data.abortkey   = [keys.F12];
if data.MEG==1
    data.resp_keys          = [28 29];% 1 and 2 on button box
else
    data.resp_keys          = [97 98];
end
stop_cogent;

data.exp_start          = datestr(now,0);  % logs the date and time

data.right = 1;
data.left = 2;

data.num_trials=3;
data.break_interval=25;

whiteC = [1 1 1]; %white
greenC = [0 1 0]; % green

% Size of everything in visual degres and then pixels
% ======================================================================= %
% units we need
data.screen.cm_per_degree = VisAng_to_cm(1,data.screen.view_dist_cm);
data.screen.pxl_per_cm = data.screen.resolution(1)/data.screen.horizontal_cm;
data.screen.pxl_per_degree = data.screen.pxl_per_cm*data.screen.cm_per_degree;

% dot presentation
data.degrees.aperture = 10; % 10 degree visul angle
data.degrees.dotDiam  = 0.3;
data.degrees.dotSpeed = 4; % 2.5 up to cogent v7, then 4 from cogent v8
data.pxl.aperture = round(data.degrees.aperture*data.screen.pxl_per_degree);
data.pxl.dotSpeed = 3/data.screen.refresh * data.degrees.dotSpeed*data.screen.pxl_per_degree; % 5 degrees per refresh rate (but x3 because three sequences interleaved)
data.pxl.noDots = 100;
data.pxl.dotDiam = round(data.degrees.dotDiam*data.screen.pxl_per_degree);
data.pxl.DotArea = (data.pxl.dotDiam/2)^2 * pi;
data.pxl.dotvsemptyPerc = (data.pxl.DotArea*data.pxl.noDots)/(data.pxl.aperture^2);

% instruction & fixation
data.degrees.fix = 0.5; % fixation cross is half a degree
data.pxl.fix  = data.degrees.fix*data.screen.pxl_per_degree;
