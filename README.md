appoptics-node
============

appoptics-node is a Node.js client for Appoptics Metrics (http://appoptics.com/)

[![build status][travis-badge]][travis-link]
[![npm version][npm-badge]][npm-link]
[![mit license][license-badge]][license-link]
[![we're hiring][hiring-badge]][hiring-link]

## Getting Started

### Install

    $ npm install appoptics-node

### Setup

Once `appoptics.start` is called, a worker will send aggregated stats to Appoptics once every 60 seconds.

``` javascript
var appoptics = require('appoptics-node');

appoptics.configure({email: 'foo@example.com', token: 'ABC123'});
appoptics.start();

process.once('SIGINT', function() {
  appoptics.stop(); // stop optionally takes a callback
});

// Don't forget to specify an error handler, otherwise errors will be thrown
appoptics.on('error', function(err) {
  console.error(err);
});
```

### Increment

Use `appoptics.increment` to track counts in Appoptics.  On each flush, the incremented total for that period will be sent.

``` javascript
var appoptics = require('appoptics-node');

appoptics.increment('foo');                     // increment by 1
appoptics.increment('foo', 2);                  // increment by 2
appoptics.increment('foo', 2, {source: 'bar'}); // custom source
```

### Measurements

You can send arbitrary measurements to Appoptics using `appoptics.measure`. These will be sent as gauges. For example:

``` javascript
var appoptics = require('appoptics-node');

appoptics.measure('member-count', 2001);
appoptics.measure('response-time', 500);
appoptics.measure('foo', 250, {source: 'bar'}); // custom source
```

### Timing

Use `appoptics.timing` to measure durations in Appoptics. You can pass it a synchronous function or an asynchronous function (it checks the function arity).  For example:

``` javascript
var appoptics = require('appoptics-node');

// synchronous
appoptics.timing('foo', function() {
  for (var i=0; i<50000; i++) console.log(i);
});

// async without a callback
appoptics.timing('foo', function(done) {
  setTimeout(done, 1000);
});

// async with a callback
var workFn = function(done) {
  setTimeout(function() {
    done(null, 'foo');
  });
};
var cb = function(err, res) {
  console.log(res); // => 'foo'
};
appoptics.timing('foo', workFn, cb);
appoptics.timing('foo', workFn, {source: 'bar'}, cb); // all timing calls also accept a custom source
```

### Express

appoptics-node includes Express middleware to log the request count and response times for your app.  It also works in other Connect-based apps.

``` javascript
var express = require('express');
var appoptics = require('appoptics-node');

var app = express();
app.use(appoptics.middleware());
```

The key names the middleware uses are configurable by passing an options hash.

``` javascript
appoptics.middleware({requestCountKey: 'myRequestCount', responseTimeKey: 'myResponseTime'});
```

### Advanced

By default the appoptics-node worker publishes data every 60 seconds. Configure
this value by passing a `period` argument to the `configure` hash.

```javascript
var appoptics = require('appoptics-node');
appoptics.configure({email: 'foo@bar.com', token: 'ABC123', period: 5000})
```

### Request Options

You can pass additional options for the HTTP POST to Appoptics using the `requestOptions` parameter.  See [request/request](https://github.com/request/request) for a complete list of options. For example, to configure a timeout:

```javascript
var appoptics = require('appoptics-node');
appoptics.configure({email: 'foo@bar.com', token: 'ABC123', requestOptions: {timeout: 250}})
```

By default appoptics-node will retry up to 3 times on connection failures and 5xx responses using an exponential backoff strategy with a 100ms base. These defaults can be overridden using the `requestOptions` paramter. See [requestretry](https://github.com/FGRibreau/node-request-retry) for a list of options. For example, to limit to a single attempt:

```javascript
var appoptics = require('appoptics-node');
appoptics.configure({email: 'foo@bar.com', token: 'ABC123', requestOptions: {maxAttempts: 1}})
```

------

## Contributing

```
$ git clone https://github.com/goodeggs/appoptics-node && cd appoptics-node
$ npm install
$ npm test
```

------

## History

appoptics-node is a fork of [librato-node](https://github.com/goodeggs/librato-node).

------

## License

[MIT][license-link]

[travis-badge]: http://img.shields.io/travis/maxnowack/appoptics-node/master.svg?style=flat-square
[travis-link]: https://travis-ci.org/maxnowack/appoptics-node
[npm-badge]: http://img.shields.io/npm/v/appoptics-node.svg?style=flat-square
[npm-link]: https://www.npmjs.org/package/appoptics-node
[license-badge]: http://img.shields.io/badge/license-mit-blue.svg?style=flat-square
[license-link]: LICENSE.md
[hiring-badge]: https://img.shields.io/badge/we're_hiring-yes-brightgreen.svg?style=flat-square
[hiring-link]: http://goodeggs.jobscore.com/?detail=Open+Source&sid=161
