global prep;
addpath quitfix;

%%%%%%%%%%%%%%% one value for you, you can load this instead
prep.subj_trainingRT = [700]; %individual's mean RTs 
% --------------------------------------------------------------------------
% Type of experiment
TMS         = 0; % 1 means that this is the TMS experiment and triggering
buttonbox   = 0; % 1 means that it is using the button box instead of keyboard i.e. serialport
eye_tracker = 0; % 1 means that it is communicating with eyetracker/spike when a saccade
                 % is made (i.e. when spike channel for eye posistion has exceeded 
                 % set threshold consistently for set time period); also
                 % cogent sends a trigger to spike when the choice is presented 
short       = 0; % will simply cut down from 96 to first 10 trials (don't 
                 % change no of trials below, generate_stim does that 
training    = 0; % will simply cut down from 96 to first 50 trials (or whatever set in generate_stim)
presheight  = -100;% adapts where on the screen everything presented (-100:100)

% --------------------------------------------------------------------------
% Configure devices
cgloadlib;
config_display(0, 1, [0 0 0], [0 0 0], 'Arial', 50, 5);   % use this for  small screen version

if buttonbox
    port_buttonbox = 2;
    config_serial(port_buttonbox); % first serial port for buttonbox
end
if eye_tracker
    port = 888;
    outport = 129; %weird needs 128 + 2^n
    %startportb;%(port);     
    wait(20);
    port_eye = 1;
    config_serial(port_eye,9600); % second serial port for eye movements
end
if TMS
    prep.ntestpulses=5;
    port_TMS = 3;
    %config_serial; % why not working when specifying number???
    outportb(888, port_TMS); % opens parallel port at "address" 888, via output lead 3
    wait(2); 
    outportb(888, 0); 
end
config_keyboard(10,1,'nonexclusive');
prep.when_start         = datestr([now],0);  % logs the date and time

% --------------------------------------------------------------------------
% Blocks and trials
prep.Blocks         = [1 2 3 4];
prep.design.conditions      = 2; %forced choice and choice
prep.design.actions         = 3; %eye,handR,handL
prep.design.trialsPerCond   = [12 24]; % forced choice / choice
prep.TMStimes(1,:)          = round(ana.subj_trainingRT(1)*[0.1 0.15 0.25 0.35 0.50 0.65]);% change percentages 
%%%%%%%%%%%%%%%%prep.TMStimes(2,:)          = round(prep.subj_trainingRT(2)*[0.1 0.35 0.5 0.6 0.7 0.8]);
%prep.TMStimes               = [80 190 300 410 520 630];
% 2*3*6*18 is 648, and then per block that's 162
prep.design.ttrials         = prep.design.conditions*prep.design.actions*length(prep.TMStimes)*mean(prep.design.trialsPerCond);
prep.design.ntrials         = prep.design.ttrials/length(prep.Blocks);

% --------------------------------------------------------------------------
% ASCII values that I get through serial port for eye movements
letterN     = 78;   % sent by Spike for new file
letterT     = 84;   % detected trigger
letterX     = 88;   % timed out trigger
letterR     = 82;   % response is also sending RT as "R=XX.XX" ms 
equalsign   = 61;
dotSign     = 46;
numbers(48:57) = [0:1:9]; % 0 to 9

% --------------------------------------------------------------------------
% Duration of presenation
prep.dur.maxChoice      = 2000;    % max time to respond
prep.dur.Delay1         = 500;     % todo jitter?
prep.dur.Outcome        = 500;     % Reward/Earned money

prep.Resp_keys          = [13 22 3]; % M for handR, V for handL (and temporarily C for eye)
if eye_tracker
    prep.Resp_keys(3)    = letterR;
end
if buttonbox
    prep.Resp_keys(1:2)  = [1 16]; %1 2 4 8 16 are button box keys
end

% --------------------------------------------------------------------------
% How far in periphery and how big
prep.periph      = 25;              % how far in pheriphery are stim presented
prep.periph_dot  = 240;             % how war the dot for eye movement
textsizeQ        = 20;              % 'too slow'
textsizeT        = 15;              % Instructions and feedback

% --------------------------------------------------------------------------
% Payment and randomwalk reward files
maxpblock           = 2.5;      % in pounds the maximum they can get per block

% --------------------------------------------------------------------------
% create variables for logging responses etc
prep.Data           =   [];
prep.Data.Results   =   [];     % vector coding the results
won                 =   [];
TTrialstart         =   [];
TOffer              =   [];
TOfferend           =   [];
TChoiceend          =   [];
TResponse           =   [];
TOutcome            =   [];
TFix1               =   [];
TFix2               =   [];
