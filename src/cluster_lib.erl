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
-define(Cookie,"abc").

-define(Uid,"joq62").
-define(Pw,"festum01").
-define(glurk,xxx).
%% --------------------------------------------------------------------


%% External exports
-export([start/0,
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
start()->
    ok=mnesia_start(),
    ok=load_git_config(),
    ok=start_master_nodes(),
    {ok,FirstHost}=start_mnesia_first_host(),
    
%Start mnesia local
   
    
    % Read config file and store in mnesia
    
     ok.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

start_mnesia_first_host()->
    Result=case db_hosts:read_all() of
	       []->
		   {error,[no_host_available,?MODULE,?FUNCTION_NAME,?LINE]};
	       [{Host,_Ip,_Port,_Uid,_Pw,Master,_Slaves}|T]->
		   %start first node 
		   
		   VmFirstMaster=list_to_atom(Master++"@"++atom_to_list(Host)),
		   stopped=rpc:call(VmFirstMaster, mnesia,stop,[]),	
		   ok=rpc:call(VmFirstMaster, mnesia,delete_schema,[[VmFirstMaster]]),
		   ok=rpc:call(VmFirstMaster, mnesia,start,[]),
		   {ok,VmFirstMaster}	   
	   end,
    Result.

			      
mnesia_start()->
    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start(),
    ok.

start_master_nodes()->
    ssh:start(),
    HostInfo=db_hosts:read_all(),     
    io:format("HostInfo= ~p~n",[HostInfo]),    
    R=[start_master(Host,Master,Ip,Port,Uid,Pw)||{Host,Ip,Port,Uid,Pw,Master,_Slaves}<-HostInfo],
    io:format("R= ~p~n",[{R,?MODULE,?FUNCTION_NAME,?LINE}]),
    ok.


start_master(Host,Master,Ip,Port,Uid,Pw)->
    ErlCmd="erl -sname "++Master++" -detached -setcookie "++?Cookie,
    TimeOut=3000,
    Start=my_ssh:ssh_send(Ip,Port,Uid,Pw,ErlCmd,TimeOut),
    timer:sleep(100),
    Vm=list_to_atom(Master++"@"++atom_to_list(Host)),
    Ping=net_adm:ping(Vm),
    io:format( "start_master =~p~n",[{Host,Master,Ip,Port,Uid,Pw,Ping,?MODULE,?FUNCTION_NAME,?LINE}]),
    {Start,Ping,Host,Vm}.

load_git_config()->
    GitPath=?HostConfigPath,
    FileName="host.config",
    ConfigDir="configs",
    File=filename:join(ConfigDir,FileName),      
    ok=db_hosts_config:create_table(),
    {atomic,ok}=db_hosts_config:create(FileName,GitPath,ConfigDir),
    case filelib:is_dir(ConfigDir) of
	true->
	    os:cmd("rm -rf "++File);
	false->
	    ok=file:make_dir(ConfigDir)
    end,
    % and Load from github and store mnesia 
    os:cmd("rm -rf "++ConfigDir),
    ok=db_hosts:create_table(),
    [{FileName,GitPath,ConfigDir}]=db_hosts_config:read(FileName),
    os:cmd("git clone "++GitPath++" "++ConfigDir),
    {ok,HostInfo}=file:consult(File),
    io:format("HostInfo= ~p~n",[{HostInfo,?MODULE,?FUNCTION_NAME,?LINE}]),
    [db_hosts:create(Host,Ip,Port,?Uid,?Pw,Master,SlaveVmIdList)||{{host_id,Host},
							    {ip,Ip},
							    {port,Port},
							    {master,Master},
							    {slaves,SlaveVmIdList}}<-HostInfo],
 
    
   ok.
    
create_lock()->
    timer:sleep(10),
    db_lock:create_table(),
    {atomic,ok}=db_lock:create(),
    [leader]=db_lock:read_all(),
    ok.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

initial_start()->
    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start().
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------


add_node(Vm)->
    Reply=case net_adm:ping(Vm) of
	      pong->
		  rpc:call(Vm,application,stop,[mnesia]),
		  ok=mnesia:delete_schema([Vm]),
		  case rpc:call(Vm,application,start,[mnesia]) of
		      ok->
			  io:format("Master is adding Node ~p~n",[{node(),Vm,?MODULE,?FUNCTION_NAME,?LINE}]),
			  case mnesia:change_config(extra_db_nodes, [Vm]) of
			      {ok,[Vm]}->
			    %  {ok,_}->
				  ok;
			      Err->
				  {error,[Err,Vm,?MODULE,?FUNCTION_NAME,?LINE]}
			  end;
		      Err->
			  {error,[Err,Vm,?MODULE,?FUNCTION_NAME,?LINE]}
		  end;
	      pang ->
		  {error,[not_running,Vm,?MODULE,?FUNCTION_NAME,?LINE]}
	  end,  
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

check_stopped_db_nodes()->
    case get_stopped_nodes() of
	[]->
	    ok;
	StoppedExtraDbNodes->
	    add_started_nodes(StoppedExtraDbNodes)
    end,
    get_stopped_nodes().


add_started_nodes([])->
    ok;
add_started_nodes([Vm|T])->
    initiate_added_node(Vm),
    timer:sleep(100),
    add_started_nodes(T).
	    
get_stopped_nodes()->
    ExtraDbNodes=mnesia:system_info(extra_db_nodes),
    RunningExtraDbNodes=lists:delete(node(),mnesia:system_info(running_db_nodes)),
    StoppedExtraDbNodes=[Node||Node<-ExtraDbNodes,
			     false==lists:member(Node,RunningExtraDbNodes)],
    StoppedExtraDbNodes.


create_table(Table,Args)->
    {atomic,ok}=mnesia:create_table(Table,Args),
    Tables=mnesia:system_info(tables),
    mnesia:wait_for_tables(Tables,?WAIT_FOR_TABLES).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
initiate_added_node(Vm)->
    Result=case net_adm:ping(Vm) of
	       pong->
		   stopped=rpc:call(Vm,mnesia,stop,[]),
		   ok=mnesia:delete_schema([Vm]),
		   ok=rpc:call(Vm,mnesia,start,[]),
		   {ok,[Vm]}=mnesia:change_config(extra_db_nodes, [Vm]);
	       pang ->
		   {error,[not_running,Vm]}
	   end,    
    Result.


%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

add_table(Vm,Table,StorageType)->
    mnesia:add_table_copy(Table,Vm,StorageType),
  %  [{Table,Args,_}]=db_gen_mnesia:read(Table),
    Tables=mnesia:system_info(tables),
    mnesia:wait_for_tables(Tables,?WAIT_FOR_TABLES).
    
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

