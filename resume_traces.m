% if one wants to resume data from previous but stopped analysis then one
% jumps better in here than using the same script
% the difference will be that this file will be shorter as all variables so
% far are saved in a MAT-File with the ending *.res

%%%%%%%%%%%%%%%%%%zu analysierende Datei ermitteln%%%%%%%%%%%%%%%%
[file,pathname] = uigetfile('*.res', 'Resume old data');
file = strcat(pathname, file);
load(file,'-mat');

%%%%%%%%%%%%%%%%%%Schleife zurück und vor und raus%%%%%%%%%%%%%%%%%%%
while i <= number_of_molecules
    %%%%%%%%%%% Donor & Acceptor & Alex aus Trace_daten auslesen%%%%%%%%%
    switch cameraside
        case 1
            donor = trace_data(:,i+1);
            acceptor = [];
            background_left = background(:,i+1);
            background_right = [];
            red = [];
            background_right_red = [];
        case 2
            donor = [];
            acceptor = trace_data(:,i+1);
            background_left = [];
            background_right = background(:,i+1);
            red = [];
            background_right_red = [];
            if alex == 1
                red = trace_data_red(:,i+1);
                background_right_red = background_red(:,i+1);
            end
        case 3
            donor = trace_data(:,2*i);
            acceptor = trace_data(:,2*i+1);
            background_left = [];
            background_right = [];
            if old_data == 0
                background_left = background(:,2*i);
                background_right = background(:,2*i+1);
            end
            red = [];
            background_right_red = [];
            if alex == 1
                red = trace_data_red(:,2*i+1);
                if old_data == 0
                    background_right_red = background_red(:,2*i+1);
                end
            end
    end
    %%%%%%%%%%%%%%%display trace and background%%%%%%%%%%%%%%%%%%
    [accept,result,trace,FRET_only_trace,back,exit] = plot_trace(donor,acceptor,red,background_left,background_right,background_right_red,time,smoothwidth,alex,cameraside,number_of_molecules,analysis,file,i,old_data);
    if exit == 1 % Save Data when exit %%%%%%%%%%%%%%%%%%%%%%%%
        save_name_res = strcat(filename_base,'.res');
        save(save_name_res,'-mat');
        disp(['Results saved meanwhile as Matlab File in ' save_name_res]);
        return
    end
    if accept == 1
        result = [i result];
        trace_report = [trace_report; result];        %append result to list
        trace_sheet = [trace_sheet, trace];
        FRET_only_trace_sheet = {FRET_only_trace_sheet{:}, FRET_only_trace};
    end
    if back == 1 && i == 1 % don't go back one trace if one is at trace no 1 already
        i = i-1;
        trace_report = [];
        trace_sheet = [];
        FRET_only_trace_sheet = {};
    end
    if back == 1 && i >= 2         % go back one trace
        i = i-2;
        if size(trace_report,1) == 1
            trace_report = [];
            trace_sheet = [];
            FRET_only_trace_sheet = {};
        else
        trace_report = trace_report(1:end-1,:);
        trace_sheet = trace_sheet(:,1:end-1);
        FRET_only_trace_sheet = FRET_only_trace_sheet(1:end-1);
        end
    end
    if accept == 0 && i == number_of_molecules && size(trace_report,1) == 0; % at the last trace and not a single one was selected
        disp('No traces selected');
        return
    end
    if exit == 2 % if one wants to get out
        disp('Data not saved');
        return
    end
    i = i+1;
end
%%%%%%%%%%%%%%%%%%%% PLOT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[FRET,x_FRET] = hist(trace_report(:,3));
[gamma,x_gamma] = hist(trace_report(:,5));
figure(1);
subplot(2,2,1);
text = strcat('FRET results of ',file);
clear title;
title(text);
bar(x_FRET,FRET);
ylabel('Number of events ');
xlabel('E');
subplot(2,2,2);
bar(x_gamma,gamma);
ylabel('Number of events ');
xlabel('Gamma');
subplot(2,2,3);
plot(trace_report(:,1),trace_report(:,3),'*');
ylabel('E');
xlabel('Molecule number');
subplot(2,2,4);
plot(trace_report(:,1),trace_report(:,5),'*');
ylabel('Gamma');
xlabel('Molecule number');

%%%%%%%%%%%%%%%%%%%%%%%%Save Data normally%%%%%%%%%%%%%%%%%%%
save_name = filename_base;
save_name_report = strcat(save_name,'_res.txt');
save_name_trace = strcat(save_name,'_trace.txt');
save_name_FRET_only_trace = strcat(save_name, '_FRETonly_trace.txt');
save(save_name_report,'trace_report','-ASCII');
save(save_name_trace,'trace_sheet','-ASCII');
fileHandle = fopen(save_name_FRET_only_trace, 'wt');
for i = 1:length(FRET_only_trace_sheet)
    fprintf(fileHandle, '%e %e %e %e %e \n', FRET_only_trace_sheet{i}');
    fprintf(fileHandle, '\n');
end
fclose(fileHandle);
disp(strcat('Data: (Molecule number, FRET2_sr E std_E gamma beta 0 FRET_length trace_length signal_donor noise_donor signal_acceptor noise_acceptor signal_red noise_red signal_background_left noise_background_left signal_background_right noise_background_right signal_background_right_red noise_background_right_red) written to ',' ',save_name,'_res.txt'));