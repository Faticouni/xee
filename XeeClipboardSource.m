#import "XeeClipboardSource.h"
//#import "XeeNSImage.h"
#import "CSMemoryHandle.h"
#import "CSMultiHandle.h"
#import "XeeImage.h"


@implementation XeeClipboardSource

+(BOOL)canInitWithPasteboard:(NSPasteboard *)pboard
{
//	return [NSBitmapImageRep canInitWithPasteboard:[NSPasteboard generalPasteboard]];

	if([[pboard types] containsObject:NSTIFFPboardType]) return YES;
	if([[pboard types] containsObject:NSPICTPboardType]) return YES;
	return NO;
}

+(BOOL)canInitWithGeneralPasteboard
{
	return [self canInitWithPasteboard:[NSPasteboard generalPasteboard]];
}

-(id)initWithPasteboard:(NSPasteboard *)pboard
{
	if(self=[super init])
	{
		image=nil;

		NSString *type=[pboard availableTypeFromArray:[NSArray arrayWithObjects:NSTIFFPboardType,NSPICTPboardType,nil]];
		NSData *data=[pboard dataForType:type];

		CSHandle *handle;
		if([type isEqual:NSPICTPboardType])
		{
			NSMutableData *head=[NSMutableData dataWithLength:512];
			handle=[CSMultiHandle multiHandleWithHandles:
				[CSMemoryHandle memoryHandleForReadingData:head],
				[CSMemoryHandle memoryHandleForReadingData:data],
			nil];
		}
		else handle=[CSMemoryHandle memoryHandleForReadingData:data];
NSLog(@"what");
[[[[handle copy] autorelease] remainingFileContents] writeToFile:@"/Users/dag/Desktop/test.pict" atomically:NO];

		image=[[XeeImage imageForHandle:handle] retain];

		if(image) return self;
		else NSBeep();

/*		NSBitmapImageRep *rep=[NSBitmapImageRep imageRepWithPasteboard:pboard];
		if(rep)
		{
			image=[[XeeNSImage alloc] initWithNSBitmapImageRep:rep];
			if(image) return self;
		}*/
		[self release];
	}

	return nil;
}

-(id)initWithGeneralPasteboard
{
	return [self initWithPasteboard:[NSPasteboard generalPasteboard]];
}

-(void)dealloc
{
	[image release];
	[super dealloc];
}

-(int)numberOfImages { return 1; }

-(int)indexOfCurrentImage { return 0; }

-(NSString *)descriptiveNameOfCurrentImage { return @"Clipboard contents"; }

-(BOOL)isNavigatable { return NO; }

-(void)pickImageAtIndex:(int)index next:(int)next
{
	if(![image loaded]) [image runLoader];
	[self triggerImageChangeAction:image];
}


@end
