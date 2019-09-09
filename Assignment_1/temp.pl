:- dynamic(kb/1).

makeKB(File):- open(File,read,Str),
               readK(Str,K), 
               reformat(K,KB), 
               asserta(kb(KB)), 
               close(Str).                  
   
readK(Stream,[]):- at_end_of_stream(Stream),!.
readK(Stream,[X|L]):- read(Stream,X),
                      readK(Stream,L).

reformat([],[]).
reformat([end_of_file],[]) :- !.
reformat([:-(H,B)|L],[[H|BL]|R]) :- !,  
                                    mkList(B,BL),
                                    reformat(L,R).
reformat([A|L],[[A]|R]) :- reformat(L,R).
    
mkList((X,T),[X|R]) :- !, mkList(T,R).
mkList(X,[X]).

initKB(File) :- retractall(kb(_)), makeKB(File).

search([[Node, NCost, NPath]|_], Path, Cost, _) :- goal(Node), Cost=NCost, Path=NPath.
search([[Node, NCost, NPath]|Rest], Path, Cost, KB) :- findall([Next, NewCost, [Next|NPath]], (arc(Node, Next, Arcost, KB), NewCost is  Arcost+NCost), Children), 
                                                       pairNodes(Children, Rest, New), 
                                                       search(New, Path, Cost, KB).

add2frontier(FNode, [], New) :- New=[FNode].
add2frontier(H, [F|Rest], New) :- lessThan(H, F), !, New = [H,F|Rest]; add2frontier(H, Rest, FNew), New = [F|FNew].

pairNodes([H|[]], [], New) :- New = [H].
pairNodes([H|Children], [], New) :- pairNodes([H], Children, New).
pairNodes([], Rest, New) :- New = Rest.
pairNodes([H|T], Rest, New):- add2frontier(H, Rest, FNew), pairNodes(T, FNew, New).

astar(Node,Path,Cost) :- kb(KB), astar(Node,Path,Cost,KB).


member(X,[X|_]).
member(X,[_|R]) :- member(X,R).

arc([H|T],Node,Cost,KB) :- member([H|B],KB), append(B,T,Node),length(B,L), Cost is L+1.


heuristic(Node,H) :- length(Node,H).

goal([]).

lessThan([[Node1|_],Cost1],[[Node2|_],Cost2]) :-heuristic(Node1,Hvalue1), heuristic(Node2,Hvalue2),F1 is Cost1+Hvalue1, F2 is Cost2+Hvalue2,F1 =< F2.


astar(Node,Path,Cost,KB) :- search([[Node, 0, [Node]]], Path, Cost, KB).




