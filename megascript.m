%Recieve the flow duration data
%Recieve the height map

%check which optimisation factor to use
    global optimiseFactor

if exist('optimiseFactor')==0
        optimiseFactor=-15;
end

global heightValues;
global powerHouseData;

heightValues=E;
FD=A90;

%powerhouse location info in 3D
powerHouseData=[54*50,86*50,heightValues(86,54);86*50,90*50,heightValues(90,86);];


mapValues=0;
head=0;
FD1D=0;

%x,y of map values
       for mapCoordHeight=1:1:size(FD,1)
           for mapCoordLength=1:1:size(FD,2)
            mapCoordLengthx=2*mapCoordLength-1;
mapValues(mapCoordHeight,mapCoordLengthx)=(mapCoordLength-1);
mapValues(mapCoordHeight,mapCoordLengthx+1)=(mapCoordHeight-1);
           end
       end
       mapValues=mapValues*50;

%initials
pipeLength=0;

%Use height values to get sizes - same dimensions as the map data
[heightValueSizeX,heightValueSizeY]=size (heightValues);

%for each of the stored data intake positions find the distance to the
%various powerhouses

for indexPowerHouse=1:size(powerHouseData,1)
    for indexMapCellX=1:heightValueSizeX
        for indexMapCellY=1:heightValueSizeY
            
            indexMapCellYx=2*indexMapCellY-1;
            
d=[mapValues(indexMapCellX,indexMapCellYx),mapValues(indexMapCellX,indexMapCellYx+1),heightValues(indexMapCellX,indexMapCellY)];

dxyz=[d-powerHouseData(indexPowerHouse,:)];

pipeLength(indexMapCellX,indexMapCellY,indexPowerHouse)=sqrt(dxyz(1).^2+dxyz(2).^2+dxyz(3).^2);

head(indexMapCellX,indexMapCellY,indexPowerHouse)=heightValues(indexMapCellX,indexMapCellY)-powerHouseData(indexPowerHouse,3);
        end
    end
end

%End of PIPELENGTHS

%For each position on the map find the turbine for which it produces the
%most profit after 15 years

indexMapCellX=0;
indexMapCellY=0;
countNo=1;
global turbineSelectionCoarseData;
turbineSelectionData=0;

for indexPowerHouse=1:size(powerHouseData,1)
    for indexMapCellX=1:heightValueSizeX
        for indexMapCellY=1:heightValueSizeY

            %convert 3d flow to 1d w.r.t to map position
            FD1D(1:1:(size(FD,3)))=FD(indexMapCellX,indexMapCellY,:);

            %Automatically sift through average sites

if mean(FD1D)>0.1 && head(indexMapCellX,indexMapCellY,indexPowerHouse)>10
    
            turbineSelectionData(countNo,1:19)=turbineselection(FD1D,head(indexMapCellX,indexMapCellY,indexPowerHouse),pipeLength(indexMapCellX,indexMapCellY,indexPowerHouse));

            turbineSelectionData(countNo,20)=head(indexMapCellX,indexMapCellY,indexPowerHouse);                 
            turbineSelectionData(countNo,21)=pipeLength(indexMapCellX,indexMapCellY,indexPowerHouse);
     
            turbineSelectionData(countNo,22)=indexMapCellX;
            turbineSelectionData(countNo,23)=indexMapCellY;
            turbineSelectionData(countNo,24)=indexPowerHouse;

end
            coarsepassprogress=(countNo/(174*234*2))*100
            countNo=countNo+1;
        end
    end
end

turbineSelectionCoarseData=sortrows(turbineSelectionData,optimiseFactor);


%Begin fine pass, selecting the top 100 sites and completing turbine
%selection based upon weekly flow information.


FD=A90Weekly;
global turbineSelectionFineData;

fineDataLength=100;
fineSelection=turbineSelectionCoarseData(1:fineDataLength,22:24);
fineSelectionX=fineSelection(:,1);
fineSelectionY=fineSelection(:,2);
fineSelectionPowerHouse=fineSelection(:,3);
indexMapCellX=0;
indexMapCellY=0;
countNo=1;

turbineSelectionData=0;



    for indexMap=1:fineDataLength

        %get map x and y positions
        indexMapCellX=fineSelectionX(indexMap);
        indexMapCellY=fineSelectionY(indexMap);
        indexPowerHouse=fineSelectionPowerHouse(indexMap);
            %convert 3d flow to 1d w.r.t to map position
            FD1D(1:1:(size(FD,3)))=FD(indexMapCellX,indexMapCellY,:);
            
    %Get rid of negatives in FD : a hangover of the Q90 method
            FD1D(49:52)=0;

    
            turbineSelectionData(countNo,1:19)=turbineselection(FD1D,head(indexMapCellX,indexMapCellY,indexPowerHouse),pipeLength(indexMapCellX,indexMapCellY,indexPowerHouse));

            turbineSelectionData(countNo,20)=head(indexMapCellX,indexMapCellY,indexPowerHouse);                 
            turbineSelectionData(countNo,21)=pipeLength(indexMapCellX,indexMapCellY,indexPowerHouse);
     
            turbineSelectionData(countNo,22)=indexMapCellX;
            turbineSelectionData(countNo,23)=indexMapCellY;
            turbineSelectionData(countNo,24)=indexPowerHouse;
            
            
            finepassprogress=(countNo/(fineDataLength))*100
            countNo=countNo+1;
    end



turbineSelectionFineData=sortrows(turbineSelectionData,optimiseFactor);

%Display

graphicalDisplay;
