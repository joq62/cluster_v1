%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(clone_test).   
   
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
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),

    ?debugMsg("Start clone_test()"),
    ?assertEqual(ok,clone_test()),
    ?debugMsg("stop clone_test()"),

 

    
   
      %% End application tests
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
clone_test()->
    ?assertEqual(ok,my_ssh:ssh_send(?Ip,?SshPort,?Uid,?Pw,"rm -rf master",?TimeOut)),
    CloneMaster="git clone https://github.com/joq62/master.git ",
    ?assertEqual(ok,my_ssh:ssh_send(?Ip,?SshPort,?Uid,?Pw,CloneMaster,?TimeOut)),
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
