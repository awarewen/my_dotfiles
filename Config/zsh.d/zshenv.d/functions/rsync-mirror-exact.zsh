# rsync-mirror-exact => rsync-mirror then delete all extraneous dest items.
#
# 镜像同步，在源文件夹和目标文件夹之间进行内容的镜像同步。
# 并且确保目标目录中的内容和源目录完全相同，rsync 会检查目标文件夹中是否有源文件夹中没有的文件，如果存在则在完成复制后删除。
#
# Example:
#
#     rsync-mirror-exact ~/foo/ ~/bar/
#
#     '-a': 表示归档模式(archive mode), 它会保持文件的属性 （如权限，时间等），并递归的复制目录，等价于 '-rlptgoD' 请注意，-a 不保留硬链接，因为查找多重链接的文件是昂贵的。必须单独指定 -H。
#     '-H': 保留硬链接。这个选项指示 rsync 在目标上创建与源中硬链接相同的硬链接。
#     '-O': 保留设备文件 (character and block devices)。
#     '-x': 不要跨越文件系统边界。这将防止 rsync 跨越挂载的文件系统边界进行复制。
#     '-z': 压缩文件传输，减少数据传输量。
#     '-v': 显示详细输出，让你看到哪些文件被复制。
#     '--delete-after': 这个选项指示 rsync 在完成复制后再删除目标中的多余项目。这样做是为了防止覆盖现有文件，特别是对于可能互相链接的文件（例如网站页面）。
#     '$@': 这是一个特殊的参数，它表示将函数调用时传递给 rsync-mirror-exact 函数的所有参数都传递给实际的 rsync 命令。
#
# We use --delete-after, rather than --delete-before or --delete-during,
# because we want the command to be able to copy on top of existing items
# that may link to each other, such as a website that has many pages.
#
rsync-mirror-exact(){
    rsync -aHOxzvi --delete-after "$@"
}
