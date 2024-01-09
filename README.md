# nbson_bench

`nbson_bench` is an OTP library to benchmark [`nbson`](https://github.com/nomasystems/nbson).

## Benchmarking
The `nbson_BENCH` script under `priv` measures the decoding and encoding times for a series of BSONs containing from 1 to 1M documents using `nbson`. This escript also executes such deserializations using [bson-erlang](https://github.com/comtihon/bson-erlang), a well-known BSON encoder/decoder, for comparison purposes. To execute the benchmark yourself, please run `rebar3 compile` before executing the script.

Executing the measurement using the .bson files under `priv/data` produced the table below. Each row corresponds to measuring the decoding time of the BSONs in a given file. The first column specifies the number of documents inside each BSON file, the second column specifies the byte sizes for each of those BSONs and the third and fourth columns show the measured times in µs for nbson and bson-erlang respectively.

You can also execute these benchmarks by running a shell and using the `nbson_bench` API.

```
--------------------------------------------------------------------------------------
DECODING PROCESS
--------------------------------------------------------------------------------------
    Size (documents)     File size (bytes)       Nbson Time (µs)  BsonErlang Time (µs)
                   1                   150                     1                     2
                  10                  2156                     0                     0
                 100                 21439                     3                     8
                1000                208773                    38                    77
               10000               2035919                   802                  1897
              100000              20365952                 12768                 28070
--------------------------------------------------------------------------------------
ENCODING PROCESS
--------------------------------------------------------------------------------------
    Size (documents)     File size (bytes)       Nbson Time (µs)  BsonErlang Time (µs)
                   1                   150                     1                     1
                  10                  2156                     0                     0
                 100                 21439                     2                     6
                1000                208773                    33                    66
               10000               2035919                   528                   783
              100000              20365952                  6842                  8572
```

Those used .bson files were generated using the [nbson_corpus](https://github.com/nomasystems/nbson_corpus) Erlang library.

