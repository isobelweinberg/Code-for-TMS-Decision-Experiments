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
        
    %% ParticipantDetails
    participant.Name='Isobel_Weinberg'; %use underscores
    participant.Age=25;
    note=''; %appears at end of filename
    
    %% Experiment Type
    option.Training = 0;
    option.TMS = 0;
    option.explicitprior = 1;
    
    %% Inputs
    DotRadius = 2.5; %pixels
    StimulusDuration = 1000; %ms - how long participant gets to make a response
    NumDots = 300;
    ApertureRadius = 200; %pixels; radius of circular aperture for RDK
    DotSpeed = 1500; %pixels per second
    MaxITIDuration = 1000; %maximum lenth of intertrial interval, milliseconds
    FixationDuration = 400; %length of fixation, milliseconds
    FixationRadius = 2.5; %pixels; radius of fixation dot
    BackgroundColour = 255; %white
    DotColour = [0 0 0]; %black
    %Independent variables
    CoherenceArray = [5 50 95]; %percent
    LeftProbabilityArray=[10 50]; %probability the RDK goes left, as a percentage
    TMSTimepointArray = [50 100];%in ms
    TrialsPerCondition = 20;
    
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
    
    %% 
    
    
    %% Load
    % call these once to avoid a slow first iteration
    GetSecs;
    KbCheck;
    % also outportb
    
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
%some no TMS trials? or are we doing behaviour separately?



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