function [headloss,pipeCost]=pipe(pipeLength,Q,hgross,D,material,indexPipe);

headloss=0;
price=0;
t=0;
%important note input one material at a time



t1=[0.006,0.0082,0.0103,0.0127,0.0124,0.0145,0.016,0.0173,0.0211,0.0231,0.0272,0.0339,0.0387,0.0429,0.0469];


price1=[51,171,387,794,78,102,132,166,205,246,346,395,460,507,614];



%  if material==0
%     price=price(1,1:5)
%     D=D(1,1:5)
%     k=0.0001

%     E=200E9
%     UTS=350E6
%     rho=7.8E3
%     thickcorrection=1.1 %assume welded
% end

if material==0
    k=0.00001;
    E=2.8E9;
    UTS=28E6;
    rho=1.4E3;
    thickcorrection=2;
   %assume temp sub zero 
end
if material==1
    k=0.00001;
    E=15E9;
    UTS=140E6;
    rho=2E3;
    thickcorrection=1; %no correction    
 end

[headloss,f,V] = MYOEx85(pipeLength,Q,D,k);

price=price1(indexPipe);
pipeCost=price*pipeLength;


%%%%%%%%%%%%%Factor of Safety%%%%%%%%%%%%%%%%%%%%%%%
%Hertha

% 
% hwallloss=(f*pipeLength*0.08*Q^2)/D^5;
% hturbloss=0;%should be done later assume no bends exits ents etc;
% hfriction=hwallloss+hturbloss;
% %Pressure wave velocity
% a=1400/sqrt(1+(2.1E9*D)/(E*t));
% %Surge head
% hsurge=(a*V)/9.81;
% htotal=hgross+hsurge;
% % Effective thickness
% teffective=t/thickcorrection;
% SF=(teffective*UTS)/(5*htotal*10^3*D);
% end