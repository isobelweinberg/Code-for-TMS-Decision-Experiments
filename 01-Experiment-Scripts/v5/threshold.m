try
    
    %% Open a dialogue box to get participant's details
    [participant] = get_input;
    
    %% Load Parameters & Setup Screen
    [t_params] = load_parameters; %Get the stimulus parameters & timings from the function which stores them
    [t_screen] = screen_setup(t_params); %Initialise the screen
    [t_params] = calc_frames(t_params, t_screen); %Calculate the number of frames needed
    %% === Experiment Type ====
    t_option.Training = 0;
    t_option.TMS = 0;
    t_option.explicitprior = 0;
    t_option.scaletoRT = 0;
    t_option.mainexp = 0;
    
    %% Filename
    %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    filename = strcat('data/',date,'_',participant.Name,'_',time,'_thresholding');
    %% ==== Inputs =====
    % Independent variables
    t_vars.LeftProbabilityArray=[30, 40, 50]; %probability the RDK goes left, as a percentage
    t_vars.TrialsPerCondition = 20;
    t_vars.TMS.Timepoints = [0, 0.25, 0.5]; %TMS timepoints, in SECONDS, relative to...
    %NB if scaling to RT, give the timepoints relative to stim as
    %proportion of mean RT e.g. 0.65
    t_vars.TMS.TimepointRelations = {'Stim', 'Stim', 'Stim'}; %....Fixation, Stim or ITI
    t_vars.TMS.Probability = 80; %in percent, gives you TMS trials vs behavioural trials
    %NB, if you are stimulating in the ITI, the interval needs to be less
    %than the minimum ITI duration!
    % Directions
    t_vars.Directions = [-1, 1];
    t_vars.conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
    
    %% Setup Quest
    tGuess=-1;
    tGuessSd=2;
    pThreshold=0.82;
    beta=3.5;delta=0.01;gamma=0.5;
    q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
    q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    
    trialsDesired=10;
    wrongRight={'wrong','right'};
    DrawFormattedText(t_screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', t_screen.windowNo);
    KbStrokeWait;
    timeZero=GetSecs;
    for k=1:trialsDesired
        % Get recommended level.  Choose your favorite algorithm.
        tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
        t_vars.CoherenceArray = tTest;
        % We are free to test any intensity we like, not necessarily what Quest suggested.
        % 	tTest=min(-0.05,max(-3,tTest)); % Restrict to range of log contrasts that our equipment can produce.
        
        % Run a trial
        NumTrials = 1;
        TrialsPerBlock = 1;
        timeSplit=GetSecs;
        t_data=[];
        [t_FixationXY, t_DotsXY, t_data] = generate_stimuli(NumTrials, t_vars, t_params, participant, t_option, t_data);
        t_data = draw_stimuli(t_FixationXY, t_DotsXY, NumTrials, TrialsPerBlock, t_params, t_screen, participant, t_option, t_data);
        timeZero = timeZero+GetSecs-timeSplit;
        response = t_data.main(1, 18);
        % Update the pdf
        actualcoherence = t_data.main(1, 21);
        q=QuestUpdate(q,actualcoherence,response); % Add the new datum (actual test intensity and observer response) to the database.
    end
    experiment_end(t_screen);
    t=QuestMode(q);	% Similar and preferable to the maximum likelihood recommended by Watson & Pelli (1983).
    fprintf('Mode threshold estimate is %4.2f\n',t);
  
    
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end