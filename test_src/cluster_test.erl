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

 %   io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=pass_2(),
 %   io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_3(),
    io:format("~p~n",[{"Stop pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_4(),
    io:format("~p~n",[{"Stop pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),

 
    
   
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
pass_3()->
    HostIds=["glurk","joq62-X550CA","c2"],
    [{ok,_},{ok,_}]=cluster:start_masters(HostIds),

   % Master2=list_to_atom("master"++"@"++HostId2),
  %  pong=net_adm:ping(Master2),
   % Slave02=list_to_atom("slave0"++"@"++HostId2),
   % {ok,Slave02}=cluster:start_slave(HostId2,"slave0","-setcookie abc"),


    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_4()->
    MasterHostIds=["joq62-X550CA","c2"],   
    SlaveNames=["slave0","slave1","slave2","slave3","slave4"],
    ErlCmd="-setcookie abc",
    [[{ok,_},
      {ok,_},
      {ok,_},
      {ok,_},
      {ok,_}],
     [{ok,_},
      {ok,_},
      {ok,_},
      {ok,_},
      {ok,_}]]=[cluster:start_slaves(HostId,SlaveNames,ErlCmd)||HostId<-MasterHostIds],
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->

    [{ok,[[{host_id,"c2"},
	   {ip,"192.168.1.202"},
	   {ssh_port,22},
	   {uid,"joq62"},
	   {pwd,"festum01"}],
	  [{host_id,"joq62-X550CA"},
	   {ip,"192.168.1.50"},
	   {ssh_port,22},
	   {uid,"joq62"},
	   {pwd,"festum01"}]]},
     {error,[[{host_id,"c2"},
	      {ip,"192.168.0.202"},
	      {ssh_port,22},
	      {uid,"joq62"},
	      {pwd,"festum01"}],
	     [{host_id,"c1"},
	      {ip,"192.168.0.201"},
	      {ssh_port,22},
	      {uid,"joq62"},
	      {pwd,"festum01"}],
	     [{host_id,"c0"},
	      {ip,"192.168.0.200"},
	      {ssh_port,22},
	      {uid,"joq62"},
	      {pwd,"festum01"}],
	     [{host_id,"joq62-X550CA"},
	      {ip,"192.168.0.100"},
	      {ssh_port,22},
	      {uid,"joq62"},
	      {pwd,"festum01"}]]}]=cluster:status_hosts(),
 %   io:format("R= ~p~n",[{R,?MODULE,?FUNCTION_NAME,?LINE}]),    

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
	  {pwd,"festum01"}],
	 [{host_id,"joq62-X550CA"},
	  {ip,"192.168.1.50"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}],
	 [{host_id,"c2"},
	  {ip,"192.168.1.202"},
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
