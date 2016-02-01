%Rounds number to 0.005m

function [rounded] = scriptRound(num2round)

%round to 0.01 decimal place

lowRound=round(num2round*10)/10;

%round to 0.01 decimal at 0.005 intervals 

hiRound=round(num2round*20)/20;

%find closest

if abs(hiRound-num2round) > abs(lowRound-num2round)
    rounded=lowRound;
else
    rounded=hiRound;
    
end
