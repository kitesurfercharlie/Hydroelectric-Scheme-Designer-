% Charlie Seviour 26/10/09   T (fraction of flow multipler)
% inputs    runoffMatrix--Map of hydrological scenario number
%           it--matrix of 8 hydrological scenario flow durations
% outputs   runoffMatrix1 3d matrix of flow durations for each coordinate
% on the map
% 
% This scipt formats the inputed flow data into a 3d matrix suitable for a
% turbine selection script.
clear runoffMatrix1
i=0;
j=0;
runoffMatrix1=0;
for i=1:size(runoffMatrix,1)
    for j=1:size(runoffMatrix,2)
         if runoffMatrix(i,j)==0
           runoffMatrix1(i,j,1:size(it,1))=0;
           else
           for zVar=1:1:size(it,1);
               it(zVar,runoffMatrix(i,j));
           runoffMatrix1(i,j,zVar)=it(zVar,runoffMatrix(i,j));
           end
         end
    end
end

