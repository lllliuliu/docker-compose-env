# LEMPR标准环境配置
当前配置为基于 docker-compose 编排，支持多种环境（dev、pro、test）的不同模式。

* [安装环境](#安装环境)
* [快速开始](#快速开始)
* [使用方式](#使用方式)
* [配置说明](#配置说明)
    * [docker-compose环境配置文件](#docker-compose环境配置文件)
        * [容器相关](#容器相关)
        * [卷相关](#卷相关)
        * [应用相关](#应用相关)
    * [Nginx配置文件](#nginx配置文件)
    * [PHP配置文件](#php配置文件)
    * [MariaDB配置文件](#mariadb配置文件)
* [PHP相关](#php相关)
    * [PHP多镜像说明](#php多镜像说明)
    * [添加PHP扩展](#添加php扩展)
    

## 安装环境
- Docker CE 18.03+
- docker-compose 1.21+

## 快速开始
1. 拉取当前仓库代码到指定目录，当前假定为 `/dc`，并进入此目录
2. 复制 `.env.demo` 到 `.env` 文件，并修改相关配置，配置说明见[docker-compose环境配置文件](#docker-compose环境配置文件)
3. 启动 `docker-compose up -d`
4. 访问 `http://test.self.com:NGINX_PORT/`(端口号替换成 .env 文件的 NGINX_PORT 配置，域名通过通过 nginx 配置)

## 使用方式
进入 `/dc` 之后，所有使用方式和 **docker-compose** 使用方式一致，主要使用命令如下：
- 启动：`docker-compose up -d`
- 重启：`docker-compose up -d`
- 重启并重新构建镜像：`docker-compose up -d --build`
- 停止并删除相关：`docker-compose down`

## 配置说明

### docker-compose环境配置文件
`.env` 文件为 **docker-compose** 的环境配置文件，主要用于指定 docker-compose.yml 中的一些配置。

当前 `.env.demo` 中指定了需要填写的一些配置，请自行复制到 `.env` 文并修改相关配置，具体配置项说明如下：

#### 容器相关
- `PHPMYADMIN_PORT` phpmyadmin 工具暴露到宿主机的端口
- `NGINX_PORT` nginx 暴露到宿主机的端口
- `REDIS_PORT` redis 暴露到宿主机的端口
- `MARIADB_PORT` mariadb 暴露到宿主机的端口
- `NETWORK_NAME` 网络名，所有容器都加入这个指定网络，如果不使用初始化脚本，配置之后还需要使用 ***docker network create*** 命令自行创建网络

#### 卷相关
- `VOLUME_ROOT` 挂载卷根目录。所有写入文件的根目录，包含数据库文件、日志文件、redis数据文件等
- `REPO_ROOT` 代码仓库挂载卷目录
    - 在 ***test*** 环境下，仓库容器会自动根据 `REPO_URL` 地址拉取代码，所以此环境下宿主机目录不需要任何文件
    - 在 ***dev*** 环境下，不会自动拉取代码，所以需要在 docker 启动之前在宿主机目录自行拉取代码

#### 应用相关
应用配置在不同环境下处理逻辑略有不同
- `APP_ENV` 应用环境，目前支持 ***dev***、***test***
- `MYSQL_ROOT_PASSWORD` 数据库 ROOT 账号
- `MYSQL_DATABASE` 项目数据库名，在 ***test*** 环境下会自动修改项目的 ***.env.test*** 相关配置
- `MYSQL_USER` 项目数据库用户名，在 ***test*** 环境下会自动修改项目的 ***.env.test*** 相关配置
- `MYSQL_PASSWORD` 项目数据库密码，在 ***test*** 环境下会自动修改项目的 ***.env.test*** 相关配置
- `REPO_URL` 项目代码 git 仓库 URL，建议使用 gitlab 的 ***Deploy Tokens*** 来拉取代码

### Nginx配置文件
Nginx 配置在 `/nginx` 目录下，包含两个主要配置：
- `nginx.conf` 主要配置，一般不需要修改
- `conf.d` server 配置，如有需要可以新增或修改，访问域名就在这里配置，如果需要配置 HTTPS ，则需要修改 Dockerfile 导入相关文件 ***(@TODO)***

### PHP配置文件
PHP 配置在 `/php` 目录下，根据不同的版本包含不同的子文件夹，并包含了[多个不同的镜像](#php多镜像说明)，主要配置有：
- `php.ini` 主配置
- `fpm/php-fpm.d` fpm 配置

这些配置一般不需要修改，如果需要新增扩展，请见[添加 PHP 扩展](#添加php扩展)

### MariaDB配置文件
MariaDB 当前直接使用的官方镜像，并使用默认配置
以后会自定义相关配置 ***(@TODO)***

## PHP相关
PHP 相关都包含在 `/php` 目录下，根据不同的版本包含不同的子文件夹，包含多个不同的镜像，公用一个 **php.ini** 文件，同时它们全部都挂载同一个仓库卷 **/data**，里面包含相关代码。

PHP 系统启动基本流程是 `repo` 容器启动并初始化操作，然后 `cli` 容器启动后台任务，最后才启动 `fpm` 容器；其他容器都会等待 `repo` 容器启动之后才开始启动，在初始化脚本中会等待 **fin.lock** 文件生成(标识 `repo` 容器启动完毕)。

所有 PHP 镜像都是基于官方镜像，所以全部使用公共的用户和用户组 **www-data:www-data**，官方相关命令如下：

```
RUN set -x \
	&& addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -G www-data www-data
```

所以 `repo` 镜像实例化启动容器的时候，会修改相关权限，其他容器的相关目录也都需要修改。

由于镜像分离，`fpm` 和 `cli` 镜像都可以在 **docker-compose** 启动时添加 `--scale` 参数来按照需求弹性伸缩，比如我启动3个 `fpm` 容器和2个 `cli` 容器：

```
docker-compose up --build --scale php7-fpm=3 --scale php7-cli=2 -d
```

### PHP多镜像说明
当前镜像分为 3 个：
- `cli` 命令行镜像用于运行任务，比如后台队列任务等
- `fpm` fpm 镜像用于 Nginx 反向代理，这里包含一个 **php-fpm.d** 文件夹，里面包含了 fpm 相关配置；并重写了 **php-entrypoint** 入口做一些 fpm 启动的初始化操作。
- `repo` 仓库镜像主要是做一些权限变更、代码拉取、数据库初始化等初始化操作，所以这是最先实例化启动容器的镜像。

### 添加PHP扩展
官方对添加扩展有标准化说明，请参考[PHP-DOCKER官方说明](https://hub.docker.com/_/php/)，启动有的扩展需要在编译时添加配置和预装程序，都可以直接参考 PHP 下多个镜像的 Dockerfile 文件。