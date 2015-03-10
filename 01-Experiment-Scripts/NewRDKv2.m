try
    
    %% Inputs
    DotRadius = 2.5; %pixels
    CoherenceArray = [100]; %percent
    StimulusDuration = 400; %ms - how long participant gets to make a response
    NumDots = 300;
    ApertureRadius = 200; %pixels; radius of circular aperture for RDK
    DotSpeed = 120; %pixels per second
    ITIDuration = 400; %lenth of intertrial interval, milliseconds
    FixationDuration = 400; %length of fixation, milliseconds
    FixationRadius = 2.5; %pixels; radius of fixation dot
    TotalNumTrials = 5; %how many trials
    BackgroundColour = [255]; %white
    DotColour = [0 0 0]; %black
    
    %Use line below to make window transparent for debugging
    %     PsychDebugWindowConfiguration();
    
    %% Load
    % call these once to avoid a slow first iteration
    GetSecs;
    % also outportb
    
    %Seed the random number generator
    rng('shuffle'); %modern
    %     rand('seed', sum(100 * clock)); %legacy
    
    Directions = [-1, 1];
    conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
    
    %% Open a window
    windowNo = Screen('OpenWindow', 0, BackgroundColour);%0 is the main
    Screen('BlendFunction', windowNo, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' ); %anti-aliasing
    RefreshRate = Screen('FrameRate', windowNo); %in Hz; PTB asks the screen what its refresh rate is
    TotalNumFrames = ceil((StimulusDuration/1000)*RefreshRate); %this is how many frames we need for the stimulus
    IFI = 1/RefreshRate; %interframe interval, seconds
    
    %Find the middle of the screen
    middlerect = Screen('Rect',windowNo);
    xmiddle=middlerect(1,3)*0.5;
    ymiddle=middlerect(1,4)*0.5;
    
    %% Prepare dot coordinates
    FixationXY = [0; 0];  % fixation spot is in middle of screen
    %pay attention - this is complicated! this is a vector of the dot coordinates with 4
    %dimensions:
    %     Dimension 1 (ROWS): x or y (i.e. top row is x and bottom row is y)
    %     Dimension 2 (COLUMNS): dots (i.e. 1 column per dot)
    %     Dimension 3 (Z): frames (i.e. 1 table per frame)
    %     Dimension 4: trials (i.e. 1 thing impossible to imagine per trial)
    DotsXY = zeros(2, NumDots, TotalNumFrames, TotalNumTrials); %preallocate
    Radii = rand(1, NumDots, TotalNumFrames, TotalNumTrials)*ApertureRadius; %generate some random distances from the centre of the aperture
    Angles = rand(1, NumDots, TotalNumFrames, TotalNumTrials)*360; %generate some random angles
    DotsXY(1, :, :, :) = Radii.*cosd(Angles);% fill with random X coordinates
    DotsXY(2, :, :, :) = Radii.*sind(Angles); % fill random Ys
    
    %Generate coherent dots
    %some coordinates need to be replaced with correlated ones to generate the coherence
    data.Coherence = zeros(1, TotalNumTrials); %preallocate
    data.Direction = zeros(1, TotalNumTrials); %preallocate
    for TrialNo = 1:TotalNumTrials
        data.Coherence(1, TrialNo) = CoherenceArray(1,(randi(numel(CoherenceArray)))); %pick a coherence at random from the Coherence Array for this trial
        data.Direction(1, TrialNo) = Directions(1, randi(numel(Directions))); %randomly allocate direction as L or R
        data.NumCoherentDots(1,TrialNo) = (data.Coherence(1,TrialNo)/100)*NumDots; %find out how many dots need to be coherent
        for DotNumber = 1:data.NumCoherentDots(1,TrialNo)
            for FrameNo = 2:TotalNumFrames
                DotsXY(1, DotNumber, FrameNo, TrialNo) = DotsXY(1, DotNumber, FrameNo-1, TrialNo) + data.Direction(1,TrialNo)*DotSpeed*IFI;
                DotsXY(2, DotNumber, FrameNo, TrialNo) = DotsXY(2, DotNumber, FrameNo-1, TrialNo);
                Angles(1, DotNumber, FrameNo, TrialNo) = Angles(1, DotNumber, FrameNo-1, TrialNo);
%                 DotsXY(1, DotNumber, FrameNo, TrialNo) = mod(DotsXY(1, DotNumber, FrameNo-1, TrialNo) + (data.Direction(1,TrialNo)*DotSpeed*IFI), ApertureRadius) - ApertureRadius ;
                %this advances the dots by a fixed distance in the X
                %direction compared to the previous frame
                %the direction is either a positive or a negative multiplier
                %Y coordinate stays the same
%                 if abs(DotsXY(1, DotNumber, FrameNo, TrialNo)) + DotRadius > ApertureRadius*cosd(Angles(1, DotNumber, FrameNo, TrialNo)) == 1
%                 end
                %add the radius to the x coordinate, and compare this to the
                %x coordinate of the perimeter of the aperture (for that
                %angle) -> get the modulus of this
                %subtract the radius away from the modulus
                %all this basically means that a dot inside the circle stays
                %where it is and one outside reappears on the opposite side
                %with an offset equal to the amount it was outside by
                circleWidth = abs(ApertureRadius*cosd(Angles(1, DotNumber, FrameNo, TrialNo)));
                DotsXY(1, DotNumber, FrameNo, TrialNo) = mod((DotsXY(1, DotNumber, FrameNo, TrialNo)) + circleWidth, circleWidth*2 ) - circleWidth;
                
            end
        end
    end
    % now we have all the coordinates for the whole experiment - all that is
    % left is to draw them!
    
    %% Draw the stimuli
    for TrialNo=1:TotalNumTrials
        data.times.trialstart(1,TrialNo) = GetSecs;
        Screen('DrawDots', windowNo, FixationXY, 2*FixationRadius, DotColour, [xmiddle ymiddle], 1);
        data.times.fixation_onset(1,TrialNo)= Screen('Flip', windowNo); %not stimulus onset time??!!
        WaitSecs(FixationDuration/1000);
        Timestamp = GetSecs;
        data.times.RDKstart(1,TrialNo) = GetSecs;
        for FrameNo=1:TotalNumFrames
            Screen('DrawDots', windowNo, DotsXY(:, :, FrameNo, TrialNo), 2*DotRadius, DotColour, [xmiddle ymiddle], 1);
            Timestamp = Screen('Flip', windowNo, Timestamp+0.5*IFI); %send flip command halfway through IFI %keep all this data??
            %look for a response! - copy from old script
        end
        data.times.RDKend(1,TrialNo) = Timestamp; %not quite accurate?
        %loop for feedback
        %temporary feedback
        DrawFormattedText(windowNo, 'Good!', 'center', 'center', [0 0 0]);
        data.times.Feedbackstart(1,TrialNo) = Screen('Flip', windowNo);
        WaitSecs(ITIDuration/1000);
    end
    %% Finish
    sca;
    Priority(0);
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end
%change all the 1, TrialNo to TrialNo??