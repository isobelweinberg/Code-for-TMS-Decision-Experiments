try
    
    clear all;
    sca;
    KbName('UnifyKeyNames');
    
    %Global Variables
    
    global participant;
    global filename;
    global TMS;
    global port;
       
    
    %% === ParticipantDetails ===
    participant.Name='Isobel_Weinberg'; %use underscores
    participant.Age=25;
    note='deletethese'; %appears at end of filename
    participant.meanRT=NaN; %in ms. Needed if scaling to RT
%     participant.threshold = (16.125/100); %as a decimal %COMMENT OUT IF NOT USING!
        
    %% === Experiment Type ====
    option.Training = 0;
    option.TMS = 1;
    option.explicitprior = 1;
    option.scaletoRT = 0;
    option.estimatethreshold = 0; %=> COMMENT OUT THE THRESHOLD?
    option.mainexp = 1;
    
    
    %% ==== Inputs =====
    
    % Independent variables
    CoherenceArray = [1, 1.5, 2]; %proportion of participant's threshold, or just percentages (if you haven't given a threshold)
    LeftProbabilityArray=[30, 40, 50]; %probability the RDK goes left, as a percentage
    TrialsPerCondition = 20;
    %TMS
    TMS.Timepoints = [0, 0.25, 0.5]; %TMS timepoints, in SECONDS, relative to...
    %NB if scaling to RT, give the timepoints relative to stim as
    %proportion of mean RT e.g. 0.65
    TMS.TimepointRelations = {'Stim', 'Stim', 'Stim'}; %....Fixation, Stim or ITI
    TMS.Probability = 80; %in percent, gives you TMS trials vs behavioural trials
    %NB, if you are stimulating in the ITI, the interval needs to be less
    %than the minimum ITI duration!
    
    % Timings
    StimulusDuration = 1000; %ms - how long participant gets to make a response
    param.FixationDuration = 400; %length of fixation, milliseconds
    param.FeedbackDuration = 200; %milliseconds
    param.MinITIDuration = 2500; %ms
    param.MaxITIDuration = 3500; %maximum lenth of intertrial interval, milliseconds
    param.TriggerLength = 0.1; %TMS stimulus duration, MILLISECONDS
    
    % Stimulus Properties
    param.DotSpeed = 2.5; %pixels
    NumDots = 300;
    ApertureRadius = 200; %pixels; radius of circular aperture for RDK
    param.DotSpeed = 1500; %pixels per second
    param.FixationRadius = 2.5; %pixels; radius of fixation dot
    BackgroundColour = 255; %white
    param.DotColour = [0 0 0]; %black
    
    % Directions
    Directions = [-1, 1];
    conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
    
    %% Setup
    
    switch option.TMS
        case 1
            TotalNumTrials = TrialsPerCondition*numel(CoherenceArray)*numel(LeftProbabilityArray)...
                *numel(Directions)*(numel(TMS.Timepoints(1,:))+1);
            %the 1 is for no TMS trials
        case 0
            TotalNumTrials = TrialsPerCondition*numel(CoherenceArray)*numel(LeftProbabilityArray)...
                *numel(Directions);
    end
    
    TrialsPerBlock = TotalNumTrials/numel(LeftProbabilityArray);
    %How many blocks are there?
    TotalNumBlocks = TotalNumTrials/TrialsPerBlock;
    
    %Scaling to RT
    if option.scaletoRT == 1
        if isnan(participant.meanRT)
            Error('Please supply a mean RT')
        else
            stimtimepoints = strcmp(TMS.Timepoints(2, :), 'Stim');
            TMS.Timepoints(1, stimtimepoints) = TMS.Timepoints(1, stimtimepoints) * participant.meanRT;
        end
    end
    
    
    %File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    filename = strcat('data/',date,'_',participant.Name,'_',time, note);
       
    
    %KeyNames
    %     escapeKey = KbName('ESCAPE');
    %     leftKey = KbName('LeftArrow');
    %     rightKey = KbName('RightArrow');
    %     spacebarKey = KbName('space');
    
    %Priority 1
    Priority(1);
    
    %Use line below to make window transparent for debugging
