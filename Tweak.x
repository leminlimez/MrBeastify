#import <UIKit/UIKit.h>
#import <rootless.h>

@interface YTElementsInlineMutedPlaybackView : UIView
@property (nonatomic, assign) BOOL beastified;
@end

%hook YTElementsInlineMutedPlaybackView
%property (nonatomic, assign) BOOL beastified;
-(instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    
    if (!self) return nil;
    
    if (!self.beastified) {
        // Get a random image
        int lowerBound = 1;
        int upperBound = 59;
        int img = lowerBound + arc4random() % (upperBound - lowerBound);
        
        // Make string
        NSString *str = [NSString stringWithFormat:@"/Library/Application Support/MrBeastify/%d.png", img];
        
        // Create image
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:ROOT_PATH_NS_VAR(str)];

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
