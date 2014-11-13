![Alt text](http://bogodaniele.com/apps/development/dbimageview/github/dbimageview_splash_2.png)

A simple object to load images asynchronously

##Getting Started

### Installation

The recommended approach for installating DBImageView is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation.

#### Podfile
```ruby
platform :ios, '6.0'
pod 'DBImageView', '~> 1.0'
```
## Integration
DBImageView has a simple integration:
```objective-c
#import "DBImageView.h"
```
Add DBImageView:
```objective-c
DBImageView *imageView = [[DBImageView alloc] initWithFrame:(CGRect){ 10, 10, 60, 60 }];
```

Set the remote image path:
```objective-c
[imageView setImageWithPath:@"remote_image_URL"];
```

### Options
You can set a placeholder:
```objective-c
[imageView setPlaceHolder:[UIImage imageNamed:@"Placeholder"]];
```
If you use a collection or a table, trigger the load action when you want
```objective-c
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[DBImageView triggerImageRequests:NO];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[DBImageView triggerImageRequests:YES];
}
```
##iOS Min Required
6.0

##Version
1.3

##Created By
[Daniele Bogo](https://github.com/danielebogo)
