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

function map = map_beads(stop_frame_map)
cameraside = 3; % one needs to analyse both sides of the camera
half_region = 4; % Beads are usually bigger than molecules
alex = 0; % Beadmap cannot have ALEX !!!

% 1. load a movie for analysis
[file path] = uigetfile({'*.sif;*.tif'},'Loading Beadmap to analyze');
filename = strcat(path,file);
movie = load_map(filename, cameraside, alex);
if stop_frame_map > movie.size
    stop_frame = movie.size;    %sometimes videos could be too short for original stop_frame_map
else
    stop_frame = stop_frame_map;
end

% 2. extract important parameters from the movie (e.g. length, height,
% width) 
min_pix_intensity = min(min(min(movie.imageData(:,:,1:stop_frame))));

% 3. correct for minimum intensity
movie.imageData = movie.imageData - min_pix_intensity;

% 4. calculate average 
frame_average = mean(movie.imageData(:,:,1:stop_frame),3);

% 5. calculate local background
backgnd = ones(movie.rows, movie.columns);
for i = 8:16:movie.rows-8
    for j = 8:16:movie.columns-8
        backgnd(i-7:i+8,j-7:j+8) = min(min(frame_average(i-7:i+8,j-7:j+8)));
    end
end
h = ones(20,20) / 400;
backgnd = imfilter(backgnd,h, 'replicate'); % filtering of the image by calculating the mean using the surrounding pixels

% 6. subtract local background
frame_average_correct = frame_average - backgnd;
clear frame_average;

% 7. 8-bit normalization
image_max = max(max(frame_average_correct));
frame_average_correct_8bit = frame_average_correct ./image_max .* 255;  %normalization

% 8. Threshold-Determination
peak_check = frame_average_correct;
temp = sort(reshape(peak_check,movie.rows.*movie.columns,1)); % create array used for bead finding
threshold = round(temp(round(0.95*movie.rows*movie.columns),1));
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
        imagesc(frame_average_correct_8bit, [0 64]);
        title('Click on a bead you want to select (FIRST from the right side)');
        [x_coord,y_coord]=ginput(1);
        x_coord = round(x_coord);
        y_coord = round(y_coord);
        figure(2); clf;
        zoom = frame_average_correct_8bit(y_coord-8:y_coord+8 ,x_coord-8:x_coord+8);
        imagesc(zoom, [0 64]);
        choicewin = menu('Do you want to keep this bead?', 'Yes', 'No');
    end
    [x_coord, y_coord] = find_peak_coordinates(x_coord,y_coord, frame_average_correct_8bit);
    shift_x_coord = x_coord - (movie.columns / 2);
    [x_coord_match, y_coord_match] = find_peak_coordinates(shift_x_coord, y_coord,frame_average_correct_8bit);
    input_result(i,:) = [x_coord y_coord x_coord_match y_coord_match];
end
close('2'); close('9');
shift_x = mean(input_result(:,1)-input_result(:,3));
shift_x_str = strcat(['Shift in x is ' num2str(shift_x) ' pixel']);
shift_y = mean(input_result(:,2)-input_result(:,4));
shift_y_str = strcat(['Shift in y is ' num2str(shift_y) ' pixel']);
disp('  ');
disp(shift_x_str);
disp('  ');
disp(shift_y_str);

% 11. circle-mask for peak marking
peak_mark = frame_average_correct_8bit;              % create array used for displaying bead position
peak_match = peak_mark;
r_inner_mark = half_region - 1;
r_outer_mark = r_inner_mark + 1;
seite_mark = 2*r_outer_mark + 1;
circle_center_mark = double(circle(r_inner_mark, seite_mark));
circle_outer_mark = double(xor(circle(r_inner_mark, seite_mark),circle(r_outer_mark, seite_mark)));

% 12. Peak Finding
for i = 1:movie.rows
    for j = 1: movie.columns
        if peak_check(i,j) < threshold
            peak_check(i,j) = 0;             
        end
    end
end

