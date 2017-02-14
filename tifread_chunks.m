% Rewritten 17/05/2010
% Read Andor TIF files.
% TIF files are now loaded in chunks instead of as a whole

function [data,info,total_frames,current_movie,breakpoint]=tifread_chunks(file, info, total_frames, frame_number, current_movie, rerun, breakpoint)
dummy=dir([file(1:end-4) '_X*.tif']);
path=file(1:max(strfind(file,'\')));
f = 0;
if rerun == 0;
    if size(dummy,1)>0
        if size(dummy,1) == 1
            info = imfinfo(file);
        else
            info = imfinfo([path dummy(1,:).name]);
        end
        infomax = imfinfo([path dummy(length(dummy),:).name]);
        total_frames = numel(info)*(size(dummy,1))+numel(infomax);
        if max(frame_number) >= total_frames
            index = frame_number > total_frames;
            frame_number = frame_number(~index);
        end
        columns = info(1,1).Width;
        rows = info(1,1).Height;
        breakpoint = length(info);
        current_movie = floor(max(frame_number) / breakpoint);
        data.imageData = zeros(columns,rows,length(frame_number));
        for i = frame_number
            f = f + 1;
            data.imageData(:,:,f) = imread(file,i);
        end
    elseif size(dummy,1)==0
        info = imfinfo(file);
        total_frames = length(info);
        if max(frame_number) >= total_frames
            index = frame_number > total_frames;
            frame_number = frame_number(~index);
        end
        columns = info(1,1).Width;
        rows = info(1,1).Height;        
        breakpoint = length(info);
        data.imageData = zeros(columns,rows,length(frame_number));
        for i = frame_number
            f = f + 1;
            data.imageData(:,:,f) = imread(file,i);
        end
    end
else
    if size(dummy,1)==0
        if max(frame_number) >= total_frames
            index = frame_number > total_frames;
            frame_number = frame_number(~index);
        end
        columns = info(1,1).Width;
        rows = info(1,1).Height;        
        data.imageData = zeros(columns,rows,length(frame_number));
        for i = frame_number
            f = f + 1;
            data.imageData(:,:,f) = imread(file,i);
            data.imageData = flipdim(data.imageData,1);
        end
        return
    end
    if max(frame_number) < breakpoint
        columns = info(1,1).Width;
        rows = info(1,1).Height;
        data.imageData = zeros(columns,rows,length(frame_number));
        if current_movie ~=0
            file = ([path dummy(current_movie,:).name]);
            frame_number = frame_number - breakpoint / (current_movie+1);
        end
        for i = frame_number
            f = f + 1;
            data.imageData(:,:,f) = imread(file,i);
        end
    else
        columns = info(1,1).Width;
        rows = info(1,1).Height;
        index = frame_number <= breakpoint;
        frame_number = frame_number(index);
        data.imageData = zeros(columns,rows,length(frame_number));
        if current_movie ~=0
            file = ([path dummy(current_movie,:).name]);
            frame_number = frame_number - breakpoint / (current_movie+1);
        end
        for i = frame_number
            f = f + 1;
            data.imageData(:,:,f) = imread((file),i);
        end        
%         
%         stop_frame = max(frame_number) - breakpoint;
%         frame_number = 1:1:stop_frame;
%         file = ([path dummy(next_movie,:).name]);
%         data.imageData(:,:,:) = data.imageData(:,:,end+1:end+stop_frame) + imread((file),frame_number);
%         disp(['appended file: ' dummy(next_movie,:).name]);
    end
end
data.imageData = flipdim(data.imageData,1);