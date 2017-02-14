% Rewritten by R. Lewis 21/10/09
% tasks:
% main analysis program to run the analysis in batch mode

% used functions and scripts:       (only self_written mentioned not MatLab)
% analyze_movie

% used parameters:
% stop_frame_map
% thresh
% half_region
% cameraside
% alex
% correct_min
% correct_backgnd
% start_frame and stop_frame for averaging movieframes for peakfinding

% hand over parameters
userData = menu_batch_analysis();
thresh = userData.thresh;
half_region = userData.half_region;
cameraside = userData.cameraside;
correct_min = userData.correct_min;
correct_backgnd = userData.correct_backgnd;
alex = userData.alex;
start_frame = userData.start_frame;
stop_frame = userData.stop_frame;
global map
if cameraside ~= 3 && cameraside ~= 0
    map = [];
else
    have_map = menu('Have you already analyzed and saved a map ?','No', 'Yes', 'Already Loaded')-1;
    switch have_map
        case 0
            disp('  ');
            disp('You have to define a map first');
            disp('  ');
            disp('Please choose:');
            if stop_frame == 0
                stop_frame_map = 25;
            else
                stop_frame_map = stop_frame;
            end
            if cameraside == 0
                map = map_beads_dualcam(stop_frame_map);
            else
                map = map_beads(stop_frame_map);
            end
        case 1
            disp('  ');
            disp('You have to define a map first');
            disp('  ');
            disp('Please choose:');
            [file path] = uigetfile('*.map','Loading pre-analyzed map');
            filename = strcat([path file]);
            load(filename,'-mat');
        case 2
            if isempty(map) == 1;
                have_map_again = menu('No map found ! Please choose:','Load pre-analyzed map', 'Analyze Map')-1;
                switch have_map_again
                    case 0
                        [file path] = uigetfile('*.map','Loading pre-analyzed map');
                        filename = strcat([path file]);
                        load(filename,'-mat');
                    case 1
                        if stop_frame == 0
                            stop_frame_map = 25;
                        else
                            stop_frame_map = stop_frame;
                        end
                        if cameraside == 0
                            map = map_beads_dualcam(stop_frame_map);
                        else
                            map = map_beads(stop_frame_map);
                        end
                end
            end
    end
end

% load movies and start analyze_movie
if cameraside ~= 0 % normal movies with split cameras
    [file path] = uigetfile({'*.sif';'*.tif'},'Loading Movies to analyze','MultiSelect','on');
    if ~iscell(file)
        a = file;
        file = cell(1,1);
        file{1,1} = a;
    end
    if path ~=0
        k = strfind(file,'.tif');% TIF movies should be loaded as chunks
        l = strfind(file,'_X'); % all extension TIFs have to be sorted out
        if length(k) == 1 && length(l) == 1 && ~isempty(k{:,1}) && isempty(l{:,1})
            tif_file = 1;
        else
            j = 0;
            for i = 1:length(k)
                dummy_k = k{:,i};
                dummy_l = l{:,i};
                    if ~isempty(dummy_k) && isempty(dummy_l)
                        j = j+1;
                        new_filelist{1,j} = file{1,i};
                        tif_file = 1;
                    elseif isempty(dummy_k) && isempty(dummy_l)
                        j = j+1;
                        new_filelist{1,j} = file{1,i};
                        tif_file = 0;                        
                    end                
            end
            file = new_filelist;
        end
        number_of_files = size(file,2);
        disp(strcat(['Files selected for analysis: ' num2str(number_of_files)]));
        for i=1:number_of_files
            filename = strcat(path,file{1,i});
            disp(['Analyzing filename "' filename '"...']);
            switch tif_file
                case 0
                    analyze_movie(filename, thresh, half_region, cameraside, correct_min, correct_backgnd, map, alex, start_frame, stop_frame);
                case 1
                    analyze_movie_tif(filename, thresh, half_region, cameraside, correct_min, correct_backgnd, map, alex, start_frame, stop_frame);
            end
            disp(['Finished analyzing: " ' filename, ' "']);
        end
    else
        errordlg('No Files selected','File Error');
    end
else % loading files from 2 cameras
    [file path] = uigetfile({'*.sif';'*.tif'},'Loading Donor Movies to analyze','MultiSelect','on');
    if ~iscell(file)
        a = file;
        file = cell(1,1);
        file{1,1} = a;
    end
    if path ~=0
        k = strfind(file,'_DON');% only movies with _DON ending should be loaded
        l = strfind(file,'_X'); % otherwise _X extension videos or even Acceptor movies are opened
        if ~isempty(k)
            j = 0;
            for i = 1:length(k)
                dummy_DON = k{:,i};
                dummy_X = l{:,i};
                if ~isempty(dummy_DON) && isempty(dummy_X)
                    j = j+1;
                    new_filelist{1,j} = file{1,i};
                end
            end
            file = new_filelist;
        end
        path_acceptor = uigetdir(path,'Select Directory of Acceptor Movies');
        if ~isempty(path_acceptor)
            number_of_files = size(file,2);
            for i=1:number_of_files
                filename = [path,file{1,i}];
                filename_base = filename(1:findstr(filename,'_DON')-1);
                filename_num_suffix = filename(findstr(filename,'_DON')+4:end);
                if exist(strcat(filename_base,'_ACC',filename_num_suffix),'file') == 2
                    filename_acc = strcat(filename_base,'_ACC',filename_num_suffix);                    
                else
                    filename_acc = [];
                    errordlg('WARNING: No Acceptor videos with corresponding filename found !!!');
                    continue
                end
                disp(strcat(['Files selected for analysis: ' num2str(number_of_files)]));
                if ~isempty(filename_acc)
                    disp(['Analyzing filename "' filename '"...']);
                    analyze_movie_dualcam(filename, filename_acc, thresh, half_region, cameraside, correct_min, correct_backgnd, map, alex, start_frame, stop_frame);
                end
                disp(['Finished analyzing: " ' filename, ' "']);
            end
        else
            errordlg('No Acceptor videos selected','File Error');
        end
    else
        errordlg('No Files selected','File Error');
    end
end