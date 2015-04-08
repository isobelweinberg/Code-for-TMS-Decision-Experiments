function data = draw_stimuli(FixationXY, DotsXY, NumTrials, TrialsPerBlock, params, screen, participant, option, data)
KbName('UnifyKeyNames'); 
FirstKey = NaN;
%% Seed the random number generator
%     rng('shuffle'); %modern
rand('seed', sum(100 * clock)); %legacy
%% Give Explicit Prior
if option.explicitprior == 1 && option.estimatethreshold == 0
    %tell participant the prior for the next block
    message = strcat('For the next', 32, num2str(TrialsPerBlock), ' trials, the probability the dot field will be moving LEFT is \n',...
        32, num2str(data.main(1, 3)), '%, and the probability it will be moving RIGHT is', 32,...
        num2str(100-data.main(1, 3)), '%');
    LeftColour = (1*(100-data.main(1, 3))/100)*[255 255 255];
    RightColour = (1*data.main(1, 3)/100)*[255 255 255];
    RectSize = [0 0 100 100];
    offset = 150;
    LeftRect = CenterRectOnPoint(RectSize, (screen.xmiddle-offset), (screen.ymiddle+150));
    RightRect = CenterRectOnPoint(RectSize, (screen.xmiddle+offset), (screen.ymiddle+150));
    
    DrawFormattedText(screen.windowNo, message, 'center', (screen.ymiddle-250), [0 0 0], '', '', '', 2.5);
    Screen(screen.windowNo,'FillRect', LeftColour, LeftRect);
    Screen(screen.windowNo,'FillRect', RightColour, RightRect);
    DrawFormattedText(screen.windowNo, 'Left', (screen.xmiddle-offset), 'center', [0 0 0], '', '', '', 2.5);
    DrawFormattedText(screen.windowNo, strcat(num2str(data.main(1, 3)), '%'), (screen.xmiddle-offset), (screen.ymiddle+50), [0 0 0], '', '', '', 2.5);
    DrawFormattedText(screen.windowNo, 'Right', (screen.xmiddle+offset), 'center', [0 0 0], '', '', '', 2.5);
    DrawFormattedText(screen.windowNo, strcat(num2str(100-data.main(1, 3)), '%'), (screen.xmiddle+offset), (screen.ymiddle+50), [0 0 0], '', '', '', 2.5);
    DrawFormattedText(screen.windowNo, 'Press any key to continue', 'center', screen.ymiddle+300, [0 0 0], '', '', '', 2.5);
    Screen('Flip', screen.windowNo);
    KbStrokeWait;
end
%% Save data labels
data.labels(1,10:20) = {'Trial Start', 'Fixation Onset', 'TMS Trigger Time', 'RDKStart', 'RDKEnd', 'TMS Miss?', 'Reaction Time', 'Response', 'Correct?', 'Feedback Start', 'ITI Start'};
%% Draw dots
for TrialNo = 1:NumTrials
    data.main(TrialNo, 10) = GetSecs;
    Screen('DrawDots', screen.windowNo, FixationXY, 2*params.FixationRadius, params.DotColour, [screen.xmiddle screen.ymiddle], 1);
    data.main(TrialNo, 11) = Screen('Flip', screen.windowNo); %not stimulus onset time??!!
    if option.TMS == 1 && data.main(TrialNo, 9) > 0 && strcmp(data.TMSRelation(1, TrialNo), 'Fixation') %if the TMS point is within the fixation period
        %wait a little bit, trigger, then wait the remainder offixation
        initialwait = data.main(TrialNo, 6);
        WaitSecs(initialwait/1000);
        data.main(TrialNo, 12) = sendtrigger(params.port);
        WaitSecs((params.FixationDuration-initialwait-params.TriggerLength)/1000);
    else
        WaitSecs(params.FixationDuration/1000); %otherwise, just wait the fixation period
    end
    Timestamp = GetSecs;
    KeyPress=0;
    KbQueueCreate;
    data.main(TrialNo, 13) = GetSecs; %record RDK Start
    KbQueueStart;
    have_stimulated = 0;
    for FrameNo=1:params.TotalNumFrames
        Screen('DrawDots', screen.windowNo, DotsXY(:, :, FrameNo, TrialNo), 2*params.DotRadius, params.DotColour, [screen.xmiddle screen.ymiddle], 1);
        Timestamp = Screen('Flip', screen.windowNo, Timestamp+0.5*params.IFI); %send flip command halfway through IFI %keep all this data??
        %if there is a timepoint in the stimulus period, and the
        %Timestamp is bigger than the timepoint, and we haven't
        %already stimulated, then stimulate!
        
        %NB this means TMS timing is only accurate to an IFI
        %(17ms) but we record when the trigger happens to have
        %accurate timings later
        if option.TMS == 1 && data.main(TrialNo, 9) > 0 && strcmp(data.TMSRelation(1, TrialNo),'Stim')...
                && data.main(TrialNo, 6) <= ...
                (Timestamp-data.main(TrialNo, 13)) && have_stimulated == 0;
            data.main(TrialNo, 12) = sendtrigger(params.port);
            have_stimulated = 1;
        end
        [KeyPress, KeyPressTime] = KbQueueCheck;
        if KeyPress ~= 0
            break
        end
    end
    %   [KeyPress, KeyPressTime, KeyCode] = KbCheck
    data.main(TrialNo, 14) = Timestamp; %record RDK End
    KbQueueStop;
    if option.TMS == 1 && data.main(TrialNo, 9) > 0 && strcmp(data.TMSRelation(1, TrialNo), 'Stim') && data.main(TrialNo, 6) >...
            (data.main(TrialNo, 14)-data.main(TrialNo, 13)) % did the person respond before the trigger?
        data.main(TrialNo, 15) = 1; %Record a miss %STORE THIS IN A BETTER WAY!
    end
    if min(KeyPressTime(KeyPressTime~=0)) ~= 0 %if a key was pressed
        FirstKey = KbName(KeyPressTime==(min(KeyPressTime(KeyPressTime~=0)))); %get the name of the first key pressed
    end
