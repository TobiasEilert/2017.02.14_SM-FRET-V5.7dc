%%%Plot the data analysed
function plotAnalysis(trace,regions,time,userData,axLoc)
cla reset
axes(axLoc);
hold on;
switch userData.cameraside
    case 1
        plot(time,trace.donor_average,'g');
        ylabel('Intensity');
        xlabel('Time (s)');
    case 2
        plot(time,trace.acceptor_average,'r');
        if alex == 1
            plot(time,trace.red_average,'m');
        end
        ylabel('Intensity');
        xlabel('Time (s)');
    case 3
        true_FRET_region = regions{2}(ceil(userData.smoothwidth/2): ...
            end-ceil(userData.smoothwidth/2)+1);
        [AX,H1,H2] = plotyy(time,trace.donor_average, ...
            time(true_FRET_region), trace.FRET(true_FRET_region));
        set(H1,'Color','g');
        set(H2,'Color','b');
        plot(AX(1),time,trace.acceptor_average,'r');
        if userData.alex == 1
            plot(AX(1),time,trace.red_average,'m');
        end
        plot(AX(1),time,trace.total_int,'k');

        set(AX(1),'YColor','k');
        set(AX(2),'YColor','b');
        set(get(AX(1),'Ylabel'),'String','Intensity');
        set(get(AX(2),'Ylabel'),'String','FRET Efficiency');
        if userData.alex == 1
            limBottom = min([trace.donor_average;trace.acceptor_average;trace.total_int]);
            limTop = max([trace.donor_average;trace.red_average;trace.total_int]);
            ylim(AX(1),[limBottom limTop]);
        else
            limBottom = min([trace.donor_average;trace.acceptor_average;trace.total_int]);
            limTop = max([trace.donor_average;trace.total_int;trace.total_int]);
            ylim(AX(1),[limBottom limTop]);
        end
        ylim(AX(2),[-0.25 1.5]);
        set(AX(2),'YTick',-0.25:0.25:1.5);
end