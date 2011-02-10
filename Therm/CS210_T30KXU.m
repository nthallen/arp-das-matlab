function CS210_T30KXU( Rpullup, scale );
% CS210_T30KXU( Rpullup[, scale ] );
% Generates Calibration for
%   30K Thermistor
%   Pulled Up by specified Resistor value (defaults to 75K)
%   Pulled Up to VRef
% Scale defaults to 1, but can be set to 16 for left-justified
% conversions.
%
% The generated conversion and file names will be
%  T30KxKU.tmc, where x is floor(Rpullup/1000);
if nargin < 2
  scale = 1;
  if nargin < 1
    Rpullup = 75e3;
  end
end
load t30k.mat
Cts = (8092 + 8092 * Rt ./ (Rt + Rpullup ))/scale;
Name = [ 'CS210_T30K' num2str(floor(Rpullup/1000)) 'KU' ];
Desc=[ '30K Thermistor pulled up by ' num2str(Rpullup/1000) 'K' ];
gencal2( T, Cts, scale, Name, Desc, [ 'AD14_' Name ', CELCIUS'], 2 );
