%%
figure; x = (-1:.1:2)'; y = (x.^2)+ones(size(x))*(-2:2)*0.1; lns=plot(x,y);
TR = lns(1).DataTipTemplate.DataTipRows;
lns(1).DataTipTemplate.DataTipRows(1) = dataTipTextRow('MyVar','');
lns(1).DataTipTemplate.DataTipRows(2:3) = TR;
%%
figure; x = (-1:.01:2)'; y = (x.^2)+ones(size(x))*(-2:2)*0.1;
Time = (x-min(x))*3600;
DTime = datetime(Time,'convertfrom','posix');
lns=plot(DTime,y);
TR = lns(1).DataTipTemplate.DataTipRows;
lns(1).DataTipTemplate.DataTipRows(1) = dataTipTextRow('MyVar','');
lns(1).DataTipTemplate.DataTipRows(2:3) = TR;
lns(1).DataTipTemplate.DataTipRows(2).Format = 'hh:mm:ss.SSS';
datatip(lns(1),DTime(100),y(100,1));
%%
figure; x = (-1:.01:2)'; y = (x.^2)+ones(size(x))*(-2:2)*0.1;
Time = x*3600;
DTime = seconds(Time);
lns=plot(DTime,y,'DisplayName','My_Var','DurationTickFormat','mm:ss');%);
TR = lns(1).DataTipTemplate.DataTipRows;
lns(1).DataTipTemplate.DataTipRows(1) = dataTipTextRow('My\_Var','');
lns(1).DataTipTemplate.DataTipRows(2:3) = TR;
lns(1).DataTipTemplate.DataTipRows(2).Format = 'mm:ss.SSS';
%datatip(lns(1),DTime(100),y(100,1));
