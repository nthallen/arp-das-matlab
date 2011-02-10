% Generates Calibration for
%   30K Thermistor
%   Pulled Down by 30.1K Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 30.1e3;
Cts = 3859 * R ./ (Rt + R );
Desc='CFB_T 30K Thermistor pulled up to 3.859 down by 30.1K';
gencal2( T, Cts, 1, 'CFB_T', Desc, 'AD12_CFB_T, CELCIUS', 2 );
