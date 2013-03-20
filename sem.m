function [y] = sem(x,varargin)
% Computes standard error of the mean (SEM)
% SYNTAX function [y] = sem(x,dim)
% INPUTS
% x     Input data
% dim   Calculate SEM on the second dimension
% OUTPUTS
% y     standard error of the mean (SEM): std/sqrt(N)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________


if nargin==2
  if varargin{1}==2
    x = x';
  end
end

n = size(x,1);
y = std(x) / sqrt(n);

% EOF
