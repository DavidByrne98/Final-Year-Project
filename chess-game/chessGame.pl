% FYP chess game modelled on Alan Turings chess playing paper 'faster than thought'
% Main file

% Calling other files
:-[fileIO].
:-[moveLogic].
:-[helperFunctions].
:-[boardState].
% :-[positionPlayValue]. % file used to test Turing's heuristic

% Dynamic Predicates that can be accessed and changed during execution
:- dynamic
	stack/2,
	top/1,
	human/1,
	depth/1,
	board/2,
	lastMove/1.

beginGame :-
	start_position(Position),	% set the position value to be the start position
	asserta(top(0)),			% Set top to be 0
	gameType,					% Set difficulty
	game_loop(Position, white).	% Main loop

gameType :-
	writeln('To play as black enter 1.'),
	writeln('To play as white enter 2.'),
	get_input(Color),						% get the input from the terminal
	set_color(Color),						% set the color based on the input from the user
	write('Easy enter: 1'), nl,
	write('Medium enter: 2'), nl,
	write('Hard enter: 3'), nl,
	write('Very Hard enter: 4 (long load times)'), nl,
	get_input(Depth),						% get the input from the terminal
	set_depth(Depth).						% set the depth that the tree will be searched

% game_loop: chess main loop,  Start and Opposite take turns
game_loop(BasicPosition, Start) :-
	asserta(board(BasicPosition, Start)),     				% enter initial board position and player color into database
	write('Enter moves like: a2a4.'), nl,
	write('To quit enter: exit.'), nl,
	repeat,
		retract(board(Position, Color)),          			% get last board position state and color
		(
			are_kings_alive(Position) ->					% if kings are alive

				% attempting to use Turing's method
				% moves(Value, knight, Position, Val),		% Count number of moves available to knights
				% write(Val), nl,
				% moves(Value, bishop, Position, Val),		% Count number of moves available to bishops
				% write(Val), nl,

				enter(Position, Color, Move),				% recieve next move from computer or player
				make_move(Color, Position, Move, New, _),	% execute the move
				swap(Color, Opponent),						% change player
				asserta(board(New, Opponent)),              % store current board position state and color
				fail
			;
				write_winner(Position),						% print winner
				halt
		).

% enter: given Position and Color and Move,  return a Move from human or computer
enter(Position, Color, Move) :-
	human(Color),											% check if color is human if not got to other enter
	repeat,													% loop
		read_move(Move),									% read move from file
		(
			check_possible(Move, Color, Position), !		% check if move is possible
		;
			write('Invalid move.'), nl,
			sleep(1),
			nl, fail
		).
enter(Position, Color, Move) :-								% computer move
	depth(Depth), !,										% get the depth to search
	worst_value(white, Alpha),								% set alpha and beta as worst case
	worst_value(black, Beta),
	evaluate(Position, Color, Value, Move, Depth, Alpha, Beta),	% evaluate the best move to make

	% check_move(Move),						% attempted to stop a dead position by picking random move
	% asserta(lastMove(Move)),

	write_move(Move), !.									% write move to file

% check_move(Move) :-
% 	member(Move, retact(lastMove(M)))

% read_move: read user input from file
read_move(move(From, To)):-
	% read(Input), % For use in terminal
	open('file.txt', read, Str),	% open text stream
	read_file(Str, Input),			% call read file
	(
		[Head|_] = Input,			% take only the first item in the list. Second item is an end of file character
		Head = 'exit',				% if head = exit exit swipl
		% Input = 'exit',
	  	halt
	;
		[Head|_] = Input, 			% take only the first item in the list. Second item is an end of file character
	    name(Head, [A, B, C, D]),	% split the move into individual atom for each coordinate
	  	position_toString([A, B], From),	% change form ascii char to byte
	  	position_toString([C, D], To), !	% change form ascii char to byte
	;
	  	write('Incorrect move format please re-enter move like: a2a4.'), nl,
		sleep(3),
		fail
	).

% make_move: get New position from Old position and Move,
make_move(Color, Old, move(From, To), New, hit):-		% makes the move on the chessboard (non visible chessboard dicated by the invalid_field)
	swap(Color, Oppo),									% get the other player color
	take(Old, Oppo, To, Temp),							% checks if there is a piece in the 'to' position and removes it
	change(Temp, Color, From, To, New), !.				% moves the piece from the 'from' position to the 'to' position
make_move(Color, Old, move(From, To), New, nohit):-
	check_00(Old, Color, From, To, Temp),				%
	change(Temp, Color, From, To, New), !.

% check_possible : check if Move is legal,  Move e.g. from(Pos1, Pos2)
check_possible(Move, Color, Position):-
	generate(PosMove, Color, Position, _, _),			% generate all moves
	Move = PosMove, !.									% check if move is in the possible moves

% generate: move(From, To),  Old: old position,  Hit:
generate(Move, Color, Old, New, Hit):-
	all_moves(Color, Old, Move),						% call all_moves which generates all moves
	make_move(Color, Old, Move, New, Hit).				% make the move that was generated

