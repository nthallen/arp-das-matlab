function T10KXKU( Rpullup, scale )
% T10KXU( Rpullup[, scale] );
% Generates Calibration for
%   10K Thermistor
%   Pulled Up by specified Resistor value (defaults to 100K)
%   Pulled Up to VRef
% Scale defaults to 1, but can be set to 16 for left-justified
% conversions.
%
% The generated conversion and file names will be
%  T10KxKU.tmc, where x is floor(Rpullup/1000);
if nargin < 2
  scale = 1;
  if nargin < 1
    Rpullup = 100e3;
  end
end
load TM4.mat; % contains T, Rrat
R25 = 10e3;
Rt = Rrat * R25;
Cts = 4096 * Rt ./ (Rt + Rpullup );
Name = [ 'T10K' num2str(floor(Rpullup/1000)) 'KU' ];
Desc=[ '10K Thermistor pulled up by ' num2str(Rpullup/1000) 'K' ];
gencal2( T, Cts, scale, Name, Desc, [ 'AD12_' Name ', CELCIUS' ], 2 );
