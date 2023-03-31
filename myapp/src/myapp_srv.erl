-module(myapp_srv).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, service/3]).

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

handle_call(Args, From, OldState) ->
    io:format("A:~p~n:B~p~n:C~p~n",[Args, From, OldState]),
    io:format("Received call\n"),
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

%service(N1, O, N2) ->
%    gen_server:call(?MODULE, [N1, O, N2]).

service(SessionID, _Env, _Input) ->
    mod_esi:deliver(SessionID, [
        "Content-type: text/html\r\n\r\n",
        "<html><body style=\"background-color: black;color: white;\">beton</body></html>"
    ]).