% 13. Roundness-Check
number_of_molecules_found = 0;
not_good = 0;
molecules_found = [];            % initialize array of bead positions
neighbouring_molecule = [];
for i = half_region + 3 : movie.rows - half_region - 3            % leave out the borders
    for j = half_region + 3 :  movie.columns - half_region - 3
        if peak_check(i,j) > 0
            if peak_check(i,j) == max(max(peak_check(i-3:i+3,j-3:j+3)))  %find local maxima %PEAK SUCHEN
                % 13.1 check if peak is round      
                ROI = frame_average_correct(i-r_outer_round:i+r_outer_round,j-r_outer_round:j+r_outer_round);
                roundness_check = ROI(ring_round);
                mean_center = mean(mean(ROI(center)));
                mean_ring = mean(mean(roundness_check));
                st_dev_ring = std(roundness_check);
                if mean_center <= mean_ring
                    break
                end
                % 13.2 check if the signal around the molecule drops or
                % whether there are potential neighbouring molecules
                neighbouring_molecule = roundness_check(find(roundness_check>(mean_ring + 3*st_dev_ring)));
                if any(neighbouring_molecule)
                   not_good = not_good +1;     % count number of bad selections
                   break; 
                end
                quality = 1;
                % 13.3 fine_tune the peak position
                if quality == 1 % -> bead was selected
                    cur_best = 16384.0;                     % should be higher than anything we expect
                    g_peaks = gauss_peaks;                  % call to function that creates gauss peaks with shifting
                    best_x = 1;
                    best_y = 1;
                    for k = 1:3
                        for l = 1:3
                            diff(k,l) = sum(sum(abs(squeeze(peak_check(i,j) * g_peaks(k,l,:,:)) - frame_average_correct(i-3:i+3,j-3:j+3))));
                            if diff(k,l) < cur_best
                                best_x = l;
                                best_y = k;
                                cur_best = diff(k,l);
                            end
                        end
                    end
                    peak_mark(i-half_region:i+half_region,j-half_region:j+half_region) = peak_mark(i-half_region:i+half_region,j-half_region:j+half_region).*circle_center_mark + circle_outer_mark*255; %right side
                    molecules_found = [molecules_found; j+0.5*(best_x-2), i+0.5*(best_y-2)];      % make array of bead positions
                    number_of_molecules_found = number_of_molecules_found + 1;                     % count number of selected beads
                else
                    not_good = not_good + 1;
                end % if quality == 1
            end % if peak_check
        end % if peak_check > 0
    end % for j
end %for i

% 14. display found beads
disp('  ');
disp(strcat(['Single beads found: ' num2str(number_of_molecules_found)]));
disp('  ');
disp(strcat(['Single beads rejected: ' num2str(not_good)]));
figure(1); clf;
imagesc(peak_mark, [0 255]);
title('All peaks found are marked with a circle');
molecules_found = sortrows(molecules_found,1);
molecules_found = flipud(molecules_found);

% 15. match the position of the beads using the determined shifts
result= [];
for i = 1:number_of_molecules_found-1
    if (molecules_found(i,1) > movie.columns/2 + half_region + 3) && (molecules_found(i,1) < movie.columns - (half_region + 3))
        for j = i+1:number_of_molecules_found
            if (abs(molecules_found(i,2) - molecules_found(j,2) - shift_y) < 4) && (abs(molecules_found(i,1) - molecules_found(j,1) - shift_x) < 4)
                result = [result; molecules_found(i,:) , molecules_found(j,:)];
            end
        end
    end
end
disp('  ');
disp(strcat(['Paired Beads found: ' num2str(length(result))]));
if (length(result)) < 5
    disp('ERROR: Not enough matching beads found')
end

% 16. mark the position of the matched beads (red circle) %%%%%%%%
bead_pairs = [result(:,1), result(:,2); result(:,3), result(:,4)];
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

result(:,1) = result(:,1) - movie.columns/2;                                 % want to map the points of the upper half to coordinates of lower half
destination_points   = [result(:,1),result(:,2)];                          % points in lower half
input_points  = [result(:,3),result(:,4)];                                 % points in upper half

TFORM = cp2tform(input_points, destination_points,'polynomial',3);         % this should make the transform to make a matching upper half
%predicted_destinations = tforminv(TFORM,destination_points);               % check how it worked
%map_residuals = input_points - predicted_destinations;                      

[transform_map, xdata, ydata] = imtransform(frame_average_correct_8bit(:,1:movie.columns/2),TFORM,'Fill',255,'XData', [1, movie.columns/2], 'YData', [1, movie.rows]);
%frame_linear = [transform_map; frame_average_correct_8bit(:,257:end)];             % put the two halfs in one array

% figure(8); clf;
% image_correct_transform = imagesc(frame_linear, [0 255]);
%[shift_x shift_y] = map_test(frame_linear)                                 % check program to test the mapping                     

add_image = transform_map+frame_average_correct_8bit(:,movie.columns/2+1:end);

figure(3); clf;
imagesc(add_image);
title('Overlay of the two camera halfs after correction');
map = TFORM;                                                          % return the mapping structure
filename_base = filename(1:findstr(filename,'.')-1);
filename_map = strcat(filename_base,'.map');
save(filename_map,'map','-mat');
disp(['Map saved as Matlab File in ' filename_map]);