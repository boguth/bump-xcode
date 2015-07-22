//
//  LoginController.m
//  Bump
//
//  Created by Apprentice on 7/21/15.
//  Copyright (c) 2015 Bump Boys!, Inc. All rights reserved.
//

#import "LoginController.h"

@implementation LoginController



-(void)viewDidLoad{
    _loginHeaderLabel.text = @"bump";
    [_loginHeaderLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Condensed" size:34.0]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  
}

- (IBAction)loginClicked:(id)sender {
        NSInteger success = 0;
        @try {
            
            if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] ) {
                
                [self alertStatus:@"Please enter Email and Password" :@"Sign in Failed!" :0];
                
            } else {
     
                NSString *post =[[NSString alloc] initWithFormat:@"phone_number=%@&password=%@",[self.txtUsername text],[self.txtPassword text]];
                NSLog(@"PostData: %@",post);
                
                NSURL *url=[NSURL URLWithString:@"https://whispering-stream-9304.herokuapp.com/sessions"];
                
                NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                NSLog(@"%@", postData);
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:url];
                [request setHTTPMethod:@"POST"];
//                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
                
                NSLog(@"%@", request);
                
//                [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
                
                NSError *error = [[NSError alloc] init];
                NSHTTPURLResponse *response = nil;
                NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

                NSLog(@"Response code: %ld", (long)[response statusCode]);
                
                if ([response statusCode] >= 200 && [response statusCode] < 300)
                {
                    NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                    NSLog(@"Response ==> %@", responseData);
                    
                    NSError *error = nil;
                    NSDictionary *jsonData = [NSJSONSerialization
                                              JSONObjectWithData:urlData
                                              options:NSJSONReadingMutableContainers
                                              error:&error];
                    
                    success = [jsonData[@"success"] integerValue];
                    NSLog(@"Success: %ld",(long)success);
                    
                    if(success == 1)
                    {
                        NSLog(@"Login SUCCESS");
                    } else {
                        
                        NSString *error_msg = (NSString *) jsonData[@"error_message"];
                        [self alertStatus:error_msg :@"Sign in Failed!" :0];
                    }
                    
                } else {
                    //if (error) NSLog(@"Error: %@", error);
                    [self alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
                }
            }
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            [self alertStatus:@"Sign in Failed." :@"Error!" :0];
        }
        if (success) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [self performSegueWithIdentifier:@"loginSuccess" sender:self];
        }
    }
    
    - (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag = tag;
        [alertView show];
    }


- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
//    [textField resignFirstResponder];
//    return YES;
//}


- (IBAction)segueAction {
    UIViewController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
    [self.navigationController pushViewController:mainViewController animated:YES];
}
@end
