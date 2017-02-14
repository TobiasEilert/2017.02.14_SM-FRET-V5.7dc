%Read a character string.
%
% f      File handle
% o      String
function o=readString(f)
n=fscanf(f,'%d',1);
if isempty(n) || n < 0 || isequal(fgetl(f),-1)
   %fclose(f);
   disp('Inconsistent string.');
end
o=fread(f,[1 n],'uint8=>char');
