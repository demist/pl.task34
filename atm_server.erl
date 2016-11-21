-module(atm_server).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
    
init([]) ->
    State = [5000, 50, 50, 50, 1000, 5000, 1000, 500, 100],
    {ok, State}.
    
handle_call({widthdraw, Amount}, _From, State) ->
    try atm:widthdraw(Amount, State) of
      {Status, Banks, RestBanks} -> {reply, {Status, Banks}, RestBanks}
    catch
      error:X -> {stop, normal, State}
    end;
    
handle_call(_Message, _From, State) ->
    {reply, invalid_command, State}.
    
handle_cast(_Message, State) -> {noreply, State}.

handle_info(_Message, State) -> {noreply, State}.

terminate(_Reason, _State) -> 
    ok.

code_change(_OldVersion, State, _Extra) -> {ok, State}.

