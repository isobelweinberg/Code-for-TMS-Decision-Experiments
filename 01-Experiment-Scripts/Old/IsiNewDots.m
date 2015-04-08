%% Moving RDK - 0% coherence
try
    clear all;
    sca;
    KbName('UnifyKeyNames');
    %Experimental Parameters
    TotalNumTrials=10;
    RDKWidth=200;
    DotDiameter=5;
    DotSpeed=120;%units: pixels/ms
    NumDots=150;
    Coherence=50;%as a percentage
    %KeyNames
    escapeKey = KbName('ESCAPE');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    %Priority 1
    Priority(1);    
    %Open Window and get window number
    %Use line below to make window transparent for debugging
    %PsychDebugWindowConfiguration();
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
    %Make empty variable for Subject responses and RDK directions
    Response=zeros(1,TotalNumTrials);
    Direction=zeros(1,TotalNumTrials);
   %Loop RDK calculation and presentation by no of trials
    TrialNo=1;
    for TrialNo=1:TotalNumTrials       
    %Fill dotposition matrix
    i=1;
    dotpositions=zeros(2,NumDots);
    for i=1:NumDots
        angle = rand * 360;
        distFromOrigin = rand * (RDKWidth/2);
        dotpositions(1, i) = distFromOrigin * cosd(angle);
        dotpositions(2, i) = distFromOrigin * sind(angle);
    end;
    %   create matrix of random direction of motion between 0 to 360
    dotdirections=rand(1,NumDots)*360;
    % assign coherent dots and their directions
     if Coherence ~=0
       NumCoherentDots=round((Coherence/100)*NumDots);
       CoherenceDirection=(randi([0 1])*180);
       dotdirections(1,1:NumCoherentDots)=CoherenceDirection;       
     end
    %split directions into x y vectors
    dotdirectionvectors=zeros(2,NumDots);
    dotdirectionvectors(1,:)=cosd(dotdirections);
    dotdirectionvectors(2,:)=sind(dotdirections);
   %while there is no keyboard press, draw the dots
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
       if KeyCode(leftKey)==1
              Response(1,TrialNo)=1; %1 in the Response variable means left keypress
           if CoherenceDirection==0
               Direction(1,TrialNo)=2; %2 in the Direction variable means dots were moving right
           elseif CoherenceDirection==180
               Direction(1,TrialNo)=1; %1 in the Direction variable means dots were moving left
           end
       elseif KeyCode(rightKey)==1
               Response(1,TrialNo)=2; %2 in the Response variable means right keypress
           if CoherenceDirection==0
               Direction(1,TrialNo)=2; 
           elseif CoherenceDirection==180
               Direction(1,TrialNo)=1; 
           end 
       elseif KeyCode(escapeKey)==1
           break
       end
           %need to display an error message in case of key press of
           %another key
   WaitSecs(1);
    end;   
    KbStrokeWait;
    sca;
    %Priority 0
    Priority(0);
    catch err
    disp('caught error');
    sca;
    rethrow (err); 
end;