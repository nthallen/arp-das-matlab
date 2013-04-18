function ne_adhoc
% ne_adhoc
% Callback routine to combine selected graphs
[~,fig] = gcbo;
k = findobj(fig,'style','checkbox');
kv = get(k,'value');
kv = [ kv{:} ]'; % convert to a double array
v = find(kv > 0);
k = k(v);
kv = kv(v);
[~,I] = sort(kv);
k = k(I)';
graphs = get(k,'tag');
ne_group({},'Ad Hoc Graph Grouping',graphs{:});
