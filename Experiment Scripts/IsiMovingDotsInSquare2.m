%% Moving RDK - 0% coherence
try
    clear all;
    sca;
    %Define Variables
    RDKWidth=400;
    DotDiameter=3;
    DotSpeed=100;%units: pixels/ms
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
    dotpositions=zeros(2,100);
    %dotpositions=aperture(1,1)+(rand(2, 100)*RDKWidth);
    %dotpositions(3:4, :) = dotpositions(1:2, :) + DotDiameter;
    for i=1:100;
        dotpositions(1,i)=(rand*RDKWidth); 
        dotpositions(2,i)=(rand*RDKWidth);
%         dotpositions(3,i)= dotpositions(1,i)+DotDiameter;
%         dotpositions(4,i)= dotpositions(2,i)+DotDiameter;
    end;
      
%   create matrix of random direction of motion between 0 to 360
    dotdirections=rand(1,100)*360;
    %split directions into x y vectors
    dotdirectionvectors=zeros(2,100);
    dotdirectionvectors(1,:)=sind(dotdirections);
%     dotdirectionvectors(3,:)=sind(dotdirections);
    dotdirectionvectors(2,:)=cosd(dotdirections);
%     dotdirectionvectors(4,:)=cosd(dotdirections);  
   %while there is no keyboard press, draw the dots
   ifi=Screen('GetFlipInterval', windowNo);
   time=0;
   timestamp=Screen('Flip', windowNo);
   latestdotpositions=dotpositions;
   while ~KbCheck
       distance=DotSpeed.*ifi;
       latestdotpositions=latestdotpositions+(dotdirectionvectors.*distance);
       reset=latestdotpositions(1,:)-(DotDiameter/2)<0|...
           latestdotpositions(2,:)-(DotDiameter/2)<0|...
               latestdotpositions(1,:)+(DotDiameter/2)>RDKWidth|...
               latestdotpositions(2,:)+(DotDiameter/2)>RDKWidth;
       nreset=sum(reset);
       latestdotpositions(1, reset)=(rand(1, nreset)*RDKWidth);
       latestdotpositions(2, reset)=(rand(1, nreset)*RDKWidth);
%        latestdotpositions(3:4, reset)=latestdotpositions(1:2, reset) + DotDiameter;
       %make dots a circle
       Screen('DrawDots', windowNo, latestdotpositions, DotDiameter, [0 0 0],...
           [aperture(1) aperture(2)], 1);
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