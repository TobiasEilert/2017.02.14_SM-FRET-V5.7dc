% Rewritten by R. Lewis 21/10/09
% tasks:
% it is clear that the _DON movies are the green channel
% so check which frame is first in the green movie
% give back the start frame for green excitation
% automatically one knows when the movie starts
% take all frames after that from the files

% used functions and scripts:       (only self_written mentioned not MatLab)
% sifread
% tifread

% used parameters:
% file
% file_type

function [green_start] = check_alex_frame_dualcam(file, file_type)
% 1. dependent on the file type select a read-in routine
excitation_check = 1; %for the the frame_check not the whole video has to be loaded
if file_type ~= 3
    movie = sifread(file, file_type, excitation_check);
    movie.columns = size(movie.imageData,2);
    movie.rows = size(movie.imageData,1);     
else
    movie = tifread(file, excitation_check);
    movie.columns = size(movie.imageData,1);
    movie.rows = size(movie.imageData,2); 
end

% 2. extract important parameters from the movie (e.g. length, height,
% width)
movie.frames = size(movie.imageData,3);
movie_all = movie.imageData(:,:,end-3:end);

% 3. correct for minimum intensity
min_pix_intensity = min(min(min(movie_all(:,:,1:end))));
movie_all = movie_all - min_pix_intensity;
movie_odd = movie_all(:,:,1:2:end-1);
movie_even = movie_all(:,:,2:2:end);

% 4. calculate at which frame the movie starts
movie_odd_average = mean(movie_all(:,:,1:2:end-1),3);
movie_even_average = mean(movie_all(:,:,2:2:end),3);

% 5. calculate local background
backgnd_odd = ones(movie.rows, movie.columns);
for i = 8:16:movie.rows-8
    for j = 8:16:movie.columns-8
        backgnd_odd(i-7:i+8,j-7:j+8) = min(min(movie_odd_average(i-7:i+8,j-7:j+8)));
    end
end
backgnd_even = ones(movie.rows, movie.columns);
for i = 8:16:movie.rows-8
    for j = 8:16:movie.columns-8
        backgnd_even(i-7:i+8,j-7:j+8) = min(min(movie_even_average(i-7:i+8,j-7:j+8)));
    end
end
h = ones(20,20) / 400;
backgnd_odd = imfilter(backgnd_odd,h, 'replicate');
backgnd_even = imfilter(backgnd_even,h, 'replicate');

% 6. subtract local background
movie_odd_correct = movie_odd_average - backgnd_odd;
        clear movie_odd_average;
        clear backgnd_odd;
movie_even_correct = movie_even_average - backgnd_even;
        clear movie_even_average;
        clear backgnd_even;

% % 7. a threshold has to be determined
% thresh = 0.98;
% temp = sort(reshape(movie_odd_correct,movie.rows.*movie.columns,1));    
% threshold_odd = round(temp(round(thresh*movie.rows*movie.columns),1));
% temp = sort(reshape(movie_even_correct,movie.rows.*movie.columns,1));
% threshold_even = round(temp(round(thresh*movie.rows*movie.columns),1));
% clear temp;

% 8. all signal above threshold has to be integrated
% also the time has to be seperated now
odd_frame = sum(sum(sum(movie_odd)));%(movie_odd > threshold_odd));
even_frame = sum(sum(sum(movie_even)));%(movie_even > threshold_even));

% 9. comparison of even and odd frames
% in real ALEX the odd frames should be excited with green laser, while the
% even ones are excited with red laser
% so while exciting red, the green channel should be "dark" and below threshold
% and in the same time below the following frame
% in case the first frame is black or the sequence is flipped, then the odd
% frames will be red
if odd_frame > even_frame
    green_start = 1;
elseif even_frame > odd_frame
    green_start = 2;
else % in case something is switched differently, one should still take all the frames
    green_start = 1;
end