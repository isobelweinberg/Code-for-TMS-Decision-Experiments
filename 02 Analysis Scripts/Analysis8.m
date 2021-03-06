global results

%% Inputs
% clear all
datafile = 'D:\TMS-EMG\Code\Code-for-TMS-Decision-Experiments\01-Experiment-Scripts\190215_Isobel_Weinberg.mat';
plot = 1; %do you want graphs?

%% Notations
%1 in the Direction variable means dots were moving left
%2 in the Direction variable means dots were moving right

%1 in the Response variable means left keypress
%2 in the Response variable means right keypress
%3 in the Response variable means Escape was pressed
%NaN in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)

%% Load file
% load (datafile)


%% Analyse RTs
if isfield (results, 'ReactionTime')==1
    
    %Find RTs by Probability
    variables.Probabilities=LeftProbabilityArray;
    [RTsbyLProbability] = sort_data_by(results.ReactionTime, results.BlockNo, 1:TotalNumBlocks, 1:TotalNumBlocks);
    %Find RTs by Coherence
    variables.Coherences=CoherenceArray;
    [RTsbyCoherence] = sort_data_by(results.ReactionTime, results.Coherence, CoherenceArray, 1:numel(CoherenceArray));
    
    if plot == 1
        %probability vs mean RT
        figure
        hold on
        bar(variables.Probabilities, RTsbyLProbability.mean);
        errorbar(variables.Probabilities, RTsbyLProbability.mean, RTsbyLProbability.stddev, '.');
        title('Mean Reaction Time by Probability')
        xlabel('Probability of Dots Going Left')
        ylabel('Mean Reaction Time')
        
        %probability vs mean RT, both hands
        LRinterspose = zeros(TotalNumBlocks,2);
        for iProbability=1:TotalNumBlocks
            LRinterspose(iProbability,1) = RTsbyLProbability.leftmean(1,iProbability);
            LRinterspose(iProbability,2) = RTsbyLProbability.rightmean(1,iProbability);
        end
        figure
        bar(variables.Probabilities,LRinterspose);
        title('Mean Reaction Time per hand by Probability')
        xlabel('Probability of Dots Going Left')
        ylabel('Mean Reaction Time')
        
        %coherence vs mean RT
        figure
        hold on
        bar(variables.Coherences, RTsbyCoherence.mean);
        errorbar(variables.Coherences, RTsbyCoherence.mean, RTsbyCoherence.stddev, '.');
        title('Mean Reaction Time per hand by Coherence')
        xlabel('Percentage of Dots Moving Together')
        ylabel('Mean Reaction Time')
    end
end

%% Analyse MEPs
if isfield (results, 'MEP')==1
    %Find MEPs by Probability
    variables.Probabilities=LeftProbabilityArray;
    [MEPsbyLProbability] = sort_data_by(results.MEP, results.BlockNo, 1:TotalNumBlocks, 1:TotalNumBlocks);
    %Find MEPs by Coherence
    variables.Coherences=CoherenceArray;
    [MEPsbyCoherence] = sort_data_by(results.MEP, results.Coherence, CoherenceArray, 1:numel(CoherenceArray));
    %Find MEPs by Timepoint
    %do something here
    
    
    if plot==1
        %MEPs vs timepoints
        figure
        hold on
        bar(variables.Probabilities, MEPsbyLProbability.mean);
        errorbar(variables.Probabilities, MEPsbyLProbability.mean, MEPsbyLProbability.stddev, '.');
        title('MEPs by Probability')
        xlabel('Probability of Dots Going Left')
        ylabel('MEP')
        
        
        
    end
end



