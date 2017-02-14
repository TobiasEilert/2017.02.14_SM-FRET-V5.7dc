function regions = getPoints(time, userData, axisLoc)
        axes(axisLoc);
        switch userData.cameraside
            case 1
                ylabel('Intensity');
                xlabel('Time (s)');
                title('Click mouse to indicate beginning');
                [start,junk]=ginput(1);
                start_row = min(find(time(:,1) > start));
                title('Click mouse to indicate donor bleaching or end');
                [don_bleach,junk]=ginput(1);
                don_bleach_row = max(find(time(:,1) < don_bleach));
                if don_bleach_row <= start_row
                    title('ERROR: You cannot define the donor bleaching here, Try again!');
                    while true
                        title('Click mouse to indicate donor bleaching or end');
                        [don_bleach,junk]=ginput(1);
                        don_bleach_row = max(find(time(:,1) < don_bleach));
                        if don_bleach_row > start_row
                            break
                        end
                    end
                end
            case 2
                ylabel('Intensity');
                xlabel('Time (s)');
                title('Click mouse to indicate beginning');
                [start,junk]=ginput(1);
                start_row = min(find(time(:,1) > start));
                title('Click mouse to indicate acceptor bleaching or end');
                [acc_bleach,junk]=ginput(1);
                acc_bleach_row = max(find(time(:,1) < acc_bleach));
                if acc_bleach_row <= start_row
                    title('ERROR: You cannot define the acceptor bleaching here, Try again!');
                    while true
                        title('Click mouse to indicate acceptor bleaching or end');
                        [acc_bleach,junk]=ginput(1);
                        acc_bleach_row = max(find(time(:,1) < acc_bleach));
                        if acc_bleach_row > start_row
                            break
                        end
                    end
                end
            case 3
                ylabel('Intensity');
                xlabel('Time (s)');
                title('Click mouse to indicate beginning');
                [start,junk]=ginput(1);
                start_row = min(find(time(:,1) > start));
                title('Click mouse to indicate acceptor bleaching');
                [acc_bleach,junk]=ginput(1);
                acc_bleach_row = min(find(time(:,1) > acc_bleach));
                if userData.alex == 1
                    acc_bleach_row = acc_bleach_row - 1; %this way one can click a little bit too late after bleaching
                    if acc_bleach_row <= (start_row + ceil(userData.smoothwidth/2+3))
                        while true
                            title('ERROR: You cannot define the acceptor bleaching here, Try again!');
                            [acc_bleach,junk]=ginput(1);
                            acc_bleach_row = min(find(time(:,1) > acc_bleach));
                            acc_bleach_row = acc_bleach_row - 1; %this way one can click a little bit too late after bleaching
                            if acc_bleach_row > (start_row + ceil(userData.smoothwidth/2)+3)
                                break
                            end
                        end
                    end
                else
                    acc_bleach_row = acc_bleach_row - 2; %this way one can click a little bit too late after bleaching
                    if acc_bleach_row <= (start_row + ceil(userData.smoothwidth/2+5))
                        while true
                            title('ERROR: You cannot define the acceptor bleaching here, Try again!');
                            [acc_bleach,junk]=ginput(1);
                            acc_bleach_row = min(find(time(:,1) > acc_bleach));
                            acc_bleach_row = acc_bleach_row - 2; %this way one can click a little bit too late after bleaching
                            if acc_bleach_row > (start_row + ceil(userData.smoothwidth/2)+5)
                                break
                            end
                        end
                    end
                end                
                title('Click mouse to indicate donor bleaching or end');
                [don_bleach,junk]=ginput(1);
                don_bleach_row = max(find(time(:,1) < don_bleach));
                if (don_bleach_row <= start_row) || (don_bleach_row <= acc_bleach_row)
                    while true
                        title('ERROR: You cannot define the donor bleaching here, Try again!');
                        [don_bleach,junk]=ginput(1);
                        don_bleach_row = max(find(time(:,1) < don_bleach));
                        if (don_bleach_row > start_row) && (don_bleach_row > acc_bleach_row)
                            break
                        end
                    end
                end
        end
        regions={};
        %%%% Defining the different regions (before/after bleaching etc.)%
        switch userData.cameraside
            case 1
                regions{1} = 1:start_row-1; %pre_donor_region
                regions{2} = start_row:don_bleach_row; %donor_region
                regions{3} = don_bleach_row+1:length(time); %post_donor_region
            case 2
                regions{1} = 1:start_row-1; %pre_acceptor_region
                regions{2} = start_row:acc_bleach_row; %acceptor_region
                regions{3} = acc_bleach_row+1:length(time); %post_acceptor_region
            case 3
                regions{1} = 1:start_row-1; %pre_FRET_region
                if userData.alex == 1
                    regions{2} = start_row:acc_bleach_row-2;  %FRET_region (3 frames substracted)
                    regions{3} = acc_bleach_row-1:acc_bleach_row+1; %post_FRET_region
                    regions{4} = acc_bleach_row+2:don_bleach_row; %donor_only_region
                else
                    regions{2} = start_row:acc_bleach_row-3;  %FRET_region (5 frames substracted)
                    regions{3} = acc_bleach_row-2:acc_bleach_row+2; %post_FRET_region
                    regions{4} = acc_bleach_row+3:don_bleach_row; %donor_only_region
                end
                regions{5} = don_bleach_row+1:length(time); %post_donor_only_region
        end
        