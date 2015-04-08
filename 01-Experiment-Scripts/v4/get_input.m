function [participant] = get_input
% Open a dialogue box to get participant's details
prompt = {'Enter name (use underscores):', 'Age:'};
dlg_title = 'Participant Details';
num_lines = 1;
default = {'Test', '25'};
input = inputdlg(prompt,dlg_title,num_lines,default);
participant.Name = input{1};
participant.Age = input{2};
end
