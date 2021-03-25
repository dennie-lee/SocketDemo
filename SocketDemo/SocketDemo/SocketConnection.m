//
//  SocketConnection.m
//  SocketDemo
//
//  Created by 4399 on 2021/3/25.
//  Copyright © 2021 liran. All rights reserved.
//


#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "SocketConnection.h"

//htons将一个无符号整型数据转为网络字节顺序，不同cpu是不同的顺序
#define SOCKET_PORT htons(8040)
//ip地址：以本地为例子
#define IP_ADRR "127.0.0.1"


@interface SocketConnection()

@property (nonatomic,assign) int clientId;

@end

@implementation SocketConnection

- (void)socketConnection{
    //创建socket
    /// int socket(int family, int type, int protocol);
    ///参数一：family：协议簇或者协议域（AF_INET：IPv4协议；AF_INET6:IPv6协议；AF_LOCAL：Unix域协议；AF_ROUTE：路由套接字；AF_KEY：密钥套接字）
    ///参数二：type：套接字类型（SOCK_STREAM：字节流套接字；SOCK_DGRAM：数据包套接字；SOCK_EQPACKET：有序分组套接字；SOCK_RAW：原始套接字）
    ///参数三：protocol协议类型（IPPROTO_TCP：TCP传输协议；IPPROTO_UDP：UDP传输协议；IPPROTO_SCTP：SCTP传输协议；0:选择所给定family和type组合的系统默认值）
    int socketId = socket(AF_INET, SOCK_STREAM, 0);
    self.clientId = socketId;
    if (socketId == -1) {
        NSLog(@"create socket fail");
        return;
    }
    //连接socket
    struct sockaddr_in socketAdrr;
    socketAdrr.sin_family = AF_INET;
    socketAdrr.sin_port = SOCKET_PORT;
    
    struct in_addr socketIn_adrr;
    socketIn_adrr.s_addr = inet_addr(IP_ADRR);
    socketAdrr.sin_addr = socketIn_adrr;
    
    ///int connect(int sockfd, const struct sockaddr * servaddr, socklen_t addrlen)
    ///参数一：sockfd（socket描述符）
    ///参数二：servaddr（socket地址结构体指针）
    ///参数三：addrlen（socket地址结构体大小）
    int result = connect(socketId, (const struct sockaddr *)&socketAdrr, sizeof(socketAdrr));
    if(result != 0){
        NSLog(@"客户端：连接失败");
        return;
    }
    NSLog(@"客户端：连接成功");
    ///异步接受信息，防止阻塞主线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self recvMsg];
    });
}


- (void)recvMsg{
    while (1) {
        uint8_t buffers[1024];
        ///ssize_t recv(int, void *, size_t, int)
        ///参数一：socket标志符
        ///参数二：缓冲区
        ///参数三：缓冲区大小
        ///参数四：指定调用方式，一般设置为0
        ssize_t sizeLen = recv(self.clientId, buffers, sizeof(buffers), 0);
        NSLog(@"客户端：接收到%zd个字节",sizeLen);
        if(sizeLen == 0){
            continue;
        }
        NSData *data = [NSData dataWithBytes:buffers length:sizeLen];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"客户端：%@ 接收到消息：%@",[NSThread currentThread],msg);
    }
}


- (void)sendMsg:(NSString *)msg{
    if(msg.length <= 0) return;
    const void *buff = msg.UTF8String;
    ///ssize_t     write(int __fd, const void * __buf, size_t __nbyte)
    ///参数一：socket标志符
    ///参数二：缓冲区
    ///参数三：缓冲区大小
    ssize_t sizeLen = write(self.clientId, buff, strlen(buff));
    NSLog(@"客户端：发送%zd字节消息",sizeLen);
}

@end
