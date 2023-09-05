#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
#import "Header.h"
#import "../YouTubeHeader/YTSettingsViewController.h"

BOOL TweakEnabled() {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:EnabledKey] != nil) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:EnabledKey];
    }
    return YES;
}

@class YTSettingsCell;

@interface YTSettingsSectionItem : NSObject
@property (nonatomic) BOOL hasSwitch;
@property (nonatomic) BOOL switchVisible;
@property (nonatomic) BOOL on;
@property (nonatomic, copy) BOOL (^switchBlock)(YTSettingsCell *, BOOL);
@property (nonatomic) int settingItemId;
- (instancetype)initWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription;
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
@end

@interface _ASDisplayView : UIView
@end

int imageCount = 0;

NSArray *flippableText = @[@23, @37, @46];

NSBundle *MrBeastifyBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"MrBeastify" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/MrBeastify.bundle")];
    });
    return bundle;
}

NSString *MrBeastifyBundlePath() {
    return [MrBeastifyBundle() bundlePath];
}

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    if (category == 1) {
        YTSettingsSectionItem *mrBeastifyOption = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Enable MrBeastify" titleDescription:@"Adds MrBeast to the YouTube Thumbnails."];
        mrBeastifyOption.hasSwitch = YES;
        mrBeastifyOption.switchVisible = YES;
        mrBeastifyOption.on = TweakEnabled();
        mrBeastifyOption.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey];
            return YES;
        };
        [sectionItems addObject:mrBeastifyOption];
    }
    %orig(sectionItems, category, title, titleDescription, headerHidden);
}
%end

%hook _ASDisplayView
-(void)layoutSubviews {
    %orig;
 
    if (!TweakEnabled()) return;

    if (![self.accessibilityIdentifier isEqualToString:@"eml.timestamp"]) return;

    for (UIView *subview in self.superview.superview.subviews) {
        // Ensure it's suitable to add our image
        if (subview.frame.size.height < 90 || subview.frame.size.height > 300) continue;
        if (subview.subviews.count != 1) continue;
  
        // Decide whether to flip or not
        BOOL isFlipped = arc4random_uniform(4) == 1;

        // Pick a random image
        int imageNumber = 1 + arc4random() % (imageCount - 1);

        // from the nsbundle
        NSString *filepath = [NSString stringWithFormat:@"%@/%d.png", MrBeastifyBundlePath(), imageNumber];
        
        if (isFlipped && [flippableText containsObject:[NSNumber numberWithInt:imageNumber]]) {
            filepath = [NSString stringWithFormat:@"%@/%d_flipped.png", MrBeastifyBundlePath(), imageNumber];
        }
        
        // Create image
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:ROOT_PATH_NS_VAR(filepath)];

        // Create image view
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = subview.frame; // same size as thumbnail
        imageView.center = subview.center; // centre of thumbnail
        if (isFlipped && ![flippableText containsObject:[NSNumber numberWithInt:imageNumber]]) {
            // Flip the UI Image
            imageView.transform = CGAffineTransformMakeScale(-1, 1);
        }

        [subview addSubview:imageView];

        break;
    }
}
%end

%ctor {
    NSBundle *tweakBundle = MrBeastifyBundle();
    imageCount = (int)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[tweakBundle bundlePath] error:nil].count;
}
