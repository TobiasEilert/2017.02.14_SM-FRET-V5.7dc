% Rewritten by R. Lewis 09/02/11 out of load_movie
% tasks:
% load the a movie in a structure called movie
% construct a polynomial function to map two sides of 1 camera or the whole
% of 2 cameras
% IMPORTANT: only first 25 frames of files are opened

% used functions and scripts:       (only self_written mentioned not MatLab)
% check_file_type
% sifread
% tifread

% used parameters:
% file
% cameraside (can only be 0 or 3 depending on dualcam or singlecam setup)
% alex (parameter is dropped here, as beadmaps cannot be taken using ALEX)
% excitation_check (0 for all frames, 1 for first 10 frames, 2 for first 25
% frames)

function [movie] = load_map(file, cameraside, alex)
excitation_check = 2; %only first 25 frames need to be loaded

% 1. check whether the user loaded a TIF or SIF movie and find version of
% SIF
file_type = check_file_type(file); %1.3 for SOLIS 4.3, 1.9 for SOLIS 4.9, 1.12 for SOLIS 4.12 and so on, 2 for TIF, 3 for Spooled New SIF,

% 2. load the movie according to the specified read-in routine
if file_type ~= 3
    movie = sifread(file, file_type, excitation_check);
else
    movie = tifread(file, excitation_check);
end

% 3. some variables have to generated
movie.columns = size(movie.imageData,2); % number of Pixel in x is divided by two because of dual colour detection
movie.rows = size(movie.imageData,1);    % number of y-Pixel
movie.size = size(movie.imageData,3); % number of Frames

