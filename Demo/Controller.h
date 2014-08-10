#import <UIKit/UIKit.h>

@class FISound;

@interface Controller : UIViewController

@property(retain) FISound *sound;

- (IBAction) playSound;
- (IBAction) stopSound;

- (IBAction) updateSoundPitchFrom: (UISlider*) slider;

@end

