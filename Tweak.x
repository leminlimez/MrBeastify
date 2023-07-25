#import <UIKit/UIKit.h>
#import <rootless.h>

@interface YTElementsInlineMutedPlaybackView : UIView
@property (nonatomic, assign) BOOL beastified;
@end

int imageCount = 0;

%hook YTElementsInlineMutedPlaybackView
%property (nonatomic, assign) BOOL beastified;
-(instancetype)initWithFrame:(CGRect)frame {
	self = %orig;
	
	if (!self) return nil;
	
	if (!self.beastified) {
		// Pick a random image
		int imageNumber = 1 + arc4random() % (imageCount - 1);
		NSString *filepath = [NSString stringWithFormat:@"/Library/Application Support/MrBeastify/%d.png", imageNumber];
		
		// Create image
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:ROOT_PATH_NS_VAR(filepath)];

		// Create image view
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = self.frame; // x y width height
		imageView.center = self.center; // centre of thumbnail

		// Overlay image view to self (thumbnail)
		[self addSubview:imageView];
		self.beastified = true;
	}
	
	return self;
}
%end

%ctor {
	// set imageCount
	imageCount = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(@"/Library/Application Support/MrBeastify/") error:nil] count];
}
