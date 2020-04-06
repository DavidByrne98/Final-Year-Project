% Contains all of the move prdicates

% all_moves: generate all possible moves
all_moves(Color, Position, move(From, To)):-
	get_player_pos(Position, player_position(Pawn, _, _, _, _, _, _), Color),
	member(From, Pawn), 	% check From is Pawn  ? get from (position) of pawns
	pawn_move(From, Color, Position, To).
all_moves(Color, Position, move(From, To)):-
	get_player_pos(Position, player_position(_, Rook, _, _, _, _, _), Color),
	member(From, Rook),  	% check From is Rook
	long_move(From, Color, rook, Position, To).
all_moves(Color, Position, move(From, To)):-
	get_player_pos(Position, player_position(_, _, Knights, _, _, _, _), Color),
	member(From, Knights), 	% check From is Knight
	short_move(From, Color, knight, Position, To).
all_moves(Color, Position, move(From, To)):-
	get_player_pos(Position, player_position(_, _, _, Bishop, _, _, _), Color),
	member(From, Bishop), 	% check From is Bish
	long_move(From, Color, bishop, Position, To).
all_moves(Color, Position, move(From, To)):-
	get_player_pos(Position, player_position(_, _, _, _, Queen, _, _), Color),
	member(From, Queen), 	% check From is Queen
	long_move(From, Color, queen, Position, To).
all_moves(Color, Position, move(King, To)):-
	get_player_pos(Position, player_position(_, _, _, _, _, [King], _), Color),
	short_move(King, Color, king, Position, To).
all_moves(Color, Position, move(King, To)):-
	get_player_pos(Position, player_position(_, _, _, _, _, [King], _), Color),
	castling_move(Color, Position, King, To).

% long_move: move for long distance
long_move(From, Color, Typ, Position, To):-
	possible_moves(Typ, Direction),
	multiple_steps(From, Direction, To, Color, Position).
% short_move: move for one step
short_move(From, Color, Typ, Position, To):-
	possible_moves(Typ, Direction),
	one_step(From, Direction, To, Color, Position).

% possible_moves: (piece,  move value)
possible_moves(rook, 10).
possible_moves(rook, -10).
possible_moves(rook, 1).
possible_moves(rook, -1).
possible_moves(bishop, 9).
possible_moves(bishop, 11).
possible_moves(bishop, -9).
possible_moves(bishop, -11).
possible_moves(knight, 19).
possible_moves(knight, 21).
possible_moves(knight, 8).
possible_moves(knight, 12).
possible_moves(knight, -8).
possible_moves(knight, -12).
possible_moves(knight, -19).
possible_moves(knight, -21).
possible_moves(queen, X):-
	possible_moves(rook, X).
possible_moves(queen, X):-
	possible_moves(bishop, X).
possible_moves(king, X):-
	possible_moves(queen, X).

% pawn_move: rules of pawn's possible move
pawn_move(From, white, Position, To):-		% pawn take
	To  is  From + 9,
	occupied(To, black, Position).
pawn_move(From, white, Position, To):-		% pawn move
	To  is  From + 10,
	unoccupied(To, Position).
pawn_move(From, white, Position, To):-		% pawn take
	To  is  From + 11,
	occupied(To, black, Position).
pawn_move(From, white, Position, To):-		% pawn double move
	To  is  From + 20,
	Over  is  From + 10,
	unoccupied(To, Position),
	unoccupied(Over, Position),
	Row  is  From // 10,
	Row = 2.
pawn_move(From, black, Position, To):-
	To  is  From - 9,
	occupied(To, white, Position).
pawn_move(From, black, Position, To):-
	To  is  From - 10,
	unoccupied(To, Position).
pawn_move(From, black, Position, To):-
	To  is  From - 11,
	occupied(To, white, Position).
pawn_move(From, black, Position, To):-
	To  is  From - 20,
	Over  is  From - 10,
	unoccupied(To, Position),
	unoccupied(Over, Position),
	Row  is  From // 10,
	Row = 7.

% one_step: from From to Next through one step
one_step(From, Direction, Next, Color, Position):-
	Next is From + Direction,
	not(invalid_field(Next)),
	not(occupied(Next, Color, Position)).

% multiple_steps: from From to Next through one or multiple steps
multiple_steps(From, Direction, Next, Color, Position):-
	one_step(From, Direction, Next, Color, Position).							% move one place
multiple_steps(From, Direction, Next, Color, Position):-						% To Do
	one_step(From, Direction, To, Color, Position),
	swap(Color, Player2),														% get other player color
	get_player_pos(Position, Player2Position, Player2),							% get other player position
	not(exist(To, Player2Position, _)),											% check that move To is not a square with opponent piece on it
	multiple_steps(To, Direction, Next, Color, Position).

% short castling
castling_move(Color, Position, King, To):-										% only used for board evaluation
	(
		Color=white,
		King=15
		;
		Color=black,
		King=85
	),
	RookNew is King+1,
	To is King+2,
	Rook is King+3,
	get_player_pos(Position, player_position(_, Rooks, _, _, _, _, _), Color),
	member(Rook, Rooks),
	unoccupied(RookNew, Position),
	unoccupied(To, Position).

% long castling
castling_move(Color, Position, King, To):-
	(
		Color=white,
		King=15
		;
		Color=black,
		King=85
	),
	RookNew is King-1,
	To is King-2,
	Blank is King-3,
	Rook is King-5,
	get_player_pos(Position, player_position(_, Rooks, _, _, _, _, _), Color),
	member(Rook, Rooks),
	unoccupied(RookNew, Position),
	unoccupied(To, Position),
	unoccupied(Blank, Position).
