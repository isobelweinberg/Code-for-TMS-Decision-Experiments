function [start_time] = draw_stim(seq_loc,dur,col_fix,pxl,MEG,eye_track,trigID,startTime,bg_col)

% dur = how long to show the stimulus
% col_fix = colour of fixation cross
% pxl gives information on how big to draw area for rectangle, how much
% speed to use etc, all from cogent_setup
% 
% Most of it is now done in make_stim prior to the experiment
% because this is where the RDM stims are generated and converted to
% pc-specific RGB-colours, that's why coherence levels don't need to be
% specified here any more
%
% seq_loc is 4D (3seq x 17reps x [x y])
% seq_col is 3D (3seq x 100trials x 3RGB)

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
seq_dur = (ceil(dur/17))/3; %17 is screen refresh rate, but should be one less, keep simple for now todo

waituntil(startTime);
for t=1:seq_dur % because will do one more 17ms refresh
    for this_seq = 1:no_seq
        
        x = squeeze(seq_loc(this_seq,t,:,1));
        y = squeeze(seq_loc(this_seq,t,:,2));
        
        % position, width
        cgellipse(x,y,d,d,repmat([0.5 0.5 0.5],length(x),1),'f');
        draw_fix(0,0,pxl.fix,col_fix);
        if MEG, cgrect(-500,380,2*pxl.fix,2*pxl.fix,[1 1 1]); end % optional to have a white spot in corner to record precise screen timings with photodiode
        
        cgflip(bg_col(1),bg_col(2),bg_col(3));
        
        % send trigger
        if t==1 & this_seq==1
            start_time = time;
            if MEG
                send_trigger(trigID);
            end
            if eye_track
                eyelink('Message','Trigger %d',trigID);
            end
        end
        
                      
    end
end

