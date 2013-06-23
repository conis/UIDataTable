//
//  UIDataTable.m
//  imCore
//
//  Created by conis on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIDataTable.h"

@interface UIDataTable(Private)
-(NSDictionary *) getRowData: (NSDictionary *) data section: (NSInteger) section row: (NSInteger) row;
-(void) drawCell: (UITableViewCell *) cell data: (NSDictionary *) data;
-(void) drawCellSignleLine: (UITableViewCell *) cell data: (NSDictionary *) data;
-(void) drawCellCaptionContent: (UITableViewCell *) cell data: (NSDictionary *) data;
-(void) drawCellSwitch: (UITableViewCell *) cell data: (NSDictionary *) data;
-(void) drawCellInput: (UITableViewCell *) cell data: (NSDictionary *) data;
-(void) clickedSwitch: (UISwitch *) sender;
-(UILabel *) addLabel:(UITableViewCell *)cell frame:(CGRect)frame text:(NSString *)text align:(NSString *)align style: (NSDictionary *) style;
-(void) setLabelStyle: (UILabel *) label style: (NSDictionary *) style;
-(CGRect) getCellFrame: (UITableViewCell *) cell;
-(NSArray *) getSectionAllRowDatas: (NSDictionary *) data section: (NSInteger) section;
//获取caption的宽度
-(NSInteger) getCaptionWidth: (NSDictionary *) data;
-(NSDictionary *) getConfigData;
-(void) saveData: (NSDictionary *) rowData section: (NSInteger) section row: (NSInteger) row;
-(NSTextAlignment) getTextAlign: (NSString *)align;
@end

@implementation UIDataTable
@synthesize dataSource = dataSource_, delegate = delegate_, dataPath = dataPath_;
//定义常量
static NSString *keyConfig = @"config";
static NSString *keySectionHeader = @"title";
static NSString *keySectionItems = @"rows";
static NSString *keySections = @"sections";
static NSString *keyRowLeftMargin = @"leftMargin";
static NSString *keyRowRightMargin = @"rightMargin";
static NSString *keyRowType = @"type";
static NSString *keyRowGuid = @"guid";
static NSString *keyRowContent = @"content";
static NSString *keyRowCaption = @"caption";
static NSString *keyRowHeight = @"height";
static NSString *keyRowAlign = @"align";
static NSString *keyRowValue = @"value";
static NSString *keyCaptionAlign = @"captionAlign";
static NSString *keyContentAlign = @"contentAlign";
static NSString *keyRowStyle = @"style";
static NSInteger kRightMargin = 15;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
      tbMain = [[UITableView alloc] initWithFrame:frame style: style];
      tbMain.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      tbMain.backgroundColor = [UIColor clearColor];
      tbMain.dataSource = self;
      tbMain.delegate = self;
      [self addSubview: tbMain];
      [tbMain release];
    }
    return self;
}

-(void) setDataSource:(NSDictionary *)dataSource
{
  dataSource_ = [dataSource retain];
  NSDictionary *config = [self getConfigData];
  cellLeftPadding_ = [[config objectForKey: @"leftPadding"] intValue];
  cellRightPadding_ = [[config objectForKey: @"rightPadding"] intValue]; 
  rowHeight_ = [[config objectForKey: @"rowHeight"] intValue];
  captionWidth_ = [[config objectForKey: @"captionWidth"] intValue];
}
#pragma -
#pragma mark Private
//获取每一行的数据
-(NSDictionary *) getRowData:(NSDictionary *)data section:(NSInteger)section row:(NSInteger)row
{
  NSArray *sections = [self getSectionAllRowDatas: data section: section];
  if(sections == nil || row >= sections.count) return nil;
  return [sections objectAtIndex: row];
}

