//
//  TestSocketIOViewController.m
//  TestSocketIO
//
//  Created by apple on 12-9-19.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import "TestSocketIOViewController.h"

@interface TestSocketIOViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (readonly) SocketIO *socketIO;
@property (nonatomic) NSString* id;
@property (weak, nonatomic) IBOutlet UITextField *messageBox;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray* tableData;
@end


@implementation TestSocketIOViewController
@synthesize messageBox = _messageBox;
@synthesize tableView = _tableView;
@synthesize textLabel = _textLabel;
@synthesize socketIO=_socketIO;
@synthesize id=_id;
@synthesize tableData=_tableData;

- (SocketIO*) socketIO
{
    if(!_socketIO) _socketIO = [[SocketIO alloc] initWithDelegate:self];

    return _socketIO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.socketIO connectToHost:@"localhost" onPort:3000];
    if (!_tableData) {
        self.tableData = [[NSMutableArray alloc] init];
    }
}

- (void)viewDidUnload
{
    [self setTextLabel:nil];
    [self setId:nil];
    [self setMessageBox:nil];
    [self setTableData:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary* result = [packet.args lastObject];
    if ([packet.name isEqualToString:@"connected"]) {
        
        self.id = [[result valueForKey:@"id"] description];
        self.textLabel.text = [[result valueForKey:@"greeting"] description];
                
    }else if ([packet.name isEqualToString:@"message"]){
        self.textLabel.text = [[result valueForKey:@"msg"] description];
        [self.tableData addObject:result];
        [self.tableView reloadData];
    }
    
    
    

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

#pragma dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"msgCell";
    UITableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!newCell) {
        newCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    newCell.textLabel.text = [[[self.tableData objectAtIndex:indexPath.row] valueForKey:@"msg"] description];
    return newCell;
}

- (IBAction)sendMsg:(id)sender {
    NSString* msg = self.messageBox.text;
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:msg forKey:@"msg"];
    [data setObject:self.id forKey:@"id"];
    [self.socketIO sendEvent:@"message" withData:data];
    [self.tableData addObject:data];
    [self.tableView reloadData];
}

@end
