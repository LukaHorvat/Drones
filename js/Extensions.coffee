Function.prototype.compose = (g) ->
    f = this
    comp = null
    do (f) ->
        comp = (args...) -> f(g(args...))
    return comp