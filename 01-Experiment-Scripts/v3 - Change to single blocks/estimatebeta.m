try
[params] = load_parameters; %Load stimulus parameters
[participant] = get_input; %Get participant's info
[screen] = screen_setup(params); %Initialise the screen
[params] = calc_frames(params, screen); %Calcualte the frames
%Some inputs
NumTrials = 1;
TrialsPerBlock = 1;
TotalNumBlocks = 1;
vars.CoherenceArray = [1 5 10 50 100];
vars.LeftProbabilityArray = [50];
vars.TrialsPerCondition = 20;
vars.TMS.Timepoints = [0, 0.25, 0.5]; %TMS timepoints, in SECONDS, relative to...
%NB if scaling to RT, give the timepoints relative to stim as
 %proportion of mean RT e.g. 0.65
vars.TMS.TimepointRelations = {'Stim', 'Stim', 'Stim'}; %....Fixation, Stim or ITI
vars.TMS.Probability = 80; %in percent, gives you TMS trials vs behavioural trials
vars.Directions = [-1, 1];
vars.conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
option.TMS = 0;
option.explicitprior = 1;
option.estimatethreshold = 0;

data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
%Generate the stimuli
[FixationXY, DotsXY, data] = generate_stimuli(NumTrials, vars, params, participant, option, data);
data = draw_stimuli(FixationXY, DotsXY, NumTrials, TrialsPerBlock, params, screen, participant, option, data);
DrawFormattedText(screen.windowNo, 'Experiment finished! Press any key to continue.', 'center', 'center', [0 0 0]);
        Screen('Flip', screen.windowNo);
        KbStrokeWait;
        data.ExperimentEnd = clock; %ExperimentEnd = datetime;
                sca;
Priority(0);
% 2. Plot & fit psychometric function
% 3. Use fit to find best fit
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end