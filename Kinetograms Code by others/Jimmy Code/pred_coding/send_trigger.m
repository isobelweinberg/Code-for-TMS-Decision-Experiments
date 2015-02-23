function send_trigger(trig_ID)

outportb(888, trig_ID);
wait(3);
outportb(888, 0);
