%% This is the application resource file (.app file) for the 'base'
%% application.
{application, cluster,
[{description, "cluster  " },
{vsn, "1.0.0" },
{modules, 
	  [cluster_app,cluster_sup,cluster,cluster_control]},
{registered,[cluster]},
{applications, [kernel,stdlib]},
{mod, {cluster_app,[]}},
{start_phases, []}
]}.
