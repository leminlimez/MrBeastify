#import <UIKit/UIKit.h>
#import <rootless.h>

@interface YTElementsInlineMutedPlaybackView : UIView
@end

%hook YTElementsInlineMutedPlaybackView
-(void)didMoveToWindow {
    %orig;
    
    // Create image
    // you should obv load this from a file or smth. just using plus here as a sample image
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/MrBeastify/1.png")];

    // Create image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.frame; // x y width height
    imageView.center = self.center; // centre of thumbnail

    // Overlay image view to self (thumbnail)
    [self addSubview:imageView];
}
%end
