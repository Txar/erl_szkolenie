%%%-------------------------------------------------------------------
%% @doc myapp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(myapp_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
  SupFlags =
    #{strategy => one_for_one,
      intensity => 1,
      period => 1},
  ChildSpecs = [spec(fun erlang_srv:start_link/0)],
  {ok, {SupFlags, ChildSpecs}}.

%% internal functions
spec(StartF) ->
  spec(StartF, [], permanent).

spec(Startf, Args, Restart) ->
  {M, F, _Arity} = erlang:fun_info_mfa(Startf),
  #{id => M,
    start => {M, F, Args},
    restart => Restart
  }.

handle_request(Params) ->
  io:format("Params: ~p", [Params]),
  Output = list_to_binary(Params),
  jsone:encode(#{<<"result">> => Output}).