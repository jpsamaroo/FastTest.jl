# FastTest.jl - Faster Julia Tests with Dagger

FastTest is a package for running regular Julia tests in parallel. FastTest
provides an `@testset` macro which aims to be drop-in compatible with
`Test.@testset`, but uses Dagger.jl to execute testsets. This allows tests to
be run on multiple threads and multiple workers automatically.
