try
    
    % %% === ParticipantDetails ===
    %     participant.Name='Isobel_Weinberg'; %use underscores
    %     participant.Age=25;
    %     note='deletethese'; %appears at end of filename
    %     participant.meanRT=NaN; %in ms. Needed if scaling to RT
    % %     participant.threshold = (16.125/100); %as a decimal %COMMENT OUT IF NOT USING!
    %
    %% Open a dialogue box to get participant's details
    prompt = {'Enter name (use underscores):', 'Age:'};
    dlg_title = 'Participant Details';
    num_lines = 1;
    default = {'Test', ''};
    participant = inputdlg(prompt,dlg_title,num_lines,default);
    
    
    %% Threshold
    
    %Get the stimulus parameters & timings from the function which stores
    %them
    [params] = load_parameters;
    
    % Initialise the screen
    [screen] = screen_setup(params);
    
    % CHECK THIS!!
    filename = strcat('data/',date,'_',participant.Name,'_',time,'_thresholding',note);
          
    %Variables for thresholding
    thresholding.trialsperblock = 1;
    thresholding.totalnumblocks = 1;
    thresholding.leftprobabilityarray = 50;
    thresholding.stepsize = 12;
    thresholding.minimumreversals = 16;
    thresholding.minimumtrials = 40;
    
    thresholding.trial = 1;
    thresholding.reversals = 0;
    
       
    %% display intro screen
    DrawFormattedText(screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', screen.windowNo);
    KbStrokeWait;
    
    %% ==1-up-2-down (transformed up-down rule, Levitt, 1970) -> find 70.7% correct threshold
    
    while thresholding.reversals <  thresholding.minimumreversals || thresholding.trial < thresholding.minimumtrials %must have an even number of runs -> odd number of reversls
        
        %set coherence
        if thresholding.trial == 1 || thresholding.trial == 2 %threshold is constant for trials 1 and 2
            thresholding.coherence(1, thresholding.trial) = 70;
        elseif (thresholding.alldata.Response(1, (thresholding.trial-1)) == 1 && thresholding.alldata.Direction(1, (thresholding.trial-1)) == -1)...
                || (thresholding.alldata.Response(1, (thresholding.trial-1)) == 2 &&...
                thresholding.alldata.Direction(1, (thresholding.trial-1)) == 1) %if last response was correct
            if (thresholding.alldata.Response(1, (thresholding.trial-2)) == 1 && thresholding.alldata.Direction(1, (thresholding.trial-2)) == -1)...
                    || (thresholding.alldata.Response(1, (thresholding.trial-2)) == 2 &&...
                    thresholding.alldata.Direction(1, (thresholding.trial-2)) == 1) %if response prior to that was also correct
                %threshold decreases by 1 step size
                thresholding.coherence(1, thresholding.trial) = thresholding.coherence(1, (thresholding.trial-1))...
                    - thresholding.stepsize;
            else
                %threshold stays the same
                thresholding.coherence(1, thresholding.trial) = thresholding.coherence(1, (thresholding.trial-1));
            end
        else %incorrect response
            %threshold increases by 1 step size
            thresholding.coherence(1, thresholding.trial) =...
                thresholding.coherence(1, (thresholding.trial-1)) + thresholding.stepsize;
        end
        if thresholding.coherence(1, thresholding.trial) < 0
            thresholding.coherence(1, thresholding.trial) = 0;
        end
        
        %== was this a reversal? ==
        if thresholding.trial > 3 %enough trials to make a decision?
            %what direction is it going in now?
            %coherence on this trial minus prev trial
            curr_direction = thresholding.coherence(1, (thresholding.trial)) - thresholding.coherence(1, (thresholding.trial-1));
            if curr_direction == 0
                curr_direction = thresholding.coherence(1, (thresholding.trial-1)) - thresholding.coherence(1, (thresholding.trial-2));
            end
            %what direction did it used to be going in?
            prev_direction = thresholding.coherence(1, (thresholding.trial-1)) - thresholding.coherence(1, (thresholding.trial-2));
            if prev_direction == 0
                prev_direction = thresholding.coherence(1, (thresholding.trial-2)) - thresholding.coherence(1, (thresholding.trial-3));
            end
            if (curr_direction < 0 && prev_direction < 0) || (curr_direction > 0 && prev_direction > 0) %if in same direction
                %do nothing
            else
                thresholding.reversals = thresholding.reversals+1; %increment reversals
            end
        end
        
        %record the reversal number on this trial
        thresholding.reversalrecord(1, thresholding.trial) = thresholding.reversals;
        
        %generate and draw stimuli
        [thresholding.fixationXY, thresholding.dotsxy, thresholding.data] = generate_stimuli(NumDots, 1, thresholding.trialsperblock,...
            thresholding.totalnumblocks, thresholding.coherence(1, thresholding.trial), thresholding.leftprobabilityarray);
        thresholding.results = draw_stimuli(thresholding.fixationXY, thresholding.dotsxy, thresholding.data,...
            1, thresholding.trialsperblock, thresholding.totalnumblocks);
        %save the results
        %(this needs to be done because otherwise in the generate_stim
        %functions, trialno is always 1, so all data gets overwritten.
        %kind of a botch)
        thresholding.alldata.Response(1, thresholding.trial) = thresholding.results.Response;
        thresholding.alldata.Direction(1, thresholding.trial) = thresholding.data.Direction;
        thresholding.alldata.ReactionTime(1, thresholding.trial) = thresholding.results.ReactionTime;
        %increment trial number
        thresholding.trial = thresholding.trial + 1;
        save (filename);
    end
    
    %calclulate 70.7% threshold - the 'mid-run estimate' - the average
    %of halfways points of every second run
    helpfultrials = cell(thresholding.reversals,1); %preallocation
    average_coherence = zeros(thresholding.reversals,1);
    for reversal = 1:2:thresholding.reversals %odd reversals only
        helpfultrials{reversal} = find(thresholding.reversalrecord == reversal); %find the trials of this reversal
        %you also need one trial before the reversal
        helpfultrials{reversal} = [(min(helpfultrials{reversal})-1), helpfultrials{reversal}];
        %midpoint of the coherences of these trials
        trough_trial(reversal) = min(helpfultrials{reversal}); %find the trough
        trough_coherence(reversal) = thresholding.coherence(1, trough_trial(reversal)); %coherence at this trough
        peak_trial(reversal) = max(helpfultrials{reversal});
        trough_peak(reversal) = thresholding.coherence(1, peak_trial(reversal));
        %average coherence the trough and peak
        midrunestimate(reversal) = (trough_coherence(reversal) + trough_peak(reversal))/2;
        %mean coherence of these trials
        %             average_coherence(reversal) = mean(thresholding.coherence(1, (helpfultrials{reversal}))) ;
    end
    
    threshold71 = mean(midrunestimate(1:2:end)); %mean of the mid-runestimate for the odd reversals
    
    %put TMS back to where it was
    option.TMS = tempstore;
    
    %thresholding complete
    alreadythresholded = 1;
    
    %save
    save (filename);
    
    %% XXXX
    Outputs needed:
    participant.Name
    
    
catch err
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end