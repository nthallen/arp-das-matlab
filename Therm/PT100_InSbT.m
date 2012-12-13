t = -200:70;
R0 = 100;
A = 3.9083E-3;
B = -5.775E-7;
C = -4.183E-12 * (t<0); % (below 0 °C), or
% C = 0 (above 0 °C);
Rt = R0 * (1 + A*t + B*t.^2 + C.*(t-100).* t.^3);
% figure; plot(t,Rt);
Bt135 = 1024*Rt./(Rt+135); % Bit value (0-1024 => 0-5V)

Desc='PT100 Thermistor pulled up by 135 Ohms';
gencal2( t', Bt135', 1, 'InSbT_t', Desc, 'InSbT_t, CELCIUS', 2 );
