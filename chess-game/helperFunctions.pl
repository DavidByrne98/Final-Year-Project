% Helper functions for chess game

% initialize the start_postion of the chessboard i.e. set the location of all of the pieces
start_position(position(P1, P2, 0)):-
	PawnWhite = [21, 22, 23, 24, 25, 26, 27, 28],
	P1 = player_position(PawnWhite, [11, 18], [12, 17], [13, 16], [14], [15], notmoved),
	PawnBlack = [71, 72, 73, 74, 75, 76, 77, 78],
	P2 = player_position(PawnBlack, [81, 88], [82, 87], [83, 86], [84], [85], notmoved).

get_input(I):-
	get(Input),
	I is Input - 48,					% convert from ascii to decimal i.e. ascii char 1 to decimal 1 (as the ascii char is sent as a number)
	I > 0, I < 5, !.					% limit range of acceptable inputs
get_input(I):- get_input(I).

set_depth(D) :-
	asserta(depth(D)).					% enter depth into depth database

set_color(1) :-
	asserta(human(black)).				% enter player color into database
set_color(2) :-
	asserta(human(white)).
set_color(3).							% enter no value for player color (this makes there be two computers)

are_kings_alive(position(W, B, _)) :-	% get and call both player_positions and check if their kings are alive
	king_alive(W),
	king_alive(B).

king_alive(player_position(_, _, _, _, _, K, _)) :-
	length(K, 1).									% check if king is present i.e. length of list is not 0

write_winner(Position) :-				% writes winner to the terminal
	write('Game Over'),  nl,
	winner(Position, Winner),
	write(Winner),
	write(' wins'),  nl.

winner(position(W, _, _),  white) :- king_alive(W).	% get winner depending on if the king is taken
winner(position(_, B, _),  black) :- king_alive(B).

worst_value(white, -10000). % for alpha beta
worst_value(black,  10000). % for alpha beta

winning(white,  10000).		% value for winning a game (large value to make sure computer chooses it)
winning(black, -10000).		% value to make sure computer tries not to loose

compare_move(_, Value, white) :-
	get_0(_, Old),
	Old>=Value, !.
compare_move(_, Value, black) :-
	get_0(_, Old),
	Old =< Value, !.
	replace(Move, Value).
	compare_move(Move, Value, _) :-

cutting(Value, white, _, Beta) :-
	Beta<Value.
cutting(Value, black, Alpha, _) :-
	Alpha>Value.

% check if X is an invalid position (this predicate sets the size and type of board i.e. this is 10 x 10 with the first and last column / row cut off)
% this allows for simpler arithmatic. i.e. one row forward = +10 instead of +8 in an 8x8 board
invalid_field(X):-
	X =< 10, !.
invalid_field(X):-
	X >= 89, !.
invalid_field(X):-
	0 is X mod 10, !.
invalid_field(X):-
	9 is X mod 10, !.

% exist: check if there is a piece of certain half in the field
% check if there is a certain piece in the field
exist(Field, player_position(X, _, _, _, _, _, _), pawn):- member(Field, X).
exist(Field, player_position(_, X, _, _, _, _, _), rook):- member(Field, X).
exist(Field, player_position(_, _, X, _, _, _, _), knight):- member(Field, X).
exist(Field, player_position(_, _, _, X, _, _, _), bishop):- member(Field, X).
exist(Field, player_position(_, _, _, _, X, _, _), queen):- member(Field, X).
exist(Field, player_position(_, _, _, _, _, X, _), king):- member(Field, X).

% swap: between black and white
% get opponent color
swap(F1, F2):-
	F1 = black,
	F2 = white.
swap(F1, F2):-
	F1 = white,
	F2 = black.

% get_player_pos: get half position for one side
get_player_pos(position(P1, _, _), P1, white).
get_player_pos(position(_, P2, _), P2, black).

% combine_half: add the half positions
combine_half(position(_, Y, Z), Half, white, position(Half, Y, Z)).
combine_half(position(X, _, Z), Half, black, position(X, Half, Z)).

% occupied: true if there is a piece in the Field
occupied(Field, white, position(Stones, _, _)):- exist(Field, Stones, _).
occupied(Field, black, position(_, Stones, _)):- exist(Field, Stones, _).

% unoccupied: true if the position is valid and not occupied by any piece
unoccupied(Field, Position):-
	not(occupied(Field, white, Position)),
	not(occupied(Field, black, Position)),
	not(invalid_field(Field)).

% extract: extract certain type of pieces from half position
extract(player_position(X, _, _, _, _, _, _), pawn, X).
extract(player_position(_, X, _, _, _, _, _), rook, X).
extract(player_position(_, _, X, _, _, _, _), knight, X).
extract(player_position(_, _, _, X, _, _, _), bishop, X).
extract(player_position(_, _, _, _, X, _, _), queen, X).
extract(player_position(_, _, _, _, _, X, _), king, X).

% combine: combine new piece list with original player position
combine(player_position(_, B, C, D, E, F, G), pawn, N, player_position(N, B, C, D, E, F, G)).
combine(player_position(A, _, C, D, E, F, G), rook, N, player_position(A, N, C, D, E, F, G)).
combine(player_position(A, B, _, D, E, F, G), knight, N, player_position(A, B, N, D, E, F, G)).
combine(player_position(A, B, C, _, E, F, G), bishop, N, player_position(A, B, C, N, E, F, G)).
combine(player_position(A, B, C, D, _, F, G), queen, N, player_position(A, B, C, D, N, F, G)).
combine(player_position(A, B, C, D, E, _, G), king, N, player_position(A, B, C, D, E, N, G)).

% remove(Elem,  List,  ListNew)
remove(X, [X|New], New):- !.
remove(X, [A|Old], [A|New]):- remove(X, Old, New).

push(Move, Value) :-
	retract(top(Old)),
	New is Old+1,
	asserta(top(New)),
	asserta(stack(Move, Value, New)), !.

pull(Move, Value) :-
	retract(top(Old)), !,
	New is Old-1,
	asserta(top(New)),
	retract(stack(Move, Value, Old)), !.

get(Move, Value, Depth) :-
	top(Top),
	Act is Top-Depth,
	stack(Move, Value, Act), !.

get_0(Move, Value) :-
	top(Top),
	stack(Move, Value, Top), !.

replace(Move, Value) :-
	top(Top),
	retract(stack(_, _, Top)),
	asserta(stack(Move, Value, Top)), !.
