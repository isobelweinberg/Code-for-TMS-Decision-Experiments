%% Moving RDK - 0% coherence
try
    clear all;
    sca;
    %Define Variables
    RDKWidth=400;
    DotDiameter=3;
    DotSpeed=0.3;%units: pixels/ms
    %Open Window and get window number
    [windowNo, rect1] = Screen('OpenWindow', 0, [255 255 255]);
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
    dotpositions=zeros(4,100);
    %dotpositions=aperture(1,1)+(rand(2, 100)*RDKWidth);
    %dotpositions(3:4, :) = dotpositions(1:2, :) + DotDiameter;
    for i=1:100;
        randomx=aperture(1,1)+(rand*RDKWidth);
        randomy=aperture(1,2)+(rand*RDKWidth);
        dotpositions(1,i)=randomx; 
        dotpositions(2,i)=randomy;
        dotpositions(3,i)= dotpositions(1,i)+DotDiameter;
        dotpositions(4,i)= dotpositions(2,i)+DotDiameter;
    end;
      
%   create matrix of random direction of motion between 0 to 360
    dotdirections=rand(1,100)*360;
    %split directions into x y vectors
    dotdirectionvectors=zeros(4,100);
    dotdirectionvectors(1,:)=sind(dotdirections);
    dotdirectionvectors(3,:)=sind(dotdirections);
    dotdirectionvectors(2,:)=cosd(dotdirections);
    dotdirectionvectors(4,:)=cosd(dotdirections);  
   %while there is no keyboard press, draw the dots
   ifi=Screen('GetFlipInterval', windowNo);
   time=0;
   timestamp=Screen('Flip', windowNo);
   latestdotpositions=dotpositions;
   while ~KbCheck
       distance=DotSpeed.*ifi;
       latestdotpositions=latestdotpositions+(latestdotpositions.*dotdirectionvectors.*distance);
       reset=latestdotpositions(1,:)<aperture(1)|latestdotpositions(2,:)<aperture(2)|...
               latestdotpositions(3,:)>aperture(3)|latestdotpositions(4,:)>aperture(4);
       nreset=sum(reset);
       latestdotpositions(1, reset)=aperture(1,1) + (rand(1, nreset)*RDKWidth);
       latestdotpositions(2, reset)=aperture(1,2) + (rand(1, nreset)*RDKWidth);
       latestdotpositions(3:4, reset)=latestdotpositions(1:2, reset) + DotDiameter;
       %make dots a circle
       Screen('FillOval', windowNo, [0 0 0], latestdotpositions);
       Screen('Flip', windowNo, timestamp+(0.5*ifi));
       time=time+ifi;
   end
   %coherence
   %anti-aliasing
    KbStrokeWait;
    sca;
    catch err
    disp('caught error');
    rethrow (err);   
end;