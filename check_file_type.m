% Rewritten by R. Lewis 21/10/09
% tasks:
% check the movie file type (i.e. TIF, Old & New SIF, Spooled SIF)

% used functions and scripts:       (only self_written mentioned not MatLab)

% used parameters:
% file
% file_type

function [file_type]=check_file_type(file)
f=fopen(file,'r');
if f < 0
   error('There is no file to be opened');
end
if ~isequal(fgetl(f),'Andor Technology Multi-Channel File')
   fclose(f);
   type = imfinfo(file);
   tif_size = length(type);
   if tif_size > 1
       type = type(1,1);
   end
   if isequal(type.Format,'tif')
     file_type = 3; %%% it is definitely a TIF file
   end
else % must be a SIF file or elseif for future data types
   skipLines(f,1);
   [file_type] = sifversion(f);
   fclose(f);
end