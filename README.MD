#Summary
根据JSON/plist/NSDictionary动态创建UITableView，并提供事件支持。

#Description
在常规则的iOS App的开发当中，我们经常会遇到UITableView需要构造，使用最多的是选项功能，但构造UI可能会花费我们一些不必要的时间。UIDataTable就是为了解决这个问题，它会根据一个plist文件、JSON文件或者一个NSDictionary，来动态创建一个UITableView，支持四种数据类型和样式。

#如何使用？

1. Clone项目到本地，`git clone http://github.com/conis/UIDataTable.git`
2. 用xCode打开项目并运行

更多请参考具体的代码，调用代码全部在`ViewController`中，代码中有非常详细的说明，不再赘述

#其它说明
1. JSON文件的格式，请参考option.samples.json，当中有详细的注释
2. JSON文件需要严格遵从JSON.org的规范，可以使用[jsonlint](http://jsonlint.com/)进行在线校验。
3. plist请参考option.plist文件

#关于作者
[涂雅](http://iove.net/)
#License
MIT
