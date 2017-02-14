function Circle=circle(r,l)
%% Generates circular Mask with radius r and box size l

Circle=ones(l);
l=(l-1)/2;
for i = -l:l
    for j= -l:l
        if round(sqrt((i*i)+(j*j)))>r
        Circle(i+l+1,j+l+1)=0;        
        end
    end
end
Circle=uint16(Circle);
