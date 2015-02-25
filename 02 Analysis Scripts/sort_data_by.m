function data_organised = sort_data_by(data, independent_variable, iv_values, index_options)

for i = index_options
    data_organised.all{1, i} = data(independent_variable == iv_values(1,i)); %e.g. sort RTs by coherence
    data_organised.left{1, i} = data(results.Direction == 1 & independent_variable == iv_values(1,i)); %left
    data_organised.right{1, i} = data(results.Direction == 2 & independent_variable == iv_values(1,i)); %right
    data_organised.mean(1, i) = mean(data(data_organised.all{1,i});
    data_organised.leftmean(1, i) = mean(data(data_organised.left{1,i});
    data_organised.rightmean(1, i) = mean(data(data_organised.right{1,i});
    data_organised.stddev(1, i) = std(data(data_organised.all{1,i});
    data_organised.leftstddev(1, i) = std(data(data_organised.left{1,i});
    data_organised.rightstddev(1, i) = std(data(data_organised.right{1,i});
    
end


% [RTsbyLProbability] = sort_data_by(results.ReactionTime, results.BlockNo, 1:TotalNumBlocks, 1:TotalNumBlocks)
% 
%  
% [RTsbyCoherence] = sort_data_by(results.ReactionTime, results.Coherence, CoherenceArray, 1:numel(CoherenceArray))