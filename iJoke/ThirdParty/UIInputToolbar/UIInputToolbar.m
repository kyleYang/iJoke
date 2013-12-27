/*
 *  UIInputToolbar.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "UIInputToolbar.h"

@interface UIInputToolbar()


@property (nonatomic, retain, readwrite) UIExpandingTextView *textView;
@property (nonatomic, retain, readwrite) PanguCheckButton *anonymousButton;
@property (nonatomic, retain, readwrite) UIBarButtonItem *inputButton;

@end


@implementation UIInputToolbar

@synthesize textView;
@synthesize inputButton;
@synthesize delegate;
@synthesize anonymousButton;

-(void)inputButtonPressed
{
    if ([delegate respondsToSelector:@selector(inputButtonPressed:anonymous:)])
    {
        [delegate inputButtonPressed:self.textView.text anonymous:self.anonymousButton.isChecked];
    }
    
    /* Remove the keyboard and clear the text */
    [self.textView resignFirstResponder];
//    [self.textView clearText];
//    [self.anonymousButton setChecked:FALSE];
}

- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView;{
    
    if ([delegate respondsToSelector:@selector(inputButtonPressed:anonymous:)])
    {
        [delegate inputButtonPressed:self.textView.text anonymous:self.anonymousButton.isChecked];
    }

    return YES;
}

- (void)resignFirstResponder{
    
    [self.textView resignFirstResponder];
}


- (void)clearText{
    [self.textView resignFirstResponder];
    [self.textView clearText];
    [self.anonymousButton setChecked:FALSE];
}



-(void)setupToolbar:(NSString *)buttonLabel
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.tintColor = [UIColor lightGrayColor];
    
    /* Create UIExpandingTextView input */
    self.textView = [[[UIExpandingTextView alloc] initWithFrame:CGRectMake(5, 7, 230, CGRectGetHeight(self.bounds)-20)] autorelease];
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.textView];
    
    self.anonymousButton = [[[PanguCheckButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textView.frame),0, 30,CGRectGetHeight(self.bounds))] autorelease];
    self.anonymousButton.style = CheckButtonStyleBox;
    self.anonymousButton.label.text = NSLocalizedString(@"joke.comment.anonymous", nil);
    self.anonymousButton.label.font = [UIFont systemFontOfSize:14];
    [self.anonymousButton setChecked:FALSE];
   
    self.inputButton = [[[UIBarButtonItem alloc] initWithCustomView:self.anonymousButton] autorelease];
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    NSArray *items = [NSArray arrayWithObjects:flexItem,self.inputButton, nil];
    [self setItems:items animated:NO];
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:@"Send"];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	CGRect textFrame = self.textView.frame;
	textFrame.size.width = MAX(230, frame.size.width - textFrame.origin.x - self.anonymousButton.frame.size.width-30);
	self.textView.frame = textFrame;
    
}

-(id)init
{
    if ((self = [super init])) {
        [self setupToolbar:@"Send"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    /* Draw custon toolbar background */
    UIImage *backgroundImage = [UIImage imageNamed:@"toolbarbg.png"];
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(backgroundImage.size.height / 2 - 1, backgroundImage.size.width / 2 - 1, backgroundImage.size.height / 2, backgroundImage.size.width / 2)];
    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGRect i = self.inputButton.customView.frame;
    i.origin.y = (self.frame.size.height - i.size.height)/2;
    self.inputButton.customView.frame = i;
}

- (void)dealloc
{
	textView.delegate = nil;
    [textView release];
    [inputButton release];
    [anonymousButton release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.frame = r;
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
//    if ([expandingTextView.text length] > 0)
//        self.inputButton.enabled = YES;
//    else
//        self.inputButton.enabled = NO;
}


@end
