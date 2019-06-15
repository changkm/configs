Set working directory to parent:
git config core.worktree "../../"

create file .git in parent dir with following content:
gitdir: /home/USERNAME/configs/.git

To clone and setup:
git clone --no-checkout https://github.com/changkm/configs.gitcd configs
git config core.worktree "../../"
git reset --hard origin/master
