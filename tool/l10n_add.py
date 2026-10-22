import json, re, sys

root = 'lib/l10n/'
strings = json.load(open(sys.argv[1]))
for lang, idx in (('en', 0), ('ar', 1)):
    f = root + f'app_{lang}.arb'
    j = json.load(open(f))
    for k, pair in strings.items():
        v = pair[idx]
        j[k] = v
        ph = re.findall(r'\{(\w+)\}', v)
        if lang == 'en' and ph:
            j['@' + k] = {'placeholders': {p: {'type': 'String'} for p in ph}}
    with open(f, 'w') as out:
        json.dump(j, out, ensure_ascii=False, indent=2)
        out.write('\n')
print('added', len(strings))
