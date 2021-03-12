%%
% data_fields tests
close all
clear all
clc

% Setup the figure
fig = figure;
set(fig,'color',[.8 .8 1]);
dfs = data_fields(fig,'h_leading', 5, 'txt_fontsize', 12);
rec = 'engeng_1';
Tvar = [ 'T' rec ];
T0 = posixtime(datetime('now'));
%
% What happens if I add a graph with a record that I have not
% previously mentioned? It borked, but was easy to create record
% automatically.
% dfs.new_graph(rec, 'CPU_Pct', 'new_fig');
dfs.new_graph(rec, 'Ivar', 'new_fig');
%dfs.set_interp(rec,'Ivar',true);
%
T1 = T0;
N = 10;
Per = 10;
%%
str.(Tvar) = T1;
T2 = T1 + 1;
TI = interp1([0 1], [T1 T2], ((1:N)-1)/N);
str.Ivar = cos(pi*(TI-T0)/Per);
%
dfs.process_record(rec,str);
T1 = T2;
%%
% Setup the data connection
dfs.connect('127.0.0.1', 1080);
%%
dfs.disconnect();
close all
clear all
clc
