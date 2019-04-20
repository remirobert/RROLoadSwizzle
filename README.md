# RROLoadSwizzle

```Objective-c

//A function which is the implementation of original method. 
//The function must take at least two arguments—self and _cmd.
void (*gOriginalViewDidLoad)(id, SEL);

void (^pushViewControllerBlock)(UIViewController *, SEL) = ^void (UIViewController *nav, SEL _cmd) {
  NSLog(@"viewDidLoad called here");

  //call original @selector(viewDidLoad)
  gOriginalViewDidLoad(nav, _cmd); 
};
RRO_SWIZZLE_BLOCK([UIViewController class], @selector(viewDidLoad), pushViewControllerBlock, &gOriginalViewDidLoad);
```
