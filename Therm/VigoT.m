function VigoT
% VigoT
% Thermistor in Vigo PVI-4TE-5, Type TB04-222
T = [190:320]';
T0 = 293;
Beta = 2918.9;
RT0 = 2200;
Rt = RT0*exp(Beta*(T0-T)./(T*T0));
Rpullup = 75000;
Cts = 4096 * Rt ./ (Rt + Rpullup );
Desc='Vigo Thermistor pulled up by 75K';
gencal3( T, Cts, 8, 'VigoT', Desc, 'AI_VigoT, KELVIN', 2 );