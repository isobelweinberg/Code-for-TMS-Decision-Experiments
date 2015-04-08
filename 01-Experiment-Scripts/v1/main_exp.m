try
    
%    ?? clear all;
    sca;
    KbName('UnifyKeyNames');
    
    %Global Variables
    global filename;
    global port;
         
    %% === Experiment Type ====
    option.Training = 0;
    option.TMS = 1;
    option.explicitprior = 1;
    option.scaletoRT = 0;
    option.estimatethreshold = 0; %=> COMMENT OUT THE THRESHOLD?
    option.mainexp = 1;
        
    %% ==== Inputs =====
    
    % Independent variables
    vars.CoherenceArray = [1, 1.5, 2]; %proportion of participant's threshold, or just percentages (if you haven't given a threshold)
    vars.LeftProbabilityArray=[30, 40, 50]; %probability the RDK goes left, as a percentage
    vars.TrialsPerCondition = 20;
    %TMS
    vars.TMS.Timepoints = [0, 0.25, 0.5]; %TMS timepoints, in SECONDS, relative to...
    %NB if scaling to RT, give the timepoints relative to stim as
    %proportion of mean RT e.g. 0.65
    vars.TMS.TimepointRelations = {'Stim', 'Stim', 'Stim'}; %....Fixation, Stim or ITI
    vars.TMS.Probability = 80; %in percent, gives you TMS trials vs behavioural trials
    %NB, if you are stimulating in the ITI, the interval needs to be less
    %than the minimum ITI duration!
    
    % Directions
    vars.Directions = [-1, 1];
    vars.conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
    
    %Get the stimulus parameters & timings from the function which stores
    %them
   [params] = load_parameters;
    
    %% Setup
    switch option.TMS
        case 1
            TotalNumTrials = vars.TrialsPerCondition*numel(vars.CoherenceArray)*numel(vars.LeftProbabilityArray)...
                *numel(vars.Directions)*(numel(vars.TMS.Timepoints(1,:))+1);
            %the 1 is for no TMS trials
            % THIS IS WRONG IF ALL TRIALS ARE TMS - FIX!!!!!!
        case 0
            TotalNumTrials = vars.TrialsPerCondition*numel(vars.CoherenceArray)*numel(vars.LeftProbabilityArray)...
                *numel(vars.Directions);
    end
    
    TrialsPerBlock = TotalNumTrials/numel(vars.LeftProbabilityArray);
    %How many blocks are there?
    TotalNumBlocks = TotalNumTrials/TrialsPerBlock;
    
    %Scaling to RT
    % LOOK AT THIS AGAIN!
    %SHOULD MEAN RT COME FROM THRESHOLDING - WON'T IT BE TOO LONG?
    if option.scaletoRT == 1
        if isnan(participant.meanRT)
            Error('Please supply a mean RT')
        else
            stimtimepoints = strcmp(vars.TMS.Timepoints(2, :), 'Stim');
            vars.TMS.Timepoints(1, stimtimepoints) = vars.TMS.Timepoints(1, stimtimepoints) * participant.meanRT;
        end
    end
        
    %File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    filename = strcat('data/',date,'_',participant.Name,'_',time, note);
       
    %% Setup the screen
    [screen] = screen_setup(params);
    
    %Human error check %HAVE ANOTHER LOOK AT THIS - STILL RELEVANT??
    if numel(vars.LeftProbabilityArray)~=TotalNumBlocks
        DrawFormattedText(screen.windowNo, 'Error. \n The number of blocks does not match the number of dot direction probabilities you have entered. \n Press any key', 'center', 'center', [0 0 0]);
        Screen('Flip', screen.windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end

    %Surely this should be in generate stimuli?
    data = NaN(TotalNumTrials, 12);
%     %Make empty variable for Subject responses, RTs and RDK vars.Directions
%     results.Response=zeros(1,TotalNumTrials);
%     results.Direction=zeros(1,TotalNumTrials);
%     results.ReactionTime=zeros(1,TotalNumTrials);
%     %==MORE EMPTY VARIABLES NEEDED==
    
    %SORT THIS OUT
    % Check for filename clash - MAKE SURE THIS IS UNCOMMENTED FOR THE
    % EXPERIMENTS
    if exist([filename '.mat'], 'file')>0
        DrawFormattedText(screen.windowNo, 'There is already a file with this name. Please check for errors.', 'center', 'center', [0 0 0]);
        Screen('Flip', screen.windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end
    
    % Set up parallel port (using Data Acquisition Toolbox)
    if option.TMS == 1
        params.port = digitalio('parallel', 'LTP1'); %defines the port as an object called port
        addline(params.port, 0:3, 'out'); %lines 0-3, making them writeable (output)
    end
        
    %% Load
    % call these once to avoid a slow first iteration
    GetSecs;
    KbCheck;
    if option.TMS ==1
        putvalue(port, 0); %sends 0 to the port
    end
    
    %Seed the random number generator
%     rng('shuffle'); %modern
     rand('seed', sum(100 * clock)); %legacy    
   
    %% Main Experiment
    
    [params] = calc_frames(params, screen); %Find no of frames needed
    data.ProbabilityOrder = randperm(TotalNumBlocks); %Used to order the probabilities
    data.labels{2} = {'BlockNo'};
    if option.mainexp == 1
        for BlockNo = 1:TotalNumBlocks
            data.main(NumTrials, 2) = BlockNo;
            data.main(NumTrials, 3) = vars.LeftProbabilityArray(1, (data.ProbabilityOrder(1, BlockNo)));
            [FixationXY, DotsXY, data] = generate_stimuli(NumTrials, vars, params, participant, option, data); %generate stimuli
            
            
        generate
        save 
        draw
        end
        
       
       
    
        
    
    
    
    
    
    
    
    
    
    
    
        % Generate stimuli
        [FixationXY, DotsXY, data] = generate_stimuli(NumDots, TotalNumTrials, TrialsPerBlock, TotalNumBlocks, vars.CoherenceArray, LeftProbabilityArray);
        % Draw the stimuli
        ExperimentStart = clock;
        %ExperimentStart = datetime;
        results = draw_stimuli(FixationXY, DotsXY, data, TotalNumTrials, TrialsPerBlock, TotalNumBlocks);
        ExperimentEnd = clock;
        %ExperimentEnd = datetime;        
    end
    %% Finish
    save (filename);
    sca;
    Priority(0);
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end

%% ===To Do ====
% 
% 1. Get rid of global variables
% 2. Change data collection to matrix
% 3. Visual anagle
% 4. num coherent dots - sometimes not a whole number - is this causing problems?
% 5. *Threshold for more than one threshold
% 6. ask for inputs - participant details, threshold, mean RT
% 7. originating script data insert
% 8. Reward based on mean RT?
% 9. What to do about/how to calculate mean RT

%Record any errors
%Rationalise variables
%Make random numbers repeatable?
%Compare to others' scripts
%button box!!

%Feedback based on RT?

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