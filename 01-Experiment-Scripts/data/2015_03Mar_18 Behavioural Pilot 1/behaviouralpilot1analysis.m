%% Organise data
%make a matrix with the results in - (can remove this step later once have
%a better organisation of data)

%reaction time
processeddata(:,1) = results.ReactionTime; 
%RDK direction
%processeddata(:,2)
%direction moved
processeddata(:,3) = results.Response;
%coherence
processeddata(:,4) = data.Coherence;
%L probability - 4th column column
for b = 1:TotalNumBlocks
processeddata((1*b):(TrialsPerBlock*b),4) = data.LeftProbability(b);
end

%% Find mean RT
RTs = processeddata(isfinite(processeddata(:,1)));%the RT column indexed by the finite numbers of the same column - strips out the NaNs
meanRT = mean(RTs); 
scaledRTs = RTs/meanRT;

%% Find data by coherence and its means
for c = 1:numel(CoherenceArray)
    RTsbyCoherence{:,c} = processeddata((processeddata(:,4)==(CoherenceArray(1,n))),1); %RTs indexed by cth coherence 
end





