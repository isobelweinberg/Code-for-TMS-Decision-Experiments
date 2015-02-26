try
    %% Inputs
    CoherenceArray = [5 10 15 30 60]
    LeftProbabilityArray = [10 30 50]
    TimepointArray = [90 140 220] %in ms after onset of stimulus
    TrialsPerBlock = 50
    TotalNumBlocks = 5
    
     rng('shuffle');
    
    %Upper Threshold
    UpperThreshold=10; %chosen for no particular reason
    
    BlockNo=1;
    TrialNo=0;
    
    for BlockNo = 1:TotalNumBlocks
        %choose a probability for the block
        ProbIndex=randi(numel(LeftProbabilityArray));
        PriorProbability=LeftProbabilityArray(1,ProbIndex);
        
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
            
            %choose a timepoint for the trial
            TimepointIndex=randi(numel(TimepointArray));
            Timepoint=TimepointArray(1,TimepointIndex);
            
            time=Timepoint;
                        
            %% Calculating Parameters
            RateOfRise = Coherence+RiseNoise;
            StartingThreshold = PriorProbability + LowerThresholdNoise;
            CurrentActivity = StartingThreshold+(RateOfRise*time);
            
            MEP=CurrentActivity + SamplingNoise;
            Direction = randi(2);
                       
            %store results
            results.BlockNo(1,TrialNo)=BlockNo;
            results.Coherence(1,TrialNo)=Coherence;
            results.Timepoint(1,TrialNo)=Timepoint;
            results.MEP(1,TrialNo)=MEP;
            results.Direction=Direction;
                    
            
        end
    end
       
     
    
catch err
    disp('caught error');
    sca;
    rethrow (err);
    
end