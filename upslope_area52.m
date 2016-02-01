function [A,A90] = upslope_area52(E, T,runoffMatrix1)
%upslope_area Upslope area measurements for a DEM
%
%   A = upslope_area(E, T) computes the upslope area for each pixel of the
%   DEM matrix, E.  T is the sparse system of linear equations computed by
%   flow_matrix; it represents the distribution of flow from pixel to pixel.
%
%   A contains the upslope area for each corresponding pixel of E.
%
%   Note: Connected groups of NaN pixels touching the border are treated as
%   having no contribution to flow.
%
%   Reference: Tarboton, "A new method for the determination of flow
%   directions and upslope areas in grid digital elevation models," Water
%   Resources Research, vol. 33, no. 2, pages 309-319, February 1997. 
%
%   Algorithm notes: The Tarboton paper is not very specific about the
%   handling of plateaus.  For details of how plateaus are handled in this
%   code, see the algorithm notes for the function flow_matrix.  In
%   particular, see the subfunction plateau_flow_weights in flow_matrix.m.
%   
%   Example
%   -------
%
%       s = load('milford_ma_dem');
%       E = s.Zc;
%       R = dem_flow(E);
%       T = flow_matrix(E, R);
%       A = upslope_area(E, T);
%       imshow(log(A), [])
%
%   See also dem_flow, dependence_map, fill_sinks, flow_matrix,
%   postprocess_plateaus.

%   Steven L. Eddins
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2007/10/02 15:50:40 $

% Right-side vector is normally all ones, reflecting an equal contribution
% to water flow originating in each pixel.
%rhs = ones(numel(E), 1);
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
% Adapted section 
% Charlie Seviour 21/10/09
% -------------------------------------------------------------------------
[mm,nn,zz]=size(runoffMatrix1);
for z=1:zz
    ValuesSparse=zeros(40716,1);
    increment=0;
for m=1:mm
    for n=1:nn
        increment=increment+1;
       ValuesSparse(increment)=runoffMatrix1(m,n,z);
   end
end

rhs = ValuesSparse;

%--------------------------------------------------------------------------
%   Steven L. Eddins
% Connected groups of NaN pixels that touch the border do not contribute
% to water volume.
mask = border_nans(E);
rhs(mask(:)) = 0;

Atemp = T\rhs;

A(:,:,z) = reshape(Atemp, size(E));
end
% -------------------------------------------------------------------------
%Take away Q90
% Stuart Scroggie 21/09/09
A90=ones(174,234,52);
[mm,nn,zz]=size(runoffMatrix1);
for m=1:mm
    for n=1:nn
       A90(m,n,:)=A(m,n,:)-A(m,n,48);
   end
end
%-------------------------------------------------------------------------

