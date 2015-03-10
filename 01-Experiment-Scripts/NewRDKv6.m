try
    %% Inputs
    DotRadius = 2.5; %pixels
    CoherenceArray = [100]; %percent
    StimulusDuration = 400; %ms - how long participant gets to make a response
    NumDots = 300;
    ApertureRadius = 200; %pixels; radius of circular aperture for RDK
    DotSpeed = 1775; %pixels per second
    ITIDuration = 400; %lenth of intertrial interval, milliseconds
    FixationDuration = 400; %length of fixation, milliseconds
    FixationRadius = 2.5; %pixels; radius of fixation dot
    TotalNumTrials = 5; %how many trials
    BackgroundColour = [255]; %white
    DotColour = [0 0 0]; %black
    
    %Use line below to make window transparent for debugging
        PsychDebugWindowConfiguration();
    
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
    
    data.Coherence = zeros(1, TotalNumTrials); %preallocate
    data.Direction = zeros(1, TotalNumTrials); %preallocate
    
    %allocate non-coherent positions to all dots
    Radii = rand(1, NumDots, TotalNumFrames, TotalNumTrials)*ApertureRadius; %generate some random distances from the centre of the aperture
    Angles = rand(1, NumDots, TotalNumFrames, TotalNumTrials)*360; %generate some random angles
    DotsXY(1, :, :, :) = Radii.*cosd(Angles);% fill with random X coordinates
    DotsXY(2, :, :, :) = Radii.*sind(Angles); % fill random Ys
    
    for TrialNo = 1:TotalNumTrials %find out how many nots need to be coherent on each trial
        data.Coherence(1, TrialNo) = CoherenceArray(1,(randi(numel(CoherenceArray)))); %pick a coherence at random from the Coherence Array for this trial
        data.Direction(1, TrialNo) = Directions(1, randi(numel(Directions))); %randomly allocate direction as L or R
        data.NumCoherentDots(1,TrialNo) = (data.Coherence(1,TrialNo)/100)*NumDots; %find out how many dots need to be coherent
                
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
                    DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder + Width;
                    %                     if data.Direction(1, TrialNo) == 1 %if going Right
                    %                         DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder + Width;
                    %                     elseif data.Direction(1, TrialNo) == -1 %if going Left
                    %                         DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder - Width;
                    %                     end
                    
                end
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
% check have made allowances for dotwidth throughout