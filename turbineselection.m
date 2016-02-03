 function [chosenData] = turbineselection(FD,head,pipeLength)

%FD is for a point on the map, sent from mega-script
%head is the pure head between intake and powerhouse
%pipeLength is the length of pipe between the powerhouse and the point,
%sent from mega-script

%check which optimisation factor to use
    global optimiseFactor
if exist('optimiseFactor')==0
        optimiseFactor=-15;
end


FDSize=size(FD,2);

%find the number of hours at which each flow runs
FDhours=(8760/FDSize);


%turbine info
turbineTypesStrings=char('francisHi' , 'francisMid' , 'francisLo' , 'kaplan' , 'turgo' , 'pelton');
turbineTypesNo=[1,2,3,4,5,6];
%model head, model flow, model dia, model speed - given from hillcurve
%sheets
turbineInfo=  [1,0.18,0.414,210;
               1,0.06,0.268,220;
               1,0.015,0.181,220;
               1,1.7,1,160;
               30,0.034,0.191,1470;
               1,0.006,0.3,125];

%initial info

pipeDiameters=[0.1,0.2,0.3,0.4,0.4532,0.587,0.686,0.7854,0.8818,1.0528,1.1746,1.3662,1.5606,1.7562,1.9522];
pipeDiameter=1;
pipeMaterial=0;
turbineTypeNo=0;
turbineCost=0;
pipeCost=0;
generatorCost=0;
totalCost=1e9;
totalInvestment=1e9;
totalReturn=1;
totalProfit=0;
powerGeneration=1;
energyGeneration=0;
capacityFactor=0;
flowRate=1;
actSpeed=1;
actDiameter=1;
indexFlow=0;
deltaH=0;
netHead=0;
maxFlow=0;
maxPower=0;

masterMatrix=[flowRate,pipeDiameter,pipeMaterial,turbineTypeNo,maxFlow,maxPower,energyGeneration,capacityFactor,actSpeed,actDiameter,turbineCost,pipeCost,generatorCost,(1/(totalInvestment/totalReturn)),totalProfit,totalCost,totalReturn,deltaH,netHead];

%Percentage either way of generator operating speed allowed
generatorAllowance=0.01;

%Pre-start:


%i Corresponds to the index of the flow duration data

%First loop - vary the rated flow
for indexFlow = 1:FDSize


 
%With the head and flow data ready, the first flow rating for the turbine is
%chosen

flowRate= FD(indexFlow);

%If flowrate is not 0 proceed
if flowRate == 0


    %Useless flow

%    masterMatrix((size(masterMatrix,1)+1),:)=[flowRate,pipeDiameter,pipeMaterial,turbineTypeNo,powerGeneration,energyGeneration,capacityFactor,actSpeed,actDiameter,turbineCost,pipeCost,generatorCost,(1/(totalInvestment/totalReturn)),totalProfit,totalCost,totalReturn];


elseif flowRate ~= 0

%Next choose the pipe diameter for steel then pvc

for indexPipe=1:(size(pipeDiameters,2))

%    if indexPipe>size(pipeDiameters,2) &&  indexPipe<= 2* size(pipeDiameters,2)
%        pipeMaterial=1;
%        pipeDiaFactor=size(pipeDiameters,2);
%     elseif indexPipe>= 2* size(pipeDiameters,2)
%         pipeMaterial=2;
%         pipeDiaFactor=2*size(pipeDiameters,2);
%    elseif indexPipe<= size(pipeDiameters,2)
%        pipeMaterial=0;
%        pipeDiaFactor=0;
%    end
    
%    pipeDiameter=pipeDiameters(indexPipe-pipeDiaFactor);
    pipeDiameter=pipeDiameters(indexPipe);
    
    if indexPipe > 4
        pipeMaterial=1;
    else
        pipeMaterial=0;
    end
    
    %send to pipe script
    %return headloss and cost
    [headloss,pipeCost]=pipe(pipeLength,flowRate,head,pipeDiameter,pipeMaterial,indexPipe);

    %net head
    
    netHead=head-headloss;
    
    %if net head is impossible, set to zero to prevent any progress at this
    %pipe dia
    if netHead <0
        netHead=0;
    end
        %Select turbine type
        
        for indexTurbine=1:(size(turbineTypesNo,2))
        turbineType=turbineTypesStrings(indexTurbine,:);
        turbineTypeNo=turbineTypesNo(indexTurbine);
        
%Designing the turbine
%Find the optimal runner diameter

actFlow=flowRate;
actHead=netHead;

modHead=turbineInfo(indexTurbine,1);
modFlow=turbineInfo(indexTurbine,2);
modDiameter=turbineInfo(indexTurbine,3);
modSpeed=turbineInfo(indexTurbine,4);



actDiameterNotRounded= sqrt ((actFlow./modFlow) * (sqrt(modHead)./sqrt(actHead)) * modDiameter^2);

%round the diameter to nearest 50mm

actDiameter=scriptround(actDiameterNotRounded);

%find the actual turbine speed

actSpeed = (sqrt (actHead)/sqrt(modHead)) * modDiameter/actDiameter * modSpeed;

%check if the actSpeed is within the generator allowance
%if so continue to the power section

check=((actSpeed/1500) < (1 + generatorAllowance) && (actSpeed/1500) > (1 - generatorAllowance)) || ((actSpeed/1000) < (1 + generatorAllowance) && (actSpeed/1000) > (1 - generatorAllowance)) || ((actSpeed/750) < (1 + generatorAllowance) && (actSpeed/750) > (1 - generatorAllowance)) || ((actSpeed/500) < (1 + generatorAllowance) && (actSpeed/500) > (1 - generatorAllowance));
if check~=1
    
