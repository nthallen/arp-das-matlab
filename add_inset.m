function [ xl, yl ] = add_inset;
% [ xl, yl ] = add_inset;
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');
finalRect = rbbox;
point2 = get(gca,'CurrentPoint');
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
xl = [ p1(1) p1(1)+offset(1) ];
yl = [ p1(2) p1(2)+offset(2) ];
hold on
axis manual
plot(x,y,'k')                            % redraw in dataspace units
k = waitforbuttonpress;
point3 = get(gca,'CurrentPoint');
finalRect = rbbox;
point4 = get(gca,'CurrentPoint');
point3 = point3(1,1:2);              % extract x and y
point4 = point4(1,1:2);
p3 = min(point3,point4);             % calculate locations
offset3 = abs(point3-point4);         % and dimensions
x = [p3(1) p3(1)+offset3(1) p3(1)+offset3(1) p3(1) p3(1)];
y = [p3(2) p3(2) p3(2)+offset3(2) p3(2)+offset3(2) p3(2)];
% plot(x,y); % just for testing

dp = p1-p3;
do = offset-offset3;
dx = [ 1 0 ];
dy = [ 0 1 ];
if prod(dp) <= 0
  conn_line(p1, p3);
end
if prod(dp + dy.*do) >= 0
  conn_line(p1+dy.*offset, p3+dy.*offset3);
end
if prod(dp + dx.*do) >= 0
  conn_line(p1+dx.*offset, p3+dx.*offset3);
end
if prod(dp + do) <= 0
  conn_line(p1+offset, p3+offset3);
end
hold off
wp = get(gcf,'Position');
normRect = finalRect ./ [ wp(3) wp(4) wp(3) wp(4) ];
axes('position', normRect );

function conn_line( p1, p2 )
  x = [p1(1) p2(1)];
  y = [p1(2) p2(2)];
  p = [0 1];
  s = .05;
  r = [ s 1-s ];
  x1 = interp1( p, x, r );
  y1 = interp1( p, y, r );
  plot(x1,y1,'k');
  return;
