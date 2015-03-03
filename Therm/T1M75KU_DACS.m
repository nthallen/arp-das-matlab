function T1M75KU_DACS
% T1M75KU
% Thermometrics (GE) B05 1 MOhm thermistor
A = load('GE_B11.dat');
T = A(:,1);
Rrat = A(:,2);
Rt = 1e6 * Rrat;
Rpullup = 75000;
Cts = 4096 * Rt ./ (Rt + Rpullup );
Desc='1M Thermistor pulled up by 75K';
gencal3( T, Cts, 8, 'T1M75KU', Desc, 'AI_T1M75KU, CELCIUS', 2 );