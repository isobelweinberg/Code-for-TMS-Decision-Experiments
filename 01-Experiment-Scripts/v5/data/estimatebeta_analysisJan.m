% load('C:\Users\Isobel\Copy\PhD\Code\Code-for-TMS-Decision-Experiments\01-Experiment-Scripts\v4\data\020415_Test_220251_estimatebeta.mat')
for coherenceindex = 1:numel(t_vars.CoherenceArray)
    coherence = t_vars.CoherenceArray(1, coherenceindex);
    num_correcttrials = numel((find(t_data_new.main(:,4)==coherence & t_data_new.main(:,18)==1))); %number correct trials
    num_trials = numel(find(t_data_new.main(:,4)==coherence)); %number of trials at that coherence
    percentcorrect(1, coherenceindex) = (num_correcttrials/num_trials);
end
% Copying http://courses.washington.edu/matlab1/Lesson_5.html
results.response = t_data_new.main(:,18);
results.intensity =  t_data_new.main(:,4);
% Fitting the curve to estimate beta and 79% threshold
pInit.t = 15; %79% threshold - prior
pInit.b = 0.03; %beta - prior
[pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},results,'Weibull');  %pBest now gives fitted beta and threshold values
% Plot curve
y = Weibull(pBest,t_vars.CoherenceArray);
figure;
plot(t_vars.CoherenceArray, percentcorrect);
hold on
plot(t_vars.CoherenceArray,y);
% Plot a smooth Weibull curve and find the threshold (change t for
% different thresholds)
x = linspace(0, 100, 1001);
smooth_weib = Weibull(pBest, x);
t = 0.7;
threshold = find(smooth_weib>t, 1);
threshold = x(threshold);