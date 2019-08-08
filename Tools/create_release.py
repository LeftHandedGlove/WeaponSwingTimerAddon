import os
import re
from distutils.dir_util import copy_tree
import shutil
import stat


# Used to delete stubborn git files
def del_rw(action, name, exc):
    os.chmod(name, stat.S_IWRITE)
    os.remove(name)

# Change to the top level of the addon
os.chdir('..')

# Get new version number
with open(r'Tools\version', 'r') as version_file_handle:
    old_version = str(version_file_handle.read()).strip()
new_version = input('Previous version number: ' + old_version + '\nNew version number: ')
with open(r'Tools\version', 'w') as version_file_handle:
    version_file_handle.write(new_version)

# Open the toc file and replace the version
print("Replacing version in .toc file")
with open(r'WeaponSwingTimer.toc', 'r') as toc_file_handle:
    all_toc_lines = toc_file_handle.read()
new_all_toc_lines = re.sub('## Version: .*', '## Version: ' + new_version, all_toc_lines)
with open(r'WeaponSwingTimer.toc', 'w') as toc_file_handle:
    toc_file_handle.write(new_all_toc_lines)

# Open the core and replace the version
print("Replacing version in core file")
with open(r'WeaponSwingTimer_Core.lua', 'r') as core_file_handle:
    all_core_lines = core_file_handle.read()
new_all_core_lines = re.sub('Version.*by', 'Version ' + new_version + ' by', all_core_lines)
with open(r'WeaponSwingTimer_Core.lua', 'w') as core_file_handle:
    core_file_handle.write(new_all_core_lines)

# Copy the addon dir and rename it with the version number
print("Copying addon directory to create release directory")
new_version_file_name = "WeaponSwingTimer_V" + new_version
copy_tree('..\WeaponSwingTimer', "..\\" + new_version_file_name)

# Remove the Tools dir from the release
print("Removing Tools directory from release")
shutil.rmtree("..\{new_loc}\Tools".format(new_loc=new_version_file_name))

# Remove all git related items
print("Removing Git related items from release")
shutil.rmtree("..\{new_loc}\.git".format(new_loc=new_version_file_name), onerror=del_rw)
os.remove("..\{new_loc}\.gitignore".format(new_loc=new_version_file_name))

# Remove the Gimp files from Images
print("Removing Gimp files from release")
# TODO: When we actually have a gimp file in there