newdepth(_Depth, hit, NewDepth) :-
	top(X),												% get depth
	X < 4,												% check depth is less than 4
	NewDepth = 1, !.									% make the new depth 1
newdepth(Depth, _, NewDepth) :-
	NewDepth is Depth - 1, !.							% decrement depth

new_alpha_beta(white, Alpha, New_Alpha, Beta, Beta) :-	% alpha beta tree structure for white side
	get_0(_, Value),
	Value > Alpha,
	New_Alpha = Value, !.
new_alpha_beta(black, Alpha, Alpha, Beta, New_Beta) :-	% alpha beta tree structure for black side
	get_0(_, Value),
	Value < Beta,
	New_Beta = Value, !.
new_alpha_beta(_, Alpha, Alpha, Beta, Beta).

evaluate(position(player_position(_, _, _, _, _, [], _), _, _), _, Value, move(0, 0), _, _, _) :-	% if the player position does not have a king in it then give that move the winning value
	winning(black, Value), !.
evaluate(position(_, player_position(_, _, _, _, _, [], _), _), _, Value, move(0, 0), _, _, _) :-
	winning(white, Value), !.
evaluate(position(W, B, _), _, Value, move(0, 0), 0, _, _) :-		% get the ratio value of the two player position-play-values
	position_play_value(W, white, White),
	position_play_value(B, black, Black),
	Value is White/Black, !.										% calculate ratio
evaluate(Position, Color, Value, Move, Depth, Alpha, Beta) :-
	worst_value(Color, Worst),										% set worst alpha beta value based on color
	push(move(0, 0), Worst),
	not(get_best(Position, Color, Depth, Alpha, Beta)),
	pull(Move, Value), !.

get_best(Position, Color, Depth, Alpha, Beta) :-
	swap(Color, Opponent),											% get the opponent color
	generate(Move, Color, Position, New_Position,  Hit),			% generate all possible moves
	newdepth(Depth, Hit, New_Depth),								% get the new depth to search
	new_alpha_beta(Color, Alpha, New_Alpha, Beta, New_Beta),		%
	evaluate(New_Position, Opponent, Value, _, New_Depth, New_Alpha, New_Beta),
	compare_move(Move, Value, Color),
	cutting(Value, Color, Alpha, Beta),
	!, fail.

% true if a piece is in From and moves to To
change(Old, Color, From, To, New) :-
	get_player_pos(Old, Half, Color),
	exist(From, Half, Type),
	extract(Half, Type, List),
	remove(From, List, Templist),
	combine(Half, Type, [To|Templist], Newhalf),
	combine_half(Old, Newhalf, Color, New).

% true if there is a piece in the Field and remove it
take(Old, Color, Field, New) :-
	get_player_pos(Old, Half, Color),
	exist(Field, Half, Type),
	extract(Half, Type, List),
	remove(Field, List, Newlist),
	combine(Half, Type, Newlist, Newhalf),
	combine_half(Old, Newhalf, Color, New).

% castling
check_00(Old, white, 15, 17, New) :-
	Old=position(player_position(_, _, _, _, _, [15], _), _, _),
	change(Old, white, 18, 16, New), !.
check_00(Old, white, 15, 13, New) :-
	Old=position(player_position(_, _, _, _, _, [15], _), _, _),
	change(Old, white, 11, 14, New), !.
check_00(Old, black, 85, 87, New) :-
	Old=position(_, player_position(_, _, _, _, _, [85], _), _),
	change(Old, black, 88, 86, New), !.
check_00(Old, black, 85, 83, New) :-
	Old=position(_, player_position(_, _, _, _, _, [85], _), _),
	change(Old, black, 81, 84, New), !.
check_00(Old, _, _, _, Old).

% position e.g. 42 to string ["d", "2"]
position_toString([L, C], Pos) :-
	nonvar(Pos), 	% Pos known
	convert_position_num(Row, Col, Pos),
	L is Col + 96, 	% int to char
	C is Row + 48, !.
position_toString([L, C], Pos) :-
	Col is L - 96, 	% char to int (char is used as ascii character code number)
	Row is C - 48,
	convert_position_num(Row, Col, Pos), !.

% position e.g. (2, 2) to no 22
convert_position_num(Row, Col, N) :-
	nonvar(N), !,
	Row is N // 10,
	Col is N mod 10.
convert_position_num(R, C, N) :-
	N  is  R*10 + C.

% write_move : print move to screen.
write_move(move(From, To)) :-
	position_toString([A, B], From),
	position_toString([C, D], To),
	name(Move, [A, B, C, D]),
	write("Computer move: "),
	write_to_file(Move),
	writeln(Move), nl, !.

% replace(ListOld,  Index,  ReplacedBy,  ListNew)
replace([_|T],  1,  X,  [X|T]).
replace([H|T],  I,  X,  [H|R]) :-
	I > 1,
	NI is I-1,
	replace(T,  NI,  X,  R),  !.
replace(L,  _,  _,  L).
