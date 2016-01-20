#import <MessageUI/MessageUI.h>
#import "RNShare.h"
#import "RCTConvert.h"
#import "RCTLog.h"

@interface CustomUIActivityItemProvider : UIActivityItemProvider
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSDictionary * fields;
@end
@implementation CustomUIActivityItemProvider
- (id)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    NSString *end = @"";
    if (activityType == UIActivityTypePostToFacebook) {
        end = @"_facebook";
    } else if (activityType == UIActivityTypePostToTwitter) {
        end = @"_twitter";
    } else if (activityType == UIActivityTypeMessage) {
        end = @"_text";
    } else if (activityType == UIActivityTypeMail) {
        end = @"_email";
    }
    
    NSString *key = [NSString stringWithFormat:@"subject%@", end];
    
    NSString *data = [RCTConvert NSString:self.fields[key]];
    if (data == nil) {
        data = [RCTConvert NSString:self.fields[@"subject"]];
    }

    return data;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([self.type isEqualToString:@"image"]) return self.placeholderItem;
    if ([self.type isEqualToString:@"url"]) return self.placeholderItem;

    
    NSString *end = @"";
    if (activityType == UIActivityTypePostToFacebook) {
		end = @"_facebook";
    } else if (activityType == UIActivityTypePostToTwitter) {
		end = @"_twitter";
    } else if (activityType == UIActivityTypeMessage) {
		end = @"_text";
    } else if (activityType == UIActivityTypeMail) {
		end = @"_email";
    } 
	
	NSString *key = [NSString stringWithFormat:@"%@%@", self.type, end];

	NSString *data = [RCTConvert NSString:self.fields[key]];
    if (data == nil) {
		data = [RCTConvert NSString:self.fields[self.type]];
	}
    
	return data;
}
@end

@implementation RNShare

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(open:(NSDictionary *)options complete:(RCTResponseSenderBlock)callback)
{
   
    CustomUIActivityItemProvider *text = [[CustomUIActivityItemProvider alloc] initWithPlaceholderItem:[RCTConvert NSString:options[@"body"]]];
    text.type = @"body";
    text.fields = options;
    CustomUIActivityItemProvider *url = [[CustomUIActivityItemProvider alloc] initWithPlaceholderItem:[NSURL URLWithString:[RCTConvert NSString:options[@"url"]]]];
    url.type = @"url";
    url.fields = options;
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[RCTConvert NSString:options[@"image"]]]];
    CustomUIActivityItemProvider *image = [[CustomUIActivityItemProvider alloc] initWithPlaceholderItem:[UIImage imageWithData: imageData]];
    image.type = @"image";
    image.fields = options;
    NSArray *itemsToShare = @[text, url, image];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         @"com.apple.mobilenotes.SharingExtension",
                                         @"com.apple.reminders.RemindersEditorExtension",
                                         UIActivityTypeAirDrop];
    activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        callback(@[completed?@1 :@0, activityType == nil ? @"" : activityType]);
    };
    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [root presentViewController:activityVC animated:YES completion:nil];
}
@end
