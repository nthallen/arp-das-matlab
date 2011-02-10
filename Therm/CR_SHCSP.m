function CR_SHCSP;
% Generates Calibration for Sample Heater Controller Temperature.
%   30K Thermistor driven by 10 uA
%   Read in with unity gain
load t30k.mat;
V = Rt * 10e-6/2;
Cts = V*409.6; % 0 to 4096 is 0 to 10V
Desc='D/A mapped to 30K Thermistor with 10 uA';
gencal2( T, Cts, 1, 'SHCStT', Desc, 'AD12_SHCStT, CELCIUS', 2 );
