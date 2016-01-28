ReturnValue = require 'nanocyte-component-return-value'
OctobluCredentialsConfigurator = require '../src/octoblu-credentials-configurator'

describe 'OctobluCredentialsConfigurator', ->
  beforeEach ->
    @sut = new OctobluCredentialsConfigurator

  it 'should exist', ->
    expect(@sut).to.be.an.instanceOf ReturnValue

  describe '->onEnvelope', ->
    describe 'when called with an envelope', ->
      beforeEach ->
        @result = @sut.onEnvelope
          config:
            channelApiMatch: require './weather.json'
            type: 'channel:weather'
            headerParams: {}
            urlParams: {}
            queryParams:
              city: 'Tempe'
              state: 'AZ'
            bodyParams:
              something: true
            url: 'http://weather.octoblu.com/temperature/fahrenheit'
            method: 'GET'
            oauth:
              tokenMethod:'none'
          message:
            userApis: [
              authtype: 'none'
              channelid: '5337a38d76a65b9693bc2a9f'
              _id: '569fc2fd0c626601000186ee'
              type: 'channel:weather'
              uuid: 'channel-weather-uuid'
            ]

      it 'should return the message', ->
        expect(@result).to.deep.equal
          type:'channel:weather'
          headerParams: {}
          urlParams: {}
          queryParams:
            city: 'Tempe'
            state: 'AZ'
          bodyParams:
            something: true
          url: 'http://weather.octoblu.com/temperature/fahrenheit'
          method: 'GET'
          oauth:
            tokenMethod:'none'

    describe 'when called with no channelApiMatch', ->
      beforeEach ->
        @result = @sut.onEnvelope
          config:
            channelApiMatch: null
          message:
            userApis: [
              authtype: 'none'
              channelid: '5337a38d76a65b9693bc2a9f'
              _id: '569fc2fd0c626601000186ee'
              type: 'channel:weather'
              uuid: 'channel-weather-uuid'
            ]

      it 'should return an empty object', ->
        expect(@result).to.deep.equal {}

    describe 'when called with no userApiMatch', ->
      beforeEach ->
        @result = @sut.onEnvelope
          config:
            channelApiMatch: null
          message:
              userApis: []

      it 'should return an empty object', ->
        expect(@result).to.deep.equal {}

    describe 'when called there is no type config', ->
      beforeEach ->
        @result = @sut.onEnvelope
          config:
            channelApiMatch:
              something: true
            type: null
          message:
            payload: null

      it 'should return an empty object', ->
        expect(@result).to.deep.equal {}
