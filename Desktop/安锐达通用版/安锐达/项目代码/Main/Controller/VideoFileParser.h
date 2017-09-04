#include <objc/NSObject.h>

@interface VideoPacket : NSObject

@property uint8_t* buffer;
@property uint32_t size;

@end

@interface VideoFileParser : NSObject

-(BOOL)open:(NSString*)fileName;
-(VideoPacket *)nextPacket;
-(void)close;

@end
