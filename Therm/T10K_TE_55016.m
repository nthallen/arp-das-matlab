%%
cd C:\Users\nort\Documents\Documents\SW\arp-das-matlab\Therm
%%
% te_55016 10K thermistor
% AD7770 is a 24-bit bipolar converter, so for positive voltages,
% we have 23-bit resolution
% If we go with 12-bit as OK for gencal2, then the scaling should
% be 2^11.
YSI = load('YSI_R_vs_t.dat');
C = YSI(:,1);
Rt = YSI(:,2);
Rpullup = 100e3;
%%
% Produce TMC lookup table
Nbits = 23;
gencalbits = 12;
scale = 2^(Nbits-gencalbits);
Cts = 2^gencalbits * Rt ./ (Rt + Rpullup );
Name = [ 'T10K' num2str(floor(Rpullup/1000)) 'KU' ];
Desc=[ '10K Thermistor pulled up by ' num2str(Rpullup/1000) 'K' ];
gencal2( C, Cts, scale, Name, Desc, [ 'AD7770_' Name ', CELCIUS'], 2 );
%%
% Generate Steinhart/Hart coefficients
V = C<100;
a = SteinHart_fit(Rt(V), C(V)+273.15);
% Rrefit = 10.^linspace(1,7,100)';
Rrefit = Rt;
Cfit = SteinHart(Rrefit, a);
%%
figure;
ax = [subplot(2,1,1) subplot(2,1,2)];
semilogx(ax(1),Rt,C-Cfit);
xlabel('Ohms');
ylabel('Error C');
plot(ax(2), C,C-Cfit);
xlabel('Celcius');
ylabel('Error');
%%
% Code that can copied into a program.
fprintf(1, 'a0 = %.4e;\n', a(1));
fprintf(1, 'a1 = %.4e;\n', a(2));
fprintf(1, 'a3 = %.4e;\n', a(3));
fprintf(1, 'logR = log(R);\n');
fprintf(1, 'C = 1./(a0 + a1 .* logR + a3.*(logR.^3)) - 273.15\n');

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

