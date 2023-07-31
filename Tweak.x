#import <UIKit/UIKit.h>
#import <rootless.h>
#import "Header.h"

BOOL TweakEnabled() {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:EnabledKey] != nil) {
	return [[NSUserDefaults standardUserDefaults] boolForKey:EnabledKey];
    }
    return YES;
}

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
