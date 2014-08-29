//
//  RootViewController.m
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "RootViewController.h"
#import "DBImageView.h"

static NSString *const kCellIdentifier = @"kCellIdentifier";
static CGFloat const kCellHeight = 80.0;

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    NSArray *_items;
}

@property (nonatomic, strong) UIView *headerView;
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _items = @[@"http://www.caos.bg.it/immagini/albero_3.jpg",
                   @"http://1.bp.blogspot.com/-AWQC0Kw9q_Q/Uq8uHsrQkpI/AAAAAAAAFVo/GHOKcf7nrXw/s640/cars.png",
                   @"http://www.german-concept-cars.com/wp-content/uploads/2010/05/German-concept-Cars-Home1.jpg",
                   @"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSOUxre9MKwPxFwb89wO33V4PzzCFnZ5ttP6tWmP5YQzRtk_40h",
                   @"http://assets.esquire.co.uk/images/uploads/fourbythree/_540_43/l_236-four-of-the-best-american-muscle-cars-2.jpg",
                   @"http://sportscommunity.com.au/wp-content/uploads/2013/01/sports-collage.jpg",
                   @"http://i.telegraph.co.uk/multimedia/archive/01806/earth_1806334c.jpg",
                   @"https://battlingthedemonswithin.files.wordpress.com/2013/09/earth-cd321c592915ddb9165e20d1053edce9ee78cd3b-s6-c30.jpg",
                   @"http://upload.wikimedia.org/wikipedia/commons/c/cc/2008_Ducati_848_Showroom.jpg",
                   @"http://kickstart.bikeexif.com/wp-content/uploads/2014/01/ducati-999.jpg",
                   @"http://kickstart.bikeexif.com/wp-content/uploads/2012/09/ducati-pantah-2.jpg",
                   @"http://static.derapate.it/derapate/fotogallery/625X0/3775/ducati-999.jpg",
                   @"http://siliconangle.com/files/2012/03/github_logo.jpg",
                   @"https://octodex.github.com/images/octobiwan.jpg",
                   @"https://octodex.github.com/images/murakamicat.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear Cache" style:UIBarButtonItemStylePlain target:self action:@selector(clearCache)];
    
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setRowHeight:kCellHeight];
    [_tableView setTableHeaderView:self.headerView];
    [self.view addSubview:_tableView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) clearCache
{
    [DBImageView clearCache];
}

- (UIView *) headerView
{
    if ( !_headerView ) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, 320, 100 }];
        [_headerView setBackgroundColor:[UIColor grayColor]];
        DBImageView *imageView = [[DBImageView alloc] initWithFrame:(CGRect){ 120, 10, 80, 80 }];
        [imageView.layer setCornerRadius:40];
        [imageView setImageWithPath:@"https://scontent-a.xx.fbcdn.net/hphotos-xfa1/v/t1.0-9/10577058_10204359246124455_969288110705724720_n.jpg?oh=851258b8fd22341daf325b256d227fd8&oe=547E80AC"];
        [_headerView addSubview:imageView];
    }
    
    return _headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        
        DBImageView *imageView = [[DBImageView alloc] initWithFrame:(CGRect){ 10, 10, 60, 60 }];
        [imageView setPlaceHolder:[UIImage imageNamed:@"Placeholder"]];
        [imageView setTag:101];
        [cell.contentView addSubview:imageView];
    }
    
    [(DBImageView *)[cell viewWithTag:101] setImageWithPath:_items[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[DBImageView triggerImageRequests:NO];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[DBImageView triggerImageRequests:YES];
}

@end