//绘制单元格
-(void) drawCell:(UITableViewCell *)cell data:(NSDictionary *)data
{
  NSNumber *guid = [data objectForKey: keyRowGuid];
  if(self.delegate &&
     [self.delegate respondsToSelector: @selector(onDisplayDataRow:)] && 
     guid != nil &&
     ![self.delegate onDisplayDataRow: [guid intValue]]){
    return;
  }
  
  if(guid == nil) cell.accessoryType = UITableViewCellAccessoryNone;
  //获取数据类型，根据类型创建不同的节点
  NSString *rowType = [data objectForKey: keyRowType];
  if([rowType isEqualToString: @"text"]){
    [self drawCellSignleLine:cell data:data];
  }else if ([rowType isEqualToString: @"kv"]){
    [self drawCellCaptionContent:cell data:data];
  }else if([rowType isEqualToString: @"switch"]){
    [self drawCellSwitch:cell data:data];
  }else if([rowType isEqualToString: @"input"]){
    [self drawCellInput:cell data: data];
  }
}

//绘制单行的文本
-(void) drawCellSignleLine:(UITableViewCell *)cell data:(NSDictionary *)data
{
  CGRect rect = [self getCellFrame: cell];
  NSString *align = [data objectForKey: keyRowAlign];
  NSDictionary *style = [data objectForKey: keyRowStyle];
  [self addLabel:cell
           frame:rect
            text:[data objectForKey: keyRowContent]
           align:align style: style];
}

//绘制开关
-(void) drawCellSwitch:(UITableViewCell *)cell data:(NSDictionary *)data
{
  CGRect cellRect = cell.frame;
  UISwitch *sw = [[UISwitch alloc] init];
  [sw addTarget:self action:@selector(clickedSwitch: ) forControlEvents:UIControlEventValueChanged];
  //重新设置位置
  CGRect swRect = sw.frame;
  swRect.origin.y = (cellRect.size.height - swRect.size.height) / 2;
  swRect.origin.x = cellRect.size.width - swRect.size.width - 10;
  sw.frame = swRect;
  sw.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  sw.on = [[data objectForKey: keyRowValue] boolValue];
  [cell.contentView addSubview: sw];
  
  //绘制Label
  CGRect rect = [self getCellFrame: cell];
  rect.size.width = swRect.origin.x;
  [self addLabel:cell frame:rect text:[data objectForKey: keyRowCaption] align: @"left" style:nil];
}

//绘制标题与内容的行
-(void) drawCellCaptionContent:(UITableViewCell *)cell data:(NSDictionary *)data
{  
  //创建label
  CGRect rect = [self getCellFrame: cell];
  rect.size.width -= kRightMargin;
  CGFloat cellWidth = rect.size.width;
  rect.size.width = [self getCaptionWidth: data];
  [self addLabel:cell frame:rect text:[data objectForKey: keyRowCaption] align:[data objectForKey: keyCaptionAlign] style:nil];
  //获取content的值
  //判断是否有宏
  NSString *macro = [data objectForKey: @"macro"];
  NSInteger guid = [[data objectForKey: keyRowGuid] intValue];
  NSString *content;
  if(self.delegate &&
     [self.delegate respondsToSelector: @selector(onGetMacro:guid:)] &&
     macro != nil){
    content = [self.delegate onGetMacro: macro guid:guid];
  }else{
    content = [data objectForKey: keyRowContent];
  }   
  rect.origin.x = rect.size.width;
  rect.size.width = cellWidth - rect.size.width;
  [self addLabel:cell frame:rect text: content align:[data objectForKey: keyContentAlign] style: nil];
}

//绘制input
-(void) drawCellInput:(UITableViewCell *)cell data:(NSDictionary *)data{
  //创建label
  CGRect rect = [self getCellFrame: cell];
  rect.size.width -= kRightMargin;
  CGFloat cellWidth = rect.size.width;
  rect.size.width = [self getCaptionWidth: data];
  [self addLabel:cell frame:rect text:[data objectForKey: keyRowCaption] align:[data objectForKey: keyCaptionAlign] style:nil];
  
  
  CGFloat height = 25;
  rect.origin.x = rect.size.width;
  rect.origin.y = (rect.size.height - height) / 2;
  rect.size.width = cellWidth - rect.size.width;
  
  //创建输入框
  UITextField *txtField = [[UITextField alloc] initWithFrame: rect];
  txtField.placeholder = [data objectForKey: @"placeholder"];
  txtField.text = [data objectForKey: @"value"];
  [cell.contentView addSubview: txtField];
}

