%See individual scripts for annotation.

load initData.mat

%do for 10 data points
it=it10;
manipulationofrunoffMatrix;
[R, S] = dem_flow(Ef);
T = flow_matrix(Ef, R);
[A, A90] = upslope_area(Ef,T, runoffMatrix1);

%do for 52 data points

it=it52;
manipulationofrunoffMatrix;
[R, S] = dem_flow(Ef);
T = flow_matrix(Ef, R);
[A, A90Weekly] = upslope_area52(Ef,T, runoffMatrix1);

%with all the hydrology gathered, run megascript

megascript