//
//  ViewController.m
//  DataTable
//
//  Created by conis on 13-6-23.
//  Copyright (c) 2013年 conis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //调用示例
  UIDataTable *dataTable = [[UIDataTable alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  //定义plist的路径
  NSString *plist = [[NSBundle mainBundle] pathForResource:@"option" ofType:@"plist"];
  //设置委托，需要在h文件加加入UIDataTableDelegate接口
  dataTable.delegate = self;
  
  //第一种方式，直接给出plist的路径
  //dataTable.dataPath = plist;
  
  //第二种方式，可以直接使用NSDictionary
  //dataTable.dataSource = [NSDictionary dictionaryWithContentsOfFile: plist];
  
  //第三种方式，读取JSON数据，并转换为NSDictionary。
  //读取JSON可以使用内置(iOS5.0+)的NSJSONSerialization，也可以使用JSONKit
  NSError *err = nil;
  //读取samples.json，当然也可以读取其它文件，甚至可以从互联网上下载配置文件
  NSString *jsonPath =  [[NSBundle mainBundle] pathForResource:@"option" ofType:@"json"];
  //将JSON文件读取到NSData中
  NSData *data = [[NSData alloc] initWithContentsOfFile: jsonPath];
  //读取JSON并转换，赋值给dataSource
  NSDictionary *dictSamples = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
  if(err != nil) NSLog(@"Error: %@", err);
  dataTable.dataSource = dictSamples;
  //将dataTable加入到view
  [self.view addSubview: dataTable];
  //release
  [dataTable release];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取宏字符
-(NSString *) onGetMacro: (NSString *)macro guid:(NSInteger)guid
{
  //如果宏是要获取软件的版本，则 
  if([macro isEqualToString: @"version"]){
    return @"1.0";
  };
  return nil;
}

//是否显示某行
-(BOOL) onDisplayDataRow:(NSInteger)guid
{
  //iOS5以下，不要显示分享到Twitter，因为不支持
  float version = [[[UIDevice currentDevice] systemVersion] floatValue]; 
  if(guid == 3 && version < 5.0f) return NO;
  return YES;
}

//选择列表中的某一行
-(void) onSelectDataTableRow:(NSInteger)guid data:(NSDictionary *)data
{
  NSString *message;
  switch (guid) {
    case 2:
      message = @"执行用户反馈操作";
      break;
    case 5:
      message = @"修改密码";
      break;
  }
  NSLog(message, nil);
}

//改变了switch的值，通过这里可以获取switch的改变事件
-(void) onChangeSwitchValue:(NSInteger)guid value:(BOOL)value
{
  NSString *message = value ? @"选择" : @"取消选择";
  NSLog(message, nil);
}
@end
