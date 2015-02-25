
tstart=tic;
outportb(888, 1);
time_taken_on=toc(tstart)*1000; %in ms
wait(1);
outportb(888, 0);
time_taken_off=toc(tstart)*1000; %in ms


%PTB -> GetSecs