//
//  MailerPlugin.h
//  cordova-plugin-mailer
//
//  Created by Victoria Petrenko on 1/28/20.
//  Copyright © 2020 TestName. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#import <Cordova/CDVPlugin.h>

@interface MailerPlugin : CDVPlugin

- (void)getDocumentPagesCount:(CDVInvokedUrlCommand*)command;
- (void)sendMail:(CDVInvokedUrlCommand*)command;

@end

NS_ASSUME_NONNULL_END
