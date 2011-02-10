% Generates Calibration for
%   30K Thermistor
%   Pulled Down by
%   30.1K Resistor
%   Pulled Up to 8.3V Reference
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 30.1e3;
V  = 8.3 * R ./ (Rt + R );
Cts = 4096 * (V/10);
Desc='30K Thermistor pulled down by 30.1K';
gencal( T, Cts, .5, 16, 'FlowTcal.tmc', Desc, 'FlowT_t, CELCIUS' );
