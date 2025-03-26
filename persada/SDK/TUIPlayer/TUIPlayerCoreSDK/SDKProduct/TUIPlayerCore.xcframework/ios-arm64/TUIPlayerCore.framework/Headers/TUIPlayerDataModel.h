// Copyright (c) 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TUIPlayerVideoModel;
@class TUIPlayerLiveModel;
typedef NS_ENUM(NSInteger, TUI_MODEL_TYPE) {

    /// 视频
    /// VOD
    TUI_MODEL_TYPE_VOD = 0,

    /// 直播
    /// Live
    TUI_MODEL_TYPE_LIVE = 1,

    /// 自定义类型
    /// custom
    TUI_MODEL_TYPE_CUSTOM = 2,

};
NS_ASSUME_NONNULL_BEGIN

@interface TUIPlayerDataModel : NSObject<NSCopying>

@property (nonatomic, assign, readonly)TUI_MODEL_TYPE modelType; ///模型类型 
@property (nonatomic, strong) id extInfo;              /// 业务数据
@property (nonatomic, copy) void (^ onExtInfoChangedBlock) (id extInfo);///extInfo信息改变block回调

/**
 * 通知extInfo数据发生改变
 */
- (void)extInfoChangeNotify;
- (NSString *)description;
- (TUIPlayerVideoModel *)asVodModel;
- (TUIPlayerLiveModel *)asLiveModel;
@end

NS_ASSUME_NONNULL_END
