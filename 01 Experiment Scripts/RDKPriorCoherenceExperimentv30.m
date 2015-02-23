%% Moving RDK - 0% coherence
  try
    
    clear all;
    sca;
    KbName('UnifyKeyNames');
 
    %% ParticipantDetails
    participant.Name='Isobel_Weinberg'; %use underscores
    participant.Age=25;
    
    %% Experiment Type
    option.Training = 0;
    option.TMS = 1;
    
    %% TMS Parameters
    TMS.dly = 1000; %TMS timepoint relative to stimulus parameters
    TMS.intl = 2;
    TMS.pre_rec = 100; %how many ms before TMS pulse to start recording
    TMS.port = 3; %which bit in the parallel port the TMS is taking orders from - FIND THIS OUT! 
    TMS.triggerport = 1; %which bit in the parallel port the TMS talks to the trigger computer - FIND THIS OUT! 
    
    %% Experimental Parameters
    TotalNumTrials=10;
    RDKWidth=200;
    DotDiameter=5;
    DotSpeed=120;%units: pixels/ms
    NumDots=150;
    CoherenceArray=[20 40 50 60 70];%array of coherences you want to use, as a percentage
    LeftProbabilityArray=[50]; %probability the RDK goes left, as a percentage
    TrialsPerBlock=10; 
    %FixedDuration=1; %1 for yes, 0 for no
    %FixedDurationLengths=[400 1000]   
   
    %% Setup
    
    %File Name
    formatOut = 'ddmmyy';
    date = datestr(now,formatOut);
    filename = strcat(date,'_',participant.Name);
    
          
    %KeyNames
    escapeKey = KbName('ESCAPE');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    
    %Priority 1
    Priority(1);    
    
    %Use line below to make window transparent for debugging
    %PsychDebugWindowConfiguration();
    
    Screen('Preference', 'SkipSyncTests', 0)
    
    [windowNo, rect1] = Screen('OpenWindow', 0, [255 255 255]);
         
    %for anti-aliasing
    Screen('BlendFunction', windowNo, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %Find middle of window
    middlerect=Screen('Rect',windowNo);
    xmiddle=middlerect(1,3)*0.5;
    ymiddle=middlerect(1,4)*0.5;
    
    %Create aperture of 50x50px centred on middle
    aperture=[0 0 RDKWidth RDKWidth];
    aperture=CenterRectOnPoint(aperture,xmiddle,ymiddle);
    
    %Seed the random number generator
    rng('shuffle');
    
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
   
     
    if option.TMS == 1
        %startportb(888); %???does this function exist?
        start_cogent;
    end
    
    % Check for filename clash - MAKE SURE THIS IS UNCOMMENTED FOR THE
    % EXPERIMENTS
%     if exist([filename '.mat'], 'file')>0
%         DrawFormattedText(windowNo, 'There is already a file for this participant and date. Please check for errors.', 'center', 'center', [0 0 0]);
%         Screen('Flip', windowNo);
%         KbStrokeWait;
%         sca;
%         Priority(0);
%     end
        
 %% Present the Stimuli
     
   
   %Loop RDK calculation and presentation by no of trials
   
    BlockNo=1;
    TrialNo=0; %where we are in terms of total trials in the experiment
    
    % BLOCK LOOP
    for BlockNo=1:TotalNumBlocks
          % Set Probability the dots will go left - determined by block
            LeftProbability = LeftProbabilityArray(1,BlockNo);
        
         % Set a certain proportion of trials to be L or R, as determined by the probability parameter
            CoherenceDirection=zeros(1,TotalNumTrials);
            LeftwardTrials=(LeftProbability/100)*TotalNumTrials;
            OrderOfTrials=randperm(TotalNumTrials);
            for j=1:LeftwardTrials
                CoherenceDirection(1,(OrderOfTrials(1,j)))=180;
            end
             
    TrialInBlockNo=1; %where we are in terms of trials in the block
        
    % TRIAL LOOP
    for TrialInBlockNo=1:TrialsPerBlock
        
    % Increment trial number
    TrialNo=TrialNo+1;
        
    %Fill dotposition matrix
    i=1;
    dotpositions=zeros(2,NumDots);
    for i=1:NumDots
        angle = rand * 360;
        distFromOrigin = rand * (RDKWidth/2);
        dotpositions(1, i) = distFromOrigin * cosd(angle);
        dotpositions(2, i) = distFromOrigin * sind(angle);
    end;
        
    % Set Coherence for this Trial - a random one from the CoherenceArray
    n = numel (CoherenceArray); 
    p = randperm(n);
    Coherence=CoherenceArray(1,(p(1,1)));
    
    % store this trial's coherence in the results structure
    results.Coherence(1,TrialNo)=Coherence; 
    
     % store this trial's block no in the results structure
    results.BlockNo(1,TrialNo)=BlockNo; 
    
    % assign coherent dots and their directions
    NumCoherentDots=round((Coherence/100)*NumDots); %how many dots of the total are going to be coherent
          
    %determine directions
    dotdirections=rand(1,NumDots)*360; %   create matrix of random direction of motion between 0 to 360
    %make some dots left or rightgoing, up to the total number of coherent dots
    dotdirections(1,1:NumCoherentDots)=CoherenceDirection(1,TrialNo);
    
    %split directions into x y vectors
    dotdirectionvectors=zeros(2,NumDots);
    dotdirectionvectors(1,:)=cosd(dotdirections);
    dotdirectionvectors(2,:)=sind(dotdirections);
    
   latestdotpositions=dotpositions; %we'll use this in the loop
    
   %Timing stuff
   FlipInterval=Screen('GetFlipInterval', windowNo);% Find the interval between flips
   %time=0;
   Timestamp=Screen('Flip', windowNo);
   
   %Draw the first frame, and make a 'StimulusOnset' variable to use in the
   %RT calculation
   Screen('DrawDots', windowNo, dotpositions, DotDiameter, [0 0 0],...
           [xmiddle ymiddle], 1); 
   [Timestamp, StimulusOnset]=Screen('Flip', windowNo, Timestamp+(0.5*FlipInterval)); 
     
   %Draw the RDK until keypress  
   KeyPress=0;            
   while KeyPress==0
       distance=DotSpeed.*FlipInterval; %each frame, the dots move a constant distance - their speed x the frame interval
       latestdotpositions=latestdotpositions+(dotdirectionvectors.*distance); %update their positions according to the distance (i.e. a constant increment each loop)
       
       %find any dots that have gone outside the edge of the circle, and
       %give them new random angles and directions
       %SHOULD THIS BE RANDOM OR SHOULD THEY REAPPEAR OPPOSITE WHERE THEY
       %DISAPPEARED??
       reset=sqrt((latestdotpositions(1,:).^2)+(latestdotpositions(2,:).^2))...
           >(RDKWidth/2);
       nreset=sum(reset);
       angle = rand(1, nreset) * 360;
       distFromOrigin = rand(1, nreset) * (RDKWidth/2);
       latestdotpositions(1, reset)=distFromOrigin.*cosd(angle);
       latestdotpositions(2, reset)=distFromOrigin.*sind(angle);         
       
       Screen('DrawDots', windowNo, latestdotpositions, DotDiameter, [0 0 0],...
           [xmiddle ymiddle], 1); 
       %flip the screen at timestamp plus half a flipinterval. Update the
       %'timestamp' variable with the time of this flip.
       [Timestamp]=Screen('Flip', windowNo, Timestamp+(0.5*FlipInterval)); 
       %time=time+ifi;
       
        %Give a TMS pulse
     
        % send a TMS trigger - WILL HAVING THIS HERE SLOW DOWN THE FLIPS? I THINK SO!
    if option.TMS == 1 && Timestamp == (StimulusOnset + TMS.dly - TMS.pre_rec) %is this still going to work if flips get missed?
           
       %start recording
       outportb(888, 2^TMS.triggerport);
       wait(1); 
       outportb(888, 0);
    end
       
    if option.TMS == 1 && Timestamp == (StimulusOnset + TMS.dly)
       
       %TMS pulse
       outportb(888, 2^TMS.port);
       wait (1); %duration of pulse in number of milliseconds
       outportb(888, 0);
    end
          
       %For screenshotting:
%        imageArray = Screen('GetImage', windowNo);
%        imwrite(imageArray, 'examplestimulus.jpg')
           
       [KeyPress, KeyPressTime, KeyCode] = KbCheck;
   end
   
%% Collect the results
    results.ReactionTime(1,TrialNo)=(KeyPressTime-StimulusOnset)*1000;%in ms; maybe make it flip start...


       if KeyCode(leftKey)==1
              results.Response(1,TrialNo)=1; %1 in the Response variable means left keypress
           if CoherenceDirection(1,TrialNo)==0
               results.Direction(1,TrialNo)=2; %2 in the Direction variable means dots were moving right
           elseif CoherenceDirection(1,TrialNo)==180
               results.Direction(1,TrialNo)=1; %1 in the Direction variable means dots were moving left
           end
       elseif KeyCode(rightKey)==1
               results.Response(1,TrialNo)=2; %2 in the Response variable means right keypress
           if CoherenceDirection(1,TrialNo)==0
               results.Direction(1,TrialNo)=2; 
           elseif CoherenceDirection(1,TrialNo)==180
               results.Direction(1,TrialNo)=1; 
           end 
       elseif KeyCode(escapeKey)==1
           break
       end
           %need to display an error message in case of key press of
           %another key
   WaitSecs(rand+0.7); %jittered intertrial interval between 0.7 and 1.7s
   
  %SHOULD THE DOTS NOT OVERLAP??
     
    end
   if TrialNo<TotalNumTrials
    DrawFormattedText(windowNo, 'Have a rest. Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', windowNo);
    KbStrokeWait;
   else
    DrawFormattedText(windowNo, 'Experiment finished! Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', windowNo);
    KbStrokeWait;
   end
    end   
%% Finish off
    sca;
    %Priority 0
    Priority(0);
       
    save (filename);
    
    if option.TMS == 1
        stop_cogent;
    end
    
    catch err
    disp('caught error');
    sca;
    rethrow (err); 
  end
%%To DO

%originating script data insert
%trials for training
%TMS pulses!
%multiple pulses

%Fixed duration experiment

%Error message
%'too long' trial break

%Record any errors
%Rationalise variables
%Put in TMS pulses
%Make random numbers repeatable?
%Set up github

%Training phase
%Compare to others' scripts
%button box!!