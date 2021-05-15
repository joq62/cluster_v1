%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(host).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(HostConfigPath,"https://github.com/joq62/host_config.git").
-define(GitHostConfigFile,"git clone https://github.com/joq62/host_config.git").
-define(Cookie,"abc").
-define(HostConfigDir,"host_config").
-define(HostConfigFile,"host_config/hosts.config").

-define(AppCatalogPath,"https://github.com/joq62/catalog.git").
-define(GitAppCatalog,"git clone https://github.com/joq62/catalog.git").
-define(AppCatalogDir,"catalog").
-define(AppCatalogFile,"catalog/application.catalog").





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
	 running_hosts/1,
	 missing_hosts/1,
	 status_host/1,
	 status_hosts/1
%	 restart_host/0
%	 install/0,
%	 start_app/5,
%	 stop_app/4,
%	 app_status/2

	]).

-define(WAIT_FOR_TABLES,5000).

%% ====================================================================
%% External functions
%% ====================================================================
status_hosts(HostInfoList)->
  check_hosts(HostInfoList).
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
status_host(HostInfo)->
    {host_id,HostId}=lists:keyfind(host_id,1,HostInfo),
    {ip,Ip}=lists:keyfind(ip,1,HostInfo),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,HostInfo),
    {uid,Uid}=lists:keyfind(uid,1,HostInfo),
    {pwd,Pwd}=lists:keyfind(pwd,1,HostInfo),
    case my_ssh:ssh_send(Ip,Port,Uid,Pwd,"hostname",5000) of
	[_HostId]->
	    running;
	Err->
	    missing
    end.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
running_hosts(HostInfoList)->
    Running=case check_hosts(HostInfoList) of
		[{ok,Available},{error,_NotAvailable}]->
		    Available;
		Err->
		    {error,[Err]}
	    end,
    Running.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
missing_hosts(HostInfoList)->
    Missing=case check_hosts(HostInfoList) of
		[{ok,_Available},{error, NotAvailable}]->
		    NotAvailable;
		Err->
		    {error,[Err]}
	    end,
    Missing.


		
    

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
    os:cmd("rm -rf "++?AppCatalogDir),
    os:cmd(?GitAppCatalog),
    {ok,AppList}=file:consult(?AppCatalogFile),
    case Available of
	[]->
	    {error,[no_hosts_available]};
	[LeaderHostInfo|_]->
	    glurk
	    % start master vm master

	    % start slaves slave_uniqueid,s1,s2,s3,s4,s5

	    

	    % load and start support application

	    % load and start master application 
    end,
    AppList.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
check_hosts(HostInfoList)->
    F1=fun check_host/2,
    F2=fun host_status/3,
    R1=mapreduce:start(F1,F2,[],HostInfoList),
    Running=[HostInfo||{ok,HostInfo}<-R1],
    Missing=[HostInfo||{error,[_,HostInfo]}<-R1],
    [{running,Running},{missing,Missing}].

check_host(Pid,HostInfo)->
    {host_id,HostId}=lists:keyfind(host_id,1,HostInfo),
    {ip,Ip}=lists:keyfind(ip,1,HostInfo),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,HostInfo),
    {uid,Uid}=lists:keyfind(uid,1,HostInfo),
    {pwd,Pwd}=lists:keyfind(pwd,1,HostInfo),
    Result=rpc:call(node(),my_ssh,ssh_send,[Ip,Port,Uid,Pwd,"hostname",7000],5000),
 %   io:format("Result ~p~n",[{Result, ?MODULE,?LINE}]),
    Pid!{check_host,{Result,HostInfo}}.

host_status(Key,Vals,[])->
  %  io:format("~p~n",[{?MODULE,?LINE,Key,Vals}]),
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
