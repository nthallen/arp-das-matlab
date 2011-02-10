% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   200K Resistor
%   Pulled Up to 10V Reference
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 200e3;
V  = 10 * R ./ (Rt + R );
Cts = 4096 * (V/10);
Desc='30K Thermistor pulled up by 200K';
gencal( T, Cts, .5, 16, 'pumpt.tmc', Desc, 'PumpT_t, CELCIUS' );
