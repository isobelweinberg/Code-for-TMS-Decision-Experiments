%% Moving RDK - 0% coherence
try
    clear all;
    sca;
    %Define Variables
    RDKWidth=200;
    DotDiameter=5;
    DotSpeed=120;%units: pixels/ms
    NumDots=150;
    %Open Window and get window number
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
    %split directions into x y vectors
    dotdirectionvectors=zeros(2,NumDots);
    dotdirectionvectors(1,:)=cosd(dotdirections);
    dotdirectionvectors(2,:)=sind(dotdirections);
   %while there is no keyboard press, draw the dots
   ifi=Screen('GetFlipInterval', windowNo);
   time=0;
   timestamp=Screen('Flip', windowNo);
   latestdotpositions=dotpositions;
   while ~KbCheck
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
   end
   %coherence
   %anti-aliasing
    KbStrokeWait;
    sca;
    catch err
    disp('caught error');
    sca;
    rethrow (err); 
end;