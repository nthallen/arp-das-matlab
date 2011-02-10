load thermcal.mat
% RTD3 and RTD10 share the same (x,y) coord., so let's average them first.
% RTD3 = (RTD3 + RTD10)/2;
% RTD10 = RTD11;
% clear RTD11;
nRTDs = 11;
nPOSs = nRTDs+7;
nsamples = length(RTD1);
RTD = zeros(nsamples,nPOSs);
xy = zeros(nPOSs,2);
for j = [1:nRTDs]
  eval(sprintf('RTD(:,j) = RTD%d;',j));
end
nPOS = 1;
xy(nPOS,:) = [ 2 4 ]; nPOS = nPOS+1; %RTD1
xy(nPOS,:) = [ 2 3 ]; nPOS = nPOS+1; %RTD2
xy(nPOS,:) = [ 2 2 ]; nPOS = nPOS+1; %RTD3
xy(nPOS,:) = [ 2 1 ]; nPOS = nPOS+1; %RTD4
xy(nPOS,:) = [ 2 0 ]; nPOS = nPOS+1; %RTD5
xy(nPOS,:) = [ 3 1 ]; nPOS = nPOS+1; %RTD6
xy(nPOS,:) = [ 4 0 ]; nPOS = nPOS+1; %RTD7
xy(nPOS,:) = [ 3 2 ]; nPOS = nPOS+1; %RTD8
xy(nPOS,:) = [ 1 2 ]; nPOS = nPOS+1; %RTD9
xy(nPOS,:) = [ 2 2 ]; nPOS = nPOS+1; %RTD10
xy(nPOS,:) = [ 0 2 ]; nPOS = nPOS+1; %RTD11
% RTD(:,nPOS) = RTD10; xy(nPOS,:) = [4,2]; nPOS = nPOS+1;
% RTD(:,nPOS) = RTD7; xy(nPOS,:) = [0,0]; nPOS = nPOS+1;
% RTD(:,nPOS) = RTD7; xy(nPOS,:) = [0,4]; nPOS = nPOS+1;
% RTD(:,nPOS) = RTD7; xy(nPOS,:) = [4,4]; nPOS = nPOS+1;
% RTD(:,nPOS) = RTD6; xy(nPOS,:) = [1,1]; nPOS = nPOS+1;
% RTD(:,nPOS) = RTD6; xy(nPOS,:) = [1,3]; nPOS = nPOS+1;
% RTD(:,nPOS) = RTD6; xy(nPOS,:) = [3,3]; nPOS = nPOS+1;
RTD(:,nPOS) = f1b1(SF1B1); xy(nPOS,:) = [3,3]; nPOS = nPOS+1;
nPOSs = nPOS-1;
RTD = RTD(:,[1:nPOSs]);
xy = xy([1:nPOSs],:);
xRTD = xy(:,1);
yRTD = xy(:,2);

% This is stuff for a movie based on griddata function
% That appears to introduce invalid oscillations, so it isn't much use

% xi = [0:.5:4];
% yi = xi';
% zi = griddata(xRTD,yRTD,RTD(i,:),xi,yi);
% mesh(xi,yi,zi); hold; plot3(xRTD,yRTD,RTD(i,:),'+'); hold;
% set(gca,'Zlim',[300 508]);
% M = moviein(nsamples);
% for j=[1:nsamples]
%   zi = griddata(xRTD,yRTD,RTD(j,:),xi,yi);
%   mesh(xi,yi,zi); hold; plot3(xRTD,yRTD,RTD(j,:),'+'); hold;
%   set(gca,'Zlim',[300 508]); set(gca,'Clim', [300 508]);
%   M(:,j) = getframe;
% end
% movie(M,5,2);

r = abs(xy(:,1)+i*xy(:,2)-2-2*i);
t = ['123456789AB']';
M = mean(RTD')';
dT = RTD - M*ones(1,nPOSs);
for j = [1:nsamples]
  R = RTD(j,:)-M(j);
  plot(r,R,'.');
  text(r,R,t);
  % set(gca,'Ylim',[300 508]);
  xlabel('Distance from Center');
  ylabel('Temperature Deviation');
  pause
end

plot(dT);
text(2*ones(1,nPOSs),dT(2,:),t);
xlabel('Samples');
ylabel('Deviation from Average');
title('Individual RTDs');
pause