%Outwith generator limits - do not continue

elseif check==1

%Adjust head to meet rpm - used for engineering analysis, not important

possibleRPM=[500,750,1000,1500];

idealRPM = possibleRPM(findnearest(actSpeed,possibleRPM));


headRequired=((idealRPM/modSpeed)*(actDiameter/modDiameter)*sqrt(modHead))^2;


%Positive means a headloss is required
%Negative means a head gain is required
deltaH=netHead-headRequired;

%set maximum flow/power equal to zero

maxFlow=0;
maxPower=0;
maxEfficiency=0;    
increment=0;
powergen=0;
generatorEfficiency=0.96;
%Get efficiency for each flow - start from smallest flow and work up
for flowVariants=FDSize:-1:1
increment=increment+1;
%Use the head to find the unit speed and the head and Q to find the unit flow
flowValue=FD(flowVariants);
[headlossValue,notNeeded]=pipe(pipeLength,flowRate,head,pipeDiameter,pipeMaterial,indexPipe);

%Get values for hillcurves
unitSpeedVariant=(actSpeed/sqrt(head-headlossValue)) * (actDiameter/modDiameter);
unitFlowVariant=(flowValue/sqrt(head-headlossValue)) * (modDiameter^2/actDiameter^2);

%Send to hillcurve script to find the efficiency
efficiency=hillcurves(turbineTypeNo,unitFlowVariant,unitSpeedVariant);


%Determine power generation at this speed
powerGeneration=((9.81*1000*flowValue*(head-headlossValue)*efficiency/100))*generatorEfficiency;



%check if power is the largest - if so, add to total energy generation
if powerGeneration > maxPower
    maxPower=powerGeneration;
    maxFlow=flowValue;
    maxEfficiency=efficiency;

end

%temp to find info on final design
% if turbineTypeNo==3 && pipeDiameter==0.8818
% 
% efficiencyMatrix(flowVariants)=efficiency;
% unitSpeedMatrix(flowVariants)=unitSpeedVariant;
% unitFlowMatrix(flowVariants)=unitFlowVariant;
% powerGenerationMatrix(flowVariants)=maxPower;
% 
% end

%if not, then the previous flow rate was used
    energyGeneration=energyGeneration+maxPower*(FDhours);
    
end

%COSTS

%Turbine cost

turbineCost=prices(turbineTypeNo,actDiameter);


generatorEfficiency=0.96;
powerGeneration=(9.81*1000*maxFlow*(head-headloss)*maxEfficiency/100*generatorEfficiency);

%get generator cost

switch idealRPM
    
    case 500
        
        generatorCost=30000+35*powerGeneration*1e-3;

    case 750
        
        generatorCost=20000+31.25*powerGeneration*1e-3;
        
    case 1000
        
        generatorCost=18000+20*powerGeneration*1e-3;
        
    case 1500

        generatorCost=12000+26.6*powerGeneration*1e-3;
end

additionalInvestment=1e6;
capacityFactor=energyGeneration/(maxPower*8760);
totalInvestment=generatorCost+turbineCost+pipeCost+additionalInvestment;

%calculate the factor required for finding income
if maxPower > 1e6
    expTariff=0.1119;
else
    expTariff=0.1496;
end

%find income for the next 15 years

totalReturn=(energyGeneration*1e-3*expTariff)*15;

%find the entire cost of the scheme for the 15 year period

totalCost=totalInvestment+(0.02*totalInvestment)*15;

%thus the 15 year profit

totalProfit=totalReturn-totalCost;


%Subtract the tax over that period
totalProfit=totalProfit*.72;

masterMatrix((size(masterMatrix,1)+1),:)=[flowRate,pipeDiameter,pipeMaterial,turbineTypeNo,maxFlow,maxPower,energyGeneration,capacityFactor,actSpeed,actDiameter,turbineCost,pipeCost,generatorCost,(1/(totalInvestment/totalReturn)),totalProfit,totalCost,totalReturn,deltaH,netHead];
%resets
powerGeneration=0;
energyGeneration=0;
turbineCost=0;
generatorCost=0;
totalInvestment=1e9;
totalReturn=0;
totalCost=1e9;

%end points

%generator allowance 
end
%turbine type
end
%pipe
end
pipeCost=0;
%flowRate check 
end

%rated flow
end

%Sort and select the top rated design
optimiseFactor=-15;
chosenData=sortrows(masterMatrix,optimiseFactor);
chosenData=chosenData(1,:);

% %Display - for debugging individual scenarios
% 
%  format short
%  f = figure('Position',[200 200 750 750]);
% cnames = {'Flow Rate (m3/s)','Pipe Diameter (m)','Pipe Material','Turbine Type (no)','Max Flow Rate (m3/s)','Max Power Generation (W)','Energy Generation (W-h)','Capacity Factor','rpm','Actual Diameter (m)','Turbine Cost (�)','Pipe Cost (�)','Generator Cost (�)','Payback (Years)','15 Year Profit (�)','Total Cost (�)','Total Return (�)','Intake Y','Intake X','Powerhouse Index','Static Head (m)','Pipe Length (m)'}; 
% % 
%  t = uitable('Data',sortrows(masterMatrix,-15),'ColumnName',cnames,'Parent',f ,'Position',[1 1 750 750]);
