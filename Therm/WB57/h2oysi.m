% h2oysi.m Generates calibration curves for
% WB57 H2O Primary Duct Thermistors after YSI replacements
% Based on lookup table from YSI.
name = 'SAFF';
R = 200e3;

Cts = [ 3:4:4095 ]';
Rt = ( Cts * R ) ./ ( 4096 - Cts );
YSI = load('../YSI_R_vs_t.dat');
v = Rt >= min(YSI(:,3)) & Rt <= max(YSI(:,3));
T = interp1( YSI(:,3), YSI(:,1), Rt(v)) + 273.15;

Desc=[ name ': 10K YSI Thermistor pulled up by ' num2str(R/1e3) 'K' ];
fromto = [ 'AD12_' name ', KELVIN' ];
gencal2( T, Cts(v), 1, name, Desc, fromto, 2 );
