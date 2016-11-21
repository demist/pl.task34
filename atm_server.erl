-module(atm_server).
-behaviour(gen_server).

-export([log/2, start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
    
start_link() ->
    gen_server:start_link({global, atm_server}, atm_server, [], []).
    
init([]) ->
    process_flag(trap_exit, true),
    State = [5000, 50, 50, 50, 1000, 5000, 1000, 500, 100],
    {ok, State}.
    
log(ok, Amount) ->
    gen_server:cast({global, transactions_server}, {widthdraw, [Amount]}),
    ok;
    
log(_Status, _Amount) ->
    ok.    
    
handle_call({widthdraw, Amount}, _From, State) ->
    try atm:widthdraw(Amount, State) of
      {Status, Banks, RestBanks} -> 
      log(Status, Amount),
      {reply, {Status, Banks}, RestBanks}
    catch
      error:_X -> {stop, normal, State}
    end;
    
handle_call(_Message, _From, State) ->
    {reply, invalid_command, State}.
    
handle_cast(_Message, State) -> {noreply, State}.

handle_info(_Message, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVersion, State, _Extra) -> {ok, State}.

