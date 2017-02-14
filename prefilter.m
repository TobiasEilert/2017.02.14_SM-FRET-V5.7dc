% Look for good traces using the auto analysis program. Returns a binary
% list with the selected molecules and a cell array with the start, pre and
% post FRET and end localization in the selected position and empty cell in
% the others.
function [acceptedProgram allIndex] = ...
    prefilter(trace_data,trace_red,nMolecules,userData)
acceptedProgram = zeros(1,nMolecules);
allIndex = cell(1,nMolecules);
for num = 1:nMolecules;
    switch userData.cameraside
        case 1
            donor = trace_data(:,num);
            acceptor = donor;
        case 2
            acceptor = trace_data(:,num);
            donor = acceptor;
        case 3
            donor = trace_data(:,2*num);
            acceptor = trace_data(:,2*num+1);
    end
    acceptor = medfilt1(acceptor,5);
    donor = medfilt1(donor,5);
    if ~isempty(trace_red)
        red = trace_red(:,2*num+1);
        red = medfilt1(red,5);
    else
        red = [];
    end
    if userData.cameraside == 3
        [acceptedProgram(num) allIndex{num} peaksIndex] = findGutPlot3(donor,acceptor,red, userData.smoothwidth);
    else
        acceptedProgram = [];
        allIndex = {};
        peaksIndex = [];
    end
end
