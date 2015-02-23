function main_exp(sub,name,age)

global prep;

% -------------------------------------------------------------------------------------- %
% check input arguments and create log/data file
if ~ischar(sub) |  ~ischar(name) | ~isnumeric(age)
    fprintf(['\n\nWrong inputs!',...
        '\nPlease use inputs such as: main_exp(''s1'',''r1'',''testname'',35)\n']);
    return
end

datafile    = sprintf('../data/%s/prep_%s_data.mat',sub,sub);
logfile     = sprintf('../data/%s/prep_%s.log',sub,sub);
config_log(logfile);

if exist(datafile,'file')
    fprintf(['\n\nA file with this subject',...
        ' and session number already exists!\nPlease specify other name... \n']);
    return
else
    if ~exist(sprintf('../data/%s',sub),'dir')
        mkdir(sprintf('../data/%s',sub));
    end
end

% -------------------------------------------------------------------------------------- %
cogent_setup;           %creates prep

% columns of stim array
prep.col.modality    = 1; % 1 = choice, 2 = fixed
prep.col.leftstim    = 2; % left stim 1,2 or 3
prep.col.rightstim   = 3; % right stim 1,2 or 3
prep.col.TMS         = 4; % 1 if eye associated with leftstim, 2 if with right stim
prep.col.duriti      = 5; % iti duration
prep.col.rew         = [7 8 9]; % reward associated with 1,2, and 3

% training has slightly less trials (2/3)
if training
    prep.design.ntrials = 108;
    prep.Blocks         = 1;
end

% generate stimuli for all blocks & save order of randwalks in prep
[stim,prep] = generate_stim(prep,training);

% cut down number of trials if just a test
if short
    prep.design.ntrials = 10; % last line in generate_stim cuts down to 10
    prep.Blocks         = 1;
end

% configure function inputs
prep.Subject.Subname      =   name;
prep.Subject.Subage       =   age;

% save all experimental parameters
file = sprintf('../data/%s/prep_%s',sub,sub);
save(file,'prep','stim');

% -------------------------------------------------------------------------------------- %
start_cogent;

% load all stim bmps
load_bmps;

% for bar at bottom
screen_min  = -150;
screen_max  = 150;
screen_width= screen_max-screen_min;

prep.pauses      =   [];

