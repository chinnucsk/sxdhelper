//
//  EquipmentViewController.m
//  ShenxiandaoHelper
//
//  Created by 王 佳 on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EquipmentViewController.h"
#import "EquipItemTableViewCell.h"
#import "JSONKit.h"

enum {
    kItemTypeEquipment,     // 装备
    kItemTypeDrug,          // 丹药
    kItemTypeMaterial,      // 材料
};
@interface ItemData : NSObject {
    NSString* itemName;
    NSString* image;
    NSString* exData;      // 装备物品此处存放的是职业信息，材料物品此处存放的是掉落地点
    int type;
    int level;          // 装备和材料物品有用
    NSString* nameColor;     // 名字的显示颜色
    NSArray* relateItem;    // 对装备和丹药而言存放的是制作所需材料，对材料而言存放的是可制作的装备或丹药
}

@property(nonatomic, retain) NSString* itemName;
@property(nonatomic, retain) NSString* image;
@property(nonatomic, retain) NSString* exData;
@property(nonatomic) int type;
@property(nonatomic) int level;
@property(nonatomic, retain) NSString* nameColor;
@property(nonatomic, retain) NSArray* relateItem;

-(ItemData*)initWithName:(NSString*)name;
-(void)print;
@end

@implementation ItemData
@synthesize itemName, image, exData, type, level, relateItem, nameColor;

-(ItemData*)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.itemName = name;
    }
    
    return self;
}

-(void)print
{
#ifdef DEBUG
    NSLog(@"name:%@  data:%@  type:%d   level:%d   items:%@", itemName, exData, type, level, relateItem);
#endif
}
@end

@implementation EquipmentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)loadFromFile:(NSString*)fileName
{
    NSError* error = nil;
    NSString* filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:@"json"];
    NSString* jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSArray* itemData = [jsonString objectFromJSONString];

    for (NSDictionary* each in itemData) {
        ItemData* idata = [[ItemData alloc]initWithName:[each objectForKey:@"name"]];
        if (idata) {
            NSString* type = [each objectForKey:@"type"];
            if ([type isEqualToString:@"equipment"]) {
                idata.type = kItemTypeEquipment;
                NSString* level = [each objectForKey:@"level"];
                idata.level = [level intValue];
                idata.exData = [each objectForKey:@"data"];
            } else if ([type isEqualToString:@"material"]) {
                idata.type = kItemTypeMaterial;
                idata.exData = [each objectForKey:@"data"];
            } else if ([type isEqualToString:@"drug"]) {
                idata.type = kItemTypeDrug;
                NSString* level = [each objectForKey:@"level"];
                idata.level = [level intValue];
            }
            
            idata.image = [each objectForKey:@"image"];
            idata.nameColor = [each objectForKey:@"color"];
            idata.relateItem = [each objectForKey:@"items"];
        }
        
        [allItems_ addObject:idata];
        
        switch (idata.type) {
            case kItemTypeMaterial:
                [materials_ addObject:idata];
                break;
            case kItemTypeEquipment:
                [equipments_ addObject:idata];
                break;
            case kItemTypeDrug:
                [drugs_ addObject:idata];
                break;
            default:
                break;
        }
    }
}

