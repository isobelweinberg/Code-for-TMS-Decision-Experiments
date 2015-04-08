try
%Load parameters
[params] = load_parameters;
%Open Window
[screen] = screen_setup(params)
%Some inputs
TotalNumTrials = 100;
TrialsPerBlock = 100;
TotalNumBlocks = 1;
CoherenceArray = [1 5 10 50 100];
LeftProbabilityArray = [50];
%Generate the stimuli
[FixationXY, DotsXY, data] = generate_stimuli(params.NumDots, TotalNumTrials, TrialsPerBlock, TotalNumBlocks, CoherenceArray, LeftProbabilityArray)
    
1. Get lots of data
Run with a range of coherences



2. Plot & fit psychometric function
3. Use fit to find best fit

catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end