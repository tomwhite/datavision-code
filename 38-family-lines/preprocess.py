# Write individuals by generation to stdout in JSON format.

# Typical usage:
# python preprocess.py <file.ged> > out.json

import dateparser
import datetime
import json
import sys
from ged4py.parser import GedcomReader
import pandas as pd


def individual_to_dict(indi, gen, include_parents=False):
    p = {
        "id": indi.xref_id,
        "gen": gen,
        "name": indi.name.format(),
        "gender": indi.sex.format()
    }
    birth_date = get_birth_date(indi)
    if birth_date:
        p["birth_date_raw"] = str(birth_date)
        birth_date = parse_date(str(birth_date))
        if birth_date is not None:
            p["birth_date"] = birth_date.isoformat()
    birth_place = get_birth_place(indi)
    if birth_place:
        p["birth_place"] = str(birth_place)
    death_date = get_death_date(indi)
    if death_date:
        p["death_date_raw"] = str(death_date)
        death_date = parse_date(str(death_date))
        if death_date is not None:
            p["death_date"] = death_date.isoformat()
            if "birth_date" in p:
                p["age"] = calculate_age(dateparser.parse(p["birth_date"]), death_date)
    if "birth_date" in p and not "death_date" in p:
        age = calculate_age(dateparser.parse(p["birth_date"]), datetime.date.today())
        if age < 120: # assume that older means death date not recorded
            p["age"] = age
    if include_parents:
        father = indi.father
        if father:
            p["father"] = individual_to_dict(father, gen + 1, False)

        mother = indi.mother
        if mother: 
            p["mother"] = individual_to_dict(mother, gen + 1, False)

    return p

def individual_to_json(indi, gen, include_parents=False):
    d = individual_to_dict(indi, gen, include_parents=include_parents)
    return json.dumps(d)

def get_gender(indi):
    return indi.sub_tag_value("SEX")

def get_birth_date(indi):
    return indi.sub_tag_value("BIRT/DATE")

def get_death_date(indi):
    return indi.sub_tag_value("DEAT/DATE")

def get_birth_place(indi):
    return indi.sub_tag_value("BIRT/PLAC")

def parse_date(s):
    dt = dateparser.parse(s, settings={"DATE_ORDER": "DMY", "PREFER_DAY_OF_MONTH": "first", "RELATIVE_BASE": datetime.datetime(2020, 1, 1)})
    if dt is None:
        #print(f"Cannot parse date '{s}'")
        return None
    return dt.date()

def calculate_age(birth_date, death_date):
    # https://stackoverflow.com/a/9754466
    return death_date.year - birth_date.year - ((death_date.month, death_date.day) < (birth_date.month, birth_date.day))

def parents(indi):
    p = []
    if indi.father is not None and get_birth_place(indi.father) is not None:
        p.append(indi.father)
    if indi.mother is not None and get_birth_place(indi.mother) is not None:
        p.append(indi.mother)
    return p

def previous_generation(individuals):
    return [parents(indi) for indi in individuals]

def flatten(l):
    return [item for sublist in l for item in sublist]

if __name__ == "__main__":

    with GedcomReader(sys.argv[1]) as parser:

        individuals = []
        generations = []
        
        indi = next(parser.records0("INDI"))
        generations.append(individual_to_dict(indi, 0, True))
        individuals.append(generations)

        l = [indi]
        gen = 0
        while len(l) > 0:
            l = flatten(previous_generation(l))
            gen += 1
            generations = []
            for indi in l:
                generations.append(individual_to_dict(indi, gen, True))
            individuals.append(generations)
        
        print(json.dumps(individuals, indent=4))
