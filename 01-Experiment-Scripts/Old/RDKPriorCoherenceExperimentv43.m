try
    
    clear all;
    sca;
    KbName('UnifyKeyNames');
    
    %Global Variables
    global TotalNumFrames;
    global ApertureRadius;
    global TotalNumBlocks;
    global LeftProbabilityArray;
    global CoherenceArray;
    global TMSTimepointArray;
    global TrialsPerBlock;
    global DotSpeed;
    global DotRadius;
    global IFI;
    global option;
    global xmiddle;
    global ymiddle;
    global windowNo;
    global FixationRadius;
    global DotColour;
    global FixationDuration;
    global MaxITIDuration;
    global MinITIDuration;
    global FeedbackDuration;
    global triggerlength;
        
    %% === ParticipantDetails ===
    participant.Name='Isobel_Weinberg'; %use underscores
    participant.Age=25;
    note=''; %appears at end of filename
    participant.meanRT=[];
    
    %% === Experiment Type ====
    option.Training = 0;
    option.TMS = 0;
    option.explicitprior = 1;
    option.scaletoRT = 0;
    
    %% ==== Inputs =====
    
    % Independent variables
    CoherenceArray = [5 50 95]; %percent
    LeftProbabilityArray=[10 50]; %probability the RDK goes left, as a percentage
    TMSFixationTimepoints = []; %TMS timepoints in ms, relative to onset of Fixation
    TMSStimTimepoints = [20 50 100]; %TMS timepoints in ms, relative to onset of Stim (or in % of meanRT, if scaletoRT is on)
    TMSITITimepoints = [10]; %TMS timepoints in ms, relative to onset of ITI (end of feedback)
    TMSFixationProb = 0;
    TMSStimProb = 0.6;
    TMSITIProb = 0.2;
    NoTMSProb = 0.2;
    TMSTimepointArray = [StimulusOnset, (StimulusOnset+20), (StimulusOnset+50), (ITIOnset+20)];%in ms 
%     ProbabilityOfTMS = 80; %in percent, gives you TMS trials vs behavioural trials
    TrialsPerCondition = 20;
    
    % Timings
    StimulusDuration = 1000; %ms - how long participant gets to make a response
    FixationDuration = 400; %length of fixation, milliseconds
    FeedbackDuration = 200; %milliseconds
    MinITIDuration = 500; %ms
    MaxITIDuration = 1000; %maximum lenth of intertrial interval, milliseconds
    
    
    % Stimulus Properties
    DotRadius = 2.5; %pixels
    NumDots = 300;
    ApertureRadius = 200; %pixels; radius of circular aperture for RDK
    DotSpeed = 1500; %pixels per second
    FixationRadius = 2.5; %pixels; radius of fixation dot
    BackgroundColour = 255; %white
    DotColour = [0 0 0]; %black
    
    % TMS
    triggerlength = 0.1; %stimulus duration, MILLISECONDS
    
    % Directions    
    Directions = [-1, 1];
    conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
    
    %% Setup
    
    switch option.TMS
        case 1
            TotalNumTrials = TrialsPerCondition*numel(CoherenceArray)*numel(LeftProbabilityArray)...
                *numel(TMSTimepointArray)*numel(Directions);
        case 0
            TotalNumTrials = TrialsPerCondition*numel(CoherenceArray)*numel(LeftProbabilityArray)...
                *numel(Directions);
    end
    
    TrialsPerBlock = TotalNumTrials/numel(LeftProbabilityArray);
    
    %File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    filename = strcat(date,'_',participant.Name,'_',time, note);
    
    
    %KeyNames
    %     escapeKey = KbName('ESCAPE');
    %     leftKey = KbName('LeftArrow');
    %     rightKey = KbName('RightArrow');
    %     spacebarKey = KbName('space');
    
    %Priority 1
    Priority(1);
    
    %Use line below to make window transparent for debugging
%         PsychDebugWindowConfiguration();
    
    Screen('Preference', 'SkipSyncTests', 0);
    
     %% Open a window
    windowNo = Screen('OpenWindow', 0, BackgroundColour);%0 is the main
    Screen('BlendFunction', windowNo, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' ); %anti-aliasing
    RefreshRate = Screen('FrameRate', windowNo); %in Hz; PTB asks the screen what its refresh rate is
    TotalNumFrames = ceil((StimulusDuration/1000)*RefreshRate); %this is how many frames we need for the stimulus
    IFI = 1/RefreshRate; %interframe interval, seconds
    
    %Find the middle of the screen
    middlerect = Screen('Rect',windowNo);
    xmiddle=middlerect(1,3)*0.5;
    ymiddle=middlerect(1,4)*0.5;
    
    %How many blocks are there?
    TotalNumBlocks = TotalNumTrials/TrialsPerBlock;
    
    %Human error check
    if numel(LeftProbabilityArray)~=TotalNumBlocks
        DrawFormattedText(windowNo, 'Error. \n The number of blocks does not match the number of dot direction probabilities you have entered. \n Press any key', 'center', 'center', [0 0 0]);
        Screen('Flip', windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end
    
    %Make empty variable for Subject responses, RTs and RDK directions
    results.Response=zeros(1,TotalNumTrials);
    results.Direction=zeros(1,TotalNumTrials);
    results.ReactionTime=zeros(1,TotalNumTrials);
    
    % Check for filename clash - MAKE SURE THIS IS UNCOMMENTED FOR THE
    % EXPERIMENTS
    if exist([filename '.mat'], 'file')>0
        DrawFormattedText(windowNo, 'There is already a file with this name. Please check for errors.', 'center', 'center', [0 0 0]);
        Screen('Flip', windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end
    
    % Set up parallel port (using Data Acquisition Toolbox)
    if option.TMS == 1
        port = digitalio('parallel', 'LTP1'); %defines the port as an object called port
        addline(port, 0:3, 'out'); %lines 0-3, making them writeable (output)
    end   
    
    
    %% Load
    % call these once to avoid a slow first iteration
    GetSecs;
    KbCheck;
    if option.TMS ==1
        putvalue(port, 0); %sends 0 to the port
    end
    
    %Seed the random number generator
    rng('shuffle'); %modern
    %     rand('seed', sum(100 * clock)); %legacy
    
    
    
    %% Generate stimuli
    [FixationXY, DotsXY, data] = generate_stimuli(NumDots, TotalNumTrials);
    
    %% Draw the stimuli
    ExperimentStart=datetime;
    results = draw_stimuli(FixationXY, DotsXY, data, TotalNumTrials);    
    ExperimentEnd = datetime;
    %% Finish
    sca;
    Priority(0);
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end

%%To DO

%FIX GENERATE AND DRAW STIMULI - TRIALS PER BLOCK!
%WHY ARE THEY ALL GOING RIGHT?

%Threshold coherences to subject!!
%visual angle
%ITI can go too short - add in min


%TMS pulses!
%TMS in ITI - add an if ITI clause?
% make TMS pulses a fraction of RT
%some no TMS trials? or are we doing behaviour separately?

%ask for inputs - participant details, threshold, mean RT

%originating script data insert
%trials for training


%Record any errors
%Rationalise variables
%Make random numbers repeatable?
%Compare to others' scripts
%button box!!

%Feedback!! - based on RT?

%Inputs

%should all be functions?
%make triggers variables
%make durations variables
%make colours variables
%visual angle
%allocate all coherences etc in one go?

%change all the 1, TrialNo to TrialNo??
% check have made allowances for dotwidth throughout

%decide on all variable names & consider using structures for global
%variables