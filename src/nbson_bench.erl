%%% Copyright 2022 Nomasystems, S.L. http://www.nomasystems.com
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
-module(nbson_bench).

-define(SEPARATOR, io:format("--------------------------------------------------------------------------------------~n")).
-define(BENCH_DIR(Filename), io_lib:format("priv/data/~s", [Filename])).
                                                                                                                          
%%% EXTERNAL EXPORTS
-export([bench/0, bench_decode/0, bench_encode/0, profile_decode/0, profile_encode/0]).

%%% MACROS
-define(TIMES , 10).

%%%-----------------------------------------------------------------------------
%%% EXTERNAL EXPORTS
%%%-----------------------------------------------------------------------------
bench() ->
    bench_decode(),
    bench_encode().

bench_decode() ->
    Times = ?TIMES,
    ?SEPARATOR,
    io:format("Decoder:~n"),
    ?SEPARATOR,
    head(),
    bench_decode(?BENCH_DIR("test1.bson"), Times),
    bench_decode(?BENCH_DIR("test10.bson"), Times),
    bench_decode(?BENCH_DIR("test100.bson"), Times),
    bench_decode(?BENCH_DIR("test1000.bson"), Times),
    bench_decode(?BENCH_DIR("test10000.bson"), Times),
    bench_decode(?BENCH_DIR("test100000.bson"), Times),
    ?SEPARATOR.
 
bench_encode() ->
    Times = ?TIMES,
    ?SEPARATOR,
    io:format("Encoder:~n"),
    ?SEPARATOR,
    head(),
    bench_encode(?BENCH_DIR("test1.bson"), Times),
    bench_encode(?BENCH_DIR("test10.bson"), Times),
    bench_encode(?BENCH_DIR("test100.bson"), Times),
    bench_encode(?BENCH_DIR("test1000.bson"), Times),
    bench_encode(?BENCH_DIR("test10000.bson"), Times),
    bench_encode(?BENCH_DIR("test100000.bson"), Times),
    ?SEPARATOR.

profile_decode() ->
    Path = ?BENCH_DIR("test1.bson"),
    {ok, Bin} = file:read_file(Path),
    eflambe:apply({nbson, decode, [Bin]}, [{output_format, brendan_gregg}]).

profile_encode() ->
    Path = ?BENCH_DIR("test1.bson"),
    {ok, Bin} = file:read_file(Path),
    {ok, B} = nbson:decode(Bin),
    eflambe:apply({nbson, encode, [B]}, [{output_format, brendan_gregg}]).

%%%-----------------------------------------------------------------------------
%%% INTERNAL FUNCTIONS
%%%-----------------------------------------------------------------------------
head() ->
    io:format("~20.. s  ~20.. s  ~20.. s  ~20.. s~n",
              ["Size (documents)", "File size (bytes)", "Nbson Time (µs)", "BsonErlang Time (µs)"]).
 
bench_decode(Path, Times) ->
    {ok, Bin} = file:read_file(Path),
    DocCount = doc_count(Path),
    NbsonTimeDecode = erlperf:time(fun() -> nbson:decode(Bin) end, Times),
    BsonErlangTimeDecode = erlperf:time(fun() -> get_docs(Bin, []) end, Times),
    io:format("~20.. s  ~20.. B  ~20.. B  ~20.. B~n",
              [DocCount,
               byte_size(Bin),
               NbsonTimeDecode,
               BsonErlangTimeDecode]).

bench_encode(Path, Times) ->
    {ok, Bin} = file:read_file(Path),
    DocCount = doc_count(Path),
    {ok, NbsonDocs} = nbson:decode(Bin),
    NbsonTimeEncode = erlperf:time(fun() -> nbson:encode(NbsonDocs) end, Times),

    {BsonErlangDocs, <<>>} = get_docs(Bin, []),
    BsonErlangTimeEncode = erlperf:time(fun() -> put_docs(BsonErlangDocs) end, Times),
    io:format("~20.. s  ~20.. B  ~20.. B  ~20.. B~n",
              [DocCount,
               byte_size(Bin),
               NbsonTimeEncode,
               BsonErlangTimeEncode]).

% get_docs implementation extracted from https://github.com/comtihon/mongodb-erlang/blob/56c700f791601a201a9d5af7cad45b3c81258209/src/connection/mongo_protocol.erl#L113
get_docs(<<>>, Docs) ->
    {lists:reverse(Docs), <<>>};
get_docs(Bin, Docs) ->
    {Doc, Bin1} = bson_binary:get_map(Bin),
    get_docs(Bin1, [Doc | Docs]).

% Multiple documents encoding implementation taken from https://github.com/comtihon/mongodb-erlang/blob/56c700f791601a201a9d5af7cad45b3c81258209/src/connection/mongo_protocol.erl#L52
put_docs(Docs) ->
    << << <<(bson_binary:put_document(Doc))/binary>> || Doc <- Docs>>/binary >>.

doc_count(Path) ->
    [_, Filename] = string:split(Path, "/", trailing),
    [_, Filename1] = string:split(Filename, "test", trailing),
    [Number, _] = string:split(Filename1, "."),
    Number.
