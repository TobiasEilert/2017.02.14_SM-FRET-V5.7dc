%Read a file section. 
% 
% f File handle 
% info Section data 
% next Flags if another section is available 
% 
function [info,next]=readSection_4_12(f,excitation_check) 
fscanf(f,'%d',6);
skipBytes(f,10); 
o=fscanf(f,'%f',5); 
info.exposureTime=o(2); 
info.cycleTime=o(3); 
info.accumulateCycles=o(5); 
info.accumulateCycleTime=o(4); 
skipBytes(f,2); 
o=fscanf(f,'%f',2); 
info.stackCycleTime=o(1); 
info.pixelReadoutTime=o(2); 
o=fscanf(f,'%f',3); 
info.gainDAC=o(3); 
skipBytes(f,68);
o =fscanf(f,'%f',1);
info.temperature=o(1);
skipLines(f,1); 
info.detectorType=readLine(f); 
info.detectorSize=fscanf(f,'%f',[1 2]); 
info.fileName=readString(f); 
skipLines(f,3); 
skipBytes(f,14); 
info.shutterTime=fscanf(f,'%f',[1 2]); 
skipLines(f,14); 
skipBytes(f,7);
%if strmatch('Luc',info.detectorType) 
%   skipLines(f,9); % Andor Luca 
%end 
info.frameAxis=readString(f); 
info.dataType=readString(f); 
info.imageAxis=readString(f); 
o=fscanf(f,'65538 %d %d %d %d %d %d %d %d 65538 %d %d %d %d %d %d',14); 
info.imageArea=[o(1) o(4) o(6);o(3) o(2) o(5)]; 
info.frameArea=[o(9) o(12);o(11) o(10)]; 
info.frameBins=[o(14) o(13)]; 
s=(1 + diff(info.frameArea))./info.frameBins; 
z=1 + diff(info.imageArea(5:6)); 
if prod(s) ~= o(8) || o(8)*z ~= o(7) 
   fclose(f); 
   error('Inconsistent image header.'); 
end 
for n=0:z 
   readLine(f);
    %skipBytes(f,11);
   %o=readString(f); 
   %if numel(o) 
    %  fprintf('%s\n',o); % comments 
   %end 
end
%info.timeStamp=fread(f,1,'uint16'); 
%skipBytes(f,2); 
if excitation_check == 1
    info.imageData=reshape(fread(f,prod(s)*10,'single=>uint16'),[s 10]); 
elseif excitation_check == 2
    info.imageData=reshape(fread(f,prod(s)*25,'single=>uint16'),[s 25]); 
else
    info.imageData=reshape(fread(f,prod(s)*z,'single=>uint16'),[s z]); 
end
%o=readString(f);           % ???
%if numel(o)
   %fprintf('%s\n',o);      % ???
%end
next=fscanf(f,'%d',1);