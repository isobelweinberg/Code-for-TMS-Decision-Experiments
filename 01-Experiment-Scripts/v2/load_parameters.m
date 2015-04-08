function [params] = load_parameters

% Timings
params.StimulusDuration = 1000; %ms - how long participant gets to make a response
params.FixationDuration = 400; %length of fixation, milliseconds
params.FeedbackDuration = 200; %milliseconds
params.MinITIDuration = 2500; %ms
params.MaxITIDuration = 3500; %maximum lenth of intertrial interval, milliseconds
params.TriggerLength = 0.1; %TMS stimulus duration, MILLISECONDS

% Stimulus Properties
params.DotSpeed = 2.5; %pixels
params.NumDots = 300;
params.ApertureRadius = 200; %pixels; radius of circular aperture for RDK
params.DotSpeed = 1500; %pixels per second
params.FixationRadius = 2.5; %pixels; radius of fixation dot
params.BackgroundColour = 255; %white
params.DotColour = [0 0 0]; %black

end