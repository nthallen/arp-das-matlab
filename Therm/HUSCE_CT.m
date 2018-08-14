%%
% HUSCE Heater Controllers
% 2.5 Vref 30K therm pulled down by 30K.
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
Rd  = 30e3;
Vpu = 2.5; % Pullup voltage
Vref = 4.096; % ADC Vref
Cts = 32768 * (Vpu/Vref) * Rd ./ (Rt + Rd );
Desc='30K Thermistor pulled down by 30K';
gencal2( T, Cts, 1, 'HUSCE_CT', Desc, 'CT_t, CELCIUS', 2 );
