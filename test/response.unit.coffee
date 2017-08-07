assert = require 'assert'
RedirectResponse = require('../src/response').RedirectResponse
Responder = require '../src/responder'
responder = new Responder()

uri = 'http://some.host/some/path'

describe 'response', ->
  describe 'RedirectResponse', ->
    it 'properly populates the properties with the specified values', ->
      response = new RedirectResponse uri, responder.codes.found
      assert.strictEqual response.body, null
      assert.strictEqual response.uri, uri
      assert.strictEqual response.statusCode, responder.codes.found
      
    context 'when no response code is specified', ->
      it "defaults to #{responder.codes.movedPermanently}", ->
        response = new RedirectResponse uri
        assert.strictEqual response.body, null
        assert.strictEqual response.uri, uri
        assert.strictEqual response.statusCode, responder.codes.movedPermanently
