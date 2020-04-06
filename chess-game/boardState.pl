% Hold predicates that evalutate the board position value

position_play_value(player_position(Pawns, Rooks, Knights, Bishops, Queens, [_], _), Color, Value) :-
	pos_count(pawn, Pawns, Color, V1),		% get value for all pawns location
	pos_count(rook, Rooks, Color, V2),		% get value for all rooks location
	pos_count(bishop, Bishops, Color, V3),	% get value for all bishops location
	pos_count(knight, Knights, Color, V4),	% get value for all knights location
	pos_count(queen, Queens, Color, V5),	% get value for all the queens location
	double_bonus(Rooks, D1),				% give double bonus if both rooks are alive
	double_bonus(Knights, D2),				% give double bonus if both knights are alive
	double_bonus(Bishops, D3),				% give double bonus if both bishops are alive
	Value is V1+V2+V3+V4+V5+30*(D1+D2+D3).	% add up total value for this players position

double_bonus([_, _], 1) :- !.	% double bouns is given if there is both pieces
double_bonus(_, 0).				% no bonus point for only one piece

pos_count(_, [], _, 0) :- !.
pos_count(PieceType, [OnePiece|Rest], Color, Value) :-
	pos_count(PieceType, Rest, Color, V2),
	pos_value(PieceType, OnePiece, Color, V1),
	Value is V1+V2, !.

pos_value(PieceType, Position, black, Value) :-									% this allows for black side to calculate moves
	New_Position is 99-Position,												% invert numbers so 88 = 22.
	pos_value(PieceType, New_Position, white, Value), !.

pos_value(PieceType, Pos, white, Value) :-
	row(Pos, Row),
	member(PieceType, [bishop, queen]),
	row_value(PieceType, Row, Value), !.
pos_value(pawn, Pos, white, 125) :-
	member(Pos, [34, 35]), !.
pos_value(pawn, Pos, white, 135) :-
	member(Pos, [44, 45, 54, 55]), !.
pos_value(pawn, Pos, white, 150) :-
	row(Pos, Row),
	member(Row, [7]), !.
pos_value(pawn, _, white, 100) :- !.

pos_value(king, Pos, white, 25) :-			% 30
	member(Pos, [11, 12, 13, 17, 18]), !.
pos_value(rook, _, white, 500) :- !.
pos_value(PieceType, Pos, white, Value) :-
	PieceType=knight,
	row_line(Pos, Row, Line),
	row_value(PieceType, Row, V1),
	line_value(PieceType, Line, V2),
	Value is V1+V2, !.

row_value(knight, 2, 315) :- !.
row_value(knight, 3, 325) :- !.
row_value(knight, X, 350) :-
	member(X, [4, 5]), !.
row_value(knight, X, 375) :-
	member(X, [6, 7]), !.
row_value(knight, _, 300) :- !.
row_value(bishop, 1, 300) :- !.
row_value(bishop, X, 330) :-
	member(X, [2, 3]), !.
row_value(bishop, _, 335) :- !.
row_value(queen, 1, 850) :- !.
row_value(queen, _, 875) :- !.

line_value(knight, X, 0) :-
	member(X, [1, 8]), !.
line_value(knight, _, 10) :- !.

row(Pos, Row) :-
	Row is Pos // 10.
row_line(Pos, Row, Line) :-
	Row is Pos // 10,
	Line is Pos mod 10.
