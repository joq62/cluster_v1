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
	 status_hosts/1

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
