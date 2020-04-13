@import Foundation;

@class ARTClientOptions;
@class AblyFlutterSurfaceRealtime;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject

-(NSNumber *)createRealtimeWithOptions:(ARTClientOptions *)options;

-(nullable AblyFlutterSurfaceRealtime *)realtimeWithHandle:(NSNumber *)handle;

/**
 This method must be called from the main dispatch queue. It may only be called
 once.
 
 @param completionHandler Will be called on the main dispatch queue when all
 platform objects have been closed down cleanly.
 */
-(void)disposeWithCompletionHandler:(dispatch_block_t)completionHandler;

@end

NS_ASSUME_NONNULL_END