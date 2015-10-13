A really unsafe implementation of sequence for the IO monad
=============

See [this blog post](http://twanvl.nl/blog/haskell/unsafe-sequence) for details.

Benchmark results
-----------------

Runtimes as a function of list length, as measured by the benchmark script.

| Function     | Description              | 10^3     | 10^4     | 10^5     | 10^6     |
|--------------|--------------------------|---------:|---------:|---------:|---------:|
| `sequence`   | From the Haskell prelude |  5.51 μs | 130.0 μs | 3.956 ms | 57.30 ms |
| `sequenceIO` | Neil Mitchell's version  | 14.72 μs | 200.0 μs | 4.489 ms | 43.65 ms |
| `sequenceU`  | Using `unsafeSetField`   | 10.07 μs | 123.6 μs | 3.881 ms | 43.20 ms |
| `sequenceH`  | Using holes              | 15.55 μs | 189.8 μs | 4.343 ms | 44.73 ms |

