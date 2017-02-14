function dummy = singleDecrement(dummy)
i=1;
while i < numel(dummy)-2
    if dummy(i) < 0 && dummy(i+1) < 0
        j = 1;
        while (i+j)<numel(dummy) && dummy(i+j) < 0 && dummy(i+j+1) < 0
            j = j+1;
        end
        weight = 0;
        for k=i:i+j
            weight = dummy(k)*k + weight;
        end
        total = sum(dummy(i:i+j));
        index = round(weight/total);
        dummy(i:i+j) = total/(j+1);
        dummy(index) = total;
        i = i+j+1;
    else
        i = i+1;
    end
end