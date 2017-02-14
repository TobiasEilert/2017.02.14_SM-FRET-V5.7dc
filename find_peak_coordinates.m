% find_peak_coordinates.m
% 
% The function gets two coordinates and an image an draws a small area centered
% the position defined by the coordinates. The user is then allowed to  move the
% center in order to match a peak position. The coordinates of the new position
% are returned.
% 
% Jens Michaelis 08-06
function [new_x, new_y] = find_peak_coordinates(old_x, old_y, data)
figure(9); clf;
new_x = old_x;
new_y = old_y;

choicewin = 0;
while choicewin ~= 1
    zoom = data(new_y-8:new_y+8, new_x-8:new_x+8);
    imagesc(zoom, [0 128]);
    line('XData', [1,17], 'YData', [9, 9], 'Color', 'r', 'LineWidth', 2);
    line('Xdata', [9,9], 'YData', [1,17], 'Color', 'r', 'LineWidth', 2);
    choicewin = menu(['Move the position, current value is: ', num2str(data(new_y, new_x))],'Keep', 'Left','Right','Up','Down');
    switch choicewin
        case 2
            new_x = new_x -1;
        case 3
            new_x = new_x +1;
        case 4
            new_y = new_y -1;
        case 5
            new_y = new_y +1;
    end
end

