%%
GE = load('YSI_R_vs_t_2.dat');
Rnom = 2252;
T = GE(:,1);
R = GE(:,2);
Vref = 2.5;
Rpu = 1.0e6;
Vth = Vref * R ./(R+Rpu);
%%
% plot(T,Vth);
%%
Tmin = interp1(Vth,T,Vref/2);
%%
v = Vth < Vref/2;
T = [Tmin; T(v)];
Vth = [Vref/2;Vth(v)];
%%
fprintf(1,'/* %.3f K Thermistor pulled up by %.1f M */\n', Rnom/1000, Rpu/1e6);
fprintf(1,'Calibration (AmbTS_T_t, CELCIUS) {\n');
for i = 1:length(Vth)
  fprintf(1, '  %.7f, %.2f\n', Vth(i), T(i));
end
fprintf(1,'}\n');
