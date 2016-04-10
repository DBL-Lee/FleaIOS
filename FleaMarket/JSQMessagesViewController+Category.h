//
//  JSQMessagesViewController+Category.h
//  FleaMarket
//
//  Created by Zichuan Huang on 07/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

@interface JSQMessagesViewController (Category)

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

- (void)keyboardController:(JSQMessagesKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame;

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;
- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom;
@end
