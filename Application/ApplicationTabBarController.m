#import "LUNTabBarController.h"


/// “private” subclass to override some missing default behavior
@interface ApplicationTabBarController : LUNTabBarController

@end


@implementation ApplicationTabBarController

- (IBAction) closeOverlay:(id) sender {
	[self hideFloatingTab];
}

- (CGFloat) floatingContentHeight {
    return 500.0f / 568.0f * self.view.bounds.size.height;
}

@end
