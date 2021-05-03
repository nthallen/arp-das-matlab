%% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
% Specifically for DACS 16-bit
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
K = T+273.15;
[a0,a1,a3] = SteinHart_fit(Rt,K);
Rmin = 100;
Rmax = 1e7;
Rt1 = exp(log(Rmin):.01:log(Rmax))';
T1 = SteinHart(Rt1,a0,a1,a3);

Rpu  = 75e3;
Vref = 2.5;
FSR = 4.096;
Cts = 2^15 * (Vref/FSR) * Rt1 ./ (Rt1 + Rpu );
Desc=sprintf('BMM 30K Thermistor pulled up by 75K FSR=%.3f',FSR);
gencal2( T1, Cts, 1, 'BMM_T30K75KU', Desc, 'BMM_T30K75KU, BMM_CELCIUS_t' );
