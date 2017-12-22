{EventEmitter} = require 'events'
Client = require './client'
Worker = require './worker'
Collector = require './collector'
middleware = require './middleware'

{collector, client, worker, config} = {}

appoptics = new EventEmitter()

appoptics.configure = (newConfig) ->
  config = newConfig
  collector = new Collector()
  client = new Client config
  worker = new Worker job: appoptics.flush, period: newConfig.period

appoptics.increment = (name, value = 1, opts={}) ->
  (opts = value; value = 1)  if value is Object(value)
  collector.increment "#{config.prefix ? ''}#{format_key(name, opts.source)}",
                      value

appoptics.measure = (name, value, opts={}) ->
  collector.measure "#{config.prefix ? ''}#{format_key(name, opts.source)}", value

appoptics.timing = (name, fn, opts={}, cb) ->
  [opts, cb] = [{}, opts] if !cb? and typeof opts is 'function'
  collector.timing "#{config.prefix ? ''}#{format_key(name, opts.source)}", fn, cb

appoptics.start = ->
  worker.start()

appoptics.stop = (cb) ->
  worker.stop()
  appoptics.flush(cb)

appoptics.flush = (cb = ->) ->
  counters = []
  gauges = []
  collector.flushTo counters, gauges
  if config.source?
    measurement.source ?= config.source for measurement in counters
    measurement.source ?= config.source for measurement in gauges
  return process.nextTick(cb) unless counters.length or gauges.length

  client.send {counters, gauges}, (err) ->
    appoptics.emit 'error', err if err?
    cb(err)

appoptics.middleware = middleware(appoptics)


module.exports = appoptics

format_key = (name, source) ->
  if source? then "#{sanitize_name(name)};#{source}"
  else sanitize_name(name)

# from the official librato statsd backend
# https://github.com/librato/statsd-librato-backend/blob/dffece631fcdc4c94b2bff1f7526486aa5bfbab9/lib/librato.js#L144
sanitize_name = (name) ->
  return name.replace(/[^-.:_\w]+/g, '_').substr(0,255)
