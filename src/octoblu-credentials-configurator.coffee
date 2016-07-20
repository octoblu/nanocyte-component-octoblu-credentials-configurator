_           = require 'lodash'
ReturnValue = require 'nanocyte-component-return-value'
debug       = require('debug')('nanocyte-component-octoblu-credentials-configurator')

class OctobluCredentialsConfigurator extends ReturnValue
  onEnvelope: ({data, message}) =>
    {userApis,transactionId} = message
    debug 'transaction exists?', data[transactionId]?
    return {transactionId} unless data[transactionId]?
    config = data[transactionId]
    {channelApiMatch} = config
    userApiMatch = _.find userApis, type: config.type
    debug 'userApiMatch', JSON.stringify(userApiMatch)

    return {transactionId} unless userApiMatch?
    return {transactionId} unless channelApiMatch?
    channelConfig = _.pick channelApiMatch,
      'bodyFormat'
      'followAllRedirects'
      'skipVerifySSL'
      'hiddenParams'
      'auth_header_key'
      'bodyParams'

    delete config.channelApiMatch
    channelConfig = _.defaults {}, config, channelConfig

    channelConfig.apikey = userApiMatch.apikey

    userToken = userApiMatch.token ? userApiMatch.key

    userOAuth =
      access_token: userToken
      access_token_secret: userApiMatch.secret
      refreshToken: userApiMatch.refreshToken
      expiresOn: userApiMatch.expiresOn
      defaultParams: userApiMatch.defaultParams

    channelConfig.defaultParams = userApiMatch.defaultParams
    channelConfig.defaultHeaderParams = userApiMatch.defaultHeaderParams if userApiMatch.defaultHeaderParams?
    channelConfig.hiddenParams = userApiMatch.hiddenParams if userApiMatch.hiddenParams?

    channelOauth =  channelApiMatch.oauth?[process.env.NODE_ENV]
    channelOauth ?= channelApiMatch.oauth
    channelOauth ?= tokenMethod: channelApiMatch.auth_strategy

    channelConfig.oauth = _.defaults {}, userOAuth, config.oauth, channelOauth

    if channelApiMatch.overrides
      channelConfig.headerParams = _.extend {}, config.headerParams, channelApiMatch.overrides.headerParams

    channelConfig.oauth.key ?= channelConfig.oauth.clientID
    channelConfig.oauth.key ?= channelConfig.oauth.consumerKey

    channelConfig.oauth.secret ?= channelConfig.oauth.clientSecret
    channelConfig.oauth.secret ?= channelConfig.oauth.consumerSecret
    channelConfig.transactionId = transactionId # pass through to be removed later

    config = JSON.parse JSON.stringify channelConfig # removes things that are undefined
    debug 'sending', config
    return config

module.exports = OctobluCredentialsConfigurator
