% thvysi.m Compares calibration curves for
% WB57 H2O Backup Primary Duct Thermistors
% Old 10K Calibration values sent from Jasna, 5/6/02

%        1/T = A + B*Ln(R) + C*(Ln(R))^3
% where T is temperature in degrees K, and R is resistance in Ohm.
%             A                B              C
P = [
      2 0.000805359     0.000262193     1.390000E-07
      3 0.000802361     0.000263891     1.3381E-07
      5 0.000837134     0.00025843      1.486E-07
      6 0.000793969     0.000265945     1.337E-07
];

prefix = 'PAF';
R = 100e3;

n_therms = size(P,1);
Cts = [ 3:4:4095 ]';
Rt = ( Cts * R ) ./ ( 4096 - Cts );
LRt = log(Rt);
col = ones(size(Cts));
n_therm = size(P,1);
row = ones(1,n_therm);
Ttherm = 1 ./ ( (col*P(:,2)') + (col*P(:,3)').*(LRt*row) + (col*P(:,4)').*(LRt.^3*row) );

YSI = load('../YSI_R_vs_t.dat');
Tysi = interp1( YSI(:,3), YSI(:,1), Rt) + 273.15;

semilogx( Rt, Ttherm, Rt, Tysi );
legend('2', '3', '5', '6', 'YSI' );

