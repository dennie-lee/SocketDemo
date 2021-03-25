//
//  ViewController.m
//  SocketDemo
//
//  Created by 4399 on 2021/3/25.
//  Copyright © 2021 liran. All rights reserved.
//

#import "ViewController.h"
#import "SocketConnection.h"
#import "SocketServerConnection.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *sendMsgTextfield;

@property (weak, nonatomic) IBOutlet UITextView *showMsgTextView;

@property (nonatomic,strong) SocketConnection *socketConnection;

@property (nonatomic,strong) SocketServerConnection *serverSocketConnection;

@property (weak, nonatomic) IBOutlet UITextField *serverMsgTextfield;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)connectAction:(id)sender {
    [self.socketConnection socketConnection];
}

- (IBAction)sendMsgAction:(id)sender {
    [self.socketConnection sendMsg:self.sendMsgTextfield.text];
}

- (SocketConnection *)socketConnection{
    if(!_socketConnection){
        _socketConnection = [[SocketConnection alloc] init];
    }
    return _socketConnection;
}

- (IBAction)serverSendMsgAction:(id)sender {
    [self.serverSocketConnection sendMsg:self.serverMsgTextfield.text];
}

- (IBAction)serverStartConnectionAction:(id)sender {
    [self.serverSocketConnection connection];
}

- (SocketServerConnection *)serverSocketConnection{
    if(!_serverSocketConnection){
        _serverSocketConnection = [[SocketServerConnection alloc] init];
    }
    return _serverSocketConnection;
}

@end
