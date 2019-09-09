%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GIVEN


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

astar(Node, Path, Cost) :- kb(KB), astar(Node, Path, Cost, KB).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GIVEN

lessThan([Node1,Cost1|_], [Node2,Cost2|_]) :- heuristic(Node1, Hvalue1), 
                                              heuristic(Node2, Hvalue2), 
                                              F1 is Cost1+Hvalue1, 
                                              F2 is Cost2+Hvalue2, 
                                              F1 =< F2.
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GIVEN

arc([H|T], Node, Cost, KB) :- member([H|B], KB), append(B, T, Node), length(B,L), Cost is L+1.

heuristic(Node, H):- length(Node, H).

goal([]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                               
pair([H|[]], [], New) :- New = [H].
pair([H|ChildNodes], [], New) :- pair([H], ChildNodes, New).
pair([], Remaining, New) :- New = Remaining.
pair([H|T], Remaining, New):- add2frontier(H, Remaining, FrontNew), pair(T, FrontNew, New).

add2frontier(FrontierNode, [], New) :- New=[FrontierNode].
add2frontier(H, [Front|Remaining], New) :- lessThan(H, Front), !, New = [H,Front|Remaining]; add2frontier(H, Remaining, FrontNew), New = [Front|FrontNew].

astar(Node, Path, Cost, KB) :- find([[Node, 0, [Node]]], Path, Cost, KB).

find([[Node, NodeCost, PathToNode]|_], Path, Cost, _ ) :- goal(Node), Cost=NodeCost, Path=PathToNode.
find([[Node, NodeCost, PathToNode]|Remaining], Path, Cost, KB) :- findall([Next, NewCost, [Next|PathToNode]], (arc(Node, Next, ArcCost, KB), NewCost is  ArcCost+NodeCost), ChildNodes), 
                                                                  pair(ChildNodes, Remaining, New), 
                                                                  find(New, Path, Cost, KB).