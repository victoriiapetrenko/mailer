//
//  MailerPlugin.m
//  cordova-plugin-mailer
//
//  Created by Victoria Petrenko on 1/28/20.
//  Copyright © 2020 TestName. All rights reserved.
//

#import "MailerManager.h"

#import <MessageUI/MessageUI.h>
#import <PDFKit/PDFKit.h>
#import "YPDocument.h"

@implementation MailerPlugin

- (void)getDocumentPagesCount:(CDVInvokedUrlCommand*)command {
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"application/pdf", nil];
    NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc]
                                    initWithObjectsAndKeys :
                                    array, @"supported",
                                    nil
                                    ];
    NSNumber *pagesCountresult = @(1);
    [self.commandDelegate sendPluginResult:pagesCountresult callbackId:command.callbackId];
}

- (void)sendMail:(CDVInvokedUrlCommand*)command {
    
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    
    // URL
    NSString* url = [options objectForKey:@"url"];
    if (url != nil && url.length > 0) {
    }
}

@end
