% closely related to IDL code that was written by Hazen Babcock
%
% uses load_movie.m, find_peak_coordinates.m, make_circle.m, gauss_peaks.m
% and optionally map_test.m
%
% Jens Michaelis 08-06

% Rewritten by R. Lewis 21/10/09
% tasks:
% bead_mapping programm, maps one side of camera to the other using mathematical operation

% used functions and scripts:       (only self_written mentioned not MatLab)
% load_movie

% used parameters:
% stop_frame_map

function map = map_beads_dualcam(stop_frame_map)
cameraside = 0; % one needs to analyse both sides of the camera
half_region = 4; % Beads are usually bigger than molecules
alex = 0; % Beadmap cannot have ALEX !!!

% 1. load a movie for analysis
% first a movie with from the "donor" camera, then from the "acceptor"
[file path] = uigetfile({'*.sif';'*.tif'},'Loading Donor Beadmap to analyze');
filename = strcat(path,file);
if path ~=0
    k = strfind(file,'.tif');
end
movie_donor = load_map(filename, cameraside, alex); % function returns object with .run (array containing data), .culomns (# of), .rows (# of)
path_acceptor = uigetdir(path,'Select Directory of Acceptor Beadmap');
if ~isempty(path_acceptor)
    filename = [path,file];
    filename_base = filename(1:findstr(filename,'_DON')-1);
    filename_num_suffix = filename(findstr(filename,'_DON')+4:end);
    if exist(strcat(filename_base,'_ACC',filename_num_suffix),'file') == 2
        filename_acc = strcat(filename_base,'_ACC',filename_num_suffix);
    else
        filename_acc = [];
        errordlg('WARNING: No Acceptor Beadmap with corresponding filename found !!!');
        return
    end
end
movie_acceptor = load_map(filename_acc, cameraside, alex); % function returns object with .run (array containing data), .culomns (# of), .rows (# of)
if ~isempty(k)
    movie_acceptor.imageData = flipdim(movie_acceptor.imageData,2);
end
if stop_frame_map > movie_donor.size
    stop_frame = movie_donor.size;    %sometimes videos could be too short for original stop_frame_map
else
    stop_frame = stop_frame_map;
end
if stop_frame_map > movie_acceptor.size
    stop_frame = movie_acceptor.size;    %sometimes videos could be too short for original stop_frame_map
end

% 2. extract important parameters from the movie (e.g. length, height,
% width)
min_pix_intensity_donor = min(min(min(movie_donor.imageData(:,:,1:stop_frame))));
min_pix_intensity_acceptor = min(min(min(movie_acceptor.imageData(:,:,1:stop_frame))));

% 3. correct for minimum intensity
movie_donor.imageData = movie_donor.imageData - min_pix_intensity_donor;
movie_acceptor.imageData = movie_acceptor.imageData - min_pix_intensity_acceptor;

% 4. calculate average
frame_average_donor = mean(movie_donor.imageData(:,:,1:stop_frame),3);
frame_average_acceptor = mean(movie_acceptor.imageData(:,:,1:stop_frame),3);

% 5. calculate local background
backgnd_donor = ones(movie_donor.rows, movie_donor.columns);
backgnd_acceptor = ones(movie_acceptor.rows, movie_acceptor.columns);
for i = 8:16:movie_donor.rows-8
    for j = 8:16:movie_donor.columns-8
        backgnd_donor(i-7:i+8,j-7:j+8) = min(min(frame_average_donor(i-7:i+8,j-7:j+8)));
    end
end
for i = 8:16:movie_acceptor.rows-8
    for j = 8:16:movie_acceptor.columns-8
        backgnd_acceptor(i-7:i+8,j-7:j+8) = min(min(frame_average_acceptor(i-7:i+8,j-7:j+8)));
    end
end
h = ones(20,20) / 400;
backgnd_donor = imfilter(backgnd_donor,h, 'replicate'); % filtering of the image by calculating the mean using the surrounding pixels
backgnd_acceptor = imfilter(backgnd_acceptor,h, 'replicate');

% 6. subtract local background
frame_average_donor_correct = frame_average_donor - backgnd_donor;
clear frame_average_donor;
frame_average_acceptor_correct = frame_average_acceptor - backgnd_acceptor;


% 7. 8-bit normalization
image_donor_max = max(max(frame_average_donor_correct));
frame_average_donor_correct_8bit = frame_average_donor_correct ./image_donor_max .* 255;  %normalization
image_acceptor_max = max(max(frame_average_acceptor_correct));
frame_average_acceptor_correct_8bit = frame_average_acceptor_correct ./image_acceptor_max .* 255;  %normalization

% 8. Threshold-Determination
peak_check_donor = frame_average_donor_correct;
temp = sort(reshape(peak_check_donor,movie_donor.rows.*movie_donor.columns,1)); % create array used for bead finding
threshold_donor = round(temp(round(0.95*movie_donor.rows*movie_donor.columns),1));
peak_check_acceptor = frame_average_acceptor_correct;
temp = sort(reshape(peak_check_acceptor,movie_acceptor.rows.*movie_acceptor.columns,1)); % create array used for bead finding
threshold_acceptor = round(temp(round(0.95*movie_acceptor.rows*movie_acceptor.columns),1));
clear temp;

% 9. Roundness Check : matrix with zeros and ones only where the Roundness check is to be done
r_inner_round = half_region;
r_outer_round = r_inner_round + 1;
seite_round = 2*r_outer_round+1;   %although the actual finding is done in a circle, the matrix has be rectangle
circle_center = double(circle(r_inner_round, seite_round)); % to calculate the mean of the signal
center = find(circle_center == 1);
circle_round = double(xor(circle(r_inner_round, seite_round),circle(r_outer_round, seite_round)));   %generate doughnut shaped ring for background check
ring_round = find(circle_round == 1);

% 10. user selects two matched pairs
input_result = ones(2,4);
for i = 1:2
    choicewin = 0;
    while choicewin ~= 1
        figure(1);
        imagesc(frame_average_acceptor_correct_8bit, [0 64]);
        title('Click on a bead you want to select (FIRST from the Acceptor camera)');
        [x_coord,y_coord]=ginput(1);
        x_coord = round(x_coord);
        y_coord = round(y_coord);
        figure(2); clf;
        zoom = frame_average_acceptor_correct_8bit(y_coord-8:y_coord+8 ,x_coord-8:x_coord+8);
        imagesc(zoom, [0 64]);
        choicewin = menu('Do you want to keep this bead?', 'Yes', 'No');
    end
    [x_coord, y_coord] = find_peak_coordinates(x_coord,y_coord, frame_average_acceptor_correct_8bit);
    [x_coord_match, y_coord_match] = find_peak_coordinates(x_coord, y_coord,frame_average_donor_correct_8bit);
    input_result(i,:) = [x_coord y_coord x_coord_match y_coord_match];
end
close('2'); close('9');
shift_x_max = abs(input_result(1,1) - input_result(1,3));
shift_x_min = abs(input_result(2,1) - input_result(2,3));
shift_x_str = strcat(['Shift in x is ' num2str((shift_x_max + shift_x_min)/2) ' pixel']);
if shift_x_max > shift_x_min
    shift_x = int16(shift_x_max);
else
    shift_x = int16(shift_x_min);
end
shift_y_max = abs(input_result(1,2) - input_result(1,4));
shift_y_min = abs(input_result(2,2) - input_result(2,4));
shift_y_str = strcat(['Shift in y is ' num2str((shift_y_max + shift_y_min)/2) ' pixel']);
if shift_y_max > shift_y_min
    shift_y = int16(shift_y_max);
else
    shift_y = int16(shift_y_min);
end
disp('  ');
disp(shift_x_str);
disp('  ');
disp(shift_y_str);

% 11. circle-mask for peak marking
peak_mark = frame_average_acceptor_correct_8bit;              % create array used for displaying bead position
peak_match = peak_mark;
r_inner_mark = half_region - 1;
r_outer_mark = r_inner_mark + 1;
seite_mark = 2*r_outer_mark + 1;
circle_center_mark = double(circle(r_inner_mark, seite_mark));
circle_outer_mark = double(xor(circle(r_inner_mark, seite_mark),circle(r_outer_mark, seite_mark)));

% 12. Peak Finding
mask_donor = (peak_check_donor > threshold_donor);
peak_check_donor = mask_donor .* peak_check_donor;
mask_acceptor = (peak_check_acceptor > threshold_acceptor);
peak_check_acceptor = mask_acceptor .* peak_check_acceptor;

% 13. Roundness-Check of Acceptor Camera
number_of_molecules_found = 0;
not_good = 0;
molecules_found_acceptor = [];            % initialize array of bead positions
neighbouring_molecule = [];
index_acceptor = find(peak_check_acceptor);
[k,l] = ind2sub([512,512],index_acceptor);
for x = 1 : length(k)           % take only peaks above threshold
    i = k(x,:);
    j = l(x,:);
    if i > half_region + 3 + shift_y && i < movie_acceptor.rows - half_region - 3 - shift_y && j > half_region + 3 + shift_x && j < movie_acceptor.columns - half_region - 3 - shift_x
        if peak_check_acceptor(i,j) == max(max(peak_check_acceptor(i-3:i+3,j-3:j+3)))  %find local maxima %PEAK SUCHEN
            % 13.1 check if peak is round
            ROI = frame_average_acceptor_correct(i-r_outer_round:i+r_outer_round,j-r_outer_round:j+r_outer_round);
            roundness_check = ROI(ring_round);
            mean_center = mean(mean(ROI(center)));
            mean_ring = mean(mean(roundness_check));
            st_dev_ring = std(roundness_check);
            quality = 1;
            if mean_center <= mean_ring
                quality = 0;
            end
            % 13.2 check if the signal around the molecule drops or
            % whether there are potential neighbouring molecules
            neighbouring_molecule = roundness_check(find(roundness_check>(mean_ring + 3*st_dev_ring)));
            if any(neighbouring_molecule) && quality ~= 0
                quality = 0;
            end
            % 13.3 fine_tune the peak position
            if quality ~=0 % -> bead was selected
                cur_best = 200000.0;                     % should be higher than anything we expect
                g_peaks = gauss_peaks;                  % call to function that creates gauss peaks with shifting
                best_x = 2;
                best_y = 2;
                for m = 1:3
                    for n = 1:3
                        diff(m,n) = sum(sum(abs(squeeze(peak_check_acceptor(i,j) * g_peaks(m,n,:,:)) - frame_average_acceptor_correct(i-3:i+3,j-3:j+3))));
                        if diff(m,n) < cur_best
                            best_x = n;
                            best_y = m;
                            cur_best = diff(m,n);
                        end
                    end
                end
                peak_mark(i-half_region:i+half_region,j-half_region:j+half_region) = peak_mark(i-half_region:i+half_region,j-half_region:j+half_region).*circle_center_mark + circle_outer_mark*255; %Acceptor camera
                molecules_found_acceptor = [molecules_found_acceptor; (j+0.5*(best_x-2)), (i+0.5*(best_y-2))];      % make array of bead positions
                number_of_molecules_found = number_of_molecules_found + 1;                     % count number of selected beads
            else
                not_good = not_good + 1;
            end % if quality ~= 0
        end % if peak_check_donor
    end % if i >
end

% 14. Roundness-Check of Donor Camera
molecules_found_donor = [];            % initialize array of bead positions
molecules_found_acceptor_temp = molecules_found_acceptor;
dummy_counter = 0;
%neighbouring_molecule = [];
k = length(molecules_found_acceptor);% find(peak_check_acceptor);
% [k,l] = ind2sub([512,512],index_donor);
for x = 1 : k          % take only peaks above threshold
    dummy_x = x;
    dummy_x = dummy_x - dummy_counter;
    i = ceil(molecules_found_acceptor(x,2));
    j = ceil(molecules_found_acceptor(x,1));
    if i > half_region + 3 + shift_y && i < movie_donor.rows - half_region - 3 - shift_y && j > half_region + 3 + shift_x && j < movie_donor.columns - half_region - 3 - shift_x
        local_max = max(max(peak_check_donor(i-3-shift_y:i+3+shift_y,j-3-shift_x:j+3+shift_x))); %find local maxima %PEAK SUCHEN
        if local_max > 0
            cor = find(peak_check_donor == local_max);
            [i,j] = ind2sub([512,512],cor(1,1));
            % 14.1 check if peak is round
            ROI = frame_average_donor_correct(i-r_outer_round:i+r_outer_round,j-r_outer_round:j+r_outer_round);
            roundness_check = ROI(ring_round);
            mean_center = mean(mean(ROI(center)));
            mean_ring = mean(mean(roundness_check));
            st_dev_ring = std(roundness_check);
            quality = 1;
            if mean_center <= mean_ring
                quality = 0;
            end
            % 14.2 check if the signal around the molecule drops or
            % whether there are potential neighbouring molecules
            neighbouring_molecule = roundness_check(find(roundness_check>(mean_ring + 3*st_dev_ring)));
            if any(neighbouring_molecule) && quality ~= 0
                quality = 0;
            end
            % 14.3 fine_tune the peak position
            if quality ~=0 % -> bead was selected
                cur_best = 200000.0;                     % should be higher than anything we expect
                g_peaks = gauss_peaks;                  % call to function that creates gauss peaks with shifting
                best_x = 2;
                best_y = 2;
                for m = 1:3
                    for n = 1:3
                        diff(m,n) = sum(sum(abs(squeeze(peak_check_donor(i,j) * g_peaks(m,n,:,:)) - frame_average_donor_correct(i-3:i+3,j-3:j+3))));
                        if diff(m,n) < cur_best
                            best_x = n;
                            best_y = m;
                            cur_best = diff(m,n);
                        end
                    end
                end
                peak_mark(i-half_region:i+half_region,j-half_region:j+half_region) = peak_mark(i-half_region:i+half_region,j-half_region:j+half_region).*circle_center_mark + circle_outer_mark*128; %donor camera
                molecules_found_donor = [molecules_found_donor; (j+0.5*(best_x-2)), (i+0.5*(best_y-2))];      % make array of bead positions
            else
                not_good = not_good + 1;
                dummy_1 = molecules_found_acceptor_temp(1:dummy_x-1,:);
                dummy_2 = molecules_found_acceptor_temp(dummy_x+1:end,:);
                molecules_found_acceptor_temp = [dummy_1;dummy_2];
                dummy_counter = dummy_counter + 1;
            end
        else
            not_good = not_good + 1;
            dummy_1 = molecules_found_acceptor_temp(1:dummy_x-1,:);
            dummy_2 = molecules_found_acceptor_temp(dummy_x+1:end,:);
            molecules_found_acceptor_temp = [dummy_1;dummy_2];
            dummy_counter = dummy_counter + 1;
        end % if quality ~= 0
    else
        not_good = not_good + 1;
        dummy_1 = molecules_found_acceptor_temp(1:dummy_x-1,:);
        dummy_2 = molecules_found_acceptor_temp(dummy_x+1:end,:);
        molecules_found_acceptor_temp = [dummy_1;dummy_2];
        dummy_counter = dummy_counter + 1;
    end % if i >
end
molecules_found_acceptor = molecules_found_acceptor_temp;

% 15. display found beads
disp('  ');
disp(strcat(['Beads in Acceptor channel found: ' num2str(number_of_molecules_found)]));
disp('  ');
disp(strcat(['Beads in both channels rejected: ' num2str(not_good)]));
figure(1); clf;
imagesc(peak_mark, [0 255]);
title('All peaks found are marked with a circle');
molecules_found_donor = flipud(molecules_found_donor);
molecules_found_acceptor = flipud(molecules_found_acceptor);

% 15. match the position of the beads using the determined shifts
%result= [];
%compare = length(molecules_found_donor) < length(molecules_found_acceptor);
%if compare == 1
 %   number_of_molecules_found = length(molecules_found_donor);
  %  molecules_found_acceptor = molecules_found_acceptor(1:length(molecules_found_donor),:);
%else
 %   number_of_molecules_found = length(molecules_found_acceptor);
 %   molecules_found_donor = molecules_found_donor(1:length(molecules_found_acceptor),:);
%end
% for i = 1:number_of_molecules_found
%     if (molecules_found_donor(i,1) > half_region + 3) && (molecules_found_donor(i,1) < movie_donor.columns - (half_region + 3)) && (molecules_found_acceptor(i,1) > half_region + 3) && (molecules_found_acceptor(i,1) < movie_acceptor.columns - (half_region + 3))
%         for j = 1:number_of_molecules_found
%if (abs(molecules_found_donor(i,2) - molecules_found_acceptor(j,2) - shift_y) < 4) && (abs(molecules_found_donor(i,1) - molecules_found_acceptor(j,1) - shift_x) < 4)
result = [molecules_found_donor, molecules_found_acceptor];
%end
%         end
%     end
% end
disp('  ');
disp(strcat(['Paired Beads found: ' num2str(length(result))]));
if (length(result)) < 5
    disp('ERROR: Not enough matching beads found')
end

% 16. mark the position of the matched beads (red circle) %%%%%%%%
bead_pairs = [result(:,3), result(:,4)];
for i = 1:length(bead_pairs)
    % draw roundness_circle around the bead
    x_pix = round(bead_pairs(i,1));
    y_pix = round(bead_pairs(i,2));
    peak_match(y_pix-half_region:y_pix+half_region,x_pix-half_region:x_pix+half_region) = peak_match(y_pix-half_region:y_pix+half_region,x_pix-half_region:x_pix+half_region).*circle_center_mark + circle_outer_mark*192;
end
figure(2); clf;
imagesc(peak_match, [0 255]);
title('The position of the matched pairs is marked with a circle');

% 17. do the mapping %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%result(:,1) = result(:,1) - movie_donor.columns;                                 % want to map the points of the upper half to coordinates of lower half
destination_points   = [result(:,3),result(:,4)];                                 % points in lower half
input_points  = [result(:,1),result(:,2)];                                        % points in upper half


TFORM = cp2tform(input_points,destination_points,'polynomial',4);         % this should make the transform to make a matching upper half
%predicted_destinations = tforminv(TFORM,destination_points);               % check how it worked
%map_residuals = input_points - predicted_destinations;

[transform_map, xdata, ydata] = imtransform(frame_average_donor_correct_8bit(:,1:movie_donor.columns),TFORM,'Fill',255,'XData', [1, movie_donor.columns], 'YData', [1, movie_donor.rows]);
%frame_linear = [transform_map; frame_average_correct_8bit(:,257:end)];             % put the two halfs in one array

% figure(8); clf;
% image_correct_transform = imagesc(frame_linear, [0 255]);
%[shift_x shift_y] = map_test(frame_linear)                                 % check program to test the mapping

add_image = transform_map+frame_average_acceptor_correct_8bit(:,1:movie_acceptor.columns);
figure(3); clf;
imagesc(add_image);
title('Overlay of the 2 Cameras after correction');
map = TFORM;                                                          % return the mapping structure
filename_base = filename(1:findstr(filename,'.')-1);
filename_map = strcat(filename_base,'.map');
save(filename_map,'map','-mat');
disp(['Map saved as Matlab File in ' filename_map]);