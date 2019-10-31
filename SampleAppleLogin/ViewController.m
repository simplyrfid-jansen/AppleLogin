//
//  ViewController.m
//  SampleAppleLogin
//
//  Created by simplyRFID-PH on 31/10/2019.
//  Copyright © 2019 simplyRFID-PH. All rights reserved.
//

#import "ViewController.h"
#import "AuthenticationServices/AuthenticationServices.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label_udid;
@property (weak, nonatomic) IBOutlet UILabel *label_id;
@property (weak, nonatomic) IBOutlet UILabel *label_email;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property UILabel *appleIDInfoLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
    
    _label_udid.text = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (void)configUI{
    
//    _appleIDInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.4)];
//    _appleIDInfoLabel.font = [UIFont systemFontOfSize:22.0];
//    _appleIDInfoLabel.numberOfLines = 0;
//    _appleIDInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    _appleIDInfoLabel.text = @"Sign In With Apple\n";
    [self.view addSubview:_appleIDInfoLabel];
     
    if (@available(iOS 13.0, *)) {
        // Sign In With Apple Button
        ASAuthorizationAppleIDButton *appleIDBtn = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhite];
        appleIDBtn.frame = CGRectMake(30, self.view.bounds.size.height - 180, self.view.bounds.size.width - 60, 100);
        //    appleBtn.cornerRadius = 22.f;
        [appleIDBtn addTarget:self action:@selector(handleAuthorizationAppleIDButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:appleIDBtn];
    }
}

-(void)handleAuthorizationAppleIDButtonPress{
    NSLog(@"Hello");
    if (@available(iOS 13.0, *)) {
        
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        appleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest]];
        authorizationController.delegate = self;
        authorizationController.presentationContextProvider = self;
        [authorizationController performRequests];
    }
}

- (void)perfomExistingAccountSetupFlows{
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        ASAuthorizationPasswordProvider *passwordProvider = [[ASAuthorizationPasswordProvider alloc] init];
        ASAuthorizationPasswordRequest *passwordRequest = [passwordProvider createRequest];
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest, passwordRequest]];
        authorizationController.delegate = self;
        authorizationController.presentationContextProvider = self;
        [authorizationController performRequests];
    }
}
 
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization{
//    NSLog(@"授权完成:::%@", authorization.credential);
//    NSLog(@"%s", __FUNCTION__);
//    NSLog(@"%@", controller);
//    NSLog(@"%@", authorization);
     
    NSMutableString *mStr = [NSMutableString string];
     
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {

        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        
        NSString *user = appleIDCredential.user;
        _label_id.text = user;
        
        NSString *familyName = appleIDCredential.fullName.familyName;
        NSString *givenName = appleIDCredential.fullName.givenName;

        _label_name.text = [NSString stringWithFormat:@"%@ %@", givenName, familyName];
        
        NSString *email = appleIDCredential.email;
        _label_email.text = email;
        
        
//        NSLog(@"--z user:%@ | email:%@ | fullname:%@",user, email, fullName);

    }else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]){

        ASPasswordCredential *passwordCredential = authorization.credential;
        NSString *user = passwordCredential.user;
        NSString *password = passwordCredential.password;
             
        [mStr appendString:user];
        [mStr appendString:@"\n"];
        [mStr appendString:password];
        [mStr appendString:@"\n"];
        NSLog(@"mStr:::%@", mStr);
//        _appleIDInfoLabel.text = mStr;
    }else{
        NSLog(@"授权信息均不符");
    }
}
 
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error{
    // Handle error.
    NSLog(@"Handle error：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
             
        default:
            break;
    }
     
    NSMutableString *mStr = [_appleIDInfoLabel.text mutableCopy];
    [mStr appendString:@"\n"];
    [mStr appendString:errorMsg];
    [mStr appendString:@"\n"];
    _appleIDInfoLabel.text = mStr;
}
 
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller{
    NSLog(@"88888888888");
    return self.view.window;
}

@end
