%%inputs 
datafile = 'D:\TMS-EMG\Code\Code-for-TMS-Decision-Experiments\01-Experiment-Scripts\190215_Isobel_Weinberg.mat'

%% NB
%1 in the Direction variable means dots were moving left
%2 in the Direction variable means dots were moving right

%1 in the Response variable means left keypress
%2 in the Response variable means right keypress
%3 in the Response variable means Escape was pressed
%NaN in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)

load (datafile)

%% Find RTs by Probability
%indexing RTs by block is the same as indexing by Probability

% Resave probabilities in new structure
DatabyLProbability.Probabilities=LeftProbabilityArray;

for iProbability=1:TotalNumBlocks
    
    % Save reaction times by probability - each cell in cell array is a
    % probability
    % Do the same for left and right RTs 
    DatabyLProbability.ReactionTime{1,iProbability} = (results.ReactionTime(results.BlockNo == iProbability));
    DatabyLProbability.ReactionTimeLeft{1,iProbability} = (results.ReactionTime(results.Direction == 1 & results.BlockNo == iProbability)); %left
    DatabyLProbability.ReactionTimeRight{1,iProbability} = (results.ReactionTime(results.Direction == 2 & results.BlockNo == iProbability)); %right
    DatabyLProbability.MeanRT(1, iProbability) = mean(DatabyLProbability.ReactionTime{1, iProbability});
    DatabyLProbability.MeanRTLeft(1, iProbability) = mean(DatabyLProbability.ReactionTimeLeft{1, iProbability}); %left
    DatabyLProbability.MeanRTRight(1, iProbability) = mean(DatabyLProbability.ReactionTimeRight{1, iProbability}); %right
    DatabyLProbability.StandardDev(1, iProbability) = std(DatabyLProbability.ReactionTime{1, iProbability});
    DatabyLProbability.StandardDevLeft(1, iProbability) = std(DatabyLProbability.ReactionTimeLeft{1,iProbability});
    DatabyLProbability.StandardDevRight(1, iProbability) = std(DatabyLProbability.ReactionTimeRight{1,iProbability});
end


%% Find RTs by Coherence

% Resave coherences in new structure
DatabyCoherence.Coherences=CoherenceArray;

for iCoherence=1:(numel(CoherenceArray))
    
    % Save reaction times by probability - each cell in cell array is a
    % coherence
    % Do the same for left and right RTs 
    DatabyCoherence.ReactionTime{1,iCoherence} = (results.ReactionTime(results.Coherence == CoherenceArray(1,iCoherence)));
    DatabyCoherence.ReactionTimeLeft{1,iCoherence} = (results.ReactionTime(results.Direction == 1 & results.Coherence == CoherenceArray(1,iCoherence))); %left
    DatabyCoherence.ReactionTimeRight{1,iCoherence} = (results.ReactionTime(results.Direction == 2 & results.Coherence == CoherenceArray(1,iCoherence))); %right
    DatabyCoherence.MeanRT(1, iCoherence) = mean(DatabyCoherence.ReactionTime{1, iCoherence});
    DatabyCoherence.MeanRTLeft(1, iCoherence) = mean(DatabyCoherence.ReactionTimeLeft{1, iCoherence}); %left
    DatabyCoherence.MeanRTRight(1, iCoherence) = mean(DatabyCoherence.ReactionTimeRight{1, iCoherence}); %right
    DatabyCoherence.StandardDev(1, iCoherence) = std(DatabyCoherence.ReactionTime{1, iCoherence});
    DatabyCoherence.StandardDevLeft(1, iCoherence) = std(DatabyCoherence.ReactionTimeLeft{1,iCoherence});
    DatabyCoherence.StandardDevRight(1, iCoherence) = std(DatabyCoherence.ReactionTimeRight{1,iCoherence});
end

%% Plot
figure
hold on
bar(DatabyLProbability.Probabilities,DatabyLProbability.MeanRT);
errorbar(DatabyLProbability.Probabilities, DatabyLProbability.MeanRT, DatabyLProbability.StandardDev, '.');
title('Mean Reaction Time by Probability')
xlabel('Probability of Dots Going Left')
ylabel('Mean Reaction Time')


LRinterspose = zeros(TotalNumBlocks,2);
for iProbability=1:TotalNumBlocks
    LRinterspose(iProbability,1) = DatabyLProbability.MeanRTLeft(1,iProbability);
    LRinterspose(iProbability,2) = DatabyLProbability.MeanRTRight(1,iProbability);
end
figure
bar(DatabyLProbability.Probabilities,LRinterspose);

figure
hold on
bar(DatabyCoherence.Coherences,DatabyCoherence.MeanRT);
errorbar(DatabyCoherence.Coherences, DatabyCoherence.MeanRT, DatabyCoherence.StandardDev, '.');
