/*
Each white piece has a position-play contribution and so does the black king. All must be added up to give the position-play value.
	For a Q, R, B, KT count
		1) The square root of the number of moves the piece can make form the position, counting a capture as two moves, and not forgetting that the king must not be left in check.
		2) (if not a Q) 1.0 if it is defended, and an additional 0.5 if twice defended.
	For a K, count
		1) For moves other than castling as 1) above.
		2) It is then necessary to make some allowance for the vulnerability of the king.
            This can be done by assuming it to be replaced by a friendly Q on the same square, estimating it as in 1), but subtracting instead of adding.
		3) 1.0 for the possibility of castling later not being lost by moves of K or R, a further 1.0 if castling could take place on the next move,
            and yet another 1.0 for the actual performance of castling.
	For a P, count
		1) 0.2 for each rank advanced
		2) 0.3 for being defended by at least one piece (not P)
	For black K, count
		1) 1.0 for the threat of checkmate
		2) 0.5 for check
(Note) No 'analysis' in involved in the position-play evaluation. In order to reduce the amount of work on deciding the move..
*/

moves(Value, knight, Position, NewVal) :-
    get_player_pos(Position, player_position(_, _, Knights, _, _, _, _), white),
    member(From, Knights),
    possible_moves(knight, Dir),
    To is Dir + From,
    ( not(occupied(To, white, Position))
        ->not(invalid_field(To)),
        writeln('knight move'),
        increment(Value, NewVal), fail                                         % this line and what is stopping the running of the main loop?
        ;writeln('ignore'), fail
    ).

moves(Value, bishop, Position, NewVal) :-
    get_player_pos(Position, player_position(_, _, _, Bishops, _, _, _), white),
    member(From, Bishops),
    possible_moves(bishop, Dir),
    To is Dir + From,
    ( not(occupied(To, white, Position))
        ->not(invalid_field(To)),
        writeln('bishop move'), fail
        % increment(Value, NewVal), !                                          % this line not properly incrementing & somethiing is stopping the running of the main loop?
        ;writeln('ignore'), fail
    ).

increment(Val, NewVal) :-
     NewVal is Val + 1,
     writeln(NewVal).

list_length([], 0).
list_length([_|Xs], L) :-
    list_length(Xs, N),
    L is N+1.
