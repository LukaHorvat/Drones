Object.defineProperty Function.prototype, 'compose',
    configurable: false
    enumerable: false
    writable: false
    value: (g) ->
        f = this
        comp = null
        do (f) ->
            comp = (args...) -> f(g(args...))
        return comp

Object.defineProperty Array.prototype, 'sortByValue',
    configurable: false
    enumerable: false
    writable: false
    value: (fn) ->
        arr = this
        do (arr) ->
            arr.sort (a, b) -> (fn a) - (fn b)

Object.defineProperty Array.prototype, 'remove',
    configurable: false
    enumerable: false
    writable: false
    value: (x) ->
        arr = this
        do (arr) ->
            for i in [arr.length - 1..0] by -1
                if arr[i] is x
                    arr.splice i, 1

