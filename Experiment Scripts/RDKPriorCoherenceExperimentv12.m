%% Moving RDK - 0% coherence
  try
    
    clear all;
    sca;
    KbName('UnifyKeyNames');
    
    %% Experimental Parameters
    TotalNumTrials=10;
    RDKWidth=200;
    DotDiameter=5;
    DotSpeed=120;%units: pixels/ms
    NumDots=150;
    CoherenceArray=[100];%array of coherences you want to use, as a percentage
    LeftProbabilityArray=[100 100 100 100 100 100 100 100 100 100]; %probability the RDK goes left, as a percentage
    TrialsPerBlock=1; 
   
   
    %% Setup
    %KeyNames
    escapeKey = KbName('ESCAPE');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    
    %Priority 1
    Priority(1);    
    
    %Use line below to make window transparent for debugging
    PsychDebugWindowConfiguration();
    
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
    if numel(LeftProbabilityArray)~=TotalNumBlocks;
       DrawFormattedText(windowNo, 'Error. \n The number of blocks does not match the number of dot direction probabilities you have entered. \n Press any key', 'center', 'center', [0 0 0]);
       Screen('Flip', windowNo);
       KbStrokeWait;
       sca;
       Priority(0);
    end
               
    %Make empty variable for Subject responses and RDK directions
    Response=zeros(1,TotalNumTrials);
    Direction=zeros(1,TotalNumTrials);
    
   
    
    
 %% Present the Stimuli
 
   %Loop RDK calculation and presentation by no of trials
    BlockNo=1;
    
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
    TrialNo=0; %where we are in terms of total trials in the experiment
    
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
    
   
   ifi=Screen('GetFlipInterval', windowNo);
   time=0;
   timestamp=Screen('Flip', windowNo);
   latestdotpositions=dotpositions;
   
   %Draw the RDK until keypress  
   KeyPress=0;            
   while KeyPress==0
       distance=DotSpeed.*ifi;
       latestdotpositions=latestdotpositions+(dotdirectionvectors.*distance);
       reset=sqrt((latestdotpositions(1,:).^2)+(latestdotpositions(2,:).^2))...
           >(RDKWidth/2);
       nreset=sum(reset);
       angle = rand(1, nreset) * 360;
       distFromOrigin = rand(1, nreset) * (RDKWidth/2);
       latestdotpositions(1, reset)=distFromOrigin.*cosd(angle);
       latestdotpositions(2, reset)=distFromOrigin.*sind(angle);         
       Screen('DrawDots', windowNo, latestdotpositions, DotDiameter, [0 0 0],...
           [xmiddle ymiddle], 1);
       Screen('Flip', windowNo, timestamp+(0.5*ifi));
       time=time+ifi;
       [KeyPress, KeyPressTime, KeyCode] = KbCheck;
   end
   
%% Collect the results
       if KeyCode(leftKey)==1
              Response(1,TrialNo)=1; %1 in the Response variable means left keypress
           if CoherenceDirection(1,TrialNo)==0
               Direction(1,TrialNo)=2; %2 in the Direction variable means dots were moving right
           elseif CoherenceDirection(1,TrialNo)==180
               Direction(1,TrialNo)=1; %1 in the Direction variable means dots were moving left
           end
       elseif KeyCode(rightKey)==1
               Response(1,TrialNo)=2; %2 in the Response variable means right keypress
           if CoherenceDirection(1,TrialNo)==0
               Direction(1,TrialNo)=2; 
           elseif CoherenceDirection(1,TrialNo)==180
               Direction(1,TrialNo)=1; 
           end 
       elseif KeyCode(escapeKey)==1
           break
       end
           %need to display an error message in case of key press of
           %another key
   WaitSecs(0.5);
   
   %are the dots clustering in the centre?
    
    
   %Have a break if we're at a whole number of blocks
   %PositionInBlock=TrialNo/TrialsPerBlock; 
   %if round(PositionInBlock)==PositionInBlock
    %  TrialNo=TrialNo+1;
     % break
   %end
   
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
%% Finish off
    KbStrokeWait;
    sca;
    %Priority 0
    Priority(0);
    catch err
    disp('caught error');
    sca;
    rethrow (err); 
  end
%%To DO
%Change prior by block
%Jitter intertrial interval
%Save the results
%Error message
%Record reaction time
%Record block number?
%Record any errors
%Rationalise variables
%Put in TMS pulses
%Make random numbers repeatable?
%Setup github
%Fixed duration experiment
% Compare to others' scripts
