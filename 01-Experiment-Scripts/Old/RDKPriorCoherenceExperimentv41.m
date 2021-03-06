try
    
    clear all;
    sca;
    KbName('UnifyKeyNames');
    
    %% ParticipantDetails
    participant.Name='Isobel_Weinberg'; %use underscores
    participant.Age=25;
    note=''; %appears at end of filename
    
    %% Experiment Type
    option.Training = 0;
    option.TMS = 0;
    option.explicitprior = 1;
    
    %% Inputs
    DotRadius = 2.5; %pixels
    StimulusDuration = 1000; %ms - how long participant gets to make a response
    NumDots = 300;
    ApertureRadius = 200; %pixels; radius of circular aperture for RDK
    DotSpeed = 1500; %pixels per second
    MaxITIDuration = 1000; %maximum lenth of intertrial interval, milliseconds
    FixationDuration = 400; %length of fixation, milliseconds
    FixationRadius = 2.5; %pixels; radius of fixation dot
    TotalNumTrials = 10; %how many trials
    BackgroundColour = 255; %white
    DotColour = [0 0 0]; %black
    %Block Structure
    TrialsPerBlock=5;
    %Independent variables
    CoherenceArray = [5 50 95]; %percent
    LeftProbabilityArray=[10 50]; %probability the RDK goes left, as a percentage
    TMSTimepointArray = [50 100];%in ms
    
    
    %% Setup
    
    %File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    filename = strcat(date,'_',participant.Name,'_',time, note);
    
    
    %KeyNames
    %     escapeKey = KbName('ESCAPE');
    %     leftKey = KbName('LeftArrow');
    %     rightKey = KbName('RightArrow');
    %     spacebarKey = KbName('space');
    
    %Priority 1
    Priority(1);
    
    %Use line below to make window transparent for debugging
    %     PsychDebugWindowConfiguration();
    
    Screen('Preference', 'SkipSyncTests', 0)
    
    %How many blocks are there?
    TotalNumBlocks = TotalNumTrials/TrialsPerBlock;
    
    %Human error check
    if numel(LeftProbabilityArray)~=TotalNumBlocks
        DrawFormattedText(windowNo, 'Error. \n The number of blocks does not match the number of dot direction probabilities you have entered. \n Press any key', 'center', 'center', [0 0 0]);
        Screen('Flip', windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end
    
    %Make empty variable for Subject responses, RTs and RDK directions
    results.Response=zeros(1,TotalNumTrials);
    results.Direction=zeros(1,TotalNumTrials);
    results.ReactionTime=zeros(1,TotalNumTrials);
    
    % Check for filename clash - MAKE SURE THIS IS UNCOMMENTED FOR THE
    % EXPERIMENTS
    if exist([filename '.mat'], 'file')>0
        DrawFormattedText(windowNo, 'There is already a file with this name. Please check for errors.', 'center', 'center', [0 0 0]);
        Screen('Flip', windowNo);
        KbStrokeWait;
        sca;
        Priority(0);
    end
    %% Load
    % call these once to avoid a slow first iteration
    GetSecs;
    KbCheck;
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
    
    for BlockNo=1:TotalNumBlocks
        % Set Probability the dots will go left - determined by block
        data.LeftProbability(1, BlockNo) = LeftProbabilityArray(1, (randi(numel(BlockNo))));
        
        for TrialNo = 1:TotalNumTrials %find out how many nots need to be coherent on each trial
            data.Coherence(1, TrialNo) = CoherenceArray(1,(randi(numel(CoherenceArray)))); %pick a coherence at random from the Coherence Array for this trial
            data.NumCoherentDots(1,TrialNo) = (data.Coherence(1,TrialNo)/100)*NumDots; %find out how many dots need to be coherent
            if TrialNo <= (data.LeftProbability(1, BlockNo)*TrialsPerBlock/100) %allocate direction
                data.Direction(1, TrialNo) = -1; %left
            else
                data.Direction(1, TrialNo) = 1; %right
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
    
    % now we have all the coordinates for the whole experiment - all that is
    % left is to draw them!
    
    %% Draw the stimuli
    
    %Record start of experiment
    ExperimentStart=datetime;
    
    for BlockNo=1:TotalNumBlocks
        if option.explicitprior == 1
            %tell participant the prior for the next block
            message = strcat('For the next', 32, num2str(TrialsPerBlock), ' trials, the probability the dot field will be moving LEFT is \n',...
                32, num2str(data.LeftProbability(1, BlockNo)), '%, and the probability it will be moving RIGHT is', 32,...
                num2str(100-data.LeftProbability(1, BlockNo)), '%');
            LeftColour = (1*(100-data.LeftProbability(1, BlockNo))/100)*[255 255 255];
            RightColour = (1*data.LeftProbability(1, BlockNo)/100)*[255 255 255];
            RectSize = [0 0 100 100];
            offset = 150;
            LeftRect = CenterRectOnPoint(RectSize, (xmiddle-offset), (ymiddle+150));
            RightRect = CenterRectOnPoint(RectSize, (xmiddle+offset), (ymiddle+150));
            
            DrawFormattedText(windowNo, message, 'center', (ymiddle-250), [0 0 0], '', '', '', 2.5);
            Screen(windowNo,'FillRect', LeftColour, LeftRect);
            Screen(windowNo,'FillRect', RightColour, RightRect);
            DrawFormattedText(windowNo, 'Left', (xmiddle-offset), 'center', [0 0 0], '', '', '', 2.5);
            DrawFormattedText(windowNo, strcat(num2str(data.LeftProbability(1, BlockNo)), '%'), (xmiddle-offset), (ymiddle+50), [0 0 0], '', '', '', 2.5);
            DrawFormattedText(windowNo, 'Right', (xmiddle+offset), 'center', [0 0 0], '', '', '', 2.5);
            DrawFormattedText(windowNo, strcat(num2str(100-data.LeftProbability(1, BlockNo)), '%'), (xmiddle+offset), (ymiddle+50), [0 0 0], '', '', '', 2.5);
            DrawFormattedText(windowNo, 'Press any key to continue', 'center', ymiddle+300, [0 0 0], '', '', '', 2.5);
            
            Screen('Flip', windowNo);
            KbStrokeWait;
        end
        
        data.LeftProbability(1, BlockNo)
        for TrialNo=1:TotalNumTrials
            data.times.trialstart(1,TrialNo) = GetSecs;
            Screen('DrawDots', windowNo, FixationXY, 2*FixationRadius, DotColour, [xmiddle ymiddle], 1);
            data.times.fixation_onset(1,TrialNo)= Screen('Flip', windowNo); %not stimulus onset time??!!
            WaitSecs(FixationDuration/1000);
            Timestamp = GetSecs;
            KeyPress=0;
            KbQueueCreate;
            data.times.RDKstart(1,TrialNo) = GetSecs;
            KbQueueStart;
            for FrameNo=1:TotalNumFrames
                Screen('DrawDots', windowNo, DotsXY(:, :, FrameNo, TrialNo), 2*DotRadius, DotColour, [xmiddle ymiddle], 1);
                Timestamp = Screen('Flip', windowNo, Timestamp+0.5*IFI); %send flip command halfway through IFI %keep all this data??
                [KeyPress, KeyPressTime] = KbQueueCheck;
                if KeyPress ~= 0
                    break
                end
                %                   [KeyPress, KeyPressTime, KeyCode] = KbCheck
            end
            data.times.RDKend(1,TrialNo) = Timestamp;
            KbQueueStop;
            
            if min(KeyPressTime(KeyPressTime~=0)) ~= 0 %if a key was pressed
                FirstKey = KbName(KeyPressTime==(min(KeyPressTime(KeyPressTime~=0)))); %get the name of the first key pressed
            else
                FirstKey = NaN;
            end
            
            min(KeyPressTime(KeyPressTime~=0)); %find the first key to be pressed
            %store the response
            if KeyPress ~= 0
                results.ReactionTime(1,TrialNo) = min(KeyPressTime(KeyPressTime~=0)); %in ms
                if strcmp (FirstKey, 'LeftArrow') == 1 %if first key pressed was left
                    results.Response(1,TrialNo)=1; %1 in the Response variable means left keypress
                elseif strcmp (FirstKey, 'RightArrow') == 1
                    results.Response(1,TrialNo)=2; %2 in the Response variable means right keypress
                elseif strcmp (FirstKey, 'ESCAPE') == 1
                    results.Response(1,TrialNo)=3; %3 in the Response variable means Escape was pressed
                    DrawFormattedText(windowNo, 'Experiment ending because you pressed escape', 'center', 'center', [0 0 0]);
                    Screen('Flip', windowNo);
                    WaitSecs(1);
                    break
                else
                    results.Response(1,TrialNo)=4; %4 in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)
                    DrawFormattedText(windowNo, 'Experiment paused. Press any key to continue.', 'center', 'center', [0 0 0]);
                    Screen('Flip', windowNo);
                    KbStrokeWait;
                    % nb - you lose a trial whenever you do this
                end
                
                if (results.Response(1, TrialNo) == 1 && data.Direction(1, TrialNo) == -1) || (results.Response(1, TrialNo) == 2 && data.Direction(1, TrialNo) == 1) %if correct response %RATIONALISE THESE!
                    DrawFormattedText(windowNo, 'Good!', 'center', 'center', [0 0 0]);
                    data.times.Feedbackstart(1,TrialNo) = Screen('Flip', windowNo);
                elseif strcmp (FirstKey, 'ESCAPE') == 1
                    break
                elseif results.Response(1, TrialNo) == 4
                    %                     DrawFormattedText(windowNo, 'Wrong! Rememember to press the Left or Right Keys', 'center', 'center', [0 0 0]);
                    %                     data.times.Feedbackstart(1,TrialNo) = Screen('Flip', windowNo);
                else
                    DrawFormattedText(windowNo, 'Wrong!', 'center', 'center', [0 0 0]);
                    data.times.Feedbackstart(1,TrialNo) = Screen('Flip', windowNo);
                end
            elseif KeyPress == 0
                DrawFormattedText(windowNo, 'Too slow!', 'center', 'center', [0 0 0]);
                Screen('Flip', windowNo);
                results.Response(1,TrialNo)=NaN; %NaN means no response was made
                results.ReactionTime(1,TrialNo)=NaN;
            end
            WaitSecs(rand*MaxITIDuration/1000);
        end
        if TrialNo<TotalNumTrials && KeyCode(escapeKey)~=1
            DrawFormattedText(windowNo, 'Have a rest. Press any key to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip', windowNo);
            KbStrokeWait;
        else
            DrawFormattedText(windowNo, 'Experiment finished! Press any key to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip', windowNo);
            KbStrokeWait;
            break
        end
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

%%To DO

%TMS pulses!

%originating script data insert
%trials for training

%TMS in ITI - add an if ITI clause?
%some no TMS trials? or are we doing behaviour separately?

%Error message
%'too long' trial break
%fixation

%Record any errors
%Rationalise variables
%Put in TMS pulses
%Make random numbers repeatable?
%Set up github

%Training phase
%Compare to others' scripts
%button box!!

%Threshold coherences to subject!!
%Feedback!! - based on RT?

%check Jimmy and Shadlen's RDKs - directions?
%fixation

%Inputs


%should all be functions?
%make triggers variables
%make durations variables
%make colours variables
%visual angle
%allocate all coherences etc in one go?

%change all the 1, TrialNo to TrialNo??
% check have made allowances for dotwidth throughout