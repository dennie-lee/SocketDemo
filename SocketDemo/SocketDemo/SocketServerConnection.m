//
//  SocketServerConnection.m
//  SocketDemo
//
//  Created by 4399 on 2021/3/25.
//  Copyright © 2021 liran. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "SocketServerConnection.h"

#define kMaxConnectCount 5


@interface SocketServerConnection()

@property (nonatomic,assign) int serverId;

@property (nonatomic,assign) int clientSocket;

@end


@implementation SocketServerConnection

- (void)connection{
    //创建socket
    /// int socket(int family, int type, int protocol);
    ///参数一：family：协议簇或者协议域（AF_INET：IPv4协议；AF_INET6:IPv6协议；AF_LOCAL：Unix域协议；AF_ROUTE：路由套接字；AF_KEY：密钥套接字）
    ///参数二：type：套接字类型（SOCK_STREAM：字节流套接字；SOCK_DGRAM：数据包套接字；SOCK_EQPACKET：有序分组套接字；SOCK_RAW：原始套接字）
    ///参数三：protocol协议类型（IPPROTO_TCP：TCP传输协议；IPPROTO_UDP：UDP传输协议；IPPROTO_SCTP：SCTP传输协议；0:选择所给定family和type组合的系统默认值）
    self.serverId = socket(AF_INET, SOCK_STREAM, 0);
    if(self.serverId == -1){
        NSLog(@"服务端：服务端创建socket失败");
        return;
    }
    NSLog(@"服务端：服务端创建socket成功");
    
    //绑定socket
    struct sockaddr_in sockAddr;
    sockAddr.sin_family = AF_INET;
    sockAddr.sin_port = htons(8040);
    
    struct in_addr inAddr;
    inAddr.s_addr = inet_addr("127.0.0.1");
    sockAddr.sin_addr = inAddr;
    bzero(&sockAddr.sin_zero, 8);
    ///int     bind(int, const struct sockaddr *, socklen_t)
    ///参数一：socket描述符
    ///参数二：socket地址结构体指针
    ///参数三：socket地址结构体大小
    int bindResult = bind(self.serverId, (const struct sockaddr *)&sockAddr, sizeof(sockAddr));
    if(bindResult == -1){
        NSLog(@"服务端：socket 绑定失败");
        return;
    }
    NSLog(@"服务端：socket 绑定成功");
    
    //监听socket
    ///int  listen(int, int)
    ///参数一：socket标识符
    ///参数二：最大连接数
    int lisentResult = listen(self.serverId, kMaxConnectCount);
    if(lisentResult == -1){
        NSLog(@"服务端：监听失败");
        return;
    }
    NSLog(@"服务端：监听成功");
    
    ///接受信息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        struct sockaddr_in client_address;
        socklen_t socklen;
        ///int     accept(int, struct sockaddr * __restrict, socklen_t * __restrict)
        ///参数一：socket描述符
        ///参数二：socket地址结构体指针
        ///参数三：socket地址结构体大小
        int client_socket = accept(self.serverId, (struct sockaddr *)&client_address, &socklen);
        self.clientSocket = client_socket;
        if(client_socket == -1){
            NSLog(@"服务端：接受客户端连接错误");
        }else{
            NSString *acceptInfo = [NSString stringWithFormat:@"客户端 in，socket：%d",client_socket];
            NSLog(@"服务端：%@",acceptInfo);
            [self recvMsg:client_socket];
        }
    });
}

///接受信息
- (void)recvMsg:(int)clientSocket{
    while (1) {
        char buff[1024] = {0};
        ssize_t sizeLen = recv(clientSocket, buff, 1024, 0);
        if(sizeLen>0){
            NSLog(@"服务端：客户端来消息了");
            NSData *recvData  = [NSData dataWithBytes:buff length:sizeLen];
            NSString *recvStr = [[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding];
            NSLog(@"服务端：%@",recvStr);
        }else if (sizeLen == -1){
            NSLog(@"服务端：读取数据失败");
            break;
        }else if (sizeLen == 0){
            NSLog(@"服务端：客户端走了");
            close(clientSocket);
            break;
        }
    }
}

///发送信息
- (void)sendMsg:(NSString *)msg{
    size_t sendResult = write(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String));
    NSLog(@"服务端：发送%zu字节数据",sendResult);
}

///关闭连接
- (void)close:(int)clientSocket{
    int closeResult = close(clientSocket);
    if(closeResult == -1){
        NSLog(@"服务端：关闭失败");
        return;
    }else{
        NSLog(@"服务端：关闭成功");
    }
}
@end
