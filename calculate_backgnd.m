function back = calculate_backgnd(data,x,y)
upper_left = 0; upper_right = 0; lower_left = 0; lower_right = 0; counts = 0;
circle_b = make_circle_b;                   % get circle for backgnd
Bgd_para = 1;                   % sensitivity parameter for sensing molecules in the neighbourhood that would distract the background circle

for k = -5:5
    for l = -5:5
        if circle_b(k+6,l+6) > 0
            if k <= 0
                if l<=0  
                    upper_left = upper_left+ data(x+k, y+l);
                    counts = counts+1;       % count how many points are added                           
                end
                if l>=0
                    upper_right =upper_right+data(x+k, y+l);
                    
                end
            end
            if k >= 0
                if l<=0 
                    lower_left = lower_left+ data(x+k, y+l);
                   
                end
                if l>=0
                    lower_right =lower_right+data(x+k, y+l);
                    
                end
            end
        end
    end
end

corners = [upper_left, upper_right, lower_left, lower_right];

if (max(corners) - min(corners)) > (Bgd_para* min(corners))      % there seems to be a peak -> remove one corner
    %one_corner = [max(corners), min(corners)];
    corners = sort(corners);
    corners = corners(1:3);                            % remove the corner with highest intensity    
    if (max(corners) - min(corners)) > (Bgd_para* min(corners))   % still peak --> remove second corner
        %two_corners = [max(corners), min(corners)]
        corners = corners(1:2);   
        if (max(corners) - min(corners)) > (Bgd_para* min(corners))   % still peak --> remove second corner
        %three_corners = [max(corners), min(corners)]
        corners = corners(1);        
        end
    end    
end

back = mean(corners)./ counts;


