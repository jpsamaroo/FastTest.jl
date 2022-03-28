module FastTest

using Dagger
using Test

macro testset(name, ex)
    @gensym f ts rts results
    ex_f = :($ts->begin
        Test.push_testset($ts)
        try
            Base.eval(Main, :($($(esc(ex)))))
        catch err
            Test.record($ts, Test.Error(:nontest_error, Expr(:tuple), err, Base.current_exceptions(), $(QuoteNode(__source__))))
        end
        Test.pop_testset()
    end)
    quote
        $f = $ex_f
        Test.@testset $name begin
            $rts = Test.get_testset()
            $results = fetch(Dagger.@spawn $f(deepcopy($rts)))
            Test.record($rts, $results)
        end
    end
end

end # module
