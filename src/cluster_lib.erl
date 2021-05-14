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
	 load_config/3,
	 read_config/1,
	 status_hosts/1,
	 start_master/2,
	 start_slave/4
	]).


-export([

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
start_slave(Master,HostId,SlaveName,ErlCmd)->
    R=case rpc:call(Master,slave,stop,[list_to_atom(SlaveName++"@"++HostId)],2000) of
	  ok->
	      case rpc:call(Master,slave,start,[HostId,SlaveName,ErlCmd],2000) of
		  {ok,Slave}->
		      rpc:call(Master,os,cmd,["rm -rf "++SlaveName],5000),
		      case rpc:call(Master,file,make_dir,[SlaveName],2000) of
			  ok->
			      {ok,Slave};
			  {error, Reason}->
			      {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]}
		      end;
		  {error, Reason}->
		      {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]}
	      end;
	  Err ->
	      {error,[Err,?MODULE,?FUNCTION_NAME,?LINE]}
      end,
    R.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start_master(HostId,HostFile)->
    L1=status_hosts(HostFile),
    {ok,AllRunningHosts}=lists:keyfind(ok,1,L1),
    HostInfoList=[HostInfo||HostInfo<-AllRunningHosts,
			{host_id,HostId}==lists:keyfind(host_id,1,HostInfo)],
    R=case HostInfoList of
	  []->
	      {error,[eexist,HostId]};
	  [HostInfo|_]->
	      {host_id,HostId}=lists:keyfind(host_id,1,HostInfo),
	      {ip,Ip}=lists:keyfind(ip,1,HostInfo),
	      {ssh_port,Port}=lists:keyfind(ssh_port,1,HostInfo),
	      {uid,Uid}=lists:keyfind(uid,1,HostInfo),
	      {pwd,Pwd}=lists:keyfind(pwd,1,HostInfo),
	      ok=rpc:call(node(),my_ssh,ssh_send,[Ip,Port,Uid,Pwd,"rm -rf master",1000],5000),
%	      io:format("rm -rf master ~p~n",[{X1,?MODULE,?LINE}]),
	      ok=rpc:call(node(),my_ssh,ssh_send,[Ip,Port,Uid,Pwd,"mkdir master",1000],5000),
%	      io:format("mkdir  master ~p~n",[{X2,?MODULE,?LINE}]),
	      true=stop_vm(HostId,"master"),
%	      io:format("Stopped ~p~n",[{Stopped,?MODULE,?LINE}]),
	      ErlCmd="erl -detached -sname master -setcookie "++?Cookie,
	    %  ErlCmd="erl -detached -sname master -setcookie abc",
%	      io:format("Ip,Port,Uid,Pwd ~p~n",[{Ip,Port,Uid,Pwd,?MODULE,?LINE}]),
	      ok=rpc:call(node(),my_ssh,ssh_send,[Ip,Port,Uid,Pwd,ErlCmd,3000],7000),
%	      io:format("Started ~p~n",[{Started,?MODULE,?LINE}]),
	      case node_started(HostId,"master") of
		  true->
		      ok;
		  false ->
		      {error,[not_started,list_to_atom("master"++"@"++HostId)]}
	      end
      end,
    R.


%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
status_hosts(HostFile)->
    Reply=case filelib:is_file(HostFile) of
	      true->
		  {ok,HostInfoList}=file:consult(HostFile),
	%	  io:format("HostInfoList ~p~n",[{HostInfoList,?MODULE,?LINE}]),
		  host:status_hosts(HostInfoList);
	      false->
		  {error,[noexist,HostFile]}
	  end,
    Reply.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load_config(Dir,HostFile,GitCmd)->
    os:cmd("rm -rf "++Dir),
    os:cmd(GitCmd),
    Reply=case filelib:is_file(HostFile) of
	      true->
		  ok;
	      false->
		  {error,[noexist,HostFile]}
	  end,
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
read_config(HostFile)->
    Reply=case filelib:is_file(HostFile) of
	      true->
		  file:consult(HostFile);
	      false->
		  {error,[noexist,HostFile]}
	  end,
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

node_started(HostId,NodeName)->
    Vm=list_to_atom(NodeName++"@"++HostId),
    check_started(50,Vm,100,false).
    
check_started(_N,_Vm,_SleepTime,true)->
    true;
check_started(0,_Vm,_SleepTime,Result)->
    Result;
check_started(N,Vm,SleepTime,_Result)->
  %  io:format("N,Vm ~p~n",[{N,Vm,?MODULE,?LINE}]),
    NewResult=case net_adm:ping(Vm) of
		  pong->
		     true;
		  _Err->
		      timer:sleep(SleepTime),
		      false
	      end,
    check_started(N-1,Vm,SleepTime,NewResult).

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
stop_vm(HostId,VmId)->
    Vm=list_to_atom(VmId++"@"++HostId),
    stop_vm(Vm).

stop_vm(Vm)->
    rpc:cast(Vm,init,stop,[]),
    vm_stopped(Vm).

vm_stopped(Vm)->
    check_stopped(50,Vm,100,false).
    
check_stopped(_N,_Vm,_SleepTime,ok)->
    ok;
check_stopped(0,_Vm,_SleepTime,Result)->
    Result;
check_stopped(N,Vm,SleepTime,_Result)->
    NewResult=case net_adm:ping(Vm) of
		  pang->
		     true;
		  _Err->
		      timer:sleep(SleepTime),
		      false
	      end,
    check_stopped(N-1,Vm,SleepTime,NewResult).

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

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
