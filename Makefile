all: benchmark-results.html

Benchmark: Benchmark.hs UnsafeSequence.hs cmmbits.cmm
	ghc --make -O2 $^

benchmark-results.html: Benchmark
	./Benchmark -o $@

