//
//	KeyboardEnabledTextField.m
//	FreckleForMac
//
//	Created by Hernan on 11/17/13.
//	Copyright (c) 2013 Hernan. All rights reserved.
//
//	Special thanks to Sun Wei for his post:
//	http://sunbruce.wordpress.com/2008/05/19/how-to-enable-keyboard-copycutpaste-shortcuts-in-nstextfield/
//

#import "KeyboardEnabledTextField.h"

@implementation KeyboardEnabledTextField

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	return self;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	if (([theEvent type] == NSKeyDown) && ([theEvent modifierFlags] & NSCommandKeyMask))
	{
		NSResponder * responder = [[self window] firstResponder];
		
		if ((responder != nil) && [responder isKindOfClass:[NSTextView class]])
		{
			NSTextView * textView = (NSTextView *)responder;
			NSRange range = [textView selectedRange];
			bool bHasSelectedTexts = (range.length > 0);
			
			unsigned short keyCode = [theEvent keyCode];
			
			bool bHandled = false;
			
			//6 Z, 7 X, 8 C, 9 V
			if (keyCode == 6)
			{
				if ([[textView undoManager] canUndo])
				{
					[[textView undoManager] undo];
					bHandled = true;
				}
			}
			else if (keyCode == 7 && bHasSelectedTexts)
			{
				[textView cut:self];
				bHandled = true;
			}
			else if (keyCode== 8 && bHasSelectedTexts)
			{
				[textView copy:self];
				bHandled = true;
			}
			else if (keyCode == 9)
			{
				[textView paste:self];
				bHandled = true;
			}
			// Added by Hernan
			else if (keyCode == 0) // A
			{
				[textView selectAll:self];
				bHandled = true;
			}
			
			if (bHandled)
				return YES;
		}
	}
	
	return NO;
}

@end
