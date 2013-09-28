Emitter = require '../src/emitter'

describe "Behavior", ->
  [emitter, behavior] = []

  beforeEach ->
    emitter = new Emitter
    behavior = emitter.signal('a').toBehavior(1)

  describe "::toBehavior(initialValue)", ->
    it "returns a new behavior with the same initial value", ->
      newBehavior = behavior.toBehavior()
      newBehavior.onValue(handler = jasmine.createSpy("handler"))
      expect(handler).toHaveBeenCalledWith(1)
      handler.reset()
      emitter.emit 'a', 44
      expect(handler).toHaveBeenCalledWith(44)

  describe "::scan(initialValue, fn)", ->
    it "returns a behavior yielding the given initial value, then a new value produced by calling the given function with the previous and new values for every change", ->
      values = []
      behavior = behavior.scan 0, (oldValue, newValue) -> oldValue + newValue
      behavior.onValue (value) -> values.push(value)

      expect(values).toEqual [1]
      emitter.emit 'a', i for i in [1..5]
      expect(values).toEqual [1, 2, 4, 7, 11, 16]

  describe "::diff(initialValue, fn)", ->
    it "returns a behavior yielding the result of the function for previous and new value of the observable", ->
      values = []
      behavior = behavior.diff 0, (oldValue, newValue) -> oldValue + newValue
      behavior.onValue (value) -> values.push(value)

      expect(values).toEqual [1]
      emitter.emit 'a', i for i in [1..5]
      expect(values).toEqual [1, 2, 3, 5, 7, 9]

  describe "::filter(predicate)", ->
    it "returns a new behavior that only changes to values matching the given predicate", ->
      values = []
      behavior.filter((value) -> value > 5).onValue (v) -> values.push(v)

      expect(values).toEqual [undefined] # initial value did not match predicate
      emitter.emit('a', i) for i in [0..10]
      expect(values).toEqual [undefined].concat([6..10])

      # now the value of the source behavior is 10, so the initial value passes the predicate
      values = []
      behavior.filter((value) -> value > 5).onValue (v) ->
        debugger
        values.push(v)
      expect(values).toEqual [10]

  describe "::map(fn)", ->
    it "returns a new signal that emits events that are transformed by the given function", ->
      values = []
      behavior.map((value) -> value + 2).onValue (v) -> values.push(v)

      expect(values).toEqual [3]
      emitter.emit('a', i) for i in [0..10]
      expect(values).toEqual [3].concat([2..12])
