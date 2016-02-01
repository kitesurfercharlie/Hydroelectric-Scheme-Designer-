function [rowValue] = findnearest(value,matrix)


%Find the difference between the matrix and the value

differenceMatrix = matrix-value;

%Find the minimum value in this matrix

minimumValue=min(abs(differenceMatrix(:)));

%Find the row and column in which this is found


[rowValue]= find(abs(differenceMatrix)==minimumValue);

rowValue=rowValue(1,1);

end


    
