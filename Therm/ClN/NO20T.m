% Generates Calibration for
%   Thermometrics 10K Thermistor
%   Pulled Up by 75K Resistor
%   Pulled Up to VRef
% But most imporantly: Calibrated through the system!
path(PATH,'c:\home\therm');
S = load('tlookup0.dat');
Cts = S(:,1);
T = S(:,2);
Desc='NO20T Calibration';
gencal2( T, Cts/16, 16, 'AD12_T10K_N0', Desc, 'AD12_T10K_N0, CELCIUS' );
