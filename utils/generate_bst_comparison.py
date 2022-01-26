from argparse import ArgumentParser
from sys import stdin

DICTS = {
    'long': {
        'rax': '%rax',
        'rdi': '%rdi',
        'mov': 'movq',
        'cmp': 'cmpq',
    },
    'default': {
        'rax': '%eax',
        'rdi': '%edi',
        'mov': 'movl',
        'cmp': 'cmpl',
    },
    'short': {
        'rax': '%ax',
        'rdi': '%di',
        'mov': 'movw',
        'cmp': 'cmpw',
    },
    'byte': {
        'rax': '%al',
        'rdi': '%dil',
        'mov': 'movb',
        'cmp': 'cmpb',
    },
}

def generate_comparison(l, d, indent, label_prefix):
    ctr = 0
    
    def printi(*args, **kwargs):
        print(indent, end='')
        print(*args, **kwargs)

    def recurse(values, start, end, suf):
        nonlocal ctr
        if start >= end:
            return []
        else:
            if suf:
                print(f'.L{label_prefix}{suf}:')
            mid = (start + end) // 2
            midval = values[mid]
            if start + 1 < end:
                printi(f'{d["cmp"]} $0x{midval:x}, {d["rdi"]}')
                printi(f'jl .L{label_prefix}{suf}0')
            if start + 2 < end:
                printi(f'jg .L{label_prefix}{suf}1')
            printi(f'{d["mov"]} ${ctr}, {d["rax"]}')
            printi('ret')
            k = (values[mid], ctr)
            ctr += 1
            r1 = recurse(values, start, mid, suf + '0')
            r2 = recurse(values, mid + 1, end, suf + '1')
            return [k] + r1 + r2

    mapping = recurse(l, 0, len(l), '')
    mapping.sort(key=lambda x: x[1])
    print()
    print(mapping)

def parse_arguments():
    parser = ArgumentParser()
    parser.add_argument('--mode', '-m', choices=DICTS.keys(), default='default')
    parser.add_argument('--format', '-f', choices=('int', 'hex'), default='hex')
    parser.add_argument('--label-prefix', '-p', default='')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_arguments()
    base = 16 if args.format == 'hex' else 10
    values = [int(l.strip(), base) for l in stdin.readlines()]
    generate_comparison(values, DICTS[args.mode], '    ', args.label_prefix)

