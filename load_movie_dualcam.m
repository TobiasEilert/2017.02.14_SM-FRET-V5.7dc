% Rewritten by R. Lewis 21/05/10
% tasks:
% load the movie in a structure called movie
% possibility to load from a dual camera setup, but then only TIF
% beadmap could be still SIF

% used functions and scripts:       (only self_written mentioned not MatLab)
% check_file_type
% sifread
% tifread

% used parameters:
% file
% cameraside
% alex

function [movie, info, green_start, total_frames, current_movie, breakpoint] = load_movie_dualcam(file, info, acceptor_file, alex, green_start, total_frames, frame_number, current_movie, rerun, breakpoint)
% 1. check whether the user loaded a TIF or SIF movie and find version of
% SIF
if rerun == 0
    file_type = check_file_type(file); %4.3 for SOLIS 4.3, 4.9 for SOLIS 4.9, 4.12 for SOLIS 4.12 and so on, 2 for Spooled New SIF, 3 for TIF
    % 2. check which frame is first, green excitation or red, but only for
    % alex movies and only in donor file
    if alex == 1 && acceptor_file == 0
        [green_start] = check_alex_frame_dualcam(file, file_type);
    end
end
% 3. load the movie according to the specified read-in routine
if file_type == 3
    [movie, info, total_frames, current_movie, breakpoint] = tifread_chunks(file, info, total_frames, frame_number, current_movie, rerun, breakpoint);
    if alex == 1 && acceptor_file == 1 && rerun == 0 %% acceptor file 1st load
        movie.imageData_red = movie.imageData(:,:,green_start+1:2:end);
        movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1);
    elseif alex == 1 && acceptor_file == 1 && rerun ~= 0 && green_start == 1 %% acceptor reload
        movie.imageData_red = movie.imageData(:,:,green_start+1:2:end);
        movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1);
    elseif alex == 1 && acceptor_file == 1 && rerun ~= 0 && green_start == 2 %% acceptor reload
        movie.imageData_red = movie.imageData(:,:,green_start-1:2:end);
        movie.imageData = movie.imageData(:,:,green_start:2:end);
    elseif alex == 1 && acceptor_file == 0 && rerun == 0 %% donor file 1st load
        movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1);
    elseif alex == 1 && acceptor_file == 0 && rerun ~= 0 && green_start == 1 %% donor file reload
        movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1);
    elseif alex == 1 && acceptor_file == 0 && rerun ~= 0 && green_start == 2 %% donor file reload
        movie.imageData = movie.imageData(:,:,green_start:2:end);
    end    
else
    excitation_check = 0;
    movie = sifread(file, file_type, excitation_check);
    info = 'SIF';
    % analyze_movie_dualcam must notice that a SIF file was loaded completely and no more reloads are coming
    if alex == 1 && acceptor_file == 1 && green_start == 1%% acceptor file load
        movie.imageData_red = movie.imageData(:,:,green_start+1:2:end);
        movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1);
    elseif alex == 1 && acceptor_file == 1 && green_start == 2 %% acceptor file load
        movie.imageData_red = movie.imageData(:,:,green_start-1:2:end);
        movie.imageData = movie.imageData(:,:,green_start:2:end);
    elseif alex == 1 && acceptor_file == 0 && green_start == 1 %% donor file load
        movie.imageData = movie.imageData(:,:,green_start:2:end-green_start+1);
    elseif alex == 1 && acceptor_file == 0 && green_start == 2 %% donor file load
        movie.imageData = movie.imageData(:,:,green_start:2:end);
    end
end
% 4. independent of file type the acceptor channel needs to be flipped at
% the y-Axis
if file_type == 3 && acceptor_file == 1
    movie.imageData = flipdim(movie.imageData,2);
end
if file_type == 3 && alex == 1 && acceptor_file == 1
    movie.imageData_red = flipdim(movie.imageData_red,2);
end

% 5. some variables have to generated
movie.columns = size(movie.imageData,2); % number of Pixel in x is divided by two because of dual colour detection
movie.rows = size(movie.imageData,1);    % number of y-Pixel
movie.size = size(movie.imageData,3); % number of Frames
if alex == 1
    movie.size = ceil(movie.size /2);
end