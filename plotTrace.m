function [FRET FRETIndex] = plotTrace(mData, time, autoanalysis, axisLoc, ...
    userData, parameters, E)

FRET = 0;
FRETIndex = 0;

cla reset;
axes(axisLoc);
hold on;

if numel(mData.donor) > 1
    plot(time,mData.donor,'g');
end
if numel(mData.acceptor) > 1
    plot(time,mData.acceptor,'r');
end
if numel(mData.red) > 1
    plot(time,mData.red,'m');
end

%parameters = struct('maxSTDdonor', .15, 'maxSTDFRET', .25, 'maxDonorPeak',
%.25, 'DonorOutPeak', .08, 'maxDonorOut', .15, 'DonorOutStep', .25, 
%'maxNegative', -.15, smoothwith, '10');

if get(autoanalysis,'Value') && ~isempty(mData.acceptor) && ~isempty(mData.donor)
    donor = medfilt1(mData.donor,5);
    acceptor = medfilt1(mData.acceptor,5);
    
    plot(time,donor,':b');
    plot(time,acceptor,':k');
    %[FRET FRETIndex peaks] = findGutPlot3(donor,acceptor,smoothwidth);
    red = medfilt1(mData.red,5);
    [FRET FRETIndex whyBad] = findGutPlot4(donor,acceptor,red,userData.smoothwidth);
    axes(axisLoc);
    topLimit = max([donor;acceptor]);
    bottomLimit = min([donor;acceptor]);
    
    if sum(FRETIndex>0) > 0
        donor_only_region = FRETIndex(3):FRETIndex(4);      
        FRET_region =FRETIndex(1):FRETIndex(2);
                

        plot([FRETIndex(1) FRETIndex(1)],[bottomLimit, topLimit], '-.b');
        plot([FRETIndex(2) FRETIndex(3)],[bottomLimit, topLimit], '--k');
        plot([FRETIndex(4) FRETIndex(4)],[bottomLimit, topLimit], '-.b');
       
        average_donor = mean(donor(donor_only_region));
        std_donor = std(donor(donor_only_region));
        plot(donor_only_region, average_donor.*ones(1,numel(donor_only_region)));
        plot(donor_only_region, average_donor-1*std_donor.*ones(1,numel(donor_only_region)),'--');
        plot(donor_only_region,average_donor+1*std_donor.*ones(1,numel(donor_only_region)), '--');
        
        plot(donor_only_region,average_donor+parameters.maxDonorOut*max(abs(donor))...
            .*ones(1,numel(donor_only_region)), '--', 'color', [0 .5 0]);
        
        
        plot(mean(donor_only_region)*ones(1,2), ...
            [average_donor*(1+ parameters.maxSTDdonor)  ...
            average_donor*(1-parameters.maxSTDdonor)],'k:d')

        beta = mean(acceptor(donor_only_region))/mean(donor(donor_only_region));
        delta_don = (mean(donor(donor_only_region))- mean(donor(FRET_region)));
        delta_acc = (mean(acceptor(FRET_region))) - (mean(acceptor(donor_only_region))); 
        gamma = delta_acc./delta_don;
        
        if E == -1
            E = mean((acceptor(FRET_region) - (beta.*donor(FRET_region)))./ ...
                (acceptor(FRET_region) + (gamma.*donor(FRET_region))));
        end
        total_int = donor*gamma + acceptor;
        %stdTotalInt = std(total_int);
        plot(total_int,'k');
        
        dummy = mean(total_int(FRET_region));
        plot(mean(FRET_region)*ones(1,2), [dummy*(1+ parameters.maxSTDdonor)  ...
            dummy*(1-parameters.maxSTDdonor)],'k:d')
        
    else
        FRETIndex = 0;
    end
    xLimit = get(axisLoc,'Xlim');
    xLimit = (xLimit(2)-xLimit(1))*.85 + xLimit(1);
    yLimit = get(axisLoc,'Ylim');
    yLimit = (yLimit(2)-yLimit(1))*.96 +yLimit(1);
    if FRET
        text(xLimit,yLimit,'GUT :)');
        text(xLimit,yLimit*.95,strcat('FRET mean value = ', num2str(E)));
        text(xLimit,yLimit*.9,whyBad);
    else
        text(xLimit,yLimit,'FALSCH');
        text(xLimit,yLimit*.9,whyBad);
    end
end