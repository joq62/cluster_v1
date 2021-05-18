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

    io:format("~p~n",[{"Start pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_0(),
    io:format("~p~n",[{"Stop pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
   % ok=pass_1(),
  %  io:format("~p~n",[{"Stop pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
   % ok=pass_2(),
  %  io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_3(),
  %  io:format("~p~n",[{"Stop pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_4(),
  %  io:format("~p~n",[{"Stop pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_5(),
  %  io:format("~p~n",[{"Stop pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
 
    
   
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
pass_0()->
    {pong,
     'test_cluster@joq62-X550CA',
     cluster_control}=cluster_control:ping(),
    RHosts=cluster:running_hosts(),
    RSlaves=cluster:running_slaves(),
    MHosts=cluster:missing_hosts(),
    MSlaves=cluster:missing_slaves(),
    io:format("RHosts ~p~n",[{RHosts,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("RSlaves ~p~n",[{RSlaves,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("MHosts ~p~n",[{MHosts,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("MSlaves ~p~n",[{MSlaves,?MODULE,?FUNCTION_NAME,?LINE}]),

   % 10=lists:flatlength(RHosts),
   % 0=lists:flatlength(RSlaves),
   % 20=lists:flatlength(MHosts),
   % 20=lists:flatlength(MSlaves),
    HostIds=["glurk","joq62-X550CA","c0","c2"], 
    [{ok,_},{ok,_}]=cluster:start_masters(HostIds),
    WantedHostIds=["glurk","joq62-X550CA","c0","c2"],   
    L=cluster:start_slaves(WantedHostIds),
    R=[{ok,Slave}||{ok,Slave}<-L],
    10=lists:flatlength(R),
    [{running,RunningHosts},{missing,MissingHosts}]=cluster:status_hosts(),
    10=lists:flatlength(RunningHosts),
    20=lists:flatlength(MissingHosts),

    [{running,RunningSlaves},{missing,MissingSlaves}]=cluster:status_slaves(),
    10=lists:flatlength(RunningSlaves),
    10=lists:flatlength(MissingSlaves),  
    timer:sleep(1000),
 
    RHosts1=cluster:running_hosts(),
    RSlaves1=cluster:running_slaves(),
    MHosts1=cluster:missing_hosts(),
    MSlaves1=cluster:missing_slaves(),
    io:format("RHosts1 ~p~n",[{RHosts1,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("RSlaves1 ~p~n",[{RSlaves1,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("MHosts1 ~p~n",[{MHosts1,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("MSlaves1 ~p~n",[{MSlaves1,?MODULE,?FUNCTION_NAME,?LINE}]),

    10=lists:flatlength(cluster:running_hosts()),
    10=lists:flatlength(cluster:running_slaves()),
    20=lists:flatlength(cluster:missing_hosts()),
    10=lists:flatlength(cluster:missing_slaves()),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_5()->
    {{running,Running},{missing,Missing}}=cluster:status_slaves(),
    10=lists:flatlength(Running),
    10=lists:flatlength(Missing),   
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_3()->
    HostIds=["glurk","joq62-X550CA","c0"],
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
    WantedHostIds=["glurk","joq62-X550CA","c0"],   
%    SlaveNames=["slave0","slave1","slave2","slave3","slave4"],
 %   ErlCmd="-setcookie abc",
    L=cluster:start_slaves(WantedHostIds),
    R=[{ok,Slave}||{ok,Slave}<-L],
    10=lists:flatlength(R),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->

    [{running,Running},{missing,Missing}]=cluster:status_hosts(),
    10=lists:flatlength(Running),
    20=lists:flatlength(Missing),
    
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
    ToKill=[	    
	    'master@joq62-X550CA',
	    'master@c2',
	    'slave0@joq62-X550CA',
	    'slave1@joq62-X550CA',
	    'slave2@joq62-X550CA',
	    'slave3@joq62-X550CA',
	    slave1@c0,
	    slave3@c0,
	    slave2@c0,
	    slave4@c0,
	    slave0@c0,
	    slave1@c2,
	    slave3@c2,
	    slave2@c2,
	    slave4@c2,
	    slave0@c2,
	    'slave4@joq62-X550CA'],
    R=[{rpc:call(Node,init,stop,[]),Node}||Node<-ToKill],
    io:format("R ~p~n",[{R,?MODULE,?FUNCTION_NAME,?LINE}]),
    timer:sleep(1000),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
    ToKill=['slave0@joq62-X550CA','slave1@joq62-X550CA',
	    'slave2@joq62-X550CA','slave3@joq62-X550CA',slave1@c2,
	    slave3@c2,slave2@c2,slave4@c2,slave0@c2,
	    'slave4@joq62-X550CA','master@joq62-X550CA',master@c2,
	    
	    slave1@c0,
	    slave3@c0,slave2@c0,slave4@c0,slave0@c0,
	    master@c2],
    [rpc:call(Node,init,stop,[])||Node<-ToKill],
    application:stop(cluster),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
