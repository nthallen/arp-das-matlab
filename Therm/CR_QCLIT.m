% Generates Calibration for QCLIT
%   30K Thermistor
%   Pulled up by 75K with 3M in parallel
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
Ret = 1./(1./Rt+1/3e6);
R  = 75e3;
Cts = (4096/3) * Ret ./ (Ret + R );
Desc='QCLIT 30K Thermistor pulled up 75K in parallel with 3M';
gencal2( T, Cts, 1, 'QCLIT', Desc, 'AD12_QCLIT, CELCIUS', 2 );
