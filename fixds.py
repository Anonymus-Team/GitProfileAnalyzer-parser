import sys
import argparse

import pandas as pd

DESCRIPTION = """Process a dataset of CVs
in order to correct the name of cities,
cut off unrealistic salaries 
and convert them to the same monetary units,
store work experience in months"""

COLUMN_NAMES = ['link', 'salary', 'currency', 'github', 'title', 
                'location', 'gender', 'age', 'experience', 'tags']
REPLACEMENT = {
    'Moscow': 'Москва',
    'Cheboksary': 'Чебоксары',
    'Nalchik': 'Нальчик'}
EXCHANGE_RATE = 75 # USD to RUR
SALARY_LOWER_CUT = 10_000 # RUR

parser = argparse.ArgumentParser(
                    prog='fixds',
                    description=DESCRIPTION)
                    
parser.add_argument('-i', '--input',
                    metavar='FILE_PATH',
                    dest='input_path',
                    help='The path to your raw dataset in .csv format',
                    required=True)
parser.add_argument('-o', '--output',
                    metavar='FILE_PATH',
                    dest='output_path',
                    help='Output path of the processed dataset in .json format',
                    default='out.json')

args = parser.parse_args()


try:
    df = pd.read_csv(args.input_path, names=COLUMN_NAMES)
except Exception as exp:
    print(exp, '\nhint: use options `-h` or `--help` to get help', file=sys.stderr)
    exit(exp.errno)

# fix city names
for old_name, new_name in REPLACEMENT.items():
    df['location'].replace(old_name, new_name, inplace=True)

# convert salary to common currenсy
df.loc[df['currency'] == 'USD', 'salary'] *= EXCHANGE_RATE
df['currency'].replace('USD', 'RUR', inplace=True)

# cut off unrealistic salaries
df = df.loc[df['salary'] >= SALARY_LOWER_CUT]

# drop the 'currency' column
df = df.drop(columns=['currency'])

# convert work experience to months
def experience_to_month(value: str):
    if not value:
        return None
    years, months = value.split(', ')
    return int(years) * 12 + int(months)
df['experience'] = df['experience'].apply(experience_to_month)

# save to .json
to_list = lambda x: str(x).split(';') 
df['tags'] = df['tags'].apply(to_list)

df.to_json(args.output_path, orient="records", force_ascii=False, lines=True)