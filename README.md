# jiaModuleDemo

jiaModuleDemo项目是为了解决关于项目中如何进行模块化开发而编写的实例，包含如何进行路由式、本地模块间交互的实现；目前还是在页面层级进行抽离，对于项目中各个模块共有的基础功能也进行提取，可以结合私有Pods进行管理；

#项目中存在的问题
```obj-c
问题一：页面耦合严重
```
<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/7.png" width=800px height=400px></img>

上面这张图中左边体现了目前项目中存在的问题，对于页面之间相互耦合，而页面之间的传参也各不相同，由于不同的开发人员或者简便方式等原因，传参的类型都有差异，包含如实体、简单基本类型等，先前项目对于路由方式也不支持，导致要实现收到消息推送进行不同的页面跳转存在硬编码情况，对于功能扩展存在相当大的问题；而右边则是模块化后页面之间的交互方式；页面之间也不存在耦合关系，都只跟JiaMediator这个中介者相依赖；而传参都统一成以字典的形式；虽然可能牺牲一些方便跟随意，却可以解耦模块化；并且加入对路由方式的处理；约定好相关的协议进行交互；用这种路由方式代替那些第三方的路由插件则是因为它的灵活性，最主要还是省去了第三方路由插件在启动时要注册路由的问题；

```obj-c
问题二：相同模块重复开发
```
<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/9.png" width=800px height=400px></img>

当公司里面有多个项目同时进行，并且有可能是多个人分别不同项目时，就会存在如上图出现的情况，其实每个APP中都是有很多共同的模块，当然有可能你会把相同功能模块代码复制一份在新项目中，但这其实并不是最好的方式，在后期不断迭代过程中，不同的人会往里面增加很多带有个人色彩的代码；这样就像相同的模块项目后期对于多个项目统一管理也是灾难性，有可能会失控，哪怕项目转移别人接手也会无形中浪费很多时间，增加维护成本，所以实例中更注重对于一些相同模块进行提取，求同存异；而模块化结合私有Pods进行管理，对于常用功能的封装，只要开放出一些简单开关配置方式，就可以实现一个功能，比如日志记录、网络请求模块、网络状态变化提示等；

#整体实现效果图
<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/1.png" width=500px height=400px></img>

```obj-c

```

实现调用代码：

```obj-c
NSDictionary *curParams=@{kDesignerModuleActionsDictionaryKeyName:@"wujunyang",kDesignerModuleActionsDictionaryKeyID:@"1001",kDesignerModuleActionsDictionaryKeyImage:@"designerImage"};
    switch (indexPath.row) {
        case 0:
        {
            UIViewController *viewController=[[JiaMediator sharedInstance]JiaMediator_Designer_viewControllerForDetail:curParams];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 1:
        {
            UIViewController *viewController=[[JiaMediator sharedInstance]JiaMediator_Designer_viewControllerForDetail:curParams];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 2:
        {
            NSString *curRoue=@"jiaScheme://Designer/nativeFetchDetailViewController?name=wujunyang&ID=1001&image=designerImage";
            UIViewController *viewController=[[JiaMediator sharedInstance]performActionWithUrl:[NSURL URLWithString:curRoue] completion:^(NSDictionary *info) {
                
            }];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
```
`上面针对本地模块调用及路由方式调用的跳转`

1：JiaMediator起到一个中介的作用，所有的模块间响应交互都是通过它进行，每个模块都会对它进行扩展分类（例如：JiaMediator+模块A），分类主要是为了用于本地间调用而又不想用路由的方式，若要用路由的方式则要注意关于路由约束准确编写，它将会直接影响到能否正确响应到目标；

<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/3.png" width=200px height=400px></img>

2：JiaMediator是每个模块都要用到的内容，可以把它放在公共的模块中，因为关于各个模块的JiaMediator由每个模块自个负责，开放给要调用的模块使用；



3：为了解耦对于页面间的传参都采用字典形式，项目中所有的页面都继承于一个基页面jiaBaseViewController，里面已经有对初始化对于字典参数的接收并赋值，每个模块的子页面只要调用parameterDictionary属性，就可以获取关于参数的内容；同样jiaBaseViewController也是每个模块都要使用，所以也被提取在公共里面，其还包括一些导栏条的封装及关于网络状态变化的提示等；



```obj-c

//页面接收参数
@property(nonatomic,strong)NSDictionary *parameterDictionary;
//初始化参数
- (id)initWithRouterParams:(NSDictionary *)params;


- (id)initWithRouterParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        _parameterDictionary=params;
        NSLog(@"当前参数：%@",params);
    }
    return self;
}
```

<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/2.png" width=500px height=400px></img>

4：当响应某一个模块目标后，将会把相应的viewController进行返回，而对于具体如何操作则是在获得当前控制器自行处理，比如是跳转还是弹出展现；

5：为了减少对于字典参数key拼写错误问题，每个模块都有一个对应key值的常量配置文件，已经把对应的key值都定义成的常量，方便调用；

