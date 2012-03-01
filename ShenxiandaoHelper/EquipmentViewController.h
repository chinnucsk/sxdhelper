//
//  EquipmentViewController.h
//  ShenxiandaoHelper
//
//  Created by 王 佳 on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EquipmentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView* tableView_;
    IBOutlet UIButton* btnMaterial;
    IBOutlet UIButton* btnEquip;
    IBOutlet UIButton* btnDrug;

    NSMutableArray* allItems_;
    NSMutableArray* equipments_;
    NSMutableArray* drugs_;
    NSMutableArray* materials_;
    
    int currentType;
}

-(IBAction)onClickMaterial:(id)sender;
-(IBAction)onClickEquipment:(id)sender;
-(IBAction)onClickDrug:(id)sender;
-(IBAction)onClickReturn:(id)sender;

-(void)search:(NSString*)text;
-(void)loadFromFile:(NSString*)fileName;
@end
