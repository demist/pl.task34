-module(transactions_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-spec get_timestamp() -> integer().
get_timestamp() ->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega*1000000 + Sec)*1000 + round(Micro/1000).

start_link() ->
    gen_server:start_link({global, transactions_server}, transactions_server, [], []).

parse([]) -> [];

parse([[{Key, First}] | Rest]) ->
    Left = parse(Rest),
    Res = lists:append([{Key, First}], Left),
    Res.
    
init([]) ->
    Key = get_timestamp(),
    process_flag(trap_exit, true),
    {ok, Ref} = dets:open_file(d4, []),
    F = dets:match(Ref, '$1'),
    Res1 = parse(F),
    Res2 = lists:sort(fun({K1, _V1}, {K2, _V2}) -> K1 < K2 end, Res1),
    Res3 = lists:map(fun ({_, {[V]}}) -> V end, Res2),
    {ok, {Key, Res3, Ref}}.  
    
handle_call(history, _From, {Key, State, Ref}) ->
    {reply, State, {Key, State, Ref}};
   
handle_call(_Message, _From, {Key, State, Ref}) ->
    {reply, invalid_command, {Key, State, Ref}}.
    
handle_cast({widthdraw, Amount}, {Key, State, Ref}) ->
    NewState = lists:append(State, Amount),
    NewKey = Key + 1,
    dets:insert(Ref, {NewKey, {Amount}}),
    {noreply, {NewKey, NewState, Ref}};
    
handle_cast(clear, {_Key, _State, Ref}) ->
    NewState = [],
    ok = dets:delete_all_objects(Ref),
    NewKey = get_timestamp(),
    {noreply, {NewKey, NewState, Ref}};

handle_cast(_Message, State) -> {noreply, State}.      

handle_info(_Message, State) -> {noreply, State}.

terminate(_Reason, {_Key, _State, Ref}) -> 
    dets:close(Ref),
    ok.

code_change(_OldVersion, State, _Extra) -> {ok, State}.