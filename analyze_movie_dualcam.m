% Written by R. Lewis 21/05/10
% tasks:
% load 2 movies from 2 cameras
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
function result = analyze_movie_dualcam(filename, filename_acc, thresh, half_region, cameraside, correct_min, correct_backgnd, map, alex, start_frame, stop_frame)
disp('Loading movie ...');
if stop_frame == 0 || stop_frame > ceil((59 + start_frame) / 1.5)
    stop_frame = ceil((59 + start_frame) / 1.5);
end
frame_number = start_frame:1:start_frame+59;
current_movie = 0;
total_frames = start_frame + 59;
breakpoint = start_frame + 59;
rerun = 0;
info = [];
acceptor_file = 0;
green_start = 1;
while min(frame_number) < total_frames

    % 1. load the movies and pack in structure
    %  .imageData : Array with Pixelcounts(y, x, t) !!!
    %  .size : Timesteps
    %  .columns : Number of x-Pixel
    %  .rows : Number of y-Pixel
    % funtion should only run when cameraside == 0, meaning in dualcam mode
    % the video is loaded in packs of 60 frames
    [movie_donor, info, green_start, total_frames, current_movie, breakpoint] = load_movie_dualcam(filename, info, acceptor_file, alex, green_start, total_frames, frame_number, current_movie, rerun, breakpoint);
    if strcmp(info,'SIF') == 1
        frame_number = total_frames;
    end
    acceptor_file = 1;
    [movie_acceptor, info, green_start, total_frames, current_movie, breakpoint] = load_movie_dualcam(filename_acc, info, acceptor_file, alex, green_start, total_frames, frame_number, current_movie, rerun, breakpoint);

    % 2. reduce end frame of movie when using ALEX
    if stop_frame > total_frames || stop_frame*1.5 > movie_donor.size
        stop_frame = floor(movie_donor.size*0.66);
    end
    if rerun == 0

        % 3. calculate minimum
        % first data_correction : absolutes Minimum berechnen
        if alex == 1
            min_pix_intensity_donor = min(min(min(movie_donor.imageData(:,:,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
            max_pix_intensity_donor = max(max(max(movie_donor.imageData(:,:,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
            disp([' Minimum pixel intensity for DONOR:  ' num2str(min_pix_intensity_donor)]);
            disp([' Maximum pixel intensity for DONOR:  ' num2str(max_pix_intensity_donor)]);
            min_pix_intensity_acceptor = min(min(min(movie_acceptor.imageData(:,:,start_frame:stop_frame))));
            max_pix_intensity_acceptor = max(max(max(movie_acceptor.imageData(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for ACCEPTOR:  ' num2str(min_pix_intensity_acceptor)]);
            disp([' Maximum pixel intensity for ACCEPTOR:  ' num2str(max_pix_intensity_acceptor)]);
            min_pix_intensity_red = min(min(min(movie_acceptor.imageData_red(:,:,start_frame:stop_frame))));
            max_pix_intensity_red = max(max(max(movie_acceptor.imageData_red(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for RED:  ' num2str(min_pix_intensity_red)]);
            disp([' Maximum pixel intensity for RED:  ' num2str(max_pix_intensity_red)]);
        else
            min_pix_intensity_donor = min(min(min(movie_donor.imageData(:,:,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
            max_pix_intensity_donor = max(max(max(movie_donor.imageData(:,:,ceil(stop_frame*0.66):ceil(stop_frame*1.5)))));
            disp([' Minimum pixel intensity for DONOR:  ' num2str(min_pix_intensity_donor)]);
            disp([' Maximum pixel intensity for DONOR:  ' num2str(max_pix_intensity_donor)]);
            min_pix_intensity_acceptor = min(min(min(movie_acceptor.imageData(:,:,start_frame:stop_frame))));
            max_pix_intensity_acceptor = max(max(max(movie_acceptor.imageData(:,:,start_frame:stop_frame))));
            disp([' Minimum pixel intensity for ACCEPTOR:  ' num2str(min_pix_intensity_acceptor)]);
            disp([' Maximum pixel intensity for ACCEPTOR:  ' num2str(max_pix_intensity_acceptor)]);
        end

        % 4. correct for minimum intensity
        if correct_min == 1
            movie_donor.imageData = movie_donor.imageData - min_pix_intensity_donor;
            movie_acceptor.imageData = movie_acceptor.imageData - min_pix_intensity_acceptor;
            if alex == 1
                movie_acceptor.imageData_red = movie_acceptor.imageData_red - min_pix_intensity_red;
            end
        end

        % 5. generate arrays for peakfinding by time averaging
        % use map, to map donor to acceptor camera
        frame_average = mean(movie_donor.imageData(:,:,ceil(stop_frame*0.66):ceil(stop_frame*1.5)),3);
        [donor, xdata, ydata] = imtransform(frame_average(:,:),map,'Fill',0,'XData', [1 movie_donor.columns], 'YData', [1, movie_donor.rows]);
        acceptor = mean(movie_acceptor.imageData(:,:,start_frame:stop_frame),3);
        combined = donor + acceptor;
        frame_average(:,:) = frame_average(:,:) + acceptor;
        if alex == 1
            acceptor_red = mean(movie_acceptor.imageData_red(:,:,start_frame:stop_frame),3);
            frame_average(:,:) = frame_average(:,:) + acceptor_red;
        end

        % 6. calculate local background
        backgnd = ones(movie_donor.rows, movie_donor.columns);
        backgnd_donor = ones(movie_donor.rows, movie_donor.columns);
        backgnd_acceptor = ones(movie_acceptor.rows, movie_acceptor.columns);
        backgnd_combined = ones(movie_donor.rows, movie_donor.columns);
        if alex == 1
            backgnd_acceptor_red = ones(movie_acceptor.rows, movie_acceptor.columns);
        end
        for i = 8:16:movie_donor.rows-8
            for j = 8:16:movie_donor.columns-8
                backgnd(i-7:i+8,j-7:j+8) = min(min(frame_average(i-7:i+8,j-7:j+8)));
                backgnd_donor(i-7:i+8,j-7:j+8) = min(min(donor(i-7:i+8,j-7:j+8)));
                backgnd_acceptor(i-7:i+8,j-7:j+8) = min(min(acceptor(i-7:i+8,j-7:j+8)));
                if alex == 1
                    backgnd_acceptor_red(i-7:i+8,j-7:j+8) = min(min(acceptor_red(i-7:i+8,j-7:j+8)));
                end
                backgnd_combined(i-7:i+8,j-7:j+8) = min(min(combined(i-7:i+8,j-7:j+8)));
            end
        end

        % 6. filter the background and subtract local background from movie
        h = ones(20,20) / 400;
        backgnd = imfilter(backgnd,h, 'replicate');
        backgnd_donor = imfilter(backgnd_donor,h, 'replicate');
        backgnd_acceptor = imfilter(backgnd_acceptor,h, 'replicate');
        backgnd_combined = imfilter(backgnd_combined,h, 'replicate');
        donor_correct = donor - backgnd_donor;
        clear donor;
        clear background_donor;
        acceptor_correct = acceptor - backgnd_acceptor;
        clear acceptor;
        clear backgnd_acceptor;
        frame_average_correct = frame_average - backgnd;
        clear frame_average;
        clear backgnd;
        combined_correct = combined - backgnd_combined;
        clear combined;
        clear backgnd_combined;
        if alex == 1
            backgnd_acceptor_red = imfilter(backgnd_acceptor_red,h, 'replicate');
            acceptor_red_correct = acceptor_red - backgnd_acceptor_red;
            clear acceptor_red;
            clear backgnd_acceptor_red;
        end

        % 7. 8-bit normalization
        image_frame_average_max = max(max(frame_average_correct));
        frame_average_correct_8bit = frame_average_correct ./ image_frame_average_max .* 255;
        clear frame_average_correct;

        % 8. create array used for peak finding
        if alex == 1
            peak_check_donor = donor_correct;
            peak_check = combined_correct;
            peak_check_red = acceptor_red_correct;
        else
            peak_check = combined_correct;
            peak_check_acceptor = acceptor_correct;
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
        if alex == 1
            temp = sort(reshape(peak_check_donor,movie_donor.rows.*movie_donor.columns,1));
            threshold_donor = round(temp(round(thresh*movie_donor.rows*movie_donor.columns),1));
            threshold = threshold_donor;
            temp = sort(reshape(peak_check_red,movie_acceptor.rows.*movie_acceptor.columns,1));
            threshold_red = round(temp(round(thresh_red*movie_acceptor.rows*movie_acceptor.columns),1));
        else
            temp = sort(reshape(peak_check_acceptor,movie_acceptor.rows.*movie_acceptor.columns,1));
            threshold_acceptor = round(temp(round(thresh*movie_acceptor.rows*movie_acceptor.columns),1));
            threshold = threshold_acceptor;
        end
        clear temp;

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
        if alex == 1
            mask_donor = (peak_check_donor > threshold);
            mask_red = (peak_check_red > threshold_red);
            peak_find = and(mask_donor, mask_red);
            peak_check = peak_find .* peak_check;
            clear peak_find;
        else
            mask_acceptor = (peak_check_acceptor > threshold);
            peak_check = mask_acceptor .* peak_check;
        end

        % 13. roundness-check
        number_of_molecules_found = 0;
        not_good = 0;
        molecules_found = [];            % initialize array of bead positions
        neighbouring_molecule = [];
        index = find(peak_check);
        [k,l] = ind2sub([512,512],index);
        for x = 1 : length(k)           % take only peaks above threshold
            i = k(x,:);
            j = l(x,:);
            if i > half_region + 3 && i < movie_acceptor.rows - half_region - 3 && j > half_region + 3 && j < movie_acceptor.columns - half_region - 3
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
                    % 13.3 match the corresponding channels
                    if quality == 1
                        peak = [j,i];
                        peak_predict = tforminv(map,peak);
                        peak_1 = round(peak_predict(1));
                        peak_2 = round(peak_predict(2));
                        if (peak_1 < half_region + 2) || (peak_2 < half_region + 2) || (peak_2 > movie_donor.rows - (half_region + 2)) || (peak_1 > movie_donor.columns - (half_region + 2))
                            quality = 0;
                        end
                        if (peak_1 > (half_region + 2)) && (peak_2 > (half_region + 2)) && (peak_2 < movie_donor.rows - (half_region + 2)) && (peak_1 < movie_donor.columns - (half_region + 2))
                            molecules_found = [molecules_found; peak_1, peak_2, j, i];
                            number_of_molecules_found = number_of_molecules_found + 1; % count number of selected beads
                            peak_mark(i-half_region:i+half_region,j-half_region:j+half_region) = peak_mark(i-half_region:i+half_region,j-half_region:j+half_region).*circle_center_mark + circle_outer_mark*255; %acceptor side
                            peak_mark(peak_2-half_region:peak_2+half_region,peak_1-half_region:peak_1+half_region) = peak_mark(peak_2-half_region:peak_2+half_region,peak_1-half_region:peak_1+half_region).*circle_center_mark + circle_outer_mark*128; % donor side
                        else
                            quality = 0;
                        end
                        if quality == 0
                            not_good = not_good + 1;
                        end
                    end
                end
            end
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
    end

        % 15. extract intensities
        T = size(movie_acceptor.imageData,3);
        if alex == 1
            T_red = size(movie_acceptor.imageData_red,3);
            if T > T_red
                T = T_red;
            end
        end
        time_trace = ones(T,(number_of_molecules_found*2)); %result-array for intensity-traces
        backgnd_trace = time_trace;  %result-array for background-traces
        if alex == 1
            time_trace_red = time_trace;
            backgnd_trace_red = time_trace_red;
        end
        for t = 1:T  %Zeititeration
            movie_donor_trace = double(movie_donor.imageData(:,:,t));  %Frame(t) in Variable laden
            movie_acceptor_trace = double(movie_acceptor.imageData(:,:,t));
            if alex == 1
            movie_red_trace = double(movie_acceptor.imageData_red(:,:,t)); %Direct Excitation Frames
            end
            for i = 1:number_of_molecules_found   %Moleküliteration
                j = i*2-1;
                %%%%%%%%%%%%%%%%%%%%%green excitation, donor part %%%%%
                ROI_donor = movie_donor_trace(molecules_found(i,2)-r_outer:molecules_found(i,2)+r_outer,molecules_found(i,1)-r_outer:molecules_found(i,1)+r_outer);
                time_trace_donor = sum(sum(circle_intensity.*ROI_donor)); %/pixel !!!!!(One can divide by pixel)!!!!!
                bg_donor = ROI_donor(ring);   %extract pixelcounts in background area
                th_donor = mean(bg_donor)+3*std(bg_donor); % calculate threshold for statistical backgroundpeaks
                backgnd_donor = mean(bg_donor(find(bg_donor<th_donor)))*pixel;  % background = mean of all background values lower then the threshold
                %backgnd_donor = calculate_backgnd(movie_green_trace,molecules_found(i,2),molecules_found(i,1))*points;
                %%%%%%%%%%%%%%%%%%%%green excitation, acceptor part%%%%
                ROI_acceptor = movie_acceptor_trace(molecules_found(i,4)-r_outer:molecules_found(i,4)+r_outer,molecules_found(i,3)-r_outer:molecules_found(i,3)+r_outer);
                time_trace_acceptor = sum(sum(circle_intensity.*ROI_acceptor)); %/pixel !!!!!(One can divide by pixel)!!!!!
                bg_acceptor = ROI_acceptor(ring);   %extract pixelcounts in background area
                th_acceptor = mean(bg_acceptor)+3*std(bg_acceptor); % calculate threshold for statistical backgroundpeaks
                backgnd_acceptor = mean(bg_acceptor(find(bg_acceptor<th_acceptor)))*pixel;  % background = mean of all background values lower then the threshold
                %backgnd_acceptor = calculate_backgnd(movie_green_trace,molecules_found(i,4),molecules_found(i,3))*points;
                %%%%%%%%%%%%%%%%%%%%red excitation, acceptor part%%%%
                if alex == 1
                    ROI_red = movie_red_trace(molecules_found(i,4)-r_outer:molecules_found(i,4)+r_outer,molecules_found(i,3)-r_outer:molecules_found(i,3)+r_outer);
                    time_trace_acceptor_red = sum(sum(circle_intensity.*ROI_red)); %/pixel !!!!!(One can divide by pixel)!!!!!
                    bg_red = ROI_red(ring);   %extract pixelcounts in background area
                    th_red = mean(bg_red)+3*std(bg_red); % calculate threshold for statistical backgroundpeaks
                    backgnd_acceptor_red = mean(bg_red(find(bg_red<th_red)))*pixel;  % background = mean of all background values lower then the threshold
                    time_trace_red(t,j:j+1) = [0, time_trace_acceptor_red];
                    backgnd_trace_red(t,j:j+1) = [0, backgnd_acceptor_red];
                end
                time_trace(t,j:j+1) = [time_trace_donor, time_trace_acceptor];
                backgnd_trace(t,j:j+1) = [backgnd_donor, backgnd_acceptor];
            end
        end

        % 16. generate time traces
        if rerun == 0
            time_axis = (1:T)';
        else
            time_axis = (time_axis(end,1)+1:time_axis(end,1)+T)';
        end
        if correct_backgnd == 1
            time_trace = time_trace - backgnd_trace;
            if alex == 1
                time_trace_red = time_trace_red - backgnd_trace_red;
            end
        end
        time_trace = [time_axis, time_trace];
        backgnd_trace = [time_axis, backgnd_trace];
        if rerun == 0
            time_trace_start = [];
            backgnd_trace_start = [];
            time_trace_red_start = [];
            backgnd_trace_red_start = [];
        end
        time_trace_start = [time_trace_start; time_trace];
        backgnd_trace_start = [backgnd_trace_start; backgnd_trace];
        if alex == 1
            time_trace_red = [time_axis, time_trace_red];
            backgnd_trace_red = [time_axis, backgnd_trace_red];
            time_trace_red_start = [time_trace_red_start, time_trace_red];
            backgnd_trace_red_start = [backgnd_trace_red_start, backgnd_trace_red];
        end
        if strcmp(info,'SIF') ~= 1
            frame_number = max(frame_number) + 1:1:max(frame_number) + 60;
            if min(frame_number) > breakpoint
                current_movie = current_movie + 1;
                breakpoint = breakpoint * (current_movie+1);
            end
            rerun = rerun + 1;
        end
        clear movie_donor;
        clear movie_acceptor;          
end
result.time_trace = time_trace_start;
if alex == 1
    result.time_trace_red = time_trace_red_start;
end
result.coordinates = molecules_found;
disp('End of analysis, saving...');

% 17. save data
filename_base = filename(1:findstr(filename,'_DON')-1);
filename_num = filename(findstr(filename,'_DON')+4:findstr(filename,'.')-1);
filename_base = strcat(filename_base, filename_num);
filename_base = strcat(filename_base, '_th_', num2str(round(threshold)), '_rad_', num2str(half_region), '.' );
filename_cor = strcat(filename_base,'cor');
filename_ttr = strcat(filename_base,'ttr');
filename_bck = strcat(filename_base,'bck');
save(filename_cor,'molecules_found','-ASCII','-tabs');
save(filename_ttr,'time_trace_start','-ASCII','-tabs');
save(filename_bck,'backgnd_trace_start','-ASCII','-tabs');
if alex == 1
    filename_atr = strcat(filename_base,'atr');
    filename_back_red = strcat(filename_base,'bkr');
    save(filename_atr,'time_trace_red_start','-ASCII','-tabs');
    save(filename_back_red,'backgnd_trace_red_start','-ASCII','-tabs');
end