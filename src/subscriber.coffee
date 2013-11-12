Mixin = require 'mixto'

module.exports =
class Subscriber extends Mixin
  subscribeWith: (eventEmitter, methodName, args) ->
    unless eventEmitter[methodName]?
      throw new Error("Object does not have method '#{methodName}' with which to subscribe")

    eventEmitter[methodName](args...)

    eventName = args[0]
    callback = args[args.length - 1]
    @addSubscription
      emitter: eventEmitter
      off: ->
        # node's EventEmitter doesn't have 'off' method.
        removeListener = eventEmitter.off ? eventEmitter.removeListener
        removeListener.call eventEmitter, eventName, callback

  addSubscription: (subscription) ->
    @subscriptions ?= []
    @subscriptions.push(subscription)

    {emitter} = subscription
    if emitter?
      @subscriptionsByObject ?= new WeakMap
      if @subscriptionsByObject.has(emitter)
        @subscriptionsByObject.get(emitter).push(subscription)
      else
        @subscriptionsByObject.set(emitter, [subscription])

    subscription

  subscribe: (eventEmitterOrSubscription, args...) ->
    if args.length is 0
      @addSubscription(eventEmitterOrSubscription)
    else
      @subscribeWith(eventEmitterOrSubscription, 'on', args)

  subscribeToCommand: (eventEmitter, args...) ->
    @subscribeWith(eventEmitter, 'command', args)

  unsubscribe: (object) ->
    if object?
      for subscription in @subscriptionsByObject?.get(object) ? []
        subscription.off()
        index = @subscriptions.indexOf(subscription)
        @subscriptions.splice(index, 1) if index >= 0
      @subscriptionsByObject?.delete(object)
    else
      subscription.off() for subscription in @subscriptions ? []
      @subscriptions = null
      @subscriptionsByObject = null
