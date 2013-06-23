//
//  UIDataTable.h
//  imCore
//
//  Created by conis on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 
*/
#import <UIKit/UIKit.h>

@protocol UIDataTableDelegate <NSObject>
-(NSString *) onGetMacro: (NSString *)macro guid:(NSInteger)guid;
-(void) onSelectDataTableRow: (NSInteger) guid data: (NSDictionary *) data;
-(void) onChangeSwitchValue: (NSInteger) guid value: (BOOL) value;
-(BOOL) onDisplayDataRow: (NSInteger) guid;
@end

@interface UIDataTable : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
  NSDictionary *dataSource_;
  id<UIDataTableDelegate> delegate_;
  UITableView *tbMain;
  NSInteger cellLeftPadding_;
  NSInteger cellRightPadding_;
  NSInteger rowHeight_;
  NSInteger captionWidth_;
  NSString *dataPath_;
}

@property (nonatomic, retain) NSString *dataPath;
@property (nonatomic, retain) id<UIDataTableDelegate> delegate;
@property (nonatomic, retain) NSDictionary *dataSource;

//根据plist的路径初始化，dataPath：plist的路径
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
-(void) reloadData;
-(id) getRowValue: (NSDictionary *) data section: (NSInteger) section row: (NSInteger) row;
-(id) getValueWithGuid: (NSDictionary *) data section: (NSInteger) section guid:(NSInteger)guid;
@end
