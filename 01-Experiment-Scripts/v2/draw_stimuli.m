function results = draw_stimuli(FixationXY, DotsXY, data, TotalNumTrials, TrialsPerBlock, TotalNumBlocks, vars, params, screen, participant, option)

%Global Variables

FirstKey = NaN;

%Seed the random number generator
%     rng('shuffle'); %modern
        rand('seed', sum(100 * clock)); %legacy

for BlockNo=1:TotalNumBlocks
    if option.explicitprior == 1 && option.estimatethreshold == 0
        %tell participant the prior for the next block
        message = strcat('For the next', 32, num2str(TrialsPerBlock), ' trials, the probability the dot field will be moving LEFT is \n',...
            32, num2str(data.LeftProbability(1, BlockNo)), '%, and the probability it will be moving RIGHT is', 32,...
            num2str(100-data.LeftProbability(1, BlockNo)), '%');
        LeftColour = (1*(100-data.LeftProbability(1, BlockNo))/100)*[255 255 255];
        RightColour = (1*data.LeftProbability(1, BlockNo)/100)*[255 255 255];
        RectSize = [0 0 100 100];
        offset = 150;
        LeftRect = CenterRectOnPoint(RectSize, (screen.xmiddle-offset), (screen.ymiddle+150));
        RightRect = CenterRectOnPoint(RectSize, (screen.xmiddle+offset), (screen.ymiddle+150));
        
        DrawFormattedText(screen.windowNo, message, 'center', (screen.ymiddle-250), [0 0 0], '', '', '', 2.5);
        Screen(screen.windowNo,'FillRect', LeftColour, LeftRect);
        Screen(screen.windowNo,'FillRect', RightColour, RightRect);
        DrawFormattedText(screen.windowNo, 'Left', (screen.xmiddle-offset), 'center', [0 0 0], '', '', '', 2.5);
        DrawFormattedText(screen.windowNo, strcat(num2str(data.LeftProbability(1, BlockNo)), '%'), (screen.xmiddle-offset), (screen.ymiddle+50), [0 0 0], '', '', '', 2.5);
        DrawFormattedText(screen.windowNo, 'Right', (screen.xmiddle+offset), 'center', [0 0 0], '', '', '', 2.5);
        DrawFormattedText(screen.windowNo, strcat(num2str(100-data.LeftProbability(1, BlockNo)), '%'), (screen.xmiddle+offset), (screen.ymiddle+50), [0 0 0], '', '', '', 2.5);
        DrawFormattedText(screen.windowNo, 'Press any key to continue', 'center', screen.ymiddle+300, [0 0 0], '', '', '', 2.5);
        Screen('Flip', screen.windowNo);
        KbStrokeWait;
    end
    
    for TrialNo = (((BlockNo-1)*TrialsPerBlock)+1):(BlockNo*TrialsPerBlock)
        data.times.trialstart(1,TrialNo) = GetSecs;
        Screen('DrawDots', screen.windowNo, FixationXY, 2*params.FixationRadius, params.DotColour, [screen.xmiddle screen.ymiddle], 1);
        data.times.fixation_onset(1,TrialNo) = Screen('Flip', screen.windowNo); %not stimulus onset time??!!
        if option.TMS == 1 && data.TMSindex(1, TrialNo) > 0 && strcmp(data.TMSRelation(1, TrialNo), 'Fixation') %if the TMS point is within the fixation period
            %wait a little bit, trigger, then wait the remainder of
            %                 %fixation
            initialwait = data.TMSTimepoint(1, TrialNo);
            WaitSecs(initialwait/1000);
            data.TMSTriggerTime(1, TrialNo) = sendtrigger(params.port);
            WaitSecs((params.FixationDuration-initialwait-params.TriggerLength)/1000);
        else
            WaitSecs(params.FixationDuration/1000); %otherwise, just wait the fixation period
        end
        
        
        %             if data.TMSTimepoint(1, TrialNo) <= FixationDuration %if the TMS point is within the fixation period
        %                 %wait a little bit, trigger, then wait the remainder of
        %                 %fixation
        %                 initialwait = FixationDuration-data.TMSTimepoint(1, TrialNo);
        %                 WaitSecs(initialwait/1000);
        %                 data.TMSTriggerTime(1, TrialNo) = trigger;
        %                 WaitSecs((FixationDuration-initialwait-params.TriggerLength)/1000);
        %             else
        %                 WaitSecs(FixationDuration/1000); %otherwise, just wait the fixation period
        %             end
        Timestamp = GetSecs;
        KeyPress=0;
        KbQueueCreate;
        data.times.RDKstart(1,TrialNo) = GetSecs;
        KbQueueStart;
        have_stimulated = 0;
        for FrameNo=1:params.TotalNumFrames
            Screen('DrawDots', screen.windowNo, DotsXY(:, :, FrameNo, TrialNo), 2*screen.DotRadius, params.DotColour, [screen.xmiddle screen.ymiddle], 1);
            Timestamp = Screen('Flip', screen.windowNo, Timestamp+0.5*params.IFI); %send flip command halfway through IFI %keep all this data??
            %if there is a timepoint in the stimulus period, and the
            %Timestamp is bigger than the timepoint, and we haven't
            %already stimulated, then stimulate!
            
            %NB this means TMS timing is only accurate to an IFI
            %(17ms) but we record when the trigger happens to have
            %accurate timings later
            if option.TMS == 1 && data.TMSindex(1, TrialNo) > 0 && strcmp(data.TMSRelation(1, TrialNo),'Stim')...
                    && data.TMSTimepoint(1, TrialNo) <= ...
                    (Timestamp-data.times.RDKstart(1,TrialNo)) && have_stimulated == 0;
                data.TMSTriggerTime(1, TrialNo) = sendtrigger(params.port);
                have_stimulated = 1;
            end
            [KeyPress, KeyPressTime] = KbQueueCheck;
            if KeyPress ~= 0
                break
            end
        end
            %                   [KeyPress, KeyPressTime, KeyCode] = KbCheck
            
            data.times.RDKend(1,TrialNo) = Timestamp;
            KbQueueStop;
            
            if option.TMS == 1 && data.TMSindex(1, TrialNo) > 0 && strcmp(data.TMSRelation(1, TrialNo), 'Stim') && data.TMSTimepoint(1, TrialNo) >...
                    (data.times.RDKend(1,TrialNo)-data.times.RDKstart(1,TrialNo)) % did the person respond before the trigger?
                data.TMSMiss(1, TrialNo) = 1; %Record a miss %STORE THIS IN A BETTER WAY!
            end
            
            if min(KeyPressTime(KeyPressTime~=0)) ~= 0 %if a key was pressed
                FirstKey = KbName(KeyPressTime==(min(KeyPressTime(KeyPressTime~=0)))); %get the name of the first key pressed
            end
            min(KeyPressTime(KeyPressTime~=0)); %find the first key to be pressed
            %if a key was pressed, store the response
            if KeyPress ~= 0
                results.ReactionTime(1,TrialNo) = min(KeyPressTime(KeyPressTime~=0)); %in ms
                if strcmp (FirstKey, 'LeftArrow') == 1 %if first key pressed was left
                    results.Response(1,TrialNo)=1; %1 in the Response variable means left keypress
                elseif strcmp (FirstKey, 'RightArrow') == 1
                    results.Response(1,TrialNo)=2; %2 in the Response variable means right keypress
                elseif strcmp (FirstKey, 'ESCAPE') == 1
                    results.Response(1,TrialNo)=3; %3 in the Response variable means Escape was pressed
                    DrawFormattedText(screen.windowNo, 'Experiment ending because you pressed escape', 'center', 'center', [0 0 0]);
                    Screen('Flip', screen.windowNo);
                    WaitSecs(1);
                    break
                else
                    results.Response(1,TrialNo)=4; %4 in the Response variable means another key was pressed (pauses the experiment & when unpaused a new RDK is created)
                    DrawFormattedText(screen.windowNo, 'Experiment paused. Press any key to continue.', 'center', 'center', [0 0 0]);
                    Screen('Flip', screen.windowNo);
                    KbStrokeWait;
                    % nb - you lose a trial whenever you do this
                end
                % give some feedback
                if (results.Response(1, TrialNo) == 1 && data.Direction(1, TrialNo) == -1) || (results.Response(1, TrialNo) == 2 && data.Direction(1, TrialNo) == 1) %if correct response %RATIONALISE THESE!
                    DrawFormattedText(screen.windowNo, 'Good!', 'center', 'center', [0 0 0]);
                    data.times.Feedbackstart(1,TrialNo) = Screen('Flip', screen.windowNo);
                    WaitSecs(params.FeedbackDuration/1000);
                elseif strcmp (FirstKey, 'ESCAPE') == 1
                    break
                elseif results.Response(1, TrialNo) == 4
                    %                     DrawFormattedText(screen.windowNo, 'Wrong! Rememember to press the Left or Right Keys', 'center', 'center', [0 0 0]);
                    %                     data.times.Feedbackstart(1,TrialNo) = Screen('Flip', screen.windowNo);
                else
                    DrawFormattedText(screen.windowNo, 'Wrong!', 'center', 'center', [0 0 0]);
                    data.times.Feedbackstart(1,TrialNo) = Screen('Flip', screen.windowNo);
                    WaitSecs(params.FeedbackDuration/1000);
                end
                %if no key was pressed, tell participant to hurry up
            elseif KeyPress == 0
                DrawFormattedText(screen.windowNo, 'Too slow!', 'center', 'center', [0 0 0]);
                Screen('Flip', screen.windowNo);
                WaitSecs(params.FeedbackDuration/1000);
                results.Response(1,TrialNo)=NaN; %NaN means no response was made
                results.ReactionTime(1,TrialNo)=NaN;
            end
            data.times.ITIstart(1,TrialNo) = Screen('Flip', screen.windowNo);
            %if we are having TMS in the ITI, wait a bit, send trigger,and
            %wait the remainder
            if option.TMS == 1 && data.TMSindex(1, TrialNo) > 0 &&...
                    strcmp(data.TMSRelation(1, TrialNo),'ITI') %if the TMS point is within the fixation period
                %wait a little bit, trigger, then wait the remainder of
                %                 %fixation
                initialwait = data.TMSTimepoint(1, TrialNo);
                WaitSecs(initialwait/1000);
                data.TMSTriggerTime(1, TrialNo) = sendtrigger(params.port);
                WaitSecs(((params.MinITIDuration) + (rand*(params.MaxITIDuration-params.MinITIDuration)-initialwait-params.TriggerLength))/1000);
            else
                WaitSecs(((params.MinITIDuration) + (rand*(params.MaxITIDuration-params.MinITIDuration)))/1000); %jitter the ITI between Min and Max
            end
            %             if data.TMSTimepoint(1, TrialNo) >= (GetSecs-data.times.trialstart(1,TrialNo));
            %                 initialwait = data.TMSTimepoint(1, TrialNo) - (GetSecs-data.times.trialstart(1,TrialNo));
            %                 WaitSecs(initialwait/1000);
            %                 data.TMSTriggerTime(1, TrialNo) = trigger;
            %                 WaitSecs(((MinITIDuration) + (rand*(MaxITIDuration-MinITIDuration)-initialwait-triggerlength))/1000);
            %             else
            %                WaitSecs(((MinITIDuration) + (rand*(MaxITIDuration-MinITIDuration)))/1000); %jitter the ITI between Min and Max
            %             end
            %give a break screen if we're at the end of a block
        end
        if TrialNo<TotalNumTrials && strcmp (FirstKey, 'ESCAPE') ~= 1
            DrawFormattedText(screen.windowNo, 'Have a rest. Press any key to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip', screen.windowNo);
            KbStrokeWait;
            save (filename);
        elseif option.estimatethreshold == 1
            break
        else
            DrawFormattedText(screen.windowNo, 'Experiment finished! Press any key to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip', screen.windowNo);
            KbStrokeWait;
            save (filename);
            break
        end
    end
end