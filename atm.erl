-module(atm).
-export([withdraw/2, gen/6]).

withdraw(Amount, Banknotes) ->
    Vars = genpossible(Amount, Banknotes).
    
    
genpossible(Amount, Banknotes) ->
    gen(0, 0, [], Banknotes, Amount, []).

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