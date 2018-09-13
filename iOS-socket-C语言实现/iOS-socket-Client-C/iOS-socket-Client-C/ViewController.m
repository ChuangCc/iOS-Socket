//
//  ViewController.m
//  iOS-socket-Client-C
//
//  .
//  Copyright © 2018年 cc. All rights reserved.
//

#import "ViewController.h"
#include <sys/socket.h>
#include <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tcpClient];
   // [self udpClient];
}

-(void)tcpClient{
    //第一步，创建socket
    //TCP是基于数据流的，因此参数二使用SOCK_STREAM
    int error = -1;
    int clientSocketId = socket(AF_INET, SOCK_STREAM, 0);
    BOOL success = (clientSocketId != -1);
    struct sockaddr_in addr;
    
    //第二步，绑定端口号
    if (success) {
        NSLog(@"client socket create success !");
        //初始化
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        
        //指定协议簇为AF_INET，比如TCP/UDP等
        addr.sin_family = AF_INET;
        
        //监听任何IP地址
        addr.sin_addr.s_addr = INADDR_ANY;
        error = bind(clientSocketId, (const struct sockaddr *)&addr, sizeof(addr));
        success = (error == 0);
    }
    
    if (success) {
        //p2p
        struct sockaddr_in peerAddr;
        memset(&peerAddr, 0, sizeof(peerAddr));
        peerAddr.sin_len = sizeof(peerAddr);
        peerAddr.sin_family = AF_INET;
        peerAddr.sin_port = htons(1024);
        
        //指定服务端端ip地址，测试时修改成对应自己的服务器ip
        peerAddr.sin_addr.s_addr = inet_addr("192.168.137.78");
        
        socklen_t addrLen;
        addrLen = sizeof(peerAddr);
        NSLog(@"will be connevting !");
        
        //第三步，链接服务器
        error = connect(clientSocketId, (struct sockaddr *)&peerAddr, addrLen);
        success = (error == 0);
        
        if (success) {
            //第四步，获取套接字信息
            error = getsockname(clientSocketId, (struct sockaddr *)&addr, &addrLen);
            success = (error == 0);
            
            if (success) {
                NSLog(@"client connect success, local address:%s,port:%d",
                      inet_ntoa(addr.sin_addr),
                      ntohs(addr.sin_port));
                
                //这里只发10次
                int count = 10;
                do{
                    //第五步，发送消息到服务端
                    send(clientSocketId, "Hi，server", 1024, 0);
                    count--;
                    //告诉server，客户端退出了
                    if (count == 0) {
                        send(clientSocketId, "exit", 1024, 0);
                    }
                }while (count >= 1);
                
                //第六步，关闭套接字
                close(clientSocketId);
            }
        }else{
            NSLog(@"connect failed");
            
            //第六步，关闭套接字
            close(clientSocketId);
        }
    }
}

-(void)udpClient{
    int  clientSocketId;
    ssize_t len;
    socklen_t addrlen;
    struct sockaddr_in client_sockaddr;
    char buffer[256] = "Hello, server !";
    
    //第一步，创建socket
    clientSocketId = socket(AF_INET, SOCK_DGRAM, 0);
    if (clientSocketId < 0) {
        NSLog(@"creat client socket fail !");
        return ;
    }
    
    addrlen = sizeof(struct sockaddr_in);
    bzero(&client_sockaddr, addrlen);
    client_sockaddr.sin_family = AF_INET;
    client_sockaddr.sin_addr.s_addr = inet_addr("192.168.137.78");
    client_sockaddr.sin_port = htons(1024);
    
    int count = 10;
    do {
        bzero(buffer, sizeof(buffer));
        sprintf(buffer, "%s","Hi, server !");
        
        //第二步，发送消息到服务端
        //注意，UDP是面向无连接到，因此不用调用connect（）
        //将字符串传送到server端
        len = sendto(clientSocketId, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_sockaddr, addrlen);
        
        if (len > 0) {
            NSLog(@"发送成功 ！");
        }else{
            NSLog(@"发送失败 ！");
        }
        
        //第三步，接收来自服务端返回到消息
        //接受server端返回到字符串
        bzero(buffer, sizeof(buffer));
        len = recvfrom(clientSocketId, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_sockaddr, &addrlen);
        NSLog(@"receive message from server : %s", buffer);
        
        count --;
    } while (count >= 0);
    
    //第四步，关闭socket
    //由于是面向无连接到，消息发出去就可以了，不用管它收不收得到，发送完就关闭了
    close(clientSocketId);
}


@end
