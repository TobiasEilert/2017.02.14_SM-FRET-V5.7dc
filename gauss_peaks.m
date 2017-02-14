function g_peaks = gauss_peaks
% gauss_peaks.m
% 
% The program makes a four dimensional array with a 2d gaussian that is shifted
% along both directions. The argument is for future use to allow adjustments
% for different binnings of data. The array is returned.
%     
% Jens Michaelis 08-06
for k = 1:3
    for l = 1:3
        offx = -1 + (k*0.5);                       % k=2 -> no offset
        offy = -1 + (l*0.5);                       % l=2 -> no offset
        for i = 0:6
            for j = 0:6
                dist = 0.4 .* ((i-3.0+offx).^2 + (j-3.0+offy).^2);
                g_peaks(k,l,i+1,j+1) = 2.0*exp(-dist);
            end
        end
    end
end