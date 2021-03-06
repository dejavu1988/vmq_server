%% Copyright 2014 Erlio GmbH Basel Switzerland (http://erl.io)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(vmq_session_proxy_sup).

-behaviour(supervisor).

%% API
-export([start_link/0,
         start_delivery/3]).

%% Supervisor callbacks
-export([init/1]).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_delivery(Nodes, QPid, SubscriberId) ->
    ClusterNodes = vmq_cluster:nodes(),
    lists:foreach(
      fun(Node) ->
              case lists:member(Node, ClusterNodes) of
                  true ->
                      {ok, _Pid} = supervisor:start_child(?MODULE, [Node, QPid,
                                                                    SubscriberId]);
                  false ->
                      lager:warning("can't initiate remote delivery due to node ~p not found", [Node])
              end
      end, Nodes).


%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init([]) ->
    {ok, {{simple_one_for_one, 5, 10},
          [{vmq_session_proxy,
            {vmq_session_proxy, start_link, []},
            temporary, 1000, worker, [vmq_session_proxy]}]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
