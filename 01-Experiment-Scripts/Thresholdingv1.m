% Provide our prior knowledge to QuestCreate, and receive the data struct "q".
tGuess=[];
while isempty(tGuess)
	tGuess=input('Estimate threshold (e.g. -1): ');
end
tGuessSd=[];
while isempty(tGuessSd)
	tGuessSd=input('Estimate the standard deviation of your guess, above, (e.g. 2): ');
end
%WHAT FIGURES TO PUT IN HERE?
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
%WHAT'S THIS FOR? %q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

% fprintf('Your initial guess was %g +- %g\n',tGuess,tGuessSd);
% fprintf('Quest''s initial threshold estimate is %g +- %g\n',QuestMean(q),QuestSd(q));

% Simulate a series of trials. 
% On each trial we ask Quest to recommend an intensity and we call QuestUpdate to save the result in q.
trialsDesired=40;
wrongRight={'wrong','right'};
timeZero=eval(getSecsFunction);
for k=1:trialsDesired
	% Get recommended level.  
	tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
	
	% We are free to test any intensity we like, not necessarily what Quest suggested.
	% 	tTest=min(-0.05,max(-3,tTest)); % Restrict to range of log contrasts that our equipment can produce.
	
	
	timeSplit=eval(getSecsFunction); % Omit simulation and printing from the timing measurements.
 	% RUN THE TRIAL
 	fprintf('Trial %3d at %5.2f is %s\n',k,tTest,char(wrongRight(response+1)));
	timeZero=timeZero+eval(getSecsFunction)-timeSplit;
	
	% UPDATE THE RESULTS
    % Update the pdf
	q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
end

% Print results of timing.
fprintf('%.0f ms/trial\n',1000*(eval(getSecsFunction)-timeZero)/trialsDesired);

% Ask Quest for the final estimate of threshold.
t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',t,sd);
% t=QuestMode(q);	% Similar and preferable to the maximum likelihood recommended by Watson & Pelli (1983). 
% fprintf('Mode threshold estimate is %4.2f\n',t);
fprintf('\nYou set the true threshold to %.2f.\n',tActual);
fprintf('Quest knew only your guess: %.2f +- %.2f.\n',tGuess,tGuessSd);

%% ====================ESTIMATING BETA============================
% Optionally, reanalyze the data with beta as a free parameter.
fprintf('\nBETA. Many people ask, so here''s how to analyze the data with beta as a free\n');
fprintf('parameter. However, we don''t recommend it as a daily practice. The data\n');
fprintf('collected to estimate threshold are typically concentrated at one\n');
fprintf('contrast and don''t constrain beta. To estimate beta, it is better to use\n');
fprintf('100 trials per intensity (typically log contrast) at several uniformly\n');
fprintf('spaced intensities. We recommend using such data to estimate beta once,\n');
fprintf('and then using that beta in your daily threshold meausurements. With\n');
fprintf('that disclaimer, here''s the analysis with beta as a free parameter.\n');
QuestBetaAnalysis(q); % optional
fprintf('Actual parameters of simulated observer:\n');
fprintf('logC	beta	gamma\n');
fprintf('%5.2f	%4.1f	%5.2f\n',tActual,q.beta,q.gamma);
