% Rewritten by R. Lewis 21/10/09
% tasks:
% check which frame is first in the movie (green or red)
% give back the start frame for green and red excitation
% automatically one knows when the movie starts

% used functions and scripts:       (only self_written mentioned not MatLab)
% sifread
% tifread

% used parameters:
% file
% file_type

function [green_start] = check_alex_frame(file, file_type)

% 1. dependent on the file type select a read-in routine
excitation_check = 1; %for the the frame_check not the whole video has to be loaded
if file_type ~= 3
    movie = sifread(file, file_type, excitation_check);
    movie.imageData = flipdim(movie.imageData,2);    %mirror the y-coordinates (flip horizontally), because Andor is counting from the bottom left corner and not like MatLab from the top left
    movie.imageData = permute(movie.imageData,[2 1 3]);   %permute, so that MatLab counts the rows as columns, Andor saves the movie not left and right but above and below
else
    movie = tifread(file, excitation_check);
end

% 2. extract important parameters from the movie (e.g. length, height,
% width)
movie.columns = size(movie.imageData,2)/2; % number of Pixel in x is divided by two because of dual colour detection
movie.rows = size(movie.imageData,1); 
movie.frames = size(movie.imageData,3);
movie_left = movie.imageData(:,1:movie.columns,end-3:end);
movie_right = movie.imageData(:,movie.columns+1:end,end-3:end);

% 3. correct for minimum intensity
min_pix_intensity_left = min(min(min(movie_left(:,:,1:end))));
min_pix_intensity_right = min(min(min(movie_right(:,:,1:end))));
movie_left = movie_left - min_pix_intensity_left;
movie_right = movie_right - min_pix_intensity_right;

% 4. calculate average of the potential green and red frames
movie_left_average = mean(movie_left(:,:,1:end),3);
movie_right_average = mean(movie_right(:,:,1:end),3);

% 5. calculate local background
backgnd_left = ones(movie.rows, movie.columns);
for i = 8:16:movie.rows-8
    for j = 8:16:movie.columns-8
        backgnd_left(i-7:i+8,j-7:j+8) = min(min(movie_left_average(i-7:i+8,j-7:j+8)));
    end
end
backgnd_right = ones(movie.rows, movie.columns);
for i = 8:16:movie.rows-8
    for j = 8:16:movie.columns-8
        backgnd_right(i-7:i+8,j-7:j+8) = min(min(movie_right_average(i-7:i+8,j-7:j+8)));
    end
end
h = ones(20,20) / 400;
backgnd_left = imfilter(backgnd_left,h, 'replicate');
backgnd_right = imfilter(backgnd_right,h, 'replicate');

% 6. subtract local background
movie_left_correct = movie_left_average - backgnd_left;
        clear movie_left_average;
        clear backgnd_left;
movie_right_correct = movie_right_average - backgnd_right;
        clear movie_right_average;
        clear backgnd_right;

% 7. a threshold has to be determined
thresh = 0.98;
temp = sort(reshape(movie_left_correct,movie.rows.*movie.columns,1));    
threshold_left = round(temp(round(thresh*movie.rows*movie.columns),1));
temp = sort(reshape(movie_right_correct,movie.rows.*movie.columns,1));
threshold_right = round(temp(round(thresh*movie.rows*movie.columns),1));
clear temp;

% 8. all signal above threshold has to be integrated
% also the time has to be seperated now
left_frame_odd = sum(movie_left(movie_left(:,:,1:2:end) > threshold_left));
right_frame_odd = sum(movie_right(movie_right(:,:,1:2:end) > threshold_right));
left_frame_even = sum(movie_left(movie_left(:,:,2:2:end) > threshold_left));
right_frame_even = sum(movie_right(movie_right(:,:,2:2:end) > threshold_right));

% 9. comparison of even and odd frames
% in real ALEX the odd frames should be excited with green laser, while the
% even ones are excited with red laser
% so while exciting red, the left side should be "dark" and below threshold
% and in the same time below the right side and the following left side
% in case the first frame is black or the sequence is flipped, then the odd
% frames will be red
if left_frame_odd > left_frame_even && right_frame_even > left_frame_even 
    green_start = 1;
elseif left_frame_even > left_frame_odd && right_frame_odd > left_frame_odd 
    green_start = 2;
else % in case something is switched differently, one should still take all the frames
    green_start = 1;
end