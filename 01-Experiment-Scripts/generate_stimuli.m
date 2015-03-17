function [FixationXY, DotsXY, data] = generate_stimuli(NumDots, TotalNumTrials)

%Global Variables
global TotalNumFrames;
global ApertureRadius;
global TotalNumBlocks;
global LeftProbabilityArray;
global CoherenceArray;
global TMSTimepointArray;
global TrialsPerBlock;
global DotSpeed;
global DotRadius;
global IFI;
global FixationDuration;

% Prepare dot coordinates
FixationXY = [0; 0];  % fixation spot is in middle of screen
%pay attention - this is complicated! this is a vector of the dot coordinates with 4
%dimensions:
%     Dimension 1 (ROWS): x or y (i.e. top row is x and bottom row is y)
%     Dimension 2 (COLUMNS): dots (i.e. 1 column per dot)
%     Dimension 3 (Z): frames (i.e. 1 table per frame)
%     Dimension 4: trials (i.e. 1 thing impossible to imagine per trial)
DotsXY = zeros(2, NumDots, TotalNumFrames, TotalNumTrials); %preallocate

data.Coherence = zeros(1, TotalNumTrials); %preallocate
data.Direction = zeros(1, TotalNumTrials); %preallocate
data.TMSTimepoint = NaN(1, TotalNumTrials); %preallocate

%allocate non-coherent positions to all dots
Radii = rand(1, NumDots, TotalNumFrames, TotalNumTrials)*ApertureRadius; %generate some random distances from the centre of the aperture
Angles = rand(1, NumDots, TotalNumFrames, TotalNumTrials)*360; %generate some random angles
DotsXY(1, :, :, :) = Radii.*cosd(Angles);% fill with random X coordinates
DotsXY(2, :, :, :) = Radii.*sind(Angles); % fill random Ys

for BlockNo=1:TotalNumBlocks
    % Set Probability the dots will go left - determined by block
    data.LeftProbability(1, BlockNo) = LeftProbabilityArray(1, (randi(numel(BlockNo))));
    
    for TrialNo = 1:TrialsPerBlock %find out how many nots need to be coherent on each trial
        data.Coherence(1, TrialNo) = CoherenceArray(1,(randi(numel(CoherenceArray)))); %pick a coherence at random from the Coherence Array for this trial
        data.NumCoherentDots(1,TrialNo) = (data.Coherence(1,TrialNo)/100)*NumDots; %find out how many dots need to be coherent
        if TrialNo <= (data.LeftProbability(1, BlockNo)*TrialsPerBlock/100) %allocate direction
            data.Direction(1, TrialNo) = -1; %left
        else
            data.Direction(1, TrialNo) = 1; %right
        end
        
        %choose a timepoint for TMS trigger
        if option.TMS == 1 && randi(100) <= ProbabilityOfTMS %find out if this will be a TMS trial
                data.TMSTimepoint(1, TrialNo) = TMSTimepointArray(1, randi(numel(TMSTimepointArray))); %pick a random TMS point
%                 data.TMSFramepoint(1, TrialNo) = data.TMSTimepoint(1, TrialNo) - 
        end
                
        for DotNumber = 1:data.NumCoherentDots(1,TrialNo) % allocate coherent positions to a subset
            %coherent dots - their Y coord stays the same throughout
            DotsXY(2, DotNumber, 2:TotalNumFrames, TrialNo) = DotsXY(2, DotNumber, 1, TrialNo);
            %X coord incremements by a fixed amount (speed x time)
            for FrameNo = 2:TotalNumFrames
                DotsXY(1, DotNumber, FrameNo, TrialNo) = DotsXY(1, DotNumber, FrameNo-1, TrialNo) + (data.Direction(1,TrialNo)*DotSpeed*IFI);
                %is the dot outside the circle?
                y = DotsXY(2, DotNumber, FrameNo, TrialNo);
                Width = sqrt(((ApertureRadius)^2)-((y)^2));
                %Width = CircleWidth((DotsXY(2, DotNumber, FrameNo, TrialNo)), ApertureRadius); give the function the Y and the circle radius and it gives you the X coord of the circle at that point
                if abs(DotsXY(1, DotNumber, FrameNo, TrialNo)) + DotRadius > Width %if outside circle
                    if data.Direction(1, TrialNo) == -1 %if going Left, make the Width negative - need this to make the mod calc work
                        Width = -1*Width;
                    end
                    XRemainder = mod((DotsXY(1, DotNumber, FrameNo, TrialNo)), Width);
                    DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder - Width;
                    %                     if data.Direction(1, TrialNo) == 1 %if going Right
                    %                         DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder + Width;
                    %                     elseif data.Direction(1, TrialNo) == -1 %if going Left
                    %                         DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder - Width;
                    %                     end
                    
                end
            end
        end
    end
end
end




% now we have all the coordinates for the whole experiment - all that is
% left is to draw them!
