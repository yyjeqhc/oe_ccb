## Ubuntu内安装使用

```sh
#下载解压包，进入解压出来的根目录
#https://gitee.com/src-openeuler/ccb/
#原来的补丁看情况需要自己手动下载，打补丁

#复制Makefile到项目根目录
root@oe:~/ccb# ls
lib  LICENSE  Makefile  README.md  sbin  tests

#安装，然后按照提示操作
make install
source /usr/local/lib/ccb/lib/env.sh
#填写账号密码
vim ~/.config/cli/defaults/config.yaml
#主机至少需要以下组件 
#apt install ruby ruby-rest-client curl wget docker-cli patch

#打补丁（可选） select_image.patch
#默认安装是这个位置,复制补丁过去
#cp select_image.patch /usr/local/lib/ccb
cd /usr/local/lib/ccb
patch -p1 < select_image.patch

#使用部分就和在openeuler的主机一样了。
```

## 容器内使用

构建镜像：

```sh
docker build -t oe:ccb .
```
启动容器：

```sh
docker run -itd --name oe --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp oe:ccb bash
```

设置euler网站的账号密码，注意特殊字符（）

```sh
#进入容器内部操作
vim ~/.config/cli/defaults/config.yaml
```

下载镜像进行构建：

```sh
#构建成功
ccb local-build os_project=openEuler-24.03-LTS:everything package=pcre2 2>&1 | tee -a build_output.log
```

使用补丁(可选):

```sh
#主机操作
docker cp select_image.patch oe:/usr/libexec/ccb/
docker exec -it oe bash
#容器内操作
cd /usr/libexec/ccb
patch -p1 < select_image.patch

#之后，就可以使用本地镜像进行构建了，构建的内容还是保存在主机相同的位置,见构建log的输出
#上面的构建本地已经有 5542887c99f6 这个镜像了
#主机 docker tag 5542887c99f6 2403lts:1
#构建成功
ccb local-build --local-image=2403lts:1 os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log
#构建成功
ccb local-build --local-image=5542887c99f6 os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log

#失败，找不到镜像
ccb local-build --local-image=1234567890 os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log
#失败，找不到镜像
ccb local-build --local-image=nonexist:now os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log
```

这样的话，在容器内使用ccb就和在主机使用ccb没有区别了

