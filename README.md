# blog

data of https://zajann.github.io (with hugo)

## Set Up
```bash
# clone root repository
git clone https://github.com/zajann/blog.git

# init & update submodule(for publish, theme)
git submodule init
git submodule update
# to escape detached HEAD of submodule's branch
git submodule foreach git checkout master 
git submodule foreach git pull origin master 
```

## Deploy
```bash
./deploy.sh "commit message"
```
