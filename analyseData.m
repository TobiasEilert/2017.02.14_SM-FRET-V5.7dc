%Analyse the traces using the previous defined regions, data of a single
%molecule (mData), and user given control variables (userData). The result
%is given back in the structures results, traces and the cell array 
%FRET_only_trace
function [result trace FRET_only_trace] = analyseData(mData, time, userData ,regions) 

result = struct('FRET2_sr', 0,'E', 0, ...
    'std_E', 0,'gamma', 0,'beta', 0,'empty', 0,...
    'FRET_length', 0,'trace_length', 0,'signal_donor', 0,'noise_donor', 0, ...
    'signal_acceptor', 0,'noise_acceptor', 0,'signal_red', 0,'noise_red', 0,...
    'signal_background_left', 0,'noise_background_left', 0, ...
    'signal_background_right', 0,'noise_background_right', 0, ...
    'signal_background_right_red', 0,'noise_background_right_red', 0);

trace = struct('donor_average',[] ,'acceptor_average',[] ,'red_average',[], ...
    'total_int',[],'FRET',[]);
FRET_only_trace={numel(trace)};

switch userData.cameraside
    case 1
        result.FRET_length = 0;
        result.trace_length = length(regions{2}); %regions{2} =donor_region
        result.signal_donor = mean(mData.donor(regions{2}));
        result.noise_donor = std(mData.donor(regions{2}));
        result.signal_acceptor = 0;
        result.noise_acceptor = 0;

    case 2
        result.FRET_length = 0;
        result.trace_length = length(regions{2}); %regions{2} = acceptor_region
        result.signal_donor = 0;
        result.noise_donor = 0;
        result.signal_acceptor = mean(mData.acceptor(regions{2})); 
        result.noise_acceptor = std(mData.acceptor(regions{2}));

    case 3
        result.FRET_length = length(regions{2}); %regions{2} =FRET_region
        result.trace_length = length(regions{4}); %regions{4} = donor_only_region, like in the old program
        result.signal_donor = mean(mData.donor(regions{2}));
        result.noise_donor = std(mData.donor(regions{2}));
        result.signal_acceptor = mean(mData.acceptor(regions{2}));
        result.noise_acceptor = std(mData.acceptor(regions{2}));
end
if userData.alex
    result.signal_red = mean(mData.red(regions{2}));
    result.noise_red = std(mData.red(regions{2}));
end

result.signal_background_left = mean(mData.background_left);
result.noise_background_left = std(mData.background_left);
result.signal_background_right = mean(mData.background_right);
result.noise_background_right = std(mData.background_right);
result.signal_background_right_red = mean(mData.background_right_red);
result.noise_background_right_red = std(mData.background_right_red);

%%%%%%%%%%%%%% Filter Data %%%%%%%%%%%%%%%%%%%%%
if numel(mData.donor) < numel(time)
    trace.donor_average = zeros(size(time));
else
    switch userData.filter
        case 1 %median filter
            trace.donor_average = medfilt1(mData.donor,userData.smoothwidth);
        case 2 %sliding average (mean filter)
            for i=1:numel(regions)
              trace.donor_average = [trace.donor_average; ...
                  smooth(mData.donor(regions{i}),userData.smoothwidth)];
            end
    end
end

if numel(mData.acceptor) < numel(time)
    trace.acceptor_average = zeros(size(time));
else
    switch userData.filter
        case 1
            trace.acceptor_average = medfilt1(mData.acceptor,userData.smoothwidth);
        case 2
            for i=1:numel(regions)
              trace.acceptor_average = [trace.acceptor_average; ...
                  smooth(mData.acceptor(regions{i}),userData.smoothwidth)];
            end
    end
end
            
if numel(mData.red) < numel(time)
    trace.red_average = zeros(size(time));
else
    switch userData.filter
        case 1
            trace.red_average = medfilt1(mData.red,userData.smoothwidth);
        case 2
            for i=1:numel(regions)
              trace.red_average = [trace.red_average; ...
                  smooth(mData.red(regions{i}),userData.smoothwidth)];
            end
    end
end

%%%%%%%%%%%%%%%%% Calculation of Beta & Gamma Values %%%%%%%%%%%%%
if userData.cameraside == 3
    result.beta = mean(mData.acceptor(regions{4}))/mean(mData.donor(regions{4}));
    delta_don = mean(mData.donor(regions{4})) - mean(mData.donor(regions{2}));
    delta_acc = mean(mData.acceptor(regions{2})) - mean(mData.acceptor(regions{4}));
    result.gamma = delta_acc/delta_don;
end

%%%%%%%%%%%%%%%%%Calculation of FRET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trace.total_int = (trace.donor_average.*result.gamma) + trace.acceptor_average;
trace.FRET = (trace.acceptor_average - (result.beta.*trace.donor_average))./ ...
    (trace.acceptor_average + (result.gamma.*trace.donor_average));
result.FRET2_sr = (result.signal_acceptor - (result.beta.*result.signal_donor))/...
    (result.signal_acceptor + (result.gamma.*result.signal_donor));
result.E = mean(trace.FRET(regions{2}));
result.std_E = std(trace.FRET(regions{2}));

%convert the trace structure in a cell array in order to select the FRET
%only region.
dummy = struct2cell(trace);
for i=1:numel(dummy)
    FRET_only_trace{i} = dummy{i}(regions{2}( ...
        ceil(userData.smoothwidth/2):end-ceil(userData.smoothwidth/2)+1));
end