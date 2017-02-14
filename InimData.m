%Initialize the structure mData using information in the structures data
%(trace_data, trace_red, bckgnd, red_bckgnd)and userData(cameraside, alex)
%and the number of molecule to analyse.
function mData = InimData(data, userData, molecule)
switch userData.cameraside
    case 1 
        mData.donor = data.trace_data(:,molecule+1);
        mData.acceptor = [];
    case 2
        mData.donor = [];
        mData.acceptor = data.trace_data(:,molecule+1);
    case 3
        mData.donor = data.trace_data(:,2*molecule);
        mData.acceptor = data.trace_data(:,2*molecule+1);
end

if ~isempty(data.trace_red)
    mData.red = data.trace_red(:,2*molecule+1);
else
    mData.red = [];
end
%%% Get data to plot the BACKGROUND of a single molecule %%%%
if numel(data.bckgnd)>1
    switch userData.cameraside
        case 1
            mData.background_left = data.bckgnd(:,molecule+1);
            mData.background_right = [];
        case 2
            mData.background_right = data.bckgnd(:,molecule+1);
            mData.background_left = [];
        case 3
            mData.background_left = data.bckgnd(:,2*molecule);
            mData.background_right = data.bckgnd(:,2*molecule+1);
    end

    if numel(data.red_bckgnd)>1
        mData.background_right_red = data.red_bckgnd(:,2*molecule+1);
    else
        mData.background_right_red = [];
    end
else
    mData.background_right = [];
    mData.background_left = [];
    mData.background_right_red = [];
end