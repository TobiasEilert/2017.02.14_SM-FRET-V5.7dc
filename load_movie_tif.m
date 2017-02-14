% Rewritten by R. Lewis 21/05/10
% tasks:
% load the movie as chunks in a structure called movie
% designed only for loading from a single camera setup

% used functions and scripts:       (only self_written mentioned not MatLab)
% check_file_type
% sifread
% tifread

% used parameters:
% file
% cameraside
% alex

function [movie, info, green_start, total_frames, current_movie, breakpoint] = load_movie_tif(file, info, cameraside, alex, green_start, total_frames, frame_number, current_movie, rerun, breakpoint)
% 1. check whether the user loaded a TIF or SIF movie and find version of
% SIF
if rerun == 0
    file_type = check_file_type(file); %4.3 for SOLIS 4.3, 4.9 for SOLIS 4.9, 4.12 for SOLIS 4.12 and so on, 2 for Spooled New SIF, 3 for TIF
    if file_type ~= 3
        errordlg('Only TIF files allowed', 'File Error');
        return
    else
        file_type = 3;
    end
    % 2. check which frame is first, green excitation or red, but only for alex movies
    if cameraside ~=0 && alex == 1
        [green_start] = check_alex_frame(file, file_type);
    end
end
% 3. load the movie according to the specified read-in routine
[movie, info, total_frames, current_movie, breakpoint] = tifread_chunks(file, info, total_frames, frame_number, current_movie, rerun, breakpoint);

% 4. some variables have to generated
movie.columns = size(movie.imageData,2); % number of Pixel in x is divided by two because of dual colour detection
movie.size = size(movie.imageData,3); % number of Frames
movie.rows = size(movie.imageData,1);    % number of y-Pixel
if cameraside ~= 0
    movie.columns = movie.columns /2;
    if alex == 1
        movie.size = ceil(movie.size/2);  % number of Frames and time points has to be one half
    end
end

% 5. the movie has to be seperated in time and space
% returns a structure according with the same name to overwrite existing
% data and avoid filling RAM
if alex == 1 && rerun == 0
    switch cameraside
        case 0
            movie.imageData = movie.imageData(:,:,:); %load all frames            
        case 1
            disp('WARNING: ALEX analysis of only one channel !!!')
            movie.imageData = movie.imageData(:,1:movie.columns,green_start:2:end);   % reduce to left part and every second frame
        case 2
            disp('WARNING: ALEX analysis of only one channel !!!')
            movie.imageData_red = movie.imageData(:,movie.columns+1:end,green_start+1:2:end);   % reduce to right part and every second frame
            movie.imageData = movie.imageData(:,movie.columns+1:end,green_start:2:end-green_start+1);   % reduce to right part and every other frame
        case 3
            movie.imageData_red = movie.imageData(:,movie.columns+1:end,green_start+1:2:end); % load frames with red excitation but only right side
            movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1); %load frames with green excitation but the whole
    end %switch
elseif alex == 1 && rerun ~= 0 && green_start == 1
    switch cameraside
        case 0
            movie.imageData = movie.imageData(:,:,:); %load all frames
        case 1
            disp('WARNING: ALEX analysis of only one channel !!!')
            movie.imageData = movie.imageData(:,1:movie.columns,green_start:2:end);   % reduce to left part and every second frame
        case 2
            disp('WARNING: ALEX analysis of only one channel !!!')
            movie.imageData_red = movie.imageData(:,movie.columns+1:end,green_start+1:2:end);   % reduce to right part and every second frame
            movie.imageData = movie.imageData(:,movie.columns+1:end,green_start:2:end-green_start+1);   % reduce to right part and every other frame
        case 3
            movie.imageData_red = movie.imageData(:,movie.columns+1:end,green_start+1:2:end); % load frames with red excitation but only right side
            movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1); %load frames with green excitation but the whole
    end %switch
elseif alex == 1 && rerun ~= 0 && green_start == 2
    switch cameraside
        case 0
            movie.imageData = movie.imageData(:,:,:); %load all frames
        case 1
            disp('WARNING: ALEX analysis of only one channel !!!')
            movie.imageData = movie.imageData(:,1:movie.columns,green_start:2:end);   % reduce to left part and every second frame
        case 2
            disp('WARNING: ALEX analysis of only one channel !!!')
            movie.imageData_red = movie.imageData(:,movie.columns+1:end,green_start-1:2:end);   % reduce to right part and every second frame
            movie.imageData = movie.imageData(:,movie.columns+1:end,green_start:2:end);   % reduce to right part and every other frame
        case 3
            movie.imageData_red = movie.imageData(:,movie.columns+1:end,green_start-1:2:end); % load frames with red excitation but only right side
            movie.imageData = movie.imageData(:,:,green_start:2:end); %load frames with green excitation but the whole
    end %switch
else
    switch cameraside % normal FRET analyis, only green excitation
        case 1
            movie.imageData = movie.imageData(:,1:movie.columns,:);
        case 2
            movie.imageData = movie.imageData(:,movie.columns+1:end,:);
        case 3
            movie.imageData = movie.imageData(:,:,:); %load all frames
    end %switch
end