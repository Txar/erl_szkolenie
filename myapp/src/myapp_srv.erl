-module(myapp_srv).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, service/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("Started"),
    {ok, started}.

handle_call(Args, From, OldState) ->
    io:format("A:~p~n:B~p~n:C~p~n",[Args, From, OldState]),
    io:format("Received call"),
    {reply, operation(lists:nth(1, Args), lists:nth(3, Args), lists:nth(2, Args)), ok}.

operation(A, B, '+') ->
    A + B;

operation(A, B, '-') ->
    A - B;

operation(A, B, '*') ->
    A * B;

operation(A, B, '/') ->
    A / B.

handle_cast(Args, B) ->
    io:format("Received cast"),
    {noreply, ok}.

service() ->
    gen_server:call(?MODULE, [argument]).

service(N1, O, N2)->
    gen_server:call(?MODULE, [N1, O, N2]).