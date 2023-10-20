# nbson_bench

`nbson_bench` is an OTP library to benchmark [`nbson`](https://github.com/nomasystems/nbson).

## Benchmarking
`nbson`'s BSON decoder implementation in `nbson_decoder.erl` uses [CPS](https://en.wikipedia.org/wiki/Continuation-passing_style). In this particular case, CPS leads to the use of the [sub binary delayed optimization](https://www.erlang.org/doc/efficiency_guide/binaryhandling.html#match-context) and improved efficiency in the deserialization process.

The `nbson_BENCH` script under `priv` measures the decoding and encoding times for a series of BSONs containing from 1 to 1M documents using `nbson`. This escript also executes such deserializations using [bson-erlang](https://github.com/comtihon/bson-erlang), a well-known BSON encoder/decoder, for comparison purposes. To execute the benchmark yourself, please run `rebar3 compile` before executing the script.

Executing the measurement using the .bson files under `priv/data` produced the table below. Each row corresponds to measuring the decoding time of the BSONs in a given file. The first column specifies the number of documents inside each BSON file, the second column specifies the byte sizes for each of those BSONs and the third and fourth columns show the measured times in µs for nbson and bson-erlang respectively.

You can also execute these benchmarks by running a shell and using the `nbson_bench` API.

```
--------------------------------------------------------------------------------------
DECODING PROCESS
--------------------------------------------------------------------------------------
    Size (documents)     File size (bytes)       Nbson Time (us)  BsonErlang Time (us)
                   1                   150                  1649                  2254
                  10                  2156                   298                   793
                 100                 21439                  3394                  7622
                1000                208773                 32143                 72362
               10000               2035919                960857               1985022
              100000              20365952              14096820              28931531
--------------------------------------------------------------------------------------
ENCODING PROCESS
--------------------------------------------------------------------------------------
    Size (documents)     File size (bytes)       Nbson Time (us)  BsonErlang Time (us)
                   1                   150                   988                  1039
                  10                  2156                   450                   663
                 100                 21439                  3041                  5965
                1000                208773                 25378                 59154
               10000               2035919                276705                904258
              100000              20365952               2753270              10265374
```

Those used .bson files were generated using the [nbson_corpus](https://github.com/nomasystems/nbson_corpus) Erlang library.

