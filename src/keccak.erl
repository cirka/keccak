-module(keccak).

%% API exports
-export([keccak256/1]).

%%====================================================================
%% API functions
%%====================================================================

keccak256(Input) when is_binary(Input) ->
 gen_server:call(keccak_server, {keccak256, Input}).


%%====================================================================
%% Internal functions
%%====================================================================
