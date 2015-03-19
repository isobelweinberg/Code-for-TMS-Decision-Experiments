function triggertime = sendtrigger(port)

global triggerlength;

triggertime = GetSecs;
putvalue(port, 1);
WaitSecs(triggerlength/1000);
putvalue(port, 0);
end