//添加Label
-(UILabel *) addLabel:(UITableViewCell *)cell frame:(CGRect)frame text:(NSString *)text align:(NSString *)align style: (NSDictionary *) style
{
  UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
  lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  lbl.text = NSLocalizedString(text, nil);
  //lbl.textAlignment = [self getTextAlign: align];
  lbl.backgroundColor = [UIColor clearColor];
  [cell.contentView addSubview: lbl];
  [self setLabelStyle: lbl style:style];
  [lbl release];
  return lbl;
}

//设置Label的样式
-(void) setLabelStyle:(UILabel *)label style:(NSDictionary *)style
{
  if(style == nil) return;
  //设置颜色
  NSArray *color = [style objectForKey: @"color"];
  if(color.count == 4){
    label.textColor = [UIColor
                       colorWithRed:[color[0] floatValue]
                       green:[color[1] floatValue]
                       blue:[color[2] floatValue]
                       alpha:[color[3] floatValue]];
  };

  //设置字体
  NSString *strFont = [style objectForKey: @"font"];
  if(strFont != nil){
    UIFont *font = label.font;
    label.font = [UIFont fontWithName:strFont size:font.pointSize];
  };
  
  //设置字体大小
  NSNumber *fSize = [style objectForKey: @"font-size"];
  if(fSize != nil){
    UIFont *font = label.font;
    label.font = [UIFont fontWithName:font.fontName size: [fSize intValue]];
  };
}

//获取cell的实际大小
-(CGRect) getCellFrame:(UITableViewCell *)cell
{
  CGRect rect = cell.frame;
  rect.size.width -= 20;
  rect.origin.x = 5;
  rect.size.height -= 5;
  return rect;
}

-(NSTextAlignment) getTextAlign:(NSString *)align{
  if([align isEqualToString:@"right"]) return NSTextAlignmentRight;
  if([align isEqualToString:@"center"]) return NSTextAlignmentCenter;
  return NSTextAlignmentLeft;
}

//获取配置的数据
-(NSDictionary *) getConfigData
{
  return [dataSource_ objectForKey: keyConfig];
}

//获取section下的所有行数据
-(NSArray *) getSectionAllRowDatas:(NSDictionary *)data section:(NSInteger)section
{
  //获取section
  NSArray *sections = [data objectForKey: keySections];
  //获取某个节点的数据
  NSDictionary *dict = [sections objectAtIndex: section];
  //获取行数据
  return [dict objectForKey: keySectionItems];
}

-(NSInteger) getCaptionWidth:(NSDictionary *)data
{
  static NSString *kCaptionWidth = @"captionWidth";
  NSNumber *captionW = [data  objectForKey: kCaptionWidth];
  if(captionW == nil) return captionWidth_;
  return [captionW intValue];
}
#pragma -
#pragma mark 事件处理
-(void) saveData:(NSDictionary *)rowData section:(NSInteger)section row:(NSInteger)row
{
  NSMutableDictionary *optionData = [[NSMutableDictionary alloc] initWithContentsOfFile: self.dataPath];
  //修改items/item[section]/items/item[row]
  NSMutableArray *sectionItems = [NSMutableArray arrayWithArray: [self getSectionAllRowDatas: optionData section: section]];
  [sectionItems replaceObjectAtIndex: row withObject: [NSDictionary dictionaryWithDictionary:rowData]];
  
  //修改items/item[section]
  NSMutableArray *items = [NSMutableArray arrayWithArray: [optionData objectForKey: keySections]];
  
  //修改items/item[section]/items
  NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithDictionary: [items objectAtIndex: section]];
  [sectionDict setValue: sectionItems forKey:keySectionItems];
  [items replaceObjectAtIndex: section withObject: sectionDict];
  
  //修改items
  [optionData setValue: items forKey: keySections];
  
  [optionData writeToFile: self.dataPath atomically: YES];
  [optionData release];
}
//switch事件的改变
-(void) clickedSwitch:(UISwitch *)sender
{
  UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
  NSIndexPath *indexPath = [tbMain indexPathForCell: cell];
  NSInteger row = [indexPath row];
  NSInteger section = [indexPath section];
  
  //修改items/item[section]/items/item[row]
  NSMutableDictionary *rowData = [NSMutableDictionary dictionaryWithDictionary: [self getRowData: dataSource_ section: section row:row]];
  [rowData setValue:[NSNumber numberWithBool: sender.on] forKey: keyRowValue];
  //[self saveData: rowData section:section row: row];
  
  NSNumber *guid = [rowData objectForKey: keyRowGuid];
  if(self.delegate &&
     [self.delegate respondsToSelector: @selector(onChangeSwitchValue:value:)]){
    [self.delegate onChangeSwitchValue: [guid intValue] value: sender.on];
  }
}
#pragma -
#pragma mark 实现Table的协议
//section的数量
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
  NSArray *items = [dataSource_ objectForKey: keySections];
  return items.count;
}

