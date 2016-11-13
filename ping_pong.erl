%% http://erlang.org/course/exercises.html
%% 1. Write a function which starts 2 processes, 
%% and sends a message M times forewards and backwards 
%% between them. After the messages have been sent the 
%% processes should terminate gracefully.

-module(ping_pong).
-export([init/0]).

init() ->
	Pid_B = spawn_link(fun() -> b() end), %spawn(?MODULE, b, []), 
	spawn_link(fun() -> a(Pid_B, 5) end).         %spawn(?MODULE, a, [Pid_B, 5]).

a(Pid_B, 0) ->
	Pid_B ! we_are_finished,
	io:format("Process ~p finished.~n",[self()]), ok;

a(Pid_B, N) ->
	Pid_B ! {self(), generic_message},
	io:format("A sent a message to B!. Message n. ~p~n",[N]),
	receive
		generic_message -> 
			io:format("A received a message from B!.~n")
	end,
	a(Pid_B, N-1).

b() ->
	receive
		 {From, generic_message} -> 
		 	From ! generic_message,
		 	io:format("B has replied to A!.~n"),
		 	b();
		 we_are_finished ->
		 	io:format("Process ~p finished.~n",[self()]), ok	
	end.

