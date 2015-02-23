
function main_exp(sub,name,age,run,threshold)

stim=generate_stimuli(sub,run,threshold);

tic;
% Check inputs and create subject directory
% ======================================================================= %
global data;

if ~ischar(sub)|~ischar(name)|~isnumeric(age)|~isnumeric(run)
    fprintf(['\n\nWrong inputs!',...
        '\nPlease use inputs such as: main_exp(''s1'',''testname'',35,1)']);
    return
end

% Create data file
datafile = sprintf(['data/%s/data_%s_%i.mat'],sub,sub,run);

if exist(datafile,'file')
    fprintf(['\n\nA file with this subject and session',...
        ' number already exists!\nPlease specify other name... \n']);
    return
else
    if ~exist(['data'],'dir')
        mkdir(['data']);
    end
    if ~exist(sprintf(['data/%s'],sub),'dir')
        mkdir(sprintf(['data/%s'],sub));
    end
end

% because of eyelink file...
if length(sub)>4
    fprintf(['\n\nThe subject name can only be four characters!',...
        '\nPlease specify other name... \n']);
    return
end

data.age = age;
data.name = name;
save(datafile,'data');

% Initialise variables
% ======================================================================= %
cogent_setup;
start_cogent;
data.t0 = time;

clearkeys;

% load stimuli
%load([sprintf('data/%s/stim_%s_%i',sub,sub,run)]);

% for each block, use new eyetrack file
if data.eye_track
    % Initialize eyetracker
    if eyelink('Initialize') ~= 0; return; end
    
    eyelink('Openfile',[sprintf('%s_%i',sub,run)]); %can't be longer than 8 letters
    
    % 0=left, 1=right, 2=both
    eye_used = Eyelink('EyeAvailable');
    data.eye_used = eye_used;
end

% start recording eye tracking data
if data.eye_track, ret_val = eyelink('StartRecording'); end

%draw blank screen, show welcome screen and wait for button press
cgflip(bg_col(1),bg_col(2),bg_col(3));
wait(1000); %wait 1s
cgpencol(1,1,1);
cgtext('You will be shown a field of randomly moving dots,',0,150);
cgtext('followed by a left or right arrow. The direction of the',0,110);
cgtext('dot motion predicts the direction of the arrow. As quickly and',0,70);
cgtext('accurately as possible, press the left button when',0,30);
cgtext('shown the left arrow, and the right button when shown the right arrow.',0,-10);
cgtext('Press the left or right button to continue the experiment.',0,-50);
cgflip(bg_col(1),bg_col(2),bg_col(3));
wait(data.Dur.instructiontime); clearkeys;
keyout = waitkeydown(inf, [data.resp_keys]); clearkeys;
cgflip(bg_col(1),bg_col(2),bg_col(3));

% Send all triggers
if data.MEG
    send_trigger(data.trig.trial);
    wait(500);
    send_trigger(data.trig.fixation);
    wait(500);
    send_trigger(data.trig.dots);
    wait(500);
    send_trigger(data.trig.delay);
    wait(500);
    send_trigger(data.trig.instr);
    wait(500);
    send_trigger(data.trig.choice);
    wait(500);
    send_trigger(data.trig.iti);
end

data.tStart  =   time;
data.responses = [];

for tr=1:data.num_trials
    ['trial ' num2str(tr)]
    
    if mod(tr,25)==0
        cgpencol(1,1,1);
        cgtext(['Take a ' num2str(data.Dur.Break/1000) ' second break.'],0,30);
        cgflip(bg_col(1),bg_col(2),bg_col(3));
        wait(data.Dur.Break);
    end
    
    % Send trial trigger
    if data.MEG,send_trigger(data.trig.trial),end %or make it a constant trigger
    if data.eye_track, eyelink('Message','Trigger %d',tr); end
    wait(5);

    % Get dot stimulus
    seq_loc = stim.RDM{tr};
    
    % Draw fixation
    draw_fix(0,0,data.pxl.fix,fix_col);
    cgflip(bg_col(1),bg_col(2),bg_col(3));
    instructStart = time;
    
    % Send fixation trigger
    if data.MEG,send_trigger(data.trig.fixation),end
    if data.eye_track, eyelink('Message','Trigger %d',data.trig.fixation); end    
    
    % Draw dots
    [stimStart]=draw_stim(seq_loc, data.Dur.Stim, fix_col, data.pxl, data.MEG, data.eye_track, data.trig.dots, instructStart+data.Dur.preStim, bg_col);
    stimEnd = time; %650 after instructStart because 500 + 150
    
    % Draw fixation
    draw_fix(0,0,data.pxl.fix,fix_col);
    cgflip(bg_col(1),bg_col(2),bg_col(3));
    
    % Send delay trigger
    if data.MEG,send_trigger(data.trig.delay),end
    if data.eye_track, eyelink('Message','Trigger %d',data.trig.delay); end    
    
    % Wait for delay time
    waituntil(stimEnd+data.Dur.Delay);
    delayEnd=time;

    % Draw instructed stimulus
    draw_arrow(0,0,instr_col,stim.trials(tr,4));
    cgflip(bg_col(1),bg_col(2),bg_col(3));
    
    % Send instruction trigger
    if data.MEG,send_trigger(data.trig.instr),end
    if data.eye_track, eyelink('Message','Trigger %d',data.trig.instr); end    
    
    % record response
    tstart2 = time; %within trial timer
    clearkeys; [key,ktime,nkeypress] = waitkeydown(data.Dur.maxChoice, data.resp_keys); clearkeys;
    if nkeypress
        % Send response trigger
        if data.MEG, send_trigger(data.trig.choice),end
        if data.eye_track, eyelink('Message','Trigger %d',data.trig.choice); end
        
        % Record response
        keydown = key(1);    %this key was pressed last
        if keydown == data.resp_keys(1),
            response = 1;  %pressed left
            rt = (ktime(1)-tstart2)/1000;
        elseif keydown == data.resp_keys(2),
            response = 2;  %pressed right
            rt = (ktime(1)-tstart2)/1000;
        else                 %no response or invalid button
            response = 0;
            rt = nan;
        end
    else
        response=0;
        rt=0;
    end
    respEnd=time;
    data.responses(end+1,:)=[response,rt];
    
    % Draw fixation
    draw_fix(0,0,data.pxl.fix,fix_col);
    cgflip(bg_col(1),bg_col(2),bg_col(3));
    
    % Send ITI trigger
    if data.MEG, send_trigger(data.trig.iti),end
    if data.eye_track, eyelink('Message','Trigger %d',data.trig.iti); end
    
    actual_iti=data.Dur.ITI-(rt*1000);
    % Wait ITI duration
    waituntil(respEnd+actual_iti);

    %check for abortkey
    readkeys; [key,ktime,nkeypress] = getkeydown(data.abortkey); clearkeys;
    if nkeypress
        break; 
    end
end
stop_cogent;

% Stop eyetracking
if data.eye_track
    eyelink('StopRecording');
    eyelink('Closefile');
    eyelink('ReceiveFile');
end

% Save data file
data.exp_stop  =   datestr(now,0);
save(datafile,'data');


if data.eye_track,eyelink('Shutdown');end
elapsed_time=toc;

['total experiment time=' num2str(elapsed_time/60) ' min']
['mean time per trial=' num2str(elapsed_time/data.num_trials/60) ' min']
