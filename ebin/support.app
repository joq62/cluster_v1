%% This is the application resource file (.app file) for the 'base'
%% application.
{application, support,
[{description, "support  " },
{vsn, "1.0.0" },
{modules, 
	  [support_app,support_sup,support]},
{registered,[support]},
{applications, [kernel,stdlib]},
{mod, {support_app,[]}},
{start_phases, []}
]}.
