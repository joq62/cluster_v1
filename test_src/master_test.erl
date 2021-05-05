%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================
-define(Host,"c0").
-define(Master,list_to_atom("master@"++?Host)).
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("start setup ~n"),
    ok=setup(),
    io:format("stop setup ~n"),

    io:format("start date_test ~n"),
    ok=date_test(),
    io:format("stop date_test ~n"),

   io:format("start slaves ~n"),
    ok=slave_test(),
    io:format("stop slave_test ~n"),
       
      %% End application tests
    io:format("start cleanup ~n"),
    ok=cleanup(),
    io:format("stop cleanup ~n"),


    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
slave_test()->
    Slaves=["s1","s2","s3","s4"],
    % Remove slave dirs
    [rpc:call(?Master,os,cmd,["rm -rf "++Slave])||Slave<-Slaves],
    [rpc:call(?Master,file,make_dir,[Slave])||Slave<-Slaves],

    [{S1,{ok,Vm1}},
     {S2,{ok,Vm2}},
     {S3,{ok,Vm3}},
     {S4,{ok,Vm4}}
    ]=[{Slave,rpc:call(?Master,slave,start,[?Host,Slave,"-setcookie abc"])}||Slave<-Slaves],

    [Vm1,Vm2,Vm3,Vm4]=['s1@c0','s2@c0','s3@c0','s4@c0'],
    SlaveVms= [{S1,Vm1},{S2,Vm2},{S3,Vm3},{S4,Vm4}],
    CloneSupport="git clone https://github.com/joq62/support.git",
    [rpc:call(Vm,os,cmd,[CloneSupport++" "++Slave++"/support"])||{Slave,Vm}<-SlaveVms],
    [rpc:call(Vm,code,add_patha,[Slave++"/support/ebin"])||{Slave,Vm}<-SlaveVms],
    
    [ok,ok,ok,ok]=[rpc:call(Vm,application,start,[support])||{_Slave,Vm}<-SlaveVms],
    [{pong,'s1@c0',support},
     {pong,'s2@c0',support},
     {pong,'s3@c0',support},
     {pong,'s4@c0',support}]=[rpc:call(Vm,support,ping,[])||{_Slave,Vm}<-SlaveVms],
    
    
    
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
date_test()->
    Date=date(),
    Date=rpc:call(?Master,erlang,date,[]),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

setup()->
  
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
