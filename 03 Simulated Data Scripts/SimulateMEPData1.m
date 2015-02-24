try
    %% Inputs
    CoherenceArray
    ProbabilityArray
    TimepointsArray
    
    %%
    rng('shuffle');
    
    %Upper Threshold
    UpperThreshold=10; %chosen for no particular reason
    
    BlockNo=1;
    TrialNo=0;
    
    for BlockNo = 1:TotalNumBlocks
        %choose a probability for the block
        ProbIndex=randi(numel(ProbabilityArray));
        PriorProbability=ProbabilityArray(1,ProbIndex)
        
        for TrialNo = 1:TrialsPerBlock
            
            %increment the trial number
            TrialNo=TrialNo+1;
            
            %choose a coherence for the trial
            CoherenceIndex=randi(numel(CoherenceArray));
            Coherence=CoherenceArray(1,CoherenceIndex);
            
            %Noise functions
            RiseNoise = randn;
            LowerThresholdNoise = randn;
            UpperThresholdNoise = randn;
            SamplingNoise = randn;
            
            %% Calculating Parameters
            RateOfRise = Coherence+RiseNoise;
            StartingThreshold = PriorProbability+ LowerThresholdTNoise;
            CurrentActivity = StartingThreshold+(RateofRise*Time);
            
            %choose a timepoint for the trial
            TimepointIndex=randi(numel(TimepointArray));
            Timepoint=TimepointArray(1,TimepointIndex);
            
            time=Timepoint;
            MEP=CurrentActivity + SamplingNoise;
            
            %store results
            results.BlockNo(1,TrialNo)=BlockNo;
            results.Coherence(1,TrialNo)=Coherence;
            results.Timepoint(1,TrialNo)=Timepoint;
            results.MEP(1,TrialNo)=MEP;
                    
            
        end
    end
     %% Plot
     
     
    
catch err
    disp('caught error');
    sca;
    rethrow (err);
    
end