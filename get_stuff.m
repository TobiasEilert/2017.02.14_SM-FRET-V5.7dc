function stuff = get_stuff(prompt,title,default)
stuff = [];
default = num2str(default);
default = {default};
answer = inputdlg(prompt,title,1,default);
answer = answer(1);
answer_string = cell2mat(answer);
stuff = str2num(answer_string);
