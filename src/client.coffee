request = require 'requestretry'
util = require 'util'
packageJson = require '../package.json'
_ = require 'lodash'

class Client
  endpoint: 'https://api.appoptics.com/v1'

  constructor: ({token, simulate, requestOptions}) ->
    if not token
      console.warn "appoptics-node metrics disabled: no token provided." unless simulate
    else
      @_requestOptions = _.defaults (requestOptions or {}),
        method: 'POST'
        uri: "#{@endpoint}/metrics"
        headers: {}
        maxAttempts: 3
        retryDelay: 100
        delayStrategy: -> (2 ^ this.attempts) * (this.retryDelay / 2)
      @_requestOptions.headers = _.defaults @_requestOptions.headers,
        authorization: 'Basic ' + new Buffer("#{token}:").toString('base64')
        'user-agent': "appoptics-node/#{packageJson.version}"

  send: (json, cb) ->
    return process.nextTick(cb) unless @_requestOptions?

    requestOptions = _.extend {}, @_requestOptions, {json}

    request requestOptions, (err, res, body) ->
      if res?.attempts > 1
        console.warn "appoptics API required #{res.attempts} retries"
      return cb(err) if err?
      if res.statusCode > 399 or body?.errors?
        return cb(new Error("Error sending to appoptics: #{util.inspect(body, depth: null)} (statusCode: #{res.statusCode})"))
      return cb(null, body)

module.exports = Client
