# Docker on Rails

## Setup docker

To create a new ruby on rails project you don't need to install any software instead of Docker and Docker Compose.
For Mac or Windows I recommend [Docker Toolbox](https://www.docker.com/docker-toolbox).

### Docker Toolbox

After installing the Docker Toolbox you need to create a new Docker Machine.
In this case the machine name is `dev` and the disk size is 20GB.
You can change it if you want.

```bash
docker-machine create --virtualbox-disk-size 20000 --driver virtualbox dev
```

I prefer to install [docker-machine-nfs](https://github.com/adlogix/docker-machine-nfs) as well.

```bash
curl -s https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/docker-machine-nfs.sh |
  sudo tee /usr/local/bin/docker-machine-nfs > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-machine-nfs
```

After installing docker-machine-nfs we can use nfs instead of shared folders.
This is much faster.

```bash
docker-machine-nfs dev
```

Enable docker to use the created machine.

```bash
eval "$(docker-machine env dev)"
```

Open `/etc/exports` and replace `-mapall=$uid:$gid` with `-maproot=0` and restart the service `sudo nfsd restart`.

One last step is to set the IP from the docker machine to your `/etc/hosts` file.
Replace `rails.dev.io` to a domain how you want to reach the project locally.

```bash
echo "192.168.99.100 rails.dev.io" | sudo tee -a /etc/hosts
```

That's all for setting up our environment.

### SSL

If you run you application you need to generate a SSL certificate and store it in `docker/nginx/ssl`.
Then change the parameters `ssl_certificate` and `ssl_certificate_kes` in `docker/nginx/sites-enabled/rails.conf`.

## Starting with Docker on Rails

### Create a new project

At first you need to clone this repository and go to the repository folder.

```bash
git clone git@github.com:mc388/docker-on-rails.git && cd docker-on-rails
```

Next you can create a new ruby on rails project.
In this case we create a rails project in version `5.0.0.beta1` (you can change the version in the `Dockerfile`).
Let's create a new project.

```bash
docker-compose run --rm rails rails new . -d mysql -T
```

The installer will ask you if you want to overwrite the `README.md` file.
It is your choice if you want to keep this file or replace it with the `README.md` from rails.

And that's it.
The new project is created.

Because docker is running as `root` you may need to change the owner of the generated files.

``` bash
sudo chown -R $USER .
```

### Setup database connection

The next step is to setup the database connection in `config/database.yml`.
This is the default configuration.
I only changed the `host` to `mysql` and the `database` to `rails_dev`.
The host `mysql` is the name of the docker container.
The database name is set in the `docker-compose.yml`.
Feel free to change the name.

```yml
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: root
  password:
  host: mysql

development:
  <<: *default
  database: rails_dev
```

### Start the webserver

After creating the project we can test if everything if working.

```bash
docker-compose up -d
```

If you now visit the url you set in you `/etc/hosts` file you should see the default ruby on rails page.

### Run commands

You can easily run all `rails`, `rake` or `bundle` commands inside the rails docker container.
Replace `<my command>` with something like `bundle install` or `rails g scaffold user name:string`

```bash
docker-compose run --rm rails <my command>
```
