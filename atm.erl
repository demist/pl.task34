-module(atm).
-export([widthdraw/2]).

widthdraw(_Amount, []) ->
    erlang:error(no_banknotes);

widthdraw(0, Banknotes) ->
    {ok, [], Banknotes};

widthdraw(Amount, Banknotes) ->
    Vars = gen(0, 0, [], Banknotes, Amount, []),
    {Status, Banks, Rest} = getResult(Amount, [], [], Vars, Banknotes),
    SortedBanks = lists:sort(fun(L, R) -> R < L end, Banks),
    {Status, SortedBanks, Rest}.
    
gen(_CurNumber, _CurAmount, _CurBanknotes, [], _Amount, _Unused) ->
    [];
gen(CurNumber, CurAmount, CurBanknotes, [FirstRest | Rest], Amount, Unused) ->
    NewUnused = lists:append(Unused, [FirstRest]),
    Without = gen(CurNumber, CurAmount, CurBanknotes, Rest, Amount, NewUnused),
    Predict = CurAmount + FirstRest,
    if
	Predict == Amount ->
	    ResNumber = CurNumber + 1,
	    ResBanknotes = lists:append(CurBanknotes, [FirstRest]),
	    ResRest = lists:append(Unused, Rest),
	    Res = lists:append(Without, [{ResNumber, ResBanknotes, ResRest}]);
	Predict < Amount ->
	    NewNumber = CurNumber + 1,
	    NewBanknotes = lists:append(CurBanknotes, [FirstRest]),
	    With = gen(NewNumber, Predict, NewBanknotes, Rest, Amount, Unused),
	    Res = lists:append(Without, With);
	Predict > Amount ->
	    Res = Without
    end,
    Res.

getResult(_Number, [], _RestBank, [], Banknotes) -> {request_another_amount, [], Banknotes};

getResult(_Number, CurBank, RestBank, [], _Banknotes) -> 
    {ok, CurBank, RestBank};

getResult(Number, CurBank, RestBank, [{NewNumber, NewRes, NewRest} | RestVars], Banknotes) ->
    if 
	NewNumber =< Number ->
	    Res = getResult(NewNumber, NewRes, NewRest, RestVars, Banknotes);
	NewNumber > Number ->
	    Res = getResult(Number, CurBank, RestBank, RestVars, Banknotes)
    end,
    Res.