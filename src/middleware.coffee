# Connect/Express middleware that records request count, response times, and status codes (1xx - 5xx).
# based on connect logger middleware https://github.com/senchalabs/connect/blob/master/lib/middleware/logger.js

module.exports = (appoptics) ->
  return ({requestCountKey, responseTimeKey, statusCodeKey}={}) ->
    return (req, res, next) ->
      req._appopticsStartTime = new Date

      # mount safety
      return next() if req._appoptics?

      # flag as appoptics
      req._appoptics = true

      appoptics.increment(requestCountKey ? 'requestCount')

      end = res.end
      res.end = (chunk, encoding) ->
        res.end = end
        res.end(chunk, encoding)
        appoptics.measure(responseTimeKey ? 'responseTime', new Date - req._appopticsStartTime)
        appoptics.increment("#{statusCodeKey ? 'statusCode'}.#{Math.floor(res.statusCode / 100)}xx")

      next()
