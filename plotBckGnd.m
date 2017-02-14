%Plot background
function plotBckGnd(mData, time, axLoc, cameraside)
cla reset
axes(axLoc);
hold on

if ~isempty(mData.background_left)
    [AX,H1,H2] = plotyy(time, mData.background_left,time, mData.donor);
    set(H2,'Color','g');
    set(H1, 'Color', [0,.5,0],'LineStyle', '--');
end

if ~isempty(mData.background_right_red) && cameraside == 2
    [AX,H1,H2] =plotyy(time, mData.background_right_red,time, mData.red);
    set(H2,'Color','m','LineStyle', ':');
    set(H1, 'Color', [.5,0,.5],'LineStyle', '--');
end

if ~isempty(mData.background_right)
    [AX,H1,H2] =plotyy(time, mData.background_right, time, mData.acceptor);
    set(H2,'Color','r');
    set(H1, 'Color', [.5,0,0],'LineStyle', '--');
end

set(AX(1),'YColor','k');
set(AX(2),'YColor','k');
set(get(AX(1),'Ylabel'),'String','Intensity Signal');
set(get(AX(2),'Ylabel'),'String','Intensity Background');

limBottom = min([mData.donor;mData.acceptor]);
limTop = max([mData.donor;mData.acceptor]);
set(AX(2),'ylim',[limBottom, limTop]);
set(AX(2),'YTick',floor(limBottom/1000)*1000:1000:ceil(limTop/1000)*1000);

limBottom = min([mData.background_left;mData.background_right]);
limTop = max([mData.background_left;mData.background_right]);
set(AX(1),'ylim',[limBottom, limTop]);
set(AX(1),'YTick',floor(limBottom/1000)*1000:1000:ceil(limTop/1000)*1000);