//
//  GetPhotoTool.m
//  photo
//
//  Created by Yulin Zhao on 2019/1/16.
//  Copyright © 2019 Yulin Zhao. All rights reserved.
//

#import "GetPhotoTool.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ZJSProtocol.h"
@interface GetPhotoTool ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZJSProtocol>
@property(nonatomic,strong)JSContext *context;

@end
@implementation GetPhotoTool
-(void)currents:(NSString *)str{
    
}
-(void)getIphonePhotoPictureWithCurrentVC:(UIViewController*)CurrentVC webview:(UIWebView*)web{
    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    
    _context=[web valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 2. 创建图片选择控制器
    UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];
    /**
     typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
     UIImagePickerControllerSourceTypePhotoLibrary, // 相册
     UIImagePickerControllerSourceTypeCamera, // 用相机拍摄获取
     UIImagePickerControllerSourceTypeSavedPhotosAlbum // 相簿
     }
     */
    // 3. 设置打开照片相册类型(显示所有相簿)
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    // 照相机
    // ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 4.设置代理
    imagePicker.delegate = self;
    // 5.modal出这个控制器
    [CurrentVC presentViewController:imagePicker animated:YES completion:nil];
    
}
#pragma mark -- <UIImagePickerControllerDelegate>--
// 获取图片后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    // 设置图片
    UIImage * image = info[UIImagePickerControllerOriginalImage];
  

    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    NSData * imageData = UIImagePNGRepresentation(image);
   
    NSString *encodedImageStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    // 这里传值给h5界面
    NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
    NSString *jsFunctStr = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
     [_context evaluateScript:jsFunctStr];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 图片转成base64字符串需要先取出所有空格和换行符
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}


@end
