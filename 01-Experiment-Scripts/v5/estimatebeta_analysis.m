load('C:\Users\Isobel\Copy\PhD\Code\Code-for-TMS-Decision-Experiments\01-Experiment-Scripts\v4\data\020415_Test_220251_estimatebeta.mat')
for coherenceindex = 1:numel(t_vars.CoherenceArray)
    coherence = t_vars.CoherenceArray(1, coherenceindex);
    num_correcttrials = numel((find(t_data.main(:,4)==coherence & t_data.main(:,18)==1))); %number correct trials
    num_trials = numel(find(t_data.main(:,4)==coherence)); %number of trials at that coherence
    percentcorrect(1, coherenceindex) = (num_correcttrials/num_trials);
end
plot(t_vars.CoherenceArray, percentcorrect);