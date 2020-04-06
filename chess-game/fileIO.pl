% Contains the fucntions that control the file IO

write_to_file(Move) :-
	open('file.txt', write, Stream),
	write(Stream, '\''),
	write(Stream, Move),
	write(Stream, '\'.'),
	nl(Stream),
	close(Stream).

read_from_file() :-
	open('file.txt', read, Str),
	read_file(Str, Text),
	close(Str),
	writeln(Text).

read_file(Stream,[]) :-
	at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
	\+  at_end_of_stream(Stream),
	read(Stream, X),
	read_file(Stream, L).
