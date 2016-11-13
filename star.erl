%% http://erlang.org/course/exercises.html
%% 3) Write a function which starts N processes 
%% in a star, and sends a message to each of them M 
%% times. After the messages have been sent the 
%% processes should terminate gracefully.
-module(star).
-export([start/3]).

start(NoProcesses, NoMessages, Message) when NoProcesses > 1 andalso NoMessages > 0 ->
	Seq = lists:seq(2, NoProcesses),

	MainNode = spawn_link(fun() -> loop_main(1, Message, NoProcesses, NoMessages) end),
	io:format("Process created: ~w ~n",[MainNode]),

	ProcSeq = lists:map(fun(X) -> spawn_link(fun() -> loop_b(MainNode, Message, 1, X, NoMessages) end) end, Seq), %id (X) not needed?
	lists:map(fun(X) -> io:format("Process created: ~w ~n",[X]) end, ProcSeq),

	MainNode ! {Message, ProcSeq}.


loop_main(M, Message, NoProcesses, NoMessages) ->
	receive
		{Message, ProcSeq} ->
			lists:map(fun(X) -> X ! {Message, ProcSeq}, 
						io:format("Process ~w SENDING TO ~w. Message number ~w. ~n",[self(), X, M])
						end, ProcSeq),
			loop_main(length(ProcSeq), Message, NoProcesses, NoMessages);
		{Message, From, ProcSeq} ->
			if M < NoMessages*NoProcesses ->
				io:format("Process ~w SENDING TO ~w. ~n",[self(), From]),
				From ! {Message, ProcSeq},
				loop_main(M+1, Message, NoProcesses, NoMessages);
			   M =:= NoMessages*NoProcesses ->
				io:format("Finish.")
			end,
		ok
	end.


loop_b(MainNode, Message, M, Id, NoMessages) ->
	receive
		{Message, ProcSeq} ->
			if M =:= NoMessages ->
				io:format("Process ~w RESPONDING TO ~w and exiting. ~n",[self(), MainNode]),
				MainNode ! {message, self(), ProcSeq};
			   M < NoMessages ->
				io:format("Process ~w RESPONDING TO ~w. Message number ~w. ~n",[self(), MainNode, M]),
				MainNode ! {message, self(), ProcSeq},
				loop_b(MainNode, Message, M+1, Id, NoMessages)
			end
	end.				

