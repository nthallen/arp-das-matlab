function T1M1M_DACS
% T1M1M_DACS
% Thermometrics (GE) B05 1 MOhm thermistor
A = load('GE_B11.dat');
T = A(:,1);
Rrat = A(:,2);
Rt = 1e6 * Rrat;
Rpullup = 1e6;
Cts = 4096 * Rt ./ (Rt + Rpullup );
Desc='1M Thermistor pulled up by 1M';
gencal3( T, Cts, 8, 'T1M1M', Desc, 'AI_T1M1M, CELCIUS', 2 );