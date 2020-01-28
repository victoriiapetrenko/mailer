//  cordova-plugin-mailer
//
//  Created by Victoria Petrenko 2020/01/28
//
//  Copyright 2020 sitewaerts GmbH. All rights reserved.
//  MIT Licensed

/*  configuration   */

var JS_HANDLE = 'Mailer'
var CDV_HANDLE = 'Mailer'

var CDV_HANDLE_ACTIONS = {
  GET_DOCUMENT_PAGES_COUNT: 'getDocumentPagesCount',

  SEND_MAIL: 'sendMail'
}

var exec = require('cordova/exec')

/*  public plugin API */

var MailerPlugin = {
  getDocumentPagesCount: function (onSuccess, onError) {
    var errorPrefix = 'Error in ' + JS_HANDLE + '.getDocumentPagesCount(): '
    try {
      exec(
        function (result) {
          if (onSuccess) {
            window.console.log('pages count is ' + JSON.stringify(result))
            onSuccess(result)
          }
        },
        function (err) {
          window.console.log(errorPrefix, err)
          if (onError) {
            onError(err)
          }
        },
        CDV_HANDLE,
        CDV_HANDLE_ACTIONS.GET_DOCUMENT_PAGES_COUNT,
        []
      )
    } catch (e) {
      window.console.log(errorPrefix + JSON.stringify(e))
      if (onError) {
        onError(e)
      }
    }
  },

  sendMail: function (url, pages, onShow, onClose, onError) {
    var me = this
    var errorPrefix = 'Error in ' + JS_HANDLE + '.sendMail(): '
    try {
      exec(
        function (result) {
          var status = result ? result.status : null

          if (status == 1) {
            if (onShow) onShow()
          } else if (status == 0) {
            if (onClose) onClose()
          } else {
            var errorMsg = "unknown state '" + status + "'"
            window.console.log(errorPrefix + errorMsg)
          }
        },
        function (err) {
          window.console.log(errorPrefix + JSON.stringify(err))
          if (onError) onError(err)
        },
        CDV_HANDLE,
        CDV_HANDLE_ACTIONS.SEND_MAIL,
        [{ url: url }]
      )
    } catch (e) {
      window.console.log(errorPrefix + JSON.stringify(e))
      if (onError) onError(e)
    }
  }
}

module.exports = MailerPlugin;