for i = [2 3 4]%prep.Blocks
    barwidth    = 1;
    cgloadbmp(bmp_bar,'barY.bmp',barwidth,10);
    maxwin      = ceil(mean(max(stim{i}(:,prep.col.rew)'))*prep.design.ntrials);
    
    % load instructions 1
    cgsetsprite(0);
    cgflip(0,0,0);
    cgfont('Arial',textsizeT);
    cgpencol(0.35,0.35,0.35);
    if i==1
        cgtext('Welcome to the first part of the experiment!',0,55+presheight);
        cgtext('You will have to make choices between two',0,40+presheight);
        cgtext('actions and indicate your choice with a',0,25+presheight);
        cgtext('button press or an eye movement to the ',0,10+presheight);
        cgtext('dot shown on the right side of the screen.',0,-5+presheight);
    else
        cgtext('Welcome to the next part of the experiment!',0,55+presheight);
        cgtext('The task is the same as before.',0,40+presheight);
    end
    cgtext('Press button to continue...',0,-30+presheight);
    cgflip(0,0,0);
    
    if buttonbox
        [tmpk,tmpt,tmpn] = waitserialbyte(port_buttonbox,inf);
        clearserialbytes(port_buttonbox);
    else
        [tmpk,tmpt,tmpn] = waitkeydown(inf);
        clearkeys;
    end
    
    % load instructions 2
    cgtext('Here you can see the three different actions again:',0,75+presheight);
    cgdrawsprite(bmp_handR,-100,40+presheight);
    cgdrawsprite(bmp_handL,0,40+presheight);
    cgdrawsprite(bmp_eye,100,40+presheight);
    cgtext('The bar on top of the screen indicates how much',0,15+presheight);
    cgtext('you have won so far. Try to collect as much',0,0+presheight);
    cgtext('money as possible.',0,-15+presheight);
    cgtext('When you are ready, press button to start...',0,-45+presheight);
    cgflip(0,0,0);
    
    %------------------------------------------------------------------------------%
    % start by key press
    if buttonbox
        [tmpk,tmpt,tmpn] = waitserialbyte(port_buttonbox,inf);
        clearserialbytes(port_buttonbox);
    else
        [tmpk,tmpt,tmpn] = waitkeydown(inf);
        clearkeys;
    end
    
    % give 7 test pulses every 3 seconds before the start (baseline and
    % position check)
    if TMS
        cgtext([num2str(prep.ntestpulses),'TMS pulses, then we will start!'],0,0+presheight);
        cgflip(0,0,0);
        wait(1000)
        for pno=1:prep.ntestpulses
            outportb(888, 2^port_TMS); %port TMS is defined in miriam_cogent_setup
            wait(2);
            outportb(888, 0);
            wait(3000);
        end
        cgtext(['Continue?'],0,0+presheight);
        cgflip(0,0,0);
        
        if buttonbox
            [tmpk,tmpt,tmpn] = waitserialbyte(port_buttonbox,inf);
            clearserialbytes(port_buttonbox);
        else
            [tmpk,tmpt,tmpn] = waitkeydown(inf);
            clearkeys;
        end
    end
    
    %draw fixation cross
    prep = prep_check_abort(prep,presheight);
    cgdrawsprite(bmp_fix,0,0+presheight);
    
    draw_bar;
    cgflip(0,0,0);
    
    Reaction_times  =   [];
    Reaction_eye    =   [];
    Response        =   [];
    won             =   [];
    won2            =   [];
    
    TTrialstart      =   [];
    TOffer           =   [];
    TOfferend        =   [];
    TResponse        =   [];
    TFix1            =   [];
    TOutcome         =   [];
    TFix2            =   [];
    
    t0  =   time; %t0 = time 'zero'
    logstring(sprintf('start_block',t0));
    
    %------------------------------------------------------------------------------%
    %-------------------  main loop: offer, response, outcome ---------------------%
    %------------------------------------------------------------------------------%
    for j = 1:prep.design.ntrials
        tstarttrial = time;
        reaction_eye = 0;
        prep = prep_check_abort(prep,presheight);
        if eye_tracker
            readserialbytes(port_eye);
        end
        %------------------------------------------------------------------------------%
        % (1)Present OFFER
        
        % bring offer on screen
        cgdrawsprite(bmp_dot,prep.periph_dot,0+presheight); % dot for saccade
        cgdrawsprite(stim{i}(j,prep.col.leftstim)+1,0,prep.periph+presheight); %left is in first column; +1 cause pics are 2..4
        cgdrawsprite(stim{i}(j,prep.col.rightstim)+1,0,-prep.periph+presheight); %right choice is in second column
        draw_bar;
        cgdrawsprite(bmp_fix,0,0+presheight);
        cgflip(0,0,0);
        logstring(sprintf('offer pres @ %0.5g: trial %0.5g block %0.5g',time,j,i));
        toffer = time;
        
        % send trigger to spike at outport specified in cogent_setup
        if eye_tracker
            outportb(port, outport);
            wait(4);
            outportb(port, 0);
            logstring(sprintf('trigger sent @ %0.5g: trial %0.5g block %0.5g',time,j,i));
        end
        
        % clear eye and button box responses so that now response can
        % be recorded
        if buttonbox
            clearserialbytes(port_buttonbox);
        end
        if eye_tracker
            clearserialbytes(port_eye);
        end
        clearkeys;
        
        %------------------------------------------------------------------------------%
        % Deliver TMS pulse at appropriate time following offer
        if TMS
            if stim{i}(j,prep.col.modality)==1 % choice
                waituntil(picturepres +prep.TMStimes(1,stim{i}(j,prep.col.TMS)));
%             else %forced choice
%                 waituntil(toffer+prep.TMStimes(2,stim{i}(j,prep.col.TMS)));
            end
            outportb(888, 2^port_TMS);
            wait(2);
            outportb(888, 0);
        end
        
        %------------------------------------------------------------------------------%
        % (2) Wait for RESPONSE
        keyB = []; keyE = []; key = []; ktime = [];
        while (time < toffer+prep.dur.maxChoice & isempty(keyB) & isempty(keyE) & isempty(key))
            % changed so that no buttonbox BUT eyetracker possible
            if buttonbox
                readserialbytes(port_buttonbox);
                [keyB ktimeB] = getserialbytes(port_buttonbox,prep.Resp_keys);
            end
            if eye_tracker
                readserialbytes(port_eye);
                [keyE ktimeE] = getserialbytes(port_eye); %because clearserialbytes was just called
                % this should only read a serialbyte when a response is made i.e. 'R=xx.xx'
                % is sent or when X the 'timed out' trigger is sent
                
                % Miriam - not sure why not needed previously or why needed
                % now but it seems to find the 'T'=84 sign in here a lot
                if ~ismember(letterR,keyE)
                    keyE = [];
                end
            end
            readkeys;
            [key ktime] = getkeydown(prep.Resp_keys);
        end
        
        % determine whether eye or hand
        if ~isempty(keyB)
            key     = keyB;
            ktime   = ktimeB;
        end
        if ~isempty(keyE)
            % it is sending something like [82 61 51 51 57 46 48 48]
            % where 82 is R, 61 is =, and the rest are numbers and '.'
            % check if first corresponds to R = response
            % (X would be timed out, N new recording, T new trial)
            % this was all done with the help of Signal people...
            
            % todo change this for letterR be member cause first might be
            if ismember(letterR,keyE)%keyE(1) == letterR
                keyE = keyE(find(keyE==letterR):end);
                key = keyE(1); % i.e. 'R'
                dotposition = find(keyE==dotSign);
                if isempty(dotposition)
                    dotposition = length(keyE); %if no dot then just use till the end
                end
                % RTtmp  = numbers(keyE(3:end-3)); % end-3 cause i don't need
                % xx.xx ms it's enough to have xx ms, 1 and 2 is R=
                RTtmp   = numbers(keyE(3:dotposition-1));
                ktime   = ktimeE;
                if ~isempty(keyB) & ktimeB < ktimeE
                    % moved both eye and hand, but hand earlier - set back
                    key     = keyB;
                    ktime   = ktimeB;
                end
            end
        end
        
        if length(key)>1 | length(ktime)>1
            key = key(1);
            ktime = ktime(1);
        end
        
        tofferend = time;
        if buttonbox
            clearserialbytes(port_buttonbox);
        end
        if eye_tracker
            clearserialbytes(port_eye);
        end
        clearkeys;
        
        %------------------------------------------------------------------------------%
        % (3) Short delay before reward
        cgdrawsprite(bmp_fix,0,0+presheight);
        draw_bar;
        cgflip(0,0,0);
        tfix1 = time;
        
        %------------------------------------------------------------------------------%
        % (4) Register response and determine/add earned reward
        
        % if no response
        if isempty(key) | ~ismember(find(key==prep.Resp_keys),stim{i}(j,[prep.col.leftstim,prep.col.rightstim]))
            %check if keys have been pressed & if response was part of what
            %was offered in this trial
            draw_bar;
            logstring(sprintf('no response'));
            cgfont('Arial',textsizeQ);
            cgpencol(0.35,0.35,0.35);
            if isempty(key)
                cgtext('Too slow!',0,0+presheight);
            else
                cgtext('Not an option!',0,0+presheight);
            end
            cgflip(0,0,0);
            reaction_time       = -1;
            response            = -1;
            tresp               = -1;
            toutcome            = -1;
            waituntil(tofferend + prep.dur.Delay1);
            won = [won 0];
            won2 = [won2 0];
        else
            logstring(sprintf('keypress/eye movement %0.5g: @ %0.5g',key(1),ktime(1)));
            
            if key == prep.Resp_keys(1) % handR
                %if ismember(1,stim{i}(j,[prep.col.leftstim,prep.col.righstim]) % handR was offered
                won_trial = stim{i}(j,prep.col.rew(1));
                won_stim  = 1;
            elseif key == prep.Resp_keys(2) %handL
                won_trial = stim{i}(j,prep.col.rew(2));
                won_stim  = 2;
            elseif key == prep.Resp_keys(3) % this is 'R' which means response came
                % through serial port i.e. eye movement was made (if
                % real experiment)
                won_trial = stim{i}(j,prep.col.rew(3));
                won_stim  = 3;
            end
            won = [won won_trial];
            % change this for eye depending on what comes from spike
            reaction_time   = ktime(1)-toffer;
            tresp           = ktime;
            response        = key;
            
            % if eye movement was made, also save RT sent by spike code
            % which is more precise because 1401 is more precise than
            % signal sent through serial port to cogent
            if eye_tracker & key == prep.Resp_keys(3)
                % convert RTtmp (eye RT) which is read in format 3 3 9
                % from the serial port to a number w the format 339(ms)
                for blah = 1:length(RTtmp)
                    reaction_eye  = reaction_eye + RTtmp(end-(blah-1))*10^(blah-1);
                end
            end
            
            % end delay between choice and outcome
            waituntil(tofferend + prep.dur.Delay1);
            
            %-----------------------------------------------------------------------%
            % (5) present OUTCOME
            
            % determine probability of the one picked to give reward
            % and then decide whether to give one or not
            cgdrawsprite(bmp_fix,0,0+presheight);
            if rand < won_trial
                cgdrawsprite(bmp_rew,0,0+presheight); %dot
                won2 = [won2 1];
            else
                % present "no reward"
                cgdrawsprite(bmp_norew,0,0+presheight); %dot
                won2 = [won2 0];
            end
            
            % refresh bar
            barwidth = screen_width*sum(won2)/maxwin;
            if barwidth<1
                barwidth = 1;
            end
            cgloadbmp(bmp_bar,'barY.bmp',barwidth,10);
            draw_bar;
            
            cgflip(0,0,0);
            toutcome = time;
            logstring(sprintf('outcome pres @ %0.5g: trial %0.5g block %0.5g as %0.5g',time,j,i,won_trial));
            waituntil(toutcome + prep.dur.Outcome);
        end %response
        
        %------------------------------------------------------------------------------%
        % (6) Wait for iti
        cgdrawsprite(bmp_fix,0,0+presheight);
        draw_bar;
        cgflip(0,0,0);
        tfix2 = time;
        waituntil(tfix2 + stim{i}(j,prep.col.duriti)*1000);
        
        prep = prep_check_abort(prep,presheight);
        
        
        if buttonbox
            clearserialbytes(port_buttonbox);
        end
        if eye_tracker
            clearserialbytes(port_eye);
        end
        
        clearkeys;
        
        Reaction_times   =   [Reaction_times;reaction_time];
        Reaction_eye     =   [Reaction_eye;reaction_eye];
        Response         =   [Response;response];
        
        TTrialstart      =   [TTrialstart;tstarttrial];
        TOffer           =   [TOffer;toffer];
        TOfferend        =   [TOfferend;tofferend];
        TResponse        =   [TResponse;tresp];
        TFix1            =   [TFix1;tfix1];
        TOutcome         =   [TOutcome;toutcome];
        TFix2            =   [TFix2;tfix2];
        
    end
    
    prep.Data(i).Results(:,1)    =   Reaction_times;
    prep.Data(i).Results(:,2)    =   Response;
    prep.Data(i).Results(:,3)    =   won;
    prep.Data(i).Results(:,4)    =   won2;
    
    prep.Data(i).EyeTimes(:,1)   =   Reaction_eye; %those are the times from the spike code for eye movements
    
    prep.Data(i).Times(:,1)      =   TTrialstart;
    prep.Data(i).Times(:,2)      =   TOffer;
    prep.Data(i).Times(:,3)      =   TOfferend;
    prep.Data(i).Times(:,4)      =   TFix1;
    prep.Data(i).Times(:,5)      =   TResponse;
    prep.Data(i).Times(:,6)      =   TOutcome;
    prep.Data(i).Times(:,7)      =   TFix2;
    
    prep.won.p(i)             = sum(won);
    prep.won.max(i)           = maxwin;
    prep.won.pound(i)         = round(sum(won)/maxwin*maxpblock*100)/100;
    
    
    %---------------------------------------------------------------------%
    % Calculate RTs in training to express the TMS times in % RT
    res   = prep.Data(i).Results;
    times = prep.Data(i).Times;
    stim2 = stim{i}(1:length(res),:);
    if eye_tracker % replace eye RTs by precise estimate from spike
        res(find(prep.Data(i).EyeTimes~=0),1) = prep.Data(i).EyeTimes(find(prep.Data(i).EyeTimes~=0));
    end
    
    % discard premature and late
    fprintf(['Number of missed/late/wrong responses: ',...
        num2str(length(find(res(:,2)==-1))),'\n']);
    times(find(res(:,2)==-1),:)  = [];
    stim2(find(res(:,2)==-1),:)  = [];
    res(find(res(:,2)==-1),:)    = [];
    
    % determine training RT & remove outliers
%%%%%%%
    RTmin       = 100;
    acc_range   = 3;       % times the stdev of the RT, everything else is outlier and kicked out
    beh.RT.mean      = mean(res(:,1));
    beh.RT.stdev     = std(res(:,1));
    beh.RT.accrange= [max(beh.RT.mean - acc_range*beh.RT.stdev,RTmin) ...
        beh.RT.mean + acc_range*beh.RT.stdev];
    outliers            = find(res(:,1)<beh.RT.accrange(1) | ...
        res(:,1)>beh.RT.accrange(2));
    beh.RT.outliers  = res(outliers,1);
    beh.nOutliers     = length(beh.RT.outliers);
    
    times(outliers,:)   = [];
    stim2(outliers,:)    = [];
    res(outliers,:)     = [];
    beh.RT.mean      = mean(res(:,1));
    beh.RT.stdev     = std(res(:,1));
    fprintf(['Mean RT: ',num2str(beh.RT.mean),', Std RT: ',...
        num2str(beh.RT.stdev),'\n']);
    fprintf(['Accepted RT range: [',num2str(beh.RT.accrange(1)),',',...
        num2str(beh.RT.accrange(2)),']\n']);
    fprintf(['Outliers: ' num2str(beh.RT.outliers'),'\n']);
%%%%%%%%%    
    % calculate RTs per condition
    beh.RT.cond    = [mean(res(find(stim2(:,1)==1),1)) mean(res(find(stim2(:,1)==0),1))];
    fprintf(['RTs for C and FC: ' num2str(beh.RT.cond),'\n']);
    
    beh.RT.condN = [length(res(find(stim2(:,1)==1),1)) length(res(find(stim2(:,1)==0),1))];
    fprintf(['Number of C and FC trials: ' num2str(beh.RT.condN),'\n']);
    prep.beh{i} = beh;
    %---------------------------------------------------------------------%
    
    
    
    % save after each block to be save...
    save(datafile,'prep','stim');
    if i < prep.Blocks(end)
        % present feedback
        cgfont('Arial',textsizeT);
        cgpencol(0.35,0.35,0.35);
        cgtext('Thank you, you have completed this block!',0,50+presheight);
        cgtext(['You won £', num2str(prep.won.pound(i)),'.'],0,30+presheight);
        cgtext('You can take a break now...',0,10+presheight);
        cgtext('Press any button when you are ready to continue.',0,-10+presheight);
        cgflip(0,0,0);
        if buttonbox
            [tmpk,tmpt,tmpn] = waitserialbyte(port_buttonbox,inf);
            clearserialbytes(port_buttonbox);
        else
            [tmpk,tmpt,tmpn] = waitkeydown(inf);
            clearkeys;
        end
    end
end

% present feedback
cgfont('Arial',textsizeT);
cgpencol(0.35,0.35,0.35);
cgtext('Thank you, you have completed the experiment!',0,70+presheight);
cgtext(['In the last block, you won £',num2str(round(sum(won)/maxwin*maxpblock*100)/100),'.'],0,55+presheight);
cgtext('Overall, you won',0,40+presheight);
for i= prep.Blocks
    cgtext(['£',num2str(prep.won.pound(i)), ' in part ',num2str(i)],0,25-(i-1)*15+presheight);
    fprintf([num2str(prep.won.pound(i)),'\n']);
end
%%%
if training
    cgtext(['Your reaction times were ',num2str(round(beh.RT.cond(1))),'ms for choice'],0,-35+presheight);
    cgtext(['and ',num2str(round(beh.RT.cond(2))),'ms for forced choice trials.'],0,-50+presheight);
end
%%%
cgtext('Press button to exit.',0,-65+presheight);
cgflip(0,0,0);

waitkeydown(inf);
clearkeys;


% end experiment
prep.when_stop  =   datestr(now,0);

readkeys;
logkeys;

cgdrawsprite(1,0,0+presheight);
cgflip(0,0,0);
wait(2000);

% safe data again
save(datafile,'prep','stim');
stop_cogent;
clear all;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [prep] = prep_check_abort(prep,presheight)
% this is checked during ITI to pause with p and then restart with q
readkeys;
[key ktime n] = getkeydown;

if n>0 & key(1) == 52 %Esc
    %save(datafile,'prep','stim');
    cgshut, wait(5), stop_cogent;
    clear all;
elseif key == 16 %pause with p and then q to restart
    cgtext('Paused',0,0+presheight);
    cgflip(0,0,0);
    logstring(sprintf('paused using P @ %0.5g: trial %0.5g block %0.5g',time,j,i));
    p1 = time;
    waitkeydown(inf,17);
    cgtext('Continue!',0,0+presheight);
    cgflip(0,0,0);
    wait(1000);
    p2 = time;
    logstring(sprintf('pause finished using Q @ %0.5g: trial %0.5g block %0.5g',time,j,i));
    prep.pauses = [prep.pauses;[p1 p2]];
end
clearkeys;
clear key ktime n;
return

% function make_pause
% % we need this because sometimes eye data is not 
%     readkeys;
%     [key ktime n] = getkeydown;
%     if key == 
% 
