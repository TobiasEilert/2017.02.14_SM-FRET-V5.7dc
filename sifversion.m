% Rewritten by R. Lewis 21/10/09
% tasks:
% check the version of the SIF file (i.e 4.3, 4.9, 4.12 or spooled 4.12)

% used functions and scripts:       (only self_written mentioned not MatLab)

% used parameters:
% file
% file_type

function [file_type]=sifversion(file)
file_type = [];
o = fscanf(file,'%f',6);
temperature = o(6);
if temperature == -999 %%% where usually the temperature is, in 4.12 non-spooled movies there is -999
    file_type = 4.12;
end
skipBytes(file,143);
dummy = fscanf(file,'%f',4);
version = dummy(3);
if version == 12 && temperature ~= -999 % if a spooled 4.12 movie the version indicator says 12, but the temperature is stored at the position like before 4.12
    file_type = 2;
    return
end
if version == 67305472 % in a old 4.3 SIF file there is a arbitrary (?),but otherwise constant number 
   file_type = 4.3;
    return
end
skipBytes(file,2);
dummy = fscanf(file,'%f',1);
if dummy == 9
    file_type = 4.9;
    return
end
if dummy == 5 || dummy == 15
    file_type = 4.15;    
end
dummy = fscanf(file,'%f',1);
if dummy == 7305472 % sometimes the position of this number changes
    file_type = 4.3;
    return
end
dummy = fscanf(file,'%f',3);
length_dummy = length(dummy);
if length_dummy > 1
    version = dummy(2);
end
if version == 9 % the version indicator in 4.9 SIF files says 9 instead of 12
    file_type = 4.9;
    return
elseif version == 12
    file_type = 4.12;
    return
elseif version == 15
    file_type = 4.15;
    return
else
    if length_dummy > 2
    version = dummy(3);
    end
end
if version == 9
    file_type = 4.9;
    return
else
    version = dummy(1);    
end
if version == 9 % just in case there is yet another version, the indicator is double-checked
    file_type = 4.9;
    return
elseif version == 15 %there is a new version 4.15 now
    file_type = 4.15;
    return
elseif file_type == 4.15
    return
else
    file_type = 4.9;
end