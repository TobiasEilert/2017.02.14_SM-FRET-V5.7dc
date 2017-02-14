function [traces2see minE, maxE] = selectFRETtraces(selectedTraces,finalData,minFRET,maxFRET)
traces2see = zeros(size(selectedTraces));
maxE = -20;
minE = 20;
for i=1:numel(selectedTraces)
    if selectedTraces(i)
        molecule = finalData{i};
        result = molecule{1};
        if result.E >= minFRET && result.E <= maxFRET
            traces2see(i) = 1;
        end
        if result.E > maxE
            maxE = result.E;
        end
        if result.E < minE
            minE = result.E;
        end
    end
end
minE = floor(minE*1000)/1000;
maxE = floor(maxE*1000)/1000;