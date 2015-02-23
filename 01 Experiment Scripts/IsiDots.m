
try
    clear all;
    sca;
    
    %Experiment settings
    interstimInterval = 1;
    totalTrialNum = 10;
    
    %Which screen are we using?
    screenNumber = max(Screen('Screens'));
    
    %Colours
    white = WhiteIndex(screenNumber);
    grey = white / 2;
    black = BlackIndex(screenNumber);
    
    %Keyboard setting
    KbName('UnifyKeyNames');
    escapeKey = KbName('ESCAPE');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
  
    %[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);
    
    % Initialize the screen
    % remember to set the first number to the screen width. Second is
    % viewing distance
    screenInfo = openExperiment(34,50,screenNumber);
    
    for trial = 1: totalTrialNum
        if trial == 1
        DrawFormattedText(screenInfo.curWindow, 'Press Any Key To Begin',...
            'center', 'center', white);
        Screen('Flip', screenInfo.curWindow);
        KbStrokeWait;
        end
            
    % Initialize dots
    % Check createMinDotInfo to change parameters (Isi: !!)
    dotInfo = createMinDotInfo(1);

    [frames, rseed, start_time, end_time, response, response_time] = ...
        dotsX(screenInfo, dotInfo);    
    WaitSecs(0.5)

    % Clear the screen and exit
    
    end
    closeExperiment;
catch
    disp('caught error');
    lasterr
    closeExperiment;
    
end;
