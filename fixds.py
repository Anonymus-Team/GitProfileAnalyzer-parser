import sys
import argparse

import pandas as pd

DESCRIPTION = """Process a dataset of CVs
in order to correct the name of cities,
convert salary into the same monetary units 
and store work experience in months."""

COLUMN_NAMES = ['link', 'salary', 'currency', 'github', 'title', 
                'location', 'gender', 'age', 'experience', 'tags']
REPLACEMENT = {
    'Moscow': 'Москва',
    'Cheboksary': 'Чебоксары',
    'Nalchik': 'Нальчик'}
EXCHANGE_RATE = 75 # USD to RUB

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
                    help='Output path of the processed dataset',
                    default='out.csv')

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
df['currency'].replace('USD', 'RUB', inplace=True)

# work experience to month
def experience_to_month(value: str):
    if not value:
        return None
    years, months = value.split(', ')
    return int(years) * 12 + int(months)

df['experience'] = df['experience'].apply(experience_to_month)

# save dataset to .csv
df.to_csv(args.output_path, index=False)