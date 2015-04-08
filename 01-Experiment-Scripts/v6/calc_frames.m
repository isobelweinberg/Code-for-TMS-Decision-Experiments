function [params] = calc_frames(params, screen)
% Calculate the frames
params.TotalNumFrames = ceil((params.StimulusDuration/1000)*screen.RefreshRate); %this is how many frames we need for the stimulus
params.IFI = 1/screen.RefreshRate; %interframe interval, seconds
end