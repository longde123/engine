# Method is any kind of a function that
# may be referenced in a node of an expressions tree.

# This constructor allows non-collable methods defined
# with objects to be converted into callable
# functions that retain all definition properties, 
# but can be used outside of expressions (e.g. in tests or user scripts)

Method = (method, reference) ->
  return unless method
  if typeof method == 'object' && !method.exec
    helper = Method.Helper(method, false, reference)
    for key, value of method
      helper[key] = value
    return helper
  method.displayName = reference
  return method

# Exports given methods as self-contained functions 
# to be used as helpers in user scripts and specs

Method.Helper = (method, scoped, displayName)  ->
  if typeof method == 'function'
    func = method
  helper = (scope) ->
    args = Array.prototype.slice.call(arguments, 0)
    length = arguments.length
    if scoped || method.serialized
      unless scope && scope.nodeType
        scope = @scope || document
        if typeof method[args.length] == 'string'
          context = scope
        else
          args.unshift(scope)
      else
        if typeof method[args.length - 1] == 'string'
          context = scope = args.shift()

    unless fn = func
      if typeof (func = method[args.length]) == 'function'
        fn = func
      else
        unless func && (fn = scope[func])
          if fn = @methods[func]
            context = @
          else
            fn = method.command
            args = [null, args[2], null, null, args[0], args[1]]

    return fn.apply(context || @, args)
  if displayName
    helper.displayName = displayName 
  return helper


Method.compile = (methods, engine) ->
  methods.engine ||= engine
  for own key, method of methods
    continue if method == engine
    if key.charAt(0) != '_'
      subkey = '_' + key
      method = @(method, subkey)
      engine[subkey] ?= method
  
    engine[key] ?= method
  return methods


module.exports = Method


