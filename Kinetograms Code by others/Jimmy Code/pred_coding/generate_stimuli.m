function stim=generate_stimuli(sub, run, threshold)
global data;
stimfile = sprintf(['data/%s/stim_%s_%i.mat'],sub,sub,run);

stim.threshold=threshold;

if exist(stimfile,'file')
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

cogent_setup;
dur = data.Dur.Stim;
pxl = data.pxl;

mot_levels = [max([0.0,.5*threshold]) threshold min([1.0,1.5*threshold])];
%mot_levels = [.128 .256 .512];

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
perc_congruent=.7;

% trials: dot_dir, coherence, congruent, instr_dir
trials=zeros(data.num_trials,4);
num_coherent_trials=data.num_trials/6;
num_congruent=round(num_coherent_trials*perc_congruent);

% left dots
trials(1:data.num_trials/2,1)=data.left;

% left dots, coherence level 1 
trials(1:num_coherent_trials,2)=mot_levels(1);
% left dots, coherence level 1, congruent
trials(1:num_congruent,3)=1;
% left dots, coherence level 1, incongruent
trials(num_congruent+1:num_coherent_trials,3)=0;

% left dots, coherence level 2
trials(num_coherent_trials+1:2*num_coherent_trials,2)=mot_levels(2);
% left dots, coherence level 2, congruent
trials(num_coherent_trials+1:num_coherent_trials+num_congruent,3)=1;
% left dots, coherence level 2, incongruent
trials(num_coherent_trials+num_congruent+1:2*num_coherent_trials,3)=0;

% left dots, coherence level 3
trials(2*num_coherent_trials+1:data.num_trials/2,2)=mot_levels(3);
% left dots, coherence level 3, congruent
trials(2*num_coherent_trials+1:2*num_coherent_trials+num_congruent,3)=1;
% left dots, coherence level 3, incongruent
trials(2*num_coherent_trials+num_congruent+1:data.num_trials/2,3)=0;

% right dots
trials(data.num_trials/2+1:data.num_trials,1)=data.right;
% right dots, coherence level 1
trials(data.num_trials/2+1:data.num_trials/2+num_coherent_trials,2)=mot_levels(1);
% right dots, coherence level 1, congruent
trials(data.num_trials/2+1:data.num_trials/2+num_congruent,3)=1;
% right dots, coherence level 1, incongruent
trials(data.num_trials/2+num_congruent+1:data.num_trials/2+num_coherent_trials,3)=0;

% right dots, coherence level 2
trials(data.num_trials/2+num_coherent_trials+1:data.num_trials/2+2*num_coherent_trials,2)=mot_levels(2);
% right dots, coherence level 2, congruent
trials(data.num_trials/2+num_coherent_trials+1:data.num_trials/2+num_coherent_trials+num_congruent,3)=1;
% right dots, coherence level 2, incongruent
trials(data.num_trials/2+num_coherent_trials+num_congruent+1:data.num_trials/2+2*num_coherent_trials,3)=0;

% right dots, coherence level 3
trials(data.num_trials/2+2*num_coherent_trials+1:data.num_trials,2)=mot_levels(3);
% right dots, coherence level 3, congruent
trials(data.num_trials/2+2*num_coherent_trials+1:data.num_trials/2+2*num_coherent_trials+num_congruent,3)=1;
% right dots, coherence level 3, incongruent
trials(data.num_trials/2+2*num_coherent_trials+num_congruent+1:data.num_trials,3)=0;

for i=1:data.num_trials
    if trials(i,1)==data.left
        if trials(i,3)==0
            trials(i,4)=data.right;
        else
            trials(i,4)=data.left;
        end
    elseif trials(i,1)==data.right
        if trials(i,3)==0
            trials(i,4)=data.left;
        else
            trials(i,4)=data.right;
        end
    end
end
stim.trials=trials(randperm(data.num_trials),:);

stim.RDM={1,data.num_trials};
for i=1:data.num_trials
    m_dir=stim.trials(i,1);
    if m_dir ==2, m_dir = -1; end
    if m_dir ==0 % noise
        incohID = 1:dots;
        cohID = [];
    end
    m_coh=stim.trials(i,2);
    
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
    stim.RDM(i)={seq_loc};
end
save(stimfile,'stim');