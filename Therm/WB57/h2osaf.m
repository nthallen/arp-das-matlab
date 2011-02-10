% h2osaf.m Generates conversions for WB57 H2O Primary Duct Thermistors
% Reads prim_therms.mat. This applies to VERSION 1.1 data.
% Retroactively corrected 6/6/02 after the realization that pullup
% is actually 200K, not 100K

load sec_therms.mat
prefix = 'SAFB';
Tnums = [1:7];
R = 200e3;

n_therms = size(therm,2)-1;
if n_therms ~= length(Tnums)
  error('Number of therms is incorrect');
end
[T,I] = sort(therm(:,n_therms+1));
Rt = therm(I,[1:n_therms])*1e3;
Cts = 4096 * Rt ./ (Rt + R );
for i = 1:length(Tnums)
% for i=1:1
  name = [ prefix num2str(Tnums(i)) ];
  Desc=[ name ': 10K Thermistor pulled up by ' num2str(R/1e3) 'K' ];
  fromto = [ 'AD12_' name ', KELVIN' ];
  gencal2( T, Cts(:,i), 1, name, Desc, fromto, 2 );
end

