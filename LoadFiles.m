%Load the files required according to the number of file chosen and the
%userData information and then in the structure data. Additionally
%inizialize control.molecule and control.totalMolecules, and the analysis
%structure.
function [data control analysis]= LoadFiles(control,userData,numFile)
filename = [control.path,control.file{numFile}];
data.trace_data = load(filename);
filename_base = filename(1:findstr(filename,'.')-1);
filename_cor = strcat(filename_base,'.cor');
data.coordinates = load(filename_cor);

if userData.old_data == 0
    filename_back = strcat(filename_base,'.bck');
    data.bckgnd = load(filename_back);
else
    data.bckgnd = [];
end

if userData.alex
    filename_atr = strcat(filename_base,'.atr');
    data.trace_red = load(filename_atr);
    if userData.old_data == 0
        filename_back_red = strcat(filename_base,'.bkr');
        data.red_bckgnd = load(filename_back_red);
    else
        data.red_bckgnd = [];
    end
else
    data.trace_red = [];
    data.red_bckgnd = [];
end

if userData.cameraside == 3
    control.totalMolecules = floor(size(data.trace_data,2)/2);
else
    control.totalMolecules = size(data.trace_data,2)-1;
end

data.time = data.trace_data(:,1);
control.molecule = 1;

analysis.selectedTraces = zeros(1,control.totalMolecules);

analysis.finalData=cell(control.totalMolecules,1);
[analysis.goodMolecules analysis.allIndex]= ...
    prefilter(data.trace_data,data.trace_red,control.totalMolecules,userData);