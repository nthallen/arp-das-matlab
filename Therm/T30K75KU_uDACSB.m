%% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
% Specifically for uDACSB AD7770 24-bit
load t30k.dat;
C  = t30k(:,1);
Rt = t30k(:,2);
R  = 75e3;
%%
Cts = 65536 * Rt ./ (Rt + R );
Desc='uDACSB 30K Thermistor pulled up by 75K';
gencal2( C, Cts, 2^7, 'T30K75KU_uDACSB', Desc, ...
  'uDACSB_T30K75KU, uDACS_CELCIUS', ...
  [], [], [150 -40]);
%%
% Generate Steinhart/Hart coefficients
V = C < 100; % fit to all points in the table
a = SteinHart_fit(Rt(V), C(V)+273.15);
% Rrefit = 10.^linspace(1,7,100)';
Rrefit = Rt;
Cfit = SteinHart(Rrefit, a);
%%
figure;
ax = [subplot(2,1,1) subplot(2,1,2)];
semilogx(ax(1),Rt,C-Cfit);
xlabel(ax(1),'Ohms');
ylabel(ax(1),'Error C');
plot(ax(2), C,C-Cfit);
xlabel(ax(2),'Celcius');
ylabel(ax(2),'Error C');
%%
% Code that can copied into a program.
fprintf(1, 'a0 = %.4e;\n', a(1));
fprintf(1, 'a1 = %.4e;\n', a(2));
fprintf(1, 'a3 = %.4e;\n', a(3));
fprintf(1, 'logR = log(R);\n');
fprintf(1, 'C = 1./(a0 + a1 .* logR + a3.*(logR.^3)) - 273.15\n');
fprintf(1, 'double uDACSB_T30K75KU_2_Celcius(int32_t At) {\n');
fprintf(1, '  double Rpu = 75e3;\n');
fprintf(1, '  double Aref = 1<<23;\n');
fprintf(1, '  double logR = log(At * Rpu / (Aref - At));\n');
fprintf(1, '  double a0 = %.4e;\n', a(1));
fprintf(1, '  double a1 = %.4e;\n', a(2));
fprintf(1, '  double a3 = %.4e;\n', a(3));
fprintf(1, '  double C = 1/(a0 + a1 * logR + a3*pow(logR,3)) - 273.15;\n');
fprintf(1, '  return C;\n');
fprintf(1, '}\n');
