module FastTest

using Dagger
using Test
using MacroTools

macro testset(name, ex)
    @gensym f ts rts results
    inner = nothing
    isfor = false
    if @capture(ex, for forvar_ in iterspec_; inner_ end)
        isfor = true
    elseif @capture(ex, begin inner_ end)
    else
        throw(ArgumentError("Unsupported @testset specification"))
    end
    if isfor
        @gensym iter
        ex_f = :(($ts, $iter)->begin
            Test.push_testset($ts)
            try
                Base.eval(Main, quote
                    $($(QuoteNode(forvar))) = $($iter)
                    $($(esc(inner)))
                end)
            catch err
                Test.record($ts, Test.Error(:nontest_error, Expr(:tuple), err, Base.current_exceptions(), $(QuoteNode(__source__))))
            end
            Test.pop_testset()
        end)
        quote
            $f = $ex_f
            for $forvar in $iterspec
                Test.@testset $name begin
                    $rts = Test.get_testset()
                    $results = fetch(Dagger.@spawn $f(deepcopy($rts), $forvar))
                    Test.record($rts, $results)
                end
            end
        end
    else
        ex_f = :($ts->begin
            Test.push_testset($ts)
            try
                Base.eval(Main, :($($(esc(inner)))))
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
end

end # module
