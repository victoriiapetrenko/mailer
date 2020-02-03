//
//  MailerPlugin.m
//  cordova-plugin-mailer
//
//  Created by Victoria Petrenko on 1/28/20.
//  Copyright © 2020 TestName. All rights reserved.
//

#import "MailerPlugin.h"

#import <MessageUI/MessageUI.h>
#import <PDFKit/PDFKit.h>

@interface MailerPlugin () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *tempPath;

@end

@implementation MailerPlugin
{
    NSString *tmpCommandCallbackID;
}

- (NSString *)createPdfWithSelectedPages:(NSString *)pdfURL withPages:(NSArray *)pages {
    
    NSString *fileName = [pdfURL lastPathComponent];
    
    NSString *path = [self applicationSupportDirectory];
    NSString *storedPath = [NSString stringWithFormat:@"%@/%@", path, fileName];
    NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pdfURL]];
    if (fileData) {
        if (@available(iOS 11.0, *)) {
            PDFDocument *pdfDocument = [[PDFDocument alloc] initWithData:fileData];
            NSInteger pagesCount = [pdfDocument pageCount];
            
            PDFDocument *newPdfDocument;
            
            for (NSInteger index = 0; index < pagesCount; index++) {
                NSInteger page = index+1;
                BOOL containsPage = [pages containsObject:@(page)];
                if (containsPage) {
                    PDFPage *page = [pdfDocument pageAtIndex:index];
                    if (page) {
                        if (!newPdfDocument) {
                            //Create new pdf document with single page
                            NSData *firstPageData = [page dataRepresentation];
                            if (firstPageData) {
                                newPdfDocument = [[PDFDocument alloc] initWithData:firstPageData];
                            }
                        } else {
                            [newPdfDocument insertPage:page atIndex:index];
                        }
                    }
                }
            }
            BOOL writed = [newPdfDocument writeToFile:storedPath];
            NSLog(@"Document writed - %@", [NSNumber numberWithBool:writed]);
        }
    }
    return storedPath;
}

- (NSString *)applicationSupportDirectory
{
    NSString *executableName =
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSError *error;
    NSString *result =
        [self
            findOrCreateDirectory:NSApplicationSupportDirectory
            inDomain:NSUserDomainMask
            appendPathComponent:executableName
            error:&error];
    if (error)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
    inDomain:(NSSearchPathDomainMask)domainMask
    appendPathComponent:(NSString *)appendComponent
    error:(NSError **)errorOut
{
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
        searchPathDirectory,
        domainMask,
        YES);
    if ([paths count] == 0)
    {
        // *** creation and return of error object omitted for space
        return nil;
    }

    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    if (appendComponent)
    {
        resolvedPath = [resolvedPath
            stringByAppendingPathComponent:appendComponent];
    }
    
    // Create the path if it doesn't exist
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]
        createDirectoryAtPath:resolvedPath
        withIntermediateDirectories:YES
        attributes:nil
        error:&error];
    if (!success)
    {
        if (errorOut)
        {
            *errorOut = error;
        }
        return nil;
    }
    
    // If we've made it this far, we have a success
    if (errorOut)
    {
        *errorOut = nil;
    }
    return resolvedPath;
}

#pragma mark - MailerPlugin Public Methods

- (void)getDocumentPagesCount:(CDVInvokedUrlCommand*)command {
    
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    // URL
    NSString* url = [options objectForKey:@"url"];
    if (url != nil && url.length > 0) {
        NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (fileData) {
            if (@available(iOS 11.0, *)) {
                PDFDocument *pdfDocument = [[PDFDocument alloc] initWithData:fileData];
                NSNumber *pagesCount = @([pdfDocument pageCount]);
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"count":pagesCount}];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }
}

- (void)sendMail:(CDVInvokedUrlCommand*)command {
    
    NSString *pdfFile = @"";
    
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    // URL
    NSString *url = [options objectForKey:@"url"];
    NSArray *pages = [options objectForKey:@"pages"];
    if (url != nil && url.length > 0) {
        if (pages && pages.count > 0) {
            //Send document with selected pages
            pdfFile = [self createPdfWithSelectedPages:url withPages:pages];
        } else {
            //Send full document
            pdfFile = url;
        }
        [self openMailComposer:pdfFile command:command];
    }
}

- (void)openMailComposer:(NSString *)filePath command:(CDVInvokedUrlCommand*)command {
    
    CDVPluginResult* pluginResult = nil;
    NSData *fileData;
    if ([filePath containsString:@"file:"]) {
        fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
    } else {
        fileData = [NSData dataWithContentsOfFile:filePath];
    }
    
    if ([MFMailComposeViewController canSendMail] == NO) return;
    
        unsigned long long fileSize = fileData.length;
    
        if (fileSize < 15728640ull) // Check fileData size limit (15MB)
        {
            if (fileData != nil) // Ensure that we have valid document file fileData data available
            {
                MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
                NSString *fileName = [filePath lastPathComponent];
                [mailComposer addAttachmentData:fileData mimeType:@"application/pdf" fileName:fileName];
    
                [mailComposer setSubject:@"Document"]; // Use the document file name for the subject
    
                mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
    
                mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate
                self.tempPath = filePath;
                [self.viewController presentViewController:mailComposer animated:YES completion:NULL];
                
                //  remember command for close event
                tmpCommandCallbackID = command.callbackId;
                
                // result object
                NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:CDVCommandStatus_OK], @"status", nil];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObj];
                //  keep callback so another result can be sent for document close
                [pluginResult setKeepCallbackAsBool:YES];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
            }
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//MARK: - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    
    [self.viewController dismissViewControllerAnimated:YES completion:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:self.tempPath error:NULL];
    NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:CDVCommandStatus_NO_RESULT], @"status", nil];
    //result status has to be OK, otherwise the cordova success callback will not be called
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObj];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:tmpCommandCallbackID];
}

@end