```obj-c
#ifndef HeaderDesignerConfig_h
#define HeaderDesignerConfig_h

//键值
static NSString * const kDesignerModuleActionsDictionaryKeyName=@"name";
static NSString * const kDesignerModuleActionsDictionaryKeyID=@"ID";
static NSString * const kDesignerModuleActionsDictionaryKeyImage=@"image";

#endif /* HeaderDesignerConfig_h */

```

```obj-c

 NSDictionary *curParams=@{kDesignerModuleActionsDictionaryKeyName:@"wujunyang",kDesignerModuleActionsDictionaryKeyID:@"1001",kDesignerModuleActionsDictionaryKeyImage:@"designerImage"};

```
6:对于网络请求模块则采用YTKNetwork，底层还是以AFNetworking进行网络通信交互，在基础全局模块JiaCore中，定义一个继承于YTKBaseRequest的JiaBaseRequest，针对JiaBaseRequest则是为了后期各个APP可以对它进行分类扩展，对于一些超时、请求头部等进行统一个性化设置，毕竟这些是每个APP都不相同；而针对模块中关于请求网络的前缀设置，则在每个模块中都有一个单例的配置类，此配置类是为了针对该模块对不同APP变化而定义；相应的配置内容开放给APP，由具体APP来定义，例如现在项目中的JiaBaseRequest+App.h类，里面有简单设置超时跟头部；当然记得把这个分类引入到APP中，比如AppPrefixHeader这个APP的全局头部；

```obj-c
#import "JiaBaseRequest+App.h"

@implementation JiaBaseRequest (App)

- (NSTimeInterval)requestTimeoutInterval {
    return 15;
}

//公共头部设置
- (NSDictionary *)requestHeaderFieldValueDictionary
{
    NSDictionary *headerDictionary=@{@"platform":@"ios"};
    return headerDictionary;
}

@end
```

```obj-c
网络交互说明如下：
```
<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/4.png" width=500px height=400px></img>

7：消息推送对于一个APP是相当重要性，一般是采用第三方的SDK进行集成，其实大部分的SDK处理代码都是差不多，在这实例中对差异化的内容进行提取，实例中将以个推进行模块化，因为消息推送的大部分代码都集中在AppDelegate中，造成的一大堆杂乱代码，当然也有一部分人对AppDelegate进行扩展分类进行移除代码，实例中将采用另外一种解决方案进行抽取，可以达到完全解耦，在具体的APP里面将不会再出现个推SDK相关内容，只要简单进行配置跟处理消息就可以，下面只是简单的列出部分代码，其它封装代码见源代码；
```obj-c
    //设置个推模块的配置
    jiaGTConfigManager *gtConfig=[jiaGTConfigManager sharedInstance];
    gtConfig.jiaGTAppId=@"0uuwznWonIANoK07JeRWgAs";
    gtConfig.jiaGTAppKey=@"26LeO4stbrA7TeyMUJdXlx3";
    gtConfig.jiaGTAppSecret=@"2282vl0IwZd9KL3ZpDyoUL7";
```
```obj-c
#pragma mark 消息推送相关处理

/**
 *  @author wujunyang, 16-07-07 16:07:25
 *
 *  @brief  处理个推消息
 *
 *  @param NotificationMessage
 */
-(void)gtNotification:(NSDictionary *)NotificationMessage
{
    NSLog(@"%@",NotificationMessage[@"payload"]);
    NSLog(@"－－－－－接收到个推通知------");
}


/**
 *  @author wujunyang, 16-07-07 16:07:40
 *
 *  @brief  处理远程苹果通知
 *
 *  @param RemoteNotificationMessage
 */
-(void)receiveRemoteNotification:(NSDictionary *)RemoteNotificationMessage
{
    NSLog(@"%@",RemoteNotificationMessage[@"message"]);
    NSLog(@"－－－－－接收到苹果通知------");
}

/**
 *  @author wujunyang, 16-09-21 14:09:33
 *
 *  @brief 获得注册成功时的deviceToken 可以在里面做一些绑定操作
 *
 *  @param deviceToken <#deviceToken description#>
 */
-(void)receiveDeviceToken:(NSString *)deviceToken
{
    NSLog(@"－－－－－当前deviceToken：%@------",deviceToken);
}
```
<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/5.png" width=500px height=400px></img>

上面能够对个推进行完全的解耦不得不提一个第三方的插件XAspect，如果想对它进行了解可以在github进行查找；它的主要作用如下图，可以用它进行其它第三方SDK的抽离

<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/6.png" width=500px height=400px></img>

#模块化结合私有Pods方案
上面实例中只是把相关模块化的提取都在一个工程进行体现，最后还是要落实结合Pods进行管理，把每个模块分开管理，不同的APP可以简单通过Pods指令就可以达到引入模块的效果，对于一些相同模块可以在不同的APP重复引用，减小重复开发成本；

<img src="https://github.com/wujunyang/jiaModuleDemo/blob/master/jiaModuleDemo/ProjectImage/8.png" width=700px height=500px></img>