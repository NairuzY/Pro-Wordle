build_kb:-
	write('Please enter a word and its category on separate lines:'),nl,
	read(Word),
	nonvar(Word),
	(
		Word=done;
		( read(Category),
		assert(word(Word,Category)),
		build_kb )
	).
build_kb:-
	build_kb.



is_category(Category):- word(_,Category).

categories(List):- setof(Category,is_category(Category),List).

available_length(Length):- word(Word,_), atom_chars(Word,List), length(List,Length).


category_help:-
	write('Choose a category:'),nl,
	read(Category),
	categories(List),
	member(Category,List),
	assert(current_category(Category)).

category_help:-
	write('This category does not exist.'),nl,
	category_help.


length_help:-
	write('Choose a length:'),nl,
	read(Length),
	current_category(Category),
	pick_word(_,Length,Category), 
	assert(current_length(Length)).


length_help:-
	write('There are no words of this length.'),nl,
	length_help.



pick_word(Word,Length,Category):-
	is_category(Category),!,
	word(Word,Category),
	atom_chars(Word,WordList),
	length(WordList,Length).
 


correct_letters2(S1,S2,LF):-
             atom_chars(S1,L1),
             atom_chars(S2,L2),
             correct_letters(L1,L2,L),
	     remove_duplicates(L,LF).
correct_letters([],_,[]).
correct_letters([H|S1],S2,A):-
             \+member(H,S2),
             correct_letters(S1,S2,A). 
correct_letters([H|S1],S2,A):-
             member(H,S2),
             A = [H|AT],
             correct_letters(S1,S2,AT).
remove_duplicates([],[]).
remove_duplicates([H|T],L):-
    	     member(H,T), !,
             remove_duplicates(T,L).
remove_duplicates([H|T],[H|L]):-
             remove_duplicates(T,L).




correct_positions2(S1,S2,L):-
	atom_chars(S1,L1),
	atom_chars(S2,L2),
	correct_positions(L1,L2,L).
correct_positions([],[],[]).
correct_positions([H|T1], [H|T2], [H|TR]):-
	correct_positions(T1,T2,TR).
correct_positions([H1|T1], [H2|T2], TR):-
	H1\=H2,
	correct_positions(T1,T2,TR).



word_length(Word,Length):- atom_chars(Word,List),length(List,Length).


guessing(Word,Length,1):-
	nl,
	write('Enter a word composed of '),
	write(Length),
	write(' letters:'),nl,
	read(Guess),
	(	( Guess = Word,
		write('You Won!') );
		write('You lost!')
	).

guessing(Word,Length,Guesses):- 
	Guesses>1,
	nl,
	write('Enter a word composed of '),
	write(Length),
	write(' letters:'),nl,
	read(Guess),

	(	( word_length(Guess,X),X =\= Length,
		write('Word is not composed of '), write(Length), write(' letters. Try again.'),nl,
		write('Remaining Guesses are '),
		write(Guesses),nl,
		guessing(Word,Length,Guesses) );
		( Guess = Word,
		write('You Won!') );
		( correct_letters2(Guess,Word,CorrectLetters),
		write('Correct letters are: '),
		write(CorrectLetters),nl,
		correct_positions2(Guess,Word,CorrectPositions),
		write('Correct letters in correct positions are: '),
		write(CorrectPositions),nl,
		write('Remaining Guesses are '),
		NewGuesses is Guesses-1,
		write(NewGuesses),nl,
		guessing(Word,Length,NewGuesses) )
	).


play:-
	write('The available categories are: '),
	categories(List),
	write(List), nl,
	category_help,
	length_help,
	current_category(Category),
	current_length(Length),
	Guesses is Length+1,
	pick_word(Word,Length,Category),
	retract(current_category(Category)),
	retract(current_length(Length)),
	write('Game started. You have '),
	write(Guesses),
	write(' guesses.'),nl,
	guessing(Word,Length,Guesses).


main:- 
	write('Welcome to Pro-Wordle!'), nl,
	write('----------------------'), nl,
	build_kb,nl,
	write('Done building the words database…'),nl,
	nl,
	play. 