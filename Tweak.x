#import <UIKit/UIKit.h>
#import <rootless.h>
#import "Header.h"

BOOL TweakEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:EnabledKey];
}

@interface _ASDisplayView : UIView
@end

int imageCount = 0;

NSArray *flippableText = @[@23, @37, @46];

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
		NSString *filepath = [NSString stringWithFormat:@"/Library/Application Support/MrBeastify/%d.png", imageNumber];
        
        if (isFlipped && [flippableText containsObject:[NSNumber numberWithInt:imageNumber]]) {
                filepath = [NSString stringWithFormat:@"/Library/Application Support/MrBeastify/%d_flipped.png", imageNumber];
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
	// set imageCount
	imageCount = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(@"/Library/Application Support/MrBeastify/") error:nil] count];
}

NSBundle *MrBeastifyBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"MrBeastify" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/MrBeastify")];
    });
    return bundle;
}
