%A function to avoid the character limit problem that occurs in uigetfile.
%The user it's only able to see the files given by the extention string
function [file path] = getLongFiles(extension)
path = [uigetdir '\'];
if isdir(path) == 1
    Files = dir(strcat(path,extension));
    if ~isempty(Files)
        file = {Files.name};
        s = listdlg('ListString', file,'ListSize',[400 200]);
        if ~isempty(s)
            file = file(s);
        else
            file = [];
            path = [];
        end
    else
        file = [];
        path = [];
    end
end