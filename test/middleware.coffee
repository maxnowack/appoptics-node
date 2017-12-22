require './support/test_helper'
_ = require 'lodash'
middlewareFactoryFactory = require '../lib/middleware'
appoptics = require '..'

describe 'middleware', ->
  {middleware, fakeReq, fakeRes, stubAppoptics} = {}

  beforeEach ->
    @sinon.stub(appoptics)
    fakeReq = {}
    fakeRes = {end: (->), statusCode: 200}

  describe 'with defaults', ->
    beforeEach ->
      middleware = middlewareFactoryFactory(appoptics)()

    describe 'request count', ->
      it 'increments for each request', (done) ->
        middleware fakeReq, fakeRes, ->
          expect(appoptics.increment.calledWith('requestCount')).to.be.true
          done()

    describe 'response time', ->
      {clock} = {}
      beforeEach ->
        clock = @sinon.useFakeTimers(new Date().getTime())

      afterEach ->
        clock.restore()

      it 'measures for each request', (done) ->
        middleware fakeReq, fakeRes, ->
          expect(appoptics.measure.calledWith('responseTime')).to.be.false
          clock.tick(101)
          fakeRes.end()
          expect(appoptics.measure.calledWith('responseTime', 101)).to.be.true
          done()

    describe 'status code', ->
      it 'increments for each request', (done) ->
        middleware fakeReq, fakeRes, ->
          expect(appoptics.increment.calledWith('statusCode.2xx')).to.be.false
          fakeRes.end()
          expect(appoptics.increment.calledWith('statusCode.2xx')).to.be.true
          done()
