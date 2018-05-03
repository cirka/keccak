-module(keccak_server).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
    port % port_id
  }).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    Path = code:priv_dir(keccak),
    PortOpts = [{cd, Path}, {packet, 4}, binary],
    Port = erlang:open_port({spawn_executable, Path ++ "/keccak_server"}, PortOpts),
    {ok, #state{port = Port}}.

handle_call({keccak256, Input}, _From, #state{port = Port} = State) ->
 case erlang:port_command(Port, Input) of
    true ->
       Result = receive 
          {Port, {data, Checksum}} ->  Checksum
          after 2000 -> {error, failed}
       end,
      {reply, Result, State};
    false ->
        {reply, {error, failed}, State}
 end;

handle_call(Request, _From, State) ->
    {reply, not_implemented, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

