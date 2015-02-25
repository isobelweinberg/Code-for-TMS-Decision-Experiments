i=1;
for i=1:10
    tstart(1,i)=tic;
    
    outportb(888, 1); % turns lead labelled BIT 0 on
    
    time_taken_on(1,i)=toc(tstart(1,i))*1000; %in ms
    wait(1);
    
    outportb(888, 0); %turns parallel port OFF
    
    time_taken_off(1,i)=toc(tstart(1,i))*1000; %in ms
        
    wait(4000);
end

av_time_taken_on = mean(time_taken_on); %in ms


%PTB -> GetSecs