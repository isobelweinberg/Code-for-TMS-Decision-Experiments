function threshold=estimate_threshold()

tGuess=.2;
tGuessSd=.3;

cogent_setup;
dur = data.Dur.Stim;
pxl = data.pxl;

% initialise vars
% ============================================================== %
area = pxl.aperture; % 10 degree visual angle
speed = pxl.dotSpeed; % speed of coherently moving dots (5d per sec)
dots = pxl.noDots; % 100 dots
diameter = pxl.dotDiam; % around 7 pixels, but in degree 0.3

d = diameter*ones(dots,1);


% random motion
% ============================================================== %
% make three sequences
no_seq = 3;
seq_dur = (ceil(dur/17))/3; %17 is screen refresh rate

rand_speed_range = [speed,10*speed];

pThreshold=0.82;
beta=3.5;delta=0.1;gamma=0.5;
no_seq=3;

q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

start_cogent;

%draw blank screen, show welcome screen and wait for button press
cgflip(bg_col(1),bg_col(2),bg_col(3));
wait(1000); %wait 1s
cgpencol(1,1,1);
cgtext('You will be shown a field of randomly moving dots.',0,150);
cgtext('When the fixation point turns green, press the left',0,110);
cgtext('button if most dots are moving to the left, and the',0,70);
cgtext('right button if most dots are moving to the right.',0,30);
cgtext('Press the left or right button to continue the experiment.',0,-10);
cgflip(bg_col(1),bg_col(2),bg_col(3));
wait(5000); clearkeys;
keyout = waitkeydown(inf, [data.resp_keys]); clearkeys;
cgflip(bg_col(1),bg_col(2),bg_col(3));

trialsDesired=40;
for k=1:trialsDesired
    start_time=time;
    
	% Draw fixation
    draw_fix(0,0,data.pxl.fix,whiteC);
    cgflip(bg_col(1),bg_col(2),bg_col(3));
    waituntil(time+500);
    
    % Get recommended level.  Choose your favorite algorithm.
	m_coh=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
    if m_coh<0
        m_coh=0.0;
    elseif m_coh>1
        m_coh=1.0;
    end
    if rand()<.5
        m_dir=1;
    else
        m_dir=2;
    end
    if m_dir ==2, m_dir = -1; end
    if m_dir ==0 % noise
        incohID = 1:dots;
        cohID = [];
    end
    for s=1:no_seq
        % starting config
        x = area*rand(dots,1)-0.5*area;
        y = area*rand(dots,1)-0.5*area;

        for t=1:seq_dur
            % in each trial, pick new subset of dots that moves coherently
            if m_dir ~=0
                I = randperm(dots);
                cohID = I(1:round(m_coh * dots));
                incohID = I(round(m_coh * dots)+1:dots);
            end

            % move randomly and restrict boundaries
            speedI = rand(length(incohID),1)*(rand_speed_range(2)-rand_speed_range(1))+rand_speed_range(1);
            x(incohID) = mod(x(incohID)+area/2+speedI.*rand(length(incohID),1)-speedI./2,area)-area/2;
            y(incohID) = mod(y(incohID)+area/2+speedI.*rand(length(incohID),1)-speedI./2,area)-area/2;

            % coherently moving        
            x(cohID) = mod(x(cohID)+area/2+m_dir*speed,area)-area/2; % not sure why I had m_dir*0.5*speed before

            seq_loc(s,t,:,:) = [x y];
        end
    end
    % initialise vars
    % ============================================================== %
    area = data.pxl.aperture; % 10 degree visual angle
    speed = data.pxl.dotSpeed; % speed of coherently moving dots (5d per sec)
    dots = data.pxl.noDots; % 100 dots
    diameter = data.pxl.dotDiam; % around 7 pixels, but in degree 0.3

    d = diameter*ones(dots,1);

    % random motion
    % ============================================================== %
    % make three sequences
    seq_dur = (ceil(data.Dur.Stim/17))/3; %17 is screen refresh rate, but should be one less, keep simple for now todo

    for t=1:seq_dur % because will do one more 17ms refresh
        for this_seq = 1:no_seq

            x = squeeze(seq_loc(this_seq,t,:,1));
            y = squeeze(seq_loc(this_seq,t,:,2));

            % position, width
            cgellipse(x,y,d,d,repmat([0.5 0.5 0.5],length(x),1),'f');
            draw_fix(0,0,data.pxl.fix,whiteC);
            
            cgflip(bg_col(1),bg_col(2),bg_col(3));
        end
    end
    % Draw fixation
    draw_fix(0,0,data.pxl.fix,greenC);
    cgflip(bg_col(1),bg_col(2),bg_col(3));
    
    % record response
    clearkeys; [key,ktime,nkeypress] = waitkeydown(1000, data.resp_keys); clearkeys;
    if nkeypress>0
        % Record response
        keydown = key(1)    %this key was pressed last
        if keydown == data.resp_keys(1),
            response = -1;  %pressed left
        elseif keydown == data.resp_keys(2),
            response = 1;  %pressed right
        else                 %no response or invalid button
            response = 0;
            rt = nan;
        end
    else
        response=0;
        rt=0;
    end
    correct=response==m_dir;
    
    fprintf('Trial %3d at %5.2f is %d\n',k,m_coh,correct);

	% Update the pdf
	q=QuestUpdate(q,m_coh,correct); % Add the new datum (actual test intensity and observer response) to the database.
        
end
stop_cogent;
% Ask Quest for the final estimate of threshold.
threshold=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean±sd) is %.2f ± %.2f\n',threshold,sd);
