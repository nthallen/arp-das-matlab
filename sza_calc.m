% sza = sza_calc( Lat, Long, time, month, day, year );
%   Lat = North Latitude in degrees
%   Long = East Longitude in degrees
%   time = Seconds since midnight GMT
%   month = 1 => Jan, 12 => Dec
%   day = Day of Month
%   year = Full year.
%
%  This program calculates solar zenith angle for any time and place
%  on earth. The required input is date, time and position of the observer.
%  This routine was originally transcribed from a Fortran program which
%  was written by Steve Lloyd. No other references to sources is known.
%  It has been tweaked minimally by Norton Allen to eliminate loops where
%  Matlab syntax permits.
function sza=szaclean(Lat,Long,time,am,ai,ak)

ut=time./3600;       % GMT in decimal hours
phi=Lat;             % Latitude (North is positive, South is negative)
alambda=Long;        % Longitude (West is negative, East is positive)
%                      a prefix r indicates the angle is in radians

% Julian date at midnight gmt minus 1721013.5
ajd0=(367.*ak)-fix((7/4)*(ak+fix((am+9)/12)))+(fix((275*am)/9))+ai;
% Julian date minus 1721013.5
ajd=(367.*ak)-fix((7/4)*(ak+fix((am+9)/12)))+(fix((275*am)/9))+ai+(ut./24);
t0=(ajd0-730531.5)/36525;
t=(ajd-730531.5)./36525;
d=357.528+(35999.05.*t);
d = mod(d, 360 );

rd=d*pi/180;

%----------------------------------- True geocentric longitude of the sun
al=280.46+(36000.772.*t)+(1.916.*sin(rd))+(0.02.*sin(2.*rd));
al = mod( al, 360 );

%----------------------------  Nu is the quadrant in which the sun resides
nu = fix(al/90) + 1;
rl = al*pi/180;
rra = atan(0.91747.*(tan(rl)));

%------------------------------------- Apparent right ascention of the sun
ra=rra*180/pi;
ra = mod( ra, 360 );

%------------------------------ Nub is the quadrant of the right ascension
%---------------------------- Since al and ra must be in the same quadrant,
%------------------------------- We will now check and make sure this is so.
nub = fix(ra/90) + 1;
ra = ra + (nu - nub) * 90;
nub = nu;

%________________________________________________________________________
rta = ra;
rdec = asin(0.3978.*sin(rl));
%------------- Declination of the sun, north is positive, south is negative.
dec = rdec*180/pi;
rphi = phi*pi/180;
%--------------------------------------- Greenwich mean sideral time in hours
gmst=6.69737456+(2400.051336.*t0)+(0.0000258622.*t0.^2)+(1.002737909.*ut);
gmst = mod( gmst, 24 );
gmt=gmst;

%-------------- Mean longitude of the ascending node of the moon's orbit ???
omega=125.04452-(1934.13626.*t)+(0.002071.*t.^2);
omega = mod( omega, 360 );
romega=omega*pi/180;

%----------------------------------------- Equation of the equinoxes in hours
e=-0.00029.*sin(romega);
%------------------------------------------------------------ Local hour angle
rlha=(15.*(gmst+e-(ra./15))+alambda)*pi/180;
rsza=acos((sin(rphi).*sin(rdec))+(cos(rphi).*cos(rdec).*cos(rlha)));
%---------------------------------------------------------- Solar zenith angle
sza=rsza*180/pi;
%_____________________________________________________________
