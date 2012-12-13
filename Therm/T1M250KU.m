function T1M250KU
% T1M250KU
% Thermometrics (GE) B05 1 MOhm thermistor
A = load('GE_B11.dat');
T = A(:,1);
Rrat = A(:,2);
Rt = 1e6 * Rrat;
Rpullup = 250000;
Cts = 4096 * Rt ./ (Rt + Rpullup );
Desc='1M Thermistor pulled up by 250K';
gencal3( T, Cts, 8, 'T1M250KU', Desc, 'AI_T1M250KU, CELCIUS', 2 );