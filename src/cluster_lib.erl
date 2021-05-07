%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(cluster_lib).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(HostConfigPath,"https://github.com/joq62/host_config.git").
-define(GitHostConfigFile,"git clone https://github.com/joq62/host_config.git").
-define(Cookie,"abc").
-define(HostConfigDir,"host_config").
-define(HostConfigFile,"host_config/hosts.config").

-record(host,{
	      host_id,
	      ip,
	      ssh_port,
	      uid,
	      pwd
	     }).
%% --------------------------------------------------------------------


%% External exports
-export([
	 install/0,
	 start_app/5,
	 stop_app/4,
	 app_status/2

	]).

-define(WAIT_FOR_TABLES,5000).

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
install()->
    %%% load Git + check hosts
    os:cmd("rm -rf "++?HostConfigDir),
    os:cmd(?GitHostConfigFile),
    {ok,HostInfoList}=file:consult(?HostConfigFile),
    [{ok,Available},{error,_NotAvailable}]=check_hosts(HostInfoList),

    % start leader master 
    case Available of
	[]->
	    {error,[no_hosts_available]};
	[LeaderHostInfo|_]->
	    glurk
	    % start master vm

	    % load and start support application

	    % load and start master application 
    end,
	    
    ok.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
check_hosts(HostInfoList)->
    F1=fun check_host/2,
    F2=fun host_status/3,
    R1=mapreduce:start(F1,F2,[],HostInfoList),
    Available=[HostInfo||{ok,HostInfo}<-R1],
    NotAvailable=[HostInfo||{error,[_,HostInfo]}<-R1],
    [{ok,Available},{error,NotAvailable}].

check_host(Pid,HostInfo)->
    {host_id,HostId}=lists:keyfind(host_id,1,HostInfo),
    {ip,Ip}=lists:keyfind(ip,1,HostInfo),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,HostInfo),
    {uid,Uid}=lists:keyfind(uid,1,HostInfo),
    {pwd,Pwd}=lists:keyfind(pwd,1,HostInfo),
    Pid!{check_host,{my_ssh:ssh_send(Ip,Port,Uid,Pwd,"hostname",5000),HostInfo}}.

host_status(Key,Vals,[])->
 %   io:format("~p~n",[{?MODULE,?LINE,Key,Vals}]),
     host_status(Vals,[]).

host_status([],Status)->
    Status;
host_status([{[HostId],HostInfo}|T],Acc) ->
    host_status(T, [{ok,HostInfo}|Acc]);
host_status([{Err,HostInfo}|T],Acc) ->
    host_status(T,[{error,[Err,HostInfo]}|Acc]).

%available_hosts([],HostsStatus)->
 %   HostsStatus;
%available_hosts([HostInfo|T],Acc)->
 %   {host_id,HostId}=lists:keyfind(host_id,1,HostInfo),
  %  {ip,Ip}=lists:keyfind(ip,1,HostInfo),
  %  {ssh_port,Port}=lists:keyfind(ssh_port,1,HostInfo),
  %  {uid,Uid}=lists:keyfind(uid,1,HostInfo),
  %  {pwd,Pwd}=lists:keyfind(pwd,1,HostInfo),
  %  io:format("~p~n",[{HostInfo,?MODULE,?LINE}]),
  %  NewAcc=case my_ssh:ssh_send(Ip,Port,Uid,Pwd,"hostname",10*5000) of
%	       [HostId]->
%		   [{ok,HostInfo}|Acc];
%	       Err->
%		   [{error,[Err,HostInfo]}|Acc]
%	   end,
 %   available_hosts(T,NewAcc).

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
stop_app(ApplicationStr,Application,Dir,Vm)->
    rpc:call(Vm,os,cmd,["rm -rf "++Dir++"/"++ApplicationStr]),
    rpc:call(Vm,application,stop,[Application]),
    rpc:call(Vm,application,unload,[Application]).
    

start_app(ApplicationStr,Application,CloneCmd,Dir,Vm)->
    rpc:call(Vm,os,cmd,[CloneCmd++" "++Dir++"/"++ApplicationStr]),
    true=rpc:call(Vm,code,add_patha,[Dir++"/"++ApplicationStr++"/ebin"]),
    ok=rpc:call(Vm,application,start,[Application]),
    app_status(Vm,Application).

app_status(Vm,Application)->
    Status = case rpc:call(Vm,Application,ping,[]) of   
		 {pong,_,Application}->
		     running;
		 Err ->
		     {error,[Err]}
	     end,
    Status.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
