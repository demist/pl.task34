-module(atm_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link(atm_sup, []).
    
init(_Args) ->
    Children =  [{atm_server, {atm_server, start_link, []}, permanent, 5000, worker, []},
	{transactions_server, {transactions_server, start_link, []}, permanent, 5000, worker, []}],
    MaxRestart = 10,
    RestartTime = 5,
    Settings = {one_for_one, MaxRestart, RestartTime},
    SupervisorSpecs = {Settings, Children},
    {ok, SupervisorSpecs}.