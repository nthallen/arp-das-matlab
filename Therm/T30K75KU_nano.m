%% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
% Specifically for uDACS16 ADS1115 16-bit
load t30k.dat;
C  = t30k(:,1);
Rt = t30k(:,2);
R  = 75e3;
%%
Cts = 256 * Rt ./ (Rt + R );
Desc='nano 30K Thermistor pulled up by 75K';
gencal2( C, Cts, 1, 'T30K75KU_nano', Desc, ...
  'nano_T30K75KU, nano_CELCIUS', ...
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
ylabel(ax(2),'Error');
%%
% Code that can copied into a program.
fprintf(1, 'a0 = %.4e;\n', a(1));
fprintf(1, 'a1 = %.4e;\n', a(2));
fprintf(1, 'a3 = %.4e;\n', a(3));
fprintf(1, 'logR = log(R);\n');
fprintf(1, 'C = 1./(a0 + a1 .* logR + a3.*(logR.^3)) - 273.15\n');
fprintf(1, 'double nano_T30K75KU_2_Celcius(int16_t At) {\n');
fprintf(1, '  double Rpu = 75e3;\n');
fprintf(1, '  int32_t Aref = 1<<23;\n');
fprintf(1, '  double logR = log(At * Rpu / (Aref - At));\n');
fprintf(1, '  double a0 = %.4e;\n', a(1));
fprintf(1, '  double a1 = %.4e;\n', a(2));
fprintf(1, '  double a3 = %.4e;\n', a(3));
fprintf(1, '  double C = 1/(a0 + a1 * logR + a3*pow(logR,3)) - 273.15;\n');
fprintf(1, '  return C;\n');
fprintf(1, '}\n');

%%
% Verify this copared to the lookup table
D0 = load('raw/210609.1F/dpopseng_1a.mat');
D1 = load('raw/210609.1F/dpopseng_1.mat');
T = time2d(D0.Tdpopseng_1');
%%
figure; plot(T,D0.Ring1T-D1.Ring1T,'.');
%%
plot(T,D0.Ring2T-D1.Ring2T,'.'); shg
%%
plot(T,D0.Ring3T-D1.Ring3T,'.'); shg

