% Rewritten by R. Lewis 21/10/09
% tasks:
% read Andor SIF multi-channel image files
% seperate the movie in left and right as well as green and red
% parts

% used functions and scripts:       (only self_written mentioned not MatLab)
% readSection

% used parameters:
% file
% file_type
% excitation_check

function [data,back,ref]=sifread(file, file_type, excitation_check) %     Read the image data, background and reference from file and  return the image data, background and reference in named structures
f=fopen(file,'r');
if f < 0
   error('Could not open the file.');
end
if ~isequal(fgetl(f),'Andor Technology Multi-Channel File')
   fclose(f);
   error('Not an Andor SIF image file.');
end
skipLines(f,1);
switch file_type
    case 4.3
        [data,next]=readSection_4_3(f,excitation_check);
        if nargout > 1 && next == 1
            [back,next]=readSection_4_3(f,excitation_check);
            if nargout > 2 && next == 1
                ref=back;
                back=readSection_4_3(f,excitation_check);
            else
                ref=struct([]);
            end
        else
            back=struct([]);
            ref=back;
        end
    case 4.9
        [data,next]=readSection_4_9(f,excitation_check);
        if nargout > 1 && next == 1
            [back,next]=readSection_4_9(f,excitation_check);
            if nargout > 2 && next == 1
                ref=back;
                back=readSection_4_9(f,excitation_check);
            else
                ref=struct([]);
            end
        else
            back=struct([]);
            ref=back;
        end
    case 4.12
        [data,next]=readSection_4_12(f,excitation_check);
        if nargout > 1 && next == 1
            [back,next]=readSection_4_12(f,excitation_check);
            if nargout > 2 && next == 1
                ref=back;
                back=readSection_4_12(f,excitation_check);
            else
                ref=struct([]);
            end
        else
            back=struct([]);
            ref=back;
        end
    case 4.15
        [data,next]=readSection_4_15(f,excitation_check);
        if nargout > 1 && next == 1
            [back,next]=readSection_4_15(f,excitation_check);
            if nargout > 2 && next == 1
                ref=back;
                back=readSection_4_15(f,excitation_check);
            else
                ref=struct([]);
            end
        else
            back=struct([]);
            ref=back;
        end
    case 2
        [data,next]=readSection_4_12_spool(f,excitation_check);
        if nargout > 1 && next == 1
            [back,next]=readSection_4_12_spool(f,excitation_check);
            if nargout > 2 && next == 1
                ref=back;
                back=readSection_4_12_spool(f,excitation_check);
            else
                ref=struct([]);
            end
        else
            back=struct([]);
            ref=back;
        end
end
fclose(f);
data.imageData = flipdim(data.imageData,2);
data.imageData = permute(data.imageData,[2 1 3]);