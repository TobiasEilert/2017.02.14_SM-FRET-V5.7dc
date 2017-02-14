% Rewritten by R. Lewis 21/10/09
% tasks:
% load the movie
% find the peaks
% calculate intensity-trace and background
% save data


% used functions and scripts:       (only self_written mentioned not MatLab)
% load_movie
% circle

% used parameters:
% stop_frame_map
% half_region
% cameraside
% start and endframe for averaging movieframes for peakfinding
function result = analyze_movie(filename, thresh, half_region, cameraside, correct_min, correct_backgnd, map, alex, start_frame, stop_frame)
disp('Loading movie ...');
% 1. load the movies and pack in structure
%  .imageData : Array with Pixelcounts(y, x, t) !!!
%  .size : Timesteps
%  .columns : Number of x-Pixel
%  .rows : Number of y-Pixel
% Caution: movie.imageData consists only of right or left half of camera
% when using cameraside 1 or 2
[movie] = load_movie(filename, cameraside, alex);

% 2. reduce end frame of movie when using ALEX
if stop_frame == 0
    stop_frame = movie.size;
elseif stop_frame > movie.size || stop_frame*1.5 > movie.size
    stop_frame = floor(movie.size*0.66);
end

% 3. calculate minimum
% first data_correction : absolutes Minimum berechnen
if alex == 1
    switch cameraside
        case 1
            min_pix_intensity_green = min(min(min(movie.imageData(:,:,start_frame:stop_frame))));
            max_pix_intensity_green = max(max(max(movie.imageData(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for LEFT:  ' num2str(min_pix_intensity_green)]);
            disp([' Maximum pixel intensity for LEFT:  ' num2str(max_pix_intensity_green)]);
        case 2
            min_pix_intensity_green = min(min(min(movie.imageData(:,:,start_frame:stop_frame))));
            max_pix_intensity_green = max(max(max(movie.imageData(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for RIGHT (Green Excitation):  ' num2str(min_pix_intensity_green)]);
            disp([' Maximum pixel intensity for RIGHT (Green Excitation):  ' num2str(max_pix_intensity_green)]);
            min_pix_intensity_red = min(min(min(movie.imageData_red(:,:,start_frame:stop_frame))));
            max_pix_intensity_red = max(max(max(movie.imageData_red(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for RIGHT (Red Excitation):  ' num2str(min_pix_intensity_red)]);
            disp([' Maximum pixel intensity for RIGHT (Red Excitation):  ' num2str(max_pix_intensity_red)]);
        case 3
            min_pix_intensity_left = min(min(min(movie.imageData(:,1:movie.columns,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
            max_pix_intensity_left = max(max(max(movie.imageData(:,1:movie.columns,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
            disp([' Minimum pixel intensity for LEFT:  ' num2str(min_pix_intensity_left)]);
            disp([' Maximum pixel intensity for LEFT:  ' num2str(max_pix_intensity_left)]);
            min_pix_intensity_right = min(min(min(movie.imageData(:,movie.columns+1:end,start_frame:stop_frame))));
            max_pix_intensity_right = max(max(max(movie.imageData(:,movie.columns+1:end,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for RIGHT:  ' num2str(min_pix_intensity_right)]);
            disp([' Maximum pixel intensity for RIGHT:  ' num2str(max_pix_intensity_right)]);
            min_pix_intensity_red = min(min(min(movie.imageData_red(:,:,start_frame:stop_frame))));
            max_pix_intensity_red = max(max(max(movie.imageData_red(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for RED:  ' num2str(min_pix_intensity_red)]);
            disp([' Maximum pixel intensity for RED:  ' num2str(max_pix_intensity_red)]);
    end
else
    if cameraside ~= 3
        min_pix_intensity = min(min(min(movie.imageData(:,:,start_frame:stop_frame))));
        max_pix_intensity = max(max(max(movie.imageData(:,:,start_frame:stop_frame))));
        disp(['Minimum pixel intensity: ' num2str(min_pix_intensity)]);
        disp(['Maximum pixel intensity: ' num2str(max_pix_intensity)]);
    else
        min_pix_intensity_left = min(min(min(movie.imageData(:,1:movie.columns,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
        max_pix_intensity_left = max(max(max(movie.imageData(:,1:movie.columns,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
        disp([' Minimum pixel intensity for LEFT:  ' num2str(min_pix_intensity_left)]);
        disp([' Maximum pixel intensity for LEFT:  ' num2str(max_pix_intensity_left)]);
        min_pix_intensity_right = min(min(min(movie.imageData(:,movie.columns+1:end,start_frame:stop_frame))));
        max_pix_intensity_right = max(max(max(movie.imageData(:,movie.columns+1:end,start_frame:stop_frame))));
        disp([' Minimum pixel intensity for RIGHT:  ' num2str(min_pix_intensity_right)]);
        disp([' Maximum pixel intensity for RIGHT:  ' num2str(max_pix_intensity_right)]);
    end
end
disp('Movie loaded...');

% 4. correct for minimum intensity
if correct_min == 1
    if alex == 1
        switch cameraside
            case 1
                movie.imageData = movie.imageData - min_pix_intensity_green;
            case 2
                movie.imageData = movie.imageData - min_pix_intensity_green;
                movie.imageData_red = movie.imageData_red - min_pix_intensity_red;
            case 3
                movie.imageData(:,1:movie.columns,:) = movie.imageData(:,1:movie.columns,:) - min_pix_intensity_left;
                movie.imageData(:,movie.columns+1:end,:) = movie.imageData(:,movie.columns+1:end,:) - min_pix_intensity_right;
                movie.imageData_red(:,1:movie.columns,:) = movie.imageData_red - min_pix_intensity_red;
        end
    else
        if cameraside ~= 3
            movie.imageData = movie.imageData - min_pix_intensity;
        else
            movie.imageData(:,1:movie.columns,:) = movie.imageData(:,1:movie.columns,:) - min_pix_intensity_left;
            movie.imageData(:,movie.columns+1:end,:) = movie.imageData(:,movie.columns+1:end,:) - min_pix_intensity_right;
        end
    end
end

% 5. generate arrays for peakfinding by time averaging
% use map, to map left hand site to right hand site
switch cameraside
    case 1
        left = mean(movie.imageData(:,:,start_frame:stop_frame),3);
    case 2
        right = mean(movie.imageData(:,:,start_frame:stop_frame),3);
        if alex == 1
            right_red = mean(movie.imageData_red(:,:,start_frame:stop_frame),3);
        end
    case 3
        if alex == 1
            frame_average_green = mean(movie.imageData(:,:,ceil(stop_frame*0.66):ceil(stop_frame*1.5)),3);
            [left, xdata, ydata] = imtransform(frame_average_green(:,1:movie.columns),map,'Fill',0,'XData', [1 movie.columns], 'YData', [1, movie.rows]);
            right = mean(movie.imageData(:,movie.columns+1:end,start_frame:stop_frame),3);
            combined = left + right;
            right_red = mean(movie.imageData_red(:,:,start_frame:stop_frame),3);
            frame_average_green(:,movie.columns+1:end) = frame_average_green(:,movie.columns+1:end) + right + right_red;
        else
            frame_average = mean(movie.imageData(:,:,start_frame:stop_frame),3);
            [left, xdata, ydata] = imtransform(frame_average(:,1:movie.columns),map,'Fill',0,'XData', [1 movie.columns], 'YData', [1, movie.rows]);
            right = mean(movie.imageData(:,movie.columns+1:end,start_frame:stop_frame),3);
            combined = left + right;
            frame_average(:,movie.columns+1:end) = frame_average(:,movie.columns+1:end) + right;
        end
end

% 6. calculate local background
switch cameraside
    case 1
        backgnd_left = ones(movie.rows, movie.columns);
        for i = 8:16:movie.rows-8
            for j = 8:16:movie.columns-8
                backgnd_left(i-7:i+8,j-7:j+8) = min(min(left(i-7:i+8,j-7:j+8)));
            end
        end
    case 2
        backgnd_right = ones(movie.rows, movie.columns);
        if alex == 1
            backgnd_right_red = ones(movie.rows, movie.columns);
        end
        for i = 8:16:movie.rows-8
            for j = 8:16:movie.columns-8
                backgnd_right(i-7:i+8,j-7:j+8) = min(min(right(i-7:i+8,j-7:j+8)));
                if alex == 1
                    backgnd_right_red(i-7:i+8,j-7:j+8) = min(min(right_red(i-7:i+8,j-7:j+8)));
                end
            end
        end
    case 3
        if alex == 1
            backgnd = ones(movie.rows, movie.columns*2);
            backgnd_left = ones(movie.rows, movie.columns);
            backgnd_right = ones(movie.rows, movie.columns);
            backgnd_combined = ones(movie.rows, movie.columns);
            backgnd_right_red = ones(movie.rows, movie.columns);
            for i = 8:16:movie.rows-8
                for j = 8:16:movie.columns*2-8
                    backgnd(i-7:i+8,j-7:j+8) = min(min(frame_average_green(i-7:i+8,j-7:j+8)));
                end
                for j = 8:16:movie.columns-8
                    backgnd_left(i-7:i+8,j-7:j+8) = min(min(left(i-7:i+8,j-7:j+8)));
                    backgnd_right(i-7:i+8,j-7:j+8) = min(min(right(i-7:i+8,j-7:j+8)));
                    backgnd_right_red(i-7:i+8,j-7:j+8) = min(min(right_red(i-7:i+8,j-7:j+8)));
                    backgnd_combined(i-7:i+8,j-7:j+8) = min(min(combined(i-7:i+8,j-7:j+8)));
                end
            end
        else
            for i = 8:16:movie.rows-8
                for j = 8:16:movie.columns*2-8
                    backgnd(i-7:i+8,j-7:j+8) = min(min(frame_average(i-7:i+8,j-7:j+8)));
                end
                for j = 8:16:movie.columns-8
                    backgnd_left(i-7:i+8,j-7:j+8) = min(min(left(i-7:i+8,j-7:j+8)));
                    backgnd_right(i-7:i+8,j-7:j+8) = min(min(right(i-7:i+8,j-7:j+8)));
                    backgnd_combined(i-7:i+8,j-7:j+8) = min(min(combined(i-7:i+8,j-7:j+8)));
                end
            end
        end
end

% 6. filter the background and subtract local background from movie
h = ones(20,20) / 400;
switch cameraside
    case 1
        backgnd_left = imfilter(backgnd_left,h, 'replicate');
        left_correct = left - backgnd_left;
        clear left;
        clear backgnd_left;
    case 2
        backgnd_right = imfilter(backgnd_right,h, 'replicate');
        right_correct = right - backgnd_right;
        if alex == 1
            backgnd_right_red = imfilter(backgnd_right_red,h, 'replicate');
            right_red_correct = right_red - backgnd_right_red;
            clear right_red;
            clear backgnd_right_red;
        end
        clear right;
        clear backgnd_right;
    case 3
        if alex == 1
            backgnd = imfilter(backgnd,h, 'replicate');
            backgnd_left = imfilter(backgnd_left,h, 'replicate');
            backgnd_right = imfilter(backgnd_right,h, 'replicate');
            backgnd_right_red = imfilter(backgnd_right_red,h, 'replicate');
            backgnd_combined = imfilter(backgnd_combined,h, 'replicate');
            left_correct = left - backgnd_left;
            clear left;
            clear background_left;
            right_correct = right - backgnd_right;
            clear right;
            clear backgnd_right;
            frame_average_correct = frame_average_green - backgnd;
            clear frame_average_green;
            clear backgnd;
            right_red_correct = right_red - backgnd_right_red;
            clear right_red;
            clear backgnd_right_red;
            combined_correct = combined - backgnd_combined;
            clear combined;
            clear backgnd_combined;
        else
            backgnd_left = imfilter(backgnd_left,h, 'replicate');
            backgnd = imfilter(backgnd,h, 'replicate');
            backgnd_right = imfilter(backgnd_right,h, 'replicate');
            backgnd_combined = imfilter(backgnd_combined,h, 'replicate');
            left_correct = left - backgnd_left;
            clear left;
            clear backgnd_left;
            right_correct = right - backgnd_right;
            clear right;
            clear backgnd_right;
            frame_average_correct = frame_average - backgnd;
            clear frame_average;
            clear backgnd;
            combined_correct = combined - backgnd_combined;
            clear combined;
            clear backgnd_combined;
        end
end

% 7. 8-bit normalization
switch cameraside
    case 1
        image_left_max = max(max(left_correct));
        frame_average_correct_8bit = left_correct ./image_left_max .* 255;  %Normierung
    case 2
        image_right_max = max(max(right_correct));
        frame_average_correct_8bit = right_correct ./image_right_max .* 255;  %Normierung
        if alex == 1
            image_right_red_max = max(max(right_red_correct));
            frame_average_correct_8bit = right_red_correct ./image_right_red_max .* 255;  %Normierung
        end
    case 3
        if alex == 1
            image_frame_average_max = max(max(frame_average_correct));
            frame_average_correct_8bit = frame_average_correct ./ image_frame_average_max .* 255;
            clear frame_average_correct;
        else
            image_frame_average_max = max(max(frame_average_correct));
            frame_average_correct_8bit = frame_average_correct ./ image_frame_average_max .* 255;
            clear frame_average_correct;
        end
end

% 8. create array used for peak finding
switch cameraside
    case 1
        peak_check = left_correct;
    case 2
        if alex == 1
            peak_check_red = right_red_correct;
        end
        peak_check = right_correct;
    case 3
        if alex == 1
            peak_check_left = left_correct;
            peak_check = combined_correct;
            peak_check_red = right_red_correct;
        else
            %peak_check_left = imfilter(left_correct_8bit,h,'replicate');    % apply small filtering to remove artifact peaks
            %peak_check_right = imfilter(right_correct_8bit,h,'replicate');
            peak_check = combined_correct;
            %peak_check_left = left_correct;
            peak_check_right = right_correct;
        end
end

% 9. create array used for displaying peak position
peak_mark = frame_average_correct_8bit;
clear frame_average_correct_8bit;

% 10. Threshold-Determination
switch thresh
    case 1
        thresh = 0.985;
        if alex == 1
            thresh_red = 0.985;
        end
    case 2
        thresh = 0.99;
        if alex == 1
            thresh_red = 0.99;
        end
    case 3
        thresh = 0.995;
        if alex == 1
            thresh_red = 0.995;
        end
    case 4
        thresh = 0.999;
        if alex == 1
            thresh_red = 0.999;
        end
    case 5
        thresh = 0.9999;
        if alex == 1
            thresh_red = 0.9999;
        end
end
switch cameraside
    case 1
        temp = sort(reshape(peak_check,movie.rows.*movie.columns,1));
        threshold = round(temp(round(thresh*movie.rows*movie.columns),1));
        clear temp;
    case 2
        if alex == 1
            temp = sort(reshape(peak_check_red,movie.rows.*movie.columns,1));
            threshold_red = round(temp(round(thresh*movie.rows*movie.columns),1));
        end
        temp = sort(reshape(peak_check,movie.rows.*movie.columns,1));
        threshold = round(temp(round(thresh*movie.rows*movie.columns),1));
        clear temp;
    case 3
        if alex == 1
            temp = sort(reshape(peak_check_left,movie.rows.*movie.columns,1));
            threshold_left = round(temp(round(thresh*movie.rows*movie.columns),1));
            threshold = threshold_left;
            temp = sort(reshape(peak_check_red,movie.rows.*movie.columns,1));
            threshold_red = round(temp(round(thresh_red*movie.rows*movie.columns),1));
        else
            temp = sort(reshape(peak_check_right,movie.rows.*movie.columns,1));
            threshold_right = round(temp(round(thresh*movie.rows*movie.columns),1));
            threshold = threshold_right;
        end
        clear temp;
end

% 11. roundness check and generation of circlular matrix
% create mask for roundnesscheck : matrix with zeros and ones only where the
% roundnesscheck is to be done
r_inner_round = half_region;
r_outer_round = r_inner_round + 1;
seite_round = 2*r_outer_round + 1;   % length of side of matrix
circle_center = double(circle(r_inner_round, seite_round)); % for integration of intensities
center = find(circle_center == 1);
circle_round = double(xor(circle(r_inner_round, seite_round),circle(r_outer_round, seite_round)));   % doughnout to calculate background
ring_round = find(circle_round == 1);

%circle-mask for peak marking
r_inner_mark = half_region - 1;
r_outer_mark = r_inner_mark + 1;
seite_mark = 2*r_outer_mark + 1;
circle_center_mark = double(circle(r_inner_mark, seite_mark));
circle_outer_mark = double(xor(circle(r_inner_mark, seite_mark),circle(r_outer_mark, seite_mark)));

% 12. peak finding
% all pixel in peak_check are to be set 0 when counts<threshold
disp('Start peakfinding...');
switch cameraside
    case 1
        mask = (peak_check > threshold);
        peak_check = mask .* peak_check;
    case 2
        if alex == 1
            mask_left = (peak_check > threshold);
            mask_red = (peak_check_red > threshold_red);
            peak_find = and(mask_left, mask_red);
            peak_check = peak_find .* peak_check;
            clear peak_find;
        else
            mask = (peak_check > threshold);
            peak_check = mask .* peak_check;
        end
    case 3
        if alex == 1
            mask_left = (peak_check_left > threshold_left);
            mask_red = (peak_check_red > threshold_red);
            peak_find = and(mask_left, mask_red);
            peak_check = peak_find .* peak_check;
            clear peak_find;
        else
            mask_right = (peak_check_right > threshold_right);
            peak_check = mask_right .* peak_check;
        end
end

% 13. roundness-check
number_of_molecules_found = 0;
not_good = 0;
molecules_found = [];            % initialize array of bead positions
neighbouring_molecule = [];
index = find(peak_check);
[k,l] = ind2sub([movie.rows,movie.columns],index);
for x = 1 : length(k)           % take only peaks above threshold
    i = k(x,:);
    j = l(x,:);
    switch cameraside
        case 1
            if i > half_region + 3 && i < movie.rows - half_region - 3 && j > half_region + 3 && j < movie.columns - half_region - 3
                if peak_check(i,j) == max(max(peak_check(i-3:i+3,j-3:j+3)))
                    % 13.1. check if peak is round
                    ROI = left_correct(i-r_outer_round:i+r_outer_round,j-r_outer_round:j+r_outer_round);
                    roundness_check = ROI(ring_round);
                    mean_center = mean(mean(ROI(center)));
                    mean_ring = mean(mean(roundness_check));
                    st_dev_ring = std(roundness_check);
                    quality = 1;
                    if mean_center <= mean_ring
                        quality = 0;
                    end
                    % 13.2. check surrounding pixels
                    neighbouring_molecule = roundness_check(find(roundness_check>(mean_ring + 3*st_dev_ring)));
                    if any(neighbouring_molecule) && quality ~= 0
                        quality = 0;
                    end
                    % 13.3. extract coordinates
                    if quality == 1 % -> bead was selected
                        peak_mark(i-half_region:i+half_region,j-half_region:j+half_region) = peak_mark(i-half_region:i+half_region,j-half_region:j+half_region).*circle_center_mark + circle_outer_mark*128;
                        molecules_found = [molecules_found; j, i]; %Koordinaten des gefundenen Peaks speichern
                        number_of_molecules_found = number_of_molecules_found + 1;
                    else
                        quality = 0;
                    end
                    if quality == 0
                        not_good = not_good + 1;
                    end
                end
            end
        case 2
            if i > half_region + 3 && i < movie.rows - half_region - 3 && j > half_region + 3 && j < movie.columns - half_region - 3
                if peak_check(i,j) == max(max(peak_check(i-3:i+3,j-3:j+3)))
                    % 13.1. check if peak is round
                    ROI = right_correct(i-r_outer_round:i+r_outer_round,j-r_outer_round:j+r_outer_round);
                    roundness_check = ROI(ring_round);
                    mean_center = mean(mean(ROI(center)));
                    mean_ring = mean(mean(roundness_check));
                    st_dev_ring = std(roundness_check);
                    quality = 1;
                    if mean_center <= mean_ring
                        quality = 0;
                    end
                    % 13.2. check surrounding pixels
                    neighbouring_molecule = roundness_check(find(roundness_check>(mean_ring + 3*st_dev_ring)));
                    if any(neighbouring_molecule) && quality ~= 0
                        quality = 0;
                    end
                    % 13.3. extract coordinates
                    if quality == 1 % -> bead was selected
                        peak_mark(i-half_region:i+half_region,j-half_region:j+half_region) = peak_mark(i-half_region:i+half_region,j-half_region:j+half_region).*circle_center_mark + circle_outer_mark*255;
                        molecules_found = [molecules_found; j, i]; %Koordinaten des gefundenen Peaks speichern
                        number_of_molecules_found = number_of_molecules_found + 1;
                    else
                        quality = 0;
                    end
                    if quality == 0,
                        not_good = not_good + 1;
                    end
                end
            end
        case 3
            if i > half_region + 3 && i < movie.rows - half_region - 3 && j > half_region + 3 && j < movie.columns - half_region - 3
                if peak_check(i,j) == max(max(peak_check(i-3:i+3,j-3:j+3)))
                    % 13.1. check if peak is round
                    ROI = combined_correct(i-r_outer_round:i+r_outer_round,j-r_outer_round:j+r_outer_round);
                    roundness_check = ROI(ring_round);
                    mean_center = mean(mean(ROI(center)));
                    mean_ring = mean(mean(roundness_check));
                    st_dev_ring = std(roundness_check);
                    quality = 1;
                    if mean_center <= mean_ring
                        quality = 0;
                    end
                    % 13.2. check surrounding pixels
                    neighbouring_molecule = roundness_check(find(roundness_check>(mean_ring + 3*st_dev_ring)));
                    if any(neighbouring_molecule) && quality ~= 0
                        quality = 0;
                    end
                    % 13.3. extract coordinates
                    if quality == 1
                        peak = [j,i];
                        peak_predict = tforminv(map,peak);
                        peak_1 = round(peak_predict(1));
                        peak_2 = round(peak_predict(2));
                        if (peak_1 < half_region + 2) || (peak_2 < half_region + 2) || (peak_2 > movie.rows - (half_region + 2)) || (peak_1 > movie.columns - (half_region + 2))
                            quality = 0;
                        end
                        if (peak_1 > (half_region + 2)) && (peak_2 > (half_region + 2)) && (peak_2 < movie.rows - (half_region + 2)) && (peak_1 < movie.columns - (half_region + 2))
                            molecules_found = [molecules_found; peak_1, peak_2, (j + movie.columns), i];
                            number_of_molecules_found = number_of_molecules_found + 1; % count number of selected beads
                            peak_mark(i-half_region:i+half_region,j+movie.columns-half_region:j+movie.columns+half_region) = peak_mark(i-half_region:i+half_region,j+movie.columns-half_region:j+movie.columns+half_region).*circle_center_mark + circle_outer_mark*255; %right side
                            peak_mark(peak_2-half_region:peak_2+half_region,peak_1-half_region:peak_1+half_region) = peak_mark(peak_2-half_region:peak_2+half_region,peak_1-half_region:peak_1+half_region).*circle_center_mark + circle_outer_mark*128; % left side
                        else
                            quality = 0;
                        end
                        if quality == 0
                            not_good = not_good + 1;
                        end
                    end
                end %if peak_check
            end % if peak_check > 0
    end %switch
end
result.coordinates = molecules_found;
disp(['Number of pairs found: ' num2str(number_of_molecules_found)]);
disp(['Number of pairs rejected: ' num2str(not_good)]);
figure(1); clf;
imagesc(peak_mark, [0 255]);
disp('End peakfinding, Start analysis...');
if number_of_molecules_found < 1
    disp('No molecules found');
    return
end

% 14. create masks for intensity and background-calculation
r_inner = half_region;
r_outer = r_inner + 2;
seite = 2*r_outer+1;
circle_intensity = double(circle(r_inner, seite));
pixel = sum(sum(circle_intensity)); %number of pixel used for intensity-calculation
circle_back = double(xor(circle(r_inner, seite),circle(r_outer, seite)));
ring = find(circle_back == 1);  %coordinates of the pixel for background-calculation

% 15. extract intensities
if alex == 1
    T = movie.size - 1;
else
    T = movie.size;
end
if cameraside == 3
    time_trace = ones(T,number_of_molecules_found*2); %result-array for intensity-traces
else
    time_trace = ones(T,number_of_molecules_found); %result-array for intensity-traces
end
backgnd_trace = time_trace;  %result-array for background-traces
if alex == 1
    time_trace_red = time_trace;
    backgnd_trace_red = time_trace_red;
end
switch cameraside
    case 1
        for t = 1:T  %time-iteration
            movie_trace = double(movie.imageData(:,:,t));  %load every frame
            for i = 1:number_of_molecules_found   %molecule-iteration
                ROI = movie_trace(molecules_found(i,2)-r_outer:molecules_found(i,2)+r_outer,molecules_found(i,1)-r_outer:molecules_found(i,1)+r_outer);
                time_trace(t,i)=sum(sum(circle_intensity.*ROI)); %/pixel !!!!!(One can divide by pixel)!!!!!
                bg = ROI(ring);   %extract pixelcounts in background area
                th = mean(bg)+3*std(bg); % calculate threshold for statistical backgroundpeaks
                backgnd_trace(t,i)=mean(bg(find(bg<th)))*pixel;  % background = mean of all background values lower then the threshold
                % backgnd_left = [backgnd_left, backgnd_trace];
            end
        end
    case 2        
        for t = 1:T  %Zeititeration
            movie_green_trace = double(movie.imageData(:,:,t));  %Frame(t) in Variable laden
            if alex == 1
                movie_red_trace = double(movie.imageData_red(:,:,t));
            end
            for i = 1:number_of_molecules_found   %Moleküliteration
                %%%%%%%%%%%%%%%%green excitation, right side%%%%%%%%%%
                ROI_right_green = movie_green_trace(molecules_found(i,2)-r_outer:molecules_found(i,2)+r_outer,molecules_found(i,1)-r_outer:molecules_found(i,1)+r_outer);
                time_trace(t,i) = sum(sum(circle_intensity.*ROI_right_green)); %/pixel !!!!!(One can divide by pixel)!!!!!
                bg_right_green = ROI_right_green(ring);   %extract pixelcounts in background area
                th_right_green = mean(bg_right_green)+3*std(bg_right_green); % calculate threshold for statistical backgroundpeaks
                backgnd_trace(t,i)=mean(bg_right_green(find(bg_right_green<th_right_green)))*pixel;  % background = mean of all background values lower then the threshold
                %%%%%%%%%%%%%%%%%%red excitation, right side%%%%%%%%%
                if alex == 1
                    ROI_right_red = movie_red_trace(molecules_found(i,2)-r_outer:molecules_found(i,2)+r_outer,molecules_found(i,1)-r_outer:molecules_found(i,1)+r_outer);
                    time_trace_red(t,i) = sum(sum(circle_intensity.*ROI_right_red));
                    bg_right_red = ROI_right_red(ring);
                    th_right_red = mean(bg_right_red)+3*std(bg_right_red); % calculate threshold for statistical backgroundpeaks
                    backgnd_trace_red(t,i)=mean(bg_right_red(find(bg_right_red<th_right_red)))*pixel;  % background = mean of all background values lower then the threshold
                    %backgnd_right = [backgnd_right, backgnd_trace];
                end
            end
        end        
    case 3
        %points = (2.*half_region+1).^2;
            for t = 1:T  %Zeititeration
                movie_green_trace = double(movie.imageData(:,:,t));  %Frame(t) in Variable laden
                if alex == 1
                    movie_red_trace = double(movie.imageData_red(:,:,t)); %Direct Excitation Frames
                end
                for i = 1:number_of_molecules_found   %Moleküliteration
                    j = i*2-1;
                    %%%%%%%%%%%%%%%%%%%%%green excitation, left part %%%%%
                    ROI_left = movie_green_trace(molecules_found(i,2)-r_outer:molecules_found(i,2)+r_outer,molecules_found(i,1)-r_outer:molecules_found(i,1)+r_outer);
                    time_trace_left = sum(sum(circle_intensity.*ROI_left)); %/pixel !!!!!(One can divide by pixel)!!!!!
                    bg_left = ROI_left(ring);   %extract pixelcounts in background area
                    th_left = mean(bg_left)+3*std(bg_left); % calculate threshold for statistical backgroundpeaks
                    backgnd_left = mean(bg_left(find(bg_left<th_left)))*pixel;  % background = mean of all background values lower then the threshold
                    %backgnd_left = calculate_backgnd(movie_green_trace,molecules_found(i,2),molecules_found(i,1))*points;
                    %%%%%%%%%%%%%%%%%%%%green excitation, right part%%%%
                    ROI_right = movie_green_trace(molecules_found(i,4)-r_outer:molecules_found(i,4)+r_outer,molecules_found(i,3)-r_outer:molecules_found(i,3)+r_outer);
                    time_trace_right = sum(sum(circle_intensity.*ROI_right)); %/pixel !!!!!(One can divide by pixel)!!!!!
                    bg_right = ROI_right(ring);   %extract pixelcounts in background area
                    th_right = mean(bg_right)+3*std(bg_right); % calculate threshold for statistical backgroundpeaks
                    backgnd_right = mean(bg_right(find(bg_right<th_right)))*pixel;  % background = mean of all background values lower then the threshold
                    %backgnd_right = calculate_backgnd(movie_green_trace,molecules_found(i,4),molecules_found(i,3))*points;
                    %%%%%%%%%%%%%%%%%%%%red excitation, right part%%%%
                    if alex == 1
                        ROI_red = movie_red_trace(molecules_found(i,4)-r_outer:molecules_found(i,4)+r_outer,molecules_found(i,3)-movie.columns-r_outer:molecules_found(i,3)-movie.columns+r_outer);
                        time_trace_right_red = sum(sum(circle_intensity.*ROI_red)); %/pixel !!!!!(One can divide by pixel)!!!!!
                        bg_red = ROI_red(ring);   %extract pixelcounts in background area
                        th_red = mean(bg_red)+3*std(bg_red); % calculate threshold for statistical backgroundpeaks
                        backgnd_right_red = mean(bg_red(find(bg_red<th_red)))*pixel;  % background = mean of all background values lower then the threshold
                        time_trace_red(t,j:j+1) = [0, time_trace_right_red];
                        backgnd_trace_red(t,j:j+1) = [0, backgnd_right_red];
                    end
                    time_trace(t,j:j+1) = [time_trace_left, time_trace_right];
                    backgnd_trace(t,j:j+1) = [backgnd_left, backgnd_right];
                end
            end        
end % switch

% 16. generate time traces
time_axis = (1:T)';
if correct_backgnd == 1
    time_trace = time_trace - backgnd_trace;
    if alex == 1
        time_trace_red = time_trace_red - backgnd_trace_red;
    end        
end
time_trace = [time_axis, time_trace];
backgnd_trace = [time_axis, backgnd_trace];
if alex == 1
    time_trace_red = [time_axis, time_trace_red];
    backgnd_trace_red = [time_axis, backgnd_trace_red];
    result.time_trace_red = time_trace_red;
    result.backgnd_trace_red = backgnd_trace_red;
end
result.time_trace = time_trace;
result.backgnd_trace = backgnd_trace;
result.coordinates = molecules_found;
disp('End of analysis, saving...');

% 17. save data
filename_base = filename(1:findstr(filename,'.')-1);
filename_base = strcat(filename_base, '_th_', num2str(round(threshold)), '_rad_', num2str(half_region), '.' );
filename_cor = strcat(filename_base,'cor');
filename_ttr = strcat(filename_base,'ttr');
filename_bck = strcat(filename_base,'bck');
save(filename_cor,'molecules_found','-ASCII','-tabs');
save(filename_ttr,'time_trace','-ASCII','-tabs');
save(filename_bck,'backgnd_trace','-ASCII','-tabs');
if alex == 1 && cameraside ~= 1
    filename_atr = strcat(filename_base,'atr');
    filename_back_red = strcat(filename_base,'bkr');
    save(filename_atr,'time_trace_red','-ASCII','-tabs');
    save(filename_back_red,'backgnd_trace_red','-ASCII','-tabs');
end