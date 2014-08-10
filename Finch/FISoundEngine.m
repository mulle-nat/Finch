#import "FISoundEngine.h"

#import "FISoundContext.h"
#import "FISoundDevice.h"
#import "FISound.h"

@interface FISoundEngine ()
@property(strong) FISoundContext *soundContext;
@end

@implementation FISoundEngine

#pragma mark Initialization

- (id) init
{
   FISoundDevice   *soundDevice;
   
    self = [super init];

    _soundMap     = [NSMutableDictionary new];
    soundDevice  = [[FISoundDevice defaultSoundDevice] retain];
    _soundContext = [[FISoundContext contextForDevice:soundDevice error:NULL] retain];
    if (!_soundContext) {
        return nil;
    }

    [self setSoundBundle:[NSBundle bundleForClass:[self class]]];
    [_soundContext setCurrent:YES];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    [_soundMap release];
    [_soundContext release];
   
    [super dealloc];
}

+ (id) sharedEngine
{
    static dispatch_once_t once;
    static FISoundEngine *sharedEngine = nil;
    dispatch_once(&once, ^{
        sharedEngine = [self new];
    });
    return sharedEngine;
}

#pragma mark Sound Loading

- (FISound*) soundNamed: (NSString*) soundName
           maxPolyphony: (NSUInteger) voices
                  error: (NSError**) error
{
   FISound   *sound;
   NSString  *path;
   
   NSParameterAssert( _soundBundle);
   
   @synchronized( self)
   {
      sound = [_soundMap objectForKey:soundName];
      if( ! sound)
      {
         path  = [_soundBundle pathForResource:soundName
                                        ofType:nil
                                   inDirectory:@"Sounds"];
         if( path)
         {
            sound = [[[FISound alloc] initWithPath:path
                                      maxPolyphony:voices
                                             error:error] autorelease];
            if( sound)
               [_soundMap setObject:sound
                             forKey:soundName];
            else
               *error = [NSError errorWithDomain:@"FISoundEngine: bad content"
                                            code:204
                                        userInfo:nil];
            
         }
         else
            *error = [NSError errorWithDomain:@"FISoundEngine: file not found"
                                         code:404
                                     userInfo:nil];
      }
   }
   return( sound);
}


- (FISound*) soundNamed: (NSString*) soundName error: (NSError**) error
{
    return [self soundNamed:soundName
    maxPolyphony:1
    error:error];
}

#pragma mark Interruption Handling

// TODO: Resume may fail here, and in that case
// we would like to keep _suspended at YES.
- (void) setSuspended: (BOOL) newValue
{
    if (newValue != _suspended) {
        _suspended = newValue;
        if (_suspended) {
            [_soundContext setCurrent:NO];
            [_soundContext setSuspended:YES];
        } else {
            [_soundContext setCurrent:YES];
            [_soundContext setSuspended:NO];
        }
    }
}

@end