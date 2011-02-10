% Generates Calibration for
%   30K Thermistor
%   Pulled Down by 30.1K Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 30.1e3;
Cts = 4096 * R ./ (Rt + R );
Desc='30K Thermistor pulled down by 30.1K';
gencal2( T, Cts, 1, 'T30K30KD', Desc, 'AD12_T30K30KD, CELCIUS', 2 );
