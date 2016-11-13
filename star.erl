%% http://erlang.org/course/exercises.html
%% 3) Write a function which starts N processes 
%% in a star, and sends a message to each of them M 
%% times. After the messages have been sent the 
%% processes should terminate gracefully.
%% 
%% NOTES:
%% -- This solution makes the assumption the first           -- 
%% -- process created is the "centre" of the star, the main  -- 
%% -- process. This could easily be changed if needed, but   -- 
%% -- I'll leave it as is, since it fulfills it's            --   
%% -- learning/skill assessment purpose.                     -- 
%% --                                                        -- 
%% -- As far as I tested it, it works fine,                  -- 
%% -- but please feel free to say something in case you      -- 
%% -- want to suggest a solution.                            --   
%%
%% My github profile: https://github.com/michelbf


-module(star).
-export([start/3]).
-author(michelf).


start(NoProcesses, NoMessages, Message) when NoProcesses > 1 andalso NoMessages > 0 ->
	io:format(".~n.~n.~n.~n"),
	Seq = lists:seq(2, NoProcesses), % '1' is the first (main) process. So this list starts at 2 for the other processes.

	%Spawn main node:
	MainNode = spawn_link(fun() -> loop_main(1, Message, NoProcesses, NoMessages) end),
	io:format("Process created: ~w ~n",[MainNode]),

	%Spawn other nodes:
	ProcSeq = lists:map(fun(_) -> spawn_link(fun() -> loop_b(MainNode, Message, 1, NoMessages) end) end, Seq), 
	lists:map(fun(X) -> io:format("Process created: ~w ~n",[X]) end, ProcSeq),

	%Send msg to main node:
	MainNode ! {Message, ProcSeq}.


loop_main(M, Message, NoProcesses, NoMessages) ->
	receive
		{Message, ProcSeq} ->
			%This will send messages to all secondary nodes ("points" of the star):
			lists:map(fun(X) -> X ! {Message}, 
						io:format("Process ~w SENDING TO ~w. Message number ~w. ~n",[self(), X, M])
						end, ProcSeq),
			loop_main(1, Message, NoProcesses, NoMessages);
		{Message, From, no_exit} ->
			io:format("Process ~w SENDING TO ~w. ~n",[self(), From]),
			From ! {Message},
			loop_main(M, Message, NoProcesses, NoMessages);
		{Message, From, exit} ->
			%Receiving a message with "exit" atom means the child process has terminated.
			if M =:= NoProcesses-1 ->
				io:format("Main process ~w will now finish.~n.~n.~n.~n", [self()]);
			   M < NoProcesses ->
				From ! {Message},
				loop_main(M+1, Message, NoProcesses, NoMessages)
			end,
		ok
	end.


loop_b(MainNode, Message, M, NoMessages) ->
	receive
		{Message} ->
			if M =:= NoMessages ->
				io:format("Process ~w RESPONDING TO ~w and exiting. ~n",[self(), MainNode]),
				MainNode ! {Message, self(), exit};
			   true ->
				io:format("Process ~w RESPONDING TO ~w. Message number ~w. ~n",[self(), MainNode, M]),
				MainNode ! {Message, self(), no_exit},
				loop_b(MainNode, Message, M+1, NoMessages)
			end
	end.				

