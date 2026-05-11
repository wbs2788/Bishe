import re

filepath = "d:/Bishe/Biblio/ref.bib"
with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if re.match(r'^\s*(url|urldate)\s*=.*', line, re.IGNORECASE):
        continue
    new_lines.append(line)

with open(filepath, "w", encoding="utf-8") as f:
    f.writelines(new_lines)
