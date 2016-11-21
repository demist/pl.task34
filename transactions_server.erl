-module(transactions_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({global, transactions_server}, transactions_server, [], []).
    
init([]) ->
    process_flag(trap_exit, true),
    State = [],
    {ok, State}.  
    
handle_call(history, _From, State) ->
    {reply, State, State};
   
handle_call(_Message, _From, State) ->
    {reply, invalid_command, State}.
    
handle_cast({widthdraw, Amount}, State) ->
    NewState = lists:append(State, Amount),
    {noreply, NewState};
    
handle_cast(clear, _State) ->
    NewState = [],
    {noreply, NewState};

handle_cast(_Message, State) -> {noreply, State}.      

handle_info(_Message, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVersion, State, _Extra) -> {ok, State}.