-module(atm).
-export([withdraw/2]).

withdraw(Amount, Banknotes) ->
    Vars = gen(0, 0, [], Banknotes, Amount, []),
    Best = getResult(Amount, [], [], Vars, Banknotes),
    Best.
    
gen(CurNumber, CurAmount, CurBanknotes, [], Amount, Unused) ->
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

getResult(Number, [], RestBank, [], Banknotes) -> {get_another, [], Banknotes};

getResult(Number, CurBank, RestBank, [], Banknotes) -> {ok, CurBank, RestBank};

getResult(Number, CurBank, RestBank, [{NewNumber, NewRes, NewRest} | RestVars], Banknotes) ->
    if 
	NewNumber =< Number ->
	    Res = getResult(NewNumber, NewRes, NewRest, RestVars, Banknotes);
	NewNumber > Number ->
	    Res = getResult(Number, CurBank, RestBank, RestVars, Banknotes)
    end,
    Res.