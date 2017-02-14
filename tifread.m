%Read Andor TIF files.
function [data]=tifread(file,excitation_check)
dummy=dir([file(1:end-4) '_X*.tif']);
path=file(1:max(strfind(file,'\')));
old=1;
if size(dummy,1)>0 && excitation_check ~= 1
    if size(dummy,1) == 1
        info = imfinfo(file);
    else
        info = imfinfo([path dummy(1,:).name]);
    end
    infomax = imfinfo([path dummy(length(dummy),:).name]);
    bla = numel(info)*(size(dummy,1))+numel(infomax);
    frames = length(info);
    data.imageData = ones(512,512,bla,'int16');
    for i = old:frames
        data.imageData(:,:,i) = imread(file,i);
    end
    for i = 1:size(dummy,1)
        file=([path dummy(i,:).name]);
        info = imfinfo(file);
        old = old+frames;
        frames = old-1+length(info);
        f=0;
        for j = old:frames
            f=f+1;
            data.imageData(:,:,j) = imread(([path dummy(i,:).name]),f);
        end
        disp(['appended file: ' dummy(i,:).name]);
        frames = length(info);
    end
elseif size(dummy,1)==0 && excitation_check ~= 1
    info = imfinfo(file);
    data.imageData=zeros(512,512,size(info,1));
    frames = length(info);
    for i = old:frames
        data.imageData(:,:,i) = imread(file,i);
    end
elseif excitation_check == 1
    data.imageData=zeros(512,512,10);
    for i = 1:10
        data.imageData(:,:,i) = imread(file,i);
    end
elseif excitation_check == 2
    data.imageData=zeros(512,512,25);
    for i = 1:25
        data.imageData(:,:,i) = imread(file,i);
    end
end
data.imageData = flipdim(data.imageData,1);

