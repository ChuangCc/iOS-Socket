//
//  ViewController.m
//  iOS-CocoaAsyncSocket-Client
//
//  Created by cc on 2018/9/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>
//客户端Socket
@property (nonatomic) GCDAsyncSocket *clientSocket;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITextView *showMessage;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //1.初始化
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -CGDAsynSocket Delegate

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [self showMessageWithStr:@"链接成功"];
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器IP ： %@", host]];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}
-(void)showMessageWithStr:(NSString *)str{
    self.showMessage.text = [self.showMessage.text stringByAppendingFormat:@"%@\n", str];
}

//接收信息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - Action
//开始链接
- (IBAction)connectAction:(id)sender {
    //2.链接服务器
    [self.clientSocket connectToHost:self.address.text onPort:self.port.text.integerValue withTimeout:-1 error:nil];
}
//发送消息
- (IBAction)sendMessage:(id)sender {
    NSData *data = [self.message.text dataUsingEncoding:NSUTF8StringEncoding];
    //withTimeout -1:无穷大
    //tag：消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
}
- (IBAction)receiveMessage:(id)sender {
    [self.clientSocket readDataWithTimeout:11 tag:0];
}


@end