//选择某行
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath: indexPath animated:YES];
  NSDictionary *data = [self getRowData: dataSource_ section: [indexPath section] row: [indexPath row]];
  NSNumber *guid = [data objectForKey: keyRowGuid];
  if(guid == nil) return;   //必需有一个guid才响应事件
  if(self.delegate &&
     [self.delegate respondsToSelector: @selector(onSelectDataTableRow:data:)]){
    [self.delegate onSelectDataTableRow:[guid intValue] data: data];
  }
}

//获取section的标题
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  //取sections
  NSArray *sections = [dataSource_ objectForKey: keySections];
  //取具体的section
  NSDictionary *dict = [sections objectAtIndex: section];
  return [dict objectForKey: keySectionHeader];
}

//获取行数据
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSArray *rows = [self getSectionAllRowDatas: dataSource_ section: section];
  return rows.count;
}

//获取高度
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger section = [indexPath section];
  NSInteger row = [indexPath row];
  NSDictionary *dictRow = [self getRowData: dataSource_ section:section row:row];
  
  //判断是否要隐藏
  NSNumber *guid = [dictRow objectForKey: keyRowGuid];
  //NSLog(@"%d, %@", [guid intValue],  dictRow);
  if(self.delegate &&
     [self.delegate respondsToSelector: @selector(onDisplayDataRow:)] &&
     guid != nil &&
     ![self.delegate onDisplayDataRow: [guid intValue]]){
    return 0;
  };
  
  NSNumber *rowHeight = [dictRow objectForKey: keyRowHeight];
  
  //获取到正确的值返回
  if(rowHeight != nil) return [rowHeight intValue];
  
  //没有行高，查找默认的高度
  NSDictionary *dictSection = [dataSource_ objectForKey: keyConfig];
  rowHeight = [dictSection objectForKey: keyRowHeight];
  //如果有默认值，则使用
  if (rowHeight != nil) return [rowHeight intValue];
  return 40;
}

//获取每一行的数据
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger row = [indexPath row];
  static NSString *kCellID = @"cellID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
    NSDictionary *dictRow = [self getRowData: dataSource_
                                     section:[indexPath section]
                                         row:row];
    //获取selectionStyle
    UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleBlue;
    //读取配置中的selectionStyle
    
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = selectionStyle;
    [self drawCell: cell data: dictRow];
  }
  return  cell;
}

#pragma -
#pragma mark Public Method
-(void) reloadData
{
  [tbMain reloadData];
}

//读取指定行的值
-(id) getRowValue: (NSDictionary *) data section: (NSInteger) section row: (NSInteger) row
{
  NSDictionary *rowData = [self getRowData: data section:section row:row];
  if(rowData != nil){
    return [rowData objectForKey: keyRowValue];
  }else{
    return nil;
  }
}

//根据guid获取值
-(id) getValueWithGuid:(NSDictionary *)data section:(NSInteger)section guid:(NSInteger)guid
{
  NSArray *items = [self getSectionAllRowDatas:data section:section];
  id result = nil;
  for(int i = 0; i < items.count; i ++){
    NSDictionary *dict = [items objectAtIndex: i];
    if([[dict objectForKey: keyRowGuid] intValue] == guid){
      //NSLog(@"%@", dict);
      result = [dict objectForKey: keyRowValue];
      break;
    }
  }
  return  result;
}
@end
