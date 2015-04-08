%% Static RDK
try
    clear all;
    sca;
    %Define Variables
    RDKWidth=100;
    DotDiameter=3;
    %Open Window and get window number
    [windowNo, rect1] = Screen('OpenWindow', 0, [255 255 255], [0 0 300 300]);
    %Find middle of window
    middlerect=Screen('Rect',windowNo);
    xmiddle=middlerect(1,3)*0.5;
    ymiddle=middlerect(1,4)*0.5;
    %Create aperture of 50x50px centred on middle
    %is this bad form?
    aperture=[0 0 RDKWidth RDKWidth];
    aperture2=CenterRectOnPoint(aperture,xmiddle,ymiddle);
    %Seed the random number generator
    %?????
    rng('shuffle');
    %Fill dotposition matrix
    i=1;
    dotpositions=zeros(4,100);%????
    for i=1:100;
        randomx=aperture2(1,1)+(rand*RDKWidth);
        randomy=aperture2(1,2)+(rand*RDKWidth);
        dotpositions(1,i)=randomx;
        dotpositions(2,i)=randomy;%can these lines be combined?
        dotpositions(3,i)= dotpositions(1,i)+DotDiameter;
        dotpositions(4,i)= dotpositions(2,i)+DotDiameter;
    end;
    %Draw dots 
    Screen('FillOval', windowNo, [0 0 0], dotpositions);
    Screen('Flip', windowNo);
    KbStrokeWait;
    sca;
catch err
    disp('caught error');
    rethrow (err);   
end;