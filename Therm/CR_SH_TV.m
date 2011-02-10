function CR_SH_TV( Gain, Vpullup )
% Generates Calibration for Sample Heater Controller Temperature Monitor.
%   30K Thermistor driven by 10 uA
%   Read in with unity gain
% Switched to a different controller 7/7/07
%   30K Thermistor pulled up to 8 V pulled down by 3.09K followed
%   by gain of 7.76 Read into our AD12 with 4.096 V = 4096 bits
load t30k.mat;
% V = Rt * 10e-6;
% Desc='30K Thermistor with 10 uA';
if nargin < 2
  Vpullup = 8.2;
end
if nargin < 1
  Gain = 1.75;
end
V = Gain * Vpullup * 3.09e3 ./ (Rt + 3.09e3);
Desc=sprintf('%.1f V 30K Thermistor pulled down by 3.09K, %.2f gain', Vpullup, Gain );
Cts = V*1e3;
Tmax = interp1( Cts, T, 4095 );
fprintf(1, 'Tmax = %.1f\n', Tmax )
gencal2( T, Cts, 1, 'SH_TV', Desc, 'AD12_SH_TV, CELCIUS', 2 );
