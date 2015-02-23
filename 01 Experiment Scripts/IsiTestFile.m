%% Shapes
try
clear all;
sca;
[windowNo, rect1] = Screen('OpenWindow', 0, [255 178 102]);
KbStrokeWait;
Screen('FillRect', windowNo, [255 204 229], [0,0,500,500]);
Screen('Flip', windowNo);
KbStrokeWait;
Screen('FrameRect', windowNo, [255 255 255], [0,0,500,500]);
Screen('Flip', windowNo);
KbStrokeWait;
Screen('DrawArc',windowNo ,[0 128 255],[0, 0, 500, 500],10,40);
Screen('Flip', windowNo);
KbStrokeWait;
rect=Screen('Rect', 0);
xmiddle=rect(1,3)*0.5;
ymiddle=rect(1,4)*0.5;
Screen('FrameRect', windowNo, [255 255 255], [xmiddle-10,ymiddle-10,xmiddle+10,ymiddle+10]);
Screen('Flip', windowNo);
KbStrokeWait;
Screen('FillOval', windowNo, [255 102 102]);
Screen('Flip', windowNo);
KbStrokeWait;
%is this bad form?
%newRect gives size of dots
newRect=[0 0 1 1];
newRect=CenterRectOnPoint(newRect,xmiddle,ymiddle);
Screen('FillOval', windowNo, [0 0 0], [newRect]);
Screen('Flip', windowNo);
KbStrokeWait;
sca;
catch err
    disp('caught error');
    rethrow (err);       
end;
%% Dots
try
clear all;
sca;
[windowNo, rect1] = Screen('OpenWindow', 0, [255 178 102]);
KbStrokeWait;
rect=Screen('Rect', 0);
xmiddle=rect(1,3)*0.5;
ymiddle=rect(1,4)*0.5;
%is this bad form?
%newRect gives size of dots
newRect=[0 0 4 4];
newRect=CenterRectOnPoint(newRect,xmiddle,ymiddle);
Screen('FillOval', windowNo, [0 0 0], [newRect]);
Screen('Flip', windowNo);
KbStrokeWait;
Rect2=[600 700 800 900; 250 350 450 550; 605 705 805 905; 255 355 455 555];
Screen('FillOval', windowNo, [0 0 0], [Rect2]);
Screen('Flip', windowNo);
KbStrokeWait;
sca;
catch err
    disp('caught error');
    rethrow (err);      
end;