-(void)checkImage
{
    for (ItemData* each in allItems_) {
        UIImage* image = [UIImage imageNamed:each.image];
        if (!image) {
            NSLog(@"%@ for %@ not found!!!!", each.image, each.itemName);
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    allItems_ = [[NSMutableArray alloc]init];
    equipments_ = [[NSMutableArray alloc]init];
    drugs_ = [[NSMutableArray alloc]init];
    materials_ = [[NSMutableArray alloc]init];

    [self loadFromFile:@"drug"];
    [self loadFromFile:@"material"];
    [self loadFromFile:@"equip"];

    [self selectType:kItemTypeMaterial];
    [self updateLabelTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    } else {
        return NO;
    }
}

-(void)search:(NSString *)text
{
    [materials_ removeAllObjects];
    [drugs_ removeAllObjects];
    [equipments_ removeAllObjects];
    
    for (ItemData* each in allItems_) {
        if ([each.itemName rangeOfString:text].location != NSNotFound) {
            switch (each.type) {
                case kItemTypeMaterial:
                    [materials_ addObject:each];
                    break;
                case kItemTypeEquipment:
                    [equipments_ addObject:each];
                    break;
                case kItemTypeDrug:
                    [drugs_ addObject:each];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString* text = textField.text;
    
    if ([text length] <= 0) {
        [materials_ removeAllObjects];
        [drugs_ removeAllObjects];
        [equipments_ removeAllObjects];
        
        for (ItemData* each in allItems_) {
            switch (each.type) {
                case kItemTypeMaterial:
                    [materials_ addObject:each];
                    break;
                case kItemTypeEquipment:
                    [equipments_ addObject:each];
                    break;
                case kItemTypeDrug:
                    [drugs_ addObject:each];
                    break;
                default:
                    break;
            }
        }
    } else {
        [self search:text];
    }
    
    if ([materials_ count] > 0) {
        [self selectType:kItemTypeMaterial];
    } else if ([equipments_ count] > 0) {
        [self selectType:kItemTypeEquipment];
    } else if ([drugs_ count] > 0) {
        [self selectType:kItemTypeDrug];
    } else {
        // nothing
        [self selectType:kItemTypeMaterial];
    }
    
    [self updateLabelTitle];

    tableView_.alpha = 0;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.5];
    tableView_.alpha = 1;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (currentType) {
        case kItemTypeDrug:
            return [drugs_ count];
            break;
        case kItemTypeEquipment:
            return [equipments_ count];
            break;
        case kItemTypeMaterial:
            return [materials_ count];
            break;
        default:
            break;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    EquipItemTableViewCell *cell = (EquipItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EquipItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ItemData* idata = nil;
    
    switch (currentType) {
        case kItemTypeMaterial:
            idata = [materials_ objectAtIndex:indexPath.row];
            break;
        case kItemTypeEquipment:
            idata = [equipments_ objectAtIndex:indexPath.row];
            break;
        case kItemTypeDrug:
            idata = [drugs_ objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    if (idata) {
        cell.image.image = [UIImage imageNamed:idata.image];
        cell.itemName.text = idata.itemName;
        if (!idata.nameColor || [idata.nameColor length] <= 0) {
            cell.itemName.textColor = [UIColor blackColor];
        } else {
            if ([idata.nameColor isEqualToString:@"purple"]) {
                cell.itemName.textColor = [UIColor purpleColor];
            } else if ([idata.nameColor isEqualToString:@"blue"]) {
                cell.itemName.textColor = [UIColor colorWithRed:0.03 green:0.48 blue:0.86 alpha:1];
            } else if ([idata.nameColor isEqualToString:@"green"]) {
                cell.itemName.textColor = [UIColor colorWithRed:0.15 green:0.55 blue:0.35 alpha:1];
            }
        }
        
        switch (idata.type) {
            case kItemTypeEquipment:
                cell.exData.text = [NSString stringWithFormat:@"职业:%@\t\t使用等级:%d", idata.exData, idata.level];
                break;
            case kItemTypeMaterial:
                cell.exData.text = [NSString stringWithFormat:@"掉落地点: %@", idata.exData];
                break;
            case kItemTypeDrug:
                cell.exData.text = [NSString stringWithFormat:@"使用等级: %d", idata.level];
                break;
            default:
                break;
        }

        if (!idata.relateItem || [idata.relateItem count] <= 0) {
            if (idata.type == kItemTypeEquipment || idata.type == kItemTypeDrug) {
                cell.relateItems.text = @"所需材料:  无";
            } else {
                cell.relateItems.text = @"可制作物品:  无";
            }
        } else {
            if (idata.type == kItemTypeEquipment || idata.type == kItemTypeDrug) {
                NSString* text = @"所需材料:  ";
                int amount = [idata.relateItem count];
                NSString* name;
                NSString* number;
                for (int i = 0; i < amount; ++i) {
                    if (i % 2 == 0) {
                        name = [idata.relateItem objectAtIndex:i];
                    } else {
                        number = [idata.relateItem objectAtIndex:i];
                        text = [text stringByAppendingFormat:@"%@x%@   ", name, number];
                    }
                }
                
                cell.relateItems.text = text;
            } else {
                NSString* text = @"可制作物品:  ";
                int amount = [idata.relateItem count];
                for (int i = 0; i < amount; ++i) {
                    if (i % 2 == 0) {
                        text = [text stringByAppendingFormat:@"%@   ", [idata.relateItem objectAtIndex:i]];
                    }
                }
                
                cell.relateItems.text = text;
            }
        }
       
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(IBAction)onClickMaterial:(id)sender
{
    if (currentType == kItemTypeMaterial) {
        return;
    }

    [self selectType:kItemTypeMaterial];
}

-(IBAction)onClickEquipment:(id)sender
{
    if (currentType == kItemTypeEquipment) {
        return;
    }

    [self selectType:kItemTypeEquipment];
}

-(IBAction)onClickDrug:(id)sender
{
    if (currentType == kItemTypeDrug) {
        return;
    }

    [self selectType:kItemTypeDrug];
}

-(void)selectType:(int)type
{
    switch (type) {
        case kItemTypeMaterial:
            currentType = kItemTypeMaterial;
            btnDrug.selected = NO;
            labelDrug.textColor = [UIColor blackColor];
            btnEquip.selected = NO;
            labelEquip.textColor = [UIColor blackColor];
            btnMaterial.selected = YES;
            labelMaterial.textColor = [UIColor yellowColor];
            break;
        case kItemTypeEquipment:
            currentType = kItemTypeEquipment;
            btnDrug.selected = NO;
            labelDrug.textColor = [UIColor blackColor];
            btnEquip.selected = YES;
            labelEquip.textColor = [UIColor yellowColor];
            btnMaterial.selected = NO;
            labelMaterial.textColor = [UIColor blackColor];
            break;
        case kItemTypeDrug:
            currentType = kItemTypeDrug;
            btnDrug.selected = YES;
            labelDrug.textColor = [UIColor yellowColor];
            btnEquip.selected = NO;
            labelEquip.textColor = [UIColor blackColor];
            btnMaterial.selected = NO;
            labelMaterial.textColor = [UIColor blackColor];
            break;
        default:
            break;
    }
    
    NSInteger count = [tableView_ numberOfRowsInSection:0];
    if (count > 0) {
        [tableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }

    [tableView_ reloadData];
    
    tableView_.alpha = 0.2;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.5];
    tableView_.alpha = 1;
    [UIView commitAnimations];
}

-(void)updateLabelTitle
{
    labelMaterial.text = [NSString stringWithFormat:@"材料(%d)", [materials_ count]];
    labelEquip.text = [NSString stringWithFormat:@"装备(%d)", [equipments_ count]];
    labelDrug.text = [NSString stringWithFormat:@"丹药(%d)", [drugs_ count]];
}


-(IBAction)onClickReturn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
