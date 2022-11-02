

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSImagePosition)
{
    KSImagePositionLeft = 0,              //图片在左，文字在右，默认
    KSImagePositionRight = 1,             //图片在右，文字在左
    KSImagePositionTop = 2,               //图片在上，文字在下
    KSImagePositionBottom = 3,            //图片在下，文字在上
//    KSImagePositioNone = 4,               //文字居中，没有图片
};

@interface UIButton (ImageTitlePosition)
/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *  @param spacing 图片和文字的间隔
 */
- (void)setImagePosition:(KSImagePosition)postion spacing:(CGFloat)spacing;

- (void)setImagePosition:(KSImagePosition)postion titleMaxWitdh:(CGFloat)maxWidth spacing:(CGFloat)spacing;
@end
