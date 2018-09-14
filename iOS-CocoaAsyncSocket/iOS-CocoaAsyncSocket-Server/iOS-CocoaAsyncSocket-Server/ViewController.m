//
//  ViewController.m
//  iOS-CocoaAsyncSocket-Server
//
//  Created by cc on 2018/9/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITextView *showConnectMessage;

//服务器socket（开放端口，监听客户端socket的链接）
@property (nonatomic) GCDAsyncSocket *serverSocket;
//保存客户端socket
@property (nonatomic) GCDAsyncSocket *clientSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 1、初始化服务器socket，在主线程力回调
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - server socket Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    //保存客户端的socket
    self.clientSocket = newSocket;
    [self showMessageWithStr:@"链接成功"];
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器地址：%@\n端口： %d", newSocket.connectedHost, newSocket.connectedPort]];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)showMessageWithStr:(NSString *)str{
    self.showConnectMessage.text = [self.showConnectMessage.text stringByAppendingFormat:@"%@\n",str];
}

#pragma mark - Action
//开始监听
- (IBAction)startReceive:(id)sender {
    //2、开放哪一个端口
    NSError *error = nil;
    BOOL result = [self.serverSocket acceptOnPort:self.port.text.integerValue error:&error];
    if (result && error == nil) {
        //开放成功
        [self showMessageWithStr:@"开放成功"];
    }
}
//发送消息
- (IBAction)sendMessage:(id)sender {
    NSData *data = [self.message.text dataUsingEncoding:NSUTF8StringEncoding];
    //withTimeout -1:无穷大，一直等
    //tag:消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
    
}
//接受消息,socket是客户端socket，表示从哪一个客户端读取消息
- (IBAction)receiveMessage:(id)sender {
    [self.clientSocket readDataWithTimeout:11 tag:0];
}


@end
