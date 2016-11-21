-module(transactions_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({global, transactions_server}, transactions_server, [], []).
    
init([]) ->
    process_flag(trap_exit, true),
    {ok, Ref} = dets:open_file(mydata, []),
    State = dets:match(Ref, '$1'),
    {ok, {State, Ref}}.  
    
handle_call(history, _From, {State, Ref}) ->
    {reply, State, {State, Ref}};
   
handle_call(_Message, _From, {State, Ref}) ->
    {reply, invalid_command, {State, Ref}}.
    
handle_cast({widthdraw, Amount}, {State, Ref}) ->
    NewState = lists:append(State, Amount),
    dets:insert(Ref, {Amount}),
    {noreply, {NewState, Ref}};
    
handle_cast(clear, {_State, Ref}) ->
    NewState = [],
    {noreply, {NewState, Ref}};

handle_cast(_Message, State) -> {noreply, State}.      

handle_info(_Message, State) -> {noreply, State}.

terminate(_Reason, {_State, Ref}) -> 
    dets:close(Ref),
    ok.

code_change(_OldVersion, State, _Extra) -> {ok, State}.