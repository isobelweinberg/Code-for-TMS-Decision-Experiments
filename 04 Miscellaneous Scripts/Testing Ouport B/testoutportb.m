% TMS.port = 3; %which bit in the parallel port the TMS is taking orders from - FIND THIS OUT!
% TMS.triggerport = 0; %which bit in the parallel port the TMS talks to the trigger computer - FIND THIS OUT!

% start_cogent;
% time_before=time; %in ms
tstart=tic;
outportb(888, 1);
wait(1);
outportb(888, 0);
tend=toc;
time_taken=toc(tstart);
time_taken2=tend-tstart;
% outportb(888, 2^TMS.port);
% wait (1); %duration of pulse in number of milliseconds
% outportb(888, 0);

% time_after=time;
% 
% stop_cogent;

%PTB -> GetSecs