//
//  SocketServerConnection.h
//  SocketDemo
//
//  Created by 4399 on 2021/3/25.
//  Copyright © 2021 liran. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketServerConnection : NSObject
- (void)connection;
- (void)sendMsg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
