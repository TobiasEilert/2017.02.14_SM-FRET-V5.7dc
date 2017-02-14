function [gutPlot,FRETIndex,whyBad] = findGutPlot3 (donor, acceptor,red, smoothwidth)
%parameters = struct('maxSTDdonor', .15, 'maxSTDFRET', .25, 'maxDonorPeak',
%.25, 'DonorOutPeak', .08, 'maxDonorOut', .15, 'DonorOutStep', .25,
%'maxNegative', -.15, smoothwith, '10');

%This function finds is the function could be a FRET event and returns the
%posible index values for the start, the FRET event and the donor bleaching

%STEP 2. Find posible FRET events
%   2.A Look look for big negative events in the acceptor signal (biggest
%   negative peaks Those could be an acceptor bleaching event. The fist
%   values and last values are not considered. Peaks consisting in two
%   decresing values are considered as the sum of them in order to consider
%   a two step bleaching as one single event. In order to be considered a
%   peak it must be a local minimum.
%   2.B Look at big increments in the donor near an acceptor decrement.
%   There must be a big positive peak in the aceptor signal in order to be
%   considered a FRET event. One position before and after the acceptor peak
%   are checked.
%STEP 3. Checks if donor is really bleach. A certain number of values above
%the established zero value are allowed.
%STEP 4 Look for the donor bleach point

whyBad= 'Error';
%Parameters to find the FRET event and the starting and donor bleaching
%points
peaks2check = 2;   %the fist value to check (FRET events at the begining don't give enough information)
minTol = .5;  %minimal requiered value of the increment with respect of the maximum value in the acceptor derivative allowed to be considered a FRET pair
maxZeroAcceptor = .3;  %Percentage of the maximal value that the function can reach to still be considered zero
maxZeroDonor = .12;
maxZeroRed = .2;
peaksTolerance = round(numel(donor)*0.03);
%5; % The number of values above maxZeroAcceptor allowed.

%Parameters to exclude bad traces
maxSTDdonor = .15;   %Max value of standard deviation in the donor only part
maxSTDFRET = .25;    %Max value of standard deviation in the total intensity
maxSTDred = .25;     %Max value of standard deviation in the red part
maxDonorPeak = .25;  %Value above or below the mean in the donor only part to be considered a peak
DonorOutPeak = .08;  %Percentage of peaks tolerate of the donor only region
maxDonorOut = .15;   %Value above or below the mean in the donor only part to be considered out of the mean
DonorOutStep = .25;  %Percentage out of the mean events tolerate of the donor only region
maxNegative = -.15;

gutPlot = 0;
peaksIndex = zeros(1,peaks2check);
FRETevent = 0;
FRETevent1 =0;
FRETevent2 = 0;
startPoint = 0;
donorBleach = 0;

%Normalize the plot to the biggest absolute value (to get values between -1
%and 1)
donor = donor/max(abs(donor));
acceptor = acceptor/max(abs(acceptor));

%differentiate the original plot in order to dectect abrupt changes
donorM = diff(donor);
donorM = donorM/max(abs(donorM));
acceptorM = diff(acceptor);
acceptorM = acceptorM/max(abs(acceptorM));
redM=[];

if min(donor) < maxNegative || min(acceptor) < maxNegative % donor or acceptor reach too far into negative values
    gutPlot = 0; %this could mean noise too
else
    %STEP 2. Find possible FRET events
    %2.A Look for the negative picks in the acceptor
    dummy = acceptorM;
    dummy(1:ceil(smoothwidth/2)) = 0;
    dummy(end-2:end)=0;
    dummy = singleDecrement(dummy); %Treat a continuous decrement as a single one
    %Find biggest negative peaks.
    flag = 0;
    for i = 1:peaks2check
        while peaksIndex(i) == 0 && ~flag
            [trash index] = min(dummy);
            if dummy(index) < dummy(index+1) && dummy(index) < dummy(index-1) %when the derivative is a local minimum
                peaksIndex(i) = index;
                if dummy(index-1) < dummy(index+1)%if the local minimum is not symmetric on both sides
                    dummy(index) = dummy(index-1);%go back one step
                else
                    dummy(index) = dummy(index+1);%go ahead one step
                end
                if acceptor(index) < maxZeroAcceptor%check the next frame, whether the acceptor trace is below the allowed Zero, so the trace bleached
                    flag = 1;
                end
            else
                dummy(index) = 0; % set the points around the biggest negative peak to Zero, so that the actual bleaching is a one step event in the derivative form
            end
        end
    end
    peaksIndex = peaksIndex(find(peaksIndex~=0));
    %2.B Look at big increments in the donor near an acceptor decrement.
    if ~isempty(peaksIndex);
        dummy = donorM;
        dummy(1:ceil(smoothwidth/2)) = 0;
        dummy(end-2:end)=0;
        dummy = -1*singleDecrement(-1*dummy); %Treat 2 continues positive values as one, equivalent to the sum of both
        %Find biggest positive peaks
        i = 1;
        while i <= numel(peaksIndex) && gutPlot == 0
            index = peaksIndex(i)-2;
            [trash j] = max(dummy(index:index+4)); % look around 4 Frames from the bleaching of acceptor
            j = j-1; % go back one frame
            if dummy(index+j) > minTol*max(dummy) && dummy(index+j) > dummy(index+j+1) && dummy(index+j) > dummy(index+j-1)
                FRETevent = index + j; % double check the position, gives position of the supposed FRET event
                %STEP 3. Checks if acceptor does really bleach.
                if sum(acceptor(index+3:end)>=maxZeroAcceptor) <= peaksTolerance % check if acceptor is bleached, if so it will be below maxZeroAcceptor, if not it can still be below PeaksTolerance
                    gutPlot = 1;
                    whyBad = '';
                else
                    break  % it does not make sense to look for further peaks if the first one does not really bleach
                end
            end
            i = i+1;
        end
    end
end
%%%Check the ALEX red trace for decrement but only if one selects ALEX
bigRedDiff = 0;
if ~isempty(red) && min(donor) >= maxNegative && min(acceptor) >= maxNegative
    red = red/max(abs(red));
    redM = diff(red);
    redM = redM/max(abs(redM));
    if min(red) < maxNegative % just in case there was acceptor, while green excitation, but not while red, so only high crosstalk, then it is not good
        gutPlot = 0;
    else
        if gutPlot == 0; % if there was too low FRET, now the red channel should be checked in the way the acceptor should have been found
            dummy = redM;
            dummy(1:ceil(smoothwidth/2)) = 0;
            dummy(end-2:end)=0;
            dummy = singleDecrement(dummy);%Treat a continuous decrement as a single one
            %Find biggest negative peaks.
            peaksIndex = zeros(1,peaks2check);
            flag = 0;
            for i = 1:peaks2check %check the red trace, the same way like the acceptor
                while peaksIndex(i) == 0 && ~flag
                    [trash index] = min(dummy);
                    bigRedDiff = 1;
                    if dummy(index) < dummy(index+1) && dummy(index) < dummy(index-1)
                        peaksIndex(i) = index;
                        if dummy(index-1) < dummy(index+1)
                            dummy(index) = dummy(index-1);
                        else
                            dummy(index) = dummy(index+1);
                        end
                        if red(index) < maxZeroRed
                            flag = 1;
                        end
                    else
                        dummy(index) = 0;
                    end
                end
            end
            peaksIndex = peaksIndex(find(peaksIndex~=0));
            if numel(peaksIndex) > 1 && abs(peaksIndex(:,1)-peaksIndex(:,2)) >= ceil(smoothwidth/2)
                redIndex_1 = peaksIndex(:,1);
                redIndex_2 = peaksIndex(:,2);
                redStates = 2; %probably 2 states
            elseif numel(peaksIndex) == 1 || abs(peaksIndex(:,1)-peaksIndex(:,2)) <= ceil(smoothwidth/2) 
                redIndex_1 = peaksIndex(:,1);
                redStates = 1; % either you can't detect a second state or there is really only one
            end                         
        else % if the plot was good already, then the red trace should be checked similarly to the donor
            dummy = redM;
            dummy = singleDecrement(dummy);
            redPlot = 0;
            %Find biggest negative peaks
            FirstRedEvent = 0;
            while redPlot == 0            
                if FRETevent <= 3
                    FRETevent = 4;
                end
                index = FRETevent-3;
                [trash j] = min(dummy(index:index+6)); % look around 4 Frames from the bleaching of acceptor
                bigRedDiff = 1;
                j = j-1; % go back one frame
                if dummy(index+j) < minTol*min(dummy) && dummy(index+j) < dummy(index+j+1) && dummy(index+j) < dummy(index+j-1)
                    RedEvent = index + j; % triple check the position, gives position of the supposed FRET event when the red
                    %STEP 3. Checks if red does really bleach.
                    if sum(red(index+5:end)>=maxZeroRed) <= peaksTolerance % check if acceptor is bleached, if so it will be below maxZeroAcceptor, if not it can still be below PeaksTolerance
                        redPlot = 1;
                        redStates = 1;
                        whyBad = '';
                    else
                        gutPlot = 0;
                        bigRedDiff = 0;
                        redStates = 2;
                        break
                    end
                elseif numel(peaksIndex) > 1 && FRETevent ~= peaksIndex(:,1) && FRETevent > 3 && FirstRedEvent ~= 1
                    FRETevent = peaksIndex(:,1);
                    FirstRedEvent = 1;
                else
                    RedEvent = FRETevent;
                    redStates = 1;
                    break
                end
            end
        end
        if bigRedDiff == 1 % Either a peak in the search for bad molecules was found, either the red trace is also good
            % Compare Red bleaching point against the acceptor bleaching point
            % if they are separated by more than 2 Frames something is wrong,
            % because they should bleach in subsequent frames
            if ~gutPlot % this means the program could not find the bleaching step by normal means
                % either FRET is too low or they are only colocalizing
                % there will have to be an additional step to
                % distinguish "only acceptor in the RED" traces from those that have a donor
                FRETevent = redIndex_1;
                RedEvent = FRETevent;
                gutPlot = 2; % it is not good(1) and not bad(0), but questionable(2)
            elseif gutPlot == 1 && abs(RedEvent-FRETevent) > 2 % if RED and ACCEPTOR don't bleach at the same time
                gutPlot = 0;               
            end
        end
    end
end
%correction because the derivative might still not increase instantly but
%in a slope, so the real FRET event has to be set where the curve moves
%upwards and not where the actual peak is
if gutPlot ~=0
    correction = 1;
    while FRETevent+correction<donorBleach && donorM(FRETevent+correction)>0.1 % after the bleaching it checks if the next value is zero or the trace is still in a slope
        correction=correction+1;
    end
    FRETevent2 = FRETevent+correction+1;

    correction = 1;
    while FRETevent-correction>startPoint && donorM(FRETevent-correction)>0.1 % before Bleaching checkup if frame before the max is in a slope
        correction=correction+1;
    end
    FRETevent1 = FRETevent-correction+1;

    %STEP 4. Look for the donor bleaching point
    %4.1 There must be at least one point that reach zero otherwise the
    %bleach point is the last point in the trace
    donorBleach = 1;
    for i=FRETevent2:numel(donor)
        if(donor(i)<=maxZeroDonor)
            donorBleach = 0;
        end
    end

    %4.2 The biggest decrement in the donor signal after the FRET point is
    %considered the bleaching point
    if donorBleach == 0
        dummy = donorM;
        dummy(1:FRETevent2) = 0;
        dummy(end-2:end)=0;
        dummy = singleDecrement(dummy);
        noise = 0;
        while donorBleach == 0 && ~noise
            [trash index] = min(dummy);
            if index > FRETevent2
                if dummy(index) < dummy(index+1) && dummy(index) < dummy(index-1)
                    donorBleach =index;
                else
                    dummy(index) = 0;
                end
            else
                noise = 1;%the donor shows strong noise inside the FRET region
            end
        end
    end
    % correction of the derivative slope
    if donorBleach == 0 || donorBleach == 1%donorBleach is 0, when the noise is too big or 1, when it does not bleach at all
        donorBleach = numel(donor); %donor bleaching is set to the end
    else
        correction = 1;
        while donorBleach-correction>FRETevent2 && donorM(donorBleach-correction)<-0.1 % again the point of decrease has to be pinpointed in case of a slope
            correction=correction+1;
        end
        donorBleach = donorBleach-correction;
    end
    %the trace might be questionable
    if gutPlot == 1
        realRed = acceptor;
        maxZeroReal = maxZeroAcceptor;
    else
        realRed = red;
        maxZeroReal = maxZeroRed;
    end

    %STEP 5. Look for the best starting point
    i = FRETevent1-1;
    firstBlink = 0;
    while i>1 && startPoint == 0 % loop in backwards direction
        if(realRed(i)<maxZeroReal) % is the Acceptor blinking, so below the set Zero one Frame before the FRET event?
            if(realRed(i-1)<maxZeroReal || firstBlink == 1) % is the Acceptor off, even two Frames before ?
                dummy = max(realRed(i:(FRETevent-1)));
                while i<FRETevent1 && realRed(i) < 0.2*dummy %%%only when the trace value is below 0.2 of the maximum around the FRETevent, then it is a Zero
                    i = i+1;
                end
                startPoint = i;
            else
                firstBlink = 1;
            end
        end
        i=i-1;%loop until the first point in trace
    end
    if startPoint == 0
        startPoint = 1;%%% when the beginning is reached then the startpoint is set 1
    elseif FRETevent1-startPoint < ceil(smoothwidth/2)
        gutPlot = 0;
    end
    % define the regions of the trace now
    FRET_region = startPoint:FRETevent1;
    donor_only_region = FRETevent2:donorBleach;
    average_donor = mean(donor(donor_only_region));
    std_donor = std(donor(donor_only_region));

    %count how long the most stable part of the donor_only lasts
    correction=0;
    while donorBleach-correction>FRETevent2 && ...
            donor(donorBleach-correction) < average_donor-1.5*std_donor ...
            || donor(donorBleach-correction)>average_donor+1.5*std_donor
        correction=correction+1;
    end
    if correction < numel(donor_only_region)*.25 % if the bad region of the donor is less than 25% of the whole donor only region, then one can take the trace
        donorBleach = donorBleach-correction;
        donor_only_region = FRETevent2:donorBleach;
        average_donor = mean(donor(donor_only_region));
        std_donor = std(donor(donor_only_region));
    else
        gutPlot = 0;
    end
    if average_donor <= maxZeroDonor %if the average of the donor is below Zero, then the trace is bad
        gutPlot = 0;
    elseif donorBleach-FRETevent2 < ceil(smoothwidth/2) % if the the donor_only region is too short, one cannot take it
        gutPlot = 0;
    elseif std_donor > maxSTDdonor %pre-defined standard deviation should not be too high
        gutPlot = 0;
    elseif mean(donor(FRET_region)) > (mean(donor(donor_only_region)) - std(donor(end-ceil(0.1*numel(donor)):end))) % if the donor goes down instead of up after the acceptor bleaching
        gutPlot = 0;
    elseif min(acceptor(FRET_region)) >= maxZeroAcceptor && ...
        mean(acceptor(FRET_region)) < mean(acceptor(donor_only_region)) - std(acceptor(end-ceil(0.1*numel(acceptor)):end)) % if the acceptor goes up instead of down after bleaching
        gutPlot = 0;        
    elseif bigRedDiff == 1 % if there was a bleaching event in the red
        % the red trace has to be checked for two levels
        RedEvent_2 = RedEvent + 2 + ceil(smoothwidth/2); % the second level should be at least as long as the smoothwidth, otherwise it will be anyway hard to work with it
        RedEvent_3 = RedEvent - 2 - ceil(smoothwidth/2);
        if RedEvent_3 < 1
           RedEvent_3 = 1;
        elseif RedEvent_2 > numel(red) % should the first level be so long, that the supposed second one exceed the length of the trace, then it means the Red Trace does not bleach
           gutPlot = 0;
        elseif redStates == 2 && mean(red(redIndex_1+2:redIndex_2)) >= 0.66*mean(red(startPoint:redIndex_1)) % if there could be 2 states then one should not be higher than the other, 5% is the detectiion limit
            gutPlot = 0;            
        elseif redStates == 2 && mean(red(redIndex_1+2:redIndex_2)) <= 0.66*mean(red(startPoint:redIndex_1)) && 0.66*mean(red(redIndex_1+2:redIndex_2)) >= mean(red(end-ceil(0.1*numel(red)):end))+2*std(red(end-ceil(0.1*numel(red)):end)) % if the first level was lower it should still be not higher than the background, otherwise it was one long level
            gutPlot = 0;
        elseif std(red(startPoint:RedEvent)) > maxSTDred %pre-defined standard deviation of the red signal should not be exceeded
            gutPlot = 0;            
        elseif 0.66*mean(red(RedEvent_3:RedEvent)) >= mean(red(RedEvent+2:RedEvent_2)) && 0.66*mean(red(RedEvent+2:RedEvent_2)) >= mean(red(end-ceil(0.1*numel(red)):end))+3*std(red(end-ceil(0.1*numel(red)):end))% if so far only one level could be detected then this level should not be higher than anything later on, except the background
            gutPlot = 0;
        elseif 0.66*mean(red(startPoint:RedEvent_3)) >= mean(red(RedEvent_3+2:RedEvent)) && 0.66*mean(red(RedEvent_3+2:RedEvent)) >= mean(red(end-ceil(0.1*numel(red)):end))+3*std(red(end-ceil(0.1*numel(red)):end))
            gutPlot = 0;
        elseif 0.66*mean(red(FRET_region)) <= mean(red(donor_only_region)) || 0.66*mean(red(FRET_region)) <= mean(red(end-ceil(0.1*numel(red)):end))+3*std(red(end-ceil(0.1*numel(red)):end)) % if the red trace was in the mean of the FRET region lower than in the donor only region or around the background then there was no acceptor after all
            gutPlot = 0;            
        end
    end
    if gutPlot ~= 0
        totalOut20 = sum(donor(donor_only_region)<average_donor-maxDonorPeak)...% only a certain amount of peaks should be present in the donor only part
            + sum(donor(donor_only_region)>average_donor+maxDonorPeak);
        if totalOut20 > round(numel(donor_only_region)*DonorOutPeak)
            gutPlot = 0;
        else
            totalOut15 = sum(donor(donor_only_region)<average_donor-maxDonorOut)...% only a certain amount out of the mean is allowed
                + sum(donor(donor_only_region)>average_donor+maxDonorOut);
            if totalOut15 > round(numel(donor_only_region)*DonorOutStep)
                gutPlot = 0;
            else
                delta_don = (mean(donor(donor_only_region))- mean(donor(FRET_region)));
                delta_acc = (mean(acceptor(FRET_region))) - (mean(acceptor(donor_only_region))) ;
                gamma = delta_acc./delta_don;
                total_int = donor(FRET_region)*gamma + acceptor(FRET_region);
                stdTotalInt = std(total_int);
                if stdTotalInt > maxSTDFRET %predefined maximum deviation in the total intensity
                    gutPlot = 0;
                end
            end
        end
    end
    if gutPlot == 2
        gutPlot = 1;%one can assume that a trace that fulfilled all the conditions before is now not questionable anymore
    end
end
FRETIndex = [startPoint, FRETevent1,FRETevent2, donorBleach];