%     PsychDebugWindowConfiguration();
    
    Screen('Preference', 'SkipSyncTests', 0);
    
    %% Open a window
    param.windowNo = Screen('OpenWindow', 0, BackgroundColour);%0 is the main
    Screen('BlendFunction', param.windowNo, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' ); %anti-aliasing
    RefreshRate = Screen('FrameRate', param.windowNo); %in Hz; PTB asks the screen what its refresh rate is
    TotalNumFrames = ceil((StimulusDuration/1000)*RefreshRate); %this is how many frames we need for the stimulus
    param.IFI = 1/RefreshRate; %interframe interval, seconds
    
    %Find the middle of the screen
    middlerect = Screen('Rect',param.windowNo);
    param.xmiddle=middlerect(1,3)*0.5;
    ymiddle=middlerect(1,4)*0.5;
        
    %Human error check
    if numel(LeftProbabilityArray)~=TotalNumBlocks
        DrawFormattedText(param.windowNo, 'Error. \n The number of blocks does not match the number of dot direction probabilities you have entered. \n Press any key', 'center', 'center', [0 0 0]);
        Screen('Flip', param.windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end
        
    %Make empty variable for Subject responses, RTs and RDK directions
    results.Response=zeros(1,TotalNumTrials);
    results.Direction=zeros(1,TotalNumTrials);
    results.ReactionTime=zeros(1,TotalNumTrials);
    %==MORE EMPTY VARIABLES NEEDED==
    
    % Check for filename clash - MAKE SURE THIS IS UNCOMMENTED FOR THE
    % EXPERIMENTS
    if exist([filename '.mat'], 'file')>0
        DrawFormattedText(param.windowNo, 'There is already a file with this name. Please check for errors.', 'center', 'center', [0 0 0]);
        Screen('Flip', param.windowNo);
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
%     rng('shuffle'); %modern
     rand('seed', sum(100 * clock)); %legacy
    
    
    %% Threshold
    if option.estimatethreshold == 1 && exist('alreadythresholded', 'var') == 0
        filename = strcat('data/',date,'_',participant.Name,'_',time,'_thresholding',note);
        
        %temporarily turn TMS off
        tempstore = option.TMS;
        option.TMS = 0;
        
        %Variables for thresholding
        thresholding.trialsperblock = 1;
        thresholding.totalnumblocks = 1;
        thresholding.leftprobabilityarray = 50;
        thresholding.stepsize = 12;
        thresholding.minimumreversals = 16;
        thresholding.minimumtrials = 40;
        
        thresholding.trial = 1;
        thresholding.reversals = 0;
        
        %display intro screen
        DrawFormattedText(param.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
        Screen('Flip', param.windowNo);
        KbStrokeWait;
        
        %==1-up-2-down (transformed up-down rule, Levitt, 1970) -> find 70.7% correct threshold
                     
        while thresholding.reversals <  thresholding.minimumreversals || thresholding.trial < thresholding.minimumtrials %must have an even number of runs -> odd number of reversls
            
            %set coherence
            if thresholding.trial == 1 || thresholding.trial == 2 %threshold is constant for trials 1 and 2
                thresholding.coherence(1, thresholding.trial) = 70;
            elseif (thresholding.alldata.Response(1, (thresholding.trial-1)) == 1 && thresholding.alldata.Direction(1, (thresholding.trial-1)) == -1)...
                    || (thresholding.alldata.Response(1, (thresholding.trial-1)) == 2 &&...
                    thresholding.alldata.Direction(1, (thresholding.trial-1)) == 1) %if last response was correct
                if (thresholding.alldata.Response(1, (thresholding.trial-2)) == 1 && thresholding.alldata.Direction(1, (thresholding.trial-2)) == -1)...
                        || (thresholding.alldata.Response(1, (thresholding.trial-2)) == 2 &&...
                        thresholding.alldata.Direction(1, (thresholding.trial-2)) == 1) %if response prior to that was also correct
                    %threshold decreases by 1 step size
                    thresholding.coherence(1, thresholding.trial) = thresholding.coherence(1, (thresholding.trial-1))...
                        - thresholding.stepsize;
                 else
                    %threshold stays the same
                    thresholding.coherence(1, thresholding.trial) = thresholding.coherence(1, (thresholding.trial-1));
                end
            else %incorrect response
                %threshold increases by 1 step size
                thresholding.coherence(1, thresholding.trial) =...
                    thresholding.coherence(1, (thresholding.trial-1)) + thresholding.stepsize;
            end
            if thresholding.coherence(1, thresholding.trial) < 0
                thresholding.coherence(1, thresholding.trial) = 0;
            end
            
            %== was this a reversal? ==
            if thresholding.trial > 3 %enough trials to make a decision?
                %what direction is it going in now?
                %coherence on this trial minus prev trial
                curr_direction = thresholding.coherence(1, (thresholding.trial)) - thresholding.coherence(1, (thresholding.trial-1));
                if curr_direction == 0
                    curr_direction = thresholding.coherence(1, (thresholding.trial-1)) - thresholding.coherence(1, (thresholding.trial-2));
                end
                %what direction did it used to be going in?
                prev_direction = thresholding.coherence(1, (thresholding.trial-1)) - thresholding.coherence(1, (thresholding.trial-2));
                if prev_direction == 0
                    prev_direction = thresholding.coherence(1, (thresholding.trial-2)) - thresholding.coherence(1, (thresholding.trial-3));
                end
                if (curr_direction < 0 && prev_direction < 0) || (curr_direction > 0 && prev_direction > 0) %if in same direction
                    %do nothing
                else
                    thresholding.reversals = thresholding.reversals+1; %increment reversals
                end
            end
            
            %record the reversal number on this trial
            thresholding.reversalrecord(1, thresholding.trial) = thresholding.reversals;
            
            %generate and draw stimuli
            [thresholding.fixationXY, thresholding.dotsxy, thresholding.data] = generate_stimuli(NumDots, 1, thresholding.trialsperblock,...
                thresholding.totalnumblocks, thresholding.coherence(1, thresholding.trial), thresholding.leftprobabilityarray);
            thresholding.results = draw_stimuli(thresholding.fixationXY, thresholding.dotsxy, thresholding.data,...
                1, thresholding.trialsperblock, thresholding.totalnumblocks);
            %save the results
            %(this needs to be done because otherwise in the generate_stim
            %functions, trialno is always 1, so all data gets overwritten.
            %kind of a botch)
            thresholding.alldata.Response(1, thresholding.trial) = thresholding.results.Response;
            thresholding.alldata.Direction(1, thresholding.trial) = thresholding.data.Direction;
            thresholding.alldata.ReactionTime(1, thresholding.trial) = thresholding.results.ReactionTime;
            %increment trial number
            thresholding.trial = thresholding.trial + 1;
           save (filename); 
        end
        
        %calclulate 70.7% threshold - the 'mid-run estimate' - the average
        %of halfways points of every second run
        helpfultrials = cell(thresholding.reversals,1); %preallocation
        average_coherence = zeros(thresholding.reversals,1);
        for reversal = 1:2:thresholding.reversals %odd reversals only
            helpfultrials{reversal} = find(thresholding.reversalrecord == reversal); %find the trials of this reversal
            %you also need one trial before the reversal
            helpfultrials{reversal} = [(min(helpfultrials{reversal})-1), helpfultrials{reversal}];
            %midpoint of the coherences of these trials
            trough_trial(reversal) = min(helpfultrials{reversal}); %find the trough
            trough_coherence(reversal) = thresholding.coherence(1, trough_trial(reversal)); %coherence at this trough
            peak_trial(reversal) = max(helpfultrials{reversal});
            trough_peak(reversal) = thresholding.coherence(1, peak_trial(reversal));
            %average coherence the trough and peak
            midrunestimate(reversal) = (trough_coherence(reversal) + trough_peak(reversal))/2;
            %mean coherence of these trials
%             average_coherence(reversal) = mean(thresholding.coherence(1, (helpfultrials{reversal}))) ;
        end
        
        threshold71 = mean(midrunestimate(1:2:end)); %mean of the mid-runestimate for the odd reversals
        
        %put TMS back to where it was
        option.TMS = tempstore;
        
        %thresholding complete
         alreadythresholded = 1;
         
         %save
         save (filename);
    end
    %% Main Experiment
    if option.mainexp == 1
        
        % Generate stimuli
        [FixationXY, DotsXY, data] = generate_stimuli(NumDots, TotalNumTrials, TrialsPerBlock, TotalNumBlocks, CoherenceArray, LeftProbabilityArray);
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