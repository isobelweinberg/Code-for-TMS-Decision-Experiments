try
%% Setup
% Keyboard
    %ListenChar(2);
    KbName('UnifyKeynames');
    esc_key = KbName('Escape');
    l_key = KbName('LeftArrow');
    r_key = KbName('RightArrow');
    u_key = KbName('UpArrow');
    d_key = KbName('DownArrow');

%% Variables
% Regarding the screen
    screen.no = 0;
    screen.background = 127.5;
    screen.diagonal = 14; % 14 for laptop

% Regarding the stimuli
    % How far one individual dot moves (in visual degrees)
    distance_travelled = 30;
    
    % the distance travelled needs to be even
    if mod(distance_travelled,2) ~= 0
        distance_travelled = distance_travelled+1;
    end 
    % Dot speed - pixels moved in one second
    pixl_speed = 240;
    % Frames per animation
    anim_frames = round(distance_travelled/pixl_speed *60);
    
    % Number of dot pairs
    n = 50;
    
    % Size of the box in visual degrees
    boxsize = 150;
    
    % Separation - or how peripheral the stimuli are
    separation = 200;
    
    % Disparity - proportion of the dots that are NOT paired
    disparity=0.5;
    sep=4;
    
    
%% Open Screen
    
    %HideCursor;
    screen.handle = Screen('OpenWindow', screen.no, screen.background, [0 0 1000 600]);
    screen.dimensions = Screen('Rect', screen.handle);
    screen.xcen = screen.dimensions(3)/2;
    screen.ycen = screen.dimensions(4)/2;
    
    
%% Locations
    rectangle= [screen.xcen-boxsize-separation  %screen.xcen+separation;
                screen.ycen-boxsize/2           %screen.ycen-boxsize/2;
                screen.xcen-separation          %screen.xcen+boxsize+separation;
                screen.ycen+boxsize/2]          + [-10; -10; 10;  10];   %screen.ycen+boxsize/2]
    
    fixation = [screen.xcen,    screen.xcen,    screen.xcen-10, screen.xcen+10;
                screen.ycen-10, screen.ycen+10, screen.ycen,    screen.ycen];
    
    
    Screen('FrameRect', screen.handle, 0, rectangle, 5);
    Screen('DrawLines', screen.handle, fixation, 4, 0);
    Screen('Flip', screen.handle);
    WaitSecs(1);
    
    
    
%% Presentation
while 1
    Screen('FrameRect', screen.handle, 0, rectangle, 5);
    Screen('DrawLines', screen.handle, fixation, 4, 0);
    Screen('DrawText', screen.handle, ['Seperation: ', num2str(sep*2), 'px Paired: ' num2str((1-disparity)*100), '%'], 0, 0);
    Screen('Flip', screen.handle);
    
    [secs, keyCode, ~] = KbWait;
    
    if keyCode(l_key)
        disparity = disparity-0.1;
        if disparity<0
            disparity=0;
            beep;
        end
            
    
    elseif  keyCode(r_key)
        disparity = disparity+0.1;
        if disparity>1
            disparity=1;
            beep;
        end
    elseif  keyCode(u_key)
        sep = sep+1;
        if sep>10
            sep=10;
            beep;
        end
    elseif  keyCode(d_key)
        sep = sep-1;
        if sep<2
            sep=2;
            beep;
        end
        
    elseif  keyCode(esc_key)
        
        break
    
    end
    
%% Dot Positions
        onset = randi(anim_frames, 1, n);
        frame_shifts = round(linspace(0, distance_travelled, anim_frames));

        x_shift = ones(1, n);
        y_shift = sep*ones(1, n);

        dot_positions_y = rand(1, n)*boxsize;
        dot_positions1_y = dot_positions_y + y_shift;
        dot_positions2_y = dot_positions_y - y_shift;

        dot_positions_x = rand(1, n)*boxsize;
        dot_positions1_x = dot_positions_x - distance_travelled/2;
        dot_positions2_x= dot_positions_x + distance_travelled/2;

        dot_positions_left_1 = zeros(2, n, 10*anim_frames);
        dot_positions_left_2 = zeros(2, n, 10*anim_frames);
        
        
        dot_positions1_x(1:round(disparity*n)) = rand(1, round(disparity*n))*boxsize;
        dot_positions2_x(1:round(disparity*n)) = rand(1, round(disparity*n))*boxsize;
        dot_positions1_y(1:round(disparity*n)) = rand(1, round(disparity*n))*boxsize;
        dot_positions2_y(1:round(disparity*n)) = rand(1, round(disparity*n))*boxsize;
        
        
        j=1;
        for iii = 1:10
            for ii = 1:anim_frames

                % The dots that have "finished" appear somewhere else
                for i = 1:n
                if mod(ii + onset(i), anim_frames) == 0

                    dot_positions1_x(i) =  rand*boxsize;
                    dot_positions2_x(i) = dot_positions1_x(i) + distance_travelled;
                    if i<=round(disparity*n)
                        dot_positions2_x(i) = rand*boxsize;
                    end

                    dot_positions1_y(i) = rand*boxsize;
                    dot_positions2_y(i) = dot_positions1_y(i) - 2*sep;
                    if i<=round(disparity*n)
                        dot_positions2_y(i) = rand*boxsize;
                    end
                end
                end

                % The dots get shifted by random frames in order to make them
                % asynchronised
                dot_positions_left_1(1, :, j) = dot_positions1_x + frame_shifts(mod(ii + onset, anim_frames)+1);
                dot_positions_left_1(2, :, j) = dot_positions1_y;

                dot_positions_left_2(1, :, j) = dot_positions2_x - frame_shifts(mod(ii + onset, anim_frames)+1);
                dot_positions_left_2(2, :, j) = dot_positions2_y;


                % any dots above or below the 
                j=j+1;
            end
        end
        stand_dot_positions = cat(2, dot_positions_left_1, dot_positions_left_2);
        stand_dot_positions = mod(stand_dot_positions, boxsize);
    
%% Dot presentation
    if ~exist(['sep', num2str(sep), 'paired', num2str((1-disparity)*100), '.avi'], 'file')
    
    for i = 1:10*anim_frames
        Screen('DrawDots', screen.handle, stand_dot_positions(:,:,i), 2, 0, [screen.xcen-separation-boxsize, screen.ycen-boxsize/2]);
        Screen('FrameRect', screen.handle, 0, rectangle, 5);
        Screen('DrawLines', screen.handle, fixation, 4, 0);
        Screen('DrawText', screen.handle, ['Seperation: ', num2str(sep*2), 'px Paired: ' num2str((1-disparity)*100), '%'], 0, 0);
        Screen('Flip', screen.handle);
        WaitSecs(0.1);
    end
    else
    for i = 1:10*anim_frames
        Screen('DrawDots', screen.handle, stand_dot_positions(:,:,i), 2, 0, [screen.xcen-separation-boxsize, screen.ycen-boxsize/2]);
        Screen('FrameRect', screen.handle, 0, rectangle, 5);
        Screen('DrawLines', screen.handle, fixation, 4, 0);
        Screen('DrawText', screen.handle, ['Seperation: ', num2str(sep*2), 'px Paired: ' num2str((1-disparity)*100), '%'], 0, 0);
        Screen('Flip', screen.handle);
        WaitSecs(0.1);
    end
    end
    
    
end
    
    
    
    
    
    
    
    
%% Shutdown
    sca;
    ListenChar(0);

    
catch err
    ListenChar(0);
    sca;
    rethrow(err);
    
end