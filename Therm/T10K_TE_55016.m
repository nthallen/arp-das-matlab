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
Nbits = 23;
gencalbits = 12;
scale = 2^(Nbits-gencalbits);
Cts = 2^gencalbits * Rt ./ (Rt + Rpullup );
Name = [ 'T10K' num2str(floor(Rpullup/1000)) 'KU' ];
Desc=[ '10K Thermistor pulled up by ' num2str(Rpullup/1000) 'K' ];
gencal2( C, Cts, scale, Name, Desc, [ 'AD7770_' Name ', CELCIUS'], 2 );
