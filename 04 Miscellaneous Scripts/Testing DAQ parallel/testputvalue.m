ntests=10;

port = digitalio('parallel', 'LTP1'); %defines the port as an object called port
        addline(port, 0:3, 'out'); %lines 0-3, making them writeable (output)
        
for i=1:ntests
    tstart(1,i)=tic;
    
    putvalue(port, 1) % turns lead labelled BIT 0 on
    
    time_taken_on(1,i)=toc(tstart(1,i))*1000; %in ms
%     pause(0.001);%s
    WaitSecs(0.001);%ms
    
    putvalue(port, 0);
 %turns parallel port OFF
    
    time_taken_off(1,i)=toc(tstart(1,i))*1000; %in ms
        
%     pause(4);%s
    wait(4000)%ms
end

av_time_taken_on = mean(time_taken_on); %in ms
av_time_taken_off = mean(time_taken_off); %in ms


%PTB -> GetSecs
