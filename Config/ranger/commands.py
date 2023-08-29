# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -------------------------------------Edit File----------------------------------------

# You can import any python module as needed.
from __future__ import (absolute_import, division, print_function)
from ranger.api.commands import Command
import os

class my_edit(Command):
    """:my_edit <filename>

    Use Neovim Edit File
    """
    def execute(self):
        if self.arg(1):
            target_filename = self.rest(1)
        else:
            # self.fm is a ranger.core.filemanager.FileManager object and gives
            # you access to internals of ranger.
            # self.fm.thisfile is a ranger.container.file.File object and is a
            # reference to the currently selected file.
            target_filename = self.fm.thisfile.path
        self.fm.notify("nvim " + target_filename + " !")
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return
        # Check out the source, or run "pydoc ranger.core.actions" for a list.
        #self.fm.edit_file(target_filename) ## 使用内置的函数只能打开无配置的neovim
        self.fm.run('nvim ' + target_filename)  # 可以打开有插件配置的neovim

    # tabnum is 1 for <TAB> and -1 for <S-TAB> by default
    def tab(self, tabnum):
        return self._tab_directory_content()

# ---------------------------------------Set Wallpaper--------------------------------------
class set_wallpaper(Command):
    """:set_wallpaper <filename>

    set the system bg
    """

    def execute(self):
        from PIL import Image
        #import errno
        # 如果选中多个文件，只使用第一个文件设置壁纸
        target_filename = self.fm.thistab.get_selection()[0].path if len(self.fm.thistab.get_selection()) > 0 else None ## self.fm.thisfile.get_selection > 0 获取当前路径
        if not target_filename:
            # 获取当前文件的路径
            target_filename = self.fm.thisfile.path

        # 检查文件是否为图片 (可以省去检测的步骤，因为最终swww 也无法将选中的文件设置为壁纸)
        #try:
            #with Image.open(target_filename) as img:
                # 解码图像文件并检查文件格式是否正确
                #img.verify()
        #except (IOError, OSError) as e:
            #if e.errno == errno.ENOENT:
                #self.fm.notify("The given file does not exist!", bad=True)
            #else:
                #self.fm.notify(f"Selected file {os.path.basename(target_filename)} is not an image.", bad=True)
            #return

        # 输出一条信息到底栏
        self.fm.notify("设置壁纸为： " + target_filename)
        # 调用外部脚本程序
        #self.fm.run('ln -sf ' + target_filename + ' ~/.config/rice_assets/Images/wallpaper.png')
        self.fm.run('swww img "' + target_filename + '" --transition-bezier .1,1,.1,.4 --transition-type grow --transition-fps 60 --transition-step 250 --transition-pos "$(hyprctl cursorpos)" --transition-duration 3')
        #self.fm.run('bspc wm -r') ## for bspwm reflash the desktop

# ---------------------------------------Select with fzf--------------------------------------
class fzf_select(Command):
   """
   :fzf_select
   Find a file using fzf.
   With a prefix argument to select only directories.

   See: https://github.com/junegunn/fzf
   """

   def execute(self):
       import subprocess
       from ranger.ext.get_executables import get_executables

       if 'fzf' not in get_executables():
           self.fm.notify('Could not find fzf in the PATH.', bad=True)
           return

       fd = None
       if 'fdfind' in get_executables():
           fd = 'fdfind'
       elif 'fd' in get_executables():
           fd = 'fd'

       if fd is not None:
           hidden = ('--hidden' if self.fm.settings.show_hidden else '')
           exclude = "--no-ignore-vcs --exclude={.wine,.git,.idea,.vscode,.sass-cache,node_modules,build,.local,.steam,.m2,.rangerdir,.ssh,.ghidra,.mozilla} --exclude '*.py[co]' --exclude '__pycache__'"
           only_directories = ('--type directory' if self.quantifier else '')
           fzf_default_command = '{} --follow {} {} {} --color=always'.format(
               fd, hidden, exclude, only_directories
           )
       else:
           hidden = ('-false' if self.fm.settings.show_hidden else r"-path '*/\.*' -prune")
           exclude = r"\( -name '\.git' -o -iname '\.*py[co]' -o -fstype 'dev' -o -fstype 'proc' \) -prune"
           only_directories = ('-type d' if self.quantifier else '')
           fzf_default_command = 'find -L . -mindepth 1 {} -o {} -o {} -print | cut -b3-'.format(
               hidden, exclude, only_directories
           )

       env = os.environ.copy()
       env['FZF_DEFAULT_COMMAND'] = fzf_default_command
       env['FZF_DEFAULT_OPTS'] = '--height=100% --layout=reverse --ansi --preview="{}"'.format('''
           (
               ~/.config/fzf/fzf_preview.py ||
               ~/Tools/Other/fzf-scope.sh {} ||
               #batcat --color=always {} ||
               bat --color=always {} ||
               #cat {} ||
               tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
           ) 2>/dev/null | head -n 100
       ''')

       fzf = self.fm.execute_command('fzf --no-multi', env=env,
                                     universal_newlines=True, stdout=subprocess.PIPE)
       stdout, _ = fzf.communicate()
       if fzf.returncode == 0:
           selected = os.path.abspath(stdout.strip())
           if os.path.isdir(selected):
               self.fm.cd(selected)
           else:
               self.fm.select_file(selected) 
