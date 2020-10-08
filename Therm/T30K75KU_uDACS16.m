% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
% Specifically for uDACS16 ADS1115 16-bit
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 75e3;
Cts = 32768 * Rt ./ (Rt + R );
Desc='uDACS16 30K Thermistor pulled up by 75K';
gencal2( T, Cts, 1, 'T30K75KU_uDACS16', Desc, ...
  'uDACS16_T30K75KU, uDACS_CELCIUS', ...
  [], [], [150 -40]);
