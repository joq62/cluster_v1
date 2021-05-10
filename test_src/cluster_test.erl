%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(cluster_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================
-define(Host,"c0").
-define(Ip,"192.168.0.200").
-define(SshPort,22).
-define(TimeOut,2*5000).
-define(Uid,"joq62").
-define(Pw,"festum01").

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_1(),
    io:format("~p~n",[{"Stop pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_2(),
    io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

 
    
   
      %% End application tests
    io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
    io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->
    glurk=cluster:status_hosts(),
    

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_1()->
    ok=cluster:load_config(),
    {ok,[[{host_id,"joq62-X550CA"},
	  {ip,"192.168.0.100"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}],
	 [{host_id,"c0"},
	  {ip,"192.168.0.200"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}],
	 [{host_id,"c1"},
	  {ip,"192.168.0.201"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}],
	 [{host_id,"c2"},
	  {ip,"192.168.0.202"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}]]}=cluster:read_config(),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_11()->
    [{ok,[[{host_id,"c0"},
	  {ip,"192.168.0.200"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}],
	 [{host_id,"joq62-X550CA"},
	  {ip,"192.168.0.100"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}]]},
    {error,[[{host_id,"c1"},
	     {ip,"192.168.0.201"},
	     {ssh_port,22},
	     {uid,"joq62"},
	     {pwd,"festum01"}],
	    [{host_id,"c2"},
	     {ip,"192.168.0.202"},
	     {ssh_port,22},
	     {uid,"joq62"},
	     {pwd,"festum01"}]]}]=cluster:install(),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
      ssh:start(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
