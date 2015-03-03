%%
A = load('GE_B11.dat');
T = A(:,1);
Rrat = A(:,2);
Rt = 1e6 * Rrat;
Rpullup = 249000;
Vref = 4.096;
V = Vref * Rt ./ (Rt + Rpullup);

k = 1e-3; % W/degree
dT = V.^2 ./ (k * Rt); % degrees error
p = zeros(3,1);
p(1) = subplot(3,1,1);
plot(p(1), T, dT);
%%
Thi = T + dT;
Rhi = interp1(T,Rt,Thi,'linear','extrap');
Vhi = Vref * Rhi ./ (Rhi + Rpullup);
dV = Vhi - V;
p(2) = subplot(3,1,2);
plot(p(2), T, dV);
%%
dbits = dV * (2^16) / Vref;
p(3) = subplot(3,1,3);
plot(p(3), T,dbits); shg;