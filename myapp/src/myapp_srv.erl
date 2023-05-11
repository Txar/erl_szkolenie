-module(myapp_srv).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, service/3, calculate/3, request/3, handle_request/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("Started"),
    inets:start(httpd, [{modules, 
        [
            mod_alias,
            mod_auth,
            mod_esi,
            mod_actions,
            mod_cgi,
            mod_dir,
            mod_get,
            mod_head,
            mod_log,
            mod_disk_log
        ]},
        {port, 8001},
        {server_name, "localhost"},
        {server_root, "./"},
        {document_root, "./htdocs"},
        {directory_index, ["index.html"]},
        {erl_script_alias, {"/test", [myapp_srv]}},
        {bind_address, "localhost"},
        {mime_types,
        [{"html", "text/html"}, {"css", "text/css"}, {"js", "application/x-javascript"}]},
        {ok, started}
    ]),
    {ok, started}.


calculate(A, B, Operator) ->
    Args = {A, B, Operator},
    gen_server:call(?MODULE, {calculate, Args}).

handle_calculate({A, B, '+'}) ->
    A + B;
handle_calculate({A, B, '-'}) ->
    A - B;
handle_calculate({A, B, '*'}) ->
    A * B;
handle_calculate({A, B, '/'}) ->
    A / B.

service(SessionID, _Env, _Input) ->
  mod_esi:deliver(SessionID,
                  ["Content-Type: text/html\r\n\r\n", "<html><body>Hello, world</body></html>"]).

request(SessionID, Env, Input) ->
  %gen_server:call(?MODULE, {handle_request, {Input}}),
  Response = gen_server:call(?MODULE, {handle_request, {Input}}),
  mod_esi:deliver(SessionID, ["Content-Type: application/json\r\n\r\n", Response]).

%service(N1, O, N2) ->
%    gen_server:call(?MODULE, [N1, O, N2]).

handle_call({calculate, Args}, _From, _OldState) ->
    Result = handle_calculate(Args),
    {reply, Result, ok};
handle_call({handle_request, {Input}}, _From, _OldState) ->
    Result = handle_request(Input),
    {reply, Result, ok};
handle_call(Args, From, OldState) ->
    io:format("A:~p~nB:~p~nC:~p~n",[Args,From,OldState]),
    io:format("Received call"),
    {reply, "odpowiedz", ok}.

handle_cast(Args, B) ->
    io:format("Received cast"),
    {noreply, ok}.

handle_request(Params) ->
    io:format("Params: ~p", [Params]),
    Output = list_to_binary(Params),
    jsone:encode(#{<<"result">> => Output}).