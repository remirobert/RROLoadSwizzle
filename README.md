# RROLoadSwizzle

![buid status](https://app.bitrise.io/app/14d90a9dfd5ce2e8/status.svg?token=uQY671hjdyKtODwsl18vfA) [![codecov](https://codecov.io/gh/remirobert/RROLoadSwizzle/branch/master/graph/badge.svg)](https://codecov.io/gh/remirobert/RROLoadSwizzle)

Used to assist in unit testing.
Check **Tests** for usage.

```Objective-c

//A function which is the implementation of original method. 
//The function must take at least two arguments—self and _cmd.
void (*gOriginalViewDidLoad)(id, SEL);

- (void)tearDown {
    RRO_REVERT_SWIZZLE_ALL_METHOD([UIViewController class]);
}

- (void)testThatViewDidLoadIsCalledWhenShowWindow {
  __block BOOL isViewDidLoadCalled = NO;
  
  void (^viewDidLoadBlock)(UIViewController *, SEL) = ^void (UIViewController *nav, SEL _cmd) {
    isViewDidLoadCalled = true;
    NSLog(@"viewDidLoad called here");

    //call original @selector(viewDidLoad) if needed
    gOriginalViewDidLoad(nav, _cmd); 
  };
  
  RRO_SWIZZLE_BLOCK([UIViewController class], @selector(viewDidLoad), viewDidLoadBlock, &gOriginalViewDidLoad);
  
  UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  window.rootViewController = [[UIViewController alloc] init];
  [window makeKeyAndVisible];
  
  XCTAssertTrue(isViewDidLoadCalled);
}
```
