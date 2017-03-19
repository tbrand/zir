# zir

[![Build Status](https://travis-ci.org/tbrand/zir.svg?branch=master)](https://travis-ci.org/tbrand/zir)
[![Dependency Status](https://shards.rocks/badge/github/tbrand/zir/status.svg)](https://shards.rocks/github/tbrand/zir)
[![devDependency Status](https://shards.rocks/badge/github/tbrand/zir/dev_status.svg)](https://shards.rocks/github/tbrand/zir)

**zir** is a command line tool that realizes to write macros in any scripts into any languages.  
See an example. (The macro is written in Ruby)
```c
#include<stdio.h>

int main(){
  <-@macro puts "double a = #{Math::PI};" ->
  printf("PI is %f!\n", a);
  return 0;
}
```
This file will be expanded by zir like
```c
#include<stdio.h>

int main(){
  double a = 3.141592653589793;
  printf("PI is %f!\n", a);
  return 0;
}
```

The result is `PI is 3.141593!`. :smile:
You can find other samples at [here](https://github.com/tbrand/zir/tree/master/spec/projs).

## Installation

zir is written in Crystal. So you need the environment. After that, clone this project and build by
```
shards build
```
Now you can find an executable binary at `zir/bin/zir`

## Usage

### Flow of the expandation

1. Search zir files (such as sample.c.z)
2. Collect macros from the files
3. Create temporary files to be executed
4. Execute the scripts
5. Embed the result into the files (such as sample.c)

### zir.yaml

zir.yaml is a configuration file to execute zir. You must put it on a root of your project. zir.yaml is consists of 3 parts.

Specify files to be expanded in **targets**. The files must end with **.z**. **.z** will be removed from the name of expanded files. So sample.c.z will be sample.c.
```yaml
targets: # An example
  - sample.c.z
```

Tell me how to execute the macros in **ids**. It need identifier and command line sample. **@file** will be replaced to a temporary executable.
```yaml
# 'macro' is an identifier and `ruby some_temporary_executable` will be executed
ids:
  macro: ruby @file
```

What to execute at finally?
```yaml
finally:
  gcc -o a.out sample.c
```

Here is a fully example.
```yaml
targets:
  - sample.c.z
  
ids:
  macro: ruby @file

finally:
  gcc -o a.out sample.c  
```

### Write macros

The structure of macros is here.
```
<-@id your_code_here ->
```

All macros are sandwiched by `<- ->`. In the above example, `@` is called **mark** and it can be `%` as well. `id` is an identifier which is defined in zir.yaml. Puts your code at `your_code_here`.

There are 2 types of macros and each of them has their mark.

First one is **print macro** that will be embeded into a source code. The mark of the print macro is **@**. Print macro shouldn't contain any logics but just print out variables. Here is an example of it.
```
<-@id puts "a" ->
```

Second one is **logic macro** that contains logics only. So This will print out nothing. Logic macros affect to the print macros which have same id with it.
```
<-%id0 a = 10 ->
<-%id1 a += 1 ->
<-@id0 puts a ->
```
So the result of this will be 10.
See [sample projects](https://github.com/tbrand/zir/tree/master/spec/projs) to know how to write these macros.

### command line

Basically, you just run `zir run` at root of your project. If you want to clean all temporary files, you can do it by `zir clean`. If you need a sample of zir.yaml, you can get it by `zir init`.

`-c DEPTH` or `--cealn=DEPTH` options help you to debug. You can specify which files to keep or to delete. DEPTH can be 0 to 2. If you specify 0, zir will keep all temporary files. Intermediate executable scripts are in .zir directory. 1 is default value that delete .zir directory but keep expanded files. So when you expand sample.c.z, expanded sample.c will remain. 2 will delete all files created by zir. (Delete sample.c in the previous case.)

`zir -h` will show you more options.

## Contributing

1. Fork it ( https://github.com/tbrand/zir/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tbrand](https://github.com/tbrand) Taichiro Suzuki - creator, maintainer
