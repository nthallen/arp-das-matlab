load t10m.dat;
T = t10m(:,1);
Rrat=t10m(:,2);
Rt = Rrat * 1e7;
R = 250e3;
V = 10 * Rt ./ (Rt + R );
Cts = 4096 * (V/10);
Desc=sprintf('10M Thermistor pulled up by %.0fK', R*1e-3);
gencal( T, Cts, .5, 16, 't10mcal.tmc', Desc, 'AD12_T10M, CELCIUS' );
