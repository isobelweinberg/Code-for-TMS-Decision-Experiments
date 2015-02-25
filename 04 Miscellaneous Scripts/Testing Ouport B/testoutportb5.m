ntests=100;
pause on
for i=1:ntests
    t1(1,i)=tic;
    
    outportb(888, 1); % turns lead labelled BIT 0 on
    
    time_taken_on(1,i)=toc(t1(1,i))*1000; %in ms
    
    %pause -> MATLAB, wait -> Cogent, WaitSecs -> PTB
%     pause(0.001);%s
    wait(1);%ms
%     WaitSecs(0.001);%s
    
    t2(1,i)=tic;
    outportb(888, 0); %turns parallel port OFF
    
   
    time_taken_off(1,i)=toc(t2(1,i))*1000; %in ms
    time_taken_total(1,i)=toc(t1(1,i))*1000;%in ms
        
%     pause(4);%s
    wait(4000);%ms
%     WaitSecs(4);%s
end

av_time_taken_on = mean(time_taken_on); %in ms
av_time_taken_off = mean(time_taken_off); %in ms
av_time_taken_total=mean(time_taken_total);%in ms

%PTB -> GetSecs