_           = require 'lodash'
ReturnValue = require 'nanocyte-component-return-value'

class OctobluCredentialsConfigurator extends ReturnValue
  onEnvelope: ({config, data}) =>
    {template,channelApiMatch} = config
    userApiMatch = _.find data.userApis, type: template.type
    return {} unless userApiMatch?
    return {} unless channelApiMatch?
    channelConfig = _.pick channelApiMatch,
      'bodyFormat'
      'followAllRedirects'
      'skipVerifySSL'
      'hiddenParams'
      'auth_header_key'
      'bodyParams'

    channelConfig = _.defaults {}, template, channelConfig

    channelConfig.apikey = userApiMatch.apikey

    userToken = userApiMatch.token ? userApiMatch.key

    userOAuth =
      access_token: userToken
      access_token_secret: userApiMatch.secret
      refreshToken: userApiMatch.refreshToken
      expiresOn: userApiMatch.expiresOn
      defaultParams: userApiMatch.defaultParams

    channelConfig.defaultParams = userApiMatch.defaultParams

    channelOauth =  channelApiMatch.oauth?[process.env.NODE_ENV]
    channelOauth ?= channelApiMatch.oauth
    channelOauth ?= tokenMethod: channelApiMatch.auth_strategy

    channelConfig.oauth = _.defaults {}, userOAuth, template.oauth, channelOauth

    if channelApiMatch.overrides
      channelConfig.headerParams = _.extend {}, template.headerParams, channelApiMatch.overrides.headerParams

    channelConfig.oauth.key ?= channelConfig.oauth.clientID
    channelConfig.oauth.key ?= channelConfig.oauth.consumerKey

    channelConfig.oauth.secret ?= channelConfig.oauth.clientSecret
    channelConfig.oauth.secret ?= channelConfig.oauth.consumerSecret

    return JSON.parse JSON.stringify channelConfig # removes things that are undefined

module.exports = OctobluCredentialsConfigurator
