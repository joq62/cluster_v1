{application, etcd,
 [{description, " etcd"},
  {vsn, "1.0.0"},
  {modules, [etcd_app,
             etcd_sup,
	     etcd_lib,
	     etcd]},
  {registered, [etcd]},
  {applications, [kernel, stdlib]},
  {mod, {etcd_app, []}}
 ]}.
