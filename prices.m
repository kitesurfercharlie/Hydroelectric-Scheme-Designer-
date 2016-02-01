function [turbineCost] = prices(turbineTypeNo,actDiameter)

turbineCost=0;
%Francis

if ((turbineTypeNo==1) || (turbineTypeNo==2) || (turbineTypeNo==3))
    priceFactor=1;

if turbineTypeNo==1
    priceFactor=1.12;
end
if turbineTypeNo==3
    priceFactor=0.88;
end

    meanDiameter=0:0.05:1.25;
    turbineCost=[61,65,69,74,78,81,86,90,95,100,105,112,120,127,134,142,152,163,175,185,200,218,235,255,275,1e10]*1e3*priceFactor;

Dindex=findnearest(actDiameter,meanDiameter);

turbineCost=turbineCost(Dindex);
end

%Kaplan
if (turbineTypeNo==4)
    priceFactor=1;

    meanDiameter=0:0.05:1.25;
    turbineCost=[61,65,69,74,78,81,86,90,95,100,105,112,120,127,134,142,152,163,175,185,200,218,235,255,275,1e10]*1e3*priceFactor;

Dindex=findnearest(actDiameter,meanDiameter);

turbineCost=turbineCost(Dindex);
end


%Pelton
if turbineTypeNo==5
    
    meanDiameter=0:0.05:1.55;
    turbineCost=[80,82,84,85,86,88,90,92,94,96,98,100,103,108,110,115,122,130,140,150,165,180,195,210,230,250,270,295,320,350,380,1e10]*1e3;
    
    
Dindex=findnearest(actDiameter,meanDiameter);

turbineCost=turbineCost(Dindex);
end

%Turgo
if turbineTypeNo==6
    %*0.0254
    meanDiameter=(0:2:44) ;
    turbineCost=[35,36,38,41,43,45,48,53,58,65,75,85,96,110,124,140,158,176,195,218,245,280,1e10]*1e3;
    
    
Dindex=findnearest(actDiameter,meanDiameter);

turbineCost=turbineCost(Dindex);
end


end

