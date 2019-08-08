import sys
import os
import time
from googletrans import Translator

translator = Translator()

localizations = ['deDE', 'enUS', 'esES', 'esMX', 'frFR', 'itIT', 'koKR', 'ptBR', 'ruRU', 'zhCN', 'zhTW']
google_languages = ['de', 'en', 'es', 'es', 'fr', 'it', 'ko', 'pt', 'ru', 'zh-CN', 'zh-TW']
local_lang_map = dict(zip(localizations, google_languages))

# Process the arguments
input_file_path = os.path.abspath(sys.argv[1])
output_file_path = os.path.abspath(os.path.join(input_file_path, '..', 'localization.lua'))

# Open the given file
print('Attempting to open: {a}'.format(a=input_file_path))
input_strings = list()
translated_strings_dict = dict()
try:
    with open(input_file_path, 'r') as input_handle:
        print('Successfully opened {a}'.format(a=input_file_path))
        for line in input_handle:
            if line.strip() not in input_strings:
                input_strings.append(line.strip())
except FileNotFoundError:
    print('File {a} not found! Exiting...'.format(a=input_file_path))
    exit(1)

# Convert all of the strings into the various languages
for language in google_languages:
    print('Starting translations for {a}'.format(a=language))
    translated_strings_dict[language] = list()
    for line in input_strings:
        print('Translating {a}'.format(a=line.strip()))
        translated_strings_dict[language].append(translator.translate(text=line.strip(), dest=language).text)
print('Done translating')

# Build the localization file.
with open(output_file_path, 'w') as output_handle:
    # Add the stuff at the top of the file
    output_handle.write('local addon_name, addon_data = ...\n\n')
    # Go through each language
    for localization in localizations:
        output_handle.write('if GetLocale() == "{a}" then\n'.format(a=localization))
        google_lang = local_lang_map[localization]
        # Go through each line
        for index, line in enumerate(translated_strings_dict[google_lang]):
            try:
                output_handle.write('\taddon_data["{a}"] = "{b}"\n'.format(a=input_strings[index], b=line))
            except UnicodeEncodeError:
                output_handle.write('\taddon_data["{a}"] = "{b}"\n'.format(a=input_strings[index], b='TODO'))
        output_handle.write('end\n\n')
print('Saving output file to: {a}'.format(a=output_file_path))




