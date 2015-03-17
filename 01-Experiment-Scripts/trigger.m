function trigger

global triggerlength;

putvalue(port, 1);
WaitSecs(triggerlength);
putvalue(port, 0);
end