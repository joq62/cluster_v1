%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(support_mnesia_lib).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-import(lists, [foreach/2]).

-include_lib("stdlib/include/qlc.hrl").

%% --------------------------------------------------------------------
-record(generic_set,{
			key,
			value
		       }).
-record(generic_bag,{
			key,
			value
		       }).

%% External exports
-export([start/0,
	 set_create/2,
	 set_read_all/0,
	 set_key_read/1,
	 set_key_delete/1,
	 set_key_update/2
	]).

-export([
	 bag_create/2,
	 bag_read_all/0,
	 bag_key_read/1,
	 bag_key_delete/1,
	 bag_delete/2,
	 bag_key_update/3
	]).
-define(WAIT_FOR_TABLES,5000).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

start()->
%    misc_log:msg(log,
%		["Line ="],
%		 node(),?MODULE,?LINE),

    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start(),

    mnesia:create_table(generic_set,[{attributes, record_info(fields,generic_set)}]),
    mnesia:wait_for_tables([generic_set], 20000),
    mnesia:create_table(generic_bag,[{attributes, record_info(fields,generic_bag)},
			    {type,bag}]),
    mnesia:wait_for_tables([generic_bag], 20000),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
set_create(Key,Value)->
    Record=#generic_set{
	      key=Key,
	      value=Value},
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).

set_read_all()->
    Z=do(qlc:q([X || X <- mnesia:table(generic_set)])),
    [{Key,Value}||{generic_set,Key,Value}<-Z].

set_key_read(Key) ->
    Z=do(qlc:q([X || X <- mnesia:table(generic_set),
		   X#generic_set.key==Key])),
    [{generic_set,_,Value}]=Z,
    Value.

set_key_delete(Key)->
    F = fun() -> 
		Deployment=[X||X<-mnesia:read({generic_set,Key}),
			       X#generic_set.key==Key],
		case Deployment of
		    []->
			mnesia:abort(generic_set);
		    [S1]->
			mnesia:delete_object(S1) 
		end
	end,
    mnesia:transaction(F).
set_key_update(Key,Value)->
    set_create(Key,Value).

%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
bag_create(Key,Value)->
    Record=#generic_bag{
	      key=Key,
	      value=Value},
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).

bag_read_all()->
    Z=do(qlc:q([X || X <- mnesia:table(generic_bag)])),
    [{Key,Value}||{generic_bag,Key,Value}<-Z].

bag_key_read(Key) ->
    Z=do(qlc:q([X || X <- mnesia:table(generic_bag),
		   X#generic_bag.key==Key])),
    [Value||{generic_bag,_Key,Value}<-Z].

bag_key_delete(Key)->
    F = fun() -> 
		Deployment=[X||X<-mnesia:read({generic_bag,Key}),
			       X#generic_bag.key==Key],
		case Deployment of
		    []->
			mnesia:abort(generic_bag);
		    Objects->
			[mnesia:delete_object(Obj)||Obj<-Objects] 
		end
	end,
    mnesia:transaction(F).
bag_delete(Key,Value)->
    F = fun() -> 
		Deployment=[X||X<-mnesia:read({generic_bag,Key}),
			       X#generic_bag.key==Key,
			       X#generic_bag.value==Value],
		case Deployment of
		    []->
			mnesia:abort(generic_bag);
		    [S1]->
			mnesia:delete_object(S1) 
		end
	end,
    mnesia:transaction(F).
bag_key_update(Key,OldValue,NewValue)->
    F = fun() -> 
		Deployment=[X||X<-mnesia:read({generic_bag,Key}),
			       X#generic_bag.key==Key,
			       X#generic_bag.value==OldValue],
		case Deployment of
		    []->
			mnesia:abort(generic_bag);
		    [S1]->
			mnesia:delete_object(S1), 
			 Record=#generic_bag{
				   key=Key,
				   value=NewValue},
			mnesia:write(Record) 
		end
	end,
    mnesia:transaction(F).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create_gen_bag(Key,Value)->
    Record=#generic_bag{
	      key=Key,
	      value=Value},
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

