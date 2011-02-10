% Generates Calibration for
%   Thermometrics 10K Thermistor
%   Pulled Up by 75K Resistor
%   Pulled Up to VRef
% But most imporantly: Calibrated through the system!
path(PATH,'c:\home\therm');
S = load('tlookup2.dat');
Cts = S(:,1);
T = S(:,2);
Desc='NO22T Calibration';
gencal2( T, Cts/16, 16, 'AD12_T10K_N2', Desc, 'AD12_T10K_N2, CELCIUS' );
