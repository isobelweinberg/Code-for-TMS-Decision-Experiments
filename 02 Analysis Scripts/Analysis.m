%1 in the Direction variable means dots were moving left
%2 in the Direction variable means dots were moving right

%1 in the Response variable means left keypress
%2 in the Response variable means right keypress
%3 in the Response variable means Escape was pressed
%NaN in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)

load D:\TMS-EMG\Kinetograms-Code\190215_Isobel_Weinberg.mat

%% Find RTs by Probability
%indexing RTs by block is the same as indexing by Probability


RTsbyLProbability=cell(7,TotalNumBlocks); %create empty variable

for i=1:TotalNumBlocks 
    %find the probability in this block and assign to TOP ROW of RTsbyLProbability
    RTsbyLProbability{1,i}=LeftProbabilityArray(1,i);
     
    %take all the elements of Reaction Time where BlockNo==i
    %assign this to the SECOND ROW of RTsbyLProbability
   
    % RTs.(strcat('Block',num2str(i))) = results.ReactionTime(results.BlockNo == i); 
    RTsbyLProbability{2,i} = results.ReactionTime(results.BlockNo == i); 
    
    %assign meant RTs to the THIRD ROW of RTsbyLProbability
    RTsbyLProbability{3,i} = mean(RTsbyLProbability{2,i});
    
    %assign Leftward RTs to the FOURTH ROW and Rightward RTs to the SIXTH
    %ROW
    %nb direction here refers to the direction of the stimulus, not the
    %response
    RTsbyLProbability{4,i} = results.ReactionTime(results.Direction == 1 & results.BlockNo == i); %left
    RTsbyLProbability{6,i} = results.ReactionTime(results.Direction == 2 & results.BlockNo == i); %right
    
    %mean Leftward RT in the FIFTH ROW and mean Rightward RT in the SEVENTH
    %ROW
    RTsbyLProbability{5,i} = mean(RTsbyLProbability{4,i}); %Left
    RTsbyLProbability{7,i} = mean(RTsbyLProbability{6,i}); %Right
    
end

%% Find RTs by Coherence

RTsbyCoherence=cell(7,numel(CoherenceArray)); %create emptyvariable

% j=CoherenceArray(1,1);

for j=1:(numel(CoherenceArray))
    %make the coherence array the TOP ROW of RTsbyCoherence
    RTsbyCoherence{1,j} = CoherenceArray(1,j);
    
    %take all the elements of Reaction Time where Coherence==j
    %assign this to the SECOND ROW of RTsbyLProbability
    RTsbyCoherence{2,j} = results.ReactionTime(results.Coherence == CoherenceArray(1,j));

    %assign meant RTs to the THIRD ROW of RTsbyCoherence
    RTsbyCoherence{3,j} = mean(RTsbyCoherence{2,j});
    
    %assign Leftward RTs to the FOURTH ROW and Rightward RTs to the SIXTH
    %ROW
    %nb direction here refers to the direction of the stimulus, not the
    %response
    RTsbyCoherence{4,j} = results.ReactionTime(results.Direction == 1 & results.Coherence == CoherenceArray(1,j)); %left
    RTsbyCoherence{6,j} = results.ReactionTime(results.Direction == 2 & results.Coherence == CoherenceArray(1,j)); %right
    
    %mean Leftward RT in the FIFTH ROW and mean Rightward RT in the SEVENTH
    %ROW
    RTsbyCoherence{5,j} = mean(RTsbyCoherence{4,j}); %Left
    RTsbyCoherence{7,j} = mean(RTsbyCoherence{6,j}); %Right
end

%% Plot
bar(RTsbyCoherence(1,:),RTsbyCoherence(3,:));
