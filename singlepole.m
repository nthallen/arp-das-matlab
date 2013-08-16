function [b,a] = singlepole( Wn, ftype )
% [b,a] = singlepole( Wn, ftype );
% b and a are suitable input parameters to Matlab's filter()
% Wn is the normalized cutoff frequency where Fnyquist = 1
% ftype is either 'lowpass' or 'highpass'
RC = 1/(2*pi*Wn);
T = 1/2;
if nargin < 2 || strcmp(ftype,'lowpass')
  a = [ (1+2*RC/T) (1-2*RC/T) ];
  b = [ 1 1 ];
elseif strcmp(ftype,'highpass')
  a = [ (2/T + 1/RC) (1/RC - 2/T) ];
  b = [ (2/T) (-2/T) ];
else
  error('Unrecognized ftype');
end