%     min(KeyPressTime(KeyPressTime~=0)); %find the first key to be pressed
    if KeyPress ~= 0 %if a key was pressed, store the response
        data.main(TrialNo, 16) = min(KeyPressTime(KeyPressTime~=0)); %RT in ms
        if strcmp (FirstKey, 'LeftArrow') == 1 %if first key pressed was left
            data.main(TrialNo, 17)=1; %1 in the Response variable means left keypress
        elseif strcmp (FirstKey, 'RightArrow') == 1
            data.main(TrialNo, 17)=2; %2 in the Response variable means right keypress
        elseif strcmp (FirstKey, 'ESCAPE') == 1
            data.main(TrialNo, 17)=3; %3 in the Response variable means Escape was pressed
            DrawFormattedText(screen.windowNo, 'Experiment ending because you pressed escape', 'center', 'center', [0 0 0]);
            Screen('Flip', screen.windowNo);
            WaitSecs(1);
            break
        else
            data.main(TrialNo, 17)=4; %4 in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)
            DrawFormattedText(screen.windowNo, 'Experiment paused. Press any key to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip', screen.windowNo);
            KbStrokeWait;
            % nb - you lose a trial whenever you do this
        end
        % ADD IN HERE A CALCULATION OF CORRECT OR NOT
        % give some feedback
        if (data.main(TrialNo, 17) == 1 && data.main(TrialNo, 5) == -1) || (data.main(TrialNo, 17) == 2 && data.main(TrialNo, 5) == 1) %if correct response %RATIONALISE THESE!
            data.main(TrialNo, 18) = 1; %Record a correct response
            DrawFormattedText(screen.windowNo, 'Good!', 'center', 'center', [0 0 0]);
            data.main(TrialNo, 19) = Screen('Flip', screen.windowNo);
            WaitSecs(params.FeedbackDuration/1000);
        elseif strcmp (FirstKey, 'ESCAPE') == 1
            break
        elseif data.main(TrialNo, 17) == 4
            %                     DrawFormattedText(screen.windowNo, 'Wrong! Rememember to press the Left or Right Keys', 'center', 'center', [0 0 0]);
            %                     data.times.Feedbackstart(1,TrialNo) = Screen('Flip', screen.windowNo);
        else
            DrawFormattedText(screen.windowNo, 'Wrong!', 'center', 'center', [0 0 0]);
            data.main(TrialNo, 18) = 0; %Record an incorrect response
            data.main(TrialNo, 19) = Screen('Flip', screen.windowNo);
            WaitSecs(params.FeedbackDuration/1000);
        end
        %if no key was pressed, tell participant to hurry up
    elseif KeyPress == 0
        DrawFormattedText(screen.windowNo, 'Too slow!', 'center', 'center', [0 0 0]);
        Screen('Flip', screen.windowNo);
        WaitSecs(params.FeedbackDuration/1000);
        data.main(TrialNo, 17)=NaN; %NaN means no response was made
        data.main(TrialNo, 16)=NaN; %No RT recorded
        data.main(TrialNo, 18) = 0; %Record an incorrect response
    end
    data.main(TrialNo, 20) = Screen('Flip', screen.windowNo);
    %if we are having TMS in the ITI, wait a bit, send trigger,and
    %wait the remainder
    if option.TMS == 1 && data.main(TrialNo, 9) > 0 &&...
            strcmp(data.TMSRelation(1, TrialNo),'ITI') %if the TMS point is within the fixation period
        %wait a little bit, trigger, then wait the remainder of
        %                 %fixation
        initialwait = data.main(TrialNo, 6); %record TMS Timepoint
        WaitSecs(initialwait/1000);
        data.main(TrialNo, 12) = sendtrigger(params.port); %record TMS Trigger time
        WaitSecs(((params.MinITIDuration) + (rand*(params.MaxITIDuration-params.MinITIDuration)-initialwait-params.TriggerLength))/1000);
    else
        WaitSecs(((params.MinITIDuration) + (rand*(params.MaxITIDuration-params.MinITIDuration)))/1000); %jitter the ITI between Min and Max
    end
    %give a break screen if we're at the end of a block
end
end