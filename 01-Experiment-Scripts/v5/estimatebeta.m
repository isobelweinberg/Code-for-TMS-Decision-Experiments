try
    
    clear all;
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
    %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    filename = strcat('data/',date,'_',participant.Name,'_',time,'_estimatebeta');
    %% ==== Inputs =====
    % Independent variables
    t_vars.CoherenceArray = [1 4 7 10 20 30 50];
    NumTrials=280;
    %% Run Experiment
    t_data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
    t_data.main(1:NumTrials, 2) = 1; % set block number to be 1
    t_data.main(1:NumTrials, 3) = 50; %set the leftward probability to 50%
    DrawFormattedText(t_screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', t_screen.windowNo);
    KbStrokeWait;
    timeZero=GetSecs;
    [t_FixationXY, t_DotsXY, t_data] = generate_stimuli(NumTrials, t_vars, t_params, participant, t_option, t_data);
    t_data = draw_stimuli(t_FixationXY, t_DotsXY, NumTrials, [], t_params, t_screen, participant, t_option, t_data);
    experiment_end(t_screen);
    save (filename);
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end