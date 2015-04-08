%% Fig 1 - Reaction Time By Coherence
% Find mean RT
meanRT = nanmean(results.ReactionTime); %find meanr RT, ignoring NaNs

% Sort RTs by Coherence
for i = 1:numel(CoherenceArray)
    index = find (data.Coherence == CoherenceArray(i));
    RTbyCoherence{1,i} = results.ReactionTime(index); %sorts data into a cell array by coherences
    RTmeansbyCoherence(1,i) = nanmean(databyCoherence{1,i}); %means of each coherence, ignoring NaNs
    RTsdbyCoherence(1,i) = nanstd(databyCoherence{1,i}); %sds of each coherence, ignoring NaNs
end

%Scale RTs to mean RT
scaledmeanRTbyCoherence = RTmeansbyCoherence/meanRT; 

%Plot
figure 
bar(CoherenceArray, scaledmeanRTbyCoherence)
hold on
errorbar(CoherenceArray, scaledmeanRTbyCoherence, RTsdbyCoherence, '.')
%% Fig 2 - Reaction Time By Prior
for k = 1:TotalNumBlocks
    RTsbyProbability{1,k} = results.ReactionTime((1*k):(TrialsPerBlock*k));
    RTmeansbyProbability(1,k) = nanmean(RTsbyProbability{1,k});
    RTsdbyProbability(1, k) = nanstd(RTsbyProbability{1,k});
    %     Probabilities = LeftProbabilityArray(1, (data.ProbabilityOrder(1, k)));
end

scaledmeanRTbyProbability = RTmeansbyProbability/meanRT;

figure 
bar((LeftProbabilityArray(data.ProbabilityOrder)), scaledmeanRTbyProbability)
hold on
errorbar((LeftProbabilityArray(data.ProbabilityOrder)), scaledmeanRTbyProbability,  RTsdbyProbability)
%NB Left ProbabilityArray gives the blocks but not the order they were
%delivered in, so need to index by the ProbabilityOrder


