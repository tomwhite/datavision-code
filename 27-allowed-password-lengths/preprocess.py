import json
import re

def get_match(regex, s):
    matches = re.search(re.compile(regex), s)
    if matches:
        return str(matches.group(1))
    else:
        return ""

print("minlength,maxlength")
with open('data/password-rules.json') as f:
    j = json.load(f)
    for key, val in j.items():
        rules = val["password-rules"]
        min_pattern = re.compile("minlength: (\d)+")
        max_pattern = re.compile("maxlength: (\d)+")
        min, max = get_match("minlength: (\d+)", rules), get_match("maxlength: (\d+)", rules)
        if len(min) > 0 or len(max) > 0:
            print(f"{min},{max}")
