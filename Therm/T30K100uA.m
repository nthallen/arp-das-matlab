% Generates Calibration for
%   30K Thermistor with 100uA current source
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
I = 100e-6;
%----------------------
% For parallel 100K
%----------------------
Rpar = 1e5;
V = I*(Rt*Rpar)./(Rt+Rpar);
Desc='30K Thermistor || 100K @ 100uA';
%----------------------
% For straight thermistor
%----------------------
%V = I * Rt;
%Desc='30K Thermistor @ 100uA';

v = V<7.5;
Cts = 65536 * V(v)/5 - 32768;
gencal2( T(v), Cts, 1, 'T30K100uA', Desc, 'AD16_T30K100uA, CELCIUS' );
