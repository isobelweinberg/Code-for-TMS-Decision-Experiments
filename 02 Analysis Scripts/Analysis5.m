%% NB
%1 in the Direction variable means dots were moving left
%2 in the Direction variable means dots were moving right

%1 in the Response variable means left keypress
%2 in the Response variable means right keypress
%3 in the Response variable means Escape was pressed
%NaN in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)

load D:\TMS-EMG\Kinetograms-Code\190215_Isobel_Weinberg.mat

%% Find RTs by Probability
%indexing RTs by block is the same as indexing by Probability

% Resave probabilities in new structure
DatabyLProbability.Probabilities=LeftProbabilityArray;

for iProbability=1:TotalNumBlocks
    
    % Save reaction times by probability - columns are probabilities
    % Do the same for left and right RTs
    DatabyLProbability.ReactionTime(:,iProbability) = (results.ReactionTime(results.BlockNo == iProbability)');
    DatabyLProbability.ReactionTime{1, iProbability} = (results.ReactionTime(results.BlockNo == iProbability)'); % THIS ONE PLEASE
    DatabyLProbability.MeanRT(1, iProbability) = mean(DatabyLProbability.ReactionTime{iProbability});
%     DatabyLProbability.ReactionTimeLeft(:,i) = (results.ReactionTime(results.Direction == 1 & results.BlockNo == i)'); %left
%     DatabyLProbability.ReactionTimeRight(:,i) = (results.ReactionTime(results.Direction == 2 & results.BlockNo == i)'); %right
    
end

% Calculate means for overall, left and right RTs
DatabyLProbability.MeanRT = mean(DatabyLProbability.ReactionTime,1);
% DatabyLProbability.MeanRTLeft = mean(DatabyLProbability.ReactionTimeLeft,1); %left
% DatabyLProbability.MeanRTRight = mean(DatabyLProbability.ReactionTimeRight,1);%right


%% Find RTs by Coherence

% Save coherences in new structure
DatabyCoherence.Coherences=CoherenceArray;

for j=1:(numel(CoherenceArray))
    
% Save reaction times by coherence - columns are coherences
% Do the same for left and right RTs
% DatabyCoherence.ReactionTime(:,j) = (results.ReactionTime(results.Coherence == CoherenceArray(1,j))');
% DatabyCoherence.ReactionTimeLeft(:,j) = (results.ReactionTime(results.Direction == 1 & results.Coherence == CoherenceArray(1,j))'); %left
% DatabyCoherence.ReactionTimeRight(:,j) = (results.ReactionTime(results.Direction == 2 & results.Coherence == CoherenceArray(1,j))'); %right
    
end

% Calculate means for overall, left and right RTs
DatabyCoherence.MeanRT = mean(DatabyCoherence.ReactionTime,1);
% DatabyCoherence.MeanRTLeft = mean(DatabyCoherence.ReactionTimeLeft,1); %left
% DatabyCoherence.MeanRTRight = mean(DatabyCoherence.ReactionTimeRight,1);%right

%% Plot
bar(DatabyLProbability.Probabilities,DatabyLProbability.MeanRT);
